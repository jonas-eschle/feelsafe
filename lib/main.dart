/// App entry point.
///
/// Initializes the Flutter binding, wraps the app in a
/// `ProviderScope`, and hands off to `GuardianAngelaApp`. Phase 15
/// additionally gates telemetry: if the user has **not** opted out
/// (secure-storage fallback key `ga_telemetry_optout`), Sentry is
/// initialized against the EU data region before `runApp`.
///
/// Fix for bugs.json Warn (main.dart init):
/// * Initializes [AppDatabase] (SQLCipher passphrase, first-launch
///   schema creation) before `runApp` so any provider reading it on
///   first frame finds a live DB.
/// * Initializes [NotificationService] so Android channels exist
///   before the first `show*` call, and the action-tap callback is
///   registered even on cold start.
/// * Starts [BatteryMonitorService] and, when it fires `onLowBattery`,
///   invokes `SessionController.startBatteryAlertSession` — closes
///   bugs.json Bug #2.
library;

import 'dart:developer' as developer;

import 'package:flutter/widgets.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:guardianangela/app.dart';
import 'package:guardianangela/core/telemetry/sentry_config.dart';
import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/domain/models/battery_alert_config.dart';
import 'package:guardianangela/features/session/session_controller.dart';
import 'package:guardianangela/services/service_providers.dart';

export 'package:guardianangela/app.dart' show GuardianAngelaApp;

/// Sentry DSN for the Guardian Angela Flutter app (EU host).
///
/// TODO(release-owner): replace the placeholder project id with the
/// real production project id before the first public build. The
/// host MUST end with `.de.sentry.io` — [initSentry] rejects
/// anything else.
const String _sentryDsn =
    'https://00000000000000000000000000000000@o0.ingest.de.sentry.io/0';

const String _appRelease = 'guardianangela@1.0.0+1';

/// Main entry point.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const storage = FlutterSecureStorage();
  final optOutRaw = await storage.read(key: telemetryOptOutStorageKey);
  final optedOut = optOutRaw == 'true';
  await initSentry(
    enabled: !optedOut,
    dsn: _sentryDsn,
    release: _appRelease,
    appRunner: () async {
      final container = ProviderContainer();
      // Fix for bugs.json Warn (AppDatabase never initialised): force
      // the Drift/SQLCipher DB open so the file is created on first
      // launch and any consumer provider finds a live handle.
      try {
        final db = container.read(appDatabaseProvider);
        await db.customStatement('SELECT 1');
      } on Object catch (e, s) {
        developer.log(
          'main: AppDatabase warm-up failed',
          error: e,
          stackTrace: s,
        );
      }
      // Fix for bugs.json Warn (NotificationService.init never
      // called): register Android channels before the first show*().
      try {
        await container.read(notificationServiceProvider).init();
      } on Object catch (e, s) {
        developer.log('main: NotificationService.init failed',
            error: e, stackTrace: s);
      }
      // Fix for bugs.json Bug #2 (battery-alert monitor never
      // subscribed): wire a top-level listener that, on every low-
      // battery crossing, starts a background battery-alert session
      // using the user's configured BatteryAlertConfig.
      await _startBatteryAlertWatcher(container);
      runApp(
        UncontrolledProviderScope(
          container: container,
          child: const GuardianAngelaApp(),
        ),
      );
    },
  );
}

/// Subscribes the top-level [BatteryMonitorService] to trigger a
/// background battery-alert session when the threshold is crossed.
///
/// Fix for bugs.json Bug #2: previously nothing in `lib/` subscribed
/// to `onLowBattery`, so `SessionController.startBatteryAlertSession`
/// was unreachable. This watcher starts monitoring with the user's
/// configured threshold and, on fire, invokes the controller.
Future<void> _startBatteryAlertWatcher(ProviderContainer container) async {
  try {
    final batteryRepo = container.read(batteryAlertRepositoryProvider);
    final stored = await batteryRepo.get();
    final config = stored ?? const BatteryAlertConfig();
    if (!config.enabled) return;
    final monitor = container.read(batteryMonitorServiceProvider);
    // Subscribe BEFORE start so we don't miss an immediate crossing.
    monitor.onLowBattery.listen((_) async {
      try {
        final current = (await batteryRepo.get()) ?? config;
        if (!current.enabled || current.chain.isEmpty) return;
        await container
            .read(sessionControllerProvider.notifier)
            .startBatteryAlertSession(current);
      } on Object catch (e, s) {
        developer.log('battery-alert session start failed',
            error: e, stackTrace: s);
      }
    });
    await monitor.startMonitoring(thresholdPercent: config.thresholdPercent);
  } on Object catch (e, s) {
    developer.log('battery-alert watcher init failed',
        error: e, stackTrace: s);
  }
}
