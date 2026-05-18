/// Reminder-templates list.
library;

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:guardianangela/core/constants/route_names.dart';
import 'package:guardianangela/features/templates/templates_controller.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// Templates list.
class TemplatesScreen extends ConsumerWidget {
  /// Creates the templates screen.
  const TemplatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(templatesControllerProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.templatesTitle)),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('$e')),
        data: (templates) => templates.isEmpty
            ? Center(child: Text(l.templatesEmpty))
            : ListView.builder(
                itemCount: templates.length,
                itemBuilder: (context, i) {
                  final t = templates[i];
                  return ListTile(
                    leading: const Icon(Icons.notifications),
                    title: Text(t.name),
                    subtitle: Text(t.title),
                    onTap: () =>
                        context.push('${RouteNames.templateEditor}?id=${t.id}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => ref
                          .read(templatesControllerProvider.notifier)
                          .delete(t.id),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: Text(l.templatesAdd),
        onPressed: () => context.push(RouteNames.templateEditor),
      ),
    );
  }
}
