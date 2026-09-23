import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_exceptions.freezed.dart';

@freezed
sealed class AppException with _$AppException implements Exception {
  const factory AppException.server(String message) = ServerException;
  const factory AppException.noInternet() = NoInternetException;
  const factory AppException.unauthorized(String message) =
      UnauthorizedException;
  const factory AppException.timeout() = TimeoutException;
  const factory AppException.unknown([String? message]) = UnknownException;

  const AppException._();

  factory AppException.fromDioError(DioException e) {
    return switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => const AppException.timeout(),
      DioExceptionType.connectionError => const AppException.noInternet(),
      DioExceptionType.badResponse => AppException._fromResponse(e),
      // transformTimeout exists only from dio 5.11, so it is matched by name
      // rather than referenced, and the wildcard keeps every version exhaustive.
      _ when e.type.name == 'transformTimeout' => const AppException.timeout(),
      _ => AppException.unknown(e.message),
    };
  }

  factory AppException._fromResponse(DioException e) {
    final message = _messageFromData(e.response?.data) ?? 'Server error';
    if (e.response?.statusCode == 401) {
      return AppException.unauthorized(message);
    }
    return AppException.server(message);
  }

  /// Dio gives a `Map` for JSON but a raw `String` for plain-text bodies.
  static String? _messageFromData(dynamic data) {
    dynamic decoded = data;
    if (data is String && data.trim().isNotEmpty) {
      try {
        decoded = jsonDecode(data);
      } on FormatException {
        return null;
      }
    }
    if (decoded is Map) {
      final message = decoded['message'];
      if (message is String && message.trim().isNotEmpty) return message;
    }
    return null;
  }
}
