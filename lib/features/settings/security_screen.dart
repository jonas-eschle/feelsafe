/// Security submenu — three PIN configs + PIN timeout.
library;

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:guardianangela/core/constants/route_names.dart';
import 'package:guardianangela/features/settings/settings_controller.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// Security screen.
class SecurityScreen extends ConsumerWidget {
  /// Creates the security screen.
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final settings = ref.watch(settingsControllerProvider).value;
    return Scaffold(
      appBar: AppBar(title: Text(l.securityTitle)),
      body: ListView(
        children: [
          _PinRow(
            title: l.securityAppPin,
            hasPin: settings?.appPinHash != null,
            which: 'app',
            onDisable: () => ref
                .read(settingsControllerProvider.notifier)
                .setAppPinHash(null),
          ),
          _PinRow(
            title: l.securitySessionEndPin,
            hasPin: settings?.sessionEndPinHash != null,
            which: 'sessionEnd',
            onDisable: () => ref
                .read(settingsControllerProvider.notifier)
                .setSessionEndPinHash(null),
          ),
          _PinRow(
            title: l.securityDuressPin,
            hasPin: settings?.duressPinHash != null,
            which: 'duress',
            onDisable: () => ref
                .read(settingsControllerProvider.notifier)
                .setDuressPinHash(null),
          ),
          const Divider(),
          ListTile(
            title: Text(l.securityPinTimeout),
            subtitle: Text('${settings?.pinTimeoutSeconds ?? 15}s'),
          ),
          Slider(
            value: (settings?.pinTimeoutSeconds ?? 15).toDouble(),
            min: 5,
            max: 60,
            divisions: 11,
            label: '${settings?.pinTimeoutSeconds ?? 15}s',
            onChanged: (v) => ref
                .read(settingsControllerProvider.notifier)
                .setPinTimeoutSeconds(v.round()),
          ),
        ],
      ),
    );
  }
}

class _PinRow extends StatelessWidget {
  const _PinRow({
    required this.title,
    required this.hasPin,
    required this.which,
    required this.onDisable,
  });

  final String title;
  final bool hasPin;
  final String which;
  final VoidCallback onDisable;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ListTile(
      title: Text(title),
      subtitle: Text(hasPin ? l.commonEnabled : l.commonDisabled),
      trailing: Wrap(
        spacing: 4,
        children: [
          if (hasPin)
            TextButton(onPressed: onDisable, child: Text(l.securityDisablePin)),
          FilledButton(
            onPressed: () =>
                context.push('${RouteNames.pinSetup}?which=$which'),
            child: Text(hasPin ? l.securityChangePin : l.securitySetPin),
          ),
        ],
      ),
    );
  }
}
