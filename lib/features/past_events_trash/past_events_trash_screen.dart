import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:guardianangela/features/past_events_trash/past_events_trash_controller.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// Trash screen for soft-deleted session logs (spec 04:2458).
///
/// Lists every row with `deletedAtMs != null`, augmented with the
/// remaining-restore countdown derived from `now - deletedAt` versus
/// `AppSettings.trashRetentionDays`. Per-row actions: Restore (clears
/// `deletedAtMs`) and Delete Permanently (hard-delete).
///
/// On every controller build the screen also triggers a
/// `purgeExpiredLogs(...)` so any tombstone older than the retention
/// window is hard-deleted before being rendered.
class PastEventsTrashScreen extends ConsumerWidget {
  /// Creates a [PastEventsTrashScreen].
  const PastEventsTrashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final stateAsync = ref.watch(pastEventsTrashControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.pastEventsTrashTitle),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: (String key) {
              if (key == 'empty') _confirmEmptyTrash(context, ref);
            },
            itemBuilder: (_) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'empty',
                child: Text(l10n.pastEventsTrashEmptyAll),
              ),
            ],
          ),
        ],
      ),
      body: stateAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, _) =>
            Center(child: Text(l10n.commonErrorWithDetail(e))),
        data: (PastEventsTrashState state) => _TrashBody(state: state),
      ),
    );
  }

  Future<void> _confirmEmptyTrash(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) =>
          const _TypedConfirmDialog(expected: 'EMPTY TRASH'),
    );
    if (ok ?? false) {
      final count = await ref
          .read(pastEventsTrashControllerProvider.notifier)
          .emptyTrash();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pastEventsTrashEmptyAllSuccess(count))),
      );
    }
  }
}

/// Double-confirmation dialog that requires the user to type the
/// [expected] string verbatim before the FilledButton enables.
class _TypedConfirmDialog extends StatefulWidget {
  const _TypedConfirmDialog({required this.expected});

  final String expected;

  @override
  State<_TypedConfirmDialog> createState() => _TypedConfirmDialogState();
}

class _TypedConfirmDialogState extends State<_TypedConfirmDialog> {
  final TextEditingController _ctl = TextEditingController();
  bool _match = false;

  @override
  void initState() {
    super.initState();
    _ctl.addListener(() {
      final next = _ctl.text == widget.expected;
      if (next != _match) setState(() => _match = next);
    });
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.pastEventsTrashEmptyAllConfirmTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(l10n.pastEventsTrashEmptyAllConfirmBody),
          const SizedBox(height: 12),
          TextField(
            controller: _ctl,
            autofocus: true,
            decoration: InputDecoration(hintText: widget.expected),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          onPressed: _match ? () => Navigator.of(context).pop(true) : null,
          child: Text(l10n.pastEventsTrashEmptyAll),
        ),
      ],
    );
  }
}

class _TrashBody extends ConsumerWidget {
  const _TrashBody({required this.state});

  final PastEventsTrashState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            l10n.pastEventsTrashRetentionNote(state.retentionDays),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        Expanded(
          child: state.logs.isEmpty
              ? Center(child: Text(l10n.pastEventsTrashEmpty))
              : ListView.builder(
                  itemCount: state.logs.length,
                  itemBuilder: (BuildContext ctx, int i) {
                    final item = state.logs[i];
                    return _TrashTile(
                      log: item,
                      retentionDays: state.retentionDays,
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _TrashTile extends ConsumerWidget {
  const _TrashTile({required this.log, required this.retentionDays});

  final PastEventsTrashLog log;
  final int retentionDays;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final remaining = _remainingDays(log.deletedAt, retentionDays);
    return ListTile(
      leading: Icon(
        log.isSimulation ? Icons.play_circle_outline : Icons.shield,
      ),
      title: Text(log.modeName),
      subtitle: Text(
        '${_formatTime(log.startedAt)} • '
        '${l10n.pastEventsTrashRemainingDays(remaining)}',
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IconButton(
            icon: const Icon(Icons.restore),
            tooltip: l10n.pastEventsRestore,
            onPressed: () => ref
                .read(pastEventsTrashControllerProvider.notifier)
                .restore(log.id),
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever),
            tooltip: l10n.pastEventsTrashDeletePermanently,
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: Text(l10n.pastEventsTrashDeletePermanently),
        content: Text(l10n.pastEventsTrashDeletePermanentlyBody),
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
    if (ok == true) {
      await ref
          .read(pastEventsTrashControllerProvider.notifier)
          .deletePermanently(log.id);
    }
  }

  int _remainingDays(DateTime deletedAt, int retentionDays) {
    final elapsed = DateTime.now().toUtc().difference(deletedAt).inDays;
    final remaining = retentionDays - elapsed;
    return remaining < 0 ? 0 : remaining;
  }

  String _formatTime(DateTime t) =>
      '${t.year}-${t.month.toString().padLeft(2, '0')}-'
      '${t.day.toString().padLeft(2, '0')} '
      '${t.hour.toString().padLeft(2, '0')}:'
      '${t.minute.toString().padLeft(2, '0')}';
}
