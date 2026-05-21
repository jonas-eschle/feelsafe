/// Top-level settings hub.
library;

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:guardianangela/core/constants/route_names.dart';
import 'package:guardianangela/domain/models/app_settings.dart';
import 'package:guardianangela/features/settings/settings_controller.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

// Mapping of BCP-47 language codes to their native display names.
// Only the 14 locales that the app ships with need entries here.
const Map<String, String> _localeDisplayNames = {
  'ar': 'العربية',
  'de': 'Deutsch',
  'el': 'Ελληνικά',
  'en': 'English',
  'es': 'Español',
  'fa': 'فارسی',
  'fr': 'Français',
  'he': 'עברית',
  'hi': 'हिन्दी',
  'pl': 'Polski',
  'ru': 'Русский',
  'uk': 'Українська',
  'zh': '中文（简体）',
  'zh_TW': '中文（繁體）',
};

/// Settings hub.
class SettingsScreen extends ConsumerWidget {
  /// Creates the settings screen.
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final settings = ref.watch(settingsControllerProvider).value;
    return Scaffold(
      appBar: AppBar(title: Text(l.settingsTitle)),
      body: ListView(
        children: [
          _NavTile(label: l.settingsSectionProfile, route: RouteNames.profile),
          _NavTile(
            label: l.settingsSectionContacts,
            route: RouteNames.contacts,
          ),
          _NavTile(label: l.settingsSectionModes, route: RouteNames.modes),
          _NavTile(
            label: l.settingsSectionDistressModes,
            route: RouteNames.distressModes,
          ),
          const Divider(),
          _NavTile(
            label: l.settingsSectionSecurity,
            route: RouteNames.settingsSecurity,
          ),
          _NavTile(
            label: l.settingsSectionStealth,
            route: RouteNames.settingsStealth,
          ),
          const Divider(),
          _NavTile(
            label: l.settingsSectionEventDefaults,
            route: RouteNames.eventDefaults,
          ),
          _NavTile(
            label: l.settingsSectionGpsLogging,
            route: RouteNames.gpsLogging,
          ),
          _NavTile(
            label: l.settingsSectionReminderTemplates,
            route: RouteNames.reminderTemplates,
          ),
          _NavTile(
            label: l.settingsSectionBatteryAlert,
            route: RouteNames.batteryAlert,
          ),
          _NavTile(
            label: l.settingsSectionNotifications,
            route: RouteNames.notificationSettings,
          ),
          _NavTile(
            label: l.settingsSectionHistoryRetention,
            route: RouteNames.historyRetention,
          ),
          const Divider(),
          _NavTile(label: l.settingsSectionBackup, route: RouteNames.backup),
          _NavTile(label: l.settingsSectionAbout, route: RouteNames.about),
          _NavTile(
            label: l.settingsSectionFeedback,
            route: RouteNames.feedback,
          ),
          const Divider(),
          _ThemeDropdown(current: settings?.themeMode ?? AppThemeMode.system),
          ListTile(
            title: Text(l.settingsAlarmDnd),
            trailing: Switch(
              value: settings?.alarmDndOverride ?? false,
              onChanged: (v) => ref
                  .read(settingsControllerProvider.notifier)
                  .setAlarmDndOverride(v),
            ),
          ),
          _LanguagePicker(current: settings?.languageCode ?? 'en'),
          _EmergencyNumberTile(current: settings?.emergencyCallNumber ?? '112'),
          SwitchListTile(
            title: Text(l.settingsAlarmGradualVolume),
            value: settings?.alarmGradualVolume ?? false,
            onChanged: (v) => ref
                .read(settingsControllerProvider.notifier)
                .setAlarmGradualVolume(v),
          ),
          if (settings?.alarmGradualVolume ?? false)
            _GradualVolumeDurationSlider(
              seconds: settings?.alarmGradualVolumeDurationSeconds ?? 5,
            ),
          _RedoOnboardingTile(),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({required this.label, required this.route});

  final String label;
  final String route;

  @override
  Widget build(BuildContext context) => ListTile(
    title: Text(label),
    trailing: const Icon(Icons.chevron_right),
    onTap: () => context.push(route),
  );
}

class _ThemeDropdown extends ConsumerWidget {
  const _ThemeDropdown({required this.current});

  final AppThemeMode current;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return ListTile(
      title: Text(l.settingsThemeMode),
      trailing: DropdownButton<AppThemeMode>(
        value: current,
        items: [
          DropdownMenuItem(
            value: AppThemeMode.system,
            child: Text(l.settingsThemeSystem),
          ),
          DropdownMenuItem(
            value: AppThemeMode.light,
            child: Text(l.settingsThemeLight),
          ),
          DropdownMenuItem(
            value: AppThemeMode.dark,
            child: Text(l.settingsThemeDark),
          ),
        ],
        onChanged: (v) {
          if (v != null) {
            ref.read(settingsControllerProvider.notifier).setThemeMode(v);
          }
        },
      ),
    );
  }
}

class _LanguagePicker extends ConsumerWidget {
  const _LanguagePicker({required this.current});

  final String current;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    // Build locale items from the supported locales list, mapping each
    // to a stable language-only code (e.g. zh_TW stays zh_TW).
    final items = AppLocalizations.supportedLocales.map((locale) {
      final code = locale.countryCode != null
          ? '${locale.languageCode}_${locale.countryCode}'
          : locale.languageCode;
      final label = _localeDisplayNames[code] ?? code;
      return DropdownMenuItem<String>(value: code, child: Text(label));
    }).toList();

    // Ensure the current code is represented; fall back to 'en'.
    final effectiveCurrent = items.any((i) => i.value == current)
        ? current
        : 'en';

    return ListTile(
      title: Text(l.settingsLanguagePicker),
      trailing: DropdownButton<String>(
        value: effectiveCurrent,
        items: items,
        onChanged: (v) {
          if (v != null) {
            ref.read(settingsControllerProvider.notifier).setLanguageCode(v);
          }
        },
      ),
    );
  }
}

class _EmergencyNumberTile extends ConsumerWidget {
  const _EmergencyNumberTile({required this.current});

  final String current;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return ListTile(
      title: Text(l.settingsEmergencyNumberLabel),
      subtitle: Text(current),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showDialog(context, ref, l),
    );
  }

  Future<void> _showDialog(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l,
  ) async {
    final ctrl = TextEditingController(text: current);
    final saved = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.settingsEmergencyNumberLabel),
        content: TextField(
          controller: ctrl,
          decoration: InputDecoration(hintText: l.settingsEmergencyNumberHint),
          keyboardType: TextInputType.phone,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(ctrl.text.trim()),
            child: Text(l.settingsEmergencyNumberSave),
          ),
        ],
      ),
    );
    ctrl.dispose();
    if (saved != null && saved.isNotEmpty) {
      await ref
          .read(settingsControllerProvider.notifier)
          .setEmergencyCallNumber(saved);
    }
  }
}

class _GradualVolumeDurationSlider extends ConsumerWidget {
  const _GradualVolumeDurationSlider({required this.seconds});

  final int seconds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return ListTile(
      title: Text(l.settingsAlarmGradualVolumeDuration(seconds)),
      subtitle: Slider(
        value: seconds.toDouble(),
        min: 0,
        max: 30,
        divisions: 30,
        label: '$seconds',
        onChanged: (v) => ref
            .read(settingsControllerProvider.notifier)
            .setAlarmGradualVolumeDuration(v.round()),
      ),
    );
  }
}

class _RedoOnboardingTile extends ConsumerWidget {
  const _RedoOnboardingTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return ListTile(
      title: Text(l.settingsRedoOnboarding),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _confirm(context, ref, l),
    );
  }

  Future<void> _confirm(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l,
  ) async {
    final proceed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.settingsRedoOnboardingConfirm),
        content: Text(l.settingsRedoOnboardingBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l.settingsRedoOnboardingProceed),
          ),
        ],
      ),
    );
    if (proceed != true) return;
    await ref
        .read(settingsControllerProvider.notifier)
        .markOnboardingIncomplete();
    if (context.mounted) context.go(RouteNames.onboarding);
  }
}
