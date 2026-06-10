/// Widget scenario WID-002 — language-switch instant rebuild (decision 43;
/// spec 07 §Coverage matrix "Language switch instant rebuild").
///
/// Proves the REAL production wiring end-to-end, with no fabricated
/// stand-ins: the actual root [GuardianAngelaApp] is pumped (real GoRouter,
/// real `AppLocalizations.delegate` + `supportedLocales`), its
/// `MaterialApp.locale` is driven by `AppSettings.languageCode` through the
/// keep-alive `appSettingsLiveProvider` in
/// `lib/services/app_state_providers.dart`, and the REAL
/// [SettingsController.setLanguage] — the wired control behind the
/// Settings → Language picker — persists the new code AND invalidates that
/// provider, so the RUNNING tree re-localizes instantly (no app restart).
///
/// The flip is observed on the first-launch onboarding welcome page, which
/// renders the anchor string without any native DB: `databaseProvider` is
/// overridden to fail fast per WID-001's teardown-stability doctrine (see
/// `onboarding_flow_widget_test.dart`'s library doc — a native in-memory
/// sqlite3 close racing the binding finalization under `--concurrency=6`
/// segfaulted the host VM). `OnboardingController._watchContacts` swallows
/// the failure; the welcome page itself never touches the DB.
///
/// Assertion anchor: `homeTagline` is a stable, non-placeholder string with a
/// distinct translation in every locale —
///   en: "Your angel's got your back."
///   de: "Dein Engel passt auf dich auf."
/// so an instant flip is observable as the rendered text changing.
library;

import 'package:flutter/material.dart';

import 'package:checks/checks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/repositories/app_settings_repository.dart';
import 'package:guardianangela/domain/models/app_settings.dart';
import 'package:guardianangela/features/settings/settings_controller.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';
import 'package:guardianangela/main.dart';
import 'package:guardianangela/services/service_providers.dart';

// Known anchor strings (must match the generated getters in app_localizations_*).
const _enTagline = 'Your angel\'s got your back.';
const _deTagline = 'Dein Engel passt auf dich auf.';
// Traditional Chinese — distinct from BOTH the zh-Simplified tagline (note the
// Traditional 守護 vs Simplified 守护) and every other locale, so a wrong-locale
// fallback (the pre-fix bug #15 resolved zh_TW to Arabic / zh-Simplified) is
// observable as the rendered text NOT being this string.
const _zhTwTagline = '你的天使,守護有你。';
const _zhTagline = '你的守护天使一直在你身边。';

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
    'WID-002 the real SettingsController.setLanguage re-localizes the LIVE '
    'root MaterialApp instantly (real controller → appSettingsLiveProvider → '
    'MaterialApp.locale) — en → de → en, no restart',
    (WidgetTester tester) async {
      // Phone-shaped viewport: the onboarding welcome page is taller than the
      // 800×600 test default in some locales.
      tester.view.physicalSize = const Size(1080, 2280);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      // Starts at 'en' (the model default languageCode). The default
      // isFirstLaunch=true routes the REAL router to the onboarding welcome
      // page, which renders the anchor without any native DB.
      final repo = _RecordingSettingsRepository(const AppSettings());
      final container = ProviderContainer(
        overrides: <Override>[
          appSettingsRepositoryProvider.overrideWithValue(repo),
          // No native DB (WID-001 doctrine — see the library doc). The only
          // reader on this route, OnboardingController._watchContacts,
          // swallows the failure and never surfaces it.
          databaseProvider.overrideWith(
            (ref) async =>
                throw StateError('WID-002: no DB on the welcome page'),
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
      await tester.pumpAndSettle();

      MaterialApp app() => tester.widget<MaterialApp>(find.byType(MaterialApp));

      // The live tree starts in English.
      check(app().locale).equals(const Locale('en'));
      expect(find.text(_enTagline), findsOneWidget);
      expect(find.text(_deTagline), findsNothing);

      // The REAL language-picker action — the SAME widget tree must rebuild
      // into German with no restart.
      await container
          .read(settingsControllerProvider.notifier)
          .setLanguage('de');
      await tester.pumpAndSettle();

      // Persisted to the repo AND applied to the running MaterialApp.
      check(repo._value.languageCode).equals('de');
      check(app().locale).equals(const Locale('de'));
      expect(find.text(_deTagline), findsOneWidget);
      expect(find.text(_enTagline), findsNothing);

      // And back to English — proving it tracks the live value, not a
      // one-shot.
      await container
          .read(settingsControllerProvider.notifier)
          .setLanguage('en');
      await tester.pumpAndSettle();
      check(app().locale).equals(const Locale('en'));
      expect(find.text(_enTagline), findsOneWidget);
      expect(find.text(_deTagline), findsNothing);
    },
  );

  testWidgets(
    'WID-002 the zh_TW Traditional tagline differs from zh-Simplified (the '
    'Traditional flip is observable, not a zh-Simplified fallback)',
    (WidgetTester tester) async {
      // Guards the premise of the zh_TW arm below: the Traditional and
      // Simplified taglines must differ, else the arm could pass on a
      // zh-Simplified fallback.
      final zhTw = await AppLocalizations.delegate.load(
        const Locale('zh', 'TW'),
      );
      final zh = await AppLocalizations.delegate.load(const Locale('zh'));
      check(zhTw.homeTagline).equals(_zhTwTagline);
      check(zh.homeTagline).equals(_zhTagline);
      check(zhTw.homeTagline).not((s) => s.equals(zh.homeTagline));
    },
  );

  testWidgets(
    'WID-002 selecting the stored code "zh_TW" resolves the LIVE root '
    'MaterialApp to Locale(zh, TW) and renders the Traditional tagline (bug '
    '#15: a single-arg Locale("zh_TW") matched no supported locale and fell '
    'back to the wrong language)',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2280);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final repo = _RecordingSettingsRepository(const AppSettings());
      final container = ProviderContainer(
        overrides: <Override>[
          appSettingsRepositoryProvider.overrideWithValue(repo),
          databaseProvider.overrideWith(
            (ref) async =>
                throw StateError('WID-002: no DB on the welcome page'),
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
      await tester.pumpAndSettle();

      MaterialApp app() => tester.widget<MaterialApp>(find.byType(MaterialApp));

      // Drive the REAL stored-language path to the underscore region code that
      // the settings picker persists for Traditional Chinese.
      await container
          .read(settingsControllerProvider.notifier)
          .setLanguage('zh_TW');
      await tester.pumpAndSettle();

      // Persisted verbatim AND resolved to the region-qualified locale — NOT a
      // single-arg Locale('zh_TW') (which would match no supported locale and
      // fall back to the wrong language).
      check(repo._value.languageCode).equals('zh_TW');
      check(app().locale).equals(const Locale('zh', 'TW'));
      // The TARGET Traditional string renders (asserting the correct target,
      // not a specific wrong fallback, so the red holds whether the pre-fix
      // fallback was ar or zh-Simplified).
      expect(find.text(_zhTwTagline), findsOneWidget);
      expect(find.text(_zhTagline), findsNothing);
      expect(find.text(_enTagline), findsNothing);
    },
  );
}
