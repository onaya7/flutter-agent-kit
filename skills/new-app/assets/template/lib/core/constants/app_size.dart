import 'package:flutter/material.dart';

abstract class AppSize {
  static const double inputHeight = 52;
  static const double buttonHeight = 52;

  static double screenWidth(BuildContext context) =>
      MediaQuery.sizeOf(context).width;

  static double screenHeight(BuildContext context) =>
      MediaQuery.sizeOf(context).height;

  static double statusBarHeight(BuildContext context) =>
      MediaQuery.paddingOf(context).top;

  static double keyboardHeight(BuildContext context) =>
      MediaQuery.viewInsetsOf(context).bottom;

  static double get appBarHeight => kToolbarHeight;

  static double get bottomNavHeight => kBottomNavigationBarHeight;

  static SizedBox w(double? width) => SizedBox(width: width);

  static SizedBox h(double? height) => SizedBox(height: height);
}
