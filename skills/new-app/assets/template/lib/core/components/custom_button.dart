import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kit_template_app/core/constants/app_color.dart';
import 'package:kit_template_app/core/constants/app_size.dart';
import 'package:kit_template_app/core/helpers/ui_helpers.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    required this.label,
    required this.onPressed,
    this.enabled = true,
    this.isLoading = false,
    this.expand = true,
    this.borderRadius = 100,
    this.width,
    this.height = AppSize.buttonHeight,
    this.backgroundColor,
    this.foregroundColor = AppColor.white,
    this.disabledBackgroundColor,
    this.disabledForegroundColor,
    this.loadingIndicatorColor,
    this.loadingIndicatorSize = 20,
    this.loadingIndicatorStrokeWidth = 2,
    this.fontSize = 16,
    this.fontWeight = FontWeight.w500,
    this.labelStyle,
    this.contentPadding,
    this.elevation,
    this.side,
    this.shape,
    this.buttonStyle,
    this.leading,
    this.trailing,
    this.spacing = 8,
    this.child,
    this.enableHaptic = true,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool enabled;
  final bool isLoading;
  final bool expand;
  final double borderRadius;
  final double? width;
  final double height;
  final Color? backgroundColor;
  final Color foregroundColor;
  final Color? disabledBackgroundColor;
  final Color? disabledForegroundColor;
  final Color? loadingIndicatorColor;
  final double loadingIndicatorSize;
  final double loadingIndicatorStrokeWidth;
  final double fontSize;
  final FontWeight fontWeight;
  final TextStyle? labelStyle;
  final EdgeInsetsGeometry? contentPadding;
  final double? elevation;
  final BorderSide? side;
  final OutlinedBorder? shape;
  final ButtonStyle? buttonStyle;
  final Widget? leading;
  final Widget? trailing;
  final double spacing;
  final Widget? child;

  /// Fires a light haptic on press; opt out for buttons that shouldn't buzz.
  final bool enableHaptic;

  Widget _buildLabelContent() {
    if (child != null) return child!;

    final text = Text(
      label,
      style: TextStyle(
        color: foregroundColor,
        fontWeight: fontWeight,
        fontSize: fontSize,
      ).merge(labelStyle),
    );
    if (leading == null && trailing == null) return text;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ?leading,
        if (leading != null) SizedBox(width: spacing),
        text,
        if (trailing != null) SizedBox(width: spacing),
        ?trailing,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isInteractive = enabled && !isLoading;
    final tap = onPressed;
    final effectiveOnPressed = (isInteractive && tap != null)
        ? () {
            if (enableHaptic) {
              unawaited(UiHelpers.hapticFeedback(FeedbackType.light));
            }
            tap();
          }
        : null;
    final button = SizedBox(
      height: height,
      child: FilledButton(
        onPressed: effectiveOnPressed,
        style: FilledButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColor.primary,
          foregroundColor: foregroundColor,
          disabledBackgroundColor:
              disabledBackgroundColor ??
              AppColor.primary.withValues(alpha: 0.4),
          disabledForegroundColor: disabledForegroundColor ?? AppColor.white,
          padding: contentPadding,
          elevation: elevation,
          side: side,
          shape:
              shape ??
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
        ).merge(buttonStyle),
        child: isLoading
            ? SizedBox(
                height: loadingIndicatorSize,
                width: loadingIndicatorSize,
                child: CircularProgressIndicator(
                  strokeWidth: loadingIndicatorStrokeWidth,
                  valueColor: AlwaysStoppedAnimation(
                    loadingIndicatorColor ?? foregroundColor,
                  ),
                ),
              )
            : _buildLabelContent(),
      ),
    );

    if (expand) {
      return SizedBox(width: width ?? double.infinity, child: button);
    }

    return width != null ? SizedBox(width: width, child: button) : button;
  }
}
