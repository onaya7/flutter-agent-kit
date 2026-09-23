---
name: add-picker-sheet
description: Build a modal bottom-sheet picker in a flutter-agent-kit app that selects one or many values from a server-provided list, using the static show() + BlocProvider.value + load() recipe. Use when a screen needs a single- or multi-select sheet backed by a cubit.
---

# Add a picker sheet

## 1. Find or add the source cubit
The options come from a `@lazySingleton` cubit that exposes `load()` and emits a freezed
`initial`/`loading`/`success(items)`/`error(message)` state.
- Reuse an existing one if it provides the list.
- For a list several features pick from (categories, countries, tags), create the cubit under
  `lib/core/services/<name>/` with the full datasource → repository → usecase → cubit chain (see
  `add-feature`), and register it in `app_bloc_provider.dart`. Its cache is the reason it is a
  singleton, so it needs no `reset()` unless the options are per-account.
- Make `load()` return early when the state is already `success`, so reopening the sheet doesn't
  refetch.

## 2. Structure the widget
Use a `StatefulWidget` with a `static show()`. `show()` resolves the cubit from the *calling* context
and passes it down with `BlocProvider.value`. The sheet is built in a new subtree, so `context.read`
inside `builder` would fail.

```dart
static Future<List<String>?> show(
  BuildContext context, {
  required List<String> initialSelection,
}) {
  final cubit = context.read<OptionsCubit>();
  return showModalBottomSheet<List<String>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppThemeColors.of(context).cards,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => BlocProvider.value(
      value: cubit,
      child: FractionallySizedBox(
        heightFactor: 0.92,
        child: OptionsPickerSheet(initialSelection: initialSelection),
      ),
    ),
  );
}
```

Take the background from `AppThemeColors.of(context)`. A fixed light constant turns the sheet's
content invisible in dark mode.

## 3. Load in `initState`
```dart
@override
void initState() {
  super.initState();
  _selected = {...widget.initialSelection};
  unawaited(context.read<OptionsCubit>().load());
}
```
Hold the working selection in local state (a `Set` for multi-select), and dispose any
`TextEditingController` you add for search.

## 4. Render all three states
Branch with `.when`/`.maybeWhen`, never `switch`/`is`:
- the list
- `LoadingIndicator`
- `AppErrorState(onRetry: cubit.load)`

## 5. Return the result
- Confirm with a `CustomButton` that calls `UiHelpers.pop(context, _selected.toList())`.
- The caller awaits `OptionsPickerSheet.show(...)` and handles `null` (dismissed) separately from an
  empty list (cleared).
- Put the sheet in the feature's `presentation/widgets/`, or in `lib/core/components/` if two
  features use it. Its public `show()` goes at the top of the file, and the private widget below.
