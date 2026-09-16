import 'package:flutter/material.dart';
import 'package:kit_template_app/core/constants/app_color.dart';
import 'package:kit_template_app/core/constants/app_gradient.dart';

/// Text painted with a gradient — the app's link and emphasis style.
class GradientText extends StatelessWidget {
  const GradientText(
    this.text, {
    required this.fontSize,
    required this.fontWeight,
    this.gradient = AppGradient.primaryDiagonal,
    this.underline = false,
    super.key,
  });

  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final Gradient gradient;
  final bool underline;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: gradient.createShader,
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          // A ShaderMask paints over the glyphs; the base just has to be opaque.
          color: AppColor.white,
          decoration: underline ? TextDecoration.underline : null,
          decorationColor: AppColor.white,
        ),
      ),
    );
  }
}
