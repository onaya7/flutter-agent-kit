import 'package:flutter/material.dart';
import 'package:kit_template_app/config/theme/app_theme_colors.dart';
import 'package:kit_template_app/core/components/caution_badge.dart';
import 'package:kit_template_app/core/components/custom_button.dart';
import 'package:kit_template_app/core/constants/app_color.dart';
import 'package:kit_template_app/core/helpers/ui_helpers.dart';

/// The icon shown atop a [showFeedbackSheet].
enum FeedbackKind { caution, success, error }

/// Confirm sheet: true on primary, false on close, null on barrier dismiss.
Future<bool?> showFeedbackSheet(
  BuildContext context, {
  required FeedbackKind kind,
  required String title,
  required String message,
  required String actionLabel,
  String? secondaryActionLabel,
  bool showClose = false,
  Color? actionColor,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _FeedbackSheet(
      kind: kind,
      title: title,
      message: message,
      actionLabel: actionLabel,
      secondaryActionLabel: secondaryActionLabel,
      showClose: showClose,
      actionColor: actionColor,
    ),
  );
}

class _FeedbackSheet extends StatelessWidget {
  const _FeedbackSheet({
    required this.kind,
    required this.title,
    required this.message,
    required this.actionLabel,
    this.secondaryActionLabel,
    this.showClose = false,
    this.actionColor,
  });

  final FeedbackKind kind;
  final String title;
  final String message;
  final String actionLabel;
  final String? secondaryActionLabel;
  final bool showClose;
  final Color? actionColor;

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.cards,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: colors.fill,
                    borderRadius: BorderRadius.circular(9),
                  ),
                ),
              ),
              if (showClose)
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => UiHelpers.pop(context, false),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        Icons.close_rounded,
                        size: 20,
                        color: colors.subtext,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 28),
              _FeedbackIcon(kind: kind),
              const SizedBox(height: 20),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: colors.textHeading,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.4,
                  color: colors.textSubheading,
                ),
              ),
              const SizedBox(height: 30),
              CustomButton(
                label: actionLabel,
                height: 50,
                borderRadius: 40,
                backgroundColor: actionColor,
                onPressed: () => UiHelpers.pop(context, true),
              ),
              if (secondaryActionLabel != null) ...[
                const SizedBox(height: 12),
                CustomButton(
                  label: secondaryActionLabel!,
                  height: 50,
                  borderRadius: 40,
                  elevation: 0,
                  backgroundColor: colors.cards,
                  foregroundColor: colors.textHeading,
                  side: BorderSide(color: colors.stroke),
                  onPressed: () => UiHelpers.pop(context, false),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _FeedbackIcon extends StatelessWidget {
  const _FeedbackIcon({required this.kind});

  final FeedbackKind kind;

  @override
  Widget build(BuildContext context) {
    return switch (kind) {
      FeedbackKind.success => const SuccessBadge(),
      FeedbackKind.caution => const CautionBadge(color: AppColor.warning),
      FeedbackKind.error => const CautionBadge(color: AppColor.error),
    };
  }
}
