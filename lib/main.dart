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
// Phase 6 will replace the placeholder _AppShell with real GoRouter +
// screens. The bootstrap pipeline and JsonRecoveryApp are final.

import 'dart:async' show unawaited;
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import 'package:guardianangela/domain/models/app_settings.dart';
import 'package:guardianangela/services/audio_service.dart';
import 'package:guardianangela/services/notification_service.dart';
import 'package:guardianangela/services/service_providers.dart';

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Phase 5C bootstrap uses a ProviderContainer for the pre-runApp steps so
  // that the Riverpod providers remain testable and the container is available
  // to pass into ProviderScope.parent.
  final container = ProviderContainer();

  // Step 1 — Open the encrypted Drift database. Awaited; failure is fatal
  // (the whole app depends on the database).
  final db = await container.read(databaseProvider.future);
  log('Database opened: ${db.runtimeType}', name: 'main');

  // Step 2 — Load AppSettings. If the JSON singleton is corrupt the load()
  // call throws a FormatException or StateError; catch and run recovery.
  final AppSettings settings;
  try {
    settings = await container.read(appSettingsRepositoryProvider).load();
    log(
      'AppSettings loaded (sentryEnabled=${settings.sentryEnabled})',
      name: 'main',
    );
  } catch (e, st) {
    log(
      'AppSettings load failed — launching recovery',
      error: e,
      stackTrace: st,
      name: 'main',
    );
    runApp(JsonRecoveryApp(reason: e.toString()));
    return;
  }

  // Step 3 — Initialize Sentry per user consent (D2: opt-in only).
  final sentryService = container.read(sentryServiceProvider);
  await sentryService.initialize(
    enabled: settings.sentryEnabled,
    // DSN is supplied at build time via --dart-define=SENTRY_DSN=...
    // When the define is absent the DSN is empty and Sentry stays inert.
    dsn: const String.fromEnvironment('SENTRY_DSN'),
  );

  // Step 4 — Startup log purge (B8: remove non-critical logs older than
  // AppSettings.sessionLogRetentionDays).
  try {
    final repo = await container.read(sessionLogRepositoryProvider.future);
    final deleted = await repo.purgeExpiredLogs(
      retentionDays: settings.sessionLogRetentionDays,
      now: DateTime.now().toUtc(),
    );
    if (deleted > 0) {
      log('Purged $deleted expired session logs', name: 'main');
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
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const GuardianAngelaApp(),
    ),
  );
}

// ---------------------------------------------------------------------------
// Root app widget — Phase 5 placeholder; Phase 6 installs GoRouter + screens.
// ---------------------------------------------------------------------------

/// Root application widget.
///
/// Phase 5 placeholder — Phase 6 replaces the [_AppShell] with the real
/// Riverpod `ProviderScope` + GoRouter shell.
class GuardianAngelaApp extends StatelessWidget {
  /// Creates the root application widget.
  const GuardianAngelaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Guardian Angela',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF131118)),
        useMaterial3: true,
      ),
      home: const _AppShell(),
    );
  }
}

/// Placeholder shell shown until Phase 6 installs real screens.
class _AppShell extends StatelessWidget {
  const _AppShell();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('Guardian Angela', style: textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(
                "Your angel's got your back.",
                style: textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Text(
                'Pre-alpha v3 — Phase 5 bootstrap.',
                style: textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
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
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['json'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) {
      if (!mounted) return;
      setState(() {
        _isRestoring = false;
        _statusMessage = 'No file selected.';
      });
      return;
    }

    // Step 2 — decode and import.
    try {
      final bytes = result.files.first.bytes;
      if (bytes == null || bytes.isEmpty) {
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
        final backupService =
            await resolvedContainer.read(backupServiceProvider.future);
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
                  onRestoreFromBackup:
                      _isRestoring ? null : _restoreFromBackup,
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
