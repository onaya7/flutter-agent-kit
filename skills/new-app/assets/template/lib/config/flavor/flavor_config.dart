import 'package:kit_template_app/config/flavor/flavor.dart';

/// One per `main_*.dart`; native per-flavor config lives in gradle/Xcode.
class FlavorConfig {
  const FlavorConfig({
    required this.flavor,
    required this.envFile,
    required this.hiveBoxName,
    this.enableDevicePreview = false,
  });

  final Flavor flavor;
  final String envFile;
  final String hiveBoxName;
  final bool enableDevicePreview;

  bool get isProd => flavor == Flavor.production;
}
