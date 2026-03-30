import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:safewayhome/l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/route_names.dart';
import '../../core/theme/pride_widgets.dart';
import '../../data/models/escalation_chain.dart';
import '../../data/models/session_mode.dart';
import 'modes_controller.dart';

class ModesScreen extends ConsumerWidget {
  const ModesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final modesAsync = ref.watch(modesControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.modes),
        bottom: const PrideAppBarBottom(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createCustomMode(context, ref),
        child: const Icon(Icons.add),
      ),
      body: modesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (modes) {
          if (modes.isEmpty) {
            return Center(child: Text(l10n.modes));
          }
          return ListView.builder(
            itemCount: modes.length,
            itemBuilder: (context, index) {
              final mode = modes[index];
              return _ModeTile(mode: mode);
            },
          );
        },
      ),
    );
  }

  void _createCustomMode(BuildContext context, WidgetRef ref) {
    final chain = EscalationChain.walkDefaults();
    final mode = SessionMode(
      id: const Uuid().v4(),
      name: '',
      checkInMechanism: CheckInMechanism.holdButton,
      checkInIntervalSeconds: 10,
      missedTolerance: 0,
      escalationSteps: chain.steps,
    );
    ref.read(modesControllerProvider.notifier).saveMode(mode);
    context.push('${RouteNames.modeEdit}?id=${mode.id}');
  }
}

class _ModeTile extends ConsumerWidget {
  final SessionMode mode;

  const _ModeTile({required this.mode});

  IconData _iconForMode(SessionMode mode) {
    switch (mode.iconName) {
      case 'directions_walk':
        return Icons.directions_walk;
      case 'local_cafe':
        return Icons.local_cafe;
      default:
        return Icons.tune;
    }
  }

  String _mechanismLabel(AppLocalizations l10n, CheckInMechanism mechanism) {
    return switch (mechanism) {
      CheckInMechanism.holdButton => l10n.holdButton,
      CheckInMechanism.disguisedReminder => l10n.disguisedReminder,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final subtitle = _mechanismLabel(l10n, mode.checkInMechanism);

    return ListTile(
      leading: Icon(_iconForMode(mode)),
      title: Text(mode.name.isEmpty ? l10n.customMode : mode.name),
      subtitle: Text(subtitle),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!mode.isBuiltIn)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                ref
                    .read(modesControllerProvider.notifier)
                    .deleteMode(mode.id);
              },
            ),
          const Icon(Icons.chevron_right),
        ],
      ),
      onTap: () => context.push('${RouteNames.modeEdit}?id=${mode.id}'),
    );
  }
}
