/// Widget tests for [SettingsSecurityScreen].
///
/// Follows the reference pattern from `home_screen_test.dart`:
/// 1. [_FakeSettingsSecurityController] subclasses the real controller
///    and overrides `build()` to return a canned [SettingsSecurityState].
/// 2. Navigation tests mount the screen inside a minimal [GoRouter] via
///    [_pumpWithRouter] so that `context.pushNamed(...)` resolves.
/// 3. Static-content tests use plain [pumpScreen] (no GoRouter needed).
///
/// Spec ref: `docs/spec/04-screens-navigation.md §Security Submenu`.
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:checks/checks.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:guardianangela/core/constants/route_names.dart';
import 'package:guardianangela/data/repositories/app_settings_repository.dart';
import 'package:guardianangela/domain/models/app_settings.dart';
import 'package:guardianangela/features/settings_security/remove_pin_dialog.dart';
import 'package:guardianangela/features/settings_security/settings_security_controller.dart';
import 'package:guardianangela/features/settings_security/settings_security_screen.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';
import 'package:guardianangela/services/service_providers.dart';
import '../../helpers/widget_test_helpers.dart';

String _hashDigits(String digits) =>
    sha256.convert(utf8.encode(digits)).toString();

/// In-memory [AppSettingsRepository] so [RemovePinDialog] can read a stored
/// hash without touching real storage.
class _FakeAppSettingsRepository extends AppSettingsRepository {
  _FakeAppSettingsRepository(this._current)
    : super(
        keyProvider: () async =>
            '0102030405060708090a0b0c0d0e0f'
            '101112131415161718191a1b1c1d1e1f20',
        resolveDir: () async =>
            Directory.systemTemp.createTempSync('settings_sec_test_'),
      );

  final AppSettings _current;

  @override
  Future<AppSettings> load() async => _current;
}

Future<void> _enterDigits(WidgetTester tester, List<int> digits) async {
  for (final d in digits) {
    await tester.tap(find.widgetWithText(InkWell, '$d').last);
    await tester.pump();
  }
  await tester.pumpAndSettle();
}

// ---------------------------------------------------------------------------
// Test fake
// ---------------------------------------------------------------------------

class _FakeSettingsSecurityController extends SettingsSecurityController {
  _FakeSettingsSecurityController(this._initial);

  final SettingsSecurityState _initial;

  int wrongPinThresholdCalls = 0;
  int? lastWrongPinThreshold;
  int pinTimeoutCalls = 0;
  int? lastPinTimeout;
  int deceptiveDialogCalls = 0;
  bool? lastDeceptiveDialog;
  int sessionEndBiometricCalls = 0;
  bool? lastSessionEndBiometric;
  int distressCancelBiometricCalls = 0;
  bool? lastDistressCancelBiometric;
  int clearPinCalls = 0;
  PinType? lastClearedType;

  @override
  Future<SettingsSecurityState> build() async => _initial;

  @override
  Future<void> setSessionEndBiometric(bool enabled) async {
    sessionEndBiometricCalls++;
    lastSessionEndBiometric = enabled;
    final cur = state.value;
    if (cur == null) return;
    state = AsyncData(_copyWith(cur, sessionEndBiometricEnabled: enabled));
  }

  @override
  Future<void> setDistressCancelBiometric(bool enabled) async {
    distressCancelBiometricCalls++;
    lastDistressCancelBiometric = enabled;
    final cur = state.value;
    if (cur == null) return;
    state = AsyncData(_copyWith(cur, distressCancelBiometricEnabled: enabled));
  }

  @override
  Future<void> clearPin(PinType type) async {
    clearPinCalls++;
    lastClearedType = type;
    final cur = state.value;
    if (cur == null) return;
    state = AsyncData(
      _copyWith(
        cur,
        appPinSet: type != PinType.app && cur.appPinSet,
        sessionEndPinSet: type != PinType.sessionEnd && cur.sessionEndPinSet,
        duressPinSet: type != PinType.duress && cur.duressPinSet,
      ),
    );
  }

  @override
  Future<void> setWrongPinThreshold(int v) async {
    wrongPinThresholdCalls++;
    lastWrongPinThreshold = v;
    final cur = state.value;
    if (cur == null) return;
    state = AsyncData(_copyWith(cur, wrongPinThreshold: v));
  }

  @override
  Future<void> setPinTimeout(int seconds) async {
    pinTimeoutCalls++;
    lastPinTimeout = seconds;
    final cur = state.value;
    if (cur == null) return;
    state = AsyncData(_copyWith(cur, pinTimeoutSeconds: seconds));
  }

  @override
  Future<void> setDeceptiveDialog(bool enabled) async {
    deceptiveDialogCalls++;
    lastDeceptiveDialog = enabled;
    final cur = state.value;
    if (cur == null) return;
    state = AsyncData(_copyWith(cur, deceptiveDialogEnabled: enabled));
  }

  int appBiometricCalls = 0;
  bool? lastAppBiometric;

  @override
  Future<void> setAppBiometric(bool enabled) async {
    appBiometricCalls++;
    lastAppBiometric = enabled;
    final cur = state.value;
    if (cur == null) return;
    state = AsyncData(_copyWith(cur, appBiometricEnabled: enabled));
  }

  // Helper because [SettingsSecurityState] has no copyWith.
  SettingsSecurityState _copyWith(
    SettingsSecurityState s, {
    bool? appPinSet,
    bool? sessionEndPinSet,
    bool? duressPinSet,
    int? pinTimeoutSeconds,
    int? wrongPinThreshold,
    bool? deceptiveDialogEnabled,
    bool? sessionEndBiometricEnabled,
    bool? appBiometricEnabled,
    bool? distressCancelBiometricEnabled,
  }) => SettingsSecurityState(
    appPinSet: appPinSet ?? s.appPinSet,
    sessionEndPinSet: sessionEndPinSet ?? s.sessionEndPinSet,
    duressPinSet: duressPinSet ?? s.duressPinSet,
    pinTimeoutSeconds: pinTimeoutSeconds ?? s.pinTimeoutSeconds,
    wrongPinThreshold: wrongPinThreshold ?? s.wrongPinThreshold,
    deceptiveDialogEnabled: deceptiveDialogEnabled ?? s.deceptiveDialogEnabled,
    sessionEndBiometricEnabled:
        sessionEndBiometricEnabled ?? s.sessionEndBiometricEnabled,
    appBiometricEnabled: appBiometricEnabled ?? s.appBiometricEnabled,
    distressCancelBiometricEnabled:
        distressCancelBiometricEnabled ?? s.distressCancelBiometricEnabled,
  );
}

// ---------------------------------------------------------------------------
// Observer for navigation assertions
// ---------------------------------------------------------------------------

/// Records every [Route] pushed on the GoRouter-owned [Navigator].
class _FakeNavigatorObserver extends NavigatorObserver {
  final List<Route<Object?>> pushed = <Route<Object?>>[];

  @override
  void didPush(Route<Object?> route, Route<Object?>? previousRoute) {
    pushed.add(route);
  }
}

// ---------------------------------------------------------------------------
// State factories
// ---------------------------------------------------------------------------

SettingsSecurityState _secState({
  bool appPinSet = false,
  bool sessionEndPinSet = false,
  bool duressPinSet = false,
  int pinTimeoutSeconds = 15,
  int wrongPinThreshold = 5,
  bool deceptiveDialogEnabled = false,
  bool sessionEndBiometricEnabled = false,
  bool appBiometricEnabled = false,
  bool distressCancelBiometricEnabled = false,
}) => SettingsSecurityState(
  appPinSet: appPinSet,
  sessionEndPinSet: sessionEndPinSet,
  duressPinSet: duressPinSet,
  pinTimeoutSeconds: pinTimeoutSeconds,
  wrongPinThreshold: wrongPinThreshold,
  deceptiveDialogEnabled: deceptiveDialogEnabled,
  sessionEndBiometricEnabled: sessionEndBiometricEnabled,
  appBiometricEnabled: appBiometricEnabled,
  distressCancelBiometricEnabled: distressCancelBiometricEnabled,
);

// ---------------------------------------------------------------------------
// Pump helpers
// ---------------------------------------------------------------------------

/// Plain pump — no GoRouter. Used for tests that do not tap configure buttons.
Future<void> _pump(
  WidgetTester tester, {
  required _FakeSettingsSecurityController fake,
  Locale locale = const Locale('en'),
  ThemeMode themeMode = ThemeMode.light,
  bool settle = true,
  List<Override> extraOverrides = const <Override>[],
}) => pumpScreen(
  tester,
  const SettingsSecurityScreen(),
  overrides: <Override>[
    settingsSecurityControllerProvider.overrideWith(() => fake),
    ...extraOverrides,
  ],
  locale: locale,
  themeMode: themeMode,
  settle: settle,
);

/// Wraps [SettingsSecurityScreen] in a minimal [GoRouter] so that
/// `context.pushNamed(RouteNames.pinSetup, …)` resolves at test time.
///
/// The router defines:
/// - `/settings/security` — the screen under test.
/// - `/settings/pin-setup` — stub destination used to verify navigation.
Future<void> _pumpWithRouter(
  WidgetTester tester, {
  required _FakeSettingsSecurityController fake,
  required _FakeNavigatorObserver observer,
  Locale locale = const Locale('en'),
  ThemeMode themeMode = ThemeMode.light,
}) async {
  final router = GoRouter(
    initialLocation: '/settings/security',
    observers: <NavigatorObserver>[observer],
    routes: <RouteBase>[
      GoRoute(
        path: '/settings/security',
        name: RouteNames.settingsSecurity,
        builder: (ctx, st) => const SettingsSecurityScreen(),
        routes: <RouteBase>[
          GoRoute(
            path: 'pin-setup',
            name: RouteNames.pinSetup,
            builder: (ctx, st) => const Scaffold(body: SizedBox.shrink()),
          ),
        ],
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        settingsSecurityControllerProvider.overrideWith(() => fake),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        locale: locale,
        localizationsDelegates: const <LocalizationsDelegate<Object>>[
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        themeMode: themeMode,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF131118)),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF131118),
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // ── AppBar ─────────────────────────────────────────────────────────────────

  group('SettingsSecurityScreen — AppBar', () {
    testWidgets('renders the Security title in the app bar', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(tester, fake: _FakeSettingsSecurityController(_secState()));
      expect(find.text(l10n.settingsSecurityRow), findsWidgets);
      expect(find.byType(AppBar), findsOneWidget);
    });
  });

  // ── Async states ───────────────────────────────────────────────────────────

  group('SettingsSecurityScreen — async states', () {
    testWidgets('shows loading indicator on first frame', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        fake: _FakeSettingsSecurityController(_secState()),
        settle: false,
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders body once AsyncValue resolves', (
      WidgetTester tester,
    ) async {
      await _pump(tester, fake: _FakeSettingsSecurityController(_secState()));
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('shows error text when controller emits error', (
      WidgetTester tester,
    ) async {
      // Override the provider with a controller that throws.
      await tester.pumpWidget(
        ProviderScope(
          overrides: <Override>[
            settingsSecurityControllerProvider.overrideWith(
              _ErrorController.new,
            ),
          ],
          child: const MaterialApp(
            localizationsDelegates: <LocalizationsDelegate<Object>>[
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: SettingsSecurityScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('Error:'), findsOneWidget);
    });
  });

  // ── PIN card titles ────────────────────────────────────────────────────────

  group('SettingsSecurityScreen — PIN card titles', () {
    testWidgets('renders App PIN title', (WidgetTester tester) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(tester, fake: _FakeSettingsSecurityController(_secState()));
      expect(find.text(l10n.securityAppPinTitle), findsOneWidget);
    });

    testWidgets('renders Session End PIN title', (WidgetTester tester) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(tester, fake: _FakeSettingsSecurityController(_secState()));
      expect(find.text(l10n.securitySessionEndPinTitle), findsOneWidget);
    });

    testWidgets('renders Duress PIN title', (WidgetTester tester) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(tester, fake: _FakeSettingsSecurityController(_secState()));
      // The Duress card sits below the test-viewport fold (the Session-End
      // card now carries three biometric/timeout controls); it is still laid
      // out in the non-lazy ListView, so match including offstage widgets.
      expect(
        find.text(l10n.securityDuressPinTitle, skipOffstage: false),
        findsOneWidget,
      );
    });
  });

  // ── PIN card body text ─────────────────────────────────────────────────────

  group('SettingsSecurityScreen — PIN card body text', () {
    testWidgets('renders App PIN help text', (WidgetTester tester) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(tester, fake: _FakeSettingsSecurityController(_secState()));
      expect(find.text(l10n.securityAppPinBody), findsOneWidget);
    });

    testWidgets('renders Session End PIN help text', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(tester, fake: _FakeSettingsSecurityController(_secState()));
      expect(find.text(l10n.securitySessionEndPinBody), findsOneWidget);
    });

    testWidgets('renders Duress PIN help text', (WidgetTester tester) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(tester, fake: _FakeSettingsSecurityController(_secState()));
      // Below-fold (see "renders Duress PIN title") — match offstage too.
      expect(
        find.text(l10n.securityDuressPinBody, skipOffstage: false),
        findsOneWidget,
      );
    });
  });

  // ── Set / Change button labels ─────────────────────────────────────────────

  group('SettingsSecurityScreen — Set vs Change button labels', () {
    testWidgets('App PIN shows "Set PIN" when not configured', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(tester, fake: _FakeSettingsSecurityController(_secState()));
      // Exactly one FilledButton should carry the "Set PIN" label for App PIN.
      final setButtons = find.descendant(
        of: find.byType(Card).first,
        matching: find.text(l10n.securitySetPin),
      );
      expect(setButtons, findsOneWidget);
    });

    testWidgets('App PIN shows "Change PIN" when configured', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(
        tester,
        fake: _FakeSettingsSecurityController(_secState(appPinSet: true)),
      );
      final changeButtons = find.descendant(
        of: find.byType(Card).first,
        matching: find.text(l10n.securityChangePin),
      );
      expect(changeButtons, findsOneWidget);
    });

    testWidgets('Session End PIN shows "Set PIN" when not configured', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(tester, fake: _FakeSettingsSecurityController(_secState()));
      final cards = tester.widgetList<Card>(find.byType(Card)).toList();
      final sessionEndCard = find.descendant(
        of: find.byWidget(cards[1]),
        matching: find.text(l10n.securitySetPin),
      );
      expect(sessionEndCard, findsOneWidget);
    });

    testWidgets('Session End PIN shows "Change PIN" when configured', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(
        tester,
        fake: _FakeSettingsSecurityController(
          _secState(sessionEndPinSet: true),
        ),
      );
      final cards = tester.widgetList<Card>(find.byType(Card)).toList();
      final sessionEndCard = find.descendant(
        of: find.byWidget(cards[1]),
        matching: find.text(l10n.securityChangePin),
      );
      expect(sessionEndCard, findsOneWidget);
    });

    testWidgets('Duress PIN shows "Set PIN" when not configured', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(tester, fake: _FakeSettingsSecurityController(_secState()));
      // Duress is the third card and sits (with its button) below the
      // test-viewport fold — assert presence in its Card without requiring
      // visibility (the non-lazy ListView lays all cards out).
      final duressCard = find.ancestor(
        of: find.text(l10n.securityDuressPinTitle, skipOffstage: false),
        matching: find.byType(Card, skipOffstage: false),
      );
      expect(
        find.descendant(
          of: duressCard,
          matching: find.text(l10n.securitySetPin, skipOffstage: false),
        ),
        findsOneWidget,
      );
    });

    testWidgets('Duress PIN shows "Change PIN" when configured', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(
        tester,
        fake: _FakeSettingsSecurityController(_secState(duressPinSet: true)),
      );
      // Duress is the third card and sits (with its button) below the fold —
      // assert presence in its Card without requiring visibility.
      final duressCard = find.ancestor(
        of: find.text(l10n.securityDuressPinTitle, skipOffstage: false),
        matching: find.byType(Card, skipOffstage: false),
      );
      expect(
        find.descendant(
          of: duressCard,
          matching: find.text(l10n.securityChangePin, skipOffstage: false),
        ),
        findsOneWidget,
      );
    });
  });

  // ── Navigation — configure button pushes correct route ─────────────────────

  group('SettingsSecurityScreen — navigation', () {
    testWidgets('tapping App PIN button pushes pinSetup route with type=app', (
      WidgetTester tester,
    ) async {
      final fake = _FakeSettingsSecurityController(_secState());
      final observer = _FakeNavigatorObserver();
      await _pumpWithRouter(tester, fake: fake, observer: observer);
      final l10n = await loadL10n(const Locale('en'));
      // Tap the first "Set PIN" button (App PIN card).
      await tester.tap(find.text(l10n.securitySetPin).first);
      await tester.pumpAndSettle();
      // A new route was pushed onto the navigator.
      check(observer.pushed).isNotEmpty();
    });

    testWidgets('tapping Session End PIN button pushes pinSetup route', (
      WidgetTester tester,
    ) async {
      final fake = _FakeSettingsSecurityController(_secState());
      final observer = _FakeNavigatorObserver();
      await _pumpWithRouter(tester, fake: fake, observer: observer);
      final l10n = await loadL10n(const Locale('en'));
      // The second "Set PIN" button belongs to Session End PIN.
      await tester.tap(find.text(l10n.securitySetPin).at(1));
      await tester.pumpAndSettle();
      check(observer.pushed).isNotEmpty();
    });

    testWidgets('tapping Duress PIN button pushes pinSetup route', (
      WidgetTester tester,
    ) async {
      final fake = _FakeSettingsSecurityController(_secState());
      final observer = _FakeNavigatorObserver();
      await _pumpWithRouter(tester, fake: fake, observer: observer);
      final l10n = await loadL10n(const Locale('en'));
      // The third "Set PIN" button belongs to Duress PIN — below the fold, so
      // scroll it into view before tapping.
      final duressSetPin = find
          .text(l10n.securitySetPin, skipOffstage: false)
          .at(2);
      await tester.ensureVisible(duressSetPin);
      await tester.pumpAndSettle();
      await tester.tap(duressSetPin);
      await tester.pumpAndSettle();
      check(observer.pushed).isNotEmpty();
    });

    testWidgets(
      'Change PIN button (all PINs set) still navigates to pinSetup',
      (WidgetTester tester) async {
        final fake = _FakeSettingsSecurityController(
          _secState(
            appPinSet: true,
            sessionEndPinSet: true,
            duressPinSet: true,
          ),
        );
        final observer = _FakeNavigatorObserver();
        await _pumpWithRouter(tester, fake: fake, observer: observer);
        final l10n = await loadL10n(const Locale('en'));
        await tester.tap(find.text(l10n.securityChangePin).first);
        await tester.pumpAndSettle();
        check(observer.pushed).isNotEmpty();
      },
    );
  });

  // ── Sliders ────────────────────────────────────────────────────────────────

  group('SettingsSecurityScreen — sliders', () {
    testWidgets('wrong-PIN threshold slider is present', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(tester, fake: _FakeSettingsSecurityController(_secState()));
      await tester.scrollUntilVisible(
        find.text(l10n.securityWrongPinThresholdLabel),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text(l10n.securityWrongPinThresholdLabel), findsOneWidget);
      expect(find.byType(Slider), findsWidgets);
    });

    testWidgets('PIN timeout slider is present', (WidgetTester tester) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(tester, fake: _FakeSettingsSecurityController(_secState()));
      // Timeout slider now lives inside the Session End PIN card.
      await tester.scrollUntilVisible(
        find.text(l10n.securityPinTimeoutLabel),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text(l10n.securityPinTimeoutLabel), findsOneWidget);
    });
  });

  // ── Deceptive dialog toggle ────────────────────────────────────────────────

  group('SettingsSecurityScreen — deceptive dialog toggle', () {
    testWidgets('renders the deceptive-dialog switch', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(tester, fake: _FakeSettingsSecurityController(_secState()));
      await tester.scrollUntilVisible(
        find.text(l10n.securityDeceptiveDialogToggle),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text(l10n.securityDeceptiveDialogToggle), findsOneWidget);
      // Four SwitchListTiles total: app-lock biometric + session-end
      // biometric + distress-cancel biometric + deceptive. skipOffstage:false
      // counts scrolled-off items.
      expect(
        find.byType(SwitchListTile, skipOffstage: false),
        findsNWidgets(4),
      );
    });

    testWidgets('switch is off when deceptiveDialogEnabled is false', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(tester, fake: _FakeSettingsSecurityController(_secState()));
      await tester.scrollUntilVisible(
        find.text(l10n.securityDeceptiveDialogToggle),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      final tile = tester.widget<SwitchListTile>(
        find.ancestor(
          of: find.text(l10n.securityDeceptiveDialogToggle),
          matching: find.byType(SwitchListTile),
        ),
      );
      check(tile.value).isFalse();
    });

    testWidgets('switch is on when deceptiveDialogEnabled is true', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(
        tester,
        fake: _FakeSettingsSecurityController(
          _secState(deceptiveDialogEnabled: true),
        ),
      );
      await tester.scrollUntilVisible(
        find.text(l10n.securityDeceptiveDialogToggle),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      final tile = tester.widget<SwitchListTile>(
        find.ancestor(
          of: find.text(l10n.securityDeceptiveDialogToggle),
          matching: find.byType(SwitchListTile),
        ),
      );
      check(tile.value).isTrue();
    });

    testWidgets('toggling switch calls setDeceptiveDialog', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeSettingsSecurityController(_secState());
      await _pump(tester, fake: fake);
      await tester.scrollUntilVisible(
        find.text(l10n.securityDeceptiveDialogToggle),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text(l10n.securityDeceptiveDialogToggle));
      await tester.pumpAndSettle();
      check(fake.deceptiveDialogCalls).equals(1);
      check(fake.lastDeceptiveDialog).equals(true);
    });
  });

  // ── Session-End biometric toggle ───────────────────────────────────────────

  group('SettingsSecurityScreen — session-end biometric toggle', () {
    testWidgets(
      'renders inside the Session End PIN card with the right label',
      (WidgetTester tester) async {
        final l10n = await loadL10n(const Locale('en'));
        await _pump(tester, fake: _FakeSettingsSecurityController(_secState()));
        expect(find.text(l10n.securitySessionEndPinBiometric), findsOneWidget);
      },
    );

    testWidgets('reflects state — off when sessionEndBiometricEnabled false', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(tester, fake: _FakeSettingsSecurityController(_secState()));
      final tile = tester.widget<SwitchListTile>(
        find.ancestor(
          of: find.text(l10n.securitySessionEndPinBiometric),
          matching: find.byType(SwitchListTile),
        ),
      );
      check(tile.value).isFalse();
    });

    testWidgets('toggling the switch calls setSessionEndBiometric(true)', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeSettingsSecurityController(_secState());
      await _pump(tester, fake: fake);
      await tester.tap(find.text(l10n.securitySessionEndPinBiometric));
      await tester.pumpAndSettle();
      check(fake.sessionEndBiometricCalls).equals(1);
      check(fake.lastSessionEndBiometric).equals(true);
    });
  });

  // ── Distress-cancel biometric toggle (#9) ──────────────────────────────────

  group('SettingsSecurityScreen — distress-cancel biometric toggle', () {
    testWidgets(
      'renders inside the Session End PIN card with the right label',
      (WidgetTester tester) async {
        final l10n = await loadL10n(const Locale('en'));
        await _pump(tester, fake: _FakeSettingsSecurityController(_secState()));
        expect(find.text(l10n.securityDistressCancelBiometric), findsOneWidget);
      },
    );

    testWidgets(
      'reflects state — on when distressCancelBiometricEnabled true',
      (WidgetTester tester) async {
        final l10n = await loadL10n(const Locale('en'));
        await _pump(
          tester,
          fake: _FakeSettingsSecurityController(
            _secState(distressCancelBiometricEnabled: true),
          ),
        );
        final tile = tester.widget<SwitchListTile>(
          find.ancestor(
            of: find.text(l10n.securityDistressCancelBiometric),
            matching: find.byType(SwitchListTile),
          ),
        );
        check(tile.value).isTrue();
      },
    );

    testWidgets('toggling the switch calls setDistressCancelBiometric(true)', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeSettingsSecurityController(_secState());
      await _pump(tester, fake: fake);
      await tester.tap(find.text(l10n.securityDistressCancelBiometric));
      await tester.pumpAndSettle();
      check(fake.distressCancelBiometricCalls).equals(1);
      check(fake.lastDistressCancelBiometric).equals(true);
    });
  });

  // ── App-lock biometric toggle ──────────────────────────────────────────────

  group('SettingsSecurityScreen — app-lock biometric toggle', () {
    testWidgets('renders inside the App PIN card with the right label', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(tester, fake: _FakeSettingsSecurityController(_secState()));
      expect(find.text(l10n.securityAppPinBiometric), findsOneWidget);
    });

    testWidgets('reflects state — on when appBiometricEnabled is true', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(
        tester,
        fake: _FakeSettingsSecurityController(
          _secState(appBiometricEnabled: true),
        ),
      );
      final tile = tester.widget<SwitchListTile>(
        find.ancestor(
          of: find.text(l10n.securityAppPinBiometric),
          matching: find.byType(SwitchListTile),
        ),
      );
      check(tile.value).isTrue();
    });

    testWidgets('toggling the switch calls setAppBiometric(true)', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeSettingsSecurityController(_secState());
      await _pump(tester, fake: fake);
      await tester.tap(find.text(l10n.securityAppPinBiometric));
      await tester.pumpAndSettle();
      check(fake.appBiometricCalls).equals(1);
      check(fake.lastAppBiometric).equals(true);
    });
  });

  // ── Clear / Remove PIN ─────────────────────────────────────────────────────

  group('SettingsSecurityScreen — clear PIN', () {
    testWidgets('App PIN Remove button shown only when PIN is set', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(tester, fake: _FakeSettingsSecurityController(_secState()));
      // When no PIN set, no Remove button rendered for that card.
      expect(find.text(l10n.securityRemovePin), findsNothing);
    });

    testWidgets('tapping Remove opens the verify dialog, not a one-tap wipe', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeSettingsSecurityController(_secState(appPinSet: true));
      await _pump(
        tester,
        fake: fake,
        extraOverrides: <Override>[
          appSettingsRepositoryProvider.overrideWithValue(
            _FakeAppSettingsRepository(
              const AppSettings().copyWith(appPinHash: _hashDigits('1234')),
            ),
          ),
        ],
      );
      await tester.tap(find.text(l10n.securityRemovePin).first);
      await tester.pumpAndSettle();
      // A PIN must be entered first — the PIN is NOT cleared on the tap.
      expect(find.byType(RemovePinDialog), findsOneWidget);
      check(fake.clearPinCalls).equals(0);
    });

    testWidgets('entering the correct PIN in the dialog calls clearPin', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeSettingsSecurityController(_secState(appPinSet: true));
      await _pump(
        tester,
        fake: fake,
        extraOverrides: <Override>[
          appSettingsRepositoryProvider.overrideWithValue(
            _FakeAppSettingsRepository(
              const AppSettings().copyWith(appPinHash: _hashDigits('1234')),
            ),
          ),
        ],
      );
      await tester.tap(find.text(l10n.securityRemovePin).first);
      await tester.pumpAndSettle();
      await _enterDigits(tester, <int>[1, 2, 3, 4]);
      check(fake.clearPinCalls).equals(1);
      check(fake.lastClearedType).equals(PinType.app);
    });

    testWidgets('cancelling the verify dialog leaves the PIN intact', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeSettingsSecurityController(_secState(appPinSet: true));
      await _pump(
        tester,
        fake: fake,
        extraOverrides: <Override>[
          appSettingsRepositoryProvider.overrideWithValue(
            _FakeAppSettingsRepository(
              const AppSettings().copyWith(appPinHash: _hashDigits('1234')),
            ),
          ),
        ],
      );
      await tester.tap(find.text(l10n.securityRemovePin).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.commonCancel));
      await tester.pumpAndSettle();
      check(fake.clearPinCalls).equals(0);
    });
  });

  // ── Info dialog ────────────────────────────────────────────────────────────

  group('SettingsSecurityScreen — info dialog', () {
    testWidgets('tapping the info icon opens the App PIN explanatory dialog', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(tester, fake: _FakeSettingsSecurityController(_secState()));
      // First info icon is the App PIN card.
      await tester.tap(find.byIcon(Icons.info_outline).first);
      await tester.pumpAndSettle();
      expect(find.text(l10n.securityAppPinInfo), findsOneWidget);
    });
  });

  // ── Three cards rendered ───────────────────────────────────────────────────

  group('SettingsSecurityScreen — card layout', () {
    testWidgets('renders exactly three PIN cards', (WidgetTester tester) async {
      await _pump(tester, fake: _FakeSettingsSecurityController(_secState()));
      // Three [Card] widgets — one per PIN type. The Duress card is below the
      // test-viewport fold, so count offstage widgets too.
      expect(find.byType(Card, skipOffstage: false), findsNWidgets(3));
    });

    testWidgets('three FilledButtons present (one per PIN card)', (
      WidgetTester tester,
    ) async {
      await _pump(tester, fake: _FakeSettingsSecurityController(_secState()));
      expect(find.byType(FilledButton, skipOffstage: false), findsNWidgets(3));
    });
  });

  // ── RTL ────────────────────────────────────────────────────────────────────

  group('SettingsSecurityScreen — RTL', () {
    testWidgets('renders in Arabic (RTL) without exception', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        fake: _FakeSettingsSecurityController(_secState()),
        locale: const Locale('ar'),
      );
      expect(find.byType(AppBar), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  // ── Dark mode ──────────────────────────────────────────────────────────────

  group('SettingsSecurityScreen — dark mode', () {
    testWidgets('renders without exception in dark mode', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        fake: _FakeSettingsSecurityController(_secState()),
        themeMode: ThemeMode.dark,
      );
      expect(tester.takeException(), isNull);
    });
  });

  // ── Accessibility ──────────────────────────────────────────────────────────

  group('SettingsSecurityScreen — accessibility', () {
    testWidgets('all three PIN titles are present as text for screen readers', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(tester, fake: _FakeSettingsSecurityController(_secState()));
      // All three titles are laid out (the Duress card is below the fold).
      expect(
        find.text(l10n.securityAppPinTitle, skipOffstage: false),
        findsOneWidget,
      );
      expect(
        find.text(l10n.securitySessionEndPinTitle, skipOffstage: false),
        findsOneWidget,
      );
      expect(
        find.text(l10n.securityDuressPinTitle, skipOffstage: false),
        findsOneWidget,
      );
    });

    testWidgets('SwitchListTile exposes a title for screen readers', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(tester, fake: _FakeSettingsSecurityController(_secState()));
      await tester.scrollUntilVisible(
        find.text(l10n.securityDeceptiveDialogToggle),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      // SwitchListTile title is a [Text] widget — readable by TalkBack/VoiceOver.
      expect(
        find.descendant(
          of: find.byType(SwitchListTile),
          matching: find.text(l10n.securityDeceptiveDialogToggle),
        ),
        findsOneWidget,
      );
    });
  });
}

// ---------------------------------------------------------------------------
// Error controller — always throws from build()
// ---------------------------------------------------------------------------

class _ErrorController extends SettingsSecurityController {
  @override
  Future<SettingsSecurityState> build() async => throw StateError('test error');
}
