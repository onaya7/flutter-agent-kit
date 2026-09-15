import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kit_template_app/app/presentation/bloc/app_bloc.dart';
import 'package:kit_template_app/core/components/custom_scaffold.dart';
import 'package:kit_template_app/core/constants/app_size.dart';
import 'package:kit_template_app/features/settings/presentation/widgets/settings_section.dart';
import 'package:kit_template_app/l10n/l10n.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return CustomScaffold(
      title: l10n.settingsTitle,
      body: BlocBuilder<AppBloc, AppState>(
        builder: (context, state) {
          final (themeMode, languageCode) = state.maybeWhen(
            ready: (themeMode, languageCode) => (themeMode, languageCode),
            orElse: () => (AppThemeMode.system, 'en'),
          );
          return ListView(
            children: [
              SettingsSection(
                label: l10n.settingsThemeLabel,
                child: SegmentedButton<AppThemeMode>(
                  showSelectedIcon: false,
                  segments: [
                    ButtonSegment(
                      value: AppThemeMode.system,
                      label: Text(l10n.settingsThemeSystem),
                    ),
                    ButtonSegment(
                      value: AppThemeMode.light,
                      label: Text(l10n.settingsThemeLight),
                    ),
                    ButtonSegment(
                      value: AppThemeMode.dark,
                      label: Text(l10n.settingsThemeDark),
                    ),
                  ],
                  selected: {themeMode},
                  onSelectionChanged: (selection) => context
                      .read<AppBloc>()
                      .add(AppEvent.themeChanged(selection.single)),
                ),
              ),
              AppSize.h(24),
              SettingsSection(
                label: l10n.settingsLanguageLabel,
                child: SegmentedButton<String>(
                  showSelectedIcon: false,
                  segments: [
                    ButtonSegment(
                      value: 'en',
                      label: Text(l10n.settingsLanguageEnglish),
                    ),
                    ButtonSegment(
                      value: 'es',
                      label: Text(l10n.settingsLanguageSpanish),
                    ),
                  ],
                  selected: {languageCode},
                  onSelectionChanged: (selection) => context
                      .read<AppBloc>()
                      .add(AppEvent.localeChanged(selection.single)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
