import 'package:flutter/material.dart';

/// Body plus a bottom-pinned action; the body scrolls instead of overflowing.
class PinnedActionLayout extends StatelessWidget {
  const PinnedActionLayout({
    required this.children,
    required this.action,
    this.centered = true,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.actionSpacing = 8,
    super.key,
  });

  final List<Widget> children;

  /// Pinned above the bottom inset: a `CustomButton`, or a `Column` of them.
  final Widget action;

  /// Centres the body in the leftover space; off for top-aligned forms.
  final bool centered;
  final CrossAxisAlignment crossAxisAlignment;

  /// Gap below [action], between it and the screen edge.
  final double actionSpacing;

  @override
  Widget build(BuildContext context) {
    final body = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: crossAxisAlignment,
      children: children,
    );

    return Column(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              child: ConstrainedBox(
                // Fills the viewport so [centered] can centre.
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: centered ? Center(child: body) : body,
              ),
            ),
          ),
        ),
        action,
        SizedBox(height: actionSpacing),
      ],
    );
  }
}
