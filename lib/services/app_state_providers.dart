// App-state providers shared by the root app, the router, and feature
// controllers.
//
// Why this file exists: `appSettingsLiveProvider` used to live in
// `lib/main.dart` and `firstLaunchProvider` in
// `lib/router/app_router.dart`, so their consumers (settings,
// backup-restore, onboarding) had to import main.dart / app_router.dart
// just for the providers — creating benign-but-ugly library import
// cycles (settings_controller → main → app_router → settings_screen →
// settings_controller; onboarding_controller → app_router →
// onboarding_screen → onboarding_controller). Hosting them in the
// services layer breaks those cycles and adds zero new layer edges:
// every consumer already depends on services/.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:guardianangela/domain/models/app_settings.dart';
import 'package:guardianangela/services/service_providers.dart';

/// Live [AppSettings] provider that re-loads from disk on demand.
///
/// `MaterialApp.router` reads the current theme + locale from here so
/// that settings changes rebuild the root widget. The provider is
/// keep-alive, so every writer that changes a field the root app
/// consumes must `ref.invalidate(appSettingsLiveProvider)` after
/// `appSettingsRepositoryProvider.save` — without that re-read the
/// change would not apply until the next cold start. Current
/// invalidators: `SettingsController.setThemeMode`,
/// `SettingsController.setLanguage`, and the backup-restore import
/// (which overwrites the whole settings singleton).
final appSettingsLiveProvider = FutureProvider<AppSettings>((ref) async {
  return ref.read(appSettingsRepositoryProvider).load();
});

/// Async provider that returns whether this is the first app launch.
///
/// Backed by `AppSettings.isFirstLaunch`. The provider is keep-alive and
/// the redirect reads its cached value, so a writer that persists a new
/// flag value must invalidate it — `OnboardingController.completeOnboarding`
/// does (invalidate + await the re-load) before `OnboardingScreen._finish`
/// navigates home; otherwise the redirect would re-read the stale `true`
/// and bounce the user straight back to /onboarding.
final firstLaunchProvider = FutureProvider<bool>((ref) async {
  final settings = await ref.read(appSettingsRepositoryProvider).load();
  return settings.isFirstLaunch;
});
