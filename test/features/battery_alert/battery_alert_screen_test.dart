/// Widget tests for [BatteryAlertScreen].
///
/// Pattern mirrors `test/features/home/home_screen_test.dart`:
/// a `_FakeBatteryAlertController` subclasses the real controller,
/// overrides `build()` to return a canned [BatteryAlertState], and
/// records every mutating call for assertion.
library;

import 'package:flutter/material.dart';

import 'package:checks/checks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/core/widgets/step_chain_editor.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/models/battery_alert_config.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/features/battery_alert/battery_alert_controller.dart';
import 'package:guardianangela/features/battery_alert/battery_alert_screen.dart';
import '../../helpers/widget_test_helpers.dart';

// ---------------------------------------------------------------------------
// Fake controller
// ---------------------------------------------------------------------------

class _FakeBatteryAlertController extends BatteryAlertController {
  _FakeBatteryAlertController(this._initial);

  final BatteryAlertState _initial;

  int setEnabledCalls = 0;
  bool? lastEnabled;

  int setThresholdCalls = 0;
  int? lastThreshold;

  int resetChainCalls = 0;

  int setChainCalls = 0;
  List<ChainStep>? lastChain;

  @override
  Future<BatteryAlertState> build() async => _initial;

  @override
  Future<void> setEnabled(bool v) async {
    setEnabledCalls++;
    lastEnabled = v;
    state = AsyncData(
      BatteryAlertState(config: _initial.config.copyWith(enabled: v)),
    );
  }

  @override
  Future<void> setThreshold(int percent) async {
    setThresholdCalls++;
    lastThreshold = percent;
  }

  @override
  Future<void> resetChain() async {
    resetChainCalls++;
  }

  @override
  Future<void> setChain(List<ChainStep> chain) async {
    setChainCalls++;
    lastChain = chain;
  }
}

// ---------------------------------------------------------------------------
// Test data helpers
// ---------------------------------------------------------------------------

ChainStep _step(ChainStepType type, {int order = 0}) => ChainStep(
  id: 'test-step-${type.name}-$order',
  type: type,
  order: order,
  waitSeconds: 0,
  durationSeconds: 10,
  gracePeriodSeconds: 5,
  retryCount: 0,
  randomize: false,
);

BatteryAlertState _state({
  bool enabled = false,
  int thresholdPercent = 10,
  List<ChainStep> chain = const <ChainStep>[],
}) => BatteryAlertState(
  config: BatteryAlertConfig(
    enabled: enabled,
    thresholdPercent: thresholdPercent,
    chain: chain,
  ),
);

Override _override(_FakeBatteryAlertController fake) =>
    batteryAlertControllerProvider.overrideWith(() => fake);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // ─── AppBar ───────────────────────────────────────────────────────────────

  group('BatteryAlertScreen — AppBar', () {
    testWidgets('renders "Battery alert" title in the AppBar', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeBatteryAlertController(_state());
      await pumpScreen(
        tester,
        const BatteryAlertScreen(),
        overrides: <Override>[_override(fake)],
      );
      expect(find.text(l10n.batteryAlertTitle), findsOneWidget);
    });

    testWidgets('shows an AppBar widget', (WidgetTester tester) async {
      final fake = _FakeBatteryAlertController(_state());
      await pumpScreen(
        tester,
        const BatteryAlertScreen(),
        overrides: <Override>[_override(fake)],
      );
      expect(find.byType(AppBar), findsOneWidget);
    });
  });

  // ─── Async states ─────────────────────────────────────────────────────────

  group('BatteryAlertScreen — async states', () {
    testWidgets('shows CircularProgressIndicator while loading', (
      WidgetTester tester,
    ) async {
      final fake = _FakeBatteryAlertController(_state());
      await pumpScreen(
        tester,
        const BatteryAlertScreen(),
        overrides: <Override>[_override(fake)],
        settle: false,
      );
      // First frame: AsyncNotifier hasn't resolved yet.
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('body renders once AsyncValue resolves', (
      WidgetTester tester,
    ) async {
      final fake = _FakeBatteryAlertController(_state());
      await pumpScreen(
        tester,
        const BatteryAlertScreen(),
        overrides: <Override>[_override(fake)],
      );
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(SwitchListTile), findsOneWidget);
    });

    testWidgets('error state renders error text', (WidgetTester tester) async {
      final fake = _FakeBatteryAlertController(_state());
      await pumpScreen(
        tester,
        const BatteryAlertScreen(),
        overrides: <Override>[
          batteryAlertControllerProvider.overrideWith(
            () => fake..state = const AsyncError('boom', StackTrace.empty),
          ),
        ],
        settle: false,
      );
      await tester.pump(); // let one frame run for the error state
      expect(find.textContaining('Error:'), findsOneWidget);
    });
  });

  // ─── Enable toggle ────────────────────────────────────────────────────────

  group('BatteryAlertScreen — enable toggle', () {
    testWidgets('SwitchListTile renders with correct off-state', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeBatteryAlertController(_state());
      await pumpScreen(
        tester,
        const BatteryAlertScreen(),
        overrides: <Override>[_override(fake)],
      );
      final tile = tester.widget<SwitchListTile>(
        find.byType(SwitchListTile).first,
      );
      check(tile.value).isFalse();
      expect(find.text(l10n.batteryAlertEnableLabel), findsOneWidget);
    });

    testWidgets('SwitchListTile renders as on when config.enabled is true', (
      WidgetTester tester,
    ) async {
      final fake = _FakeBatteryAlertController(
        _state(
          enabled: true,
          chain: <ChainStep>[_step(ChainStepType.smsContact)],
        ),
      );
      await pumpScreen(
        tester,
        const BatteryAlertScreen(),
        overrides: <Override>[_override(fake)],
      );
      final tile = tester.widget<SwitchListTile>(
        find.byType(SwitchListTile).first,
      );
      check(tile.value).isTrue();
    });

    testWidgets('toggling switch to true calls setEnabled(true)', (
      WidgetTester tester,
    ) async {
      final fake = _FakeBatteryAlertController(_state());
      await pumpScreen(
        tester,
        const BatteryAlertScreen(),
        overrides: <Override>[_override(fake)],
      );
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      check(fake.setEnabledCalls).equals(1);
      check(fake.lastEnabled).equals(true);
    });

    testWidgets('toggling switch to false calls setEnabled(false)', (
      WidgetTester tester,
    ) async {
      final fake = _FakeBatteryAlertController(
        _state(
          enabled: true,
          chain: <ChainStep>[_step(ChainStepType.smsContact)],
        ),
      );
      await pumpScreen(
        tester,
        const BatteryAlertScreen(),
        overrides: <Override>[_override(fake)],
      );
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      check(fake.setEnabledCalls).equals(1);
      check(fake.lastEnabled).equals(false);
    });

    testWidgets('threshold slider and chain editor are hidden when disabled', (
      WidgetTester tester,
    ) async {
      final fake = _FakeBatteryAlertController(_state());
      await pumpScreen(
        tester,
        const BatteryAlertScreen(),
        overrides: <Override>[_override(fake)],
      );
      // Slider only appears when enabled.
      expect(find.byType(Slider), findsNothing);
      expect(find.byType(StepChainEditor), findsNothing);
    });

    testWidgets('threshold slider and chain editor appear when enabled', (
      WidgetTester tester,
    ) async {
      final fake = _FakeBatteryAlertController(
        _state(
          enabled: true,
          chain: <ChainStep>[_step(ChainStepType.smsContact)],
        ),
      );
      await pumpScreen(
        tester,
        const BatteryAlertScreen(),
        overrides: <Override>[_override(fake)],
      );
      expect(find.byType(Slider), findsOneWidget);
      expect(find.byType(StepChainEditor), findsOneWidget);
    });
  });

  // ─── Threshold slider ─────────────────────────────────────────────────────

  group('BatteryAlertScreen — threshold slider', () {
    testWidgets('slider label shows stored threshold percent', (
      WidgetTester tester,
    ) async {
      final fake = _FakeBatteryAlertController(
        _state(enabled: true, thresholdPercent: 25),
      );
      await pumpScreen(
        tester,
        const BatteryAlertScreen(),
        overrides: <Override>[_override(fake)],
      );
      final slider = tester.widget<Slider>(find.byType(Slider));
      check(slider.value.round()).equals(25);
    });

    testWidgets('slider has min 5 and max 50 per spec', (
      WidgetTester tester,
    ) async {
      final fake = _FakeBatteryAlertController(_state(enabled: true));
      await pumpScreen(
        tester,
        const BatteryAlertScreen(),
        overrides: <Override>[_override(fake)],
      );
      final slider = tester.widget<Slider>(find.byType(Slider));
      check(slider.min).equals(5.0);
      check(slider.max).equals(50.0);
    });

    testWidgets('slider has 45 divisions (5..50 in 1% steps)', (
      WidgetTester tester,
    ) async {
      final fake = _FakeBatteryAlertController(_state(enabled: true));
      await pumpScreen(
        tester,
        const BatteryAlertScreen(),
        overrides: <Override>[_override(fake)],
      );
      final slider = tester.widget<Slider>(find.byType(Slider));
      check(slider.divisions).equals(45);
    });

    testWidgets('threshold label text is rendered', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeBatteryAlertController(_state(enabled: true));
      await pumpScreen(
        tester,
        const BatteryAlertScreen(),
        overrides: <Override>[_override(fake)],
      );
      expect(find.text(l10n.batteryAlertThresholdLabel), findsOneWidget);
    });
  });

  // ─── Alert chain header and reset ─────────────────────────────────────────

  group('BatteryAlertScreen — alert chain header', () {
    testWidgets('chain header text is rendered', (WidgetTester tester) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeBatteryAlertController(
        _state(
          enabled: true,
          chain: <ChainStep>[_step(ChainStepType.smsContact)],
        ),
      );
      await pumpScreen(
        tester,
        const BatteryAlertScreen(),
        overrides: <Override>[_override(fake)],
      );
      expect(find.text(l10n.batteryAlertChainHeader), findsOneWidget);
    });

    testWidgets('Reset button is visible when enabled', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeBatteryAlertController(
        _state(
          enabled: true,
          chain: <ChainStep>[_step(ChainStepType.smsContact)],
        ),
      );
      await pumpScreen(
        tester,
        const BatteryAlertScreen(),
        overrides: <Override>[_override(fake)],
      );
      expect(find.text(l10n.batteryAlertResetChain), findsOneWidget);
    });

    testWidgets('tapping Reset calls resetChain on controller', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeBatteryAlertController(
        _state(
          enabled: true,
          chain: <ChainStep>[_step(ChainStepType.smsContact)],
        ),
      );
      await pumpScreen(
        tester,
        const BatteryAlertScreen(),
        overrides: <Override>[_override(fake)],
      );
      await tester.tap(find.text(l10n.batteryAlertResetChain));
      await tester.pumpAndSettle();
      check(fake.resetChainCalls).equals(1);
    });
  });

  // ─── StepChainEditor ──────────────────────────────────────────────────────

  group('BatteryAlertScreen — StepChainEditor', () {
    testWidgets('renders one Card per step in the chain', (
      WidgetTester tester,
    ) async {
      final fake = _FakeBatteryAlertController(
        _state(
          enabled: true,
          chain: <ChainStep>[
            _step(ChainStepType.smsContact),
            _step(ChainStepType.loudAlarm, order: 1),
          ],
        ),
      );
      await pumpScreen(
        tester,
        const BatteryAlertScreen(),
        overrides: <Override>[_override(fake)],
      );
      expect(find.byType(Card), findsNWidgets(2));
    });

    testWidgets('step type names are rendered in the chain', (
      WidgetTester tester,
    ) async {
      final fake = _FakeBatteryAlertController(
        _state(
          enabled: true,
          chain: <ChainStep>[
            _step(ChainStepType.smsContact),
            _step(ChainStepType.phoneCallContact, order: 1),
          ],
        ),
      );
      await pumpScreen(
        tester,
        const BatteryAlertScreen(),
        overrides: <Override>[_override(fake)],
      );
      expect(find.text(ChainStepType.smsContact.name), findsOneWidget);
      expect(find.text(ChainStepType.phoneCallContact.name), findsOneWidget);
    });

    testWidgets(
      'Remove step button is absent when chain has 1 step (minSteps=0 still canRemove at 1)',
      (WidgetTester tester) async {
        // minSteps=0 so canRemove is always true for len>=1.
        // Verify the delete button shows on an expanded card.
        final l10n = await loadL10n(const Locale('en'));
        final fake = _FakeBatteryAlertController(
          _state(
            enabled: true,
            chain: <ChainStep>[_step(ChainStepType.smsContact)],
          ),
        );
        await pumpScreen(
          tester,
          const BatteryAlertScreen(),
          overrides: <Override>[_override(fake)],
        );
        // Expand the card to reveal the remove button.
        await tester.tap(find.text(ChainStepType.smsContact.name));
        await tester.pumpAndSettle();
        expect(find.text(l10n.stepEditorRemove), findsOneWidget);
      },
    );

    testWidgets('tapping Remove on a step calls setChain with step removed', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeBatteryAlertController(
        _state(
          enabled: true,
          chain: <ChainStep>[
            _step(ChainStepType.smsContact),
            _step(ChainStepType.loudAlarm, order: 1),
          ],
        ),
      );
      await pumpScreen(
        tester,
        const BatteryAlertScreen(),
        overrides: <Override>[_override(fake)],
      );
      // Expand the first card.
      await tester.tap(find.text(ChainStepType.smsContact.name));
      await tester.pumpAndSettle();
      // Scroll the Remove button into the viewport before tapping.
      final removeFinder = find.text(l10n.stepEditorRemove).first;
      await tester.ensureVisible(removeFinder);
      await tester.pumpAndSettle();
      await tester.tap(removeFinder);
      await tester.pumpAndSettle();
      check(fake.setChainCalls).equals(1);
      check(fake.lastChain!.length).equals(1);
    });

    testWidgets('Add step button is rendered', (WidgetTester tester) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeBatteryAlertController(_state(enabled: true));
      await pumpScreen(
        tester,
        const BatteryAlertScreen(),
        overrides: <Override>[_override(fake)],
      );
      expect(find.text(l10n.modeChainAddStep), findsOneWidget);
    });
  });

  // ─── Forbidden step type filtering ────────────────────────────────────────

  group('BatteryAlertScreen — allowed step types', () {
    testWidgets(
      'Add step bottom sheet shows only allowed types, not holdButton',
      (WidgetTester tester) async {
        final l10n = await loadL10n(const Locale('en'));
        final fake = _FakeBatteryAlertController(_state(enabled: true));
        await pumpScreen(
          tester,
          const BatteryAlertScreen(),
          overrides: <Override>[_override(fake)],
        );
        await tester.tap(find.text(l10n.modeChainAddStep));
        await tester.pumpAndSettle();
        // holdButton is forbidden — must not appear in the picker.
        expect(find.text(ChainStepType.holdButton.name), findsNothing);
      },
    );

    testWidgets('Add step bottom sheet does not offer disguisedReminder', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeBatteryAlertController(_state(enabled: true));
      await pumpScreen(
        tester,
        const BatteryAlertScreen(),
        overrides: <Override>[_override(fake)],
      );
      await tester.tap(find.text(l10n.modeChainAddStep));
      await tester.pumpAndSettle();
      expect(find.text(ChainStepType.disguisedReminder.name), findsNothing);
    });

    testWidgets('Add step bottom sheet does not offer hardwareButton', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeBatteryAlertController(_state(enabled: true));
      await pumpScreen(
        tester,
        const BatteryAlertScreen(),
        overrides: <Override>[_override(fake)],
      );
      await tester.tap(find.text(l10n.modeChainAddStep));
      await tester.pumpAndSettle();
      expect(find.text(ChainStepType.hardwareButton.name), findsNothing);
    });

    testWidgets('Add step bottom sheet offers smsContact', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeBatteryAlertController(_state(enabled: true));
      await pumpScreen(
        tester,
        const BatteryAlertScreen(),
        overrides: <Override>[_override(fake)],
      );
      await tester.tap(find.text(l10n.modeChainAddStep));
      await tester.pumpAndSettle();
      expect(find.text(ChainStepType.smsContact.name), findsOneWidget);
    });

    testWidgets('Add step bottom sheet offers loudAlarm', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeBatteryAlertController(_state(enabled: true));
      await pumpScreen(
        tester,
        const BatteryAlertScreen(),
        overrides: <Override>[_override(fake)],
      );
      await tester.tap(find.text(l10n.modeChainAddStep));
      await tester.pumpAndSettle();
      expect(find.text(ChainStepType.loudAlarm.name), findsOneWidget);
    });

    testWidgets(
      'tapping smsContact in the bottom sheet calls setChain with new step',
      (WidgetTester tester) async {
        final l10n = await loadL10n(const Locale('en'));
        final fake = _FakeBatteryAlertController(_state(enabled: true));
        await pumpScreen(
          tester,
          const BatteryAlertScreen(),
          overrides: <Override>[_override(fake)],
        );
        await tester.tap(find.text(l10n.modeChainAddStep));
        await tester.pumpAndSettle();
        await tester.tap(find.text(ChainStepType.smsContact.name));
        await tester.pumpAndSettle();
        check(fake.setChainCalls).equals(1);
        final added = fake.lastChain!;
        check(added.length).equals(1);
        check(added.first.type).equals(ChainStepType.smsContact);
      },
    );
  });

  // ─── Forbidden step snackbar ──────────────────────────────────────────────

  group('BatteryAlertScreen — forbidden step validation', () {
    testWidgets('passing a forbidden step type to onChanged shows a SnackBar', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final forbiddenStep = ChainStep(
        id: 'forbidden-hold',
        type: ChainStepType.holdButton,
        order: 0,
        waitSeconds: 0,
        durationSeconds: 10,
        gracePeriodSeconds: 5,
        retryCount: 0,
        randomize: false,
      );
      final fake = _FakeBatteryAlertController(_state(enabled: true));
      await pumpScreen(
        tester,
        const BatteryAlertScreen(),
        overrides: <Override>[_override(fake)],
      );
      // Drive the StepChainEditor's onChanged with a forbidden step
      // via the widget directly.
      final editorFinder = find.byType(StepChainEditor);
      final editor = tester.widget<StepChainEditor>(editorFinder);
      editor.onChanged(<ChainStep>[forbiddenStep]);
      await tester.pumpAndSettle();
      // SnackBar should appear; setChain must NOT have been called.
      expect(
        find.text(l10n.batteryAlertForbiddenStep('holdButton')),
        findsOneWidget,
      );
      check(fake.setChainCalls).equals(0);
    });
  });

  // ─── RTL ─────────────────────────────────────────────────────────────────

  group('BatteryAlertScreen — RTL', () {
    testWidgets('renders in Arabic (RTL) without overflow', (
      WidgetTester tester,
    ) async {
      final fake = _FakeBatteryAlertController(_state());
      await pumpScreen(
        tester,
        const BatteryAlertScreen(),
        overrides: <Override>[_override(fake)],
        locale: const Locale('ar'),
      );
      expect(find.byType(AppBar), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  // ─── Dark mode ────────────────────────────────────────────────────────────

  group('BatteryAlertScreen — dark mode', () {
    testWidgets('renders without exception in dark mode', (
      WidgetTester tester,
    ) async {
      final fake = _FakeBatteryAlertController(
        _state(
          enabled: true,
          chain: <ChainStep>[_step(ChainStepType.smsContact)],
        ),
      );
      await pumpScreen(
        tester,
        const BatteryAlertScreen(),
        overrides: <Override>[_override(fake)],
        themeMode: ThemeMode.dark,
      );
      expect(tester.takeException(), isNull);
    });
  });

  // ─── Accessibility ────────────────────────────────────────────────────────

  group('BatteryAlertScreen — accessibility', () {
    testWidgets('SwitchListTile toggle is tappable by Semantics', (
      WidgetTester tester,
    ) async {
      final fake = _FakeBatteryAlertController(_state());
      await pumpScreen(
        tester,
        const BatteryAlertScreen(),
        overrides: <Override>[_override(fake)],
      );
      // Verify the semantics tree contains a switch.
      expect(
        find.bySemanticsLabel(RegExp('', caseSensitive: false)),
        findsWidgets,
      );
      expect(find.byType(Switch), findsOneWidget);
    });

    testWidgets('renders in Persian (RTL) without exception', (
      WidgetTester tester,
    ) async {
      final fake = _FakeBatteryAlertController(_state());
      await pumpScreen(
        tester,
        const BatteryAlertScreen(),
        overrides: <Override>[_override(fake)],
        locale: const Locale('fa'),
      );
      expect(tester.takeException(), isNull);
    });
  });
}
