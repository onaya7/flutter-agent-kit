import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_ce/hive.dart';
import 'package:injectable/injectable.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:kit_template_app/config/flavor/flavor_config.dart';
import 'package:kit_template_app/core/constants/env.dart';
import 'package:kit_template_app/core/network_info/api_client.dart';
import 'package:kit_template_app/core/network_info/request_inspector.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

@module
abstract class RegisterModule {
  @lazySingleton
  Box<dynamic> appBox(FlavorConfig config) =>
      Hive.box<dynamic>(config.hiveBoxName);

  @lazySingleton
  InternetConnection get internetConnection => InternetConnection();

  @lazySingleton
  FlutterSecureStorage get secureStorage => const FlutterSecureStorage();

  @lazySingleton
  ApiClient apiClient(Dio dio) => ApiClient(dio, baseUrl: Env.apiBaseUrl);

  @lazySingleton
  Dio dio(FlavorConfig config) {
    final dio = Dio(
      BaseOptions(
        baseUrl: Env.apiBaseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {'Accept': 'application/json'},
      ),
    );
    if (!config.isProd) {
      dio.interceptors.add(
        PrettyDioLogger(requestHeader: true, requestBody: true),
      );
    }
    dio.interceptors.add(
      RetryInterceptor(
        dio: dio,
        retryDelays: const [
          Duration(seconds: 1),
          Duration(seconds: 2),
          Duration(seconds: 3),
        ],
      ),
    );
    final inspector = appRequestInspector(config);
    if (inspector != null) {
      dio.interceptors.add(inspector.getDioRequestInterceptor());
    }
    return dio;
  }
}
