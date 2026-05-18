/// PIN setup — enter then confirm, save hash.
///
/// Fix for bugs.json Block (PIN Argon2id upgrade): hashes now flow
/// through [PinHasher.hash] (salted + iterated) instead of bare
/// SHA-256.
///
/// Fix for bugs.json Block (_submit race): `_maybeAdvance` previously
/// fired `_submit` without awaiting. After the confirmation buffer
/// reached the target length, every further digit re-entered
/// `_submit`, producing concurrent Argon2 hashes and settings writes
/// that could both pop the route. The new `_submitting` guard
/// short-circuits re-entry until the in-flight submit resolves.
library;

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:guardianangela/core/utils/pin_hasher.dart';
import 'package:guardianangela/core/widgets/pin_keypad.dart';
import 'package:guardianangela/features/settings/settings_controller.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// PIN setup screen.
class PinSetupScreen extends ConsumerStatefulWidget {
  /// Creates the PIN-setup screen.
  const PinSetupScreen({super.key});

  @override
  ConsumerState<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends ConsumerState<PinSetupScreen> {
  final _first = StringBuffer();
  final _second = StringBuffer();
  bool _confirming = false;
  bool _submitting = false;
  String? _error;

  /// Fix for bugs.json Block (PIN Argon2id upgrade): delegates to
  /// [PinHasher.hash] so setup and verify use the same primitive.
  Future<String> _hash(String pin) => PinHasher.hash(pin);

  void _onDigit(int d) {
    if (_submitting) return;
    setState(() {
      (_confirming ? _second : _first).write(d);
      _error = null;
    });
    _maybeAdvance();
  }

  void _onBackspace() {
    if (_submitting) return;
    final buf = _confirming ? _second : _first;
    final s = buf.toString();
    if (s.isEmpty) return;
    setState(() {
      buf.clear();
      buf.write(s.substring(0, s.length - 1));
    });
  }

  void _maybeAdvance() {
    if (!_confirming) {
      if (_first.length >= 4) {
        setState(() => _confirming = true);
      }
      return;
    }
    if (_second.length >= _first.length) {
      // Guard re-entry: `_submit` hashes on a worker isolate and
      // awaits an async settings write; a repeat digit tap must not
      // fire a second concurrent `_submit`.
      if (_submitting) return;
      _submit();
    }
  }

  Future<void> _submit() async {
    if (_submitting) return;
    _submitting = true;
    try {
      final l = AppLocalizations.of(context);
      final a = _first.toString();
      final b = _second.toString();
      if (a != b) {
        setState(() {
          _error = l.pinSetupMismatch;
          _first.clear();
          _second.clear();
          _confirming = false;
        });
        return;
      }
      final hash = await _hash(a);
      if (!mounted) return;
      final which = GoRouterState.of(context).uri.queryParameters['which'];
      final notifier = ref.read(settingsControllerProvider.notifier);
      switch (which) {
        case 'app':
          await notifier.setAppPinHash(hash);
        case 'sessionEnd':
          await notifier.setSessionEndPinHash(hash);
        case 'duress':
          await notifier.setDuressPinHash(hash);
        default:
          await notifier.setSessionEndPinHash(hash);
      }
      if (mounted) context.pop();
    } finally {
      _submitting = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final buf = _confirming ? _second : _first;
    return Scaffold(
      appBar: AppBar(title: Text(l.pinSetupTitle)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_confirming ? l.pinSetupConfirm : l.pinSetupEnter),
            const SizedBox(height: 24),
            Text(
              '\u2022' * buf.length,
              style: Theme.of(context).textTheme.displayMedium,
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 24),
            PinKeypad(onDigit: _onDigit, onBackspace: _onBackspace),
          ],
        ),
      ),
    );
  }
}
