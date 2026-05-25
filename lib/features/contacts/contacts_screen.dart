import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:guardianangela/core/constants/route_names.dart';
import 'package:guardianangela/features/contacts/contacts_controller.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// Emergency contacts list screen.
///
/// Reorderable list backed by [ContactsController]. Tap a contact to
/// edit, swipe to delete, FAB to add. See spec 04 §Contacts Screen.
class ContactsScreen extends ConsumerWidget {
  /// Creates a [ContactsScreen].
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final stateAsync = ref.watch(contactsControllerProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.contactsTitle)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.pushNamed(RouteNames.contactForm),
        tooltip: l10n.contactsAdd,
        child: const Icon(Icons.add),
      ),
      body: stateAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, _) => Center(child: Text('Error: $e')),
        data: (state) {
          if (state.contacts.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(l10n.contactsEmpty, textAlign: TextAlign.center),
              ),
            );
          }
          return ListView.builder(
            itemCount: state.contacts.length,
            itemBuilder: (BuildContext ctx, int i) {
              final c = state.contacts[i];
              return Dismissible(
                key: ValueKey<String>(c.id),
                background: Container(
                  color: Theme.of(ctx).colorScheme.error,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                direction: DismissDirection.endToStart,
                confirmDismiss: (_) async {
                  return await showDialog<bool>(
                        context: ctx,
                        builder: (BuildContext dctx) => AlertDialog(
                          title: Text(l10n.contactDeleteConfirm),
                          content: Text(l10n.contactDeleteBody(c.name)),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.of(dctx).pop(false),
                              child: Text(l10n.commonCancel),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.of(dctx).pop(true),
                              child: Text(l10n.commonDelete),
                            ),
                          ],
                        ),
                      ) ??
                      false;
                },
                onDismissed: (_) {
                  ref.read(contactsControllerProvider.notifier).delete(c.id);
                },
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(c.name.characters.first.toUpperCase()),
                  ),
                  title: Text(c.name),
                  subtitle: Text(c.phoneNumber),
                  trailing: Wrap(
                    spacing: 4,
                    children: <Widget>[
                      for (final ch in c.channels) Chip(label: Text(ch.name)),
                    ],
                  ),
                  onTap: () => context.pushNamed(
                    RouteNames.contactForm,
                    queryParameters: <String, String>{'id': c.id},
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
