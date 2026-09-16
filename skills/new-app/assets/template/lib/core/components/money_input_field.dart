import 'package:flutter/material.dart';
import 'package:kit_template_app/core/components/custom_inputfield.dart';
import 'package:kit_template_app/core/helpers/money_input_formatter.dart';

/// Digits and one decimal point, thousands-grouped; unformat before send.
class MoneyInputField extends StatelessWidget {
  const MoneyInputField({
    required this.controller,
    super.key,
    this.labelText,
    this.hintText = 'Enter amount',
    this.currencySymbol = r'$',
    this.suffixText,
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.currentFocus,
    this.nextFocus,
    this.maxDecimals = 2,
  });

  final TextEditingController controller;
  final String? labelText;
  final String? hintText;
  final String currencySymbol;
  final String? suffixText;
  final void Function(String)? onChanged;
  final String? Function(String?)? validator;
  final bool enabled;
  final FocusNode? currentFocus;
  final FocusNode? nextFocus;
  final int maxDecimals;

  @override
  Widget build(BuildContext context) {
    return CustomInputField(
      controller: controller,
      currentFocus: currentFocus,
      nextFocus: nextFocus,
      labelText: labelText,
      hintText: hintText,
      enabled: enabled,
      prefixText: '$currencySymbol ',
      suffixText: suffixText,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [MoneyInputFormatter(maxDecimals: maxDecimals)],
      onChanged: onChanged,
      validator: validator,
    );
  }
}
