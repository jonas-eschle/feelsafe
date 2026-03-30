import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:safewayhome/l10n/app_localizations.dart';

import '../../core/constants/route_names.dart';
import '../../core/theme/pride_widgets.dart';
import '../../data/models/emergency_contact.dart';
import 'contacts_controller.dart';

class ContactsScreen extends ConsumerWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final contactsAsync = ref.watch(contactsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.emergencyContacts),
        bottom: const PrideAppBarBottom(),
      ),
      body: contactsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text(error.toString())),
        data: (contacts) {
          if (contacts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noContactsYet,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => context.push(RouteNames.contactEdit),
                    icon: const Icon(Icons.add),
                    label: Text(l10n.addContact),
                  ),
                ],
              ),
            );
          }

          return ReorderableListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: contacts.length,
            onReorder: (oldIndex, newIndex) {
              ref
                  .read(contactsControllerProvider.notifier)
                  .reorderContacts(oldIndex, newIndex);
            },
            itemBuilder: (context, index) {
              final contact = contacts[index];
              return _ContactTile(
                key: ValueKey(contact.id),
                contact: contact,
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(RouteNames.contactEdit),
        tooltip: l10n.addContact,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _ContactTile extends ConsumerWidget {
  final EmergencyContact contact;

  const _ContactTile({super.key, required this.contact});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Dismissible(
      key: ValueKey(contact.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        color: theme.colorScheme.error,
        child: Icon(Icons.delete, color: theme.colorScheme.onError),
      ),
      confirmDismiss: (_) => _confirmDelete(context, contact.name, l10n),
      onDismissed: (_) {
        ref
            .read(contactsControllerProvider.notifier)
            .deleteContact(contact.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.contactDeleted)),
        );
      },
      child: ListTile(
        leading: CircleAvatar(
          child: Text(
            contact.name.isNotEmpty ? contact.name[0].toUpperCase() : '?',
          ),
        ),
        title: Text(contact.name),
        subtitle: Text(
          [
            contact.phoneNumber,
            if (contact.relationship != null &&
                contact.relationship!.isNotEmpty)
              contact.relationship,
          ].join(' \u2022 '),
        ),
        trailing: Icon(
          switch (contact.preferredChannel) {
            MessageChannel.sms => Icons.sms,
            MessageChannel.whatsapp => Icons.chat,
            MessageChannel.telegram => Icons.send,
            MessageChannel.phoneCall => Icons.phone,
          },
          color: theme.colorScheme.onSurfaceVariant,
        ),
        onTap: () => context.push(
          '${RouteNames.contactEdit}?id=${contact.id}',
        ),
      ),
    );
  }

  Future<bool?> _confirmDelete(
    BuildContext context,
    String name,
    AppLocalizations l10n,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteContactConfirmTitle),
        content: Text(l10n.deleteContactConfirmMessage(name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}
