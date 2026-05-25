import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:guardianangela/domain/enums/stealth_timer_display.dart';
import 'package:guardianangela/features/settings_stealth/settings_stealth_controller.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// Stealth settings screen.
///
/// Exposes every `StealthConfig` field. See spec 06 §Stealth Mode.
class SettingsStealthScreen extends ConsumerWidget {
  /// Creates a [SettingsStealthScreen].
  const SettingsStealthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final stateAsync = ref.watch(settingsStealthControllerProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsStealthRow)),
      body: stateAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, _) => Center(child: Text('Error: $e')),
        data: (s) {
          final notifier = ref.read(settingsStealthControllerProvider.notifier);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              SwitchListTile(
                title: Text(l10n.stealthEnabledLabel),
                value: s.config.enabled,
                onChanged: notifier.setEnabled,
              ),
              if (s.config.enabled) ...<Widget>[
                ListTile(
                  title: Text(l10n.stealthFakeNameLabel),
                  subtitle: Text(s.config.fakeName),
                  onTap: () => _editFakeName(context, ref, s.config.fakeName),
                ),
                SwitchListTile(
                  title: Text(l10n.stealthNotificationDisguiseLabel),
                  value: s.config.notificationDisguise,
                  onChanged: notifier.setNotificationDisguise,
                ),
                SwitchListTile(
                  title: Text(l10n.stealthSessionScreenLabel),
                  value: s.config.sessionScreenStealth,
                  onChanged: notifier.setSessionScreenStealth,
                ),
                ListTile(
                  title: Text(l10n.stealthTimerDisplayLabel),
                  trailing: DropdownButton<StealthTimerDisplay>(
                    value: s.config.timerDisplay,
                    onChanged: (StealthTimerDisplay? v) {
                      if (v != null) notifier.setTimerDisplay(v);
                    },
                    items: <DropdownMenuItem<StealthTimerDisplay>>[
                      DropdownMenuItem(
                        value: StealthTimerDisplay.normal,
                        child: Text(l10n.stealthTimerDisplayNormal),
                      ),
                      DropdownMenuItem(
                        value: StealthTimerDisplay.small,
                        child: Text(l10n.stealthTimerDisplaySmall),
                      ),
                      DropdownMenuItem(
                        value: StealthTimerDisplay.none,
                        child: Text(l10n.stealthTimerDisplayNone),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Future<void> _editFakeName(
    BuildContext context,
    WidgetRef ref,
    String current,
  ) async {
    final ctl = TextEditingController(text: current);
    final l10n = AppLocalizations.of(context);
    final res = await showDialog<String>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: Text(l10n.stealthFakeNameLabel),
        content: TextField(controller: ctl, autofocus: true),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(ctl.text),
            child: Text(l10n.commonSave),
          ),
        ],
      ),
    );
    if (res != null) {
      await ref
          .read(settingsStealthControllerProvider.notifier)
          .setFakeName(res);
    }
  }
}
