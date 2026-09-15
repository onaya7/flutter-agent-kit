import 'package:dio_request_inspector/dio_request_inspector.dart';
import 'package:kit_template_app/config/flavor/flavor_config.dart';

/// Null in production, so the overlay and interceptor stay fully disabled.
DioRequestInspector? appRequestInspector(FlavorConfig config) {
  if (config.isProd) return null;
  return DioRequestInspector(isInspectorEnabled: true, showSummary: false);
}
