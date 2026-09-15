---
name: paginate-list
description: Add incremental loading (loadMore, hasMore, page merge) plus infinite scroll to a list screen in a flutter-agent-kit app whose endpoint returns totalPages/totalElements. Use whenever a list endpoint is paginated and the current code only fetches page 1.
---

# Paginate a list

If the app already has a paginated cubit, mirror it instead of inventing a different shape. Search
for `loadMore` under `lib/`.

## 1. Confirm the endpoint is paginated
The response model must carry `totalPages` / `totalElements` and a `content` list. If it doesn't,
stop: there's nothing to paginate.

## 2. Add a `loadingMore` variant to the state
The union becomes `initial` / `loading` / `loadingMore` / `success(data)` / `error(message)`.
`loadingMore` is separate from `loading` so the view keeps showing existing rows while it appends,
instead of flashing a full-screen spinner.

## 3. Cubit: cache the params, the page and the data

```dart
ParamsType? _cachedParams;
int _cachedPage = 1;
ResultModel? _cachedData;

ResultModel? get cachedData => _cachedData;
bool get hasMore => _cachedPage < (_cachedData?.totalPages ?? 0);
```

**`fetch(params)`**
- Emit `loading`.
- Force `params.copyWith(page: 1)` and cache the params.
- On success, set `_cachedPage = 1` and `_cachedData = data`.

**`loadMore()`**
- Return immediately if `_cachedParams == null || !hasMore`, or if the state is already
  `loadingMore`.
- Emit `loadingMore` and request `page: _cachedPage + 1`.
- On success, **merge**, then advance `_cachedPage`, then emit `success(combined)`:

```dart
final combined = _cachedData!.copyWith(
  content: [..._cachedData!.content, ...data.content],
  totalPages: data.totalPages,
  totalElements: data.totalElements,
);
```

- Merging before advancing the page counter keeps the two consistent if a request fails.
- On failure, **don't emit `error`**; that would replace rows already on screen. Emit
  `success(_cachedData!)` again and leave `_cachedPage` unchanged, so the next scroll retries.

**`reset()`**
- Clear all three fields and emit `initial`.
- Call it when filters change and on sign-out.

The public `hasMore` and `cachedData` getters trigger bloc_lint's
`prefer_void_public_cubit_methods`. That warning is expected here.

## 4. View: trigger near the bottom

```dart
void _onScroll() {
  final cubit = context.read<XCubit>();
  if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200 &&
      cubit.hasMore) {
    unawaited(cubit.loadMore());
  }
}
```

Add the listener in `initState` and dispose the controller in `dispose`. The 200px threshold starts
fetching before the user reaches the end.

## 5. Check
- The view branches on state with `.when`/`.maybeWhen`, never `switch`/`is`, and treats `loadingMore`
  as "show the rows plus a footer spinner".
- The cubit is `@lazySingleton` and registered in `app_bloc_provider.dart`.
- Scrolling past the last page fires no request; `hasMore` turns false on the final page.
- A cubit test covers: first page, a merged second page, a failed `loadMore` that keeps the rows,
  and `reset()`.
- The feature doc's **State** section says the cubit is paginated.
