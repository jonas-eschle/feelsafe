import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:guardianangela/core/constants/route_names.dart';
import 'package:guardianangela/features/reminder_templates/reminder_templates_controller.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// Reminder templates list screen.
///
/// Unified list of built-in + custom templates. Built-ins cannot be
/// deleted (menu item disabled with tooltip). See spec 04 §Templates Screen.
class ReminderTemplatesScreen extends ConsumerWidget {
  /// Creates a [ReminderTemplatesScreen].
  const ReminderTemplatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final stateAsync = ref.watch(reminderTemplatesControllerProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.templatesTitle)),
      floatingActionButton: FloatingActionButton(
        tooltip: l10n.templatesCreate,
        onPressed: () => context.pushNamed(RouteNames.templateEditor),
        child: const Icon(Icons.add),
      ),
      body: stateAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, _) => Center(child: Text('Error: $e')),
        data: (state) {
          if (state.templates.isEmpty) {
            return Center(child: Text(l10n.templatesEmpty));
          }
          return ListView.builder(
            itemCount: state.templates.length,
            itemBuilder: (BuildContext ctx, int i) {
              final t = state.templates[i];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.notifications_outlined),
                  title: Text(t.name),
                  subtitle: Text('${t.title} • ${t.body}'),
                  trailing: PopupMenuButton<String>(
                    onSelected: (String key) async {
                      switch (key) {
                        case 'edit':
                          await context.pushNamed<void>(
                            RouteNames.templateEditor,
                            queryParameters: <String, String>{'id': t.id},
                          );
                        case 'duplicate':
                          await ref
                              .read(
                                reminderTemplatesControllerProvider.notifier,
                              )
                              .duplicate(t.id);
                        case 'delete':
                          if (!t.isCustom) return;
                          await ref
                              .read(
                                reminderTemplatesControllerProvider.notifier,
                              )
                              .delete(t.id);
                      }
                    },
                    itemBuilder: (_) => <PopupMenuEntry<String>>[
                      PopupMenuItem<String>(
                        value: 'edit',
                        child: Text(l10n.commonEdit),
                      ),
                      PopupMenuItem<String>(
                        value: 'duplicate',
                        child: Text(l10n.modesDuplicate),
                      ),
                      PopupMenuItem<String>(
                        value: 'delete',
                        enabled: t.isCustom,
                        child: Text(l10n.commonDelete),
                      ),
                    ],
                  ),
                  onTap: () => context.pushNamed(
                    RouteNames.templateEditor,
                    queryParameters: <String, String>{'id': t.id},
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
