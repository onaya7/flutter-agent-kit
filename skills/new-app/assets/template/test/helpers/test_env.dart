import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Loads [env] over test defaults so `Env` getters resolve without a file.
void loadTestEnv([Map<String, String> env = const {}]) {
  dotenv.testLoad(
    mergeWith: {'API_BASE_URL': 'https://api.example.com', ...env},
  );
}
