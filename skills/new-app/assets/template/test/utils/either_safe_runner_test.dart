import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kit_template_app/core/error/failure.dart';
import 'package:kit_template_app/core/exception/app_exceptions.dart';
import 'package:kit_template_app/utils/either_safe_runner.dart';

void main() {
  const runner = EitherSafeRunner();

  Future<Either<Failure, int>> run(Exception error) =>
      runner<int>(safeCallback: () async => throw error);

  DioException badResponse(int status, Object? data) {
    final options = RequestOptions(path: '/items');
    return DioException.badResponse(
      statusCode: status,
      requestOptions: options,
      response: Response(
        requestOptions: options,
        statusCode: status,
        data: data,
      ),
    );
  }

  test('returns the callback value on the right', () async {
    final result = await runner<int>(safeCallback: () async => 42);
    expect(result, const Right<Failure, int>(42));
  });

  group('maps an AppException to its Failure', () {
    test('server', () async {
      expect(
        await run(const AppException.server('Down')),
        const Left<Failure, int>(Failure.serverError('Down')),
      );
    });

    test('noInternet', () async {
      expect(
        await run(const AppException.noInternet()),
        const Left<Failure, int>(Failure.noInternet()),
      );
    });

    test('unauthorized', () async {
      expect(
        await run(const AppException.unauthorized('Expired')),
        const Left<Failure, int>(Failure.unauthorized('Expired')),
      );
    });

    test('timeout becomes a server failure', () async {
      final result = await run(const AppException.timeout());
      expect(result.isLeft(), isTrue);
      result.leftMap((failure) => expect(failure, isA<ServerFailure>()));
    });

    test('unknown keeps its message', () async {
      expect(
        await run(const AppException.unknown('Odd')),
        const Left<Failure, int>(Failure.app('Odd')),
      );
    });
  });

  group('maps a DioException through AppException', () {
    test('a JSON error body surfaces its message', () async {
      expect(
        await run(badResponse(422, {'message': 'Name is taken'})),
        const Left<Failure, int>(Failure.serverError('Name is taken')),
      );
    });

    test('a plain-text JSON body is decoded for its message', () async {
      expect(
        await run(badResponse(400, '{"message":"Bad input"}')),
        const Left<Failure, int>(Failure.serverError('Bad input')),
      );
    });

    test('a 401 becomes unauthorized', () async {
      expect(
        await run(badResponse(401, {'message': 'Sign in again'})),
        const Left<Failure, int>(Failure.unauthorized('Sign in again')),
      );
    });

    test('a body without a message falls back to a generic one', () async {
      expect(
        await run(badResponse(500, 'gateway exploded')),
        const Left<Failure, int>(Failure.serverError('Server error')),
      );
    });

    test('a connection error becomes noInternet', () async {
      final error = DioException.connectionError(
        requestOptions: RequestOptions(path: '/items'),
        reason: 'offline',
      );
      expect(
        await run(error),
        const Left<Failure, int>(Failure.noInternet()),
      );
    });
  });

  test('any other exception becomes unknown', () async {
    expect(
      await run(const FormatException('bad json')),
      const Left<Failure, int>(Failure.unknown()),
    );
  });
}
