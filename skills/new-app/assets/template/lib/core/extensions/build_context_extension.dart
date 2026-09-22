import 'package:flutter/material.dart';

extension BuildContextPlatformX on BuildContext {
  /// True on iOS and macOS, for choosing Cupertino chrome over Material.
  ///
  /// Reads the theme rather than `dart:io`'s `Platform.isIOS`, which no widget
  /// test can steer — `debugDefaultTargetPlatformOverride` and `pumpWidget`'s
  /// theme both move this, so both branches stay testable on one machine.
  bool get isApplePlatform => switch (Theme.of(this).platform) {
        TargetPlatform.iOS || TargetPlatform.macOS => true,
        _ => false,
      };
}
