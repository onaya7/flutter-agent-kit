import 'package:flutter/material.dart';
import 'package:kit_template_app/core/constants/app_color.dart';

/// A gradient used by more than one file belongs here, not inline.
abstract class AppGradient {
  static const primaryDiagonal = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColor.primary, AppColor.primaryLight],
  );
}
