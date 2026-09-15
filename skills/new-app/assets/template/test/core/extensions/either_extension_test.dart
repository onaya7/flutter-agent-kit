import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kit_template_app/core/extensions/either_extension.dart';

void main() {
  group('EitherX', () {
    test('a Right exposes its value and no left', () {
      const Either<String, int> either = Right(42);
      expect(either.rightOrNull, 42);
      expect(either.leftOrNull, isNull);
    });

    test('a Left exposes its value and no right', () {
      const Either<String, int> either = Left('failed');
      expect(either.leftOrNull, 'failed');
      expect(either.rightOrNull, isNull);
    });
  });
}
