import 'dart:convert' show utf8;

import 'package:flutter/material.dart';

import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:guardianangela/core/widgets/pin_keypad.dart';
import 'package:guardianangela/features/settings_security/settings_security_controller.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';
import 'package:guardianangela/services/service_providers.dart';

/// PIN setup screen.
///
/// Used to set / change / remove any of the three PINs. The route's
/// `type` query parameter selects which PIN: `app`, `sessionEnd`, or
/// `duress`. See spec 06 §Security and spec 04 §Settings PIN Setup.
class PinSetupScreen extends ConsumerStatefulWidget {
  /// Creates a [PinSetupScreen].
  const PinSetupScreen({super.key, required this.pinType});

  /// PIN type — `app`, `sessionEnd`, or `duress`.
  final String pinType;

  @override
  ConsumerState<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends ConsumerState<PinSetupScreen> {
  final List<int> _entry = <int>[];
  final List<int> _confirm = <int>[];
  bool _confirming = false;
  String? _error;

  String _label(AppLocalizations l10n) {
    return switch (widget.pinType) {
      'app' => l10n.securityAppPinTitle,
      'sessionEnd' => l10n.securitySessionEndPinTitle,
      _ => l10n.securityDuressPinTitle,
    };
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    if (_entry.length < 4) {
      setState(() => _error = l10n.pinSetupTooShort);
      return;
    }
    if (!_confirming) {
      setState(() => _confirming = true);
      return;
    }
    if (!_listsEqual(_entry, _confirm)) {
      setState(() {
        _error = l10n.pinSetupMismatch;
        _confirm.clear();
      });
      return;
    }
    final digits = _entry.join();
    final hash = sha256.convert(utf8.encode(digits)).toString();
    final repo = ref.read(appSettingsRepositoryProvider);
    final settings = await repo.load();
    final updated = switch (widget.pinType) {
      'app' => settings.copyWith(appPinHash: hash),
      'sessionEnd' => settings.copyWith(sessionEndPinHash: hash),
      _ => settings.copyWith(duressPinHash: hash),
    };
    // Collision check: deny if the same hash collides with another PIN
    // of higher / equal priority.
    final collides = <String?>[
      if (widget.pinType != 'app') updated.appPinHash,
      if (widget.pinType != 'sessionEnd') updated.sessionEndPinHash,
      if (widget.pinType != 'duress') updated.duressPinHash,
    ].any((String? h) => h == hash);
    if (collides) {
      setState(() {
        _error = l10n.pinSetupCollision;
        _entry.clear();
        _confirm.clear();
        _confirming = false;
      });
      return;
    }
    await repo.save(updated);
    // The save bypassed the keep-alive security controller; without a
    // rebuild the Security screen we pop back to would keep claiming the
    // PIN is not set (no Change/Remove actions, duress shown unarmed).
    ref.invalidate(settingsSecurityControllerProvider);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.pinSetupSaved)));
    context.pop();
  }

  bool _listsEqual(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void _onDigit(int d) {
    setState(() {
      _error = null;
      final list = _confirming ? _confirm : _entry;
      if (list.length >= 8) return;
      list.add(d);
    });
  }

  void _onBackspace() {
    setState(() {
      _error = null;
      final list = _confirming ? _confirm : _entry;
      if (list.isNotEmpty) list.removeLast();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final list = _confirming ? _confirm : _entry;
    return Scaffold(
      appBar: AppBar(title: Text(_label(l10n))),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: <Widget>[
              Text(
                _confirming ? l10n.pinSetupConfirmNew : l10n.pinSetupEnterNew,
                style: textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  for (int i = 0; i < 8; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: CircleAvatar(
                        radius: 8,
                        backgroundColor: i < list.length
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHigh,
                      ),
                    ),
                ],
              ),
              if (_error != null) ...<Widget>[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const Spacer(),
              PinKeypad(onDigit: _onDigit, onBackspace: _onBackspace),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: list.length >= 4 ? _save : null,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                child: Text(l10n.pinSubmit),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
