---
paths:
  - "lib/features/*/data/**"
  - "lib/features/*/domain/**"
  - "lib/core/services/*/**"
  - "lib/core/network_info/**"
  - "lib/core/injections/**"
---

# Data and domain layers

## Layer boundaries: the ones that get violated plausibly
- `domain/` imports no Flutter, and `data/` and `presentation/` never import each other.
- **The model is the currency.** A `data/models/` DTO is what the datasource returns, what the
  repository and usecase hand back, and what the cubit holds in its state. `domain/` imports it.
  Do not mirror a wire row with a second class that carries the same fields.
- `domain/entities/` is for what the wire does not give you: enums, drafts a screen builds up,
  action outcomes, onboarding stages, and params objects shared by more than one usecase.
  **It is created when something needs it, not scaffolded up front**, so in most apps it will not
  exist for a while — and a small app may keep drafts beside the flow that fills them and
  wire-adjacent enums in `data/models/` instead. If that is where yours are, say so here. A rule
  that describes a directory nobody has created sends the next agent to invent one.
- Presentation calls a **usecase**, never a repository directly.
- `lib/core/services/*` are full clean-architecture sub-features and follow these same boundaries,
  even though they live under `core/`.

## The pipeline: datasource → repository → usecase → cubit

**Endpoints** are constants in `AppUrl` (`lib/core/constants/app_url.dart`); the base URL comes
from `Env.apiBaseUrl`. **`ApiClient`** (Retrofit, `lib/core/network_info/api_client.dart`) exposes
generic HTTP verbs only. Never add a per-endpoint method to it.

1. **Datasource:** wrap the call in `InternetSafeRunner`, unwrap the response envelope
   (`(response.data as Map)['data']`), and return `Model.fromJson(...)`. If the backend's envelope
   differs, change it here and in `app_exceptions.dart`, then record the real shape in this rule.
2. **Repository:** wrap the datasource in `EitherSafeRunner` and return `Either<Failure, T>`
   (dartz), mapping `AppException`/`DioException` to a `Failure`. It passes the model straight
   through; return `Unit` when the response carries nothing the app uses.
3. **Usecase:** `@injectable`, extends `UseCase<T, Params>` (`lib/core/usecase/usecase.dart`; use
   `NoParams` when there are none). It only delegates to the repository. A params class lives in
   the usecase file that takes it, not in `entities/`, unless two usecases share it.
4. **Cubit:** see `.claude/rules/state-management.md`.

Read environment values only through `Env` (`lib/core/constants/env.dart`), never with
`dotenv.env[...]` elsewhere.

## The pipeline in code

Endpoints are getters, so `Env` is read after dotenv loads:

```dart
// lib/core/constants/app_url.dart
static String get orders => '$baseUrl/api/v1/orders';
static String cancelOrder(int orderId) => '$baseUrl/api/v1/orders/$orderId';
```

**The model.** Every wire field is nullable, because the backend omits keys it has no value for.
This is the type the whole feature passes around, so a null is resolved where it is read, not
behind a second class that repeats the same fields:

```dart
// data/models/order_model.dart
@freezed
abstract class OrderModel with _$OrderModel {
  const factory OrderModel({
    int? id,
    String? status,
    num? total,
    @Default(<String>[]) List<String> photos,
  }) = _OrderModel;

  factory OrderModel.fromJson(Map<String, dynamic> json) =>
      _$OrderModelFromJson(json);
}
```

**The domain layer.** The contract and the usecase both speak in models; `domain/` importing
`data/models/` is expected here. Return `Unit` from an action whose response the app ignores. A
params class lives in the usecase file that takes it, and moves to `domain/entities/` once a
second usecase needs it:

```dart
// domain/repositories/orders_repository.dart
abstract class OrdersRepository {
  Future<Either<Failure, List<OrderModel>>> getOrders(GetOrdersParams params);
  Future<Either<Failure, Unit>> cancelOrder(int orderId);
}

// domain/usecases/get_orders_usecase.dart
class GetOrdersParams extends Equatable {
  const GetOrdersParams({this.search, this.page = 1, this.size = 20});

  final String? search;
  final int page;
  final int size;

  /// Dio drops null entries, so an unset filter is simply absent.
  Map<String, dynamic> toQuery() => {
    'searchTerm': search,
    'page': page,
    'size': size,
  };

  @override
  List<Object?> get props => [search, page, size];
}

@injectable
class GetOrdersUsecase extends UseCase<List<OrderModel>, GetOrdersParams> {
  GetOrdersUsecase(this._repository);

  final OrdersRepository _repository;

  @override
  Future<Either<Failure, List<OrderModel>>> call(GetOrdersParams params) =>
      _repository.getOrders(params);
}
```

**The data layer.** `InternetSafeRunner` is not in the container: build it in the datasource's
initializer from the injected `NetworkInfo`. `EitherSafeRunner` is const, so the repository holds
one `static const`, and its methods are one line each because nothing is transformed on the way
back.

```dart
// data/datasources/orders_remote_datasource.dart
abstract class OrdersRemoteDatasource {
  Future<List<OrderModel>> getOrders(GetOrdersParams params);
  Future<void> cancelOrder(int orderId);
}

@LazySingleton(as: OrdersRemoteDatasource)
class OrdersRemoteDatasourceImpl implements OrdersRemoteDatasource {
  OrdersRemoteDatasourceImpl({required this.client, required this.networkInfo})
    : internetSafeRunner = InternetSafeRunner(networkInfo);

  final ApiClient client;
  final NetworkInfo networkInfo;
  final InternetSafeRunner internetSafeRunner;

  @override
  Future<List<OrderModel>> getOrders(GetOrdersParams params) {
    return internetSafeRunner<List<OrderModel>>(
      safeCallback: () async {
        final result = await client.getRequest(
          path: AppUrl.orders,
          query: params.toQuery(),
        );
        final data =
            (result.response.data as Map<String, dynamic>)['data']
                as List<dynamic>;
        return data
            .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }
}

// data/repositories/orders_repository_impl.dart
@LazySingleton(as: OrdersRepository)
class OrdersRepositoryImpl implements OrdersRepository {
  OrdersRepositoryImpl({required this.remote});

  final OrdersRemoteDatasource remote;

  static const _runner = EitherSafeRunner();

  @override
  Future<Either<Failure, List<OrderModel>>> getOrders(GetOrdersParams params) {
    return _runner<List<OrderModel>>(
      safeCallback: () => remote.getOrders(params),
    );
  }

  @override
  Future<Either<Failure, Unit>> cancelOrder(int orderId) {
    return _runner<Unit>(
      safeCallback: () async {
        await remote.cancelOrder(orderId);
        return unit;
      },
    );
  }
}
```

The cubit that consumes `GetOrdersUsecase` is in `.claude/rules/state-management.md`, and the view
that consumes the cubit is in `.claude/rules/ui-conventions.md`. Both hold `OrderModel`.

## Mappers: the two kinds that earn their place
Neither one exists to satisfy a layer boundary, and **neither is scaffolded up front**. Until the
work outgrows it, reshaping is an extension sitting next to the thing it reshapes, or a getter on
the model itself — that is the lighter idiom and it is usually the right one. Add a directory only
when there is real work to do, and record here which of the two your app actually has.

- `presentation/mappers/`: an extension that reshapes a model into what a widget takes — a status
  enum, a label, a row's view data, or one model rebuilt as another so a fetched item and a
  list-supplied one take the same path.
- `data/mappers/`: a `toEntity()` extension for the case where two sources describe the same thing
  differently — a REST payload and a socket frame, say — and the app needs one normalized type to
  reason about. That entity belongs in `domain/entities/`, and the mapper is where the wire's
  inconsistencies stop.

## DI annotations
| Kind | Annotation |
|---|---|
| Datasource, repository | `@LazySingleton(as: <AbstractType>)` |
| …the same, but concrete with no abstraction | `@lazySingleton` — an interceptor extending a package base class has nothing to register *as* |
| Usecase | `@injectable` |
| Cubit, bloc | `@lazySingleton` — mounted in `app_bloc_provider.dart`; route-scope the exceptions |

- The container is `lib/core/injections/injection.dart` (`sl`, `configureDependencies()`).
- Third-party singletons (Dio, `ApiClient`, the Hive box, secure storage, connectivity) are
  registered by hand in `register_module.dart`.
- **Never hand-edit `injection.config.dart`**; rerun codegen.
- New Hive adapters go in `registerHiveAdapters()`
  (`lib/app/presentation/view/app_hive_adapters.dart`), kept in alphabetical order.

## Storage
- Tokens, credentials and personal data go in `SecureLocalDataStorage`, **never** in Hive.
- Preferences and caches go in `LocalDataStorage` (Hive CE).

**Group the keys by destination and assert the grouping.** A heading such as `// Hive —
non-sensitive` above a key list is a claim, not a guarantee: a credential filed under it reads as
approved. Have the conventions test fail when a credential-shaped name reaches the plaintext store.

**A model is the wrong place to hold a secret it does not need.** Where a screen reveals something
sensitive — a card PAN, a full account number — split it: the persisted model keeps what every
screen shows (a last-four, a masked tail), and a second model carries the secret, is fetched on
reveal, and lives in memory only. Give that second model **no `fromJson`/`toJson` at all**, so it
cannot be serialised even by mistake and the guarantee is structural rather than a convention.

## JSON models: silent traps
- json_serializable silently drops keys the model doesn't declare, so a typo in a `@JsonKey` name
  reads as `null` rather than failing.
- **Every wire-facing enum carries an `unknown` arm, and every enum-typed field carries
  `@JsonKey(unknownEnumValue: X.unknown)`.** Without it one unrecognised value throws inside
  `fromJson`, which the repository's runner reports as a generic failure — so a backend adding a
  category reads to the user as "something went wrong". Map wire names with `@JsonValue`. A purely
  cosmetic enum may point at its existing default instead of growing an arm nothing can render.
  Prose alone does not hold this: assert it in the conventions test.
- A null `int?` printed with `toString()` becomes the string `"null"`, so format nullable values
  explicitly.
- When you add or widen a model, add a contract test that decodes captured server JSON from
  `test/fixtures/<feature>/`.

## Known limitation
`AppException` parses only `response.data['message']`. Every other 4xx/5xx detail collapses into
`ServerFailure`, so the UI cannot branch on status codes or read validation payloads. Extend
`app_exceptions.dart` when a feature needs that detail.
