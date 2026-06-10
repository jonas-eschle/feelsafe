import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import 'package:flutter_contacts/flutter_contacts.dart' as fc;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:guardianangela/core/constants/route_names.dart';
import 'package:guardianangela/features/contacts/contacts_controller.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

import 'package:flutter_contacts/models/permissions/permission_status.dart'
    as fc_perm;
import 'package:flutter_contacts/models/permissions/permission_type.dart'
    as fc_perm_type;

/// Emergency contacts list screen.
///
/// Reorderable list backed by [ContactsController]. Tap a contact to
/// edit, swipe to delete (per row), drag-handle to reorder, FAB to
/// add new, AppBar action to import from device contacts, overflow
/// menu to delete every contact. See spec 04 §Contacts Screen.
class ContactsScreen extends ConsumerWidget {
  /// Creates a [ContactsScreen].
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final stateAsync = ref.watch(contactsControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.contactsTitle),
        actions: <Widget>[
          if (_importSupported)
            // LCOV_EXCL_START — device-only (_importSupported ⇒ Android/iOS): native contact-import button; the Linux test host never builds it (CI build-android/ios)
            IconButton(
              tooltip: l10n.contactsImportFromDevice,
              icon: const Icon(Icons.import_contacts),
              onPressed: () => _importFromDevice(context, ref),
            ),
          // LCOV_EXCL_STOP
          PopupMenuButton<String>(
            onSelected: (String key) async {
              if (key == 'delete_all') {
                await _confirmDeleteAll(context, ref);
              }
            },
            itemBuilder: (_) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'delete_all',
                child: Text(l10n.contactsDeleteAllMenu),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.pushNamed(RouteNames.contactForm),
        tooltip: l10n.contactsAdd,
        child: const Icon(Icons.add),
      ),
      body: stateAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, _) =>
            Center(child: Text(l10n.commonErrorWithDetail(e))),
        data: (state) {
          if (state.contacts.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(l10n.contactsEmpty, textAlign: TextAlign.center),
              ),
            );
          }
          return ReorderableListView.builder(
            itemCount: state.contacts.length,
            onReorder: (int oldIndex, int newIndex) {
              ref
                  .read(contactsControllerProvider.notifier)
                  .reorder(oldIndex, newIndex);
            },
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
                      const Icon(Icons.drag_handle),
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

  /// True on mobile (Android / iOS), false on web / desktop.
  bool get _importSupported {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }

  // LCOV_EXCL_START — device-only (Android/iOS): flutter_contacts native picker, reachable only via the _importSupported-gated button above (CI build-android/ios)
  Future<void> _importFromDevice(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    try {
      final status = await fc.FlutterContacts.permissions.request(
        fc_perm_type.PermissionType.read,
      );
      if (status != fc_perm.PermissionStatus.granted) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.contactsImportPermissionDenied)),
        );
        return;
      }
      final pickedId = await fc.FlutterContacts.native.showPicker();
      if (pickedId == null || !context.mounted) return;
      final picked = await fc.FlutterContacts.get(pickedId);
      if (picked == null || !context.mounted) return;
      final firstPhone = picked.phones.isNotEmpty
          ? picked.phones.first.number
          : '';
      final displayName = picked.displayName ?? '';
      await context.pushNamed(
        RouteNames.contactForm,
        queryParameters: <String, String>{
          if (displayName.isNotEmpty) 'name': displayName,
          if (firstPhone.isNotEmpty) 'phone': firstPhone,
        },
      );
    } on Object catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.contactsImportNotSupported)));
    }
  }
  // LCOV_EXCL_STOP

  Future<void> _confirmDeleteAll(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final firstOk = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: Text(l10n.contactsDeleteAllConfirmTitle),
        content: Text(l10n.contactsDeleteAllConfirmBody),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.commonConfirm),
          ),
        ],
      ),
    );
    if (firstOk != true || !context.mounted) return;
    final typed = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => const _TypeToConfirmDialog(),
    );
    if (typed != true || !context.mounted) return;
    await ref.read(contactsControllerProvider.notifier).deleteAll();
  }
}

class _TypeToConfirmDialog extends StatefulWidget {
  const _TypeToConfirmDialog();

  @override
  State<_TypeToConfirmDialog> createState() => _TypeToConfirmDialogState();
}

class _TypeToConfirmDialogState extends State<_TypeToConfirmDialog> {
  final TextEditingController _ctl = TextEditingController();
  bool _match = false;

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final sentinel = l10n.contactsDeleteAllTypeConfirmSentinel;
    return AlertDialog(
      title: Text(l10n.contactsDeleteAllTypeConfirmTitle),
      content: TextField(
        controller: _ctl,
        decoration: InputDecoration(
          hintText: l10n.contactsDeleteAllTypeConfirmHint,
        ),
        onChanged: (String v) {
          setState(() => _match = v == sentinel);
        },
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          onPressed: _match ? () => Navigator.of(context).pop(true) : null,
          child: Text(l10n.contactsDeleteAllConfirmButton),
        ),
      ],
    );
  }
}
