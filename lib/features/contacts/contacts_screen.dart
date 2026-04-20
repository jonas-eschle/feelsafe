/// Emergency contacts list screen with add / edit / delete / reorder.
library;

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:guardianangela/core/constants/route_names.dart';
import 'package:guardianangela/domain/models/emergency_contact.dart';
import 'package:guardianangela/features/contacts/contacts_controller.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// Emergency contacts list.
class ContactsScreen extends ConsumerWidget {
  /// Creates the contacts screen.
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(contactsControllerProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.contactsTitle)),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('$e')),
        data: (contacts) => contacts.isEmpty
            ? Center(child: Text(l.contactsEmpty))
            : ReorderableListView.builder(
                itemCount: contacts.length,
                onReorder: (o, n) => ref
                    .read(contactsControllerProvider.notifier)
                    .reorder(o, n),
                itemBuilder: (context, i) => _ContactTile(
                  key: ValueKey(contacts[i].id),
                  contact: contacts[i],
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: Text(l.contactsAdd),
        onPressed: () => context.push(RouteNames.contactForm),
      ),
    );
  }
}

class _ContactTile extends ConsumerWidget {
  const _ContactTile({super.key, required this.contact});

  final EmergencyContact contact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return ListTile(
      leading: const Icon(Icons.person),
      title: Text(contact.name),
      subtitle: Text(contact.phoneNumber),
      onTap: () => context.push(
        '${RouteNames.contactForm}?id=${contact.id}',
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline),
        onPressed: () async {
          final ok = await showDialog<bool>(
            context: context,
            builder: (c) => AlertDialog(
              title: Text(l.contactDeleteConfirm),
              content: Text(l.contactDeleteBody(contact.name)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(c).pop(false),
                  child: Text(l.commonCancel),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(c).pop(true),
                  child: Text(l.commonDelete),
                ),
              ],
            ),
          );
          if (ok ?? false) {
            await ref
                .read(contactsControllerProvider.notifier)
                .delete(contact.id);
          }
        },
      ),
    );
  }
}
