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
      await tester.tap(find.byIcon(Icons.share));
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
      await tester.tap(find.byIcon(Icons.share));
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
      await tester.tap(find.byIcon(Icons.share));
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
      await tester.tap(find.byIcon(Icons.share));
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
      await tester.tap(find.byIcon(Icons.share));
      await tester.pumpAndSettle();
      check(_capturedShareText ?? '').contains('Date Mode');
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
      await tester.tap(find.byIcon(Icons.share));
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
}
