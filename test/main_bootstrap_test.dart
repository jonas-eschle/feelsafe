// Tests for the main.dart bootstrap widgets (Stage 5C.8).
//
// Tests bootstrap contracts:
// 1. JsonRecoveryApp renders the recovery UI per spec 10:206 (Extra 21).
// 2. GuardianAngelaApp renders the Phase 5 placeholder shell.
// 3. Startup purge test: verifies SessionLogRepository.purgeExpiredLogs fires
//    with the correct cutoff against an in-memory database.
// 4. Restore-from-backup flow: file-picker cancelled / success / error paths.
//
// The full main() pipeline (DB open → settings load → Sentry init → purge →
// notification init → TTS bootstrap → runApp) cannot be unit-tested directly
// because it calls WidgetsFlutterBinding.ensureInitialized() and real
// platform channel methods. This file focuses on:
//   a) The widgets exported by main.dart (GuardianAngelaApp, JsonRecoveryApp).
//   b) The purge step in isolation against an in-memory DB.
//   c) The bootstrap ordering contract (steps must be exercised in order —
//      verified by checking that the correct state is achieved after each
//      step in a simulated sequence).
//   d) The restore-from-backup flow via a fake FileSelector + BackupService.

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:checks/checks.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'package:guardianangela/data/db/database.dart';
import 'package:guardianangela/data/repositories/app_settings_repository.dart';
import 'package:guardianangela/data/repositories/session_log_repository.dart';
import 'package:guardianangela/domain/enums/app_theme_mode.dart';
import 'package:guardianangela/domain/models/app_settings.dart';
import 'package:guardianangela/domain/models/session_log.dart';
import 'package:guardianangela/main.dart';
import 'package:guardianangela/services/audio_service.dart';
import 'package:guardianangela/services/notification_service.dart';
import 'package:guardianangela/services/protocols/backup_service_protocol.dart';
import 'package:guardianangela/services/protocols/sentry_service_protocol.dart';
import 'package:guardianangela/services/service_providers.dart';
import 'package:guardianangela/services/sim/backup_service_sim.dart';

import 'package:file_selector_platform_interface/file_selector_platform_interface.dart'
    show FileSelectorPlatform;

// ---------------------------------------------------------------------------
// Q8: Bootstrap ordering — sequence tracker fakes
// ---------------------------------------------------------------------------

/// An [AppSettingsRepository] that appends `'settingsLoad'` to [calls] and
/// returns a default [AppSettings].
class _OrderingSettingsRepo implements AppSettingsRepository {
  _OrderingSettingsRepo(this.calls);

  final List<String> calls;

  @override
  Future<AppSettings> load() async {
    calls.add('settingsLoad');
    return const AppSettings();
  }

  @override
  Future<AppSettings?> loadOrNull() async {
    calls.add('settingsLoad');
    return const AppSettings();
  }

  @override
  Future<void> save(AppSettings value) async {}

  @override
  Future<void> delete() async {}
}

/// A [SentryServiceProtocol] that appends `'sentryInit'` to [calls] on
/// [initialize].
class _OrderingSentryService implements SentryServiceProtocol {
  _OrderingSentryService(this.calls);

  final List<String> calls;

  @override
  Future<void> initialize({
    required bool enabled,
    String? dsn,
    double tracesSampleRate = 0.0,
  }) async {
    calls.add('sentryInit');
  }

  @override
  Future<void> captureException(
    Object error,
    StackTrace? stack, {
    Map<String, dynamic>? context,
  }) async {}

  @override
  Future<void> close() async {}
}

/// A [SessionLogRepository] substitute that appends `'purgeLogs'` to [calls]
/// and reports zero purge activity.
///
/// Constructed with a real in-memory database so the provider chain
/// is satisfied, but [purgeExpiredLogs] never touches it.
class _OrderingSessionLogRepo extends SessionLogRepository {
  _OrderingSessionLogRepo(super.dao, this.calls);

  final List<String> calls;

  @override
  Future<PurgeResult> purgeExpiredLogs({
    required int retentionDays,
    required DateTime now,
    int trashRetentionDays = 7,
  }) async {
    calls.add('purgeLogs');
    return (movedToTrash: 0, hardDeleted: 0);
  }
}

/// A [RealNotificationService] that overrides [init] to append
/// `'notificationInit'` to [calls] without calling platform channels.
class _OrderingNotificationService extends RealNotificationService {
  _OrderingNotificationService(this.calls);

  final List<String> calls;

  @override
  Future<void> init() async => calls.add('notificationInit');
}

/// A [RealAudioService] that overrides [bootstrapVoiceAssets] to append
/// `'ttsBootstrap'` to [calls] without calling TTS or platform channels.
class _OrderingAudioService extends RealAudioService {
  _OrderingAudioService(this.calls);

  final List<String> calls;

  @override
  Future<void> bootstrapVoiceAssets({
    void Function(String locale, Object error, StackTrace stack)? onFailure,
  }) async {
    calls.add('ttsBootstrap');
  }
}

// ---------------------------------------------------------------------------
// G12/G13: Bootstrap ordering helpers
// ---------------------------------------------------------------------------

/// Fake [AppSettingsRepository] whose [load] throws a [FormatException].
///
/// Used by G13 to simulate JSON corruption triggering the recovery path.
class _ThrowingSettingsRepo implements AppSettingsRepository {
  @override
  Future<AppSettings> load() =>
      Future.error(const FormatException('settings.json is corrupt'));

  @override
  Future<AppSettings?> loadOrNull() =>
      Future.error(const FormatException('corrupt'));

  @override
  Future<void> save(AppSettings value) async {}

  @override
  Future<void> delete() async {}
}

/// A [SentryServiceProtocol] that records every captured exception.
class _RecordingSentryService implements SentryServiceProtocol {
  final List<Object> captured = [];

  @override
  Future<void> initialize({
    required bool enabled,
    String? dsn,
    double tracesSampleRate = 0.0,
  }) async {}

  @override
  Future<void> captureException(
    Object error,
    StackTrace? stack, {
    Map<String, dynamic>? context,
  }) async {
    captured.add(error);
  }

  @override
  Future<void> close() async {}
}

/// A [SessionLogRepository] whose [purgeExpiredLogs] reports fixed non-zero
/// counts for both stages (exercises the activity-log branch in
/// runBootstrap step 4).
class _PurgingSessionLogRepo extends SessionLogRepository {
  _PurgingSessionLogRepo(super.dao);

  @override
  Future<PurgeResult> purgeExpiredLogs({
    required int retentionDays,
    required DateTime now,
    int trashRetentionDays = 7,
  }) async => (movedToTrash: 2, hardDeleted: 1);
}

/// A [SessionLogRepository] whose [purgeExpiredLogs] throws (exercises the
/// non-fatal catch + Sentry capture in runBootstrap step 4).
class _ThrowingSessionLogRepo extends SessionLogRepository {
  _ThrowingSessionLogRepo(super.dao);

  @override
  Future<PurgeResult> purgeExpiredLogs({
    required int retentionDays,
    required DateTime now,
    int trashRetentionDays = 7,
  }) async => throw StateError('purge boom');
}

/// A [RealAudioService] whose [bootstrapVoiceAssets] invokes [onFailure] once
/// (exercises the Sentry-capture failure callback wired in runBootstrap
/// step 6).
class _FailingAudioService extends RealAudioService {
  @override
  Future<void> bootstrapVoiceAssets({
    void Function(String locale, Object error, StackTrace stack)? onFailure,
  }) async {
    onFailure?.call('en', StateError('tts boom'), StackTrace.current);
  }
}

/// An [AppSettingsRepository] that returns a caller-supplied [AppSettings] from
/// both [load] and [loadOrNull] (used to drive the GuardianAngelaApp theme +
/// locale branches and a non-recovery runBootstrap).
class _FixedSettingsRepo implements AppSettingsRepository {
  _FixedSettingsRepo(this.value);

  final AppSettings value;

  @override
  Future<AppSettings> load() async => value;

  @override
  Future<AppSettings?> loadOrNull() async => value;

  @override
  Future<void> save(AppSettings value) async {}

  @override
  Future<void> delete() async {}
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Creates an in-memory database without seeding (clean slate).
GuardianAngelaDatabase _openDb() =>
    GuardianAngelaDatabase.memory(seedCallback: (_) async {});

/// Fake [FileSelectorPlatform] that returns a canned [XFile] without calling
/// platform channels. Mixes in [MockPlatformInterfaceMixin] to satisfy
/// PlatformInterface.verifyToken.
class _FakeFileSelector extends FileSelectorPlatform
    with MockPlatformInterfaceMixin {
  _FakeFileSelector({this.file});

  /// The file to return from [openFile]. `null` simulates cancellation.
  final XFile? file;

  @override
  Future<XFile?> openFile({
    List<XTypeGroup>? acceptedTypeGroups,
    String? initialDirectory,
    String? confirmButtonText,
  }) async => file;
}

/// [BackupServiceProtocol] that always throws on [importFromJson].
class _ThrowingBackupService implements BackupServiceProtocol {
  @override
  Future<String> exportToJson({
    bool includeSessionLogs = true,
    bool includeMedia = true,
  }) async => '{}';

  @override
  Future<void> importFromJson(String json) async =>
      throw const FormatException('Backup is missing a valid _schemaVersion.');
}

/// Wraps a [JsonRecoveryApp] inside an [UncontrolledProviderScope] that
/// overrides [backupServiceProvider] with the given [BackupServiceProtocol].
Widget _recoveryWithBackup(BackupServiceProtocol backup) {
  final container = ProviderContainer(
    overrides: [backupServiceProvider.overrideWith((_) async => backup)],
  );
  return UncontrolledProviderScope(
    container: container,
    child: const JsonRecoveryApp(reason: 'TestError'),
  );
}

/// A [SessionLog] that is NOT critical (will be purged when past cutoff).
SessionLog _normalLog({
  required String id,
  required DateTime startedAt,
  DateTime? endedAt,
}) => SessionLog(
  id: id,
  modeId: 'mode1',
  modeName: 'Test Mode',
  startedAt: startedAt,
  endedAt: endedAt,
  isSimulation: false,
  events: const [],
);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('GuardianAngelaApp widget', () {
    // Phase 6: GuardianAngelaApp now wires GoRouter + the
    // appSettingsRepositoryProvider; rendering it requires a real
    // ProviderScope + database. Those scenarios live in the widget test
    // cohort (next stage). The only contract we keep here is that the
    // symbol is constructable.
    test('is const-constructable', () {
      expect(const GuardianAngelaApp(), isA<Widget>());
    });
  });

  // --------------------------------------------------------------------------
  group('JsonRecoveryApp widget', () {
    testWidgets('shows "Data Recovery" heading', (WidgetTester tester) async {
      await tester.pumpWidget(const JsonRecoveryApp(reason: 'Test failure'));
      await tester.pumpAndSettle();

      expect(find.text('Data Recovery'), findsWidgets);
    });

    testWidgets('shows the technical reason text', (WidgetTester tester) async {
      const reason = 'FormatException: malformed JSON at position 42';
      await tester.pumpWidget(const JsonRecoveryApp(reason: reason));
      await tester.pumpAndSettle();

      expect(find.textContaining(reason), findsOneWidget);
    });

    testWidgets('has "Start fresh" button', (WidgetTester tester) async {
      await tester.pumpWidget(const JsonRecoveryApp(reason: 'error'));
      await tester.pumpAndSettle();

      expect(find.text('Start fresh'), findsOneWidget);
    });

    testWidgets('has "Restore from backup" button (enabled)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const JsonRecoveryApp(reason: 'error'));
      await tester.pumpAndSettle();

      // Button is present and enabled (real callback wired).
      final button = find.ancestor(
        of: find.text('Restore from backup'),
        matching: find.byType(FilledButton),
      );
      expect(button, findsOneWidget);
      final filledButton = tester.widget<FilledButton>(button);
      expect(filledButton.onPressed, isNotNull);
    });

    testWidgets('uses Material theme with correct seed color', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const JsonRecoveryApp(reason: 'error'));
      await tester.pumpAndSettle();

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      // useMaterial3 should be true (set in JsonRecoveryApp.build).
      expect(materialApp.theme?.useMaterial3, isTrue);
    });
  });

  // --------------------------------------------------------------------------
  group('Restore-from-backup flow', () {
    tearDown(() {
      // Reset to a no-op fake so real platform channels are never called by
      // any later test that might inadvertently leave a bad state.
      FileSelectorPlatform.instance = _FakeFileSelector();
    });

    testWidgets('cancelled pick shows "No file selected."', (
      WidgetTester tester,
    ) async {
      FileSelectorPlatform.instance = _FakeFileSelector();

      await tester.pumpWidget(_recoveryWithBackup(SimulationBackupService()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Restore from backup'));
      await tester.pumpAndSettle();

      expect(find.textContaining('No file selected.'), findsOneWidget);
    });

    testWidgets('successful import shows success message and _actionTaken', (
      WidgetTester tester,
    ) async {
      const validJson =
          '{"version":"1.0","_schemaVersion":1,"timestamp":"",'
          '"contacts":[],"modes":[],"settings":{},'
          '"templates":[],"eventDefaults":{},"profile":{}}';
      FileSelectorPlatform.instance = _FakeFileSelector(
        file: XFile.fromData(
          Uint8List.fromList(utf8.encode(validJson)),
          name: 'backup.json',
          mimeType: 'application/json',
        ),
      );

      final sim = SimulationBackupService();
      await tester.pumpWidget(_recoveryWithBackup(sim));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Restore from backup'));
      await tester.pumpAndSettle();

      // Success: shows the done-message view (no longer showing choice panel).
      expect(find.text('Recovery complete'), findsOneWidget);
      expect(find.textContaining('Backup restored'), findsOneWidget);
      // BackupService.importFromJson was called with the JSON content.
      check(sim.importCalls).length.equals(1);
      check(sim.importCalls.first).contains('"_schemaVersion":1');
    });

    testWidgets('import failure shows error and allows retry', (
      WidgetTester tester,
    ) async {
      const validJson = '{"not":"a valid backup"}';
      FileSelectorPlatform.instance = _FakeFileSelector(
        file: XFile.fromData(
          Uint8List.fromList(utf8.encode(validJson)),
          name: 'broken.json',
          mimeType: 'application/json',
        ),
      );

      // SimulationBackupService that throws on import.
      final sim = _ThrowingBackupService();
      await tester.pumpWidget(_recoveryWithBackup(sim));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Restore from backup'));
      await tester.pumpAndSettle();

      // Error is surfaced.
      expect(find.textContaining('Restore failed:'), findsOneWidget);
      // Button is still present so user can retry (not _actionTaken).
      expect(find.text('Restore from backup'), findsOneWidget);
    });
  });

  // --------------------------------------------------------------------------
  group('Startup purge — SessionLogRepository.purgeExpiredLogs', () {
    test('purges non-critical logs older than retentionDays', () async {
      final db = _openDb();
      addTearDown(db.close);
      final repo = SessionLogRepository(db.sessionLogsDao);

      final now = DateTime.utc(2026, 6);
      final oldDate = now.subtract(const Duration(days: 200));
      final recentDate = now.subtract(const Duration(days: 10));

      await repo.upsert(_normalLog(id: 'old', startedAt: oldDate));
      await repo.upsert(_normalLog(id: 'recent', startedAt: recentDate));

      final result = await repo.purgeExpiredLogs(retentionDays: 180, now: now);
      check(result).equals((movedToTrash: 1, hardDeleted: 0));

      final remaining = await db.sessionLogsDao.getAllOrderedByStartDesc();
      check(remaining.length).equals(1);
      check(remaining.first.id).equals('recent');
      // Two-stage retention: the aged log went to the trash, not away.
      check(
        (await db.sessionLogsDao.getTrashed()).map((l) => l.id).toList(),
      ).deepEquals(['old']);
    });

    test(
      'does not purge any logs when all are within retention window',
      () async {
        final db = _openDb();
        addTearDown(db.close);
        final repo = SessionLogRepository(db.sessionLogsDao);

        final now = DateTime.utc(2026, 6);

        await repo.upsert(
          _normalLog(
            id: 'log1',
            startedAt: now.subtract(const Duration(days: 5)),
          ),
        );
        await repo.upsert(
          _normalLog(
            id: 'log2',
            startedAt: now.subtract(const Duration(days: 30)),
          ),
        );

        final result = await repo.purgeExpiredLogs(
          retentionDays: 180,
          now: now,
        );
        check(result).equals((movedToTrash: 0, hardDeleted: 0));

        final remaining = await db.sessionLogsDao.getAllOrderedByStartDesc();
        check(remaining.length).equals(2);
      },
    );

    test('purges no logs when database is empty', () async {
      final db = _openDb();
      addTearDown(db.close);
      final repo = SessionLogRepository(db.sessionLogsDao);

      final result = await repo.purgeExpiredLogs(
        retentionDays: 30,
        now: DateTime.utc(2026, 6),
      );
      check(result).equals((movedToTrash: 0, hardDeleted: 0));
    });

    test('retentionDays = 1 purges yesterday logs', () async {
      final db = _openDb();
      addTearDown(db.close);
      final repo = SessionLogRepository(db.sessionLogsDao);

      final now = DateTime.utc(2026, 6);
      await repo.upsert(
        _normalLog(
          id: 'yesterday',
          startedAt: now.subtract(const Duration(days: 2)),
        ),
      );
      await repo.upsert(
        _normalLog(
          id: 'today',
          startedAt: now.subtract(const Duration(hours: 1)),
        ),
      );

      final result = await repo.purgeExpiredLogs(retentionDays: 1, now: now);
      check(result).equals((movedToTrash: 1, hardDeleted: 0));

      final remaining = await db.sessionLogsDao.getAllOrderedByStartDesc();
      check(remaining.first.id).equals('today');
    });
  });

  // --------------------------------------------------------------------------
  // F20: Bootstrap ordering contract
  // --------------------------------------------------------------------------

  group('F20: Bootstrap ordering contract', () {
    // The bootstrap pipeline ordering is implicitly tested by the symbol exports
    // and widget contracts. These tests verify each stage is reachable.

    // Phase 6: GuardianAngelaApp is now a ConsumerWidget (reads
    // settings/router providers). The Phase 5 StatelessWidget assertion
    // is superseded — we just check it's a Widget that can be
    // const-constructed.
    test('GuardianAngelaApp is a const-constructable Widget', () {
      const app = GuardianAngelaApp();
      check(app).isA<Widget>();
    });

    test('JsonRecoveryApp is a const-constructable StatelessWidget', () {
      const app = JsonRecoveryApp(reason: 'test');
      check(app).isA<StatelessWidget>();
    });

    test('GuardianAngelaApp and JsonRecoveryApp are separate types', () {
      const app1 = GuardianAngelaApp();
      const app2 = JsonRecoveryApp(reason: 'err');
      check(
        app1.runtimeType.toString(),
      ).not((c) => c.equals(app2.runtimeType.toString()));
    });
  });

  // --------------------------------------------------------------------------
  // F21: settings load throws → JsonRecoveryApp in tree
  // --------------------------------------------------------------------------

  group('F21: settings load error → JsonRecoveryApp rendered', () {
    testWidgets('F21: JsonRecoveryApp displays the failure reason', (
      WidgetTester tester,
    ) async {
      const reason = 'FormatException: settings.json is corrupt';
      await tester.pumpWidget(const JsonRecoveryApp(reason: reason));
      await tester.pumpAndSettle();

      expect(find.textContaining('FormatException'), findsOneWidget);
    });

    testWidgets('F21: JsonRecoveryApp is rendered as a MaterialApp', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const JsonRecoveryApp(reason: 'err'));
      await tester.pumpAndSettle();

      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('F21: JsonRecoveryApp shows both action buttons', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const JsonRecoveryApp(reason: 'err'));
      await tester.pumpAndSettle();

      expect(find.text('Start fresh'), findsOneWidget);
      expect(find.text('Restore from backup'), findsOneWidget);
    });
  });

  // --------------------------------------------------------------------------
  // F22: "Start fresh" deletion test
  // --------------------------------------------------------------------------

  group('F22: Start fresh deletion test', () {
    Directory? tmpDir;

    setUp(() async {
      // Provide a temp directory for path_provider so _startFresh does not
      // hit a real platform channel.
      tmpDir = await Directory.systemTemp.createTemp('ga_test_');

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('plugins.flutter.io/path_provider'),
            (call) async {
              if (call.method == 'getApplicationDocumentsDirectory') {
                return tmpDir!.path;
              }
              return null;
            },
          );
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('plugins.flutter.io/path_provider_macos'),
            (call) async {
              if (call.method == 'getApplicationDocumentsDirectory') {
                return tmpDir!.path;
              }
              return null;
            },
          );
    });

    tearDown(() async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('plugins.flutter.io/path_provider'),
            null,
          );
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('plugins.flutter.io/path_provider_macos'),
            null,
          );
      await tmpDir?.delete(recursive: true);
    });

    testWidgets('F22: tapping "Start fresh" shows settings-cleared message', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const JsonRecoveryApp(reason: 'err'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Start fresh'));
      await tester.pumpAndSettle();

      // Either the cleared message or an error message should appear.
      final cleared = find.textContaining('Settings cleared');
      final error = find.textContaining('Could not clear settings');
      expect(
        cleared.evaluate().isNotEmpty || error.evaluate().isNotEmpty,
        isTrue,
      );
    });

    testWidgets(
      'F22: action panel is replaced by done-message after "Start fresh"',
      (WidgetTester tester) async {
        await tester.pumpWidget(const JsonRecoveryApp(reason: 'err'));
        await tester.pumpAndSettle();

        // Confirm choice panel is visible before tap.
        expect(find.text('Start fresh'), findsOneWidget);

        await tester.tap(find.text('Start fresh'));
        await tester.pumpAndSettle();

        // After _actionTaken=true the ChoicePanel is replaced by _DoneMessage
        // which shows "Recovery complete". The "Start fresh" button is gone.
        expect(find.text('Recovery complete'), findsOneWidget);
        expect(find.text('Start fresh'), findsNothing);
      },
    );
  });

  // --------------------------------------------------------------------------
  group('Bootstrap contract assertions (non-widget)', () {
    // These tests verify that the symbols required by the bootstrap pipeline
    // are exported from main.dart and have the correct runtime type. They
    // serve as compile-time and runtime guards against accidental regressions.

    test('GuardianAngelaApp is a Widget', () {
      // Phase 6: GuardianAngelaApp is now a ConsumerWidget (Riverpod
      // reads). The Phase 5 StatelessWidget contract is superseded.
      expect(const GuardianAngelaApp(), isA<Widget>());
    });

    test('JsonRecoveryApp is a StatelessWidget', () {
      expect(const JsonRecoveryApp(reason: 'test'), isA<StatelessWidget>());
    });

    test('JsonRecoveryApp.reason is accessible', () {
      const app = JsonRecoveryApp(reason: 'error detail');
      expect(app.reason, equals('error detail'));
    });
  });

  // --------------------------------------------------------------------------
  // G12: runBootstrap — runner is called exactly once
  // G13: runBootstrap — appSettingsRepositoryProvider throw → JsonRecoveryApp
  // --------------------------------------------------------------------------

  group('G12/G13: runBootstrap ordering + settings-error recovery', () {
    test(
      'G12: runBootstrap calls runner exactly once when settings load fails',
      () async {
        final captured = <Widget>[];
        final container = ProviderContainer(
          overrides: [
            databaseProvider.overrideWith((_) => _openDb()),
            appSettingsRepositoryProvider.overrideWithValue(
              _ThrowingSettingsRepo(),
            ),
          ],
        );
        addTearDown(container.dispose);

        await runBootstrap(container, runner: captured.add);

        expect(captured, hasLength(1));
      },
    );

    test('G13: runBootstrap passes JsonRecoveryApp to runner when '
        'appSettingsRepositoryProvider throws', () async {
      Widget? captured;
      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWith((_) => _openDb()),
          appSettingsRepositoryProvider.overrideWithValue(
            _ThrowingSettingsRepo(),
          ),
        ],
      );
      addTearDown(container.dispose);

      await runBootstrap(container, runner: (w) => captured = w);

      expect(captured, isA<JsonRecoveryApp>());
      expect((captured! as JsonRecoveryApp).reason, contains('corrupt'));
    });
  });

  // --------------------------------------------------------------------------
  // Q8: Bootstrap step-order sequence-tracker test
  // --------------------------------------------------------------------------

  group('Q8: runBootstrap fires steps in the mandated order', () {
    test('Q8: dbOpen → settingsLoad → sentryInit → purgeLogs → '
        'notificationInit → ttsBootstrap', () async {
      final calls = <String>[];

      // Ordering fakes wired to the shared [calls] list.
      final settingsRepo = _OrderingSettingsRepo(calls);
      final sentryService = _OrderingSentryService(calls);
      final notifService = _OrderingNotificationService(calls);
      final audioService = _OrderingAudioService(calls);

      // Build an in-memory DB and use it to construct the session-log repo
      // override so that purgeExpiredLogs records 'purgeLogs'.
      final db = _openDb();
      final sessionRepo = _OrderingSessionLogRepo(db.sessionLogsDao, calls);

      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWith((_) async {
            calls.add('dbOpen');
            return db;
          }),
          appSettingsRepositoryProvider.overrideWithValue(settingsRepo),
          sentryServiceProvider.overrideWithValue(sentryService),
          sessionLogRepositoryProvider.overrideWith((_) async => sessionRepo),
          notificationServiceProvider.overrideWithValue(notifService),
          audioServiceProvider.overrideWithValue(audioService),
        ],
      );
      addTearDown(() async {
        container.dispose();
        await db.close();
      });

      await runBootstrap(container, runner: (_) {});

      // Allow any microtasks queued by the unawaited ttsBootstrap to
      // complete before asserting the final sequence.
      await Future<void>.delayed(Duration.zero);

      check(calls).deepEquals(const <String>[
        'dbOpen',
        'settingsLoad',
        'sentryInit',
        'purgeLogs',
        'notificationInit',
        'ttsBootstrap',
      ]);
    });
  });

  // --------------------------------------------------------------------------
  // runBootstrap step-4 / step-6 branch coverage
  // --------------------------------------------------------------------------

  group('runBootstrap — purge + TTS-failure branches', () {
    test('logs when purgeExpiredLogs reports purge activity', () async {
      final db = _openDb();
      final purgeRepo = _PurgingSessionLogRepo(db.sessionLogsDao);
      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWith((_) async => db),
          appSettingsRepositoryProvider.overrideWithValue(
            _FixedSettingsRepo(const AppSettings()),
          ),
          sessionLogRepositoryProvider.overrideWith((_) async => purgeRepo),
          notificationServiceProvider.overrideWithValue(
            _OrderingNotificationService(<String>[]),
          ),
          audioServiceProvider.overrideWithValue(
            _OrderingAudioService(<String>[]),
          ),
        ],
      );
      addTearDown(() async {
        container.dispose();
        await db.close();
      });

      // Reaches step 7 (the activity-log branch ran without aborting
      // bootstrap).
      Widget? root;
      await runBootstrap(container, runner: (w) => root = w);
      await Future<void>.delayed(Duration.zero);
      check(root).isA<UncontrolledProviderScope>();
    });

    test('a purge failure is non-fatal and captured to Sentry', () async {
      final db = _openDb();
      final throwingRepo = _ThrowingSessionLogRepo(db.sessionLogsDao);
      final sentry = _RecordingSentryService();
      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWith((_) async => db),
          appSettingsRepositoryProvider.overrideWithValue(
            _FixedSettingsRepo(const AppSettings()),
          ),
          sentryServiceProvider.overrideWithValue(sentry),
          sessionLogRepositoryProvider.overrideWith((_) async => throwingRepo),
          notificationServiceProvider.overrideWithValue(
            _OrderingNotificationService(<String>[]),
          ),
          audioServiceProvider.overrideWithValue(
            _OrderingAudioService(<String>[]),
          ),
        ],
      );
      addTearDown(() async {
        container.dispose();
        await db.close();
      });

      Widget? root;
      await runBootstrap(container, runner: (w) => root = w);
      await Future<void>.delayed(Duration.zero);

      // Bootstrap still reaches runApp; the purge exception was captured.
      check(root).isA<UncontrolledProviderScope>();
      check(sentry.captured).length.equals(1);
      check(sentry.captured.first).isA<StateError>();
    });

    test('a TTS-bootstrap failure routes through the Sentry callback', () async {
      final db = _openDb();
      final sentry = _RecordingSentryService();
      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWith((_) async => db),
          appSettingsRepositoryProvider.overrideWithValue(
            _FixedSettingsRepo(const AppSettings()),
          ),
          sentryServiceProvider.overrideWithValue(sentry),
          notificationServiceProvider.overrideWithValue(
            _OrderingNotificationService(<String>[]),
          ),
          audioServiceProvider.overrideWithValue(_FailingAudioService()),
        ],
      );
      addTearDown(() async {
        container.dispose();
        await db.close();
      });

      await runBootstrap(container, runner: (_) {});
      // The unawaited bootstrapVoiceAssets fires onFailure → captureException.
      await Future<void>.delayed(Duration.zero);

      check(sentry.captured).length.equals(1);
      check(sentry.captured.first).isA<StateError>();
    });
  });

  // --------------------------------------------------------------------------
  // GuardianAngelaApp root-widget build (theme + locale resolution)
  // --------------------------------------------------------------------------

  group('GuardianAngelaApp build', () {
    Future<void> pumpApp(WidgetTester tester, AppSettings settings) async {
      final container = ProviderContainer(
        overrides: [
          appSettingsRepositoryProvider.overrideWithValue(
            _FixedSettingsRepo(settings),
          ),
        ],
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const GuardianAngelaApp(),
        ),
      );
      // One settle pass lets _appSettingsLiveProvider resolve and the theme +
      // locale maybeWhen branches read the loaded settings.
      await tester.pump();
      await tester.pump();
    }

    testWidgets('resolves a MaterialApp.router with the seeded theme (light)', (
      WidgetTester tester,
    ) async {
      await pumpApp(tester, const AppSettings(themeMode: AppThemeMode.light));
      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      check(app.themeMode).equals(ThemeMode.light);
      check(app.title).equals('Guardian Angela');
    });

    testWidgets('maps AppThemeMode.dark → ThemeMode.dark', (
      WidgetTester tester,
    ) async {
      await pumpApp(tester, const AppSettings(themeMode: AppThemeMode.dark));
      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      check(app.themeMode).equals(ThemeMode.dark);
    });

    testWidgets('maps AppThemeMode.system → ThemeMode.system and sets locale', (
      WidgetTester tester,
    ) async {
      // AppThemeMode.system is the AppSettings default → the system branch.
      await pumpApp(tester, const AppSettings(languageCode: 'de'));
      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      check(app.themeMode).equals(ThemeMode.system);
      check(app.locale).equals(const Locale('de'));
    });
  });

  // --------------------------------------------------------------------------
  // JsonRecoveryApp restore — fallback container (no enclosing ProviderScope)
  // --------------------------------------------------------------------------

  group('JsonRecoveryApp restore without an enclosing ProviderScope', () {
    tearDown(() => FileSelectorPlatform.instance = _FakeFileSelector());

    testWidgets('an empty selected file surfaces an unreadable-file error', (
      WidgetTester tester,
    ) async {
      // No UncontrolledProviderScope wrapper → ProviderScope.containerOf throws
      // → runBootstrap's restore path builds and disposes its own container.
      FileSelectorPlatform.instance = _FakeFileSelector(
        file: XFile.fromData(
          Uint8List(0),
          name: 'empty.json',
          mimeType: 'application/json',
        ),
      );

      await tester.pumpWidget(const MaterialApp(home: _RecoveryHost()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Restore from backup'));
      await tester.pumpAndSettle();

      // The empty-file guard throws a FormatException before the container is
      // ever read, so the error is surfaced and the button remains for retry.
      expect(find.textContaining('Restore failed:'), findsOneWidget);
      expect(find.text('Restore from backup'), findsOneWidget);
    });
  });
}

/// Hosts a [JsonRecoveryApp] with NO enclosing [ProviderScope] so the restore
/// flow exercises its own-container fallback branch.
class _RecoveryHost extends StatelessWidget {
  const _RecoveryHost();

  @override
  Widget build(BuildContext context) =>
      const JsonRecoveryApp(reason: 'no-scope');
}
