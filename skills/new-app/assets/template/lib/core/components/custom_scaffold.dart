import 'package:flutter/material.dart';
import 'package:kit_template_app/core/components/custom_appbar.dart';

class CustomScaffold extends StatelessWidget {
  const CustomScaffold({
    required this.body,
    this.title,
    this.appBar,
    this.actions,
    this.leading,
    this.showBackButton = true,
    this.onBackPressed,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.bottomNavigationBar,
    this.bottomSheet,
    this.drawer,
    this.endDrawer,
    this.backgroundColor,
    this.safeArea = true,
    this.padding = const EdgeInsets.all(16),
    this.resizeToAvoidBottomInset,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
    super.key,
  }) : assert(
         appBar == null || title == null,
         'Provide either appBar or title, not both',
       );

  final Widget body;
  final String? title;
  final PreferredSizeWidget? appBar;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? bottomNavigationBar;
  final Widget? bottomSheet;
  final Widget? drawer;
  final Widget? endDrawer;
  final Color? backgroundColor;
  final bool safeArea;
  final EdgeInsetsGeometry padding;
  final bool? resizeToAvoidBottomInset;
  final bool extendBody;
  final bool extendBodyBehindAppBar;

  @override
  Widget build(BuildContext context) {
    final resolvedAppBar =
        appBar ??
        (title != null
            ? CustomAppBar(
                title: title,
                actions: actions,
                leading: leading,
                showBackButton: showBackButton,
                onBackPressed: onBackPressed,
              )
            : null);

    Widget content = Padding(padding: padding, child: body);
    if (safeArea) content = SafeArea(bottom: false, child: content);

    return Scaffold(
      appBar: resolvedAppBar,
      body: content,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomNavigationBar: bottomNavigationBar,
      bottomSheet: bottomSheet,
      drawer: drawer,
      endDrawer: endDrawer,
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      extendBody: extendBody,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
    );
  }
}
