import 'package:guardianangela/domain/configs/step_config.dart';
import 'package:guardianangela/domain/enums/sms_contact_selection.dart';
import 'package:guardianangela/domain/models/emergency_contact.dart';

/// Resolves which contacts an `smsContact` step targets, before any channel
/// filter is applied.
///
/// This is the single source of truth for SMS-step recipient selection. Both
/// the runtime strategy (`SmsContactStrategy`) and the save-time validator
/// (`validateModeDraft`) call it, so the set of people a distress message
/// reaches at runtime can never silently diverge from the set the editor
/// validates against (spec 02:319, decision 15/15b).
///
/// Resolution rules, in priority order, matching [SmsContactSelection]:
/// - **Legacy back-compat:** when [SmsContactConfig.contactSelection] is
///   [SmsContactSelection.allContacts] AND [SmsContactConfig.contactIds] is
///   non-null and non-empty, the ids are honoured as *specific ids* (a
///   non-null id list under `allContacts` was historically written by an
///   older picker and must be read as a static selection — see spec 03
///   §SmsContactConfig).
/// - [SmsContactSelection.allContacts]: every contact in [contacts]
///   (dynamic — newly added contacts are auto-included).
/// - [SmsContactSelection.firstContact]: only the contact with the lowest
///   [EmergencyContact.sortOrder]; ties broken by list order (Dart's
///   `List.sort` is stable). An empty [contacts] yields an empty list.
/// - [SmsContactSelection.specificIds]: only the contacts whose id appears in
///   [SmsContactConfig.contactIds] (order preserved, duplicates preserved,
///   missing ids skipped). A null or empty id list yields an empty list.
///
/// The returned list preserves selection order and may contain duplicates if
/// an id list repeats one — exactly as the runtime resolver does.
List<EmergencyContact> resolveSmsTargets(
  SmsContactConfig config,
  List<EmergencyContact> contacts,
) {
  final List<String>? ids = config.contactIds;

  // Legacy back-compat: allContacts + explicit contactIds → specific ids.
  if (config.contactSelection == SmsContactSelection.allContacts &&
      ids != null &&
      ids.isNotEmpty) {
    return _contactsByIds(ids, contacts);
  }

  return switch (config.contactSelection) {
    SmsContactSelection.allContacts => contacts,
    SmsContactSelection.firstContact =>
      contacts.isEmpty
          ? const <EmergencyContact>[]
          : <EmergencyContact>[
              (List<EmergencyContact>.of(
                contacts,
              )..sort((a, b) => a.sortOrder.compareTo(b.sortOrder))).first,
            ],
    SmsContactSelection.specificIds =>
      (ids == null || ids.isEmpty)
          ? const <EmergencyContact>[]
          : _contactsByIds(ids, contacts),
  };
}

/// The contacts in [contacts] whose id appears in [ids].
///
/// Order and duplicates follow [ids]; ids with no matching contact are
/// skipped. Mirrors the runtime `ids.map(byId).whereType<EmergencyContact>()`.
List<EmergencyContact> _contactsByIds(
  List<String> ids,
  List<EmergencyContact> contacts,
) {
  final Map<String, EmergencyContact> byId = <String, EmergencyContact>{
    for (final EmergencyContact c in contacts) c.id: c,
  };
  return <EmergencyContact>[
    for (final String id in ids)
      if (byId[id] case final EmergencyContact c) c,
  ];
}
