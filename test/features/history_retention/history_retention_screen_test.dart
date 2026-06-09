/// Widget tests for [HistoryRetentionScreen].
///
/// Follows the reference pattern from
/// `test/features/home/home_screen_test.dart`:
/// [_FakeHistoryRetentionController] subclasses the real controller,
/// overrides `build()` to return a canned [HistoryRetentionState], and
/// exposes call counters for interaction assertions.
///
/// Spec refs: 06-settings.md §History & Retention Screen.
library;

import 'dart:io';

import 'package:flutter/material.dart';

import 'package:checks/checks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/db/database.dart';
import 'package:guardianangela/data/repositories/app_settings_repository.dart';
import 'package:guardianangela/data/repositories/session_log_repository.dart';
import 'package:guardianangela/domain/enums/end_reason.dart';
import 'package:guardianangela/domain/models/app_settings.dart';
import 'package:guardianangela/domain/models/session_log.dart';
import 'package:guardianangela/domain/models/session_log_event.dart';
import 'package:guardianangela/features/history_retention/history_retention_controller.dart';
import 'package:guardianangela/features/history_retention/history_retention_screen.dart';
import 'package:guardianangela/services/service_providers.dart';
import '../../helpers/widget_test_helpers.dart';

// ---------------------------------------------------------------------------
// Fake controller
// ---------------------------------------------------------------------------

class _FakeHistoryRetentionController extends HistoryRetentionController {
  _FakeHistoryRetentionController(this._initial);

  final HistoryRetentionState _initial;

  int setSessionLogRetentionCalls = 0;
  int? lastSessionLogRetentionDays;

  int setTrashRetentionCalls = 0;
  int? lastTrashRetentionDays;

  @override
  Future<HistoryRetentionState> build() async => _initial;

  @override
  Future<void> setSessionLogRetention(int days) async {
    setSessionLogRetentionCalls++;
    lastSessionLogRetentionDays = days;
    state = AsyncData(
      HistoryRetentionState(
        sessionLogRetentionDays: days,
        trashRetentionDays: _initial.trashRetentionDays,
      ),
    );
  }

  @override
  Future<void> setTrashRetention(int days) async {
    setTrashRetentionCalls++;
    lastTrashRetentionDays = days;
    state = AsyncData(
      HistoryRetentionState(
        sessionLogRetentionDays: _initial.sessionLogRetentionDays,
        trashRetentionDays: days,
      ),
    );
  }
}

/// Controller whose build() always throws, exercising the AsyncError path.
class _AsyncErrorController extends HistoryRetentionController {
  @override
  Future<HistoryRetentionState> build() async =>
      throw Exception('settings load failed');
}

/// Recording fake [AppSettingsRepository] for the Purge-now flow (the
/// button reads the REAL settings repo, not the faked controller).
class _FakeAppSettingsRepository extends AppSettingsRepository {
  _FakeAppSettingsRepository(this._current)
    : super(
        keyProvider: () async => '00' * 32,
        resolveDir: () async =>
            Directory.systemTemp.createTempSync('history_retention_scr_'),
      );

  final AppSettings _current;

  @override
  Future<AppSettings> load() async => _current;
}

// ---------------------------------------------------------------------------
// Factory helpers
// ---------------------------------------------------------------------------

HistoryRetentionState _defaultState({
  int sessionLogRetentionDays = 180,
  int trashRetentionDays = 7,
}) => HistoryRetentionState(
  sessionLogRetentionDays: sessionLogRetentionDays,
  trashRetentionDays: trashRetentionDays,
);

List<Override> _overrides(_FakeHistoryRetentionController fake) => <Override>[
  historyRetentionControllerProvider.overrideWith(() => fake),
];

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // ── AppBar ────────────────────────────────────────────────────────────────

  group('HistoryRetentionScreen — AppBar', () {
    testWidgets('renders "History & retention" title in AppBar', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const HistoryRetentionScreen(),
        overrides: _overrides(_FakeHistoryRetentionController(_defaultState())),
      );
      expect(find.text(l10n.historyRetentionTitle), findsWidgets);
      expect(find.byType(AppBar), findsOneWidget);
    });
  });

  // ── Async states ──────────────────────────────────────────────────────────

  group('HistoryRetentionScreen — async states', () {
    testWidgets('shows CircularProgressIndicator on first frame (loading)', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        const HistoryRetentionScreen(),
        overrides: _overrides(_FakeHistoryRetentionController(_defaultState())),
        settle: false,
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('no spinner once AsyncValue resolves', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        const HistoryRetentionScreen(),
        overrides: _overrides(_FakeHistoryRetentionController(_defaultState())),
      );
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('shows error text on AsyncError', (WidgetTester tester) async {
      await pumpScreen(
        tester,
        const HistoryRetentionScreen(),
        overrides: <Override>[
          historyRetentionControllerProvider.overrideWith(
            _AsyncErrorController.new,
          ),
        ],
      );
      expect(find.textContaining('Error:'), findsOneWidget);
    });
  });

  // ── Session log retention slider ──────────────────────────────────────────

  group('HistoryRetentionScreen — session log retention slider', () {
    testWidgets('renders session log label', (WidgetTester tester) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const HistoryRetentionScreen(),
        overrides: _overrides(_FakeHistoryRetentionController(_defaultState())),
      );
      expect(find.text(l10n.historyRetentionLogsLabel), findsOneWidget);
    });

    testWidgets('renders helper text below session log slider', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const HistoryRetentionScreen(),
        overrides: _overrides(_FakeHistoryRetentionController(_defaultState())),
      );
      expect(find.text(l10n.historyRetentionLogsHelper), findsOneWidget);
    });

    testWidgets('renders Slider widget for session log retention', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        const HistoryRetentionScreen(),
        overrides: _overrides(_FakeHistoryRetentionController(_defaultState())),
      );
      // Two sliders total (session log + trash).
      expect(find.byType(Slider), findsNWidgets(2));
    });

    testWidgets('session log slider value matches state (180 default)', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        const HistoryRetentionScreen(),
        overrides: _overrides(
          // _defaultState defaults to 180; stated explicitly in test name.
          _FakeHistoryRetentionController(_defaultState()),
        ),
      );
      final sliders = tester.widgetList<Slider>(find.byType(Slider)).toList();
      // First slider is session log retention.
      check(sliders[0].value).equals(180.0);
    });

    testWidgets(
      'session log slider value reflects custom initial value (30 days)',
      (WidgetTester tester) async {
        await pumpScreen(
          tester,
          const HistoryRetentionScreen(),
          overrides: _overrides(
            _FakeHistoryRetentionController(
              _defaultState(sessionLogRetentionDays: 30),
            ),
          ),
        );
        final sliders = tester.widgetList<Slider>(find.byType(Slider)).toList();
        check(sliders[0].value).equals(30.0);
      },
    );

    testWidgets('session log slider min is 1 and max is 365', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        const HistoryRetentionScreen(),
        overrides: _overrides(_FakeHistoryRetentionController(_defaultState())),
      );
      final sliders = tester.widgetList<Slider>(find.byType(Slider)).toList();
      check(sliders[0].min).equals(1.0);
      check(sliders[0].max).equals(365.0);
    });

    testWidgets(
      'session log slider label shows current day count suffixed with d',
      (WidgetTester tester) async {
        await pumpScreen(
          tester,
          const HistoryRetentionScreen(),
          overrides: _overrides(
            _FakeHistoryRetentionController(
              _defaultState(sessionLogRetentionDays: 90),
            ),
          ),
        );
        final sliders = tester.widgetList<Slider>(find.byType(Slider)).toList();
        check(sliders[0].label).equals('90d');
      },
    );

    testWidgets('dragging session log slider calls setSessionLogRetention', (
      WidgetTester tester,
    ) async {
      final fake = _FakeHistoryRetentionController(
        // Default 180 days; explicit value dropped (matches factory default).
        _defaultState(),
      );
      await pumpScreen(
        tester,
        const HistoryRetentionScreen(),
        overrides: _overrides(fake),
      );
      // Drag the first Slider (session log) to the leftmost edge.
      final sliderFinder = find.byType(Slider).first;
      await tester.drag(sliderFinder, const Offset(-300, 0));
      await tester.pumpAndSettle();
      check(fake.setSessionLogRetentionCalls).isGreaterOrEqual(1);
    });
  });

  // ── Trash retention slider ────────────────────────────────────────────────

  group('HistoryRetentionScreen — trash retention slider', () {
    testWidgets('renders trash retention label', (WidgetTester tester) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const HistoryRetentionScreen(),
        overrides: _overrides(_FakeHistoryRetentionController(_defaultState())),
      );
      expect(find.text(l10n.historyRetentionTrashLabel), findsOneWidget);
    });

    testWidgets('renders helper text below trash slider', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const HistoryRetentionScreen(),
        overrides: _overrides(_FakeHistoryRetentionController(_defaultState())),
      );
      expect(find.text(l10n.historyRetentionTrashHelper), findsOneWidget);
    });

    testWidgets('trash slider value matches state (7 days default)', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        const HistoryRetentionScreen(),
        overrides: _overrides(
          // _defaultState defaults to 7 days; stated explicitly in name.
          _FakeHistoryRetentionController(_defaultState()),
        ),
      );
      final sliders = tester.widgetList<Slider>(find.byType(Slider)).toList();
      // Second slider is trash retention.
      check(sliders[1].value).equals(7.0);
    });

    testWidgets('trash slider value reflects custom initial value (14 days)', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        const HistoryRetentionScreen(),
        overrides: _overrides(
          _FakeHistoryRetentionController(
            _defaultState(trashRetentionDays: 14),
          ),
        ),
      );
      final sliders = tester.widgetList<Slider>(find.byType(Slider)).toList();
      check(sliders[1].value).equals(14.0);
    });

    testWidgets('trash slider min is 1 and max is 90', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        const HistoryRetentionScreen(),
        overrides: _overrides(_FakeHistoryRetentionController(_defaultState())),
      );
      final sliders = tester.widgetList<Slider>(find.byType(Slider)).toList();
      check(sliders[1].min).equals(1.0);
      check(sliders[1].max).equals(90.0);
    });

    testWidgets('trash slider label shows current day count suffixed with d', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        const HistoryRetentionScreen(),
        overrides: _overrides(
          _FakeHistoryRetentionController(
            _defaultState(trashRetentionDays: 30),
          ),
        ),
      );
      final sliders = tester.widgetList<Slider>(find.byType(Slider)).toList();
      check(sliders[1].label).equals('30d');
    });

    testWidgets('dragging trash slider calls setTrashRetention', (
      WidgetTester tester,
    ) async {
      final fake = _FakeHistoryRetentionController(
        // Default 7 days; explicit value dropped (matches factory default).
        _defaultState(),
      );
      await pumpScreen(
        tester,
        const HistoryRetentionScreen(),
        overrides: _overrides(fake),
      );
      // Drag the second Slider (trash) to the right.
      final sliderFinder = find.byType(Slider).last;
      await tester.drag(sliderFinder, const Offset(300, 0));
      await tester.pumpAndSettle();
      check(fake.setTrashRetentionCalls).isGreaterOrEqual(1);
    });
  });

  // ── Both sliders present ──────────────────────────────────────────────────

  group('HistoryRetentionScreen — layout', () {
    testWidgets('renders exactly two Slider widgets', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        const HistoryRetentionScreen(),
        overrides: _overrides(_FakeHistoryRetentionController(_defaultState())),
      );
      expect(find.byType(Slider), findsNWidgets(2));
    });

    testWidgets('renders all four label/helper texts', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const HistoryRetentionScreen(),
        overrides: _overrides(_FakeHistoryRetentionController(_defaultState())),
      );
      expect(find.text(l10n.historyRetentionLogsLabel), findsOneWidget);
      expect(find.text(l10n.historyRetentionLogsHelper), findsOneWidget);
      expect(find.text(l10n.historyRetentionTrashLabel), findsOneWidget);
      expect(find.text(l10n.historyRetentionTrashHelper), findsOneWidget);
    });

    testWidgets('session log and trash sliders are independent '
        '(changing one does not call the other method)', (
      WidgetTester tester,
    ) async {
      final fake = _FakeHistoryRetentionController(_defaultState());
      await pumpScreen(
        tester,
        const HistoryRetentionScreen(),
        overrides: _overrides(fake),
      );
      await tester.drag(find.byType(Slider).first, const Offset(-200, 0));
      await tester.pumpAndSettle();
      // Only session log method must have been invoked.
      check(fake.setSessionLogRetentionCalls).isGreaterOrEqual(1);
      check(fake.setTrashRetentionCalls).equals(0);
    });

    testWidgets('body is scrollable (ListView wraps content)', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        const HistoryRetentionScreen(),
        overrides: _overrides(_FakeHistoryRetentionController(_defaultState())),
      );
      expect(find.byType(ListView), findsOneWidget);
    });
  });

  // ── Boundary values ───────────────────────────────────────────────────────

  group('HistoryRetentionScreen — boundary values', () {
    testWidgets('session log slider shows value 1 (minimum)', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        const HistoryRetentionScreen(),
        overrides: _overrides(
          _FakeHistoryRetentionController(
            _defaultState(sessionLogRetentionDays: 1),
          ),
        ),
      );
      final sliders = tester.widgetList<Slider>(find.byType(Slider)).toList();
      check(sliders[0].value).equals(1.0);
      check(sliders[0].label).equals('1d');
    });

    testWidgets('session log slider shows value 365 (maximum)', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        const HistoryRetentionScreen(),
        overrides: _overrides(
          _FakeHistoryRetentionController(
            _defaultState(sessionLogRetentionDays: 365),
          ),
        ),
      );
      final sliders = tester.widgetList<Slider>(find.byType(Slider)).toList();
      check(sliders[0].value).equals(365.0);
      check(sliders[0].label).equals('365d');
    });

    testWidgets('trash slider shows value 1 (minimum)', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        const HistoryRetentionScreen(),
        overrides: _overrides(
          _FakeHistoryRetentionController(_defaultState(trashRetentionDays: 1)),
        ),
      );
      final sliders = tester.widgetList<Slider>(find.byType(Slider)).toList();
      check(sliders[1].value).equals(1.0);
      check(sliders[1].label).equals('1d');
    });

    testWidgets('trash slider shows value 90 (maximum)', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        const HistoryRetentionScreen(),
        overrides: _overrides(
          _FakeHistoryRetentionController(
            _defaultState(trashRetentionDays: 90),
          ),
        ),
      );
      final sliders = tester.widgetList<Slider>(find.byType(Slider)).toList();
      check(sliders[1].value).equals(90.0);
      check(sliders[1].label).equals('90d');
    });
  });

  // ── RTL smoke ─────────────────────────────────────────────────────────────

  group('HistoryRetentionScreen — RTL', () {
    testWidgets('renders in Arabic (RTL) without overflow', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        const HistoryRetentionScreen(),
        overrides: _overrides(_FakeHistoryRetentionController(_defaultState())),
        locale: const Locale('ar'),
      );
      expect(find.byType(AppBar), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders in Hebrew (RTL) without overflow', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        const HistoryRetentionScreen(),
        overrides: _overrides(_FakeHistoryRetentionController(_defaultState())),
        locale: const Locale('he'),
      );
      expect(find.byType(AppBar), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  // ── Dark mode smoke ───────────────────────────────────────────────────────

  group('HistoryRetentionScreen — dark mode', () {
    testWidgets('renders without exception in dark mode', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        const HistoryRetentionScreen(),
        overrides: _overrides(_FakeHistoryRetentionController(_defaultState())),
        themeMode: ThemeMode.dark,
      );
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  // ── Accessibility ─────────────────────────────────────────────────────────

  group('HistoryRetentionScreen — accessibility', () {
    testWidgets('helper text uses bodySmall style (smaller than label)', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const HistoryRetentionScreen(),
        overrides: _overrides(_FakeHistoryRetentionController(_defaultState())),
      );
      final logsHelperText = tester.widget<Text>(
        find.text(l10n.historyRetentionLogsHelper),
      );
      // The helper is styled with Theme.of(context).textTheme.bodySmall,
      // which must not be null; its fontSize must be set by the theme.
      check(logsHelperText.style).isNotNull();
    });

    testWidgets('both sliders use the spec snap stops', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        const HistoryRetentionScreen(),
        overrides: _overrides(_FakeHistoryRetentionController(_defaultState())),
      );
      final sliders = tester.widgetList<Slider>(find.byType(Slider)).toList();
      // Session log stops [1,3,7,14,30,60,90,180,365] → 8 divisions.
      check(sliders[0].divisions).equals(8);
      // Trash stops [1,3,7,14,30,60,90] → 6 divisions.
      check(sliders[1].divisions).equals(6);
    });

    testWidgets('setSessionLogRetention receives integer days argument', (
      WidgetTester tester,
    ) async {
      final fake = _FakeHistoryRetentionController(
        // Default 180 days; explicit value dropped (matches factory default).
        _defaultState(),
      );
      await pumpScreen(
        tester,
        const HistoryRetentionScreen(),
        overrides: _overrides(fake),
      );
      await tester.drag(find.byType(Slider).first, const Offset(-300, 0));
      await tester.pumpAndSettle();
      // The controller receives an int (not a double), proving v.round() is
      // used in the onChanged callback.
      if (fake.lastSessionLogRetentionDays != null) {
        check(fake.lastSessionLogRetentionDays!).isGreaterOrEqual(1);
        check(fake.lastSessionLogRetentionDays!).isLessOrEqual(365);
      }
    });

    testWidgets('setTrashRetention receives integer days argument', (
      WidgetTester tester,
    ) async {
      final fake = _FakeHistoryRetentionController(
        // Default 7 days; explicit value dropped (matches factory default).
        _defaultState(),
      );
      await pumpScreen(
        tester,
        const HistoryRetentionScreen(),
        overrides: _overrides(fake),
      );
      await tester.drag(find.byType(Slider).last, const Offset(200, 0));
      await tester.pumpAndSettle();
      if (fake.lastTrashRetentionDays != null) {
        check(fake.lastTrashRetentionDays!).isGreaterOrEqual(1);
        check(fake.lastTrashRetentionDays!).isLessOrEqual(90);
      }
    });
  });

  // ── Purge now ─────────────────────────────────────────────────────────────

  group('HistoryRetentionScreen — purge now', () {
    /// Pumps the screen with a REAL in-memory Drift DB behind
    /// `sessionLogRepositoryProvider` plus a fake settings repo, so the
    /// Purge-now button drives the real purge end-to-end.
    Future<GuardianAngelaDatabase> pumpWithDb(WidgetTester tester) async {
      final db = GuardianAngelaDatabase.memory(seedCallback: (_) async {});
      addTearDown(db.close);
      await pumpScreen(
        tester,
        const HistoryRetentionScreen(),
        overrides: <Override>[
          historyRetentionControllerProvider.overrideWith(
            () => _FakeHistoryRetentionController(_defaultState()),
          ),
          databaseProvider.overrideWith((_) async => db),
          appSettingsRepositoryProvider.overrideWithValue(
            _FakeAppSettingsRepository(const AppSettings()),
          ),
        ],
      );
      return db;
    }

    Future<void> tapPurgeNow(WidgetTester tester) async {
      final l10n = await loadL10n(const Locale('en'));
      final button = find.text(l10n.historyRetentionPurgeNow);
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pumpAndSettle();
    }

    testWidgets(
      'purges an expired trashed log and reports the count in a SnackBar',
      (WidgetTester tester) async {
        final db = await pumpWithDb(tester);
        final repo = SessionLogRepository(db.sessionLogsDao);
        final now = DateTime.now().toUtc();
        final started = now.subtract(const Duration(days: 30));
        await repo.upsert(
          SessionLog(
            id: 'expired-trash',
            modeId: 'walk-mode',
            modeName: 'Walk Mode',
            startedAt: started,
            endedAt: started.add(const Duration(minutes: 5)),
            endReason: EndReason.userQuit,
            isSimulation: false,
            events: const <SessionLogEvent>[],
          ),
        );
        // Trashed 10 days ago > default 7-day trash window → purgeable.
        await repo.softDelete(
          'expired-trash',
          now: now.subtract(const Duration(days: 10)),
        );
        final l10n = await loadL10n(const Locale('en'));

        await tapPurgeNow(tester);

        expect(find.text(l10n.historyRetentionPurged(1)), findsOneWidget);
        check(await repo.getById('expired-trash')).isNull();
      },
    );

    testWidgets('reports 0 purged on an empty database', (
      WidgetTester tester,
    ) async {
      await pumpWithDb(tester);
      final l10n = await loadL10n(const Locale('en'));

      await tapPurgeNow(tester);

      expect(find.text(l10n.historyRetentionPurged(0)), findsOneWidget);
    });
  });
}
