import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:guardianangela/core/theme/guardian_angela_logo.dart';
import 'package:guardianangela/core/widgets/deceptive_old_pin_dialog.dart';
import 'package:guardianangela/core/widgets/pin_keypad.dart';
import 'package:guardianangela/domain/enums/end_reason.dart';
import 'package:guardianangela/domain/models/app_settings.dart';
import 'package:guardianangela/features/launch_gate/launch_gate_controller.dart';
import 'package:guardianangela/features/session/session_controller.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';
import 'package:guardianangela/services/service_providers.dart';

/// App-lock launch gate (spec 06 §App PIN — "all app screens require PIN entry
/// on launch").
///
/// Covers the whole app on cold start whenever an App PIN is set
/// (`AppSettings.appPinHash != null`); the router redirect routes every
/// location here until [LaunchGateController.unlock] is called. Cold-start
/// only — there is no re-lock on resume.
///
/// **Unlock paths (priority ladder mirrors `EndSessionOverlay`, R-27):**
/// - **Biometric** (opt-in, `appPinBiometricEnabled`): tried automatically on
///   mount and re-triggerable via the keypad action key. Success unlocks.
/// - **Duress PIN** (highest hash priority): silently starts the default
///   distress chain ([SessionController.startDistressSession]) and then
///   *fake-unlocks* — the attacker sees the app open normally.
/// - **App PIN**: unlocks.
/// - **Wrong PIN**: shake / deceptive "Old PIN entered" dialog and the shared
///   wrong-PIN counter ticks; at `wrongPinThreshold` the distress chain fires
///   silently and the gate **stays locked** (no visible change to the
///   attacker, spec 06 §Wrong PIN Behavior).
///
/// The Session End PIN is intentionally NOT accepted here — it does not unlock
/// the app (spec 06 auto-submit ladder: App PIN is matched only at App-PIN
/// prompts).
class LaunchPinScreen extends ConsumerStatefulWidget {
  /// Creates a [LaunchPinScreen].
  const LaunchPinScreen({super.key});

  @override
  ConsumerState<LaunchPinScreen> createState() => _LaunchPinScreenState();
}

class _LaunchPinScreenState extends ConsumerState<LaunchPinScreen>
    with SingleTickerProviderStateMixin {
  /// Settings loaded once on mount; null while the future is in flight.
  AppSettings? _settings;

  /// Digits typed at the keypad.
  final List<int> _entry = <int>[];

  /// Whether to render the inline "Incorrect PIN" hint. Defaults to false.
  bool _showWrong = false;

  /// Whether the device has usable biometrics AND the user opted in — drives
  /// the keypad's biometric action key. Defaults to false.
  bool _biometricAvailable = false;

  late final AnimationController _shakeCtl;
  late final Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _shakeCtl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _shakeAnim = Tween<double>(
      begin: 0,
      end: 8,
    ).animate(CurvedAnimation(parent: _shakeCtl, curve: Curves.elasticIn));
    _init();
  }

  Future<void> _init() async {
    final settings = await ref.read(appSettingsRepositoryProvider).load();
    if (!mounted) return;
    setState(() => _settings = settings);
    if (!settings.appPinBiometricEnabled) return;
    final available = await ref.read(biometricServiceProvider).isAvailable();
    if (!mounted) return;
    setState(() => _biometricAvailable = available);
    if (available) {
      await _tryBiometric();
    }
  }

  @override
  void dispose() {
    _shakeCtl.dispose();
    super.dispose();
  }

  Future<void> _tryBiometric() async {
    final l10n = AppLocalizations.of(context);
    final ok = await ref
        .read(biometricServiceProvider)
        .authenticate(reason: l10n.launchPinBiometricReason);
    if (!mounted) return;
    if (ok) {
      _unlock();
    }
    // On failure / cancel the keypad stays — the App PIN is the fallback.
  }

  void _unlock() {
    ref.read(sessionControllerProvider.notifier).resetWrongPinAttempts();
    ref.read(launchGateProvider.notifier).unlock();
  }

  Future<void> _onDigit(int d) async {
    setState(() {
      _entry.add(d);
      _showWrong = false;
    });
    if (_entry.length < 4) return;
    await _tryAutoSubmit();
  }

  void _onBackspace() {
    if (_entry.isEmpty) return;
    setState(() {
      _entry.removeLast();
      _showWrong = false;
    });
  }

  Future<void> _tryAutoSubmit() async {
    final settings = _settings;
    if (settings == null) return;
    // Walk every prefix length n in [4..entry.length], Duress > App at each
    // length (spec 06 auto-submit, R-27). Session End PIN is not accepted at
    // the App-lock gate. First match stops the loop.
    for (int n = 4; n <= _entry.length; n++) {
      final digits = _entry.take(n).join();
      final hash = sha256.convert(utf8.encode(digits)).toString();
      if (settings.duressPinHash != null && settings.duressPinHash == hash) {
        await _fireDistress(EndReason.duressPin);
        if (!mounted) return;
        // Fake-normal: the attacker sees the app open while distress runs.
        _unlock();
        return;
      }
      if (settings.appPinHash != null && settings.appPinHash == hash) {
        _unlock();
        return;
      }
    }
    if (_entry.length >= 4) {
      await _handleWrongPin(settings);
    }
  }

  Future<void> _handleWrongPin(AppSettings settings) async {
    final controller = ref.read(sessionControllerProvider.notifier);
    final attempts = controller.notifyWrongPinAttempt();
    await _showWrongFeedback(settings);
    if (!mounted) return;
    if (attempts >= settings.wrongPinThreshold) {
      // Silent distress; the gate STAYS locked — identical shake to any wrong
      // PIN, no visible difference to the attacker (spec 06 §Wrong PIN).
      await _fireDistress(EndReason.wrongPinExhausted);
      if (!mounted) return;
    }
    setState(() {
      _entry.clear();
      _showWrong = true;
    });
  }

  /// Ensures the session controller has finished building (so its async
  /// `build()` cannot clobber the running-session state we are about to set),
  /// then starts the distress chain.
  Future<void> _fireDistress(EndReason reason) async {
    await ref.read(sessionControllerProvider.future);
    if (!mounted) return;
    await ref
        .read(sessionControllerProvider.notifier)
        .startDistressSession(reason: reason);
  }

  Future<void> _showWrongFeedback(AppSettings settings) async {
    if (settings.deceptivePinDialogEnabled) {
      await DeceptiveOldPinDialog.show(context);
      return;
    }
    await _shakeCtl.forward();
    if (!mounted) return;
    _shakeCtl.reset();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext _, BoxConstraints constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight.isFinite
                      ? constraints.maxHeight - 48
                      : 0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const Center(child: GuardianAngelaLogo()),
                    const SizedBox(height: 24),
                    Text(
                      l10n.launchPinTitle,
                      style: textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    AnimatedBuilder(
                      animation: _shakeAnim,
                      builder: (BuildContext _, Widget? child) {
                        return Transform.translate(
                          offset: Offset(_shakeAnim.value, 0),
                          child: child,
                        );
                      },
                      child: Text(
                        List<String>.generate(
                          _entry.length < 4 ? 4 : _entry.length,
                          (int i) => i < _entry.length ? '●' : '○',
                        ).join(' '),
                        style: textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    if (_showWrong) ...<Widget>[
                      const SizedBox(height: 8),
                      Text(
                        l10n.launchPinIncorrect,
                        style: textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 24),
                    PinKeypad(
                      onDigit: _onDigit,
                      onBackspace: _onBackspace,
                      onAction: _biometricAvailable ? _tryBiometric : null,
                      biometricAvailable: _biometricAvailable,
                      actionIcon: _biometricAvailable
                          ? const Icon(Icons.fingerprint)
                          : null,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
