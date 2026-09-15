import 'package:dartz/dartz.dart';

extension EitherX<L, R> on Either<L, R> {
  L? get leftOrNull => fold((l) => l, (_) => null);

  R? get rightOrNull => fold((_) => null, (r) => r);
}
