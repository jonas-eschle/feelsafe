/// Supplemental tests for [AppDefaults] covering the `toString()`
/// branch (line 126) and the `clearDefaultDistressModeId` path in
/// `copyWith` (line 90).
library;

import 'package:checks/checks.dart';
import 'package:test/test.dart';

import 'package:guardianangela/domain/models/models.dart';

void main() {
  group('AppDefaults.toString', () {
    test('shows template count', () {
      const d = AppDefaults();
      check(d.toString()).contains('AppDefaults');
      check(d.toString()).contains('0');
    });
  });

  group('AppDefaults.copyWith — clearDefaultDistressModeId', () {
    test('clearDefaultDistressModeId=true clears the id to null', () {
      const d = AppDefaults(defaultDistressModeId: 'some-id');
      check(d.defaultDistressModeId).equals('some-id');
      final cleared = d.copyWith(clearDefaultDistressModeId: true);
      check(cleared.defaultDistressModeId).isNull();
    });

    test('clearDefaultDistressModeId=false preserves existing id', () {
      const d = AppDefaults(defaultDistressModeId: 'my-id');
      final preserved = d.copyWith(clearDefaultDistressModeId: false);
      check(preserved.defaultDistressModeId).equals('my-id');
    });

    test('providing a new distressModeId replaces the old one', () {
      const d = AppDefaults(defaultDistressModeId: 'old-id');
      final replaced =
          d.copyWith(defaultDistressModeId: 'new-id');
      check(replaced.defaultDistressModeId).equals('new-id');
    });
  });
}
