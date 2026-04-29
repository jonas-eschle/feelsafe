/// App entry point.
///
/// Initializes the Flutter binding, wraps the app in a
/// `ProviderScope`, and hands off to `GuardianAngelaApp`.
///
/// Telemetry: per Q42 (opt-in, default OFF), Sentry is initialized
/// before `runApp` only when the user has opted in. The DSN is
/// supplied at build time via `--dart-define=SENTRY_DSN=…`.
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

/// Sentry DSN (Q43). Supplied via `--dart-define=SENTRY_DSN=…` at
/// build time. Empty default keeps the source tree free of any DSN
/// literal — release builds inject the production value, debug
/// builds run with no DSN and Sentry stays disabled regardless of
/// the opt-in toggle.
const String _sentryDsn = String.fromEnvironment(
  'SENTRY_DSN',
  defaultValue: '',
);

const String _appRelease = 'guardianangela@1.0.0+1';

/// Main entry point.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // ignore: deprecated_member_use
  const storage = FlutterSecureStorage(
    // Q38: AndroidOptions(encryptedSharedPreferences: true) swaps the
    // default soft-Keystore-wrapped SharedPreferences backend for
    // AndroidX EncryptedSharedPreferences.
    // ignore: deprecated_member_use
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  // Q42: Sentry is opt-IN, default OFF. The legacy
  // `ga_telemetry_optout` storage key is being phased to a
  // `ga_telemetry_optin` key — the former meant `true=disabled`,
  // the latter means `true=enabled`. Absence of either → telemetry
  // stays off. Also fast-path: when no DSN was provided at build
  // time (debug builds), we never even read the toggle.
  final optInRaw = await storage.read(key: telemetryOptInStorageKey);
  final optedIn = optInRaw == 'true';
  final telemetryEnabled = optedIn && _sentryDsn.isNotEmpty;
  await initSentry(
    enabled: telemetryEnabled,
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
        developer.log(
          'main: NotificationService.init failed',
          error: e,
          stackTrace: s,
        );
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
Future<void> _startBatteryAlertWatcher(ProviderContainer container) async {
  try {
    final batteryRepo = container.read(batteryAlertRepositoryProvider);
    final stored = await batteryRepo.get();
    final config = stored ?? const BatteryAlertConfig();
    if (!config.enabled) return;
    final monitor = container.read(batteryMonitorServiceProvider);
    monitor.onLowBattery.listen((_) async {
      try {
        final current = (await batteryRepo.get()) ?? config;
        if (!current.enabled || current.chain.isEmpty) return;
        await container
            .read(sessionControllerProvider.notifier)
            .startBatteryAlertSession(current);
      } on Object catch (e, s) {
        developer.log(
          'battery-alert session start failed',
          error: e,
          stackTrace: s,
        );
      }
    });
    await monitor.startMonitoring(thresholdPercent: config.thresholdPercent);
  } on Object catch (e, s) {
    developer.log(
      'battery-alert watcher init failed',
      error: e,
      stackTrace: s,
    );
  }
}
