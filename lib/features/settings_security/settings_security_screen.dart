import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:guardianangela/core/constants/route_names.dart';
import 'package:guardianangela/features/settings_security/remove_pin_dialog.dart';
import 'package:guardianangela/features/settings_security/settings_security_controller.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// Security submenu. Bundles all three PINs + biometric + wrong-PIN
/// threshold + deceptive dialog toggle. Spec 04 §Security Submenu
/// (lines 1785–1833).
class SettingsSecurityScreen extends ConsumerWidget {
  /// Creates a [SettingsSecurityScreen].
  const SettingsSecurityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final stateAsync = ref.watch(settingsSecurityControllerProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsSecurityRow)),
      body: stateAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, _) => Center(child: Text('Error: $e')),
        data: (s) => ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            _PinCard(
              type: PinType.app,
              title: l10n.securityAppPinTitle,
              body: l10n.securityAppPinBody,
              infoBody: l10n.securityAppPinInfo,
              isSet: s.appPinSet,
              appBiometricEnabled: s.appBiometricEnabled,
            ),
            const SizedBox(height: 16),
            _PinCard(
              type: PinType.sessionEnd,
              title: l10n.securitySessionEndPinTitle,
              body: l10n.securitySessionEndPinBody,
              infoBody: l10n.securitySessionEndPinInfo,
              isSet: s.sessionEndPinSet,
              sessionEndBiometricEnabled: s.sessionEndBiometricEnabled,
              pinTimeoutSeconds: s.pinTimeoutSeconds,
            ),
            const SizedBox(height: 16),
            _PinCard(
              type: PinType.duress,
              title: l10n.securityDuressPinTitle,
              body: l10n.securityDuressPinBody,
              infoBody: l10n.securityDuressPinInfo,
              isSet: s.duressPinSet,
            ),
            const SizedBox(height: 24),
            Text(l10n.securityWrongPinThresholdLabel),
            Slider(
              value: s.wrongPinThreshold.toDouble(),
              min: 2,
              max: 10,
              divisions: 8,
              label: '${s.wrongPinThreshold}',
              onChanged: (double v) {
                ref
                    .read(settingsSecurityControllerProvider.notifier)
                    .setWrongPinThreshold(v.round());
              },
            ),
            SwitchListTile(
              title: Text(l10n.securityDeceptiveDialogToggle),
              value: s.deceptiveDialogEnabled,
              onChanged: (bool v) {
                ref
                    .read(settingsSecurityControllerProvider.notifier)
                    .setDeceptiveDialog(v);
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// One of the three PIN cards on the security submenu. Session-end is
/// the only card that exposes the biometric toggle and the prompt
/// timeout slider (spec 04:1809–1811).
class _PinCard extends ConsumerWidget {
  const _PinCard({
    required this.type,
    required this.title,
    required this.body,
    required this.infoBody,
    required this.isSet,
    this.sessionEndBiometricEnabled,
    this.pinTimeoutSeconds,
    this.appBiometricEnabled,
  });

  final PinType type;
  final String title;
  final String body;
  final String infoBody;
  final bool isSet;
  final bool? sessionEndBiometricEnabled;
  final int? pinTimeoutSeconds;
  final bool? appBiometricEnabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final pinTypeQuery = switch (type) {
      PinType.app => 'app',
      PinType.sessionEnd => 'sessionEnd',
      PinType.duress => 'duress',
    };
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ListTile(
              title: Row(
                children: <Widget>[
                  Expanded(child: Text(title)),
                  IconButton(
                    icon: const Icon(Icons.info_outline),
                    tooltip: l10n.securityWhatIsThis,
                    onPressed: () => _showInfo(context, l10n),
                  ),
                ],
              ),
              subtitle: Text(body),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: <Widget>[
                  FilledButton(
                    onPressed: () => context.pushNamed(
                      RouteNames.pinSetup,
                      queryParameters: <String, String>{'type': pinTypeQuery},
                    ),
                    child: Text(
                      isSet ? l10n.securityChangePin : l10n.securitySetPin,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (isSet)
                    TextButton(
                      onPressed: () => _confirmClear(context, ref),
                      child: Text(l10n.securityRemovePin),
                    ),
                ],
              ),
            ),
            if (type == PinType.app)
              SwitchListTile(
                title: Text(l10n.securityAppPinBiometric),
                value: appBiometricEnabled ?? false,
                onChanged: (bool v) {
                  ref
                      .read(settingsSecurityControllerProvider.notifier)
                      .setAppBiometric(v);
                },
              ),
            if (type == PinType.sessionEnd) ...<Widget>[
              SwitchListTile(
                title: Text(l10n.securitySessionEndPinBiometric),
                value: sessionEndBiometricEnabled ?? false,
                onChanged: (bool v) {
                  ref
                      .read(settingsSecurityControllerProvider.notifier)
                      .setSessionEndBiometric(v);
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(l10n.securityPinTimeoutLabel),
              ),
              Slider(
                value: (pinTimeoutSeconds ?? 15).toDouble(),
                min: 5,
                max: 120,
                divisions: 23,
                label: '${pinTimeoutSeconds ?? 15}s',
                onChanged: (double v) {
                  ref
                      .read(settingsSecurityControllerProvider.notifier)
                      .setPinTimeout(v.round());
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _showInfo(BuildContext context, AppLocalizations l10n) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: Text(title),
        content: Text(infoBody),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.commonClose),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmClear(BuildContext context, WidgetRef ref) async {
    // Require the current PIN before removing it: an attacker holding the
    // unlocked device must not be able to wipe the victim's PIN protection
    // with a one-tap "are you sure?" (spec 06 §Security).
    final verified = await RemovePinDialog.show(
      context,
      type: type,
      title: title,
    );
    if (verified) {
      await ref
          .read(settingsSecurityControllerProvider.notifier)
          .clearPin(type);
    }
  }
}
