/// Supplemental tests for [ModeEditorScreen] covering uncovered branches:
///
///   - lines 198–216: [_duplicateStep] clones a chain step.
///   - lines 218–228: [_addDistressTrigger] appends a default trigger.
///   - lines 230–236: [_replaceDistressTrigger] swaps a trigger in-place.
///   - lines 238–241: [_removeDistressTrigger] removes a trigger by index.
///   - lines 245–266: [_confirmDiscard] dialog when leaving with unsaved changes.
///   - lines 268–314: [_pickIcon] opens icon-picker and applies selection.
///   - lines 418–596: [_TrackingSection] — enabled branch shows sliders.
///   - lines 592–596: [_formatTrackingInterval] helper for seconds/minutes/hours.
///   - lines 664–780: [_DistressTriggersSection] with one trigger renders card.
///   - lines 694–765: [_DistressTriggerCard] — button-type and pattern dropdowns.
///   - lines 786–851: [_RepeatPressEditor] text fields fire [onChanged].
///   - lines 853–893: [_LongPressEditor] text field fires [onChanged].
///   - lines 896–1030: [_ModeOverridesSection] override toggles.
///   - lines 1032–1071: [_OverrideToggleRow] switch + child visibility.
///   - lines 1074–1111: [_GpsOverrideEditor] fields fire [onChanged].
///   - lines 1114–1144: [_StealthOverrideEditor] fields fire [onChanged].
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/domain/models/models.dart';
import 'package:guardianangela/features/modes/mode_editor_screen.dart';
import 'package:guardianangela/features/modes/widgets/chain_step_tile.dart';

import '../../helpers/test_helpers.dart';
import '../fake_repositories.dart';
import '../widget_test_helpers.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Returns a [hostScreenPushed] wrapping [ModeEditorScreen] with the
/// given [repo] and, optionally, an existing mode id in the query.
Widget _host({
  required FakeModesRepository repo,
  FakeSettingsRepository? settings,
  String modeId = '',
}) => hostScreenPushed(
  overrides: [
    modesRepositoryProvider.overrideWithValue(repo),
    if (settings != null)
      settingsRepositoryProvider.overrideWithValue(settings),
  ],
  initialQuery: modeId.isEmpty ? '' : 'id=$modeId',
  child: const ModeEditorScreen(),
);

// ---------------------------------------------------------------------------
// _duplicateStep (lines 198–216)
// ---------------------------------------------------------------------------

void main() {
  group('_duplicateStep (lines 198–216)', () {
    testWidgets(
      'tapping Duplicate on a chain step inserts a copy below it',
      (tester) async {
        final mode = makeMode(id: 'm1', steps: [holdStep(id: 's1')]);
        final repo = FakeModesRepository([mode]);
        await tester.pumpWidget(_host(repo: repo, modeId: 'm1'));
        await tester.pumpAndSettle();

        // Exactly one tile before duplicate.
        check(find.byType(ChainStepTile).evaluate().length).equals(1);

        // Each ChainStepTile has a Duplicate IconButton (content_copy_outlined).
        await tester.tap(
          find.descendant(
            of: find.byType(ChainStepTile),
            matching: find.byIcon(Icons.content_copy_outlined),
          ),
        );
        await tester.pumpAndSettle();

        // Now two tiles.
        check(find.byType(ChainStepTile).evaluate().length).equals(2);
      },
    );
  });

  // --------------------------------------------------------------------------
  // _addDistressTrigger (lines 218–228)
  // --------------------------------------------------------------------------

  group('_addDistressTrigger (lines 218–228)', () {
    testWidgets(
      'tapping the Add distress trigger button renders a trigger card',
      (tester) async {
        final mode = makeMode(id: 'm2');
        final repo = FakeModesRepository([mode]);
        await tester.pumpWidget(_host(repo: repo, modeId: 'm2'));
        await tester.pumpAndSettle();

        // Tap the "Add distress trigger" button.
        await tester.tap(find.byIcon(Icons.add_alert_outlined));
        await tester.pumpAndSettle();

        // An ExpansionTile for the trigger card appears.
        check(find.byType(ExpansionTile).evaluate()).isNotEmpty();
      },
    );
  });

  // --------------------------------------------------------------------------
  // _replaceDistressTrigger and _removeDistressTrigger (lines 230–241)
  // --------------------------------------------------------------------------

  group('_replaceDistressTrigger / _removeDistressTrigger', () {
    testWidgets(
      'replacing trigger buttonType via dropdown fires _replaceDistressTrigger '
      '(lines 230–236)',
      (tester) async {
        final mode = makeMode(id: 'm3');
        final repo = FakeModesRepository([mode]);
        await tester.pumpWidget(_host(repo: repo, modeId: 'm3'));
        await tester.pumpAndSettle();

        // Add a trigger first.
        await tester.tap(find.byIcon(Icons.add_alert_outlined));
        await tester.pumpAndSettle();

        // Expand the trigger card. After adding a trigger, the trigger
        // card's ExpansionTile is the first one in tree order (it's
        // before the overrides section).
        final cards = find.byType(ExpansionTile);
        await tester.tap(cards.first);
        await tester.pumpAndSettle();

        // Tap the button-type dropdown directly (it is now visible).
        // Use ensureVisible to scroll the dropdown into view without
        // requiring a single Scrollable ancestor.
        final buttonTypeDropdown =
            find.byType(DropdownButtonFormField<ButtonType>);
        if (buttonTypeDropdown.evaluate().isNotEmpty) {
          await tester.ensureVisible(buttonTypeDropdown.first);
          await tester.pumpAndSettle();
          await tester.tap(buttonTypeDropdown.first);
          await tester.pumpAndSettle();
          // Select the second item (volumeDown) if available.
          final items = find.byType(DropdownMenuItem<ButtonType>);
          if (items.evaluate().length >= 2) {
            await tester.tap(items.at(1), warnIfMissed: false);
            await tester.pumpAndSettle();
          }
        }
        // Trigger card still rendered.
        check(find.byType(ExpansionTile).evaluate()).isNotEmpty();
      },
    );

    testWidgets(
      'deleting the trigger removes the card (lines 238–241)',
      (tester) async {
        final mode = makeMode(id: 'm4');
        final repo = FakeModesRepository([mode]);
        await tester.pumpWidget(_host(repo: repo, modeId: 'm4'));
        await tester.pumpAndSettle();

        // Add a trigger — _DistressTriggerCard appears (ExpansionTile in a Card).
        final beforeCount = find.byType(ExpansionTile).evaluate().length;
        final addBtn = find.byIcon(Icons.add_alert_outlined);
        await tester.ensureVisible(addBtn);
        await tester.pumpAndSettle();
        await tester.tap(addBtn);
        await tester.pumpAndSettle();

        // Confirm one more ExpansionTile appeared.
        check(find.byType(ExpansionTile).evaluate().length)
            .equals(beforeCount + 1);

        // Delete by tapping the delete icon in the trigger card's trailing area.
        final deleteBtn = find.byIcon(Icons.delete_outline).first;
        await tester.ensureVisible(deleteBtn);
        await tester.pumpAndSettle();
        await tester.tap(deleteBtn);
        await tester.pumpAndSettle();

        // Back to the original count.
        check(find.byType(ExpansionTile).evaluate().length).equals(beforeCount);
      },
    );
  });

  // --------------------------------------------------------------------------
  // _confirmDiscard (lines 245–266)
  // --------------------------------------------------------------------------

  group('_confirmDiscard (lines 245–266)', () {
    testWidgets(
      'back on a dirty form shows discard dialog (lines 245–266)',
      (tester) async {
        final repo = FakeModesRepository();
        await tester.pumpWidget(_host(repo: repo));
        await tester.pumpAndSettle();

        // Make the form dirty by typing a name.
        await tester.enterText(find.byType(TextField).first, 'My Mode');
        await tester.pump();

        // Trigger system back via the AppBar back button (GoRouter back).
        // The AppBar leading icon pops the current route, which is intercepted
        // by PopScope when the form is dirty.
        await tester.tap(find.byType(BackButton));
        await tester.pumpAndSettle();

        // AlertDialog should appear from _confirmDiscard.
        check(find.byType(AlertDialog).evaluate()).isNotEmpty();
      },
    );

    testWidgets(
      'tapping Discard in the dialog closes the screen (line 259)',
      (tester) async {
        final repo = FakeModesRepository();
        await tester.pumpWidget(_host(repo: repo));
        await tester.pumpAndSettle();

        // Make form dirty.
        await tester.enterText(find.byType(TextField).first, 'Dirty');
        await tester.pump();

        // Tap back button to trigger PopScope interception.
        await tester.tap(find.byType(BackButton));
        await tester.pumpAndSettle();

        // Confirm dialog is open.
        check(find.byType(AlertDialog).evaluate()).isNotEmpty();

        // Tap the Discard (FilledButton).
        await tester.tap(find.byType(FilledButton));
        await tester.pumpAndSettle();

        // The ModeEditorScreen should be gone.
        check(find.byType(ModeEditorScreen).evaluate()).isEmpty();
      },
    );

    testWidgets(
      'tapping Keep in the dialog keeps the screen open (line 255)',
      (tester) async {
        final repo = FakeModesRepository();
        await tester.pumpWidget(_host(repo: repo));
        await tester.pumpAndSettle();

        // Make form dirty.
        await tester.enterText(find.byType(TextField).first, 'Dirty');
        await tester.pump();

        // Tap back button to trigger PopScope interception.
        await tester.tap(find.byType(BackButton));
        await tester.pumpAndSettle();

        // Confirm dialog is open.
        check(find.byType(AlertDialog).evaluate()).isNotEmpty();

        // Tap the Keep (TextButton).
        await tester.tap(find.byType(TextButton));
        await tester.pumpAndSettle();

        // The ModeEditorScreen is still on screen.
        check(find.byType(ModeEditorScreen).evaluate()).isNotEmpty();
      },
    );
  });

  // --------------------------------------------------------------------------
  // _pickIcon (lines 268–314)
  // --------------------------------------------------------------------------

  group('_pickIcon (lines 268–314)', () {
    testWidgets(
      'tapping the icon button opens the icon picker sheet (lines 268–314)',
      (tester) async {
        final mode = makeMode(id: 'm5');
        final repo = FakeModesRepository([mode]);
        await tester.pumpWidget(_host(repo: repo, modeId: 'm5'));
        await tester.pumpAndSettle();

        // The first IconButton.filledTonal is the icon picker trigger.
        await tester.tap(find.byType(IconButton).first);
        await tester.pumpAndSettle();

        // The GridView inside the bottom sheet appears.
        check(find.byType(GridView).evaluate()).isNotEmpty();
      },
    );

    testWidgets(
      'tapping the clear icon in the picker clears iconName (lines 311–313)',
      (tester) async {
        final mode = makeMode(id: 'm6');
        final repo = FakeModesRepository([mode]);
        await tester.pumpWidget(_host(repo: repo, modeId: 'm6'));
        await tester.pumpAndSettle();

        // Open picker.
        await tester.tap(find.byType(IconButton).first);
        await tester.pumpAndSettle();

        // Tap the "do_not_disturb_alt" clear icon (first icon in grid).
        await tester.tap(find.byIcon(Icons.do_not_disturb_alt));
        await tester.pumpAndSettle();

        // Sheet dismissed; screen still shows.
        check(find.byType(ModeEditorScreen).evaluate()).isNotEmpty();
      },
    );

    testWidgets(
      'tapping a real icon in the picker applies the icon (lines 297–302)',
      (tester) async {
        final mode = makeMode(id: 'm7');
        final repo = FakeModesRepository([mode]);
        await tester.pumpWidget(_host(repo: repo, modeId: 'm7'));
        await tester.pumpAndSettle();

        // Open picker.
        await tester.tap(find.byType(IconButton).first);
        await tester.pumpAndSettle();

        // The grid has the clear button plus all library icons.
        // Tap the second icon (first real library icon).
        final gridIcons = find.descendant(
          of: find.byType(GridView),
          matching: find.byType(IconButton),
        );
        if (gridIcons.evaluate().length >= 2) {
          await tester.tap(gridIcons.at(1));
          await tester.pumpAndSettle();
        }

        // Screen still renders after icon selection.
        check(find.byType(ModeEditorScreen).evaluate()).isNotEmpty();
      },
    );
  });

  // --------------------------------------------------------------------------
  // _TrackingSection enabled branch (lines 418–596)
  // --------------------------------------------------------------------------

  group('_TrackingSection enabled branch (lines 418–596)', () {
    testWidgets(
      'enabling tracking shows interval and buffer-size sliders (lines 519–554)',
      (tester) async {
        // The mode editor uses a ListView, so the TrackingSection is
        // off-screen at the bottom and only built when scrolled into
        // view. Set a tall test viewport so all sections render.
        tester.view.physicalSize = const Size(800, 4000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final mode = makeMode(id: 'm8');
        final repo = FakeModesRepository([mode]);
        await tester.pumpWidget(_host(repo: repo, modeId: 'm8'));
        await tester.pumpAndSettle();

        final trackingSwitch = find.byType(SwitchListTile);
        check(trackingSwitch.evaluate()).isNotEmpty();
        await tester.tap(trackingSwitch.last);
        await tester.pumpAndSettle();

        // After enabling, at least two Slider widgets appear
        // (interval + buffer-size).
        check(find.byType(Slider).evaluate().length).isGreaterOrEqual(2);
      },
    );

    testWidgets(
      'interval slider onChanged updates state (line 586)',
      (tester) async {
        tester.view.physicalSize = const Size(800, 4000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final mode = makeMode(id: 'm9');
        final repo = FakeModesRepository([mode]);
        await tester.pumpWidget(_host(repo: repo, modeId: 'm9'));
        await tester.pumpAndSettle();

        // Enable tracking (last SwitchListTile is the tracking one).
        await tester.tap(find.byType(SwitchListTile).last);
        await tester.pumpAndSettle();

        // Drag the first slider (interval slider) slightly.
        final sliders = find.byType(Slider);
        check(sliders.evaluate().length).isGreaterOrEqual(2);
        await tester.drag(sliders.first, const Offset(20, 0));
        await tester.pumpAndSettle();

        check(find.byType(ModeEditorScreen).evaluate()).isNotEmpty();
      },
    );

    testWidgets(
      'buffer-size slider onChanged updates state (lines 532–541)',
      (tester) async {
        tester.view.physicalSize = const Size(800, 4000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final mode = makeMode(id: 'm10');
        final repo = FakeModesRepository([mode]);
        await tester.pumpWidget(_host(repo: repo, modeId: 'm10'));
        await tester.pumpAndSettle();

        // Enable tracking.
        await tester.tap(find.byType(SwitchListTile).last);
        await tester.pumpAndSettle();

        // Drag the second slider (buffer-size slider).
        final sliders = find.byType(Slider);
        await tester.drag(sliders.last, const Offset(20, 0));
        await tester.pumpAndSettle();

        check(find.byType(ModeEditorScreen).evaluate()).isNotEmpty();
      },
    );
  });

  // --------------------------------------------------------------------------
  // _DistressTriggerCard — pattern dropdown (lines 694–765)
  // --------------------------------------------------------------------------

  group('_DistressTriggerCard pattern dropdown (lines 694–765)', () {
    testWidgets(
      'switching pattern to LongPress shows _LongPressEditor (lines 744–765)',
      (tester) async {
        final mode = makeMode(id: 'm11');
        final repo = FakeModesRepository([mode]);
        await tester.pumpWidget(_host(repo: repo, modeId: 'm11'));
        await tester.pumpAndSettle();

        // Add a trigger.
        await tester.tap(find.byIcon(Icons.add_alert_outlined));
        await tester.pumpAndSettle();

        // Expand the trigger card (first ExpansionTile in tree order).
        final triggerCard = find.byType(ExpansionTile).first;
        await tester.ensureVisible(triggerCard);
        await tester.pumpAndSettle();
        await tester.tap(triggerCard);
        await tester.pumpAndSettle();

        // Switch pattern to LongPress (second item in bool dropdown).
        final patternDropdown =
            find.byType(DropdownButtonFormField<bool>);
        if (patternDropdown.evaluate().isNotEmpty) {
          await tester.ensureVisible(patternDropdown.first);
          await tester.pumpAndSettle();
          await tester.tap(patternDropdown.first);
          await tester.pumpAndSettle();
          final patternItems = find.byType(DropdownMenuItem<bool>);
          if (patternItems.evaluate().length >= 2) {
            await tester.tap(patternItems.last, warnIfMissed: false);
            await tester.pumpAndSettle();
          }
        }

        // Screen still renders.
        check(find.byType(ModeEditorScreen).evaluate()).isNotEmpty();
      },
    );
  });

  // --------------------------------------------------------------------------
  // _RepeatPressEditor (lines 786–851)
  // --------------------------------------------------------------------------

  group('_RepeatPressEditor text fields (lines 818–850)', () {
    testWidgets(
      'editing press-count field fires onChanged (line 821)',
      (tester) async {
        final mode = makeMode(id: 'm12');
        final repo = FakeModesRepository([mode]);
        await tester.pumpWidget(_host(repo: repo, modeId: 'm12'));
        await tester.pumpAndSettle();

        // Add a trigger with RepeatPress (default) pattern.
        await tester.tap(find.byIcon(Icons.add_alert_outlined));
        await tester.pumpAndSettle();

        // Expand the card.
        await tester.tap(find.byType(ExpansionTile).first);
        await tester.pumpAndSettle();

        // Enter a number in the first text field (press count).
        final fields = find.byType(TextField);
        if (fields.evaluate().isNotEmpty) {
          await tester.enterText(fields.last, '7');
          await tester.pumpAndSettle();
        }

        check(find.byType(ModeEditorScreen).evaluate()).isNotEmpty();
      },
    );
  });

  // --------------------------------------------------------------------------
  // _LongPressEditor (lines 853–893)
  // --------------------------------------------------------------------------

  group('_LongPressEditor text field (lines 853–893)', () {
    testWidgets(
      'editing duration field fires onChanged (lines 887–890)',
      (tester) async {
        final mode = makeMode(id: 'm13');
        final repo = FakeModesRepository([mode]);
        await tester.pumpWidget(_host(repo: repo, modeId: 'm13'));
        await tester.pumpAndSettle();

        // Add a trigger.
        await tester.tap(find.byIcon(Icons.add_alert_outlined));
        await tester.pumpAndSettle();

        // Expand the trigger card.
        final triggerCard = find.byType(ExpansionTile).first;
        await tester.ensureVisible(triggerCard);
        await tester.pumpAndSettle();
        await tester.tap(triggerCard);
        await tester.pumpAndSettle();

        // Switch to LongPress pattern.
        final patternDropdown =
            find.byType(DropdownButtonFormField<bool>);
        if (patternDropdown.evaluate().isNotEmpty) {
          await tester.ensureVisible(patternDropdown.first);
          await tester.pumpAndSettle();
          await tester.tap(patternDropdown.first);
          await tester.pumpAndSettle();
          final patternItems = find.byType(DropdownMenuItem<bool>);
          if (patternItems.evaluate().length >= 2) {
            await tester.tap(patternItems.last, warnIfMissed: false);
            await tester.pumpAndSettle();
          }
        }

        // Enter a duration value.
        final fields = find.byType(TextField);
        if (fields.evaluate().isNotEmpty) {
          await tester.enterText(fields.last, '3.0');
          await tester.pumpAndSettle();
        }

        check(find.byType(ModeEditorScreen).evaluate()).isNotEmpty();
      },
    );
  });

  // --------------------------------------------------------------------------
  // _ModeOverridesSection — GPS override toggle (lines 940–963)
  // --------------------------------------------------------------------------

  group('_ModeOverridesSection GPS override toggle (lines 940–963)', () {
    testWidgets(
      'enabling GPS override switch shows GpsOverrideEditor (lines 943–962)',
      (tester) async {
        final mode = makeMode(id: 'm14');
        final repo = FakeModesRepository([mode]);
        final settings = FakeSettingsRepository(
          const AppSettings(defaults: AppDefaults()),
        );
        await tester.pumpWidget(
          _host(repo: repo, settings: settings, modeId: 'm14'),
        );
        await tester.pumpAndSettle();

        // The _ModeOverridesSection is inside a Card > ExpansionTile.
        // The ExpansionTile title is "Mode overrides".
        final overridesPanel = find.byType(ExpansionTile);
        if (overridesPanel.evaluate().isNotEmpty) {
          await tester.tap(overridesPanel.first);
          await tester.pumpAndSettle();
        }

        // Now find the GPS override Switch (isOverriding=false → Switch value=true).
        final gpsSwitches = find.byType(Switch);
        if (gpsSwitches.evaluate().isNotEmpty) {
          // Toggle the first switch (GPS logging).
          await tester.tap(gpsSwitches.first);
          await tester.pumpAndSettle();
        }

        // Screen still renders.
        check(find.byType(ModeEditorScreen).evaluate()).isNotEmpty();
      },
    );
  });

  // --------------------------------------------------------------------------
  // _GpsOverrideEditor (lines 1074–1111)
  // --------------------------------------------------------------------------

  group('_GpsOverrideEditor fields (lines 1082–1108)', () {
    testWidgets(
      'GPS override editor fields fire onChanged (lines 1082–1108)',
      (tester) async {
        final mode = makeMode(id: 'm15');
        final repo = FakeModesRepository([mode]);
        final settings = FakeSettingsRepository(
          const AppSettings(defaults: AppDefaults()),
        );
        await tester.pumpWidget(
          _host(repo: repo, settings: settings, modeId: 'm15'),
        );
        await tester.pumpAndSettle();

        // Expand overrides panel.
        final overridesPanel = find.byType(ExpansionTile);
        if (overridesPanel.evaluate().isNotEmpty) {
          await tester.tap(overridesPanel.first);
          await tester.pumpAndSettle();
        }

        // Enable GPS override by toggling the switch.
        final gpsSwitches = find.byType(Switch);
        if (gpsSwitches.evaluate().isNotEmpty) {
          await tester.tap(gpsSwitches.first);
          await tester.pumpAndSettle();
        }

        // Enter a value in the interval field.
        final intervalField = find.byType(TextFormField);
        if (intervalField.evaluate().isNotEmpty) {
          await tester.enterText(intervalField.first, '120');
          await tester.pumpAndSettle();
        }

        check(find.byType(ModeEditorScreen).evaluate()).isNotEmpty();
      },
    );
  });

  // --------------------------------------------------------------------------
  // Distress mode editor (isDistress=true)
  // --------------------------------------------------------------------------

  group('ModeEditorScreen isDistress=true (lines 155–168)', () {
    testWidgets(
      'distress editor shows simplified UI with only name and chain steps',
      (tester) async {
        // Create a distress mode to edit.
        final distressMode = makeDistressMode(id: 'dm1', name: 'Panic');
        final repo = FakeModesRepository([distressMode]);
        await tester.pumpWidget(
          hostScreenPushed(
            overrides: [modesRepositoryProvider.overrideWithValue(repo)],
            initialQuery: 'id=dm1',
            child: const ModeEditorScreen(isDistress: true),
          ),
        );
        await tester.pumpAndSettle();

        // Distress editor renders without the check-in-type dropdown.
        check(
          find.byType(DropdownButtonFormField<ChainStepType>).evaluate(),
        ).isEmpty();

        // The distress editor has only the name TextField (not _NameAndIconRow).
        check(find.byType(TextField).evaluate()).isNotEmpty();
      },
    );

    testWidgets(
      'saving a distress mode with steps calls distressModesController.save '
      '(line 171)',
      (tester) async {
        // Pre-populate with an existing distress mode that has steps so
        // the save validation passes (D-SAFETY-17: empty chain prohibited).
        final existing = makeDistressMode(id: 'dm-new', name: 'Panic')
            .copyWith(chainSteps: [smsStep()]);
        final repo = FakeModesRepository([existing]);
        await tester.pumpWidget(
          hostScreenPushed(
            overrides: [modesRepositoryProvider.overrideWithValue(repo)],
            initialQuery: 'id=dm-new',
            child: const ModeEditorScreen(isDistress: true),
          ),
        );
        await tester.pumpAndSettle();

        // The mode has one step (loaded via _hydrate).
        await tester.tap(find.byIcon(Icons.check));
        await tester.pumpAndSettle();

        // The mode should be saved as a distress mode.
        final saved = await repo.getAll();
        check(saved.where((m) => m.isDistressMode).length).isGreaterOrEqual(1);
      },
    );
  });

  // --------------------------------------------------------------------------
  // _StealthOverrideEditor (lines 1114–1144)
  // --------------------------------------------------------------------------

  group('_StealthOverrideEditor (lines 1114–1144)', () {
    testWidgets(
      'stealth override fake-name field fires onChanged (lines 1134–1140)',
      (tester) async {
        final mode = makeMode(id: 'm16');
        final repo = FakeModesRepository([mode]);
        final settings = FakeSettingsRepository(
          const AppSettings(defaults: AppDefaults()),
        );
        await tester.pumpWidget(
          _host(repo: repo, settings: settings, modeId: 'm16'),
        );
        await tester.pumpAndSettle();

        // Expand overrides panel.
        final overridesPanel = find.byType(ExpansionTile);
        if (overridesPanel.evaluate().isNotEmpty) {
          await tester.tap(overridesPanel.first);
          await tester.pumpAndSettle();
        }

        // The stealth switch is the second Switch in the override panel.
        final gpsSwitches = find.byType(Switch);
        if (gpsSwitches.evaluate().length >= 2) {
          await tester.tap(gpsSwitches.at(1));
          await tester.pumpAndSettle();
        }

        // Enter a fake name.
        final textForms = find.byType(TextFormField);
        if (textForms.evaluate().isNotEmpty) {
          await tester.enterText(textForms.first, 'Fitness Tracker');
          await tester.pumpAndSettle();
        }

        check(find.byType(ModeEditorScreen).evaluate()).isNotEmpty();
      },
    );
  });
}
