import 'package:flutter/material.dart';

/// Installed once on the root `MaterialApp`; screens must not redo it.
abstract final class KeyboardDismissal {
  /// `manual` is not a real opt-out: a drag starts with a tap outside.
  static ScrollBehavior get scrollBehavior =>
      const MaterialScrollBehavior().copyWith(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      );

  /// Applies to every field below it, even ones passing no handler.
  static Map<Type, Action<Intent>> get tapOutsideActions =>
      <Type, Action<Intent>>{
        EditableTextTapOutsideIntent:
            CallbackAction<EditableTextTapOutsideIntent>(
              onInvoke: (intent) => intent.focusNode.unfocus(),
            ),
      };
}
