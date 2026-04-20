/// App entry point.
///
/// Initializes the Flutter binding, wraps the app in a
/// `ProviderScope`, and hands off to `GuardianAngelaApp`. Phase 15
/// additionally gates telemetry: if the user has **not** opted out
/// (secure-storage fallback key `ga_telemetry_optout`), Sentry is
/// initialized against the EU data region before `runApp`.
library;

import 'package:flutter/widgets.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:guardianangela/app.dart';
import 'package:guardianangela/core/telemetry/sentry_config.dart';

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
  // TODO Phase 6: init AppDatabase before runApp.
  const storage = FlutterSecureStorage();
  final optOutRaw = await storage.read(key: telemetryOptOutStorageKey);
  final optedOut = optOutRaw == 'true';
  await initSentry(
    enabled: !optedOut,
    dsn: _sentryDsn,
    release: _appRelease,
    appRunner: () async {
      runApp(const ProviderScope(child: GuardianAngelaApp()));
    },
  );
}
