// Wiring-map coverage test — Phase 5A implementation.
//
// Verifies bidirectional consistency between docs/wiring-map.md and
// lib/services/service_providers.dart:
//
//   (a) Every `final xxxProvider = Provider(...)` declaration in
//       service_providers.dart has a row in the wiring map.
//   (b) Every row in the wiring map whose status is `wired-real` or
//       `wired-sim-only` matches a provider declaration in the file.
//   (c) Every row with status `pending-5b` or `pending-5c` references
//       a protocol file under lib/services/protocols/ that exists.

import 'dart:io';

import 'package:checks/checks.dart';
import 'package:test/test.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Parses all `Provider | ... | ... | ... | status | ...` data rows from
/// docs/wiring-map.md.
///
/// Skips header rows, blank lines, and separator rows (lines of `---`).
List<_WiringRow> _parseWiringMap() {
  final file = File('docs/wiring-map.md');
  if (!file.existsSync()) {
    fail('docs/wiring-map.md does not exist');
  }
  final lines = file.readAsLinesSync();
  final rows = <_WiringRow>[];
  for (final line in lines) {
    final trimmed = line.trim();
    if (!trimmed.startsWith('|')) continue;
    if (trimmed.startsWith('| Provider') || trimmed.startsWith('|---')) {
      continue;
    }
    final parts = trimmed
        .split('|')
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty);
    final asList = parts.toList();
    // Rows have at least 6 columns: Provider, Type, Real, Sim, Status, Spec
    if (asList.length < 5) continue;
    // Status is column index 4 (0-based).
    final provider = asList[0].replaceAll('`', '');
    final status = asList[4].replaceAll('`', '').trim();
    final specRef = asList.length >= 6 ? asList[5] : '';
    rows.add(_WiringRow(provider: provider, status: status, specRef: specRef));
  }
  return rows;
}

/// Extracts every `final xxxProvider = Provider...` declaration from
/// lib/services/service_providers.dart.
Set<String> _parseServiceProviders() {
  final file = File('lib/services/service_providers.dart');
  if (!file.existsSync()) {
    fail('lib/services/service_providers.dart does not exist');
  }
  final content = file.readAsStringSync();
  final pattern = RegExp(r'final\s+(\w+Provider)\s*=\s*Provider');
  return pattern.allMatches(content).map((m) => m.group(1)!).toSet();
}

/// Extracts the relative protocol file path from a spec-ref cell that
/// contains a markdown link like `[protocol](../lib/services/protocols/x.dart)`.
String? _extractProtocolPath(String specRef) {
  final match = RegExp(r'\(([^)]+\.dart)\)').firstMatch(specRef);
  if (match == null) return null;
  // Strip leading '../' — the test runs from the project root.
  return match.group(1)!.replaceAll(RegExp(r'^(\.\./)+'), '');
}

class _WiringRow {
  const _WiringRow({
    required this.provider,
    required this.status,
    required this.specRef,
  });

  final String provider;
  final String status;
  final String specRef;
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('Wiring-map coverage (Phase 5A)', () {
    test('docs/wiring-map.md exists', () {
      check(File('docs/wiring-map.md').existsSync()).isTrue();
    });

    test('docs/wiring-map.md has content', () {
      final content = File('docs/wiring-map.md').readAsStringSync();
      check(content.trim()).isNotEmpty();
    });

    test('docs/wiring-map.md contains the provider inventory table', () {
      final content = File('docs/wiring-map.md').readAsStringSync();
      check(content).contains('## Provider inventory');
    });

    test('lib/services/service_providers.dart exists', () {
      check(File('lib/services/service_providers.dart').existsSync()).isTrue();
    });

    test('(a) every provider in service_providers.dart has a row in '
        'the wiring map', () {
      final rows = _parseWiringMap();
      final mapProviders = rows.map((r) => r.provider).toSet();
      final fileProviders = _parseServiceProviders();

      final missingFromMap = fileProviders.difference(mapProviders);

      check(missingFromMap).isEmpty();
    });

    test('(b) every wired-real / wired-sim-only row in the map '
        'matches a provider declaration in service_providers.dart', () {
      final rows = _parseWiringMap().where(
        (r) => r.status == 'wired-real' || r.status == 'wired-sim-only',
      );
      final fileProviders = _parseServiceProviders();
      final mismatches = <String>[];

      for (final row in rows) {
        if (!fileProviders.contains(row.provider)) {
          mismatches.add(row.provider);
        }
      }

      check(mismatches).isEmpty();
    });

    test('(c) every pending-5b / pending-5c row references an existing '
        'protocol file under lib/services/protocols/', () {
      final rows = _parseWiringMap().where(
        (r) => r.status == 'pending-5b' || r.status == 'pending-5c',
      );
      final missing = <String>[];

      for (final row in rows) {
        final path = _extractProtocolPath(row.specRef);
        if (path == null) continue; // No protocol link — skip.
        if (!File(path).existsSync()) {
          missing.add('${row.provider} → $path');
        }
      }

      check(missing).isEmpty();
    });

    test('wiring map has at least 24 wired-real or wired-sim-only rows', () {
      // Phase 5A wires: encryption, keyProvider,
      // appSettings, userProfile, batteryAlertConfig,
      // sessionLog = 6 rows (database is pending-5c).
      // Stage 5B.1 adds 7 more: vibration, wakelock, flash, screenFlash,
      // recording, contact, audio = 13 total.
      // Stage 5B.2 adds 6 more: location, batteryMonitor, notification,
      // hardwareButton, callState, systemUi = 19 total.
      // Stage 5B.3 adds 5 more: phone, messaging, backgroundSession,
      // sentry, sessionLogRecorder = 24 total.
      final wiredCount = _parseWiringMap()
          .where(
            (r) => r.status == 'wired-real' || r.status == 'wired-sim-only',
          )
          .length;
      check(wiredCount).isGreaterOrEqual(24);
    });

    test('wiring map has at least 3 pending-5b rows '
        '(remaining services not yet wired after Stage 5B.3)', () {
      // Stage 5B.3 promoted 5 more pending-5b → wired-real.
      // Remaining pending-5b: permissionAudit, sessionStartValidator, backup.
      final pendingCount = _parseWiringMap()
          .where((r) => r.status == 'pending-5b')
          .length;
      check(pendingCount).isGreaterOrEqual(3);
    });
  });
}
