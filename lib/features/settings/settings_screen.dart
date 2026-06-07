import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:guardianangela/core/constants/route_names.dart';
import 'package:guardianangela/core/widgets/settings_tile.dart';
import 'package:guardianangela/domain/enums/app_theme_mode.dart';
import 'package:guardianangela/features/session/session_controller.dart';
import 'package:guardianangela/features/settings/settings_controller.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// Settings hub.
///
/// Shows only Theme + Language inline. Every other setting is a
/// subcategory row. See spec 04 §Settings Screen and spec 06.
class SettingsScreen extends ConsumerWidget {
  /// Creates a [SettingsScreen].
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final stateAsync = ref.watch(settingsControllerProvider);
    final sessionState = ref.watch(sessionControllerProvider).value;
    final sessionRunning =
        sessionState != null &&
        sessionState.activeChain.isNotEmpty &&
        sessionState.phase != SessionPhase.idle &&
        sessionState.phase != SessionPhase.ended;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.homeMenuSettings)),
      body: stateAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, _) => Center(child: Text('Error: $e')),
        data: (state) => ListView(
          children: <Widget>[
            _SectionHeader(text: l10n.settingsGeneralHeader),
            ListTile(
              leading: const Icon(Icons.brightness_6),
              title: Text(l10n.settingsThemeLabel),
              subtitle: Wrap(
                spacing: 8,
                children: <Widget>[
                  for (final m in AppThemeMode.values)
                    ChoiceChip(
                      label: Text(_themeLabel(m, l10n)),
                      selected: state.themeMode == m,
                      onSelected: (bool s) {
                        if (s) {
                          ref
                              .read(settingsControllerProvider.notifier)
                              .setThemeMode(m);
                        }
                      },
                    ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: Text(l10n.settingsLanguageLabel),
              subtitle: Text(state.languageCode),
              onTap: () => _pickLanguage(context, ref, state.languageCode),
            ),
            const Divider(),
            _SectionHeader(text: l10n.settingsConfigurationHeader),
            SettingsTile(
              icon: Icons.person_outline,
              title: l10n.settingsProfileRow,
              onTap: () => context.pushNamed(RouteNames.profile),
            ),
            SettingsTile(
              icon: Icons.shield_outlined,
              title: l10n.settingsSecurityRow,
              subtitle: l10n.settingsSecuritySubtitle,
              onTap: () => context.pushNamed(RouteNames.settingsSecurity),
            ),
            SettingsTile(
              icon: Icons.visibility_off_outlined,
              title: l10n.settingsStealthRow,
              subtitle: state.stealthEnabled
                  ? l10n.settingsStealthSummaryOn
                  : l10n.settingsStealthSummaryOff,
              onTap: () => context.pushNamed(RouteNames.settingsStealth),
            ),
            SettingsTile(
              icon: Icons.directions_walk,
              title: l10n.settingsModesRow,
              onTap: () => context.pushNamed(RouteNames.modes),
            ),
            SettingsTile(
              icon: Icons.warning_amber_outlined,
              title: l10n.settingsDistressModesRow,
              onTap: () => context.pushNamed(RouteNames.distressModes),
            ),
            SettingsTile(
              icon: Icons.tune,
              title: l10n.settingsEventDefaultsRow,
              onTap: () => context.pushNamed(RouteNames.settingsEventDefaults),
            ),
            SettingsTile(
              icon: Icons.location_on_outlined,
              title: l10n.settingsGpsLoggingRow,
              onTap: () => context.pushNamed(RouteNames.settingsGpsLogging),
            ),
            SettingsTile(
              icon: Icons.notifications_outlined,
              title: l10n.settingsRemindersRow,
              onTap: () =>
                  context.pushNamed(RouteNames.settingsReminderTemplates),
            ),
            SettingsTile(
              icon: Icons.notifications_active_outlined,
              title: l10n.settingsNotificationsRow,
              onTap: () => context.pushNamed(RouteNames.settingsNotifications),
            ),
            const Divider(),
            _SectionHeader(text: l10n.settingsAppHeader),
            SettingsTile(
              icon: Icons.history,
              title: l10n.settingsHistoryRetentionRow,
              onTap: () =>
                  context.pushNamed(RouteNames.settingsHistoryRetention),
            ),
            SettingsTile(
              icon: Icons.backup_outlined,
              title: l10n.settingsBackupRow,
              onTap: () => context.pushNamed(RouteNames.settingsBackup),
            ),
            SettingsTile(
              icon: Icons.feedback_outlined,
              title: l10n.settingsFeedbackRow,
              onTap: () => context.pushNamed(RouteNames.settingsFeedback),
            ),
            SettingsTile(
              icon: Icons.info_outline,
              title: l10n.settingsAboutRow,
              onTap: () => context.pushNamed(RouteNames.settingsAbout),
            ),
            if (sessionRunning)
              Tooltip(
                message: l10n.settingsRedoOnboardingActiveSessionTooltip,
                child: ListTile(
                  leading: const Icon(Icons.restart_alt),
                  title: Text(l10n.settingsRedoOnboarding),
                  // spec:04:1951: disabled because a session is active
                  enabled: false,
                ),
              )
            else
              ListTile(
                leading: const Icon(Icons.restart_alt),
                title: Text(l10n.settingsRedoOnboarding),
                onTap: () => _redoOnboarding(context, ref),
              ),
            ListTile(
              leading: const Icon(Icons.local_phone_outlined),
              title: Text(l10n.settingsEmergencyNumberLabel),
              subtitle: Text(state.emergencyCallNumber),
              onTap: () =>
                  _pickEmergencyNumber(context, ref, state.emergencyCallNumber),
            ),
            ListTile(
              leading: const Icon(Icons.article_outlined),
              title: Text(l10n.settingsOssLicenses),
              onTap: () => showLicensePage(
                context: context,
                applicationName: 'Guardian Angela',
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _themeLabel(AppThemeMode m, AppLocalizations l10n) {
    return switch (m) {
      AppThemeMode.light => l10n.settingsThemeLight,
      AppThemeMode.dark => l10n.settingsThemeDark,
      AppThemeMode.system => l10n.settingsThemeSystem,
    };
  }

  Future<void> _pickLanguage(
    BuildContext context,
    WidgetRef ref,
    String current,
  ) async {
    const supported = <String>[
      'en',
      'de',
      'es',
      'fr',
      'ru',
      'zh',
      'zh_TW',
      'hi',
      'fa',
      'uk',
      'pl',
      'el',
      'ar',
      'he',
    ];
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (BuildContext ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            for (final code in supported)
              ListTile(
                title: Text(code),
                trailing: code == current ? const Icon(Icons.check) : null,
                onTap: () => Navigator.of(ctx).pop(code),
              ),
          ],
        ),
      ),
    );
    if (selected != null) {
      await ref.read(settingsControllerProvider.notifier).setLanguage(selected);
    }
  }

  Future<void> _pickEmergencyNumber(
    BuildContext context,
    WidgetRef ref,
    String current,
  ) async {
    final l10n = AppLocalizations.of(context);
    // Curated list of common emergency-services numbers. Country code
    // is shown alongside for clarity.
    const List<(String label, String number)> presets = <(String, String)>[
      ('International (GSM)', '112'),
      ('United States / Canada', '911'),
      ('United Kingdom', '999'),
      ('Australia', '000'),
      ('China', '110'),
      ('Japan', '110'),
      ('India', '112'),
    ];
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (BuildContext ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                l10n.settingsEmergencyNumberCountryPickerTitle,
                style: Theme.of(ctx).textTheme.titleMedium,
              ),
            ),
            for (final (String label, String number) in presets)
              ListTile(
                title: Text(label),
                subtitle: Text(number),
                trailing: number == current ? const Icon(Icons.check) : null,
                onTap: () => Navigator.of(ctx).pop(number),
              ),
          ],
        ),
      ),
    );
    if (selected != null) {
      await ref
          .read(settingsControllerProvider.notifier)
          .setEmergencyCallNumber(selected);
    }
  }

  Future<void> _redoOnboarding(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: Text(l10n.settingsRedoOnboarding),
        content: Text(l10n.settingsRedoOnboardingConfirm),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.commonConfirm),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    await ref.read(settingsControllerProvider.notifier).resetOnboarding();
    if (!context.mounted) return;
    context.goNamed(RouteNames.onboarding);
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        text.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
