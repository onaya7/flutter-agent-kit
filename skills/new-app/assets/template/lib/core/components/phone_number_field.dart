import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kit_template_app/config/theme/app_theme_colors.dart';
import 'package:kit_template_app/core/components/custom_inputfield.dart';
import 'package:kit_template_app/core/helpers/phone_country.dart';
import 'package:kit_template_app/core/helpers/phone_input_formatter.dart';

class PhoneNumberField extends StatelessWidget {
  const PhoneNumberField({
    required this.controller,
    this.focusNode,
    this.nextFocus,
    this.labelText,
    this.hintText,
    this.validator,
    this.onChanged,
    this.inputFormatters,
    this.country = PhoneCountry.fallback,
    this.onCountryTap,
    this.variant = InputFieldVariant.standard,
    this.borderRadius,
    this.enabled = true,
    this.textStyle,
    this.contentPadding,
    super.key,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final FocusNode? nextFocus;
  final String? labelText;
  final String? hintText;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final List<TextInputFormatter>? inputFormatters;

  /// Drives the mask, the validator and the flag.
  final PhoneCountry country;
  final VoidCallback? onCountryTap;
  final InputFieldVariant variant;
  final double? borderRadius;
  final bool enabled;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? contentPadding;

  @override
  Widget build(BuildContext context) {
    return CustomInputField(
      variant: variant,
      borderRadius: borderRadius,
      controller: controller,
      currentFocus: focusNode,
      nextFocus: nextFocus,
      labelText: labelText,
      hintText: hintText,
      enabled: enabled,
      textStyle: textStyle,
      contentPadding: contentPadding,
      keyboardType: TextInputType.phone,
      action: nextFocus != null ? TextInputAction.next : TextInputAction.done,
      inputFormatters:
          inputFormatters ?? [PhoneInputFormatter(country: country)],
      validator: validator,
      onChanged: onChanged,
      prefixWidget: _CountrySelector(country: country, onTap: onCountryTap),
      // Unbounded, not null: the 48x48 default minHeight would grow the field.
      prefixIconConstraints: const BoxConstraints(),
    );
  }
}

class _CountrySelector extends StatelessWidget {
  const _CountrySelector({required this.country, this.onTap});

  final PhoneCountry country;
  final VoidCallback? onTap;

  /// The chevron promises a picker, so only show one when there is a choice.
  bool get _selectable => onTap != null && PhoneCountry.supported.length > 1;

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 8),
      child: InkWell(
        onTap: _selectable ? onTap : null,
        borderRadius: BorderRadius.circular(20),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipOval(
              child: SizedBox(
                width: 24,
                height: 24,
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: Text(
                    country.flag,
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
              ),
            ),
            if (_selectable) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: colors.iconLow,
              ),
            ],
            const SizedBox(width: 8),
            Container(width: 1, height: 24, color: colors.stroke),
          ],
        ),
      ),
    );
  }
}
