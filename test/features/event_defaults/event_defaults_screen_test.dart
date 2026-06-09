/// Widget tests for EventDefaultsScreen.
///
/// Follows the pattern established in `test/features/home/home_screen_test.dart`:
/// a `_FakeEventDefaultsController` subclasses the real controller and overrides
/// `build()` to inject a canned `EventDefaultsState`. Each `testWidgets` body
/// calls `pumpScreen` from `widget_test_helpers.dart`.
///
/// The screen renders a lazy [ListView] containing 9 [ExpansionTile]s.
/// Tiles beyond ~5 are not built until they scroll into view. Tests use
/// [_scrollToTile] / [_scrollUntilTextVisible] / [_tapSwitch] to drive
/// interaction without relying on `skipOffstage`.
library;

import 'package:flutter/material.dart';

import 'package:checks/checks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/domain/configs/step_config.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/enums/press_pattern.dart';
import 'package:guardianangela/domain/models/event_defaults.dart';
import 'package:guardianangela/features/event_defaults/event_defaults_controller.dart';
import 'package:guardianangela/features/event_defaults/event_defaults_screen.dart';
import '../../helpers/widget_test_helpers.dart';

// ---------------------------------------------------------------------------
// Fake controllers
// ---------------------------------------------------------------------------

class _FakeEventDefaultsController extends EventDefaultsController {
  _FakeEventDefaultsController(this._initial);

  final EventDefaultsState _initial;

  int saveCalls = 0;
  EventDefaults? lastSaved;

  @override
  Future<EventDefaultsState> build() async => _initial;

  @override
  Future<void> save(EventDefaults updated) async {
    saveCalls++;
    lastSaved = updated;
    state = AsyncData(EventDefaultsState(defaults: updated));
  }
}

/// Controller whose build always throws, exercising the async error branch.
class _FakeErrorController extends EventDefaultsController {
  @override
  Future<EventDefaultsState> build() async =>
      throw Exception('controller build error');
}

// ---------------------------------------------------------------------------
// Test helpers
// ---------------------------------------------------------------------------

/// Builds a canned [EventDefaultsState] from the supplied or default config.
EventDefaultsState _defaultState({EventDefaults? defaults}) =>
    EventDefaultsState(defaults: defaults ?? const EventDefaults());

/// Returns an [Override] that installs [fake] as the notifier.
Override _override(_FakeEventDefaultsController fake) =>
    eventDefaultsControllerProvider.overrideWith(() => fake);

/// Returns the tile-header text rendered by the screen for [type].
///
/// The screen uses `type.name` directly (e.g. `"holdButton"`).
String _tileName(ChainStepType t) => t.name;

/// Scrolls the outer [ListView] downward (300 px per step, up to 20 steps)
/// until [targetFinder] finds at least one widget.
///
/// The list is lazy — items that have never been scrolled into view are not
/// in the widget tree at all and cannot be found by any `Finder` flag.
Future<void> _scrollUntilVisible(
  WidgetTester tester,
  Finder targetFinder,
) async {
  const maxDrags = 20;
  for (var i = 0; i < maxDrags; i++) {
    if (targetFinder.evaluate().isNotEmpty) return;
    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pumpAndSettle();
  }
}

/// Pumps the screen, scrolls to the [type] tile, and taps it to expand.
///
/// Returns the installed [_FakeEventDefaultsController] so callers can
/// assert on [saveCalls] / [lastSaved] after interacting with the form.
Future<_FakeEventDefaultsController> _pumpAndExpand(
  WidgetTester tester,
  ChainStepType type, {
  EventDefaults? defaults,
}) async {
  final fake = _FakeEventDefaultsController(_defaultState(defaults: defaults));
  await pumpScreen(
    tester,
    const EventDefaultsScreen(),
    overrides: <Override>[_override(fake)],
  );
  final tileFinder = find.text(_tileName(type));
  await _scrollUntilVisible(tester, tileFinder);
  await tester.tap(tileFinder);
  await tester.pumpAndSettle();
  return fake;
}

/// Scrolls a [SwitchListTile] labelled [title] into view, then taps its
/// [Switch].
///
/// Uses [scrollUntilVisible] to handle form fields that fall below the
/// viewport after a tile is expanded.
Future<void> _tapSwitch(WidgetTester tester, String title) async {
  final titleFinder = find.text(title);
  await _scrollUntilVisible(tester, titleFinder);
  final switchFinder = find.descendant(
    of: find.ancestor(of: titleFinder, matching: find.byType(SwitchListTile)),
    matching: find.byType(Switch),
  );
  await tester.scrollUntilVisible(
    switchFinder,
    100,
    scrollable: find
        .descendant(
          of: find.byType(ListView),
          matching: find.byType(Scrollable),
        )
        .first,
  );
  await tester.pumpAndSettle();
  await tester.tap(switchFinder);
  await tester.pumpAndSettle();
}

/// Scrolls until [textFinder] is on screen, then asserts it is found.
Future<void> _assertText(WidgetTester tester, Finder textFinder) async {
  await _scrollUntilVisible(tester, textFinder);
  expect(textFinder, findsOneWidget);
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // ── AppBar ────────────────────────────────────────────────────────────────

  group('EventDefaultsScreen — AppBar', () {
    testWidgets('shows the event-defaults title in the app bar', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeEventDefaultsController(_defaultState());
      await pumpScreen(
        tester,
        const EventDefaultsScreen(),
        overrides: <Override>[_override(fake)],
      );
      expect(find.text(l10n.eventDefaultsTitle), findsOneWidget);
    });

    testWidgets('has exactly one AppBar', (WidgetTester tester) async {
      final fake = _FakeEventDefaultsController(_defaultState());
      await pumpScreen(
        tester,
        const EventDefaultsScreen(),
        overrides: <Override>[_override(fake)],
      );
      expect(find.byType(AppBar), findsOneWidget);
    });
  });

  // ── Async states ──────────────────────────────────────────────────────────

  group('EventDefaultsScreen — async states', () {
    testWidgets('shows CircularProgressIndicator while loading', (
      WidgetTester tester,
    ) async {
      final fake = _FakeEventDefaultsController(_defaultState());
      await pumpScreen(
        tester,
        const EventDefaultsScreen(),
        overrides: <Override>[_override(fake)],
        settle: false,
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('hides spinner once data resolves', (
      WidgetTester tester,
    ) async {
      final fake = _FakeEventDefaultsController(_defaultState());
      await pumpScreen(
        tester,
        const EventDefaultsScreen(),
        overrides: <Override>[_override(fake)],
      );
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('renders error text when controller throws during build', (
      WidgetTester tester,
    ) async {
      final fake = _FakeErrorController();
      await pumpScreen(
        tester,
        const EventDefaultsScreen(),
        overrides: <Override>[
          eventDefaultsControllerProvider.overrideWith(() => fake),
        ],
      );
      expect(find.textContaining('Error:'), findsOneWidget);
    });
  });

  // ── Section headers ───────────────────────────────────────────────────────

  group('EventDefaultsScreen — section headers', () {
    testWidgets('check-in section header visible on initial load', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeEventDefaultsController(_defaultState());
      await pumpScreen(
        tester,
        const EventDefaultsScreen(),
        overrides: <Override>[_override(fake)],
      );
      expect(find.text(l10n.eventDefaultsCheckInHeader), findsOneWidget);
    });

    testWidgets('escalation and panic headers visible after scrolling down', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeEventDefaultsController(_defaultState());
      await pumpScreen(
        tester,
        const EventDefaultsScreen(),
        overrides: <Override>[_override(fake)],
      );
      final escalationFinder = find.text(l10n.eventDefaultsEscalationHeader);
      await _scrollUntilVisible(tester, escalationFinder);
      expect(escalationFinder, findsOneWidget);

      final panicFinder = find.text(l10n.eventDefaultsPanicHeader);
      await _scrollUntilVisible(tester, panicFinder);
      expect(panicFinder, findsOneWidget);
    });

    testWidgets('at least one Divider visible on initial render', (
      WidgetTester tester,
    ) async {
      final fake = _FakeEventDefaultsController(_defaultState());
      await pumpScreen(
        tester,
        const EventDefaultsScreen(),
        overrides: <Override>[_override(fake)],
      );
      expect(find.byType(Divider), findsAtLeastNWidgets(1));
    });
  });

  // ── All 9 ExpansionTiles present ──────────────────────────────────────────

  group('EventDefaultsScreen — all 9 tiles present', () {
    testWidgets('all 9 tile headers reachable by scrolling', (
      WidgetTester tester,
    ) async {
      final fake = _FakeEventDefaultsController(_defaultState());
      await pumpScreen(
        tester,
        const EventDefaultsScreen(),
        overrides: <Override>[_override(fake)],
      );
      for (final type in ChainStepType.values) {
        final tileFinder = find.text(_tileName(type));
        await _scrollUntilVisible(tester, tileFinder);
        expect(
          tileFinder,
          findsOneWidget,
          reason: '${type.name} tile header not found after scrolling',
        );
      }
    });

    for (final type in ChainStepType.values) {
      testWidgets('tile for ${type.name} scrolls into view and is tappable', (
        WidgetTester tester,
      ) async {
        final fake = _FakeEventDefaultsController(_defaultState());
        await pumpScreen(
          tester,
          const EventDefaultsScreen(),
          overrides: <Override>[_override(fake)],
        );
        final tileFinder = find.text(_tileName(type));
        await _scrollUntilVisible(tester, tileFinder);
        expect(tileFinder, findsOneWidget);
      });
    }
  });

  // ── holdButton form ───────────────────────────────────────────────────────

  group('EventDefaultsScreen — holdButton form', () {
    testWidgets('expanding tile shows HoldStyle dropdown label', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pumpAndExpand(tester, ChainStepType.holdButton);
      await _assertText(tester, find.text(l10n.eventDefaultsHoldStyle));
    });

    testWidgets('expanding tile shows vibrate and sound switches', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pumpAndExpand(tester, ChainStepType.holdButton);
      await _assertText(tester, find.text(l10n.eventDefaultsHoldVibrate));
      await _assertText(tester, find.text(l10n.eventDefaultsHoldSound));
    });

    testWidgets('toggling vibrate switch calls save with flipped value', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      // vibrateOnRelease defaults to true.
      final fake = await _pumpAndExpand(tester, ChainStepType.holdButton);
      await _tapSwitch(tester, l10n.eventDefaultsHoldVibrate);
      check(fake.saveCalls).equals(1);
      check(fake.lastSaved!.holdButton.vibrateOnRelease).isFalse();
    });

    testWidgets('blackScreenMode switch present in holdButton form', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pumpAndExpand(tester, ChainStepType.holdButton);
      await _assertText(tester, find.text(l10n.eventDefaultsBlackScreen));
    });
  });

  // ── disguisedReminder form ────────────────────────────────────────────────

  group('EventDefaultsScreen — disguisedReminder form', () {
    testWidgets('expanding tile shows randomize-interval switch', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pumpAndExpand(tester, ChainStepType.disguisedReminder);
      await _assertText(
        tester,
        find.text(l10n.eventDefaultsReminderRandomInterval),
      );
    });

    testWidgets('toggling resetOnEarlyCheckIn switch calls save', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      // resetOnEarlyCheckIn defaults to true — toggling flips to false.
      final fake = await _pumpAndExpand(
        tester,
        ChainStepType.disguisedReminder,
      );
      await _tapSwitch(tester, l10n.eventDefaultsReminderResetOnEarly);
      check(fake.saveCalls).equals(1);
      check(fake.lastSaved!.disguisedReminder.resetOnEarlyCheckIn).isFalse();
    });
  });

  // ── countdownWarning form ─────────────────────────────────────────────────

  group('EventDefaultsScreen — countdownWarning form', () {
    testWidgets('expanding tile shows CountdownStyle dropdown label', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pumpAndExpand(tester, ChainStepType.countdownWarning);
      await _assertText(tester, find.text(l10n.eventDefaultsCountdownStyle));
    });

    testWidgets('expanding tile shows vibrate and sound switches', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pumpAndExpand(tester, ChainStepType.countdownWarning);
      await _assertText(tester, find.text(l10n.eventDefaultsCountdownVibrate));
      await _assertText(tester, find.text(l10n.eventDefaultsCountdownSound));
    });

    testWidgets('toggling sound switch saves with updated value', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      // sound defaults to false — toggling flips to true.
      final fake = await _pumpAndExpand(tester, ChainStepType.countdownWarning);
      await _tapSwitch(tester, l10n.eventDefaultsCountdownSound);
      check(fake.saveCalls).equals(1);
      check(fake.lastSaved!.countdownWarning.sound).isTrue();
    });
  });

  // ── fakeCall form ─────────────────────────────────────────────────────────

  group('EventDefaultsScreen — fakeCall form', () {
    testWidgets('expanding tile shows CallStyle dropdown label', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pumpAndExpand(tester, ChainStepType.fakeCall);
      await _assertText(tester, find.text(l10n.eventDefaultsFakeCallStyle));
    });

    testWidgets('expanding tile shows caller-name text field label', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pumpAndExpand(tester, ChainStepType.fakeCall);
      await _assertText(
        tester,
        find.text(l10n.eventDefaultsFakeCallCallerName),
      );
    });

    testWidgets('expanding tile shows ring-duration spinner label', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pumpAndExpand(tester, ChainStepType.fakeCall);
      await _assertText(
        tester,
        find.text(l10n.eventDefaultsFakeCallRingDuration),
      );
    });

    testWidgets('declineIsSafe switch is rendered', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pumpAndExpand(tester, ChainStepType.fakeCall);
      await _assertText(
        tester,
        find.text(l10n.eventDefaultsFakeCallDeclineIsSafe),
      );
    });

    testWidgets('toggling declineIsSafe switch calls save with flipped value', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      // declineIsSafe defaults to true — toggling flips to false.
      final fake = await _pumpAndExpand(tester, ChainStepType.fakeCall);
      await _tapSwitch(tester, l10n.eventDefaultsFakeCallDeclineIsSafe);
      check(fake.saveCalls).equals(1);
      check(fake.lastSaved!.fakeCall.declineIsSafe).isFalse();
    });
  });

  // ── smsContact form ───────────────────────────────────────────────────────

  group('EventDefaultsScreen — smsContact form', () {
    testWidgets('expanding tile shows channel dropdown label', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pumpAndExpand(tester, ChainStepType.smsContact);
      await _assertText(tester, find.text(l10n.eventDefaultsSmsChannel));
    });

    testWidgets('include-location and include-medical switches are present', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pumpAndExpand(tester, ChainStepType.smsContact);
      await _assertText(
        tester,
        find.text(l10n.eventDefaultsSmsIncludeLocation),
      );
      await _assertText(tester, find.text(l10n.eventDefaultsSmsIncludeMedical));
    });

    testWidgets('recordDuration spinner absent when autoRecordAudio is false', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      // autoRecordAudio defaults to false.
      await _pumpAndExpand(tester, ChainStepType.smsContact);
      // Scroll all the way through the form to confirm it's truly absent.
      await _assertText(tester, find.text(l10n.eventDefaultsBlackScreen));
      expect(find.text(l10n.eventDefaultsSmsRecordDuration), findsNothing);
    });

    testWidgets('toggling includeLocation switch calls save', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      // includeLocation defaults to true — toggling flips to false.
      final fake = await _pumpAndExpand(tester, ChainStepType.smsContact);
      await _tapSwitch(tester, l10n.eventDefaultsSmsIncludeLocation);
      check(fake.saveCalls).equals(1);
      check(fake.lastSaved!.smsContact.includeLocation).isFalse();
    });

    testWidgets('enabling autoRecordAudio calls save with updated value', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      // autoRecordAudio defaults to false — toggling flips to true.
      final fake = await _pumpAndExpand(tester, ChainStepType.smsContact);
      await _tapSwitch(tester, l10n.eventDefaultsSmsAutoRecord);
      check(fake.saveCalls).equals(1);
      check(fake.lastSaved!.smsContact.autoRecordAudio).isTrue();
    });
  });

  // ── phoneCallContact form ─────────────────────────────────────────────────

  group('EventDefaultsScreen — phoneCallContact form', () {
    testWidgets('expanding tile shows primary-contact text field label', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pumpAndExpand(tester, ChainStepType.phoneCallContact);
      await _assertText(
        tester,
        find.text(l10n.eventDefaultsPhonePrimaryContact),
      );
    });

    testWidgets('blackScreen switch present in phoneCallContact form', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pumpAndExpand(tester, ChainStepType.phoneCallContact);
      await _assertText(tester, find.text(l10n.eventDefaultsBlackScreen));
    });
  });

  // ── loudAlarm form ────────────────────────────────────────────────────────

  group('EventDefaultsScreen — loudAlarm form', () {
    testWidgets('expanding tile shows volume slider label', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pumpAndExpand(tester, ChainStepType.loudAlarm);
      await _assertText(
        tester,
        find.textContaining(l10n.eventDefaultsLoudAlarmVolume),
      );
    });

    testWidgets('expanding tile shows LoudAlarmSound dropdown label', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pumpAndExpand(tester, ChainStepType.loudAlarm);
      await _assertText(tester, find.text(l10n.eventDefaultsLoudAlarmSound));
    });

    testWidgets('flash-screen and flash-light switches present', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pumpAndExpand(tester, ChainStepType.loudAlarm);
      await _assertText(
        tester,
        find.text(l10n.eventDefaultsLoudAlarmFlashScreen),
      );
      await _assertText(
        tester,
        find.text(l10n.eventDefaultsLoudAlarmFlashLight),
      );
    });

    testWidgets('toggling gradualVolume switch saves with new value', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      // gradualVolume defaults to false — toggling flips to true.
      final fake = await _pumpAndExpand(tester, ChainStepType.loudAlarm);
      await _tapSwitch(tester, l10n.eventDefaultsLoudAlarmGradual);
      check(fake.saveCalls).equals(1);
      check(fake.lastSaved!.loudAlarm.gradualVolume).isTrue();
    });
  });

  // ── callEmergency form ────────────────────────────────────────────────────

  group('EventDefaultsScreen — callEmergency form', () {
    testWidgets('expanding tile shows emergency-number text field label', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pumpAndExpand(tester, ChainStepType.callEmergency);
      await _assertText(
        tester,
        find.text(l10n.eventDefaultsCallEmergencyNumber),
      );
    });

    testWidgets('showConfirmation and smsFirst switches are present', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pumpAndExpand(tester, ChainStepType.callEmergency);
      await _assertText(
        tester,
        find.text(l10n.eventDefaultsCallEmergencyConfirm),
      );
      await _assertText(
        tester,
        find.text(l10n.eventDefaultsCallEmergencySmsFirst),
      );
    });

    testWidgets(
      'confirmationDuration spinner absent when showConfirmation is false',
      (WidgetTester tester) async {
        final l10n = await loadL10n(const Locale('en'));
        const initial = EventDefaults(
          callEmergency: CallEmergencyConfig(showConfirmation: false),
        );
        await _pumpAndExpand(
          tester,
          ChainStepType.callEmergency,
          defaults: initial,
        );
        // Scroll to blackScreen to ensure the form is fully rendered.
        await _assertText(tester, find.text(l10n.eventDefaultsBlackScreen));
        expect(
          find.text(l10n.eventDefaultsCallEmergencyConfirmDuration),
          findsNothing,
        );
      },
    );

    testWidgets(
      'confirmationDuration spinner present when showConfirmation is true',
      (WidgetTester tester) async {
        final l10n = await loadL10n(const Locale('en'));
        // showConfirmation defaults to true.
        await _pumpAndExpand(tester, ChainStepType.callEmergency);
        await _assertText(
          tester,
          find.text(l10n.eventDefaultsCallEmergencyConfirmDuration),
        );
      },
    );

    testWidgets('toggling sendLocationSmsFirst calls save', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      // sendLocationSmsFirst defaults to true — toggling flips to false.
      final fake = await _pumpAndExpand(tester, ChainStepType.callEmergency);
      await _tapSwitch(tester, l10n.eventDefaultsCallEmergencySmsFirst);
      check(fake.saveCalls).equals(1);
      check(fake.lastSaved!.callEmergency.sendLocationSmsFirst).isFalse();
    });
  });

  // ── hardwareButton form ───────────────────────────────────────────────────

  group('EventDefaultsScreen — hardwareButton form', () {
    testWidgets('expanding tile shows ButtonType dropdown label', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pumpAndExpand(tester, ChainStepType.hardwareButton);
      await _assertText(tester, find.text(l10n.eventDefaultsHardwareButton));
    });

    testWidgets('expanding tile shows PressPattern dropdown label', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pumpAndExpand(tester, ChainStepType.hardwareButton);
      await _assertText(tester, find.text(l10n.eventDefaultsHardwarePattern));
    });

    testWidgets(
      'pressCount spinner shown when pattern is repeatPress (default)',
      (WidgetTester tester) async {
        final l10n = await loadL10n(const Locale('en'));
        // pressPattern defaults to repeatPress.
        await _pumpAndExpand(tester, ChainStepType.hardwareButton);
        await _assertText(
          tester,
          find.text(l10n.eventDefaultsHardwarePressCount),
        );
      },
    );

    testWidgets('longPress-duration slider shown when pattern is longPress', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      const initial = EventDefaults(
        hardwareButton: HardwareButtonConfig(
          pressPattern: PressPattern.longPress,
        ),
      );
      await _pumpAndExpand(
        tester,
        ChainStepType.hardwareButton,
        defaults: initial,
      );
      await _assertText(
        tester,
        find.textContaining(l10n.eventDefaultsHardwareLongDuration),
      );
    });

    testWidgets('blackScreen switch present in hardwareButton form', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pumpAndExpand(tester, ChainStepType.hardwareButton);
      await _assertText(tester, find.text(l10n.eventDefaultsBlackScreen));
    });

    testWidgets('toggling blackScreen switch saves the hardwareButton slot', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      // blackScreenMode defaults to false — toggling flips to true.
      final fake = await _pumpAndExpand(tester, ChainStepType.hardwareButton);
      await _tapSwitch(tester, l10n.eventDefaultsBlackScreen);
      check(fake.saveCalls).equals(1);
      check(fake.lastSaved!.hardwareButton.blackScreenMode).isTrue();
      // Sibling slots are untouched by the per-type replace.
      check(fake.lastSaved!.loudAlarm).equals(const LoudAlarmConfig());
    });
  });

  // ── RTL ───────────────────────────────────────────────────────────────────

  group('EventDefaultsScreen — RTL', () {
    testWidgets('renders in Arabic (RTL) without layout exception', (
      WidgetTester tester,
    ) async {
      final fake = _FakeEventDefaultsController(_defaultState());
      await pumpScreen(
        tester,
        const EventDefaultsScreen(),
        overrides: <Override>[_override(fake)],
        locale: const Locale('ar'),
      );
      expect(find.byType(AppBar), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  // ── Dark mode ─────────────────────────────────────────────────────────────

  group('EventDefaultsScreen — dark mode', () {
    testWidgets('renders without exception in dark mode', (
      WidgetTester tester,
    ) async {
      final fake = _FakeEventDefaultsController(_defaultState());
      await pumpScreen(
        tester,
        const EventDefaultsScreen(),
        overrides: <Override>[_override(fake)],
        themeMode: ThemeMode.dark,
      );
      expect(tester.takeException(), isNull);
    });
  });

  // ── Accessibility ─────────────────────────────────────────────────────────

  group('EventDefaultsScreen — accessibility', () {
    testWidgets('all tiles can be expanded and collapsed without exception', (
      WidgetTester tester,
    ) async {
      final fake = _FakeEventDefaultsController(_defaultState());
      await pumpScreen(
        tester,
        const EventDefaultsScreen(),
        overrides: <Override>[_override(fake)],
      );
      for (final type in ChainStepType.values) {
        final tileFinder = find.text(_tileName(type));
        await _scrollUntilVisible(tester, tileFinder);
        await tester.tap(tileFinder);
        await tester.pumpAndSettle();
        // Collapse before moving to the next tile to keep the viewport tidy.
        await tester.tap(tileFinder);
        await tester.pumpAndSettle();
      }
      expect(tester.takeException(), isNull);
    });

    testWidgets('holdButton SwitchListTiles meet 48 dp height requirement', (
      WidgetTester tester,
    ) async {
      await _pumpAndExpand(tester, ChainStepType.holdButton);
      final elements = tester.elementList(find.byType(SwitchListTile)).toList();
      check(elements).isNotEmpty();
      for (final element in elements) {
        final box = element.renderObject as RenderBox;
        check(box.size.height).isGreaterOrEqual(48.0);
      }
    });
  });

  // ── Save isolation ────────────────────────────────────────────────────────

  group('EventDefaultsScreen — save isolation', () {
    testWidgets('editing holdButton does not alter other configs', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      // soundOnRelease defaults to false; smsContact.includeLocation defaults
      // to true — both conditions are met by the plain default EventDefaults.
      final fake = await _pumpAndExpand(tester, ChainStepType.holdButton);
      await _tapSwitch(tester, l10n.eventDefaultsHoldSound);
      check(fake.lastSaved!.holdButton.soundOnRelease).isTrue();
      check(fake.lastSaved!.smsContact.includeLocation).isTrue();
    });
  });
}
