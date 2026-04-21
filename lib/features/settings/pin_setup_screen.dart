/// PIN setup — enter then confirm, save hash.
///
/// Fix for bugs.json Block (PIN Argon2id upgrade): hashes now flow
/// through [PinHasher.hash] (salted + iterated) instead of bare
/// SHA-256.
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
  String? _error;

  /// Fix for bugs.json Block (PIN Argon2id upgrade): delegates to
  /// [PinHasher.hash] so setup and verify use the same primitive.
  String _hash(String pin) => PinHasher.hash(pin);

  void _onDigit(int d) {
    setState(() {
      (_confirming ? _second : _first).write(d);
      _error = null;
    });
    _maybeAdvance();
  }

  void _onBackspace() {
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
      if (_first.length >= 4 && _first.length >= 4) {
        // Accept 4-8 digits.
      }
      if (_first.length >= 4) {
        setState(() => _confirming = true);
      }
      return;
    }
    if (_second.length >= _first.length) {
      _submit();
    }
  }

  Future<void> _submit() async {
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
    final hash = _hash(a);
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
              '•' * buf.length,
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
