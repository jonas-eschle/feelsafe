/// Widget tests for [PastEventsDetailScreen].
///
/// Follows the reference pattern from
/// `test/features/home/home_screen_test.dart` with one adaptation:
/// the screen is a [ConsumerStatefulWidget] that reads
/// [sessionLogRepositoryProvider] directly (no separate Notifier).
/// Every test therefore overrides [databaseProvider] with an in-memory
/// [GuardianAngelaDatabase] that is pre-seeded with the required logs.
///
/// Share-action tests intercept the `dev.fluttercommunity.plus/share`
/// MethodChannel so no platform binary is invoked. The handler captures
/// the `text` argument from the params map and stores it in
/// [_capturedShareText] for assertion.
///
/// Spec ref: `docs/spec/04-screens-navigation.md §Session Log Detail`
/// (lines 2463–2550).
library;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:checks/checks.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/db/database.dart';
import 'package:guardianangela/domain/enums/end_reason.dart';
import 'package:guardianangela/domain/models/session_log.dart';
import 'package:guardianangela/domain/models/session_log_event.dart';
import 'package:guardianangela/features/past_events_detail/past_events_detail_screen.dart';
import 'package:guardianangela/services/service_providers.dart';
import '../../helpers/widget_test_helpers.dart';

// ---------------------------------------------------------------------------
// Share channel mock
// ---------------------------------------------------------------------------

/// The MethodChannel name used by share_plus.
const _kShareChannel = 'dev.fluttercommunity.plus/share';

/// Recorded text argument from the most recent `share` channel call.
String? _capturedShareText;

/// Recorded subject argument from the most recent `share` channel call.
String? _capturedShareSubject;

/// Installs a mock handler on [_kShareChannel] that captures [ShareParams]
/// `text` and `subject` fields without invoking any platform binary.
///
/// Call [_clearShareCapture] between tests (via [addTearDown]).
void _installShareMock() {
  _capturedShareText = null;
  _capturedShareSubject = null;
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(const MethodChannel(_kShareChannel), (
        MethodCall call,
      ) async {
        if (call.method == 'share') {
          final args = call.arguments as Map<Object?, Object?>;
          _capturedShareText = args['text'] as String?;
          _capturedShareSubject = args['subject'] as String?;
        }
        // Return the "unavailable" sentinel so ShareResult decodes cleanly.
        return 'dev.fluttercommunity.plus/share/unavailable';
      });
}

/// Removes the share mock handler, restoring default behaviour.
void _removeShareMock() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(const MethodChannel(_kShareChannel), null);
}

// ---------------------------------------------------------------------------
// Printing channel mock (Share as PDF)
// ---------------------------------------------------------------------------

/// The MethodChannel name used by the `printing` plugin.
const _kPrintingChannel = 'net.nfet.printing';

/// PDF bytes captured from the most recent `sharePdf` channel call.
List<int>? _capturedPdfBytes;

/// Filename captured from the most recent `sharePdf` channel call.
String? _capturedPdfName;

/// Installs a mock handler on [_kPrintingChannel] that captures the
/// `sharePdf` document bytes and filename without invoking any platform
/// binary. The PDF itself is built in pure Dart by `package:pdf`, so the
/// captured bytes are the REAL document produced by the screen.
void _installPrintingMock() {
  _capturedPdfBytes = null;
  _capturedPdfName = null;
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(const MethodChannel(_kPrintingChannel), (
        MethodCall call,
      ) async {
        if (call.method == 'sharePdf') {
          final args = call.arguments as Map<Object?, Object?>;
          _capturedPdfBytes = args['doc'] as List<int>?;
          _capturedPdfName = args['name'] as String?;
          return 1;
        }
        return 0;
      });
}

/// Removes the printing mock handler, restoring default behaviour.
void _removePrintingMock() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(const MethodChannel(_kPrintingChannel), null);
}

// ---------------------------------------------------------------------------
// Database helpers
// ---------------------------------------------------------------------------

/// Opens an empty in-memory [GuardianAngelaDatabase] (no seed data).
GuardianAngelaDatabase _openDb() =>
    GuardianAngelaDatabase.memory(seedCallback: (_) async {});

/// Returns an [Override] that wires [databaseProvider] to [db].
Override _dbOverride(GuardianAngelaDatabase db) =>
    databaseProvider.overrideWith((_) async => db);

// ---------------------------------------------------------------------------
// Data factories
// ---------------------------------------------------------------------------

/// Fixed UTC base timestamp — 2026-04-02 21:45:20.
final _base = DateTime.utc(2026, 4, 2, 21, 45, 20);

SessionLogEvent _event({
  String eventType = 'started',
  String description = 'Session started',
  int stepIndex = 0,
  String? stepType,
  double? latitude,
  double? longitude,
  String? deliveryStatus,
  DateTime? timestamp,
}) => SessionLogEvent(
  timestamp: timestamp ?? _base,
  eventType: eventType,
  stepType: stepType,
  stepIndex: stepIndex,
  description: description,
  latitude: latitude,
  longitude: longitude,
  deliveryStatus: deliveryStatus,
);

SessionLog _log({
  String id = 'log-1',
  String modeId = 'mode-1',
  String modeName = 'Walk Mode',
  bool isSimulation = false,
  List<SessionLogEvent>? events,
  DateTime? endedAt,
  EndReason endReason = EndReason.disarm,
  DateTime? deletedAt,
}) => SessionLog(
  id: id,
  modeId: modeId,
  modeName: modeName,
  startedAt: _base,
  endedAt: endedAt ?? _base.add(const Duration(minutes: 5, seconds: 23)),
  endReason: endReason,
  isSimulation: isSimulation,
  events:
      events ??
      <SessionLogEvent>[
        _event(),
        _event(
          eventType: 'step_fired',
          description: 'Hold button active',
          stepType: 'holdButton',
          timestamp: _base.add(const Duration(seconds: 5)),
        ),
      ],
  deletedAt: deletedAt,
);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // ── AppBar ─────────────────────────────────────────────────────────────────

  group('PastEventsDetailScreen — AppBar', () {
    testWidgets('renders "Session log" title in app bar', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final db = _openDb();
      addTearDown(db.close);
      await db.sessionLogsDao.upsert(_log());
      await pumpScreen(
        tester,
        const PastEventsDetailScreen(logId: 'log-1'),
        overrides: <Override>[_dbOverride(db)],
      );
      expect(find.text(l10n.pastEventsDetailTitle), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('app bar shows the Share icon button', (
      WidgetTester tester,
    ) async {
      final db = _openDb();
      addTearDown(db.close);
      await db.sessionLogsDao.upsert(_log());
      await pumpScreen(
        tester,
        const PastEventsDetailScreen(logId: 'log-1'),
        overrides: <Override>[_dbOverride(db)],
      );
      expect(find.byIcon(Icons.share), findsOneWidget);
    });

    testWidgets('Share button tooltip matches l10n pastEventsDetailShare', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final db = _openDb();
      addTearDown(db.close);
      await db.sessionLogsDao.upsert(_log());
      await pumpScreen(
        tester,
        const PastEventsDetailScreen(logId: 'log-1'),
        overrides: <Override>[_dbOverride(db)],
      );
      expect(find.byTooltip(l10n.pastEventsDetailShare), findsOneWidget);
    });

    testWidgets('Share icon onPressed is null while log is still loading', (
      WidgetTester tester,
    ) async {
      final db = _openDb();
      addTearDown(db.close);
      await db.sessionLogsDao.upsert(_log());
      // settle: false keeps the screen in the loading state.
      await pumpScreen(
        tester,
        const PastEventsDetailScreen(logId: 'log-1'),
        overrides: <Override>[_dbOverride(db)],
        settle: false,
      );
      final btn = tester.widget<IconButton>(
        find.ancestor(
          of: find.byIcon(Icons.share),
          matching: find.byType(IconButton),
        ),
      );
      check(btn.onPressed).isNull();
    });
  });

  // ── Loading / spinner state ────────────────────────────────────────────────

  group('PastEventsDetailScreen — loading state', () {
    testWidgets('shows CircularProgressIndicator while fetching', (
      WidgetTester tester,
    ) async {
      final db = _openDb();
      addTearDown(db.close);
      await db.sessionLogsDao.upsert(_log());
      await pumpScreen(
        tester,
        const PastEventsDetailScreen(logId: 'log-1'),
        overrides: <Override>[_dbOverride(db)],
        settle: false,
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('no spinner once log resolves', (WidgetTester tester) async {
      final db = _openDb();
      addTearDown(db.close);
      await db.sessionLogsDao.upsert(_log());
      await pumpScreen(
        tester,
        const PastEventsDetailScreen(logId: 'log-1'),
        overrides: <Override>[_dbOverride(db)],
      );
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });

  // ── Not-found / error state ────────────────────────────────────────────────

  group('PastEventsDetailScreen — not-found state', () {
    testWidgets('shows empty-state banner when id is not in database', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      // Empty database — getById returns null.
      final db = _openDb();
      addTearDown(db.close);
      await pumpScreen(
        tester,
        const PastEventsDetailScreen(logId: 'does-not-exist'),
        overrides: <Override>[_dbOverride(db)],
      );
      expect(find.text(l10n.pastEventsEmpty), findsOneWidget);
    });

    testWidgets('body contains no ListTile when id is not found', (
      WidgetTester tester,
    ) async {
      final db = _openDb();
      addTearDown(db.close);
      await pumpScreen(
        tester,
        const PastEventsDetailScreen(logId: 'missing'),
        overrides: <Override>[_dbOverride(db)],
      );
      expect(find.byType(ListTile), findsNothing);
    });
  });

  // ── Header section ─────────────────────────────────────────────────────────

  group('PastEventsDetailScreen — header section', () {
    testWidgets('renders mode name as prominent text', (
      WidgetTester tester,
    ) async {
      final db = _openDb();
      addTearDown(db.close);
      await db.sessionLogsDao.upsert(_log(modeName: 'Night Walk'));
      await pumpScreen(
        tester,
        const PastEventsDetailScreen(logId: 'log-1'),
        overrides: <Override>[_dbOverride(db)],
      );
      expect(find.text('Night Walk'), findsOneWidget);
    });

    testWidgets('renders SIM Chip for simulated sessions', (
      WidgetTester tester,
    ) async {
      final db = _openDb();
      addTearDown(db.close);
      await db.sessionLogsDao.upsert(_log(isSimulation: true));
      await pumpScreen(
        tester,
        const PastEventsDetailScreen(logId: 'log-1'),
        overrides: <Override>[_dbOverride(db)],
      );
      expect(find.text('SIM'), findsOneWidget);
    });

    testWidgets('does not render SIM Chip for real sessions', (
      WidgetTester tester,
    ) async {
      final db = _openDb();
      addTearDown(db.close);
      await db.sessionLogsDao.upsert(_log());
      await pumpScreen(
        tester,
        const PastEventsDetailScreen(logId: 'log-1'),
        overrides: <Override>[_dbOverride(db)],
      );
      expect(find.text('SIM'), findsNothing);
    });

    testWidgets('renders "Start:" label in body', (WidgetTester tester) async {
      final db = _openDb();
      addTearDown(db.close);
      await db.sessionLogsDao.upsert(_log());
      await pumpScreen(
        tester,
        const PastEventsDetailScreen(logId: 'log-1'),
        overrides: <Override>[_dbOverride(db)],
      );
      expect(find.textContaining('Start:'), findsOneWidget);
    });

    testWidgets('renders "End:" label when endedAt is set', (
      WidgetTester tester,
    ) async {
      final db = _openDb();
      addTearDown(db.close);
      await db.sessionLogsDao.upsert(_log());
      await pumpScreen(
        tester,
        const PastEventsDetailScreen(logId: 'log-1'),
        overrides: <Override>[_dbOverride(db)],
      );
      expect(find.textContaining('End:'), findsOneWidget);
    });

    testWidgets('Divider separates header from event timeline', (
      WidgetTester tester,
    ) async {
      final db = _openDb();
      addTearDown(db.close);
      await db.sessionLogsDao.upsert(_log());
      await pumpScreen(
        tester,
        const PastEventsDetailScreen(logId: 'log-1'),
        overrides: <Override>[_dbOverride(db)],
      );
      expect(find.byType(Divider), findsOneWidget);
    });
  });

  // ── Event timeline ─────────────────────────────────────────────────────────

  group('PastEventsDetailScreen — event timeline', () {
    testWidgets('renders one ListTile per event in the log', (
      WidgetTester tester,
    ) async {
      final events = <SessionLogEvent>[
        _event(),
        _event(
          eventType: 'step_fired',
          description: 'Hold button',
          timestamp: _base.add(const Duration(seconds: 5)),
        ),
        _event(
          eventType: 'completed',
          description: 'User confirmed safe',
          timestamp: _base.add(const Duration(minutes: 5)),
        ),
      ];
      final db = _openDb();
      addTearDown(db.close);
      await db.sessionLogsDao.upsert(_log(events: events));
      await pumpScreen(
        tester,
        const PastEventsDetailScreen(logId: 'log-1'),
        overrides: <Override>[_dbOverride(db)],
      );
      expect(find.byType(ListTile), findsNWidgets(events.length));
    });

    testWidgets('each event tile subtitle shows the eventType string', (
      WidgetTester tester,
    ) async {
      final events = <SessionLogEvent>[
        _event(description: 'Start'),
        _event(
          eventType: 'escalated',
          description: 'Contacts notified',
          timestamp: _base.add(const Duration(seconds: 10)),
        ),
      ];
      final db = _openDb();
      addTearDown(db.close);
      await db.sessionLogsDao.upsert(_log(events: events));
      await pumpScreen(
        tester,
        const PastEventsDetailScreen(logId: 'log-1'),
        overrides: <Override>[_dbOverride(db)],
      );
      expect(find.text('started'), findsOneWidget);
      expect(find.text('escalated'), findsOneWidget);
    });

    testWidgets('no ListTile rendered when events list is empty', (
      WidgetTester tester,
    ) async {
      final db = _openDb();
      addTearDown(db.close);
      await db.sessionLogsDao.upsert(_log(events: <SessionLogEvent>[]));
      await pumpScreen(
        tester,
        const PastEventsDetailScreen(logId: 'log-1'),
        overrides: <Override>[_dbOverride(db)],
      );
      expect(find.byType(ListTile), findsNothing);
    });

    testWidgets('event tiles use event_note icon as leading', (
      WidgetTester tester,
    ) async {
      final db = _openDb();
      addTearDown(db.close);
      await db.sessionLogsDao.upsert(
        _log(events: <SessionLogEvent>[_event(description: 'Start')]),
      );
      await pumpScreen(
        tester,
        const PastEventsDetailScreen(logId: 'log-1'),
        overrides: <Override>[_dbOverride(db)],
      );
      expect(find.byIcon(Icons.event_note), findsOneWidget);
    });
  });

  // ── Share action ───────────────────────────────────────────────────────────

  group('PastEventsDetailScreen — Share action', () {
    setUp(_installShareMock);
    tearDown(_removeShareMock);

    testWidgets('tapping Share fires share_plus with mode name in text', (
      WidgetTester tester,
    ) async {
      final db = _openDb();
      addTearDown(db.close);
      await db.sessionLogsDao.upsert(_log());
      await pumpScreen(
        tester,
        const PastEventsDetailScreen(logId: 'log-1'),
        overrides: <Override>[_dbOverride(db)],
      );
      final l10n = await loadL10n(const Locale('en'));
      await tester.tap(find.byIcon(Icons.share));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.pastEventsDetailShareText));
      await tester.pumpAndSettle();
      check(_capturedShareText).isNotNull();
      check(_capturedShareText!).contains('Walk Mode');
    });

    testWidgets('Share subject is "Guardian Angela session log"', (
      WidgetTester tester,
    ) async {
      final db = _openDb();
      addTearDown(db.close);
      await db.sessionLogsDao.upsert(_log());
      await pumpScreen(
        tester,
        const PastEventsDetailScreen(logId: 'log-1'),
        overrides: <Override>[_dbOverride(db)],
      );
      final l10n = await loadL10n(const Locale('en'));
      await tester.tap(find.byIcon(Icons.share));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.pastEventsDetailShareText));
      await tester.pumpAndSettle();
      check(_capturedShareSubject).equals('Guardian Angela session log');
    });

    testWidgets('normal mode share text contains "Start:" line', (
      WidgetTester tester,
    ) async {
      final db = _openDb();
      addTearDown(db.close);
      await db.sessionLogsDao.upsert(_log());
      await pumpScreen(
        tester,
        const PastEventsDetailScreen(logId: 'log-1'),
        overrides: <Override>[_dbOverride(db)],
      );
      final l10n = await loadL10n(const Locale('en'));
      await tester.tap(find.byIcon(Icons.share));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.pastEventsDetailShareText));
      await tester.pumpAndSettle();
      check(_capturedShareText ?? '').contains('Start:');
    });

    testWidgets('evidence mode sends JSON containing log id', (
      WidgetTester tester,
    ) async {
      final db = _openDb();
      addTearDown(db.close);
      await db.sessionLogsDao.upsert(_log(id: 'ev-1'));
      await pumpScreen(
        tester,
        const PastEventsDetailScreen(logId: 'ev-1', evidenceMode: true),
        overrides: <Override>[_dbOverride(db)],
      );
      final l10n = await loadL10n(const Locale('en'));
      await tester.tap(find.byIcon(Icons.share));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.pastEventsDetailShareText));
      await tester.pumpAndSettle();
      check(_capturedShareText).isNotNull();
      check(_capturedShareText!).contains('"id"');
      check(_capturedShareText!).contains('ev-1');
    });

    testWidgets('evidence mode JSON contains modeName field value', (
      WidgetTester tester,
    ) async {
      final db = _openDb();
      addTearDown(db.close);
      await db.sessionLogsDao.upsert(_log(id: 'ev-2', modeName: 'Date Mode'));
      await pumpScreen(
        tester,
        const PastEventsDetailScreen(logId: 'ev-2', evidenceMode: true),
        overrides: <Override>[_dbOverride(db)],
      );
      final l10n = await loadL10n(const Locale('en'));
      await tester.tap(find.byIcon(Icons.share));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.pastEventsDetailShareText));
      await tester.pumpAndSettle();
      check(_capturedShareText ?? '').contains('Date Mode');
    });

    testWidgets('evidence-mode export is VALID JSON that round-trips a '
        'modeName containing quotes, backslashes and newlines', (
      WidgetTester tester,
    ) async {
      // A user-editable mode name with every JSON-hostile character class.
      const trickyName = 'has "quotes", a back\\slash and\nnewlines';
      final db = _openDb();
      addTearDown(db.close);
      await db.sessionLogsDao.upsert(
        _log(id: 'ev-tricky', modeName: trickyName),
      );
      await pumpScreen(
        tester,
        const PastEventsDetailScreen(logId: 'ev-tricky', evidenceMode: true),
        overrides: <Override>[_dbOverride(db)],
      );
      final l10n = await loadL10n(const Locale('en'));
      await tester.tap(find.byIcon(Icons.share));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.pastEventsDetailShareText));
      await tester.pumpAndSettle();
      check(_capturedShareText).isNotNull();
      // The police-report evidence bundle MUST parse as JSON…
      final decoded = jsonDecode(_capturedShareText!) as Map<String, dynamic>;
      // …and round-trip the exact string, unmangled.
      check(decoded['modeName']).equals(trickyName);
      check(decoded['id']).equals('ev-tricky');
      check(decoded['startedAt']).equals(_base.toIso8601String());
      final events = decoded['events'] as List<dynamic>;
      check(events.length).equals(2);
      final first = events.first as Map<String, dynamic>;
      check(first['type']).equals('started');
      check(first['timestamp']).equals(_base.toIso8601String());
    });

    testWidgets('evidence mode JSON contains startedAt key', (
      WidgetTester tester,
    ) async {
      final db = _openDb();
      addTearDown(db.close);
      await db.sessionLogsDao.upsert(_log(id: 'ev-3'));
      await pumpScreen(
        tester,
        const PastEventsDetailScreen(logId: 'ev-3', evidenceMode: true),
        overrides: <Override>[_dbOverride(db)],
      );
      final l10n = await loadL10n(const Locale('en'));
      await tester.tap(find.byIcon(Icons.share));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.pastEventsDetailShareText));
      await tester.pumpAndSettle();
      check(_capturedShareText ?? '').contains('"startedAt"');
    });
  });

  // ── RTL smoke ──────────────────────────────────────────────────────────────

  group('PastEventsDetailScreen — RTL', () {
    testWidgets('renders in Arabic (RTL) without overflow', (
      WidgetTester tester,
    ) async {
      final db = _openDb();
      addTearDown(db.close);
      await db.sessionLogsDao.upsert(_log());
      await pumpScreen(
        tester,
        const PastEventsDetailScreen(logId: 'log-1'),
        overrides: <Override>[_dbOverride(db)],
        locale: const Locale('ar'),
      );
      expect(find.byType(AppBar), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('RTL not-found state renders without exception', (
      WidgetTester tester,
    ) async {
      final db = _openDb();
      addTearDown(db.close);
      await pumpScreen(
        tester,
        const PastEventsDetailScreen(logId: 'missing'),
        overrides: <Override>[_dbOverride(db)],
        locale: const Locale('ar'),
      );
      expect(tester.takeException(), isNull);
    });
  });

  // ── Dark mode smoke ────────────────────────────────────────────────────────

  group('PastEventsDetailScreen — dark mode', () {
    testWidgets('renders without exception in dark mode with log', (
      WidgetTester tester,
    ) async {
      final db = _openDb();
      addTearDown(db.close);
      await db.sessionLogsDao.upsert(_log());
      await pumpScreen(
        tester,
        const PastEventsDetailScreen(logId: 'log-1'),
        overrides: <Override>[_dbOverride(db)],
        themeMode: ThemeMode.dark,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('dark mode not-found state renders without exception', (
      WidgetTester tester,
    ) async {
      final db = _openDb();
      addTearDown(db.close);
      await pumpScreen(
        tester,
        const PastEventsDetailScreen(logId: 'missing'),
        overrides: <Override>[_dbOverride(db)],
        themeMode: ThemeMode.dark,
      );
      expect(tester.takeException(), isNull);
    });
  });

  // ── Accessibility ──────────────────────────────────────────────────────────

  group('PastEventsDetailScreen — accessibility', () {
    testWidgets('Share icon button exposes tooltip for screen readers', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final db = _openDb();
      addTearDown(db.close);
      await db.sessionLogsDao.upsert(_log());
      await pumpScreen(
        tester,
        const PastEventsDetailScreen(logId: 'log-1'),
        overrides: <Override>[_dbOverride(db)],
      );
      expect(find.byTooltip(l10n.pastEventsDetailShare), findsOneWidget);
    });

    testWidgets('mode name is visible text node for a11y tree', (
      WidgetTester tester,
    ) async {
      final db = _openDb();
      addTearDown(db.close);
      await db.sessionLogsDao.upsert(_log(modeName: 'A11y Walk'));
      await pumpScreen(
        tester,
        const PastEventsDetailScreen(logId: 'log-1'),
        overrides: <Override>[_dbOverride(db)],
      );
      expect(find.text('A11y Walk'), findsOneWidget);
    });
  });

  // ── Share as PDF ───────────────────────────────────────────────────────────

  group('PastEventsDetailScreen — Share PDF action', () {
    setUp(_installPrintingMock);
    tearDown(_removePrintingMock);

    testWidgets('PDF menu item builds a non-empty PDF and shares it under the '
        'log-id filename', (WidgetTester tester) async {
      final db = _openDb();
      addTearDown(db.close);
      await db.sessionLogsDao.upsert(_log());
      await pumpScreen(
        tester,
        const PastEventsDetailScreen(logId: 'log-1'),
        overrides: <Override>[_dbOverride(db)],
      );
      final l10n = await loadL10n(const Locale('en'));
      await tester.tap(find.byIcon(Icons.share));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.pastEventsDetailSharePdf));
      await tester.pumpAndSettle();
      check(_capturedPdfName).equals('guardian_angela_log-1.pdf');
      check(_capturedPdfBytes).isNotNull();
      check(_capturedPdfBytes!).isNotEmpty();
      // A real PDF document starts with the %PDF magic header.
      check(String.fromCharCodes(_capturedPdfBytes!.take(5))).equals('%PDF-');
    });

    testWidgets('PDF export works for an in-progress log (endedAt null)', (
      WidgetTester tester,
    ) async {
      final db = _openDb();
      addTearDown(db.close);
      // endReason must be null when endedAt is null (model invariant).
      await db.sessionLogsDao.upsert(
        SessionLog(
          id: 'log-open',
          modeId: 'mode-1',
          modeName: 'Walk Mode',
          startedAt: _base,
          isSimulation: false,
          events: <SessionLogEvent>[_event()],
        ),
      );
      await pumpScreen(
        tester,
        const PastEventsDetailScreen(logId: 'log-open'),
        overrides: <Override>[_dbOverride(db)],
      );
      final l10n = await loadL10n(const Locale('en'));
      await tester.tap(find.byIcon(Icons.share));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.pastEventsDetailSharePdf));
      await tester.pumpAndSettle();
      check(_capturedPdfName).equals('guardian_angela_log-open.pdf');
      check(_capturedPdfBytes).isNotNull();
    });
  });

  // ── Delete action ──────────────────────────────────────────────────────────

  group('PastEventsDetailScreen — Delete action', () {
    testWidgets('Delete icon opens the confirmation dialog', (
      WidgetTester tester,
    ) async {
      final db = _openDb();
      addTearDown(db.close);
      await db.sessionLogsDao.upsert(_log());
      await pumpScreen(
        tester,
        const PastEventsDetailScreen(logId: 'log-1'),
        overrides: <Override>[_dbOverride(db)],
      );
      final l10n = await loadL10n(const Locale('en'));
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text(l10n.pastEventsDeleteConfirm), findsOneWidget);
    });

    testWidgets('cancelling keeps the log live (not trashed)', (
      WidgetTester tester,
    ) async {
      final db = _openDb();
      addTearDown(db.close);
      await db.sessionLogsDao.upsert(_log());
      await pumpScreen(
        tester,
        const PastEventsDetailScreen(logId: 'log-1'),
        overrides: <Override>[_dbOverride(db)],
      );
      final l10n = await loadL10n(const Locale('en'));
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.commonCancel));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      // Screen stays put and the row is untouched.
      expect(find.byType(PastEventsDetailScreen), findsOneWidget);
      check(await db.sessionLogsDao.getTrashed()).isEmpty();
    });

    testWidgets(
      'confirming soft-deletes the log (restorable trash row) and pops '
      'back to the previous screen',
      (WidgetTester tester) async {
        final db = _openDb();
        addTearDown(db.close);
        await db.sessionLogsDao.upsert(_log());
        // Mount via a pushed route so the screen has somewhere to pop to.
        await pumpScreen(
          tester,
          Builder(
            builder: (BuildContext context) => Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          const PastEventsDetailScreen(logId: 'log-1'),
                    ),
                  ),
                  child: const Text('open detail'),
                ),
              ),
            ),
          ),
          overrides: <Override>[_dbOverride(db)],
        );
        await tester.tap(find.text('open detail'));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(Icons.delete_outline));
        await tester.pumpAndSettle();
        // Confirm with the dialog's FilledButton ("Delete").
        await tester.tap(
          find.descendant(
            of: find.byType(AlertDialog),
            matching: find.byType(FilledButton),
          ),
        );
        await tester.pumpAndSettle();
        // Detail screen popped back to the host scaffold.
        expect(find.byType(PastEventsDetailScreen), findsNothing);
        expect(find.text('open detail'), findsOneWidget);
        // SOFT delete: row still exists, now in the trash (restorable).
        final trashed = await db.sessionLogsDao.getTrashed();
        check(trashed.map((l) => l.id)).deepEquals(<String>['log-1']);
        check(await db.sessionLogsDao.getById('log-1')).isNotNull();
      },
    );
  });
}
