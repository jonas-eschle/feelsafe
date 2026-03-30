import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:safewayhome/l10n/app_localizations.dart';

import '../../core/theme/pride_widgets.dart';
import '../../data/models/emergency_contact.dart';
import 'contacts_controller.dart';

class ContactFormScreen extends ConsumerStatefulWidget {
  final String? contactId;

  const ContactFormScreen({super.key, this.contactId});

  @override
  ConsumerState<ContactFormScreen> createState() => _ContactFormScreenState();
}

class _ContactFormScreenState extends ConsumerState<ContactFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _relationshipController;
  MessageChannel _preferredChannel = MessageChannel.sms;
  bool _isLoading = true;

  bool get _isEditing => widget.contactId != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _relationshipController = TextEditingController();
    _loadContact();
  }

  Future<void> _loadContact() async {
    if (!_isEditing) {
      setState(() => _isLoading = false);
      return;
    }
    final contacts = await ref.read(contactsControllerProvider.future);
    final contact = contacts.where((c) => c.id == widget.contactId).firstOrNull;
    if (contact != null) {
      _nameController.text = contact.name;
      _phoneController.text = contact.phoneNumber;
      _relationshipController.text = contact.relationship ?? '';
      _preferredChannel = contact.preferredChannel;
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _relationshipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l10n.editContact : l10n.addContact),
        bottom: const PrideAppBarBottom(),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: l10n.contactName,
                        prefixIcon: const Icon(Icons.person),
                      ),
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return l10n.fieldRequired;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: l10n.contactPhone,
                        prefixIcon: const Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return l10n.fieldRequired;
                        }
                        if (!_isValidPhone(value.trim())) {
                          return l10n.invalidPhoneNumber;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _relationshipController,
                      decoration: InputDecoration(
                        labelText: l10n.contactRelationship,
                        prefixIcon: const Icon(Icons.group),
                      ),
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.done,
                    ),
                    const SizedBox(height: 16),
                    SegmentedButton<MessageChannel>(
                      segments: [
                        ButtonSegment(
                          value: MessageChannel.sms,
                          label: Text(l10n.sms),
                          icon: const Icon(Icons.sms),
                        ),
                        ButtonSegment(
                          value: MessageChannel.whatsapp,
                          label: Text(l10n.whatsapp),
                          icon: const Icon(Icons.chat),
                        ),
                        ButtonSegment(
                          value: MessageChannel.telegram,
                          label: Text(l10n.telegram),
                          icon: const Icon(Icons.send),
                        ),
                        ButtonSegment(
                          value: MessageChannel.phoneCall,
                          label: Text(l10n.phoneCall),
                          icon: const Icon(Icons.phone),
                        ),
                      ],
                      selected: {_preferredChannel},
                      onSelectionChanged: (set) {
                        setState(() => _preferredChannel = set.first);
                      },
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => context.pop(),
                            child: Text(l10n.cancel),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: FilledButton(
                            onPressed: _save,
                            child: Text(l10n.save),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  bool _isValidPhone(String phone) {
    // Accept digits, spaces, dashes, parens, plus sign; at least 3 digits
    final digitsOnly = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.length < 3) return false;
    return RegExp(r'^[+\d][\d\s\-().]*$').hasMatch(phone);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final l10n = AppLocalizations.of(context);
    final controller = ref.read(contactsControllerProvider.notifier);
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final relationship = _relationshipController.text.trim();

    if (_isEditing) {
      await controller.updateContact(
        id: widget.contactId!,
        name: name,
        phoneNumber: phone,
        relationship: relationship.isEmpty ? null : relationship,
        preferredChannel: _preferredChannel,
      );
    } else {
      await controller.addContact(
        name: name,
        phoneNumber: phone,
        relationship: relationship.isEmpty ? null : relationship,
        preferredChannel: _preferredChannel,
      );
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.contactSaved)),
      );
      context.pop();
    }
  }
}
