import 'package:flutter/foundation.dart' show setEquals;
import 'package:flutter/material.dart';

import 'package:guardianangela/domain/configs/step_config.dart';
import 'package:guardianangela/domain/enums/sms_contact_selection.dart';
import 'package:guardianangela/domain/models/emergency_contact.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// Always-visible grid of one toggle button per emergency contact, used to
/// pick the recipients of an `smsContact` step (spec 04 §SMS Contact
/// Selection).
///
/// A contact whose [EmergencyContact.channels] includes the step's
/// [SmsContactConfig.channel] is selectable; one that does not is greyed and
/// can never be selected. Toggling re-infers [SmsContactConfig.contactSelection]:
/// every channel-capable contact selected → [SmsContactSelection.allContacts]
/// (with `contactIds` cleared to null — a non-null id list under `allContacts`
/// is treated as specific IDs by the runtime resolver); any strict subset →
/// [SmsContactSelection.specificIds].
class SmsContactGrid extends StatelessWidget {
  /// Creates an [SmsContactGrid].
  const SmsContactGrid({
    super.key,
    required this.contacts,
    required this.config,
    required this.onChanged,
    required this.onManageContacts,
  });

  /// All emergency contacts in the repository (capable + incapable).
  final List<EmergencyContact> contacts;

  /// The current smsContact config whose selection this grid edits.
  final SmsContactConfig config;

  /// Called with an updated config when the selection changes.
  final ValueChanged<SmsContactConfig> onChanged;

  /// Called when the user taps the empty-state or wants to manage contacts.
  final VoidCallback onManageContacts;

  /// Channel-capable contacts, ordered by [EmergencyContact.sortOrder].
  List<EmergencyContact> get _capable => <EmergencyContact>[
    ...contacts.where((c) => c.channels.contains(config.channel)),
  ]..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

  /// The currently-selected contact ids, mirroring the runtime resolver.
  Set<String> _selectedIds(List<EmergencyContact> capable) {
    final Set<String> capableIds = capable.map((c) => c.id).toSet();
    final List<String>? ids = config.contactIds;
    // Legacy: allContacts + explicit ids → treated as specific IDs.
    if (config.contactSelection == SmsContactSelection.allContacts &&
        ids != null &&
        ids.isNotEmpty) {
      return ids.toSet().intersection(capableIds);
    }
    return switch (config.contactSelection) {
      SmsContactSelection.allContacts => capableIds,
      SmsContactSelection.specificIds =>
        (ids ?? const <String>[]).toSet().intersection(capableIds),
      SmsContactSelection.firstContact =>
        capable.isEmpty ? <String>{} : <String>{capable.first.id},
    };
  }

  /// Rebuilds the config with [selection]/[ids], clearing fields correctly
  /// (cannot use copyWith — it can't null [SmsContactConfig.contactIds]).
  SmsContactConfig _withSelection(
    SmsContactSelection selection,
    List<String>? ids,
  ) => SmsContactConfig(
    contactIds: ids,
    contactSelection: selection,
    channel: config.channel,
    includeLocation: config.includeLocation,
    includeMedicalInfo: config.includeMedicalInfo,
    autoRecordAudio: config.autoRecordAudio,
    recordDurationSeconds: config.recordDurationSeconds,
    messageTemplate: config.messageTemplate,
    blackScreenMode: config.blackScreenMode,
  );

  void _toggle(EmergencyContact contact) {
    final List<EmergencyContact> capable = _capable;
    final Set<String> capableIds = capable.map((c) => c.id).toSet();
    final Set<String> next = <String>{..._selectedIds(capable)};
    if (!next.remove(contact.id)) next.add(contact.id);
    if (next.isNotEmpty && setEquals(next, capableIds)) {
      onChanged(_withSelection(SmsContactSelection.allContacts, null));
    } else {
      onChanged(
        _withSelection(SmsContactSelection.specificIds, next.toList()..sort()),
      );
    }
  }

  String _summary(
    AppLocalizations l10n,
    List<EmergencyContact> capable,
    Set<String> selected,
  ) {
    if (selected.isEmpty) return l10n.smsContactSummaryNone;
    if (selected.length == capable.length) return l10n.smsContactSummaryAll;
    final String names = capable
        .where((c) => selected.contains(c.id))
        .map((c) => c.name)
        .join(', ');
    return l10n.smsContactSummaryTo(names);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (contacts.isEmpty) {
      return ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.person_add_alt_1_outlined),
        title: Text(l10n.smsContactEmptyAddPrompt),
        trailing: const Icon(Icons.chevron_right),
        onTap: onManageContacts,
      );
    }
    final List<EmergencyContact> capable = _capable;
    final Set<String> capableIds = capable.map((c) => c.id).toSet();
    final Set<String> selected = _selectedIds(capable);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            _summary(l10n, capable, selected),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: <Widget>[
            for (final EmergencyContact c in contacts)
              _ContactChip(
                contact: c,
                capable: capableIds.contains(c.id),
                selected: selected.contains(c.id),
                disabledTooltip: l10n.smsContactChannelDisabledTooltip,
                onToggle: () => _toggle(c),
              ),
          ],
        ),
      ],
    );
  }
}

class _ContactChip extends StatelessWidget {
  const _ContactChip({
    required this.contact,
    required this.capable,
    required this.selected,
    required this.disabledTooltip,
    required this.onToggle,
  });

  final EmergencyContact contact;
  final bool capable;
  final bool selected;
  final String disabledTooltip;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    if (!capable) {
      return Tooltip(
        message: disabledTooltip,
        child: FilterChip(
          label: Text(contact.name),
          onSelected: null,
          avatar: const Icon(Icons.block_outlined, size: 18),
        ),
      );
    }
    return FilterChip(
      label: Text(contact.name),
      selected: selected,
      avatar: Icon(
        selected ? Icons.check_circle : Icons.person_outline,
        size: 18,
      ),
      onSelected: (_) => onToggle(),
    );
  }
}
