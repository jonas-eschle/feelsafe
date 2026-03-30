import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:safewayhome/l10n/app_localizations.dart';

import '../../core/constants/route_names.dart';
import '../../core/theme/pride_widgets.dart';
import '../../data/models/reminder_template.dart';
import '../session/widgets/disguised_reminder_overlay.dart';
import 'templates_controller.dart';

class ReminderTemplatesScreen extends ConsumerWidget {
  const ReminderTemplatesScreen({super.key});

  static IconData _confirmationIcon(ConfirmationType type) {
    return switch (type) {
      ConfirmationType.tapButton => Icons.touch_app,
      ConfirmationType.tapWord => Icons.spellcheck,
      ConfirmationType.swipe => Icons.swipe,
      ConfirmationType.dismiss => Icons.close,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final templatesAsync = ref.watch(templatesControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.reminderTemplates),
        bottom: const PrideAppBarBottom(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEditor(context, ref, null),
        child: const Icon(Icons.add),
      ),
      body: templatesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (templates) {
          if (templates.isEmpty) {
            return Center(child: Text(l10n.reminderTemplates));
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: templates.length,
            itemBuilder: (context, index) {
              final tpl = templates[index];
              return Card(
                margin:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _showEditor(context, ref, tpl),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _confirmationIcon(tpl.confirmationType),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                tpl.name,
                                style:
                                    Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            if (tpl.isCustom)
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () {
                                  ref
                                      .read(templatesControllerProvider
                                          .notifier)
                                      .deleteTemplate(tpl.id);
                                },
                                visualDensity: VisualDensity.compact,
                              ),
                            const Icon(Icons.chevron_right, size: 20),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Mini preview of the disguised reminder
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: SizedBox(
                            height: 100,
                            child: OverflowBox(
                              alignment: Alignment.topCenter,
                              maxHeight: 100 / 0.55,
                              maxWidth: double.infinity,
                              child: Transform.scale(
                                scale: 0.55,
                                alignment: Alignment.topCenter,
                                child: IgnorePointer(
                                  child: DisguisedReminderOverlay(
                                    template: tpl,
                                    onConfirmed: () {},
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showEditor(
    BuildContext context,
    WidgetRef ref,
    ReminderTemplate? template,
  ) {
    if (template != null) {
      context.go('${RouteNames.templateEdit}?id=${template.id}');
    } else {
      context.go(RouteNames.templateEdit);
    }
  }
}

