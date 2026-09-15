import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kit_template_app/core/constants/app_url.dart';
import 'package:kit_template_app/core/constants/env.dart';
import 'package:kit_template_app/core/error/failure.dart';
import 'package:kit_template_app/core/extensions/either_extension.dart';
import 'package:kit_template_app/core/network_info/api_client.dart';
import 'package:kit_template_app/utils/either_safe_runner.dart';

import '../../helpers/helpers.dart';

void main() {
  late StubHttpAdapter adapter;
  late ApiClient client;

  setUp(() {
    loadTestEnv({'API_BASE_URL': 'https://api.test.example.com'});
    adapter = StubHttpAdapter();
    client = ApiClient(
      Dio()..httpClientAdapter = adapter,
      baseUrl: Env.apiBaseUrl,
    );
  });

  test('getRequest sends the query and returns the envelope', () async {
    adapter.enqueue({
      'data': {'id': 1},
    });

    final result = await client.getRequest(
      path: '${AppUrl.baseUrl}/items',
      query: {'page': 2},
    );

    final request = adapter.requests.single;
    expect(request.method, 'GET');
    expect(
      request.uri.toString(),
      'https://api.test.example.com/items?page=2',
    );
    expect((result.response.data as Map)['data'], {'id': 1});
  });

  test('postRequest sends the JSON body', () async {
    adapter.enqueue({'data': null});

    await client.postRequest(
      path: '${AppUrl.baseUrl}/items',
      body: {'name': 'Notebook'},
    );

    final request = adapter.requests.single;
    expect(request.method, 'POST');
    expect(request.data, {'name': 'Notebook'});
  });

  test('an error envelope reaches the caller as its message', () async {
    adapter.enqueue({'message': 'Name is taken'}, statusCode: 422);

    final result = await const EitherSafeRunner()(
      safeCallback: () => client.postRequest(
        path: '${AppUrl.baseUrl}/items',
        body: <String, dynamic>{},
      ),
    );

    expect(result.leftOrNull, const Failure.serverError('Name is taken'));
  });
}
