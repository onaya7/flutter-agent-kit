import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:kit_template_app/config/theme/app_theme_colors.dart';
import 'package:kit_template_app/core/components/picker_launcher.dart';

/// Tap-to-pick date field rendering the chosen [date] as `DD/MM/YY`.
class DatePickerField extends StatelessWidget {
  const DatePickerField({required this.date, required this.onTap, super.key});

  final DateTime? date;
  final VoidCallback onTap;

  String get _formatted {
    final d = date!;
    String pad(int value) => value.toString().padLeft(2, '0');
    return '${pad(d.day)}/${pad(d.month)}/${pad(d.year % 100)}';
  }

  @override
  Widget build(BuildContext context) {
    return PickerLauncher(
      value: date == null ? null : _formatted,
      placeholder: 'DD/MM/YY',
      leading: Icon(
        IconsaxPlusLinear.calendar,
        size: 22,
        color: AppThemeColors.of(context).iconLow,
      ),
      onTap: onTap,
    );
  }
}
