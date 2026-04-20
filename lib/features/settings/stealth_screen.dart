/// Stealth configuration screen.
library;

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:guardianangela/domain/models/app_defaults.dart';
import 'package:guardianangela/domain/models/stealth_config.dart';
import 'package:guardianangela/features/settings/settings_controller.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// Stealth screen.
class StealthScreen extends ConsumerWidget {
  /// Creates the stealth screen.
  const StealthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final settings = ref.watch(settingsControllerProvider).value;
    final stealth = settings?.defaults.stealth ?? const StealthConfig();

    Future<void> update(StealthConfig next) {
      final defaults =
          (settings?.defaults ?? const AppDefaults()).copyWith(stealth: next);
      return ref
          .read(settingsControllerProvider.notifier)
          .setDefaults(defaults);
    }

    return Scaffold(
      appBar: AppBar(title: Text(l.stealthTitle)),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text(l.stealthEnable),
            value: stealth.enabled,
            onChanged: (v) => update(stealth.copyWith(enabled: v)),
          ),
          ListTile(
            title: Text(l.stealthFakeName),
            subtitle: Text(stealth.fakeName),
          ),
          SwitchListTile(
            title: Text(l.stealthNotificationDisguise),
            value: stealth.notificationDisguise,
            onChanged: (v) =>
                update(stealth.copyWith(notificationDisguise: v)),
          ),
          SwitchListTile(
            title: Text(l.stealthTimerDisplay),
            value: stealth.timerDisplay,
            onChanged: (v) => update(stealth.copyWith(timerDisplay: v)),
          ),
          SwitchListTile(
            title: Text(l.stealthSessionScreen),
            value: stealth.sessionScreenStealth,
            onChanged: (v) =>
                update(stealth.copyWith(sessionScreenStealth: v)),
          ),
        ],
      ),
    );
  }
}
