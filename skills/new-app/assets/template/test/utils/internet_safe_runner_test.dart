import 'package:flutter_test/flutter_test.dart';
import 'package:kit_template_app/core/exception/app_exceptions.dart';
import 'package:kit_template_app/core/network_info/network_info.dart';
import 'package:kit_template_app/utils/internet_safe_runner.dart';
import 'package:mocktail/mocktail.dart';

class _MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late _MockNetworkInfo networkInfo;
  late InternetSafeRunner runner;

  setUp(() {
    networkInfo = _MockNetworkInfo();
    runner = InternetSafeRunner(networkInfo);
  });

  test('runs the callback when connected', () async {
    when(() => networkInfo.isConnected).thenAnswer((_) async => true);

    expect(await runner<String>(safeCallback: () async => 'done'), 'done');
  });

  test('throws noInternet without running the callback when offline', () async {
    when(() => networkInfo.isConnected).thenAnswer((_) async => false);
    var ran = false;

    await expectLater(
      runner<String>(
        safeCallback: () async {
          ran = true;
          return 'done';
        },
      ),
      throwsA(isA<NoInternetException>()),
    );
    expect(ran, isFalse);
  });
}
