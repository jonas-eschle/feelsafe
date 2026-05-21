/// Security submenu — three PIN configs + biometric toggles + PIN
/// timeout + duress-test row. Spec 06 §Security.
library;

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:guardianangela/core/constants/route_names.dart';
import 'package:guardianangela/core/utils/pin_hasher.dart';
import 'package:guardianangela/core/widgets/pin_keypad.dart';
import 'package:guardianangela/core/widgets/timing_slider.dart';
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
    final hasAppPin = settings?.appPinHash != null;
    final hasSessionEndPin = settings?.sessionEndPinHash != null;
    final hasDuressPin = settings?.duressPinHash != null;
    final notifier = ref.read(settingsControllerProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: Text(l.securityTitle)),
      body: ListView(
        children: [
          _PinRow(
            title: l.securityAppPin,
            hasPin: hasAppPin,
            which: 'app',
            onDisable: () => notifier.setAppPinHash(null),
          ),
          // Spec 06 §Security: biometric toggle is rendered here
          // (immediately under the App PIN row) and is disabled
          // when no App PIN is configured.
          SwitchListTile(
            title: Text(l.securityAppPinBiometric),
            value: settings?.appPinBiometricEnabled ?? false,
            onChanged: hasAppPin
                ? (v) => notifier.setAppPinBiometricEnabled(v)
                : null,
          ),
          _PinRow(
            title: l.securitySessionEndPin,
            hasPin: hasSessionEndPin,
            which: 'sessionEnd',
            onDisable: () => notifier.setSessionEndPinHash(null),
          ),
          SwitchListTile(
            title: Text(l.securitySessionEndPinBiometric),
            value: settings?.sessionEndPinBiometricEnabled ?? false,
            onChanged: hasSessionEndPin
                ? (v) => notifier.setSessionEndPinBiometricEnabled(v)
                : null,
          ),
          _PinRow(
            title: l.securityDuressPin,
            hasPin: hasDuressPin,
            which: 'duress',
            onDisable: () => notifier.setDuressPinHash(null),
          ),
          // Distress-cancel biometric is gated on the App PIN being
          // configured (the cancel flow re-uses the App-PIN keypad).
          SwitchListTile(
            title: Text(l.securityDistressCancelBiometric),
            value: settings?.distressCancelBiometricEnabled ?? false,
            onChanged: hasAppPin
                ? (v) => notifier.setDistressCancelBiometricEnabled(v)
                : null,
          ),
          // Q-DURESS-TEST: lets the user verify the duress PIN works
          // without firing the distress chain. Renders a keypad and
          // confirms a match — never invokes the engine.
          if (hasDuressPin)
            ListTile(
              title: Text(l.securityDuressTest),
              subtitle: Text(l.securityDuressTestSubtitle),
              leading: const Icon(Icons.verified_outlined),
              onTap: () => _testDuressPin(
                context: context,
                duressHash: settings!.duressPinHash!,
                pinTimeoutSeconds: settings.pinTimeoutSeconds,
              ),
            ),
          const Divider(),
          // Spec 11 §DE-1: log-snap slider + direct numeric entry.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TimingSlider(
              label: l.securityPinTimeout,
              seconds: settings?.pinTimeoutSeconds ?? 15,
              onChanged: (v) => notifier.setPinTimeoutSeconds(v.clamp(5, 120)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _testDuressPin({
    required BuildContext context,
    required String duressHash,
    required int pinTimeoutSeconds,
  }) async {
    // Verifies the user's duress PIN is reachable. The keypad runs
    // verify() locally; the engine is *never* invoked, so the user
    // can practice without consequences.
    final pin = await showDialog<String?>(
      context: context,
      builder: (_) => const _DuressTestKeypad(),
    );
    if (pin == null || pin.isEmpty) return;
    final ok = await PinHasher.verify(pin, duressHash);
    if (!context.mounted) return;
    final l = AppLocalizations.of(context);
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text(ok ? l.commonEnabled : l.commonDisabled),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l.commonCancel),
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

class _DuressTestKeypad extends StatefulWidget {
  const _DuressTestKeypad();

  @override
  State<_DuressTestKeypad> createState() => _DuressTestKeypadState();
}

class _DuressTestKeypadState extends State<_DuressTestKeypad> {
  final StringBuffer _buffer = StringBuffer();

  void _onDigit(int d) {
    setState(() => _buffer.write(d));
  }

  void _onBackspace() {
    final current = _buffer.toString();
    if (current.isEmpty) return;
    setState(() {
      _buffer.clear();
      _buffer.write(current.substring(0, current.length - 1));
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l.securityDuressTest),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '•' * _buffer.length,
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 12),
          PinKeypad(onDigit: _onDigit, onBackspace: _onBackspace),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: Text(l.commonCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_buffer.toString()),
          child: Text(l.pinSubmit),
        ),
      ],
    );
  }
}
