/// Unit tests for `SessionContext` — configFor fallback, placeholder
/// substitution.
library;

import 'package:checks/checks.dart';
import 'package:test/test.dart';

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/models/models.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('SessionContext.configFor', () {
    test('returns step.config when non-null', () {
      final step = holdStep(releaseSensitivity: 0.9);
      const ctx = SessionContext(eventDefaults: EventDefaults());
      final c = ctx.configFor(step);
      check(c).isA<HoldButtonConfig>();
      check((c as HoldButtonConfig).releaseSensitivity).equals(0.9);
    });

    test('falls back to eventDefaults when step.config is null', () {
      final step_ = step(type: ChainStepType.holdButton);
      const ctx = SessionContext(
        eventDefaults: EventDefaults(
          holdButton: HoldButtonConfig(releaseSensitivity: 0.7),
        ),
      );
      final c = ctx.configFor(step_);
      check((c as HoldButtonConfig).releaseSensitivity).equals(0.7);
    });

    test('throws StateError if both null', () {
      final step_ = step(type: ChainStepType.holdButton);
      const ctx = SessionContext();
      check(() => ctx.configFor(step_)).throws<StateError>();
    });

    test('falls back for each step type', () {
      const ctx = SessionContext(eventDefaults: EventDefaults());
      for (final type in ChainStepType.values) {
        final step_ = step(type: type);
        check(ctx.configFor(step_)).isA<StepConfig>();
      }
    });
  });

  group('SessionContext.resolvePlaceholders', () {
    test('substitutes name from userProfile', () {
      const ctx = SessionContext(userProfile: UserProfile(name: 'Alice'));
      check(ctx.resolvePlaceholders('Hello {name}')).equals('Hello Alice');
    });

    test('explicit name beats userProfile', () {
      const ctx = SessionContext(userProfile: UserProfile(name: 'Alice'));
      check(ctx.resolvePlaceholders('Hi {name}', name: 'Bob')).equals('Hi Bob');
    });

    test('missing userProfile yields empty name', () {
      const ctx = SessionContext();
      check(ctx.resolvePlaceholders('Hi {name}')).equals('Hi ');
    });

    test('substitutes location', () {
      const ctx = SessionContext();
      check(
        ctx.resolvePlaceholders('Loc: {location}', location: 'Zurich'),
      ).equals('Loc: Zurich');
    });

    test('substitutes time', () {
      const ctx = SessionContext();
      check(
        ctx.resolvePlaceholders('Time: {time}', time: '10:00'),
      ).equals('Time: 10:00');
    });

    test('substitutes description', () {
      const ctx = SessionContext();
      check(
        ctx.resolvePlaceholders('D: {description}', description: 'help'),
      ).equals('D: help');
    });

    test('unresolved placeholders become empty', () {
      const ctx = SessionContext();
      check(
        ctx.resolvePlaceholders('{name} @ {location}, {time}'),
      ).equals(' @ , ');
    });

    test('all four placeholders together', () {
      const ctx = SessionContext(userProfile: UserProfile(name: 'A'));
      check(
        ctx.resolvePlaceholders(
          '{name}|{location}|{time}|{description}',
          location: 'L',
          time: 'T',
          description: 'D',
        ),
      ).equals('A|L|T|D');
    });
  });

  group('SessionContext copyWith', () {
    test('replaces mode', () {
      const ctx = SessionContext();
      final mode = makeMode();
      check(ctx.copyWith(mode: mode).mode).equals(mode);
    });

    test('replaces contacts', () {
      const ctx = SessionContext();
      final contacts = [makeContact()];
      check(ctx.copyWith(contacts: contacts).contacts).deepEquals(contacts);
    });

    test('replaces userProfile', () {
      const ctx = SessionContext();
      const profile = UserProfile(name: 'A');
      check(ctx.copyWith(userProfile: profile).userProfile).equals(profile);
    });

    test('replaces isSimulation', () {
      const ctx = SessionContext();
      check(ctx.copyWith(isSimulation: true).isSimulation).isTrue();
    });

    test('replaces reminderTemplates', () {
      const ctx = SessionContext();
      const tpl = ReminderTemplate(
        id: 't1',
        name: 'n',
        title: 'T',
        body: 'B',
        confirmationType: ConfirmationType.dismiss,
        displayStyle: ReminderDisplayStyle.subtle,
        isGlobal: true,
      );
      check(
        ctx.copyWith(reminderTemplates: const [tpl]).reminderTemplates,
      ).deepEquals(const [tpl]);
    });

    test('replaces hadMedicalInfo', () {
      const ctx = SessionContext();
      check(ctx.copyWith(hadMedicalInfo: true).hadMedicalInfo).isTrue();
    });

    test('replaces eventDefaults', () {
      const ctx = SessionContext();
      const ed = EventDefaults();
      check(ctx.copyWith(eventDefaults: ed).eventDefaults).equals(ed);
    });

    test('replaces emergencyNumber', () {
      const ctx = SessionContext();
      check(ctx.copyWith(emergencyNumber: '999').emergencyNumber).equals('999');
    });

    test('null copyWith preserves all fields', () {
      final ctx = SessionContext(
        mode: makeMode(),
        contacts: [makeContact()],
        userProfile: const UserProfile(name: 'A'),
        isSimulation: true,
        hadMedicalInfo: true,
        eventDefaults: const EventDefaults(),
        emergencyNumber: '911',
      );
      check(ctx.copyWith()).equals(ctx);
    });
  });

  group('SessionContext equality / hashCode / toString', () {
    test('identical contexts equal', () {
      const ctx = SessionContext();
      check(ctx == ctx).isTrue();
    });

    test('equal values equal', () {
      const a = SessionContext();
      const b = SessionContext();
      check(a).equals(b);
      check(a.hashCode).equals(b.hashCode);
    });

    test('toString exposes key fields', () {
      final mode = makeMode(name: 'Walk');
      final ctx = SessionContext(mode: mode);
      check(ctx.toString()).contains('Walk');
    });

    test('different types unequal', () {
      const ctx = SessionContext();
      // ignore: unrelated_type_equality_checks
      check(ctx == 'not a context').isFalse();
    });

    test('different mode unequal', () {
      const a = SessionContext();
      final b = SessionContext(mode: makeMode());
      check(a == b).isFalse();
    });

    test('different userProfile unequal', () {
      const a = SessionContext();
      const b = SessionContext(userProfile: UserProfile(name: 'A'));
      check(a == b).isFalse();
    });

    test('different isSimulation unequal', () {
      const a = SessionContext();
      const b = SessionContext(isSimulation: true);
      check(a == b).isFalse();
    });

    test('different hadMedicalInfo unequal', () {
      const a = SessionContext();
      const b = SessionContext(hadMedicalInfo: true);
      check(a == b).isFalse();
    });

    test('different eventDefaults unequal', () {
      const a = SessionContext();
      const b = SessionContext(eventDefaults: EventDefaults());
      check(a == b).isFalse();
    });

    test('different emergencyNumber unequal', () {
      const a = SessionContext();
      const b = SessionContext(emergencyNumber: '999');
      check(a == b).isFalse();
    });

    test('different contacts length unequal', () {
      const a = SessionContext();
      final b = SessionContext(contacts: [makeContact()]);
      check(a == b).isFalse();
    });

    test('different contacts at index unequal', () {
      final a = SessionContext(contacts: [makeContact(name: 'A')]);
      final b = SessionContext(contacts: [makeContact(name: 'B')]);
      check(a == b).isFalse();
    });

    test('different reminderTemplates length unequal', () {
      const a = SessionContext();
      const tpl = ReminderTemplate(
        id: 't1',
        name: 'n',
        title: 'T',
        body: 'B',
        confirmationType: ConfirmationType.dismiss,
        displayStyle: ReminderDisplayStyle.subtle,
        isGlobal: true,
      );
      const b = SessionContext(reminderTemplates: [tpl]);
      check(a == b).isFalse();
    });

    test('different reminderTemplates at index unequal', () {
      const t1 = ReminderTemplate(
        id: 't1',
        name: 'n',
        title: 'T',
        body: 'B',
        confirmationType: ConfirmationType.dismiss,
        displayStyle: ReminderDisplayStyle.subtle,
        isGlobal: true,
      );
      const t2 = ReminderTemplate(
        id: 't2',
        name: 'n',
        title: 'T',
        body: 'B',
        confirmationType: ConfirmationType.dismiss,
        displayStyle: ReminderDisplayStyle.subtle,
        isGlobal: true,
      );
      const a = SessionContext(reminderTemplates: [t1]);
      const b = SessionContext(reminderTemplates: [t2]);
      check(a == b).isFalse();
    });
  });
}
