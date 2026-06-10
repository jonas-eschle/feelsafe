/// Widget tests for [SettingsStealthScreen].
///
/// Follows the reference pattern from
/// `test/features/home/home_screen_test.dart`:
/// 1. [_FakeStealthController] subclasses [SettingsStealthController] and
///    overrides `build()` to return a canned [SettingsStealthState].
/// 2. Each test calls `pumpScreen(tester, const SettingsStealthScreen(), …)`.
/// 3. Assertions use `find.byType`, `find.text`, l10n keys, and the
///    call-counter fields on the fake.
///
/// Spec refs:
/// - `docs/spec/04-screens-navigation.md §SettingsStealthScreen`
/// - `docs/spec/06-stealth.md §StealthConfig`
library;

import 'package:flutter/material.dart';

import 'package:checks/checks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/core/widgets/info_icon_button.dart';
import 'package:guardianangela/domain/enums/stealth_icon_preset.dart';
import 'package:guardianangela/domain/enums/stealth_timer_display.dart';
import 'package:guardianangela/domain/models/stealth_config.dart';
import 'package:guardianangela/features/settings_stealth/settings_stealth_controller.dart';
import 'package:guardianangela/features/settings_stealth/settings_stealth_screen.dart';
import '../../helpers/widget_test_helpers.dart';

// ---------------------------------------------------------------------------
// Test fakes
// ---------------------------------------------------------------------------

class _FakeStealthController extends SettingsStealthController {
  _FakeStealthController(this._initial);

  final SettingsStealthState _initial;

  int setEnabledCalls = 0;
  bool? lastEnabledValue;

  int setFakeNameCalls = 0;
  String? lastFakeName;

  int setNotificationDisguiseCalls = 0;
  bool? lastNotificationDisguiseValue;

  int setSessionScreenStealthCalls = 0;
  bool? lastSessionScreenStealthValue;

  int setTimerDisplayCalls = 0;
  StealthTimerDisplay? lastTimerDisplay;

  int setFakeIconCalls = 0;
  StealthIconPreset? lastFakeIcon;

  int setLockTaskModeCalls = 0;
  bool? lastLockTaskMode;

  @override
  Future<SettingsStealthState> build() async => _initial;

  @override
  Future<void> setFakeIcon(StealthIconPreset preset) async {
    setFakeIconCalls++;
    lastFakeIcon = preset;
    final current = state.value;
    if (current == null) return;
    state = AsyncData(
      SettingsStealthState(config: current.config.copyWith(fakeIcon: preset)),
    );
  }

  @override
  Future<void> setLockTaskMode(bool v) async {
    setLockTaskModeCalls++;
    lastLockTaskMode = v;
    final current = state.value;
    if (current == null) return;
    state = AsyncData(
      SettingsStealthState(config: current.config.copyWith(lockTaskMode: v)),
    );
  }

  @override
  Future<void> setEnabled(bool v) async {
    setEnabledCalls++;
    lastEnabledValue = v;
    final current = state.value;
    if (current == null) return;
    state = AsyncData(
      SettingsStealthState(config: current.config.copyWith(enabled: v)),
    );
  }

  @override
  Future<void> setFakeName(String name) async {
    setFakeNameCalls++;
    lastFakeName = name;
    final current = state.value;
    if (current == null) return;
    state = AsyncData(
      SettingsStealthState(config: current.config.copyWith(fakeName: name)),
    );
  }

  @override
  Future<void> setNotificationDisguise(bool v) async {
    setNotificationDisguiseCalls++;
    lastNotificationDisguiseValue = v;
    final current = state.value;
    if (current == null) return;
    state = AsyncData(
      SettingsStealthState(
        config: current.config.copyWith(notificationDisguise: v),
      ),
    );
  }

  @override
  Future<void> setSessionScreenStealth(bool v) async {
    setSessionScreenStealthCalls++;
    lastSessionScreenStealthValue = v;
    final current = state.value;
    if (current == null) return;
    state = AsyncData(
      SettingsStealthState(
        config: current.config.copyWith(sessionScreenStealth: v),
      ),
    );
  }

  @override
  Future<void> setTimerDisplay(StealthTimerDisplay d) async {
    setTimerDisplayCalls++;
    lastTimerDisplay = d;
    final current = state.value;
    if (current == null) return;
    state = AsyncData(
      SettingsStealthState(config: current.config.copyWith(timerDisplay: d)),
    );
  }
}

// ---------------------------------------------------------------------------
// Test data factories
// ---------------------------------------------------------------------------

/// Builds a [SettingsStealthState] with configurable fields.
///
/// Defaults mirror [StealthConfig] defaults: enabled=false, fakeName='Music',
/// notificationDisguise=true, sessionScreenStealth=true,
/// timerDisplay=normal.
SettingsStealthState _stateWith({
  bool enabled = false,
  String fakeName = 'Music',
  StealthIconPreset fakeIcon = StealthIconPreset.music,
  bool notificationDisguise = true,
  bool sessionScreenStealth = true,
  StealthTimerDisplay timerDisplay = StealthTimerDisplay.normal,
  bool lockTaskMode = false,
}) => SettingsStealthState(
  config: StealthConfig(
    enabled: enabled,
    fakeName: fakeName,
    fakeIcon: fakeIcon,
    notificationDisguise: notificationDisguise,
    sessionScreenStealth: sessionScreenStealth,
    timerDisplay: timerDisplay,
    lockTaskMode: lockTaskMode,
  ),
);

/// Builds the override list for a given fake controller.
List<Override> _overrides(_FakeStealthController fake) => <Override>[
  settingsStealthControllerProvider.overrideWith(() => fake),
];

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // -------------------------------------------------------------------------
  // App bar
  // -------------------------------------------------------------------------
  group('SettingsStealthScreen — AppBar', () {
    testWidgets('shows the Stealth title in the app bar', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const SettingsStealthScreen(),
        overrides: _overrides(_FakeStealthController(_stateWith())),
      );
      expect(find.text(l10n.settingsStealthRow), findsOneWidget);
    });

    testWidgets('renders an AppBar widget', (WidgetTester tester) async {
      await pumpScreen(
        tester,
        const SettingsStealthScreen(),
        overrides: _overrides(_FakeStealthController(_stateWith())),
      );
      expect(find.byType(AppBar), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  // Async states
  // -------------------------------------------------------------------------
  group('SettingsStealthScreen — async states', () {
    testWidgets('shows CircularProgressIndicator while loading', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        const SettingsStealthScreen(),
        overrides: _overrides(_FakeStealthController(_stateWith())),
        settle: false,
      );
      // First frame: AsyncNotifier is still building.
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('hides CircularProgressIndicator after data resolves', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        const SettingsStealthScreen(),
        overrides: _overrides(_FakeStealthController(_stateWith())),
      );
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('shows error text when controller emits an error', (
      WidgetTester tester,
    ) async {
      final fake = _FakeStealthController(_stateWith());
      await pumpScreen(
        tester,
        const SettingsStealthScreen(),
        overrides: _overrides(fake),
        settle: false,
      );
      // Inject an error after the widget is mounted.
      fake.state = AsyncError(Exception('db fail'), StackTrace.empty);
      await tester.pumpAndSettle();
      expect(find.textContaining('Error:'), findsOneWidget);
      expect(find.textContaining('db fail'), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  // Master stealth toggle
  // -------------------------------------------------------------------------
  group('SettingsStealthScreen — enable toggle', () {
    testWidgets('renders the enable-stealth SwitchListTile', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const SettingsStealthScreen(),
        overrides: _overrides(_FakeStealthController(_stateWith())),
      );
      expect(find.text(l10n.stealthEnabledLabel), findsOneWidget);
    });

    testWidgets('toggle is OFF when enabled=false', (
      WidgetTester tester,
    ) async {
      // enabled defaults to false — no explicit arg needed.
      await pumpScreen(
        tester,
        const SettingsStealthScreen(),
        overrides: _overrides(_FakeStealthController(_stateWith())),
      );
      final sw = tester.widget<Switch>(find.byType(Switch).first);
      check(sw.value).isFalse();
    });

    testWidgets('toggle is ON when enabled=true', (WidgetTester tester) async {
      await pumpScreen(
        tester,
        const SettingsStealthScreen(),
        overrides: _overrides(
          _FakeStealthController(_stateWith(enabled: true)),
        ),
      );
      final sw = tester.widget<Switch>(find.byType(Switch).first);
      check(sw.value).isTrue();
    });

    testWidgets('tapping the toggle calls setEnabled(true)', (
      WidgetTester tester,
    ) async {
      // Start with default: enabled=false.
      final fake = _FakeStealthController(_stateWith());
      await pumpScreen(
        tester,
        const SettingsStealthScreen(),
        overrides: _overrides(fake),
      );
      await tester.tap(find.byType(Switch).first);
      await tester.pumpAndSettle();
      check(fake.setEnabledCalls).equals(1);
      check(fake.lastEnabledValue).equals(true);
    });

    testWidgets('tapping the toggle calls setEnabled(false) when ON', (
      WidgetTester tester,
    ) async {
      final fake = _FakeStealthController(_stateWith(enabled: true));
      await pumpScreen(
        tester,
        const SettingsStealthScreen(),
        overrides: _overrides(fake),
      );
      await tester.tap(find.byType(Switch).first);
      await tester.pumpAndSettle();
      check(fake.setEnabledCalls).equals(1);
      check(fake.lastEnabledValue).equals(false);
    });
  });

  // -------------------------------------------------------------------------
  // Conditional sub-options — hidden when disabled
  // -------------------------------------------------------------------------
  group('SettingsStealthScreen — stealth disabled hides sub-options', () {
    testWidgets('fake name tile is absent when stealth is disabled', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      // Default enabled=false.
      await pumpScreen(
        tester,
        const SettingsStealthScreen(),
        overrides: _overrides(_FakeStealthController(_stateWith())),
      );
      expect(find.text(l10n.stealthFakeNameLabel), findsNothing);
    });

    testWidgets(
      'notification disguise tile is absent when stealth is disabled',
      (WidgetTester tester) async {
        final l10n = await loadL10n(const Locale('en'));
        await pumpScreen(
          tester,
          const SettingsStealthScreen(),
          overrides: _overrides(_FakeStealthController(_stateWith())),
        );
        expect(find.text(l10n.stealthNotificationDisguiseLabel), findsNothing);
      },
    );

    testWidgets(
      'session screen stealth tile is absent when stealth is disabled',
      (WidgetTester tester) async {
        final l10n = await loadL10n(const Locale('en'));
        await pumpScreen(
          tester,
          const SettingsStealthScreen(),
          overrides: _overrides(_FakeStealthController(_stateWith())),
        );
        expect(find.text(l10n.stealthSessionScreenLabel), findsNothing);
      },
    );

    testWidgets('timer display tile is absent when stealth is disabled', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const SettingsStealthScreen(),
        overrides: _overrides(_FakeStealthController(_stateWith())),
      );
      expect(find.text(l10n.stealthTimerDisplayLabel), findsNothing);
    });
  });

  // -------------------------------------------------------------------------
  // Fake name tile
  // -------------------------------------------------------------------------
  group('SettingsStealthScreen — fake name', () {
    testWidgets(
      'fake name tile shows current name as subtitle when stealth enabled',
      (WidgetTester tester) async {
        final l10n = await loadL10n(const Locale('en'));
        await pumpScreen(
          tester,
          const SettingsStealthScreen(),
          overrides: _overrides(
            _FakeStealthController(
              _stateWith(enabled: true, fakeName: 'Weather App'),
            ),
          ),
        );
        expect(find.text(l10n.stealthFakeNameLabel), findsOneWidget);
        expect(find.text('Weather App'), findsOneWidget);
      },
    );

    testWidgets('tapping fake name tile opens an AlertDialog', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      // fakeName is default 'Music' — omit the redundant arg.
      await pumpScreen(
        tester,
        const SettingsStealthScreen(),
        overrides: _overrides(
          _FakeStealthController(_stateWith(enabled: true)),
        ),
      );
      await tester.tap(find.text(l10n.stealthFakeNameLabel));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets('dialog pre-fills the current fake name', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const SettingsStealthScreen(),
        overrides: _overrides(
          _FakeStealthController(
            _stateWith(enabled: true, fakeName: 'Podcast'),
          ),
        ),
      );
      await tester.tap(find.text(l10n.stealthFakeNameLabel));
      await tester.pumpAndSettle();
      final tf = tester.widget<TextField>(find.byType(TextField));
      check(tf.controller!.text).equals('Podcast');
    });

    testWidgets('dialog Save button calls setFakeName with entered text', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeStealthController(_stateWith(enabled: true));
      await pumpScreen(
        tester,
        const SettingsStealthScreen(),
        overrides: _overrides(fake),
      );
      await tester.tap(find.text(l10n.stealthFakeNameLabel));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Notes');
      await tester.tap(find.text(l10n.commonSave));
      await tester.pumpAndSettle();
      check(fake.setFakeNameCalls).equals(1);
      check(fake.lastFakeName).equals('Notes');
    });

    testWidgets('dialog Cancel button does NOT call setFakeName', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeStealthController(_stateWith(enabled: true));
      await pumpScreen(
        tester,
        const SettingsStealthScreen(),
        overrides: _overrides(fake),
      );
      await tester.tap(find.text(l10n.stealthFakeNameLabel));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Ignored');
      await tester.tap(find.text(l10n.commonCancel));
      await tester.pumpAndSettle();
      check(fake.setFakeNameCalls).equals(0);
    });

    testWidgets('dialog dismisses after Save is tapped', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const SettingsStealthScreen(),
        overrides: _overrides(
          _FakeStealthController(_stateWith(enabled: true)),
        ),
      );
      await tester.tap(find.text(l10n.stealthFakeNameLabel));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.commonSave));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
    });
  });

  // -------------------------------------------------------------------------
  // Notification disguise toggle
  // -------------------------------------------------------------------------
  group('SettingsStealthScreen — notification disguise toggle', () {
    testWidgets('notification disguise is visible when stealth enabled', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      // notificationDisguise defaults to true — no explicit arg needed.
      await pumpScreen(
        tester,
        const SettingsStealthScreen(),
        overrides: _overrides(
          _FakeStealthController(_stateWith(enabled: true)),
        ),
      );
      expect(find.text(l10n.stealthNotificationDisguiseLabel), findsOneWidget);
    });

    testWidgets(
      'notification disguise switch is ON when notificationDisguise=true',
      (WidgetTester tester) async {
        await pumpScreen(
          tester,
          const SettingsStealthScreen(),
          overrides: _overrides(
            _FakeStealthController(_stateWith(enabled: true)),
          ),
        );
        // Switches: index 0 = master enable, index 1 = notifDisguise.
        final sw = tester.widgetList<Switch>(find.byType(Switch)).elementAt(1);
        check(sw.value).isTrue();
      },
    );

    testWidgets(
      'notification disguise switch is OFF when notificationDisguise=false',
      (WidgetTester tester) async {
        await pumpScreen(
          tester,
          const SettingsStealthScreen(),
          overrides: _overrides(
            _FakeStealthController(
              _stateWith(enabled: true, notificationDisguise: false),
            ),
          ),
        );
        final sw = tester.widgetList<Switch>(find.byType(Switch)).elementAt(1);
        check(sw.value).isFalse();
      },
    );

    testWidgets('tapping toggle calls setNotificationDisguise(false)', (
      WidgetTester tester,
    ) async {
      // notificationDisguise defaults to true.
      final fake = _FakeStealthController(_stateWith(enabled: true));
      await pumpScreen(
        tester,
        const SettingsStealthScreen(),
        overrides: _overrides(fake),
      );
      await tester.tap(find.byType(Switch).at(1));
      await tester.pumpAndSettle();
      check(fake.setNotificationDisguiseCalls).equals(1);
      check(fake.lastNotificationDisguiseValue).equals(false);
    });
  });

  // -------------------------------------------------------------------------
  // Session screen stealth toggle
  // -------------------------------------------------------------------------
  group('SettingsStealthScreen — session screen stealth toggle', () {
    testWidgets('session screen stealth is visible when stealth enabled', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      // sessionScreenStealth defaults to true.
      await pumpScreen(
        tester,
        const SettingsStealthScreen(),
        overrides: _overrides(
          _FakeStealthController(_stateWith(enabled: true)),
        ),
      );
      expect(find.text(l10n.stealthSessionScreenLabel), findsOneWidget);
    });

    testWidgets('tapping toggle calls setSessionScreenStealth(false)', (
      WidgetTester tester,
    ) async {
      // sessionScreenStealth defaults to true — no explicit arg needed.
      final fake = _FakeStealthController(_stateWith(enabled: true));
      await pumpScreen(
        tester,
        const SettingsStealthScreen(),
        overrides: _overrides(fake),
      );
      // Switches: 0=enable, 1=notifDisguise, 2=sessionScreen.
      await tester.tap(find.byType(Switch).at(2));
      await tester.pumpAndSettle();
      check(fake.setSessionScreenStealthCalls).equals(1);
      check(fake.lastSessionScreenStealthValue).equals(false);
    });
  });

  // -------------------------------------------------------------------------
  // Timer display dropdown
  // -------------------------------------------------------------------------
  group('SettingsStealthScreen — timer display dropdown', () {
    testWidgets('timer display label is visible when stealth enabled', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      // timerDisplay defaults to normal.
      await pumpScreen(
        tester,
        const SettingsStealthScreen(),
        overrides: _overrides(
          _FakeStealthController(_stateWith(enabled: true)),
        ),
      );
      expect(find.text(l10n.stealthTimerDisplayLabel), findsOneWidget);
    });

    testWidgets('dropdown shows Normal when timerDisplay=normal', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      // timerDisplay defaults to normal — no explicit arg.
      await pumpScreen(
        tester,
        const SettingsStealthScreen(),
        overrides: _overrides(
          _FakeStealthController(_stateWith(enabled: true)),
        ),
      );
      expect(find.text(l10n.stealthTimerDisplayNormal), findsOneWidget);
    });

    testWidgets('dropdown shows Small when timerDisplay=small', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const SettingsStealthScreen(),
        overrides: _overrides(
          _FakeStealthController(
            _stateWith(enabled: true, timerDisplay: StealthTimerDisplay.small),
          ),
        ),
      );
      expect(find.text(l10n.stealthTimerDisplaySmall), findsOneWidget);
    });

    testWidgets('dropdown shows Hidden when timerDisplay=none', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const SettingsStealthScreen(),
        overrides: _overrides(
          _FakeStealthController(
            _stateWith(enabled: true, timerDisplay: StealthTimerDisplay.none),
          ),
        ),
      );
      expect(find.text(l10n.stealthTimerDisplayNone), findsOneWidget);
    });

    testWidgets('selecting Small from dropdown calls setTimerDisplay(small)', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      // timerDisplay starts as normal (default).
      final fake = _FakeStealthController(_stateWith(enabled: true));
      await pumpScreen(
        tester,
        const SettingsStealthScreen(),
        overrides: _overrides(fake),
      );
      await tester.tap(find.byType(DropdownButton<StealthTimerDisplay>));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.stealthTimerDisplaySmall).last);
      await tester.pumpAndSettle();
      check(fake.setTimerDisplayCalls).equals(1);
      check(fake.lastTimerDisplay).equals(StealthTimerDisplay.small);
    });

    testWidgets('selecting Hidden from dropdown calls setTimerDisplay(none)', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      // timerDisplay starts as normal (default).
      final fake = _FakeStealthController(_stateWith(enabled: true));
      await pumpScreen(
        tester,
        const SettingsStealthScreen(),
        overrides: _overrides(fake),
      );
      await tester.tap(find.byType(DropdownButton<StealthTimerDisplay>));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.stealthTimerDisplayNone).last);
      await tester.pumpAndSettle();
      check(fake.setTimerDisplayCalls).equals(1);
      check(fake.lastTimerDisplay).equals(StealthTimerDisplay.none);
    });
  });

  // -------------------------------------------------------------------------
  // RTL smoke test
  // -------------------------------------------------------------------------
  group('SettingsStealthScreen — RTL', () {
    testWidgets('renders in Arabic (RTL) without exception', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        const SettingsStealthScreen(),
        overrides: _overrides(
          _FakeStealthController(_stateWith(enabled: true)),
        ),
        locale: const Locale('ar'),
      );
      expect(find.byType(AppBar), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  // -------------------------------------------------------------------------
  // Dark mode smoke test
  // -------------------------------------------------------------------------
  group('SettingsStealthScreen — dark mode', () {
    testWidgets('renders without exception in dark mode', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        const SettingsStealthScreen(),
        overrides: _overrides(
          _FakeStealthController(_stateWith(enabled: true)),
        ),
        themeMode: ThemeMode.dark,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('stealth sub-options render in dark mode when enabled', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const SettingsStealthScreen(),
        overrides: _overrides(
          _FakeStealthController(
            _stateWith(
              enabled: true,
              fakeName: 'Weather',
              timerDisplay: StealthTimerDisplay.small,
            ),
          ),
        ),
        themeMode: ThemeMode.dark,
      );
      expect(find.text(l10n.stealthFakeNameLabel), findsOneWidget);
      expect(find.text(l10n.stealthTimerDisplaySmall), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  // -------------------------------------------------------------------------
  // Accessibility smoke test
  // -------------------------------------------------------------------------
  group('SettingsStealthScreen — accessibility', () {
    testWidgets('enable toggle has a Semantics label', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const SettingsStealthScreen(),
        overrides: _overrides(_FakeStealthController(_stateWith())),
      );
      // SwitchListTile renders the title text inside a Semantics node.
      expect(find.text(l10n.stealthEnabledLabel), findsOneWidget);
    });

    testWidgets('sub-option tiles have accessible text when enabled', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const SettingsStealthScreen(),
        overrides: _overrides(
          _FakeStealthController(_stateWith(enabled: true)),
        ),
      );
      expect(find.text(l10n.stealthFakeNameLabel), findsOneWidget);
      expect(find.text(l10n.stealthNotificationDisguiseLabel), findsOneWidget);
      expect(find.text(l10n.stealthSessionScreenLabel), findsOneWidget);
      expect(find.text(l10n.stealthTimerDisplayLabel), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  // Fake-icon picker (spec 04 §Stealth Settings)
  // -------------------------------------------------------------------------
  group('SettingsStealthScreen — fake icon picker', () {
    testWidgets('renders the icon-preset dropdown when stealth is enabled', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const SettingsStealthScreen(),
        overrides: _overrides(
          _FakeStealthController(_stateWith(enabled: true)),
        ),
      );
      expect(find.text(l10n.stealthFakeIconLabel), findsOneWidget);
      expect(find.byType(DropdownButton<StealthIconPreset>), findsOneWidget);
    });

    testWidgets('selecting a preset calls setFakeIcon', (
      WidgetTester tester,
    ) async {
      final fake = _FakeStealthController(_stateWith(enabled: true));
      await pumpScreen(
        tester,
        const SettingsStealthScreen(),
        overrides: _overrides(fake),
      );
      await tester.tap(find.byType(DropdownButton<StealthIconPreset>));
      await tester.pumpAndSettle();
      // The "Calendar" entry is one of the visible menu items.
      await tester.tap(find.text('Calendar').last);
      await tester.pumpAndSettle();
      check(fake.setFakeIconCalls).equals(1);
      check(fake.lastFakeIcon).equals(StealthIconPreset.calendar);
    });
  });

  // -------------------------------------------------------------------------
  // Lock-task / pinned-app toggle
  // -------------------------------------------------------------------------
  group('SettingsStealthScreen — lock-task toggle', () {
    testWidgets('renders the lock-task toggle when stealth is enabled', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const SettingsStealthScreen(),
        overrides: _overrides(
          _FakeStealthController(_stateWith(enabled: true)),
        ),
      );
      expect(find.text(l10n.stealthLockTaskLabel), findsOneWidget);
    });

    testWidgets('lock-task toggle persists the value via setLockTaskMode', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeStealthController(_stateWith(enabled: true));
      await pumpScreen(
        tester,
        const SettingsStealthScreen(),
        overrides: _overrides(fake),
      );
      await tester.tap(find.text(l10n.stealthLockTaskLabel));
      await tester.pumpAndSettle();
      check(fake.setLockTaskModeCalls).equals(1);
      check(fake.lastLockTaskMode).equals(true);
    });

    testWidgets('toggle is hidden when stealth is disabled', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const SettingsStealthScreen(),
        overrides: _overrides(_FakeStealthController(_stateWith())),
      );
      expect(find.text(l10n.stealthLockTaskLabel), findsNothing);
    });

    testWidgets('renders an info button next to the lock-task toggle', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        const SettingsStealthScreen(),
        overrides: _overrides(
          _FakeStealthController(_stateWith(enabled: true)),
        ),
      );
      // The lock-task toggle is the only field with an InfoIconButton on
      // this screen, so exactly one is rendered (and only when enabled).
      expect(find.byType(InfoIconButton), findsOneWidget);
    });

    testWidgets('info button is absent when stealth is disabled', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        const SettingsStealthScreen(),
        overrides: _overrides(_FakeStealthController(_stateWith())),
      );
      expect(find.byType(InfoIconButton), findsNothing);
    });

    testWidgets('tapping the info button opens the trade-off explanation', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const SettingsStealthScreen(),
        overrides: _overrides(
          _FakeStealthController(_stateWith(enabled: true)),
        ),
      );
      await tester.tap(find.byType(InfoIconButton));
      await tester.pumpAndSettle();
      // The info sheet shows the lock-task trade-off body verbatim.
      expect(find.text(l10n.stealthLockTaskInfo), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  // Construction
  // -------------------------------------------------------------------------
  group('SettingsStealthScreen — construction', () {
    testWidgets('a non-const construction with an explicit key renders', (
      WidgetTester tester,
    ) async {
      // Every other test uses `const SettingsStealthScreen()`, which the
      // compiler canonicalises away from the constructor's line table.
      await pumpScreen(
        tester,
        SettingsStealthScreen(key: UniqueKey()),
        overrides: _overrides(_FakeStealthController(_stateWith())),
      );
      expect(find.byType(SettingsStealthScreen), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });
  });
}
