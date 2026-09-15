import 'dart:convert';

/// Without one, go_router decodes `extra` into a Map and the cast fails.
class AppExtraCodec extends Codec<Object?, Object?> {
  const AppExtraCodec();

  @override
  Converter<Object?, Object?> get encoder => const _AppExtraEncoder();

  @override
  Converter<Object?, Object?> get decoder => const _AppExtraDecoder();
}

class _AppExtraEncoder extends Converter<Object?, Object?> {
  const _AppExtraEncoder();

  // Register a typed extra as `final Model m => {'t': 'model', 'v': m.toJson()}`.
  @override
  Object? convert(Object? input) => switch (input) {
    null || String() || num() || bool() => input,
    _ => null,
  };
}

class _AppExtraDecoder extends Converter<Object?, Object?> {
  const _AppExtraDecoder();

  @override
  Object? convert(Object? input) => input;
}
