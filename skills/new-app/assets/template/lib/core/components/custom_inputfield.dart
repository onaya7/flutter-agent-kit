import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:kit_template_app/config/theme/app_theme_colors.dart';
import 'package:kit_template_app/core/constants/app_color.dart';
import 'package:kit_template_app/core/helpers/ui_helpers.dart';

enum InputFieldVariant {
  /// The app `InputDecorationTheme`: 30px radius, unfilled.
  standard,

  /// Filled 16px-radius box for bios, notes and comments.
  textArea,

  /// Filled search pill.
  pill,

  /// Underline only, for app-bar search.
  underline,

  /// Invisible border, for composers that draw their own container.
  bare,
}

class CustomInputField extends StatelessWidget {
  const CustomInputField({
    super.key,
    this.variant = InputFieldVariant.standard,

    this.controller,
    this.currentFocus,
    this.nextFocus,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.onSuffixIconTap,

    this.hintText,
    this.labelText,
    this.prefixText,
    this.suffixText,
    this.prefixIcon,
    this.prefixIconPath,
    this.prefixWidget,

    this.enabled = true,
    this.autofocus = false,
    this.isPasswordField = false,
    this.obscureText = false,
    this.action,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.maxlines = 1,
    this.minLines,

    this.filled,
    this.fillColor,
    this.borderRadius,
    this.contentPadding,
    this.prefixIconConstraints,
    this.textStyle,
    this.hintStyle,
    this.cursorColor,
    this.isDense,
    this.isCollapsed,
  });

  final InputFieldVariant variant;

  final TextEditingController? controller;
  final FocusNode? currentFocus;
  final FocusNode? nextFocus;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final VoidCallback? onSuffixIconTap;

  final String? hintText;
  final String? labelText;
  final String? prefixText;
  final String? suffixText;
  final IconData? prefixIcon;
  final String? prefixIconPath;

  /// Escape hatch for a prefix the icon fields can't build; wins over both.
  final Widget? prefixWidget;

  final bool? enabled;
  final bool autofocus;
  final bool isPasswordField;
  final bool obscureText;
  final TextInputAction? action;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxlines;
  final int? minLines;

  final bool? filled;
  final Color? fillColor;
  final double? borderRadius;
  final EdgeInsetsGeometry? contentPadding;
  final BoxConstraints? prefixIconConstraints;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final Color? cursorColor;
  final bool? isDense;
  final bool? isCollapsed;

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);

    final field = TextFormField(
      controller: controller,
      focusNode: currentFocus,
      enabled: enabled,
      autofocus: autofocus,
      maxLines: maxlines,
      minLines: minLines,
      style: textStyle,
      cursorColor: cursorColor,
      textInputAction: _action,
      keyboardType: _keyboardType,
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters,
      obscureText: obscureText,
      obscuringCharacter: '*',
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted ?? _advanceFocus,
      // Not [currentFocus]: a null one made this a no-op.
      onTapOutside: (_) => UiHelpers.dismissKeyboard(),
      decoration: _decoration(context, colors),
    );

    if (labelText == null) return field;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText!,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: colors.textHeading,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 8),
        field,
      ],
    );
  }

  void Function(String)? get _advanceFocus =>
      nextFocus == null ? null : (_) => nextFocus!.requestFocus();

  /// A multiline box keeps its newline key unless given an action or focus.
  TextInputAction get _action {
    if (action != null) return action!;
    if (nextFocus != null) return TextInputAction.next;
    return maxlines == 1 ? TextInputAction.done : TextInputAction.newline;
  }

  /// `newline` asserts unless the keyboard is `multiline`.
  TextInputType? get _keyboardType =>
      _action == TextInputAction.newline && keyboardType == TextInputType.text
      ? TextInputType.multiline
      : keyboardType;

  InputDecoration _decoration(BuildContext context, AppThemeColors colors) {
    final decoration = InputDecoration(
      hintText: hintText,
      hintStyle: hintStyle,
      prefixText: prefixText,
      prefixStyle: prefixText == null
          ? null
          : TextStyle(
              color: colors.textHeading,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
      suffixText: suffixText,
      suffixStyle: suffixText == null
          ? null
          : TextStyle(
              color: colors.subtext,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
      prefixIcon: prefixWidget ?? _prefix(context, colors),
      prefixIconConstraints: prefixIconConstraints,
      suffixIcon: isPasswordField
          ? IconButton(
              onPressed: onSuffixIconTap,
              icon: Icon(
                obscureText
                    ? IconsaxPlusLinear.eye_slash
                    : IconsaxPlusLinear.eye,
                color: colors.iconLow,
              ),
            )
          : null,
      filled: filled,
      fillColor: fillColor,
      contentPadding: contentPadding,
      isDense: isDense,
      isCollapsed: isCollapsed,
      errorMaxLines: 10,
    );

    final style = _style(colors);
    if (style == null) return decoration;

    final fill = fillColor ?? style.fill;
    InputBorder border(Color color, [double? width]) =>
        style.shape(color, width ?? style.width);

    return decoration.copyWith(
      filled: filled ?? fill != null,
      fillColor: fill,
      contentPadding: contentPadding ?? style.padding,
      // Every state is spelled out so the theme's 30px radius can't leak in.
      border: border(style.stroke),
      enabledBorder: border(style.stroke),
      disabledBorder: border(style.stroke),
      focusedBorder: border(style.focusedStroke, style.focusedWidth),
      errorBorder: border(style.errorStroke),
      focusedErrorBorder: border(style.errorStroke, style.focusedWidth),
    );
  }

  /// `null` for [InputFieldVariant.standard]; it defers to the theme.
  _VariantStyle? _style(AppThemeColors colors) => switch (variant) {
    InputFieldVariant.standard => null,
    InputFieldVariant.textArea => _VariantStyle(
      shape: _outline(borderRadius ?? 16),
      stroke: colors.stroke,
      focusedStroke: colors.primary,
      focusedWidth: 1.5,
      fill: colors.cardFill,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    InputFieldVariant.pill => _VariantStyle(
      shape: _outline(borderRadius ?? 100),
      stroke: colors.stroke,
      fill: colors.cards,
      padding: const EdgeInsets.symmetric(vertical: 14),
    ),
    InputFieldVariant.underline => _VariantStyle(
      shape: _underline,
      stroke: colors.stroke,
      padding: const EdgeInsets.symmetric(vertical: 12),
    ),
    // Transparent, not none: the border keeps its inset, so height is stable.
    InputFieldVariant.bare => _VariantStyle(
      shape: _outline(borderRadius ?? 10),
      stroke: Colors.transparent,
      errorStroke: Colors.transparent,
      width: 1.5,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 5),
    ),
  };

  Widget? _prefix(BuildContext context, AppThemeColors colors) {
    if (prefixIcon != null) {
      return Padding(
        padding: const EdgeInsets.only(left: 20, right: 12),
        child: Icon(prefixIcon, size: 20, color: colors.iconLow),
      );
    }
    if (prefixIconPath == null) return null;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SvgPicture.asset(
        prefixIconPath!,
        width: 20,
        height: 20,
        colorFilter: ColorFilter.mode(
          Theme.of(context).inputDecorationTheme.labelStyle?.color ??
              colors.iconLow,
          BlendMode.srcIn,
        ),
      ),
    );
  }
}

typedef _BorderShape = InputBorder Function(Color color, double width);

_BorderShape _outline(double radius) =>
    (color, width) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: BorderSide(color: color, width: width),
    );

InputBorder _underline(Color color, double width) => UnderlineInputBorder(
  borderSide: BorderSide(color: color, width: width),
);

class _VariantStyle {
  const _VariantStyle({
    required this.shape,
    required this.stroke,
    required this.padding,
    this.errorStroke = AppColor.error,
    this.fill,
    this.width = 1,
    Color? focusedStroke,
    double? focusedWidth,
  }) : _focusedStroke = focusedStroke,
       _focusedWidth = focusedWidth;

  final _BorderShape shape;
  final Color stroke;
  final Color errorStroke;
  final Color? fill;
  final double width;
  final EdgeInsetsGeometry padding;

  final Color? _focusedStroke;
  final double? _focusedWidth;

  /// Focus falls back to the resting stroke where a variant draws no highlight.
  Color get focusedStroke => _focusedStroke ?? stroke;
  double get focusedWidth => _focusedWidth ?? width;
}
