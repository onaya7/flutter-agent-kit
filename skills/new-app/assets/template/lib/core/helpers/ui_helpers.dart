import 'dart:async';
import 'dart:io';

import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kit_template_app/core/components/app_loader.dart';
import 'package:kit_template_app/core/constants/app_color.dart';
import 'package:kit_template_app/core/constants/keys.dart';
import 'package:kit_template_app/utils/logger.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

enum FeedbackType { light, medium, heavy, selection, impact }

enum ToastStatus { success, error, info, warning }

abstract class UiHelpers {
  static void showToast(
    String message, {
    ToastStatus status = ToastStatus.info,
    BuildContext? context,
  }) {
    final ctx = Keys.navigatorKey.currentContext ?? context;
    if (ctx == null) return;

    final (icon, color) = switch (status) {
      ToastStatus.success => (
        const Icon(Icons.check_circle_outline, color: AppColor.white),
        AppColor.success,
      ),
      ToastStatus.error => (
        const Icon(Icons.error_outline, color: AppColor.white),
        AppColor.error,
      ),
      ToastStatus.info => (
        const Icon(Icons.info_outline, color: AppColor.white),
        AppColor.info,
      ),
      ToastStatus.warning => (
        const Icon(Icons.warning_amber_outlined, color: AppColor.white),
        AppColor.warning,
      ),
    };

    DelightToastBar(
      autoDismiss: true,
      snackbarDuration: const Duration(seconds: 3),
      position: DelightSnackbarPosition.top,
      builder: (_) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            icon,
            const Gap(10),
            Expanded(
              child: Text(
                message,
                maxLines: 2,
                style: const TextStyle(
                  color: AppColor.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Gap(10),
            GestureDetector(
              onTap: DelightToastBar.removeAll,
              child: const Icon(Icons.close, color: AppColor.white, size: 15),
            ),
          ],
        ),
      ),
    ).show(ctx);
  }

  /// Context-free; always pair with [hideLoader], ideally in a `finally`.
  static void showLoader() => AppLoader.show();

  static void hideLoader() => AppLoader.hide();

  /// Context-free, so safe from any callback.
  static void dismissKeyboard() =>
      FocusManager.instance.primaryFocus?.unfocus();

  static void shiftFocus(
    BuildContext context,
    FocusNode? currentFocus,
    FocusNode? nextFocus,
  ) {
    currentFocus?.unfocus();
    if (nextFocus != null) FocusScope.of(context).requestFocus(nextFocus);
  }

  static void navigateTo(
    BuildContext context,
    String routeName, {
    Map<String, String>? pathParameters,
    Map<String, dynamic>? queryParameters,
    Object? extra,
  }) {
    logger.i('Navigating to $routeName');
    unawaited(
      context.pushNamed(
        routeName,
        pathParameters: pathParameters ?? const {},
        queryParameters: queryParameters ?? const {},
        extra: extra,
      ),
    );
  }

  /// Like [navigateTo], but returns the value the route pops with.
  static Future<T?> navigateForResult<T>(
    BuildContext context,
    String routeName, {
    Map<String, String>? pathParameters,
    Map<String, dynamic>? queryParameters,
    Object? extra,
  }) {
    logger.i('Navigating to $routeName (awaiting result)');
    return context.pushNamed<T>(
      routeName,
      pathParameters: pathParameters ?? const {},
      queryParameters: queryParameters ?? const {},
      extra: extra,
    );
  }

  static void replace(
    BuildContext context,
    String routeName, {
    Map<String, String>? pathParameters,
    Map<String, String>? queryParameters,
    Object? extra,
  }) {
    logger.i('Replacing with $routeName');
    context.pushReplacementNamed(
      routeName,
      pathParameters: pathParameters ?? const {},
      queryParameters: queryParameters ?? const {},
      extra: extra,
    );
  }

  static void replaceStack(
    BuildContext context,
    String routeName, {
    Map<String, String>? pathParameters,
    Map<String, String>? queryParameters,
    Object? extra,
  }) {
    logger.i('Replacing stack with $routeName');
    context.goNamed(
      routeName,
      pathParameters: pathParameters ?? const {},
      queryParameters: queryParameters ?? const {},
      extra: extra,
    );
  }

  static void pop<T extends Object?>(BuildContext context, [T? result]) {
    context.pop(result);
  }

  static Future<bool> showConfirmDialog(
    BuildContext context, {
    String title = 'Are you sure?',
    String message = 'This action cannot be undone.',
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
  }) async {
    if (Platform.isIOS) {
      final result = await showCupertinoDialog<bool>(
        context: context,
        builder: (dialogContext) => CupertinoAlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(cancelLabel),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(confirmLabel),
            ),
          ],
        ),
      );
      return result ?? false;
    }
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(cancelLabel),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColor.error),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  static Future<DateTime?> datePicker(
    BuildContext context, {
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    final initial = initialDate ?? DateTime.now();
    final first = firstDate ?? DateTime(1900);
    final last = lastDate ?? DateTime.now();

    if (!Platform.isIOS) {
      return showDatePicker(
        context: context,
        initialDate: initial,
        firstDate: first,
        lastDate: last,
      );
    }

    DateTime? selectedDate = initial;
    return showCupertinoModalPopup<DateTime>(
      context: context,
      builder: (context) => _CupertinoPickerSheet(
        onDone: () => Navigator.pop(context, selectedDate),
        picker: CupertinoDatePicker(
          initialDateTime: initial,
          minimumDate: first,
          maximumDate: last,
          mode: CupertinoDatePickerMode.date,
          showDayOfWeek: true,
          onDateTimeChanged: (newDate) => selectedDate = newDate,
        ),
      ),
    );
  }

  static Future<TimeOfDay?> timePicker(BuildContext context) async {
    if (!Platform.isIOS) {
      return showTimePicker(context: context, initialTime: TimeOfDay.now());
    }

    var tempDateTime = DateTime.now();
    return showCupertinoModalPopup<TimeOfDay>(
      context: context,
      builder: (context) => _CupertinoPickerSheet(
        onDone: () =>
            Navigator.pop(context, TimeOfDay.fromDateTime(tempDateTime)),
        picker: CupertinoDatePicker(
          initialDateTime: tempDateTime,
          mode: CupertinoDatePickerMode.time,
          use24hFormat: true,
          onDateTimeChanged: (newDate) => tempDateTime = newDate,
        ),
      ),
    );
  }

  static String generateUniqueId() => const Uuid().v1();

  static Future<void> hapticFeedback(FeedbackType type) async {
    try {
      if (Platform.isIOS) {
        switch (type) {
          case FeedbackType.light:
            await HapticFeedback.lightImpact();
          case FeedbackType.medium:
          case FeedbackType.impact:
            await HapticFeedback.mediumImpact();
          case FeedbackType.heavy:
            await HapticFeedback.heavyImpact();
          case FeedbackType.selection:
            await HapticFeedback.selectionClick();
        }
      } else if (Platform.isAndroid) {
        switch (type) {
          case FeedbackType.light:
          case FeedbackType.selection:
            await HapticFeedback.lightImpact();
          case FeedbackType.medium:
          case FeedbackType.impact:
            await HapticFeedback.mediumImpact();
          case FeedbackType.heavy:
            await HapticFeedback.heavyImpact();
        }
      }
    } on Object catch (e) {
      logger.e('Haptic feedback error: $e');
    }
  }

  /// "5MB" rather than "5.0MB", leaving a fractional cap intact.
  static String _readableMb(double megabytes) {
    final isWhole = megabytes == megabytes.truncateToDouble();
    return '${megabytes.toStringAsFixed(isWhole ? 0 : 1)}MB';
  }

  static Future<void> pickImage(
    BuildContext context,
    ImageSource source,
    void Function(File) onImagePicked, {
    double? maxFileSizeInMB,
  }) async {
    await hapticFeedback(FeedbackType.light);
    try {
      final picked = await ImagePicker().pickImage(
        source: source,
        imageQuality: 80,
      );
      if (picked == null) {
        logger.i('No image selected.');
        return;
      }
      final file = File(picked.path);
      if (maxFileSizeInMB != null && context.mounted) {
        if (!await _withinSizeLimit(context, file, maxFileSizeInMB, 'Image')) {
          return;
        }
      }
      onImagePicked(file);
    } on Object catch (e) {
      logger.e('Error picking image: $e');
    }
  }

  /// Restrict with [allowedExtensions]; null allows any type.
  static Future<void> pickFile(
    BuildContext context,
    void Function(File) onPicked, {
    List<String>? allowedExtensions,
    double? maxFileSizeInMB,
  }) async {
    await hapticFeedback(FeedbackType.light);
    try {
      final result = await FilePicker.pickFiles(
        type: allowedExtensions == null ? FileType.any : FileType.custom,
        allowedExtensions: allowedExtensions,
      );
      final path = result?.files.single.path;
      if (path == null) {
        logger.i('No file selected.');
        return;
      }
      final file = File(path);
      if (maxFileSizeInMB != null && context.mounted) {
        if (!await _withinSizeLimit(context, file, maxFileSizeInMB, 'File')) {
          return;
        }
      }
      onPicked(file);
    } on Object catch (e) {
      logger.e('Error picking file: $e');
    }
  }

  static Future<bool> _withinSizeLimit(
    BuildContext context,
    File file,
    double maxFileSizeInMB,
    String noun,
  ) async {
    final sizeMB = await file.length() / (1024 * 1024);
    if (sizeMB <= maxFileSizeInMB) return true;
    logger.e('File size exceeds limit: ${sizeMB.toStringAsFixed(2)} MB');
    if (context.mounted) {
      showToast(
        '$noun size exceeds ${_readableMb(maxFileSizeInMB)} limit. '
        'Please select a smaller ${noun.toLowerCase()}.',
        status: ToastStatus.error,
        context: context,
      );
    }
    return false;
  }

  /// iOS requires a non-zero anchor for a share popover.
  static Rect _defaultSharePositionOrigin(BuildContext context) {
    final box = context.findRenderObject() as RenderBox?;
    if (box != null && box.hasSize && box.size.width > 0) {
      return box.localToGlobal(Offset.zero) & box.size;
    }
    final screen = MediaQuery.sizeOf(context);
    return Rect.fromCenter(
      center: Offset(screen.width / 2, screen.height / 2),
      width: 1,
      height: 1,
    );
  }

  static Future<void> onShareWithResult(
    BuildContext context, {
    String? text,
    String? subject,
    String? uri,
    List<String> imageNames = const [],
    List<String> imagePaths = const [],
    String? successMessage,
    Rect? sharePositionOrigin,
  }) async {
    final origin = sharePositionOrigin ?? _defaultSharePositionOrigin(context);
    final ShareParams params;
    if (imagePaths.isNotEmpty) {
      params = ShareParams(
        files: [
          for (var i = 0; i < imagePaths.length; i++)
            XFile(imagePaths[i], name: imageNames[i]),
        ],
        text: text,
        subject: subject,
        sharePositionOrigin: origin,
      );
    } else if (uri != null && uri.isNotEmpty) {
      params = ShareParams(uri: Uri.parse(uri), sharePositionOrigin: origin);
    } else {
      params = ShareParams(
        text: text,
        subject: subject,
        sharePositionOrigin: origin,
      );
    }
    final shareResult = await SharePlus.instance.share(params);
    if (shareResult.status == ShareResultStatus.success) {
      if (!context.mounted) return;
      showToast(
        successMessage ?? 'Shared',
        status: ToastStatus.success,
        context: context,
      );
      logger.i('Share successful: $shareResult');
    } else {
      logger.e('Share failed: $shareResult');
    }
  }

  static Future<void> copyToClipboard(String text, BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    showToast(
      'Copied to clipboard',
      status: ToastStatus.success,
      context: context,
    );
  }

  /// For destinations the app doesn't host; in-app content belongs in a route.
  static Future<void> openExternalUrl(
    String url, {
    BuildContext? context,
  }) async {
    try {
      final launched = await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
      if (!launched) throw Exception('launchUrl returned false for $url');
    } on Object catch (e) {
      logger.e('Failed to open external url $url: $e');
      if (context != null && !context.mounted) return;
      showToast(
        'Could not open link',
        status: ToastStatus.error,
        context: context,
      );
    }
  }
}

class _CupertinoPickerSheet extends StatelessWidget {
  const _CupertinoPickerSheet({required this.picker, required this.onDone});

  final Widget picker;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      margin: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      color: CupertinoColors.systemBackground.resolveFrom(context),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  CupertinoButton(onPressed: onDone, child: const Text('Done')),
                ],
              ),
            ),
            Expanded(child: picker),
          ],
        ),
      ),
    );
  }
}
