import 'dart:async';
import 'dart:developer';

import 'package:device_preview/device_preview.dart';
import 'package:dio_request_inspector/dio_request_inspector.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:kit_template_app/app/presentation/view/app.dart';
import 'package:kit_template_app/config/flavor/flavor_config.dart';
import 'package:kit_template_app/core/app_manager/app_manager.dart';
import 'package:kit_template_app/core/network_info/request_inspector.dart';

/// Delegates init to [AppManager]; owns the tree wrap and zone guard.
Future<void> bootstrap(FlavorConfig config) async {
  assert(
    appFlavor == null || appFlavor == config.flavor.name,
    'Built with --flavor $appFlavor but started the ${config.flavor.name} entry point',
  );
  await runZonedGuarded(
    () async {
      await AppManager.initialize(config);
      runApp(_wrap(config, const App()));
    },
    (error, stack) {
      log('Uncaught zone error', error: error, stackTrace: stack);
    },
  );
}

Widget _wrap(FlavorConfig config, Widget child) {
  var widget = child;
  if (config.enableDevicePreview) {
    widget = DevicePreview(builder: (_) => widget);
  }
  final inspector = appRequestInspector(config);
  if (inspector != null) {
    widget = DioRequestInspectorMain(inspector: inspector, child: widget);
  }
  return widget;
}
