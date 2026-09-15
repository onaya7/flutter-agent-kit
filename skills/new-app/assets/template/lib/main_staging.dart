import 'package:kit_template_app/bootstrap.dart';
import 'package:kit_template_app/config/flavor/flavor.dart';
import 'package:kit_template_app/config/flavor/flavor_config.dart';

Future<void> main() => bootstrap(
  const FlavorConfig(
    flavor: Flavor.staging,
    envFile: '.env.staging',
    hiveBoxName: 'kit_template_app_staging_box',
  ),
);
