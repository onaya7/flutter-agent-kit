import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Per-flavor constants live on `FlavorConfig`, not here.
abstract class Env {
  static String get apiBaseUrl => dotenv.env['API_BASE_URL'] ?? '';
}
