import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

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
  const ContactFormScreen({super.key, this.contactId});

  /// Contact id when editing; null for create.
  final String? contactId;

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
                      TextField(
                        controller: _phoneCtl,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: l10n.contactFieldPhone,
                        ),
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
                    ],
                  ),
                ),
              ),
      ),
    );
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
