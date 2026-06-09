/// Widget tests for [PastEventsTrashScreen].
///
/// Pattern mirrors `test/features/home/home_screen_test.dart`:
/// 1. A `_FakeTrashController` subclasses the real
///    [PastEventsTrashController] and overrides `build()` to return a
///    canned [PastEventsTrashState].
/// 2. Each test calls `pumpScreen` with an override for
///    [pastEventsTrashControllerProvider].
/// 3. Assertions use `find.text`, `find.byType`, and `package:checks`.
library;

import 'package:flutter/material.dart';

import 'package:checks/checks.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/features/past_events_trash/past_events_trash_controller.dart';
import 'package:guardianangela/features/past_events_trash/past_events_trash_screen.dart';
import '../../helpers/widget_test_helpers.dart';

// ---------------------------------------------------------------------------
// Test fake
// ---------------------------------------------------------------------------

class _FakeTrashController extends PastEventsTrashController {
  _FakeTrashController(this._initial);

  final PastEventsTrashState _initial;

  int restoreCalls = 0;
  String? lastRestoredId;

  int deletePermanentlyCalls = 0;
  String? lastDeletedId;

  int emptyTrashCalls = 0;

  /// Value returned by the [emptyTrash] override (the purged-row count
  /// surfaced in the success SnackBar).
  int emptyTrashResult = 0;

  @override
  Future<PastEventsTrashState> build() async => _initial;

  @override
  Future<int> emptyTrash() async {
    emptyTrashCalls++;
    return emptyTrashResult;
  }

  @override
  Future<void> restore(String id) async {
    restoreCalls++;
    lastRestoredId = id;
  }

  @override
  Future<void> deletePermanently(String id) async {
    deletePermanentlyCalls++;
    lastDeletedId = id;
  }
}

// ---------------------------------------------------------------------------
// Test data helpers
// ---------------------------------------------------------------------------

/// Fixed reference UTC time used as [deletedAt] in tests so that
/// [_remainingDays] returns a stable non-negative value (the log was
/// "just" trashed).
final _kNow = DateTime.utc(2026, 5, 27, 12);

PastEventsTrashLog _log({
  String id = 'log-1',
  String modeName = 'Test Mode',
  bool isSimulation = false,
  DateTime? deletedAt,
  DateTime? startedAt,
}) => PastEventsTrashLog(
  id: id,
  modeName: modeName,
  startedAt: startedAt ?? DateTime.utc(2026, 5, 27, 10),
  durationSeconds: 300,
  isSimulation: isSimulation,
  deletedAt: deletedAt ?? _kNow,
);

PastEventsTrashState _state({
  List<PastEventsTrashLog>? logs,
  int retentionDays = 7,
}) => PastEventsTrashState(
  logs: logs ?? <PastEventsTrashLog>[],
  retentionDays: retentionDays,
);

List<Override> _overrides(_FakeTrashController fake) => <Override>[
  pastEventsTrashControllerProvider.overrideWith(() => fake),
];

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // -------------------------------------------------------------------------
  group('PastEventsTrashScreen — AppBar', () {
    testWidgets('renders the Trash title in the app bar', (
      WidgetTester tester,
    ) async {
      final fake = _FakeTrashController(_state());
      final l10n = await loadL10n(const Locale('en'));
      // Deliberately NON-const so the constructor line executes at
      // runtime — a const instance is canonicalized and its DA line
      // flickers in full-suite lcov runs.
      await pumpScreen(
        tester,
        PastEventsTrashScreen(key: UniqueKey()),
        overrides: _overrides(fake),
      );
      expect(find.text(l10n.pastEventsTrashTitle), findsWidgets);
    });
  });

  // -------------------------------------------------------------------------
  group('PastEventsTrashScreen — async states', () {
    testWidgets('shows CircularProgressIndicator while loading', (
      WidgetTester tester,
    ) async {
      final fake = _FakeTrashController(_state());
      await pumpScreen(
        tester,
        const PastEventsTrashScreen(),
        overrides: _overrides(fake),
        settle: false,
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('hides CircularProgressIndicator once resolved', (
      WidgetTester tester,
    ) async {
      final fake = _FakeTrashController(_state());
      await pumpScreen(
        tester,
        const PastEventsTrashScreen(),
        overrides: _overrides(fake),
      );
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('shows error text on AsyncError', (WidgetTester tester) async {
      // Inject an error state by using a controller that throws.
      final provider = pastEventsTrashControllerProvider.overrideWith(() {
        return _ErrorTrashController();
      });
      await pumpScreen(
        tester,
        const PastEventsTrashScreen(),
        overrides: <Override>[provider],
      );
      expect(find.textContaining('Error:'), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  group('PastEventsTrashScreen — empty state', () {
    testWidgets('shows the empty-trash message when list is empty', (
      WidgetTester tester,
    ) async {
      final fake = _FakeTrashController(_state());
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const PastEventsTrashScreen(),
        overrides: _overrides(fake),
      );
      expect(find.text(l10n.pastEventsTrashEmpty), findsOneWidget);
    });

    testWidgets('empty state shows no ListTile widgets', (
      WidgetTester tester,
    ) async {
      final fake = _FakeTrashController(_state());
      await pumpScreen(
        tester,
        const PastEventsTrashScreen(),
        overrides: _overrides(fake),
      );
      expect(find.byType(ListTile), findsNothing);
    });
  });

  // -------------------------------------------------------------------------
  group('PastEventsTrashScreen — retention note', () {
    testWidgets('shows the retention-note text with retentionDays', (
      WidgetTester tester,
    ) async {
      final fake = _FakeTrashController(_state());
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const PastEventsTrashScreen(),
        overrides: _overrides(fake),
      );
      expect(find.text(l10n.pastEventsTrashRetentionNote(7)), findsOneWidget);
    });

    testWidgets('retention note reflects custom retentionDays value', (
      WidgetTester tester,
    ) async {
      final fake = _FakeTrashController(_state(retentionDays: 14));
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const PastEventsTrashScreen(),
        overrides: _overrides(fake),
      );
      expect(find.text(l10n.pastEventsTrashRetentionNote(14)), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  group('PastEventsTrashScreen — list rows', () {
    testWidgets('renders one ListTile per trashed log', (
      WidgetTester tester,
    ) async {
      final logs = <PastEventsTrashLog>[
        _log(id: 'a', modeName: 'Walk Mode'),
        _log(id: 'b', modeName: 'Date Mode'),
        _log(id: 'c', modeName: 'Night Out'),
      ];
      final fake = _FakeTrashController(_state(logs: logs));
      await pumpScreen(
        tester,
        const PastEventsTrashScreen(),
        overrides: _overrides(fake),
      );
      expect(find.byType(ListTile), findsNWidgets(3));
    });

    testWidgets('row shows mode name as title', (WidgetTester tester) async {
      final logs = <PastEventsTrashLog>[_log(id: 'a', modeName: 'Walk Mode')];
      final fake = _FakeTrashController(_state(logs: logs));
      await pumpScreen(
        tester,
        const PastEventsTrashScreen(),
        overrides: _overrides(fake),
      );
      expect(find.text('Walk Mode'), findsOneWidget);
    });

    testWidgets('row subtitle contains formatted startedAt timestamp', (
      WidgetTester tester,
    ) async {
      final started = DateTime.utc(2026, 5, 27, 10, 5);
      final logs = <PastEventsTrashLog>[_log(id: 'a', startedAt: started)];
      final fake = _FakeTrashController(_state(logs: logs));
      await pumpScreen(
        tester,
        const PastEventsTrashScreen(),
        overrides: _overrides(fake),
      );
      // The screen formats as YYYY-MM-DD HH:mm — e.g. "2026-05-27 10:05".
      expect(find.textContaining('2026-05-27'), findsOneWidget);
      expect(find.textContaining('10:05'), findsOneWidget);
    });

    testWidgets('row subtitle contains remaining-days label', (
      WidgetTester tester,
    ) async {
      // Use the real wall clock (not the test's pinned _kNow) so the
      // screen's `DateTime.now()` agrees: deletedAt is "just trashed"
      // → remaining = 7 (the default retentionDays).
      final justNow = DateTime.now().toUtc();
      final fake = _FakeTrashController(
        _state(
          logs: <PastEventsTrashLog>[_log(id: 'a', deletedAt: justNow)],
        ),
      );
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const PastEventsTrashScreen(),
        overrides: _overrides(fake),
      );
      expect(
        find.textContaining(l10n.pastEventsTrashRemainingDays(7)),
        findsOneWidget,
      );
    });

    testWidgets('simulation log shows play_circle_outline icon', (
      WidgetTester tester,
    ) async {
      final logs = <PastEventsTrashLog>[_log(id: 'a', isSimulation: true)];
      final fake = _FakeTrashController(_state(logs: logs));
      await pumpScreen(
        tester,
        const PastEventsTrashScreen(),
        overrides: _overrides(fake),
      );
      expect(find.byIcon(Icons.play_circle_outline), findsOneWidget);
    });

    testWidgets('real log shows shield icon', (WidgetTester tester) async {
      // isSimulation defaults to false — only real session.
      final logs = <PastEventsTrashLog>[_log(id: 'a')];
      final fake = _FakeTrashController(_state(logs: logs));
      await pumpScreen(
        tester,
        const PastEventsTrashScreen(),
        overrides: _overrides(fake),
      );
      expect(find.byIcon(Icons.shield), findsOneWidget);
    });

    testWidgets('two logs render two restore buttons', (
      WidgetTester tester,
    ) async {
      final logs = <PastEventsTrashLog>[
        _log(id: 'a', modeName: 'Walk Mode'),
        _log(id: 'b', modeName: 'Date Mode'),
      ];
      final fake = _FakeTrashController(_state(logs: logs));
      await pumpScreen(
        tester,
        const PastEventsTrashScreen(),
        overrides: _overrides(fake),
      );
      expect(find.byIcon(Icons.restore), findsNWidgets(2));
    });

    testWidgets('two logs render two delete-forever buttons', (
      WidgetTester tester,
    ) async {
      final logs = <PastEventsTrashLog>[
        _log(id: 'a', modeName: 'Walk Mode'),
        _log(id: 'b', modeName: 'Date Mode'),
      ];
      final fake = _FakeTrashController(_state(logs: logs));
      await pumpScreen(
        tester,
        const PastEventsTrashScreen(),
        overrides: _overrides(fake),
      );
      expect(find.byIcon(Icons.delete_forever), findsNWidgets(2));
    });
  });

  // -------------------------------------------------------------------------
  group('PastEventsTrashScreen — restore action', () {
    testWidgets('tapping Restore icon calls controller.restore with log id', (
      WidgetTester tester,
    ) async {
      final logs = <PastEventsTrashLog>[
        _log(id: 'log-abc', modeName: 'Walk Mode'),
      ];
      final fake = _FakeTrashController(_state(logs: logs));
      await pumpScreen(
        tester,
        const PastEventsTrashScreen(),
        overrides: _overrides(fake),
      );
      await tester.tap(find.byIcon(Icons.restore));
      await tester.pumpAndSettle();
      check(fake.restoreCalls).equals(1);
      check(fake.lastRestoredId).equals('log-abc');
    });

    testWidgets('restore button exposes the Restore tooltip', (
      WidgetTester tester,
    ) async {
      final logs = <PastEventsTrashLog>[_log(id: 'a')];
      final fake = _FakeTrashController(_state(logs: logs));
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const PastEventsTrashScreen(),
        overrides: _overrides(fake),
      );
      expect(find.byTooltip(l10n.pastEventsRestore), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  group('PastEventsTrashScreen — delete permanently action', () {
    testWidgets('tapping Delete-forever shows confirmation dialog', (
      WidgetTester tester,
    ) async {
      final logs = <PastEventsTrashLog>[_log(id: 'a')];
      final fake = _FakeTrashController(_state(logs: logs));
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const PastEventsTrashScreen(),
        overrides: _overrides(fake),
      );
      await tester.tap(find.byIcon(Icons.delete_forever));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text(l10n.pastEventsTrashDeletePermanently), findsWidgets);
    });

    testWidgets('confirmation dialog shows the "cannot be undone" body text', (
      WidgetTester tester,
    ) async {
      final logs = <PastEventsTrashLog>[_log(id: 'a')];
      final fake = _FakeTrashController(_state(logs: logs));
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const PastEventsTrashScreen(),
        overrides: _overrides(fake),
      );
      await tester.tap(find.byIcon(Icons.delete_forever));
      await tester.pumpAndSettle();
      expect(
        find.text(l10n.pastEventsTrashDeletePermanentlyBody),
        findsOneWidget,
      );
    });

    testWidgets('cancelling dialog does NOT call deletePermanently', (
      WidgetTester tester,
    ) async {
      final logs = <PastEventsTrashLog>[_log(id: 'a')];
      final fake = _FakeTrashController(_state(logs: logs));
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const PastEventsTrashScreen(),
        overrides: _overrides(fake),
      );
      await tester.tap(find.byIcon(Icons.delete_forever));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.commonCancel));
      await tester.pumpAndSettle();
      check(fake.deletePermanentlyCalls).equals(0);
    });

    testWidgets('confirming dialog calls deletePermanently with log id', (
      WidgetTester tester,
    ) async {
      final logs = <PastEventsTrashLog>[
        _log(id: 'log-xyz', modeName: 'Walk Mode'),
      ];
      final fake = _FakeTrashController(_state(logs: logs));
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const PastEventsTrashScreen(),
        overrides: _overrides(fake),
      );
      await tester.tap(find.byIcon(Icons.delete_forever));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.commonConfirm));
      await tester.pumpAndSettle();
      check(fake.deletePermanentlyCalls).equals(1);
      check(fake.lastDeletedId).equals('log-xyz');
    });

    testWidgets('delete-forever button exposes its tooltip', (
      WidgetTester tester,
    ) async {
      final logs = <PastEventsTrashLog>[_log(id: 'a')];
      final fake = _FakeTrashController(_state(logs: logs));
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const PastEventsTrashScreen(),
        overrides: _overrides(fake),
      );
      expect(
        find.byTooltip(l10n.pastEventsTrashDeletePermanently),
        findsOneWidget,
      );
    });
  });

  // -------------------------------------------------------------------------
  group('PastEventsTrashScreen — remaining days', () {
    testWidgets(
      'remaining days shows 0 when deletedAt is beyond retentionDays ago',
      (WidgetTester tester) async {
        // deleted 10 days ago with default retentionDays=7 → clamped to 0.
        final oldDate = DateTime.now().toUtc().subtract(
          const Duration(days: 10),
        );
        final logs = <PastEventsTrashLog>[_log(id: 'a', deletedAt: oldDate)];
        final fake = _FakeTrashController(_state(logs: logs));
        final l10n = await loadL10n(const Locale('en'));
        await pumpScreen(
          tester,
          const PastEventsTrashScreen(),
          overrides: _overrides(fake),
        );
        expect(
          find.textContaining(l10n.pastEventsTrashRemainingDays(0)),
          findsOneWidget,
        );
      },
    );

    testWidgets('remaining days is correct for mid-retention log', (
      WidgetTester tester,
    ) async {
      // deleted 3 days ago with default retentionDays=7 → 4 days remaining.
      final threeDaysAgo = DateTime.now().toUtc().subtract(
        const Duration(days: 3),
      );
      final logs = <PastEventsTrashLog>[_log(id: 'a', deletedAt: threeDaysAgo)];
      final fake = _FakeTrashController(_state(logs: logs));
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const PastEventsTrashScreen(),
        overrides: _overrides(fake),
      );
      expect(
        find.textContaining(l10n.pastEventsTrashRemainingDays(4)),
        findsOneWidget,
      );
    });
  });

  // -------------------------------------------------------------------------
  group('PastEventsTrashScreen — RTL', () {
    testWidgets('renders in Arabic (RTL) without overflow or exception', (
      WidgetTester tester,
    ) async {
      final logs = <PastEventsTrashLog>[_log(id: 'a', modeName: 'Walk Mode')];
      final fake = _FakeTrashController(_state(logs: logs));
      await pumpScreen(
        tester,
        const PastEventsTrashScreen(),
        overrides: _overrides(fake),
        locale: const Locale('ar'),
      );
      expect(find.byType(AppBar), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('empty state renders in RTL without exception', (
      WidgetTester tester,
    ) async {
      final fake = _FakeTrashController(_state());
      await pumpScreen(
        tester,
        const PastEventsTrashScreen(),
        overrides: _overrides(fake),
        locale: const Locale('ar'),
      );
      expect(tester.takeException(), isNull);
    });
  });

  // -------------------------------------------------------------------------
  group('PastEventsTrashScreen — dark mode', () {
    testWidgets('renders without exception in dark mode (empty)', (
      WidgetTester tester,
    ) async {
      final fake = _FakeTrashController(_state());
      await pumpScreen(
        tester,
        const PastEventsTrashScreen(),
        overrides: _overrides(fake),
        themeMode: ThemeMode.dark,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders without exception in dark mode (with logs)', (
      WidgetTester tester,
    ) async {
      final logs = <PastEventsTrashLog>[
        _log(id: 'a', modeName: 'Walk Mode'),
        _log(id: 'b', modeName: 'Date Mode', isSimulation: true),
      ];
      final fake = _FakeTrashController(_state(logs: logs));
      await pumpScreen(
        tester,
        const PastEventsTrashScreen(),
        overrides: _overrides(fake),
        themeMode: ThemeMode.dark,
      );
      expect(tester.takeException(), isNull);
    });
  });

  // -------------------------------------------------------------------------
  group('PastEventsTrashScreen — accessibility', () {
    testWidgets('restore icon button exposes Restore tooltip', (
      WidgetTester tester,
    ) async {
      final logs = <PastEventsTrashLog>[_log(id: 'a')];
      final fake = _FakeTrashController(_state(logs: logs));
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const PastEventsTrashScreen(),
        overrides: _overrides(fake),
      );
      expect(find.byTooltip(l10n.pastEventsRestore), findsOneWidget);
    });

    testWidgets('delete-forever icon button exposes Delete tooltip', (
      WidgetTester tester,
    ) async {
      final logs = <PastEventsTrashLog>[_log(id: 'a')];
      final fake = _FakeTrashController(_state(logs: logs));
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const PastEventsTrashScreen(),
        overrides: _overrides(fake),
      );
      expect(
        find.byTooltip(l10n.pastEventsTrashDeletePermanently),
        findsOneWidget,
      );
    });

    testWidgets('multiple rows all have restore tooltips', (
      WidgetTester tester,
    ) async {
      final logs = <PastEventsTrashLog>[
        _log(id: 'a', modeName: 'Walk'),
        _log(id: 'b', modeName: 'Date'),
        _log(id: 'c', modeName: 'Night'),
      ];
      final fake = _FakeTrashController(_state(logs: logs));
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const PastEventsTrashScreen(),
        overrides: _overrides(fake),
      );
      expect(find.byTooltip(l10n.pastEventsRestore), findsNWidgets(3));
    });
  });

  // -------------------------------------------------------------------------
  group('PastEventsTrashScreen — empty trash action', () {
    /// Opens the AppBar overflow menu and taps "Empty trash", landing on
    /// the typed-confirmation dialog.
    Future<void> openEmptyTrashDialog(WidgetTester tester) async {
      final l10n = await loadL10n(const Locale('en'));
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.pastEventsTrashEmptyAll));
      await tester.pumpAndSettle();
    }

    /// Returns the dialog's confirm [FilledButton] (the one labelled
    /// "Empty trash" inside the AlertDialog).
    Finder confirmButton() => find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byType(FilledButton),
    );

    testWidgets('menu action opens the typed-confirmation dialog', (
      WidgetTester tester,
    ) async {
      final fake = _FakeTrashController(
        _state(logs: <PastEventsTrashLog>[_log(id: 'a')]),
      );
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const PastEventsTrashScreen(),
        overrides: _overrides(fake),
      );
      await openEmptyTrashDialog(tester);
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(
        find.text(l10n.pastEventsTrashEmptyAllConfirmTitle),
        findsOneWidget,
      );
      expect(
        find.text(l10n.pastEventsTrashEmptyAllConfirmBody),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.byType(TextField),
        ),
        findsOneWidget,
      );
    });

    testWidgets('confirm stays disabled until the exact phrase is typed', (
      WidgetTester tester,
    ) async {
      final fake = _FakeTrashController(_state());
      await pumpScreen(
        tester,
        const PastEventsTrashScreen(),
        overrides: _overrides(fake),
      );
      await openEmptyTrashDialog(tester);
      // Disabled on open.
      check(tester.widget<FilledButton>(confirmButton()).onPressed).isNull();
      // Still disabled on a near-miss.
      await tester.enterText(find.byType(TextField), 'empty trash');
      await tester.pumpAndSettle();
      check(tester.widget<FilledButton>(confirmButton()).onPressed).isNull();
      // Enabled once the phrase matches verbatim.
      await tester.enterText(find.byType(TextField), 'EMPTY TRASH');
      await tester.pumpAndSettle();
      check(tester.widget<FilledButton>(confirmButton()).onPressed).isNotNull();
    });

    testWidgets('cancelling the dialog does NOT call emptyTrash', (
      WidgetTester tester,
    ) async {
      final fake = _FakeTrashController(_state());
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const PastEventsTrashScreen(),
        overrides: _overrides(fake),
      );
      await openEmptyTrashDialog(tester);
      await tester.tap(find.text(l10n.commonCancel));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      check(fake.emptyTrashCalls).equals(0);
    });

    testWidgets(
      'typing the phrase and confirming calls emptyTrash and shows the '
      'purged-count SnackBar',
      (WidgetTester tester) async {
        final fake = _FakeTrashController(_state())..emptyTrashResult = 3;
        final l10n = await loadL10n(const Locale('en'));
        await pumpScreen(
          tester,
          const PastEventsTrashScreen(),
          overrides: _overrides(fake),
        );
        await openEmptyTrashDialog(tester);
        await tester.enterText(find.byType(TextField), 'EMPTY TRASH');
        await tester.pumpAndSettle();
        await tester.tap(confirmButton());
        await tester.pumpAndSettle();
        check(fake.emptyTrashCalls).equals(1);
        expect(
          find.text(l10n.pastEventsTrashEmptyAllSuccess(3)),
          findsOneWidget,
        );
      },
    );
  });
}

// ---------------------------------------------------------------------------
// Error-state helper controller (throws on build)
// ---------------------------------------------------------------------------

class _ErrorTrashController extends PastEventsTrashController {
  @override
  Future<PastEventsTrashState> build() =>
      Future<PastEventsTrashState>.error(Exception('db-failure'));
}
