/// Modal PIN-entry dialog wired to [SessionController.handlePinResult].
///
/// Compares the entered PIN against the persisted hashes via the
/// settings controller; returns a [PinResult] describing the outcome.
library;

import 'dart:async';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';

import 'package:guardianangela/core/utils/pin_result.dart';
import 'package:guardianangela/core/widgets/pin_keypad.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// Presents a modal PIN dialog. Returns the [PinResult] outcome.
///
/// [sessionEndHash] — PIN hash that counts as "disarm" (correct).
/// [duressHash] — PIN hash that silently fires the distress chain.
/// [timeout] — max seconds to wait; `0` disables the timeout.
Future<PinResult> showPinEntryDialog({
  required BuildContext context,
  required String? sessionEndHash,
  required String? duressHash,
  int timeout = 15,
}) async {
  final l = AppLocalizations.of(context);
  final result = await showDialog<PinResult>(
    context: context,
    barrierDismissible: true,
    builder: (context) => _PinDialog(
      sessionEndHash: sessionEndHash,
      duressHash: duressHash,
      timeout: timeout,
      title: l.pinEntryTitle,
      subtitle: l.pinEntrySubtitle,
    ),
  );
  return result ?? PinResult.cancelled;
}

/// Hashes a PIN consistently with Settings mutators. Uses SHA-256
/// (matches the test fixtures used by the settings controller).
String hashPin(String pin) => sha256.convert(pin.codeUnits).toString();

class _PinDialog extends StatefulWidget {
  const _PinDialog({
    required this.sessionEndHash,
    required this.duressHash,
    required this.timeout,
    required this.title,
    required this.subtitle,
  });

  final String? sessionEndHash;
  final String? duressHash;
  final int timeout;
  final String title;
  final String subtitle;

  @override
  State<_PinDialog> createState() => _PinDialogState();
}

class _PinDialogState extends State<_PinDialog> {
  final StringBuffer _buffer = StringBuffer();
  Timer? _timeoutTimer;

  @override
  void initState() {
    super.initState();
    if (widget.timeout > 0) {
      _timeoutTimer = Timer(Duration(seconds: widget.timeout), () {
        if (mounted) Navigator.of(context).pop(PinResult.timeout);
      });
    }
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    super.dispose();
  }

  void _onDigit(int d) {
    if (_buffer.length >= 8) return;
    setState(() => _buffer.write(d));
    _maybeSubmit();
  }

  void _onBackspace() {
    final current = _buffer.toString();
    if (current.isEmpty) return;
    setState(() {
      _buffer.clear();
      _buffer.write(current.substring(0, current.length - 1));
    });
  }

  void _maybeSubmit() {
    final pin = _buffer.toString();
    if (pin.length < 4) return;
    final hash = hashPin(pin);
    if (widget.duressHash != null && hash == widget.duressHash) {
      Navigator.of(context).pop(PinResult.duress);
      return;
    }
    if (widget.sessionEndHash != null && hash == widget.sessionEndHash) {
      Navigator.of(context).pop(PinResult.correct);
      return;
    }
    if (pin.length >= 8) {
      Navigator.of(context).pop(PinResult.wrong);
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
            onPressed: () =>
                Navigator.of(context).pop(PinResult.cancelled),
            child: Text(AppLocalizations.of(context).cancel),
          ),
        ],
      );
}
