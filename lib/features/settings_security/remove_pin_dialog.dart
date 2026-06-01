import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:guardianangela/core/constants/pin_constants.dart';
import 'package:guardianangela/core/widgets/pin_keypad.dart';
import 'package:guardianangela/domain/models/app_settings.dart';
import 'package:guardianangela/features/settings_security/settings_security_controller.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';
import 'package:guardianangela/services/service_providers.dart';

/// Identity check shown before a PIN is removed (spec 06 §Security).
///
/// Removing a configured PIN requires re-entering **that** PIN first, so an
/// attacker who merely has the unlocked device cannot wipe a victim's PIN
/// protection (the prior flow only asked "are you sure?"). Returns `true`
/// only when the entered digits match the stored hash for [type].
///
/// This is a plain identity check, not a distress prompt: per spec 06:174 the
/// Duress PIN / wrong-PIN escalation apply at the App-lock and Session-End
/// prompts, not here. Wrong entries simply shake; there is no counter and no
/// distress. Auto-submits on match; a wrong attempt is only surfaced once the
/// entry reaches [kPinMaxLength] (consistent with the other keypads — a
/// shorter entry may be a prefix of a longer correct PIN).
class RemovePinDialog extends ConsumerStatefulWidget {
  /// Creates a [RemovePinDialog] verifying the PIN of [type].
  const RemovePinDialog({super.key, required this.type, required this.title});

  /// Which PIN is being removed (and therefore verified).
  final PinType type;

  /// The PIN's display title, shown as the dialog title.
  final String title;

  /// Shows the dialog and resolves to `true` only when the correct PIN was
  /// entered. Cancelling or dismissing resolves to `false`.
  static Future<bool> show(
    BuildContext context, {
    required PinType type,
    required String title,
  }) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => RemovePinDialog(type: type, title: title),
    );
    return ok ?? false;
  }

  @override
  ConsumerState<RemovePinDialog> createState() => _RemovePinDialogState();
}

class _RemovePinDialogState extends ConsumerState<RemovePinDialog>
    with SingleTickerProviderStateMixin {
  final List<int> _entry = <int>[];
  bool _showWrong = false;

  /// Stored hash for [RemovePinDialog.type]; null until settings load.
  String? _storedHash;

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
    _load();
  }

  Future<void> _load() async {
    final settings = await ref.read(appSettingsRepositoryProvider).load();
    if (!mounted) return;
    setState(() => _storedHash = _hashFor(settings, widget.type));
  }

  String? _hashFor(AppSettings s, PinType type) => switch (type) {
    PinType.app => s.appPinHash,
    PinType.sessionEnd => s.sessionEndPinHash,
    PinType.duress => s.duressPinHash,
  };

  @override
  void dispose() {
    _shakeCtl.dispose();
    super.dispose();
  }

  Future<void> _onDigit(int d) async {
    if (_entry.length >= kPinMaxLength) return;
    setState(() {
      _entry.add(d);
      _showWrong = false;
    });
    if (_entry.length < kPinMinLength) return;
    final hash = sha256.convert(utf8.encode(_entry.join())).toString();
    if (_storedHash != null && hash == _storedHash) {
      Navigator.of(context).pop(true);
      return;
    }
    if (_entry.length >= kPinMaxLength) {
      await _shakeCtl.forward();
      if (!mounted) return;
      _shakeCtl.reset();
      setState(() {
        _entry.clear();
        _showWrong = true;
      });
    }
  }

  void _onBackspace() {
    if (_entry.isEmpty) return;
    setState(() {
      _entry.removeLast();
      _showWrong = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              l10n.securityRemovePinPrompt,
              style: textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            AnimatedBuilder(
              animation: _shakeAnim,
              builder: (BuildContext _, Widget? child) => Transform.translate(
                offset: Offset(_shakeAnim.value, 0),
                child: child,
              ),
              child: Text(
                List<String>.generate(
                  _entry.length < kPinMinLength ? kPinMinLength : _entry.length,
                  (int i) => i < _entry.length ? '●' : '○',
                ).join(' '),
                style: textTheme.headlineSmall,
              ),
            ),
            if (_showWrong) ...<Widget>[
              const SizedBox(height: 8),
              Text(
                l10n.securityRemovePinIncorrect,
                style: textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
            const SizedBox(height: 16),
            PinKeypad(onDigit: _onDigit, onBackspace: _onBackspace),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.commonCancel),
        ),
      ],
    );
  }
}
