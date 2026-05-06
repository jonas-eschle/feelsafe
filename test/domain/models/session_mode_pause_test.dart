/// Tests for [SessionMode.pauseAllowed] and [SessionMode.maxPauseMinutes]:
/// default values, JSON round-trip, copyWith, and equality semantics.
///
/// Spec 01 §Pause Behavior.
library;

import 'package:checks/checks.dart';
import 'package:test/test.dart';

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/models/session_mode.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Minimal mode for these tests — no chain steps needed.
SessionMode _mode({
  bool? pauseAllowed,
  int? maxPauseMinutes,
}) => SessionMode(
  id: 'test-pause',
  name: 'Pause Test',
  checkInType: ChainStepType.holdButton,
  pauseAllowed: pauseAllowed ?? true,
  maxPauseMinutes: maxPauseMinutes,
);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('SessionMode.pauseAllowed default', () {
    test('default pauseAllowed is true', () {
      // Arrange / Act
      final m = _mode();
      // Assert
      check(m.pauseAllowed).isTrue();
    });

    test('default maxPauseMinutes is null', () {
      final m = _mode();
      check(m.maxPauseMinutes).isNull();
    });
  });

  group('SessionMode JSON round-trip', () {
    test('pauseAllowed=true survives toJson/fromJson', () {
      // Arrange
      final m = _mode(pauseAllowed: true);
      // Act
      final rt = SessionMode.fromJson(m.toJson());
      // Assert
      check(rt.pauseAllowed).isTrue();
    });

    test('pauseAllowed=false survives toJson/fromJson', () {
      final m = _mode(pauseAllowed: false);
      final rt = SessionMode.fromJson(m.toJson());
      check(rt.pauseAllowed).isFalse();
    });

    test('maxPauseMinutes=null survives toJson/fromJson', () {
      final m = _mode(maxPauseMinutes: null);
      final rt = SessionMode.fromJson(m.toJson());
      check(rt.maxPauseMinutes).isNull();
    });

    test('maxPauseMinutes=30 survives toJson/fromJson', () {
      final m = _mode(maxPauseMinutes: 30);
      final rt = SessionMode.fromJson(m.toJson());
      check(rt.maxPauseMinutes).equals(30);
    });

    test('legacy JSON without pause keys deserializes to defaults', () {
      // Arrange — omit both keys from the raw JSON map.
      final raw = <String, Object?>{
        'id': 'legacy',
        'name': 'Legacy',
        'checkInType': 'holdButton',
      };
      // Act
      final m = SessionMode.fromJson(raw);
      // Assert — defaults apply.
      check(m.pauseAllowed).isTrue();
      check(m.maxPauseMinutes).isNull();
    });
  });

  group('SessionMode.copyWith pause fields', () {
    test('copyWith(pauseAllowed: false) flips the flag', () {
      // Arrange
      final original = _mode(pauseAllowed: true);
      // Act
      final copy = original.copyWith(pauseAllowed: false);
      // Assert
      check(copy.pauseAllowed).isFalse();
      check(original.pauseAllowed).isTrue(); // original unchanged
    });

    test('copyWith(maxPauseMinutes: 30) sets the value', () {
      final original = _mode();
      final copy = original.copyWith(maxPauseMinutes: 30);
      check(copy.maxPauseMinutes).equals(30);
    });

    test('copyWith(clearMaxPauseMinutes: true) nulls the value', () {
      final original = _mode(maxPauseMinutes: 30);
      final copy = original.copyWith(clearMaxPauseMinutes: true);
      check(copy.maxPauseMinutes).isNull();
    });

    test(
      'copyWith without clearMaxPauseMinutes preserves existing value',
      () {
        final original = _mode(maxPauseMinutes: 15);
        final copy = original.copyWith(pauseAllowed: false);
        check(copy.maxPauseMinutes).equals(15);
      },
    );
  });

  group('SessionMode equality accounts for pause fields', () {
    test('modes differing only in pauseAllowed are NOT equal', () {
      // Arrange
      final a = _mode(pauseAllowed: true);
      final b = _mode(pauseAllowed: false);
      // Assert
      check(a).not((m) => m.equals(b));
    });

    test('modes differing only in maxPauseMinutes are NOT equal', () {
      final a = _mode(maxPauseMinutes: null);
      final b = _mode(maxPauseMinutes: 30);
      check(a).not((m) => m.equals(b));
    });

    test('identical pause fields yield equal modes', () {
      final a = _mode(pauseAllowed: false, maxPauseMinutes: 10);
      final b = _mode(pauseAllowed: false, maxPauseMinutes: 10);
      check(a).equals(b);
    });

    test('hashCode is the same for equal modes', () {
      final a = _mode(pauseAllowed: false, maxPauseMinutes: 10);
      final b = _mode(pauseAllowed: false, maxPauseMinutes: 10);
      check(a.hashCode).equals(b.hashCode);
    });
  });
}
