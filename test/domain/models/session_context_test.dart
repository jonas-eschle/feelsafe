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
      check(ctx.resolvePlaceholders('Loc: {location}', location: 'Zurich'))
          .equals('Loc: Zurich');
    });

    test('substitutes time', () {
      const ctx = SessionContext();
      check(ctx.resolvePlaceholders('Time: {time}', time: '10:00'))
          .equals('Time: 10:00');
    });

    test('substitutes description', () {
      const ctx = SessionContext();
      check(ctx.resolvePlaceholders(
        'D: {description}',
        description: 'help',
      )).equals('D: help');
    });

    test('unresolved placeholders become empty', () {
      const ctx = SessionContext();
      check(ctx.resolvePlaceholders('{name} @ {location}, {time}'))
          .equals(' @ , ');
    });

    test('all four placeholders together', () {
      const ctx = SessionContext(userProfile: UserProfile(name: 'A'));
      check(ctx.resolvePlaceholders(
        '{name}|{location}|{time}|{description}',
        location: 'L',
        time: 'T',
        description: 'D',
      )).equals('A|L|T|D');
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
  });
}
