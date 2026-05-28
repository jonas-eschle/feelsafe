import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:guardianangela/core/widgets/deceptive_old_pin_dialog.dart';
import 'package:guardianangela/core/widgets/pin_keypad.dart';
import 'package:guardianangela/core/widgets/swipe_slider.dart';
import 'package:guardianangela/domain/enums/end_reason.dart';
import 'package:guardianangela/domain/models/app_settings.dart';
import 'package:guardianangela/features/session/session_controller.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';
import 'package:guardianangela/services/service_providers.dart';

/// Outcome the [EndSessionOverlay] reports back to the session screen.
///
/// The session screen translates each outcome into the appropriate
/// controller call + navigation:
///
/// - [EndSessionOutcome.dismissed]: user tapped Cancel or backed out —
///   the screen does nothing.
/// - [EndSessionOutcome.endConfirmed]: swipe + (optional) correct PIN —
///   the screen calls `controller.endSession()` and navigates to
///   `/session/completed`.
/// - [EndSessionOutcome.duressPinEntered]: user entered the Duress PIN
///   at the prompt — the screen calls
///   `controller.confirmDistress(reason: EndReason.duressPin)` so the
///   distress chain replaces the main chain.
/// - [EndSessionOutcome.wrongPinExhausted]: wrong-PIN counter reached
///   `AppSettings.wrongPinThreshold` in a real session — the screen
///   calls `controller.confirmDistress(reason: EndReason.wrongPinExhausted)`.
enum EndSessionOutcome {
  /// User cancelled or backed out without ending the session.
  dismissed,

  /// Swipe (and PIN if required) succeeded — end the session cleanly.
  endConfirmed,

  /// User typed the Duress PIN; fire the distress chain silently.
  duressPinEntered,

  /// Wrong-PIN counter hit the threshold; fire the distress chain
  /// silently (real sessions only — simulation reports a SnackBar).
  wrongPinExhausted,
}

/// Internal stages of the [EndSessionOverlay] state machine.
enum _Stage {
  /// Showing the heading + Cancel + SwipeSlider.
  swipe,

  /// Showing the PIN keypad (only when `sessionEndPinHash` is set).
  pin,
}

/// Fullscreen overlay shown when the user taps the session screen's
/// End-Session app-bar icon.
///
/// Renders in two stages (spec 04:540-545):
///
/// 1. **Swipe** — heading + body + [SwipeSlider]. Cancel returns
///    [EndSessionOutcome.dismissed].
/// 2. **PIN** — appears only when `AppSettings.sessionEndPinHash` is
///    set. Hashes every entered prefix of length `>= 4` and compares
///    against (a) `duressPinHash`, (b) `appPinHash`, (c) `sessionEndPinHash`
///    in that order — Duress wins prefix collisions per R-27. Wrong
///    entries increment the controller's in-memory counter and emit
///    `ChainEvent.deceptiveOldPinShown` for forensics. At the configured
///    `wrongPinThreshold` (default 5) the distress chain fires silently
///    in real sessions; a SnackBar replaces the distress in simulation.
///
/// **Simulation** (spec 04:545): the PIN prompt still shows so users can
/// practice the flow, plus a `[Skip]` button that bypasses the PIN.
/// Wrong PINs still shake / show the deceptive dialog but never count
/// against the threshold and never fire the distress chain.
class EndSessionOverlay extends ConsumerStatefulWidget {
  /// Creates an [EndSessionOverlay].
  ///
  /// [isSimulation] toggles the `[SIM]` badge and the simulation-only
  /// `[Skip]` button. Defaults to false.
  const EndSessionOverlay({
    super.key,
    required this.onOutcome,
    this.isSimulation = false,
  });

  /// Fired with the user's outcome. The overlay also calls
  /// `Navigator.of(context).pop()` right before invoking [onOutcome] so
  /// the caller does not need to dismiss the dialog manually.
  final ValueChanged<EndSessionOutcome> onOutcome;

  /// Whether the surrounding session is a simulation. Drives the `[SIM]`
  /// badge, the `[Skip]` button, and the wrong-PIN suppression rule
  /// (spec 04:545-548). Defaults to false.
  final bool isSimulation;

  /// Convenience launcher that wraps the overlay in
  /// `showDialog<EndSessionOutcome>`, pops it on outcome, and resolves
  /// to the outcome the user picked.
  ///
  /// Returns [EndSessionOutcome.dismissed] when the user backs out
  /// without producing an outcome.
  static Future<EndSessionOutcome> show(
    BuildContext context, {
    required bool isSimulation,
  }) async {
    final result = await showDialog<EndSessionOutcome>(
      context: context,
      barrierColor: Colors.transparent,
      useSafeArea: false,
      builder: (BuildContext ctx) => EndSessionOverlay(
        isSimulation: isSimulation,
        onOutcome: (EndSessionOutcome o) => Navigator.of(ctx).pop(o),
      ),
    );
    return result ?? EndSessionOutcome.dismissed;
  }

  @override
  ConsumerState<EndSessionOverlay> createState() => _EndSessionOverlayState();
}

class _EndSessionOverlayState extends ConsumerState<EndSessionOverlay>
    with SingleTickerProviderStateMixin {
  /// Current stage of the overlay's local state machine.
  _Stage _stage = _Stage.swipe;

  /// Cached settings loaded once on mount; null while the future is in
  /// flight. Defaults to null to signal "still loading".
  AppSettings? _settings;

  /// Digits the user has typed at the PIN keypad.
  final List<int> _entry = <int>[];

  /// Whether to render the inline "Incorrect PIN" hint beneath the
  /// keypad. Defaults to false.
  bool _showWrong = false;

  /// Whether to render the "Use the Session End PIN, not the app lock
  /// PIN" hint beneath the keypad. Defaults to false.
  bool _showAppPinMismatch = false;

  /// Simulation-only local wrong-PIN counter. Drives the educational
  /// SnackBar when the user reaches `wrongPinThreshold` consecutive
  /// wrong entries; never touches the controller's real counter, never
  /// fires the distress chain. Spec 04:548. Defaults to 0.
  int _simWrongAttempts = 0;

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
    // Load settings asynchronously so the swipe stage renders immediately
    // and the PIN priority decision has its data ready when needed.
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await ref.read(appSettingsRepositoryProvider).load();
    if (!mounted) return;
    setState(() => _settings = settings);
  }

  @override
  void dispose() {
    _shakeCtl.dispose();
    super.dispose();
  }

  void _cancel() => widget.onOutcome(EndSessionOutcome.dismissed);

  Future<void> _onSwipeConfirmed() async {
    // Loaded settings may still be null on a very fast swipe — wait one
    // frame so the PIN-resolution branch has the data.
    AppSettings? settings = _settings;
    if (settings == null) {
      settings = await ref.read(appSettingsRepositoryProvider).load();
      if (!mounted) return;
      _settings = settings;
    }
    if (settings.sessionEndPinHash == null) {
      // No PIN configured → swipe is the only gate.
      widget.onOutcome(EndSessionOutcome.endConfirmed);
      return;
    }
    setState(() {
      _stage = _Stage.pin;
      _entry.clear();
      _showWrong = false;
      _showAppPinMismatch = false;
    });
  }

  Future<void> _onDigit(int d) async {
    setState(() {
      _entry.add(d);
      _showWrong = false;
      _showAppPinMismatch = false;
    });
    if (_entry.length < 4) {
      return;
    }
    await _tryAutoSubmit();
  }

  void _onBackspace() {
    if (_entry.isEmpty) return;
    setState(() {
      _entry.removeLast();
      _showWrong = false;
      _showAppPinMismatch = false;
    });
  }

  Future<void> _tryAutoSubmit() async {
    final settings = _settings;
    if (settings == null) return;
    // Walk every prefix length `n in [4..entry.length]` and try the
    // priority ladder. Spec 06 §Auto-submit algorithm (F-149, R-27):
    // Duress > App > Session End. A match at any length stops the loop.
    for (int n = 4; n <= _entry.length; n++) {
      final digits = _entry.take(n).join();
      final hash = sha256.convert(utf8.encode(digits)).toString();
      // (a) Duress PIN — silent distress.
      if (settings.duressPinHash != null && settings.duressPinHash == hash) {
        // Duress always resets the wrong-PIN counter (it's a
        // "successful" entry from the counter's perspective — spec 06
        // §Wrong PIN Behavior, R-27).
        ref.read(sessionControllerProvider.notifier).resetWrongPinAttempts();
        widget.onOutcome(EndSessionOutcome.duressPinEntered);
        return;
      }
      // (b) App PIN — explicit no-op at the Session End gate. The user
      // sees an inline hint and the entry is cleared; this is NOT a
      // wrong-PIN counter increment because the App PIN is a valid
      // configured secret on the device, just not the one this prompt
      // accepts.
      if (settings.appPinHash != null && settings.appPinHash == hash) {
        setState(() {
          _entry.clear();
          _showAppPinMismatch = true;
          _showWrong = false;
        });
        return;
      }
      // (c) Session End PIN — success.
      if (settings.sessionEndPinHash != null &&
          settings.sessionEndPinHash == hash) {
        ref.read(sessionControllerProvider.notifier).resetWrongPinAttempts();
        widget.onOutcome(EndSessionOutcome.endConfirmed);
        return;
      }
    }
    // No match at any length — only fire the wrong-PIN branch when the
    // user has provided enough digits for at least one comparison.
    if (_entry.length >= 4) {
      await _handleWrongPin();
    }
  }

  Future<void> _handleWrongPin() async {
    final settings = _settings;
    if (settings == null) return;

    if (widget.isSimulation) {
      // Simulation rule (spec 04:548): wrong PINs still surface the
      // shake / deceptive dialog so the user can practice the flow, but
      // the real failure counter does NOT advance and the distress
      // chain does NOT fire. We do maintain a local sim-only counter so
      // we can surface an educational SnackBar when the threshold is
      // reached.
      _simWrongAttempts += 1;
      final messenger = ScaffoldMessenger.maybeOf(context);
      await _showWrongFeedback(settings);
      if (!mounted) return;
      if (_simWrongAttempts >= settings.wrongPinThreshold) {
        messenger?.showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).sessionEndSimDistressWouldFire,
            ),
          ),
        );
        setState(() {
          _entry.clear();
          _showWrong = true;
          _simWrongAttempts = 0;
        });
        return;
      }
      setState(() {
        _entry.clear();
        _showWrong = true;
      });
      return;
    }

    final controller = ref.read(sessionControllerProvider.notifier);
    final attempts = controller.notifyWrongPinAttempt();
    await _showWrongFeedback(settings);
    if (!mounted) return;
    if (attempts >= settings.wrongPinThreshold) {
      widget.onOutcome(EndSessionOutcome.wrongPinExhausted);
      return;
    }
    setState(() {
      _entry.clear();
      _showWrong = true;
    });
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

  void _onSimSkip() => widget.onOutcome(EndSessionOutcome.endConfirmed);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Material(
      color: cs.surface,
      child: SafeArea(
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
                child: switch (_stage) {
                  _Stage.swipe => _SwipeStage(
                    isSimulation: widget.isSimulation,
                    onCancel: _cancel,
                    onConfirm: _onSwipeConfirmed,
                  ),
                  _Stage.pin => _PinStage(
                    isSimulation: widget.isSimulation,
                    entryLength: _entry.length,
                    showWrong: _showWrong,
                    showAppPinMismatch: _showAppPinMismatch,
                    shakeAnim: _shakeAnim,
                    onDigit: _onDigit,
                    onBackspace: _onBackspace,
                    onCancel: _cancel,
                    onSimSkip: widget.isSimulation ? _onSimSkip : null,
                  ),
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SwipeStage extends StatelessWidget {
  const _SwipeStage({
    required this.isSimulation,
    required this.onCancel,
    required this.onConfirm,
  });

  final bool isSimulation;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (isSimulation)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Align(
              child: _SimBadge(label: l10n.sessionEndOverlaySimBadge),
            ),
          ),
        Icon(Icons.exit_to_app, size: 64, color: theme.colorScheme.primary),
        const SizedBox(height: 16),
        Text(
          l10n.sessionEndOverlayTitle,
          style: textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.sessionEndOverlayBody,
          style: textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        SwipeSlider(
          label: l10n.sessionEndOverlaySwipeLabel,
          onConfirm: onConfirm,
        ),
        const SizedBox(height: 16),
        TextButton(onPressed: onCancel, child: Text(l10n.commonCancel)),
      ],
    );
  }
}

class _PinStage extends StatelessWidget {
  const _PinStage({
    required this.isSimulation,
    required this.entryLength,
    required this.showWrong,
    required this.showAppPinMismatch,
    required this.shakeAnim,
    required this.onDigit,
    required this.onBackspace,
    required this.onCancel,
    required this.onSimSkip,
  });

  final bool isSimulation;
  final int entryLength;
  final bool showWrong;
  final bool showAppPinMismatch;
  final Animation<double> shakeAnim;
  final ValueChanged<int> onDigit;
  final VoidCallback onBackspace;
  final VoidCallback onCancel;
  final VoidCallback? onSimSkip;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (isSimulation)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Align(
              child: _SimBadge(label: l10n.sessionEndOverlaySimBadge),
            ),
          ),
        const Icon(Icons.lock_outline, size: 48),
        const SizedBox(height: 16),
        Text(
          l10n.sessionEndPinPromptTitle,
          style: textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        AnimatedBuilder(
          animation: shakeAnim,
          builder: (BuildContext _, Widget? child) {
            return Transform.translate(
              offset: Offset(shakeAnim.value, 0),
              child: child,
            );
          },
          child: Text(
            List<String>.generate(
              entryLength < 4 ? 4 : entryLength,
              (int i) => i < entryLength ? '●' : '○',
            ).join(' '),
            style: textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
        ),
        if (showAppPinMismatch) ...<Widget>[
          const SizedBox(height: 8),
          Text(
            l10n.sessionEndPinAppPinMismatch,
            style: textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
            textAlign: TextAlign.center,
          ),
        ],
        if (showWrong) ...<Widget>[
          const SizedBox(height: 8),
          Text(
            l10n.sessionEndPinIncorrect,
            style: textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 16),
        PinKeypad(onDigit: onDigit, onBackspace: onBackspace),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            TextButton(onPressed: onCancel, child: Text(l10n.commonCancel)),
            if (onSimSkip != null)
              TextButton(
                onPressed: onSimSkip,
                child: Text(l10n.sessionEndPinSimSkip),
              ),
          ],
        ),
      ],
    );
  }
}

class _SimBadge extends StatelessWidget {
  const _SimBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// Look up [EndReason] values from the overlay outcome — kept here so
/// the call site can stay declarative.
EndReason endReasonFor(EndSessionOutcome outcome) => switch (outcome) {
  EndSessionOutcome.dismissed => EndReason.userQuit,
  EndSessionOutcome.endConfirmed => EndReason.userQuit,
  EndSessionOutcome.duressPinEntered => EndReason.duressPin,
  EndSessionOutcome.wrongPinExhausted => EndReason.wrongPinExhausted,
};
