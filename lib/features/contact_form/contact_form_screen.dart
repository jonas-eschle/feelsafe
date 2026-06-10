import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import 'package:guardianangela/core/utils/phone_validators.dart';
import 'package:guardianangela/core/utils/phone_warning_l10n.dart';
import 'package:guardianangela/data/repositories/contacts_repository.dart';
import 'package:guardianangela/domain/enums/message_channel.dart';
import 'package:guardianangela/domain/models/emergency_contact.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';
import 'package:guardianangela/services/service_providers.dart';

/// Create / edit emergency contact form.
///
/// See spec 04 §Contact Form. Supports unsaved-changes dirty guard
/// (Extra 59) and a "Save" CTA in the app bar.
class ContactFormScreen extends ConsumerStatefulWidget {
  /// Creates a [ContactFormScreen].
  const ContactFormScreen({
    super.key,
    this.contactId,
    this.initialName,
    this.initialPhone,
  });

  /// Contact id when editing; null for create.
  final String? contactId;

  /// Pre-fill name (used when importing from device contacts).
  final String? initialName;

  /// Pre-fill phone (used when importing from device contacts).
  final String? initialPhone;

  @override
  ConsumerState<ContactFormScreen> createState() => _ContactFormScreenState();
}

class _ContactFormScreenState extends ConsumerState<ContactFormScreen> {
  final _nameCtl = TextEditingController();
  final _phoneCtl = TextEditingController();
  final _relCtl = TextEditingController();
  Set<MessageChannel> _channels = <MessageChannel>{
    MessageChannel.sms,
    MessageChannel.whatsapp,
    MessageChannel.telegram,
    MessageChannel.phoneCall,
  };
  String? _languageCode;
  bool _dirty = false;
  bool _loading = true;
  EmergencyContact? _editing;

  @override
  void initState() {
    super.initState();
    _load();
    _nameCtl.addListener(_markDirty);
    _phoneCtl.addListener(_markDirty);
    _relCtl.addListener(_markDirty);
  }

  Future<void> _load() async {
    if (widget.contactId == null) {
      // Pre-fill from import-name / import-phone query parameters.
      if (widget.initialName != null) _nameCtl.text = widget.initialName!;
      if (widget.initialPhone != null) _phoneCtl.text = widget.initialPhone!;
      setState(() => _loading = false);
      return;
    }
    try {
      final db = await ref.read(databaseProvider.future);
      final repo = ContactsRepository(db.contactsDao);
      final c = await repo.getById(widget.contactId!);
      if (!mounted || c == null) {
        setState(() => _loading = false);
        return;
      }
      _nameCtl.text = c.name;
      _phoneCtl.text = c.phoneNumber;
      _relCtl.text = c.relationship ?? '';
      _channels = c.channels.toSet();
      _languageCode = c.languageCode;
      _editing = c;
      _dirty = false;
      setState(() => _loading = false);
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _markDirty() {
    if (!_dirty) {
      setState(() => _dirty = true);
    }
  }

  @override
  void dispose() {
    _nameCtl.dispose();
    _phoneCtl.dispose();
    _relCtl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final name = _nameCtl.text.trim();
    final phone = _phoneCtl.text.trim();
    if (name.length < 2) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.validationNameTooShort)));
      return;
    }
    if (phone.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.validationPhoneRequired)));
      return;
    }
    if (_channels.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.validationChannelsRequired)));
      return;
    }
    final db = await ref.read(databaseProvider.future);
    final repo = ContactsRepository(db.contactsDao);
    final contact = EmergencyContact(
      id: _editing?.id ?? const Uuid().v4(),
      name: name,
      phoneNumber: phone,
      relationship: _relCtl.text.trim().isEmpty ? null : _relCtl.text.trim(),
      sortOrder: _editing?.sortOrder ?? 0,
      channels: _channels.toList(),
      languageCode: _languageCode,
    );
    await repo.upsert(contact);
    if (!mounted) return;
    _dirty = false;
    context.pop();
  }

  Future<bool> _confirmLeave() async {
    if (!_dirty) return true;
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: Text(l10n.contactUnsavedDiscardTitle),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.contactUnsavedDiscardKeep),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.contactUnsavedDiscardDiscard),
          ),
        ],
      ),
    );
    return ok ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (bool didPop, _) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        final shouldPop = await _confirmLeave();
        if (shouldPop && mounted) {
          navigator.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.contactId == null
                ? l10n.contactFormTitleCreate
                : l10n.contactFormTitleEdit,
          ),
          actions: <Widget>[
            TextButton(onPressed: _save, child: Text(l10n.commonSave)),
          ],
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      TextField(
                        controller: _nameCtl,
                        decoration: InputDecoration(
                          labelText: l10n.contactFieldName,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Live, non-blocking character-class warning (Extra 26).
                      // Empty is enforced separately by _save()'s required
                      // check, so only the invalid-character advisory is
                      // surfaced here as helperText.
                      ValueListenableBuilder<TextEditingValue>(
                        valueListenable: _phoneCtl,
                        builder: (BuildContext context, TextEditingValue v, _) {
                          final PhoneNumberWarning? warning =
                              PhoneValidators.warnContactNumber(v.text.trim());
                          final String? helper =
                              warning == PhoneNumberWarning.invalidCharacters
                              ? phoneWarningMessage(l10n, warning!)
                              : null;
                          return TextField(
                            controller: _phoneCtl,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              labelText: l10n.contactFieldPhone,
                              helperText: helper,
                              helperMaxLines: 2,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _relCtl,
                        decoration: InputDecoration(
                          labelText: l10n.contactFieldRelationship,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(l10n.contactChannelsHeader),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: <Widget>[
                          for (final ch in MessageChannel.values)
                            FilterChip(
                              label: Text(_channelLabel(ch, l10n)),
                              selected: _channels.contains(ch),
                              onSelected: (bool s) {
                                setState(() {
                                  if (s) {
                                    _channels.add(ch);
                                  } else {
                                    _channels.remove(ch);
                                  }
                                  _dirty = true;
                                });
                              },
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String?>(
                        initialValue: _languageCode,
                        decoration: InputDecoration(
                          labelText: l10n.contactFieldLanguage,
                        ),
                        items: <DropdownMenuItem<String?>>[
                          DropdownMenuItem<String?>(
                            child: Text(l10n.contactLanguageDefault),
                          ),
                          for (final Locale loc
                              in AppLocalizations.supportedLocales)
                            DropdownMenuItem<String?>(
                              value: loc.toLanguageTag(),
                              child: Text(loc.toLanguageTag()),
                            ),
                        ],
                        onChanged: (String? v) {
                          setState(() {
                            _languageCode = v;
                            _dirty = true;
                          });
                        },
                      ),
                      if (_showIosSmsWarning)
                        // LCOV_EXCL_START — iOS-only (_showIosSmsWarning ⇒ Platform.isIOS): manual-send SMS warning (CI build-ios)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Text(
                            l10n.contactFormIosSmsWarning,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      // LCOV_EXCL_STOP
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  /// Whether to render the iOS SMS manual-send warning.
  ///
  /// Spec 04:1379 says the warning appears when running on iOS and the
  /// SMS channel is enabled. On web and other non-iOS platforms it is
  /// suppressed.
  bool get _showIosSmsWarning {
    if (kIsWeb) return false;
    return Platform.isIOS && _channels.contains(MessageChannel.sms);
  }

  String _channelLabel(MessageChannel ch, AppLocalizations l10n) {
    return switch (ch) {
      MessageChannel.sms => l10n.contactChannelSms,
      MessageChannel.whatsapp => l10n.contactChannelWhatsapp,
      MessageChannel.telegram => l10n.contactChannelTelegram,
      MessageChannel.phoneCall => l10n.contactChannelPhone,
    };
    // Helper kept exhaustive over MessageChannel; new variants surface
    // as compile errors here.
  }
}
