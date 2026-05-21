// Wiring-map coverage test — Phase 0 skeleton.
//
// Verifies bidirectional consistency between docs/wiring-map.md and
// the live Riverpod providers, routes, and model classes.
//
// Phase 5 will populate this file with the full provider inventory
// and bidirectional checks. Until then this skeleton verifies that
// the wiring-map document exists and contains the required header.

import 'dart:io';

import 'package:test/test.dart';

void main() {
  group('Wiring-map coverage (Phase 0 skeleton)', () {
    test('docs/wiring-map.md exists', () {
      final file = File('docs/wiring-map.md');
      expect(
        file.existsSync(),
        isTrue,
        reason: 'docs/wiring-map.md must exist',
      );
    });

    test('docs/wiring-map.md has content', () {
      final file = File('docs/wiring-map.md');
      final content = file.readAsStringSync();
      expect(
        content.trim(),
        isNotEmpty,
        reason: 'docs/wiring-map.md must not be empty',
      );
    });

    // Phase 5 additions (currently commented — Phase 5 will
    // implement the full bidirectional provider check):
    //
    // test('Every Riverpod provider is in the wiring map', () { ... });
    // test('Every wiring-map provider row references a real file', () { ... });
    // test('Every route in app_router.dart is in the wiring map', () { ... });
  });
}
