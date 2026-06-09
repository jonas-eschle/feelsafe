/// Widget scenario WID-002 — language-switch instant rebuild (decision 43;
/// spec 07 §Coverage matrix "Language switch instant rebuild").
///
/// Proves the real localization wiring: the root `MaterialApp.locale` is driven
/// by `AppSettings.languageCode` (`main.dart:260` watches a settings provider
/// and feeds `Locale(s.languageCode)`), and the real `AppLocalizations.delegate`
/// + `supportedLocales` re-resolve every `AppLocalizations.of(context).<key>`
/// the instant the locale value changes — no app restart. This test mirrors
/// that exact production wiring: a Riverpod provider holds the language code, a
/// `ConsumerWidget` feeds it to `MaterialApp.locale`, and flipping the provider
/// value rebuilds the running tree into the new locale.
///
/// It also drives the **real** [SettingsController.setLanguage] to prove the
/// setter persists the new code to the repository (the control behind the
/// Settings → Language picker), and asserts the persisted value round-trips —
/// closing the loop from "user picks a language" to "every string rebuilds".
///
/// Assertion anchor: `homeTagline` is a stable, non-placeholder string with a
/// distinct translation in every locale —
///   en: "Your angel's got your back."
///   de: "Dein Engel passt auf dich auf."
/// so an instant flip is observable as the rendered text changing.
library;

import 'package:flutter/material.dart';

import 'package:checks/checks.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/repositories/app_settings_repository.dart';
import 'package:guardianangela/domain/models/app_settings.dart';
import 'package:guardianangela/features/settings/settings_controller.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';
import 'package:guardianangela/services/service_providers.dart';

// Known anchor strings (must match the generated getters in app_localizations_*).
const _enTagline = 'Your angel\'s got your back.';
const _deTagline = 'Dein Engel passt auf dich auf.';

// ─── Production-mirroring locale wiring ──────────────────────────────────────

/// Holds the active language code, exactly as `AppSettings.languageCode` does
/// in production. Flipping this is what the Settings language picker
/// effectively does (it saves the setting; the root widget re-reads it).
///
/// A `Notifier` (not the legacy `StateProvider`) to match the project's
/// Riverpod-3 idiom; `set` is the live mutation the locale watcher reacts to.
class _LanguageCode extends Notifier<String> {
  @override
  String build() => 'en';

  void set(String code) => state = code;
}

final _languageCodeProvider = NotifierProvider<_LanguageCode, String>(
  _LanguageCode.new,
);

/// A faithful stand-in for the root `GuardianAngelaApp`: `MaterialApp.locale`
/// follows the watched language code through the REAL `AppLocalizations`
/// delegate + supportedLocales, so a code change rebuilds the whole tree.
class _LocalizedApp extends ConsumerWidget {
  const _LocalizedApp();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final code = ref.watch(_languageCodeProvider);
    return MaterialApp(
      locale: Locale(code),
      localizationsDelegates: const <LocalizationsDelegate<Object>>[
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: const _TaglineScreen(),
    );
  }
}

/// Renders a single localized string so the test can observe it change.
class _TaglineScreen extends StatelessWidget {
  const _TaglineScreen();

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(child: Text(AppLocalizations.of(context).homeTagline)),
  );
}

// ─── In-memory settings repo (round-trips save → load) ───────────────────────

final class _RecordingSettingsRepository extends AppSettingsRepository {
  _RecordingSettingsRepository(this._value)
    : super(
        keyProvider: () async => '00' * 33,
        resolveDir: () async => throw UnimplementedError('no disk in tests'),
      );

  AppSettings _value;

  @override
  Future<AppSettings> load() async => _value;

  @override
  Future<AppSettings?> loadOrNull() async => _value;

  @override
  Future<void> save(AppSettings value) async => _value = value;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('WID-002 the en anchor strings differ from the de ones (the '
      'flip is observable)', (WidgetTester tester) async {
    // Guards the test's premise: if a future ARB edit makes the two equal, this
    // fails loudly rather than the flip test silently passing.
    final en = await AppLocalizations.delegate.load(const Locale('en'));
    final de = await AppLocalizations.delegate.load(const Locale('de'));
    check(en.homeTagline).equals(_enTagline);
    check(de.homeTagline).equals(_deTagline);
    check(en.homeTagline).not((s) => s.equals(de.homeTagline));
  });

  testWidgets(
    'WID-002 flipping the language code rebuilds the running UI into the new '
    'locale instantly (no restart) — en → de → en',
    (WidgetTester tester) async {
      late ProviderContainer container;
      await tester.pumpWidget(
        ProviderScope(
          child: Consumer(
            builder: (context, ref, _) {
              container = ProviderScope.containerOf(context);
              return const _LocalizedApp();
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Initial locale is English.
      expect(find.text(_enTagline), findsOneWidget);
      expect(find.text(_deTagline), findsNothing);

      // Switch to German — the SAME widget tree rebuilds into German.
      container.read(_languageCodeProvider.notifier).set('de');
      await tester.pumpAndSettle();
      expect(find.text(_deTagline), findsOneWidget);
      expect(find.text(_enTagline), findsNothing);

      // And back to English — proving it tracks the live value, not a one-shot.
      container.read(_languageCodeProvider.notifier).set('en');
      await tester.pumpAndSettle();
      expect(find.text(_enTagline), findsOneWidget);
      expect(find.text(_deTagline), findsNothing);
    },
  );

  testWidgets(
    'WID-002 the real SettingsController.setLanguage persists the new code '
    '(the wiring behind the Settings language picker)',
    (WidgetTester tester) async {
      // Starts at 'en' (the model default languageCode).
      final repo = _RecordingSettingsRepository(const AppSettings());
      final container = ProviderContainer(
        overrides: <Override>[
          appSettingsRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      // Mount the container in the tree so the controller's `invalidateSelf`
      // rebuilds are drained by the binding (no leaked timer on teardown).
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: SizedBox.shrink()),
        ),
      );
      await tester.pumpAndSettle();

      // The controller's async build reflects the starting locale.
      final initial = await container.read(settingsControllerProvider.future);
      check(initial.languageCode).equals('en');

      // The wired language-picker action.
      await container
          .read(settingsControllerProvider.notifier)
          .setLanguage('de');
      await tester.pumpAndSettle();

      // Persisted to the repo (so the next launch / the root locale watcher
      // reads German) and reflected in the rebuilt controller state.
      check(repo._value.languageCode).equals('de');
      final after = await container.read(settingsControllerProvider.future);
      check(after.languageCode).equals('de');
    },
  );
}
