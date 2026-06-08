/// Unit tests for [resolveSmsTargets] — the single shared SMS-target
/// resolver used by both [SmsContactStrategy] (runtime) and
/// [validateModeDraft] (save-time validation).
///
/// Spec ref: docs/spec/02-event-types.md §6 smsContact; decision 15/15b.
///
/// Every branch of the resolver is covered directly here so the two call
/// sites can inherit one tested implementation and never drift:
/// - allContacts (true "all")
/// - legacy allContacts + explicit ids → specific ids
/// - firstContact (by sortOrder, ties, empty)
/// - specificIds (matches, missing-id skip, null ids, empty ids, order,
///   duplicates)
library;

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/domain/configs/step_config.dart';
import 'package:guardianangela/domain/enums/sms_contact_selection.dart';
import 'package:guardianangela/domain/models/emergency_contact.dart';
import 'package:guardianangela/domain/orchestration/resolve_sms_targets.dart';

EmergencyContact _contact(String id, {int sortOrder = 0}) => EmergencyContact(
  id: id,
  name: id,
  phoneNumber: '+1555000$id',
  sortOrder: sortOrder,
);

/// The ids of the resolved targets, in order.
List<String> _ids(List<EmergencyContact> contacts) => <String>[
  for (final EmergencyContact c in contacts) c.id,
];

void main() {
  group('resolveSmsTargets — allContacts (true "all")', () {
    test('returns every contact in list order', () {
      final contacts = <EmergencyContact>[
        _contact('a'),
        _contact('b', sortOrder: 1),
        _contact('c', sortOrder: 2),
      ];
      final result = resolveSmsTargets(const SmsContactConfig(), contacts);
      check(_ids(result)).deepEquals(<String>['a', 'b', 'c']);
    });

    test('empty repo → empty list', () {
      final result = resolveSmsTargets(
        const SmsContactConfig(),
        const <EmergencyContact>[],
      );
      check(result).isEmpty();
    });
  });

  group('resolveSmsTargets — legacy allContacts + explicit ids', () {
    test(
      'non-empty contactIds under allContacts → treated as specific ids',
      () {
        final contacts = <EmergencyContact>[
          _contact('a'),
          _contact('b', sortOrder: 1),
          _contact('c', sortOrder: 2),
        ];
        // allContacts selection (default) but ids present → only those ids.
        final result = resolveSmsTargets(
          const SmsContactConfig(contactIds: <String>['b']),
          contacts,
        );
        check(_ids(result)).deepEquals(<String>['b']);
      },
    );

    test('empty contactIds under allContacts → genuine allContacts', () {
      final contacts = <EmergencyContact>[
        _contact('a'),
        _contact('b', sortOrder: 1),
      ];
      final result = resolveSmsTargets(
        const SmsContactConfig(contactIds: <String>[]),
        contacts,
      );
      check(_ids(result)).deepEquals(<String>['a', 'b']);
    });
  });

  group('resolveSmsTargets — firstContact', () {
    test('lowest sortOrder wins', () {
      // 'b' has the lowest sortOrder (0, the default) → it is the target.
      final contacts = <EmergencyContact>[
        _contact('a', sortOrder: 2),
        _contact('b'),
        _contact('c', sortOrder: 1),
      ];
      final result = resolveSmsTargets(
        const SmsContactConfig(
          contactSelection: SmsContactSelection.firstContact,
        ),
        contacts,
      );
      check(_ids(result)).deepEquals(<String>['b']);
    });

    test('ties broken by list order (stable sort)', () {
      final contacts = <EmergencyContact>[
        _contact('first', sortOrder: 1),
        _contact('second', sortOrder: 1),
      ];
      final result = resolveSmsTargets(
        const SmsContactConfig(
          contactSelection: SmsContactSelection.firstContact,
        ),
        contacts,
      );
      check(_ids(result)).deepEquals(<String>['first']);
    });

    test('does not mutate the input list order', () {
      // 'b' sorts first (sortOrder 0, the default) but list order is 'a','b'.
      final contacts = <EmergencyContact>[
        _contact('a', sortOrder: 2),
        _contact('b'),
      ];
      resolveSmsTargets(
        const SmsContactConfig(
          contactSelection: SmsContactSelection.firstContact,
        ),
        contacts,
      );
      // The caller's list must be untouched (resolver sorts a copy).
      check(_ids(contacts)).deepEquals(<String>['a', 'b']);
    });

    test('empty repo → empty list', () {
      final result = resolveSmsTargets(
        const SmsContactConfig(
          contactSelection: SmsContactSelection.firstContact,
        ),
        const <EmergencyContact>[],
      );
      check(result).isEmpty();
    });
  });

  group('resolveSmsTargets — specificIds', () {
    test('matches a subset, order follows the id list', () {
      final contacts = <EmergencyContact>[
        _contact('a'),
        _contact('b', sortOrder: 1),
        _contact('c', sortOrder: 2),
      ];
      final result = resolveSmsTargets(
        const SmsContactConfig(
          contactSelection: SmsContactSelection.specificIds,
          contactIds: <String>['c', 'a'],
        ),
        contacts,
      );
      check(_ids(result)).deepEquals(<String>['c', 'a']);
    });

    test('skips ids with no matching contact', () {
      final contacts = <EmergencyContact>[_contact('a')];
      final result = resolveSmsTargets(
        const SmsContactConfig(
          contactSelection: SmsContactSelection.specificIds,
          contactIds: <String>['missing', 'a'],
        ),
        contacts,
      );
      check(_ids(result)).deepEquals(<String>['a']);
    });

    test('preserves duplicate ids (matches runtime map().whereType)', () {
      final contacts = <EmergencyContact>[_contact('a')];
      final result = resolveSmsTargets(
        const SmsContactConfig(
          contactSelection: SmsContactSelection.specificIds,
          contactIds: <String>['a', 'a'],
        ),
        contacts,
      );
      check(_ids(result)).deepEquals(<String>['a', 'a']);
    });

    test('null contactIds → empty list', () {
      final contacts = <EmergencyContact>[_contact('a')];
      final result = resolveSmsTargets(
        const SmsContactConfig(
          contactSelection: SmsContactSelection.specificIds,
        ),
        contacts,
      );
      check(result).isEmpty();
    });

    test('empty contactIds → empty list', () {
      final contacts = <EmergencyContact>[_contact('a')];
      final result = resolveSmsTargets(
        const SmsContactConfig(
          contactSelection: SmsContactSelection.specificIds,
          contactIds: <String>[],
        ),
        contacts,
      );
      check(result).isEmpty();
    });
  });
}
