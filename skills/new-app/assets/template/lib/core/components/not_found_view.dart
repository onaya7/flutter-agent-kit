import 'package:flutter/material.dart';
import 'package:kit_template_app/config/navigators/routes_names.dart';
import 'package:kit_template_app/core/components/custom_appbar.dart';
import 'package:kit_template_app/core/components/custom_scaffold.dart';
import 'package:kit_template_app/core/components/state_widgets.dart';
import 'package:kit_template_app/core/helpers/ui_helpers.dart';

class NotFoundView extends StatelessWidget {
  const NotFoundView({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: const CustomAppBar(title: '404'),
      padding: EdgeInsets.zero,
      body: AppErrorState(
        title: 'Page not found',
        message:
            'The link you followed may be broken, or the page may have been removed.',
        icon: Icons.link_off_rounded,
        retryLabel: 'Go home',
        onRetry: () => UiHelpers.replaceStack(context, RoutesName.home),
      ),
    );
  }
}
