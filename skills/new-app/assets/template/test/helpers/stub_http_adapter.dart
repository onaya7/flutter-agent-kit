import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// One scripted reply; a `String` body is sent as plain text, anything else as JSON.
class StubResponse {
  const StubResponse(this.body, {this.statusCode = 200});

  final Object? body;
  final int statusCode;
}

/// Records every request and answers them, in order, from [enqueue]d replies.
class StubHttpAdapter implements HttpClientAdapter {
  final List<RequestOptions> requests = [];
  final List<StubResponse> _replies = [];

  void enqueue(Object? body, {int statusCode = 200}) =>
      _replies.add(StubResponse(body, statusCode: statusCode));

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    if (_replies.isEmpty) {
      throw StateError('No stubbed reply for ${options.method} ${options.uri}');
    }
    final reply = _replies.removeAt(0);
    final body = reply.body;
    final isText = body is String;
    return ResponseBody.fromString(
      isText ? body : jsonEncode(body),
      reply.statusCode,
      headers: {
        Headers.contentTypeHeader: [
          if (isText) Headers.textPlainContentType else Headers.jsonContentType,
        ],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
