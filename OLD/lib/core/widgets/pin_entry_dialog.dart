/// Modal PIN-entry dialog wired to [SessionController.handlePinResult].
///
/// Compares the entered PIN against the persisted hashes via the
/// settings controller; returns a [PinResult] describing the outcome.
///
/// Fix for bugs.json Block (PIN Argon2id upgrade): verification now
/// goes through [PinHasher.verify] — constant-time + salted — instead
/// of plain SHA-256 equality.
///
/// Fix for bugs.json Block (Argon2id UI-thread freeze): [PinHasher]
/// is now async (Argon2id runs in a worker isolate). We also gate
/// repeated `_maybeSubmit` invocations behind an `_inFlight` flag so
/// each digit added after length>=4 does not pile up concurrent
/// verifications on the same buffer.
library;

import 'dart:async';

import 'package:flutter/material.dart';

import 'package:guardianangela/core/utils/pin_hasher.dart';
import 'package:guardianangela/core/utils/pin_result.dart';
import 'package:guardianangela/core/widgets/pin_keypad.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';
import 'package:guardianangela/services/protocols/biometric_service_protocol.dart';

/// Presents a modal PIN dialog. Returns the [PinResult] outcome.
///
/// [sessionEndHash] — PIN hash that counts as "disarm" (correct).
/// [duressHash] — PIN hash that silently fires the distress chain.
/// [timeout] — max seconds to wait; `0` disables the timeout.
/// [biometric] — optional biometric service. When non-null, the
/// dialog tries biometric auth first and falls back to PIN entry
/// on failure. Pass null to skip biometric.
Future<PinResult> showPinEntryDialog({
  required BuildContext context,
  required String? sessionEndHash,
  required String? duressHash,
  int timeout = 15,
  Object? biometric,
}) async {
  final l = AppLocalizations.of(context);
  final bio =
      biometric is BiometricServiceProtocol ? biometric : null;
  final result = await showDialog<PinResult>(
    context: context,
    barrierDismissible: true,
    builder: (context) => _PinDialog(
      sessionEndHash: sessionEndHash,
      duressHash: duressHash,
      timeout: timeout,
      title: l.pinEntryTitle,
      subtitle: l.pinEntrySubtitle,
      biometric: bio,
      biometricReason: l.pinEntryBiometricReason,
    ),
  );
  return result ?? PinResult.cancelled;
}

/// Hashes a PIN consistently with Settings mutators.
///
/// Fix for bugs.json Block (PIN Argon2id upgrade): delegates to
/// [PinHasher.hash]. See `pin_hasher.dart` for the algorithm and
/// deviation-from-D-SEC-10 rationale.
Future<String> hashPin(String pin) => PinHasher.hash(pin);

class _PinDialog extends StatefulWidget {
  const _PinDialog({
    required this.sessionEndHash,
    required this.duressHash,
    required this.timeout,
    required this.title,
    required this.subtitle,
    required this.biometric,
    required this.biometricReason,
  });

  final String? sessionEndHash;
  final String? duressHash;
  final int timeout;
  final String title;
  final String subtitle;
  final BiometricServiceProtocol? biometric;
  final String biometricReason;

  @override
  State<_PinDialog> createState() => _PinDialogState();
}

class _PinDialogState extends State<_PinDialog> {
  final StringBuffer _buffer = StringBuffer();
  Timer? _timeoutTimer;

  /// Guards [_maybeSubmit] so a single verify pass runs for one
  /// buffer state, even as the user keeps tapping digits. Without
  /// this, each digit after length>=4 would enqueue another ~1.3s
  /// Argon2 verification, amplifying cost 5x for an 8-digit PIN.
  bool _inFlight = false;

  /// Whether biometric auth is currently being attempted. While true,
  /// the keypad is hidden so the user does not see a flash of the
  /// number pad before the platform biometric prompt appears.
  bool _bioInFlight = false;

  @override
  void initState() {
    super.initState();
    if (widget.timeout > 0) {
      _timeoutTimer = Timer(Duration(seconds: widget.timeout), () {
        if (mounted) Navigator.of(context).pop(PinResult.timeout);
      });
    }
    final bio = widget.biometric;
    if (bio != null && widget.sessionEndHash != null) {
      _bioInFlight = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(_tryBiometric(bio));
      });
    }
  }

  Future<void> _tryBiometric(BiometricServiceProtocol bio) async {
    try {
      if (!await bio.isAvailable()) {
        if (!mounted) return;
        setState(() => _bioInFlight = false);
        return;
      }
      final result = await bio.authenticate(reason: widget.biometricReason);
      if (!mounted) return;
      if (result == BiometricResult.success) {
        Navigator.of(context).pop(PinResult.correct);
        return;
      }
      // Cancelled / unavailable / failed → fall back to keypad.
      setState(() => _bioInFlight = false);
    } on Object catch (_) {
      // Defensive: any platform error → fall back to keypad.
      if (!mounted) return;
      setState(() => _bioInFlight = false);
    }
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    super.dispose();
  }

  void _onDigit(int d) {
    // Q12: no length cap on the buffer. Long PINs are accepted; the
    // user just keeps typing until they press Submit.
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

  Future<void> _maybeSubmit() async {
    // Q12 / B4: this runs when the user presses the Submit button.
    // No auto-submit on digit entry — the dialog stays open until the
    // user explicitly confirms.
    if (_inFlight) return;
    _inFlight = true;
    try {
      while (true) {
        final pin = _buffer.toString();
        if (pin.isEmpty) return;
        // Fix for bugs.json Block (PIN Argon2id upgrade) + Warn
        // (timing attack): PinHasher.verify is salted + constant-
        // time — no prefix-byte timing oracle. Duress is checked
        // FIRST so a user who set duress == sessionEnd never sees
        // the "disarm" branch.
        final duress = widget.duressHash;
        if (duress != null && await PinHasher.verify(pin, duress)) {
          if (!mounted) return;
          Navigator.of(context).pop(PinResult.duress);
          return;
        }
        final sessionEnd = widget.sessionEndHash;
        if (sessionEnd != null &&
            await PinHasher.verify(pin, sessionEnd)) {
          if (!mounted) return;
          if (_buffer.toString() != pin) continue;
          Navigator.of(context).pop(PinResult.correct);
          return;
        }
        // Buffer mutated during verify — re-check against the new
        // string rather than popping based on stale data.
        if (_buffer.toString() != pin) continue;
        if (mounted) {
          Navigator.of(context).pop(PinResult.wrong);
        }
        return;
      }
    } finally {
      _inFlight = false;
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.title),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(widget.subtitle),
        const SizedBox(height: 12),
        if (_bioInFlight)
          // While biometric prompt is in flight, render a slim
          // placeholder so the keypad does not flash beneath the
          // OS biometric sheet.
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: CircularProgressIndicator(),
          )
        else ...[
          Text(
            '\u2022' * _buffer.length,
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 12),
          PinKeypad(onDigit: _onDigit, onBackspace: _onBackspace),
        ],
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(PinResult.cancelled),
        child: Text(AppLocalizations.of(context).cancel),
      ),
      if (!_bioInFlight)
        FilledButton(
          key: const Key('pin-submit'),
          onPressed: _buffer.isEmpty ? null : _maybeSubmit,
          child: Text(AppLocalizations.of(context).pinSubmit),
        ),
    ],
  );
}
