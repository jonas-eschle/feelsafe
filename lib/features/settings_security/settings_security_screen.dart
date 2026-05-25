import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:guardianangela/core/constants/route_names.dart';
import 'package:guardianangela/features/settings_security/settings_security_controller.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// Security submenu. Bundles all three PINs + biometric + wrong-PIN
/// threshold + deceptive dialog toggle.
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
              title: l10n.securityAppPinTitle,
              body: l10n.securityAppPinBody,
              isSet: s.appPinSet,
              onConfigure: () => context.pushNamed(
                RouteNames.pinSetup,
                queryParameters: <String, String>{'type': 'app'},
              ),
            ),
            const SizedBox(height: 16),
            _PinCard(
              title: l10n.securitySessionEndPinTitle,
              body: l10n.securitySessionEndPinBody,
              isSet: s.sessionEndPinSet,
              onConfigure: () => context.pushNamed(
                RouteNames.pinSetup,
                queryParameters: <String, String>{'type': 'sessionEnd'},
              ),
            ),
            const SizedBox(height: 16),
            _PinCard(
              title: l10n.securityDuressPinTitle,
              body: l10n.securityDuressPinBody,
              isSet: s.duressPinSet,
              onConfigure: () => context.pushNamed(
                RouteNames.pinSetup,
                queryParameters: <String, String>{'type': 'duress'},
              ),
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
            Text(l10n.securityPinTimeoutLabel),
            Slider(
              value: s.pinTimeoutSeconds.toDouble(),
              min: 5,
              max: 120,
              divisions: 23,
              label: '${s.pinTimeoutSeconds}s',
              onChanged: (double v) {
                ref
                    .read(settingsSecurityControllerProvider.notifier)
                    .setPinTimeout(v.round());
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

class _PinCard extends StatelessWidget {
  const _PinCard({
    required this.title,
    required this.body,
    required this.isSet,
    required this.onConfigure,
  });

  final String title;
  final String body;
  final bool isSet;
  final VoidCallback onConfigure;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(body),
        trailing: FilledButton(
          onPressed: onConfigure,
          child: Text(isSet ? l10n.securityChangePin : l10n.securitySetPin),
        ),
      ),
    );
  }
}
