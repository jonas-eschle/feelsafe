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
  bool _hydrated = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();
    _relationshipCtrl = TextEditingController();
    _languageCtrl = TextEditingController();
    // Default: every channel enabled. The user toggles them off if
    // they want to narrow the channels.
    _channels.addAll(MessageChannel.values);
  }

  void _hydrate(List<EmergencyContact> contacts) {
    if (_hydrated) return;
    _hydrated = true;
    final id = widget.id ?? GoRouterState.of(context).uri.queryParameters['id'];
    if (id == null) return;
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

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _relationshipCtrl.dispose();
    _languageCtrl.dispose();
    super.dispose();
  }

  void _toggleChannel(MessageChannel channel, bool selected) {
    setState(() {
      if (selected) {
        _channels.add(channel);
      } else {
        _channels.remove(channel);
      }
    });
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
    final contactsAsync = ref.watch(contactsControllerProvider);
    if (!_hydrated) {
      contactsAsync.whenData(_hydrate);
    }
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
            DropdownButtonFormField<String>(
              initialValue: _languageCtrl.text.isEmpty
                  ? null
                  : _languageCtrl.text,
              decoration: InputDecoration(labelText: l.contactFieldLanguage),
              items: [
                DropdownMenuItem<String>(
                  value: null,
                  child: Text(l.contactLanguageDefault),
                ),
                for (final code in const [
                  'en',
                  'de',
                  'es',
                  'fr',
                  'ru',
                  'zh',
                  'zh_TW',
                  'hi',
                  'fa',
                  'uk',
                  'pl',
                  'el',
                  'ar',
                  'he',
                ])
                  DropdownMenuItem<String>(value: code, child: Text(code)),
              ],
              onChanged: (v) =>
                  setState(() => _languageCtrl.text = v ?? ''),
            ),
            const SizedBox(height: 24),
            Text(
              l.contactChannelsHeader,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ChannelChip(
                  channel: MessageChannel.sms,
                  label: l.contactChannelSms,
                  selected: _channels.contains(MessageChannel.sms),
                  onChanged: _toggleChannel,
                ),
                _ChannelChip(
                  channel: MessageChannel.whatsapp,
                  label: l.contactChannelWhatsapp,
                  selected: _channels.contains(MessageChannel.whatsapp),
                  onChanged: _toggleChannel,
                ),
                _ChannelChip(
                  channel: MessageChannel.telegram,
                  label: l.contactChannelTelegram,
                  selected: _channels.contains(MessageChannel.telegram),
                  onChanged: _toggleChannel,
                ),
                _ChannelChip(
                  channel: MessageChannel.phoneCall,
                  label: l.contactChannelPhone,
                  selected: _channels.contains(MessageChannel.phoneCall),
                  onChanged: _toggleChannel,
                ),
              ],
            ),
            const SizedBox(height: 24),
            FilledButton(onPressed: _save, child: Text(l.commonSave)),
          ],
        ),
      ),
    );
  }
}

/// Clickable button-style toggle for a single messaging channel.
class _ChannelChip extends StatelessWidget {
  const _ChannelChip({
    required this.channel,
    required this.label,
    required this.selected,
    required this.onChanged,
  });

  final MessageChannel channel;
  final String label;
  final bool selected;
  final void Function(MessageChannel channel, bool selected) onChanged;

  @override
  Widget build(BuildContext context) => FilterChip(
    label: Text(label),
    selected: selected,
    onSelected: (v) => onChanged(channel, v),
  );
}
