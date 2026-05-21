// Guardian Angela — application entry.
//
// Pre-alpha v3. This main.dart is the minimal Phase 0 entry point:
// it wires day-1 Sentry (per `docs/rewrite/v3-plan.md` §0 D2) around
// `runApp`, and renders a placeholder splash screen until Phase 6
// installs the real router + screens.
//
// Phase 5 will swap the placeholder splash for the real
// `GuardianAngelaApp` (Riverpod `ProviderScope` + GoRouter + the
// resolved `AppSettings.sentryEnabled` gate). For Phase 0, the Sentry
// init runs with NO DSN — the SDK is wired but stays inert until
// the user opts in via the eventual Settings → Privacy screen
// (spec 06 §"Optional Sentry telemetry").

import 'package:flutter/material.dart';

import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SentryFlutter.init((options) {
    // Phase 0: SDK wired, but no DSN — no events leave the device.
    // Phase 5 reads `AppSettings.sentryEnabled` + a real DSN here.
    options.dsn = '';
    options.tracesSampleRate = 0;
    options.sendDefaultPii = false;
  }, appRunner: () => runApp(const GuardianAngelaApp()));
}

/// Root widget. Phase 0 placeholder — Phase 5/6 replaces this with the
/// real Riverpod `ProviderScope` + GoRouter shell.
class GuardianAngelaApp extends StatelessWidget {
  const GuardianAngelaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Guardian Angela',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF131118)),
        useMaterial3: true,
      ),
      home: const _Phase0Splash(),
    );
  }
}

class _Phase0Splash extends StatelessWidget {
  const _Phase0Splash();

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
                'Pre-alpha v3 — Phase 0 skeleton.',
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
