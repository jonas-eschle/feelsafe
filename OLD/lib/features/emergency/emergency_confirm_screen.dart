/// Full-screen pre-dial countdown for the emergency call step.
///
/// Spec 04 §EmergencyCallConfirmationScreen. Navigated to by the
/// SessionScreen when the active session emits an
/// [EmergencyConfirmRequest] on
/// [SessionController.emergencyConfirmationRequests]. Shows a large
/// countdown + a full-width "Cancel call" button. Tapping Cancel
/// disarms the session (which cancels the pending strategy via
/// `isCancelled`, so no real call is placed). When the countdown
/// reaches zero the screen pops itself; the
/// `CallEmergencyStrategy.executeReal` silent delay expires in
/// parallel and the call is dialed.
library;

import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:guardianangela/core/widgets/pin_entry_dialog.dart';
import 'package:guardianangela/features/session/session_controller.dart';
import 'package:guardianangela/features/settings/settings_controller.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';
import 'package:guardianangela/services/service_providers.dart';

/// Pre-dial countdown screen shown before placing an emergency call.
class EmergencyConfirmScreen extends ConsumerStatefulWidget {
  /// Creates the countdown screen.
  const EmergencyConfirmScreen({
    required this.number,
    required this.durationSeconds,
    super.key,
  });

  /// The number that will be dialed when the countdown expires.
  final String number;

  /// Total countdown duration in seconds.
  final int durationSeconds;

  @override
  ConsumerState<EmergencyConfirmScreen> createState() =>
      _EmergencyConfirmScreenState();
}

class _EmergencyConfirmScreenState
    extends ConsumerState<EmergencyConfirmScreen> {
  late int _remaining = widget.durationSeconds;
  Timer? _ticker;
  bool _popped = false;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _remaining -= 1);
      if (_remaining <= 0) {
        _popIfMounted();
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _popIfMounted() {
    if (_popped) return;
    _popped = true;
    _ticker?.cancel();
    if (!mounted) return;
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _onCancel() async {
    if (_popped) return;
    final settings = await ref.read(settingsControllerProvider.future);
    if (!mounted) return;
    final sessionEnd = settings.sessionEndPinHash;
    final controller = ref.read(sessionControllerProvider.notifier);
    // If a session-end PIN is configured, gate the cancel. Otherwise
    // disarm immediately — the user tapped an explicit "Cancel" on
    // a full-screen emergency countdown; no attacker vector.
    if (sessionEnd != null) {
      final result = await showPinEntryDialog(
        context: context,
        sessionEndHash: sessionEnd,
        duressHash: settings.duressPinHash,
        timeout: settings.pinTimeoutSeconds,
        biometric: settings.sessionEndPinBiometricEnabled
            ? ref.read(biometricServiceProvider)
            : null,
      );
      if (!controller.handlePinResult(result)) {
        // Wrong / timeout / cancelled — do not disarm, do not pop.
        return;
      }
    }
    await controller.disarm();
    _popIfMounted();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.errorContainer,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Icon(
                Icons.priority_high,
                size: 80,
                color: theme.colorScheme.onErrorContainer,
              ),
              const SizedBox(height: 16),
              Text(
                l.emergencyConfirmTitle(widget.number),
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: theme.colorScheme.onErrorContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l.emergencyConfirmSubtitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onErrorContainer,
                ),
              ),
              const SizedBox(height: 32),
              // Big countdown digit — rendered standalone so test
              // suites and accessibility readers get a discrete
              // "8" / "7" / ... instead of a templated sentence.
              Text(
                '${_remaining.clamp(0, 999)}',
                textAlign: TextAlign.center,
                style: theme.textTheme.displayLarge?.copyWith(
                  color: theme.colorScheme.onErrorContainer,
                  fontWeight: FontWeight.w700,
                  fontSize: 96,
                ),
              ),
              Text(
                l.emergencyConfirmCountdown(_remaining.clamp(0, 999)),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onErrorContainer,
                ),
              ),
              const Spacer(),
              SizedBox(
                height: 64,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.error,
                    foregroundColor: theme.colorScheme.onError,
                  ),
                  icon: const Icon(Icons.call_end, size: 32),
                  label: Text(
                    l.emergencyConfirmCancel,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: _onCancel,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
