// Guardian Angela — application entry point.
//
// Bootstrap pipeline (Stage 5C.4):
//   1. Open the encrypted Drift database (awaited — blocks runApp).
//   2. Load AppSettings from the JSON singleton (awaited).
//   3. Initialize Sentry per AppSettings.sentryEnabled (awaited).
//   4. Run startup log purge via SessionLogRepository.purgeExpiredLogs.
//   5. Initialize NotificationService channels (awaited — must run before
//      any background service starts).
//   6. Kick off bootstrapVoiceAssets() on RealAudioService (unawaited —
//      runs in the background; failures go to Sentry but never block boot).
//   7. runApp with ProviderScope.
//
// If step 2 throws (JSON corruption / decryption failure per spec 10:206
// §JSON Repository Corruption Recovery — Extra 21), the pipeline catches
// the exception and calls runApp with the minimal JsonRecoveryApp widget
// instead of the normal GuardianAngelaApp.
//
// The bootstrap pipeline and JsonRecoveryApp are final; the root app uses
// MaterialApp.router wired through `lib/router/app_router.dart`.

import 'dart:async' show unawaited;
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:file_selector/file_selector.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import 'package:guardianangela/data/repositories/app_settings_repository.dart';
import 'package:guardianangela/data/seed_data.dart';
import 'package:guardianangela/domain/enums/app_theme_mode.dart';
import 'package:guardianangela/domain/models/app_settings.dart';
import 'package:guardianangela/domain/models/emergency_numbers.dart';
import 'package:guardianangela/features/launch_gate/launch_gate_controller.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';
import 'package:guardianangela/router/app_router.dart';
import 'package:guardianangela/services/app_state_providers.dart';
import 'package:guardianangela/services/audio_service.dart';
import 'package:guardianangela/services/notification_service.dart';
import 'package:guardianangela/services/service_providers.dart';

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

// LCOV_EXCL_START — real app entry: `flutter test` never executes main(); proven on-device by integration_test/app_boot_smoke_test.dart (emulator lcov), which calls it directly
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Phase 5C bootstrap uses a ProviderContainer for the pre-runApp steps so
  // that the Riverpod providers remain testable and the container is available
  // to pass into ProviderScope.parent.
  final container = ProviderContainer();
  await runBootstrap(container);
}
// LCOV_EXCL_STOP

/// Runs the 7-step bootstrap pipeline using [container] and calls [runner]
/// (defaults to [runApp]) with the resolved root widget.
///
/// Extracted from [main] so tests can inject a fake [runner] to observe
/// which root widget is selected (G12/G13 ordering contract).
///
/// **Bootstrap order (fixed, must not be reordered):**
/// 1. Open the encrypted Drift database.
/// 2. Load AppSettings (throws → JsonRecoveryApp).
/// 3. Initialize Sentry.
/// 4. Startup log purge.
/// 5. Initialize notification channels.
/// 6. Bootstrap TTS voice assets (unawaited).
/// 7. runApp with GuardianAngelaApp.
@visibleForTesting
Future<void> runBootstrap(
  ProviderContainer container, {
  void Function(Widget) runner = runApp,
}) async {
  // Step 1 — Open the encrypted Drift database. Awaited; failure is fatal
  // (the whole app depends on the database).
  final db = await container.read(databaseProvider.future);
  log('Database opened: ${db.runtimeType}', name: 'main');

  // Step 2 — Load AppSettings. If the JSON singleton is corrupt the load()
  // call throws a FormatException or StateError; catch and run recovery.
  //
  // On a genuine first launch (no settings file on disk yet) the emergency
  // number is seeded from the device region (spec 06 §Emergency Number,
  // precedence tier 2). A returning user's value is loaded verbatim — tier 1
  // (the user's edited value) always wins and is never overwritten.
  final AppSettings settings;
  try {
    final repo = container.read(appSettingsRepositoryProvider);
    settings = await seedFirstLaunchSettings(
      repo,
      deviceLocale: Platform.localeName,
    );
    log(
      'AppSettings loaded (sentryEnabled=${settings.sentryEnabled}, '
      'emergencyCallNumber=${settings.emergencyCallNumber})',
      name: 'main',
    );
  } catch (e, st) {
    log(
      'AppSettings load failed — launching recovery',
      error: e,
      stackTrace: st,
      name: 'main',
    );
    runner(JsonRecoveryApp(reason: e.toString()));
    return;
  }

  // Seed the App-lock launch gate (spec 06 §App PIN) synchronously, before
  // runApp, so the router's first redirect already knows whether to gate —
  // no flash of app content behind the lock. Cold-start only; never re-locks.
  container
      .read(launchGateProvider.notifier)
      .lockForLaunch(appPinSet: settings.appPinHash != null);

  // Step 3 — Initialize Sentry per user consent (D2: opt-in only).
  final sentryService = container.read(sentryServiceProvider);
  await sentryService.initialize(
    enabled: settings.sentryEnabled,
    // DSN is supplied at build time via --dart-define=SENTRY_DSN=...
    // When the define is absent the DSN is empty and Sentry stays inert.
    dsn: const String.fromEnvironment('SENTRY_DSN'),
  );

  // Step 4 — Startup log purge (B8 + trash retention):
  //   * non-critical logs older than AppSettings.sessionLogRetentionDays
  //     are SOFT-deleted into the recoverable trash (spec 03:966–967)
  //   * trashed logs older than AppSettings.trashRetentionDays are
  //     hard-deleted (spec 03:970, spec 04:2455–2459).
  try {
    final repo = await container.read(sessionLogRepositoryProvider.future);
    final purge = await repo.purgeExpiredLogs(
      retentionDays: settings.sessionLogRetentionDays,
      now: DateTime.now().toUtc(),
      trashRetentionDays: settings.trashRetentionDays,
    );
    if (purge.movedToTrash > 0 || purge.hardDeleted > 0) {
      log(
        'Startup log purge: ${purge.movedToTrash} aged logs moved to '
        'trash, ${purge.hardDeleted} expired trash rows hard-deleted',
        name: 'main',
      );
    }
  } catch (e, st) {
    log(
      'Session log purge failed (non-fatal)',
      error: e,
      stackTrace: st,
      name: 'main',
    );
    await sentryService.captureException(e, st);
  }

  // Step 5 — Initialize notification channels. Must complete before any
  // background service starts (spec 05 §Initialization).
  final notificationService =
      container.read(notificationServiceProvider) as RealNotificationService;
  await notificationService.init();

  // Step 6 — Bootstrap TTS voice assets (unawaited — runs in the background;
  // a missing clip is tolerated by the fake-call step, which silently skips
  // voice playback and still rings). Failures are captured to Sentry.
  final audioService = container.read(audioServiceProvider) as RealAudioService;
  unawaited(
    audioService.bootstrapVoiceAssets(
      onFailure: (String locale, Object e, StackTrace st) {
        sentryService.captureException(e, st).ignore();
      },
    ),
  );

  // Step 7 — runApp. UncontrolledProviderScope exposes the pre-warmed
  // ProviderContainer (with the open DB and loaded settings) directly to
  // the widget tree, avoiding a redundant re-initialization on first read.
  runner(
    UncontrolledProviderScope(
      container: container,
      child: const GuardianAngelaApp(),
    ),
  );
}

/// Loads [AppSettings], seeding the emergency number on a genuine first launch.
///
/// Implements spec 06 §Emergency Number precedence:
/// 1. A returning user's persisted value (file present on disk) is returned
///    verbatim — the user's edited value always wins and is never overwritten,
///    even if it equals the GSM fallback `'112'`.
/// 2. On first launch (no settings file yet, [AppSettingsRepository.loadOrNull]
///    is `null`) the emergency number is seeded from [deviceLocale]'s region
///    via [emergencyNumberForLocale] and persisted, so the field is correct for
///    the user's country out of the box.
/// 3. An unmapped / region-less locale resolves to [kEmergencyFallback].
///
/// Throws (propagating to the caller's recovery path) only if the underlying
/// load fails with corruption — a present-but-unreadable file. The seed
/// resolution itself is total and never throws.
@visibleForTesting
Future<AppSettings> seedFirstLaunchSettings(
  AppSettingsRepository repo, {
  required String deviceLocale,
}) async {
  final AppSettings? existing = await repo.loadOrNull();
  if (existing != null) {
    // Returning user — respect the persisted value (precedence tier 1).
    return existing;
  }
  // First launch — seed from the device region (precedence tier 2/3).
  final AppSettings seeded = SeedData.defaultAppSettings(
    emergencyCallNumber: emergencyNumberForLocale(deviceLocale),
  );
  await repo.save(seeded);
  log(
    'First launch — seeded emergencyCallNumber='
    '${seeded.emergencyCallNumber} from locale "$deviceLocale"',
    name: 'main',
  );
  return seeded;
}

// ---------------------------------------------------------------------------
// Root app widget — wires MaterialApp.router to the GoRouter from
// lib/router/app_router.dart. Theme + locale follow live AppSettings.
// ---------------------------------------------------------------------------

/// Root application widget.
///
/// Wires `MaterialApp.router` to the GoRouter from
/// `lib/router/app_router.dart`. Theme follows the user's
/// `AppSettings.themeMode` preference; locale follows
/// `AppSettings.languageCode`.
class GuardianAngelaApp extends ConsumerWidget {
  /// Creates the root application widget.
  const GuardianAngelaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    final settingsAsync = ref.watch(appSettingsLiveProvider);
    final scheme = ColorScheme.fromSeed(seedColor: const Color(0xFF131118));
    final darkScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF131118),
      brightness: Brightness.dark,
    );
    return MaterialApp.router(
      title: 'Guardian Angela',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      themeMode: settingsAsync.maybeWhen(
        data: (s) => switch (s.themeMode) {
          AppThemeMode.light => ThemeMode.light,
          AppThemeMode.dark => ThemeMode.dark,
          AppThemeMode.system => ThemeMode.system,
        },
        orElse: () => ThemeMode.system,
      ),
      theme: ThemeData(colorScheme: scheme, useMaterial3: true),
      darkTheme: ThemeData(colorScheme: darkScheme, useMaterial3: true),
      locale: settingsAsync.maybeWhen(
        data: (s) => Locale(s.languageCode),
        orElse: () => null,
      ),
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}

// ---------------------------------------------------------------------------
// JSON Repository Corruption Recovery App (spec 10:206 — Extra 21)
// ---------------------------------------------------------------------------

/// Minimal recovery widget shown when the JSON singleton repositories are
/// corrupt or unreadable (spec 10:206 §JSON Repository Corruption Recovery
/// Extra 21).
///
/// Offers two actions:
/// - **Start fresh** — deletes the `json_store` directory and all its
///   encrypted JSON files, then re-seeds defaults on the next launch.
/// - **Restore from backup** — opens the OS file picker, validates the
///   selected JSON via [BackupServiceProtocol.importFromJson], and
///   instructs the user to relaunch on success.
///
/// Neither action re-starts the bootstrap pipeline; both finish with an
/// instruction to relaunch the app so it can boot into a healthy state.
class JsonRecoveryApp extends StatelessWidget {
  /// Creates the recovery application.
  ///
  /// [reason] is the human-readable error message shown for diagnostics.
  const JsonRecoveryApp({super.key, required this.reason});

  /// Human-readable description of the corruption or load error.
  final String reason;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Guardian Angela — Recovery',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF131118)),
        useMaterial3: true,
      ),
      home: _RecoveryScreen(reason: reason),
    );
  }
}

/// Recovery screen body.
class _RecoveryScreen extends StatefulWidget {
  const _RecoveryScreen({required this.reason});

  final String reason;

  @override
  State<_RecoveryScreen> createState() => _RecoveryScreenState();
}

class _RecoveryScreenState extends State<_RecoveryScreen> {
  bool _actionTaken = false;
  bool _isRestoring = false;
  String? _statusMessage;

  Future<void> _startFresh() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final jsonStoreDir = Directory('${dir.path}/json_store');
      if (jsonStoreDir.existsSync()) {
        await jsonStoreDir.delete(recursive: true);
        log('json_store deleted by recovery flow', name: 'JsonRecoveryApp');
      }
      if (!mounted) return;
      setState(() {
        _actionTaken = true;
        _statusMessage =
            'Settings cleared. Please close and relaunch the app to '
            'restore defaults.';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _statusMessage = 'Could not clear settings: $e';
      });
    }
  }

  Future<void> _restoreFromBackup() async {
    setState(() => _isRestoring = true);

    // Step 1 — let the user pick a JSON file.
    const XTypeGroup typeGroup = XTypeGroup(
      label: 'JSON',
      extensions: <String>['json'],
    );
    final XFile? file = await openFile(
      acceptedTypeGroups: <XTypeGroup>[typeGroup],
    );

    if (file == null) {
      if (!mounted) return;
      setState(() {
        _isRestoring = false;
        _statusMessage = 'No file selected.';
      });
      return;
    }

    // Step 2 — decode and import.
    try {
      final Uint8List bytes = await file.readAsBytes();
      if (bytes.isEmpty) {
        throw const FormatException('Selected file is empty or unreadable.');
      }
      final jsonString = utf8.decode(bytes);

      // Prefer the Riverpod container from the nearest ProviderScope (present
      // in tests via UncontrolledProviderScope and in production if the
      // recovery widget is wrapped). Fall back to a fresh ProviderContainer
      // when no scope is found (normal production path — the encrypted DB may
      // still fail to open if the key is corrupt; the catch below surfaces
      // that error so the user can try "Start fresh" instead).
      if (!mounted) return;
      ProviderContainer? ownedContainer;
      ProviderContainer resolvedContainer;
      try {
        resolvedContainer = ProviderScope.containerOf(context);
      } catch (_) {
        ownedContainer = ProviderContainer();
        resolvedContainer = ownedContainer;
      }
      try {
        final backupService = await resolvedContainer.read(
          backupServiceProvider.future,
        );
        await backupService.importFromJson(jsonString);
      } finally {
        ownedContainer?.dispose();
      }

      if (!mounted) return;
      setState(() {
        _isRestoring = false;
        _actionTaken = true;
        _statusMessage = 'Backup restored. Please relaunch the app.';
      });
    } catch (e) {
      log('Restore from backup failed: $e', name: 'JsonRecoveryApp');
      if (!mounted) return;
      setState(() {
        _isRestoring = false;
        // Do NOT set _actionTaken so the user can retry.
        _statusMessage = 'Restore failed: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data Recovery')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _actionTaken
              ? _DoneMessage(statusMessage: _statusMessage ?? '')
              : _ChoicePanel(
                  reason: widget.reason,
                  onStartFresh: _statusMessage == null ? _startFresh : null,
                  onRestoreFromBackup: _isRestoring ? null : _restoreFromBackup,
                  isRestoring: _isRestoring,
                  statusMessage: _statusMessage,
                ),
        ),
      ),
    );
  }
}

/// Shown after the "Start fresh" action completes.
class _DoneMessage extends StatelessWidget {
  const _DoneMessage({required this.statusMessage});

  final String statusMessage;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Recovery complete', style: textTheme.titleLarge),
        const SizedBox(height: 16),
        Text(statusMessage, style: textTheme.bodyMedium),
      ],
    );
  }
}

/// Action choices panel for the recovery screen.
class _ChoicePanel extends StatelessWidget {
  const _ChoicePanel({
    required this.reason,
    required this.onStartFresh,
    required this.onRestoreFromBackup,
    required this.isRestoring,
    this.statusMessage,
  });

  final String reason;
  final VoidCallback? onStartFresh;

  /// Callback invoked when the user taps "Restore from backup".
  ///
  /// Set to `null` while a restore is in progress to prevent double-taps.
  final VoidCallback? onRestoreFromBackup;

  /// Whether a restore is currently in progress (shows a progress indicator
  /// inside the button label).
  final bool isRestoring;
  final String? statusMessage;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Data Recovery', style: textTheme.titleLarge),
        const SizedBox(height: 12),
        Text(
          'Guardian Angela could not read its settings. '
          'This can happen after an OS update, storage corruption, '
          'or an unexpected shutdown.',
          style: textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Technical detail: $reason',
          style: textTheme.bodySmall?.copyWith(color: colorScheme.error),
        ),
        const SizedBox(height: 32),
        FilledButton.icon(
          onPressed: onStartFresh,
          icon: const Icon(Icons.refresh),
          label: const Text('Start fresh'),
        ),
        const SizedBox(height: 8),
        FilledButton.icon(
          onPressed: onRestoreFromBackup,
          icon: const Icon(Icons.upload_file),
          label: isRestoring
              ? const _RestoreProgress()
              : const Text('Restore from backup'),
        ),
        if (statusMessage != null) ...<Widget>[
          const SizedBox(height: 24),
          Text(statusMessage!, style: textTheme.bodyMedium),
        ],
      ],
    );
  }
}

/// Small inline progress indicator shown inside the restore button while
/// a file is being picked and imported.
class _RestoreProgress extends StatelessWidget {
  const _RestoreProgress();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        SizedBox(width: 8),
        Text('Restoring…'),
      ],
    );
  }
}
