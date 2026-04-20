/// Emergency-contact create / edit form.
///
/// Reads the optional `id` query parameter from the current
/// `GoRouterState` to resolve the contact being edited; creating
/// when null.
library;

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/models/emergency_contact.dart';
import 'package:guardianangela/features/contacts/contacts_controller.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// Contact create / edit form.
class ContactFormScreen extends ConsumerStatefulWidget {
  /// Creates the contact form.
  const ContactFormScreen({super.key, this.id});

  /// Optional id of the contact being edited; null = creating.
  final String? id;

  @override
  ConsumerState<ContactFormScreen> createState() => _ContactFormScreenState();
}

class _ContactFormScreenState extends ConsumerState<ContactFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _relationshipCtrl;
  late TextEditingController _languageCtrl;
  final Set<MessageChannel> _channels = <MessageChannel>{};

  EmergencyContact? _existing;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();
    _relationshipCtrl = TextEditingController();
    _languageCtrl = TextEditingController();
    _channels.add(MessageChannel.sms);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final id = widget.id ?? GoRouterState.of(context).uri.queryParameters['id'];
    if (id != null && _existing == null) {
      final contacts =
          ref.read(contactsControllerProvider).value ??
          const <EmergencyContact>[];
      for (final c in contacts) {
        if (c.id == id) {
          _existing = c;
          _nameCtrl.text = c.name;
          _phoneCtrl.text = c.phoneNumber;
          _relationshipCtrl.text = c.relationship ?? '';
          _languageCtrl.text = c.languageCode ?? '';
          _channels
            ..clear()
            ..addAll(c.channels);
          break;
        }
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _relationshipCtrl.dispose();
    _languageCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) return;
    final existing = _existing;
    final contact = EmergencyContact(
      id: existing?.id ?? const Uuid().v4(),
      name: _nameCtrl.text.trim(),
      phoneNumber: _phoneCtrl.text.trim(),
      sortOrder: existing?.sortOrder ?? 0,
      relationship: _relationshipCtrl.text.trim().isEmpty
          ? null
          : _relationshipCtrl.text.trim(),
      languageCode: _languageCtrl.text.trim().isEmpty
          ? null
          : _languageCtrl.text.trim(),
      channels: _channels.toList(growable: false),
    );
    if (contact.channels.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.contactRequiredError)));
      return;
    }
    await ref.read(contactsControllerProvider.notifier).save(contact);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isEdit = _existing != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? l.contactFormTitleEdit : l.contactFormTitleCreate),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: InputDecoration(labelText: l.contactFieldName),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? l.contactRequiredError : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(labelText: l.contactFieldPhone),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? l.contactRequiredError : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _relationshipCtrl,
              decoration: InputDecoration(
                labelText: l.contactFieldRelationship,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _languageCtrl,
              decoration: InputDecoration(labelText: l.contactFieldLanguage),
            ),
            const SizedBox(height: 24),
            Text(
              l.contactChannelsHeader,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            CheckboxListTile(
              value: _channels.contains(MessageChannel.sms),
              title: Text(l.contactChannelSms),
              onChanged: (v) => setState(() {
                if (v ?? false) {
                  _channels.add(MessageChannel.sms);
                } else {
                  _channels.remove(MessageChannel.sms);
                }
              }),
            ),
            CheckboxListTile(
              value: _channels.contains(MessageChannel.whatsapp),
              title: Text(l.contactChannelWhatsapp),
              onChanged: (v) => setState(() {
                if (v ?? false) {
                  _channels.add(MessageChannel.whatsapp);
                } else {
                  _channels.remove(MessageChannel.whatsapp);
                }
              }),
            ),
            CheckboxListTile(
              value: _channels.contains(MessageChannel.telegram),
              title: Text(l.contactChannelTelegram),
              onChanged: (v) => setState(() {
                if (v ?? false) {
                  _channels.add(MessageChannel.telegram);
                } else {
                  _channels.remove(MessageChannel.telegram);
                }
              }),
            ),
            CheckboxListTile(
              value: _channels.contains(MessageChannel.phoneCall),
              title: Text(l.contactChannelPhone),
              onChanged: (v) => setState(() {
                if (v ?? false) {
                  _channels.add(MessageChannel.phoneCall);
                } else {
                  _channels.remove(MessageChannel.phoneCall);
                }
              }),
            ),
            const SizedBox(height: 24),
            FilledButton(onPressed: _save, child: Text(l.commonSave)),
          ],
        ),
      ),
    );
  }
}
