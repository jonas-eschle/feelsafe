/// Extended coverage tests for [ChainStepTile].
///
/// Covers the uncovered lines (~11) relating to:
///  * Step-type dropdown: selecting a *different* type fires onChanged
///    with a new step whose config is null (reset) but timings are
///    preserved.
///  * Step-type dropdown: selecting the *same* type does NOT fire
///    onChanged (the early-return guard `if (t == null || t == step.type)`).
///  * Delete button: tapping it fires onDelete (also covered in base
///    test but reproduced here with explicit callback capture for clarity).
///  * Expansion reveals StepConfigForm.
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/models/step_config.dart';
import 'package:guardianangela/features/modes/widgets/chain_step_tile.dart';
import 'package:guardianangela/features/modes/widgets/step_config_form.dart';

import '../../widget_test_helpers.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

ChainStep _step({
  String id = 'step-0',
  ChainStepType type = ChainStepType.holdButton,
  int wait = 5,
  int duration = 30,
  int grace = 10,
  int order = 0,
  StepConfig? config,
}) => ChainStep(
  id: id,
  type: type,
  order: order,
  durationSeconds: duration,
  gracePeriodSeconds: grace,
  waitSeconds: wait,
  retryCount: 0,
  randomize: 0,
  config: config,
);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('ChainStepTile – step-type dropdown', () {
    testWidgets(
      'selecting a DIFFERENT type fires onChanged with null config and '
      'preserved timings',
      (tester) async {
        ChainStep? received;
        final original = _step(
          type: ChainStepType.holdButton,
          wait: 7,
          duration: 45,
          grace: 12,
          config: const HoldButtonConfig(releaseSensitivity: 0.5),
        );

        await tester.pumpWidget(hostScreen(
          child: SingleChildScrollView(
            child: ChainStepTile(
              step: original,
              onChanged: (s) => received = s,
              onDelete: () {},
            ),
          ),
        ));
        await tester.pumpAndSettle();

        // Expand the tile to reveal the dropdown.
        await tester.tap(find.byType(ExpansionTile));
        await tester.pumpAndSettle();

        // Open the step-type dropdown.
        final dropdown = find.byType(DropdownButtonFormField<ChainStepType>);
        await tester.tap(dropdown);
        await tester.pumpAndSettle();

        // Choose a different type: smsContact.
        // The dropdown overlay prepends one hidden selected-value copy
        // before the visible items, so smsContact (enum index 4) is at
        // position 5 in the DropdownMenuItem list.
        final smsItem = find.byWidgetPredicate(
          (w) =>
              w is DropdownMenuItem<ChainStepType> &&
              w.value == ChainStepType.smsContact,
        );
        await tester.tap(smsItem.last);
        await tester.pumpAndSettle();

        // onChanged must have fired.
        check(received).isNotNull();
        check(received!.type).equals(ChainStepType.smsContact);

        // Timings must be preserved.
        check(received!.waitSeconds).equals(7);
        check(received!.durationSeconds).equals(45);
        check(received!.gracePeriodSeconds).equals(12);

        // Config must have been reset to null (type-specific config is
        // incompatible with the new type).
        check(received!.config).isNull();
      },
    );

    testWidgets(
      'selecting the SAME type does NOT fire onChanged',
      (tester) async {
        var callCount = 0;

        await tester.pumpWidget(hostScreen(
          child: SingleChildScrollView(
            child: ChainStepTile(
              step: _step(type: ChainStepType.holdButton),
              onChanged: (_) => callCount++,
              onDelete: () {},
            ),
          ),
        ));
        await tester.pumpAndSettle();

        // Expand to reveal dropdown.
        await tester.tap(find.byType(ExpansionTile));
        await tester.pumpAndSettle();

        // Open dropdown.
        await tester.tap(find.byType(DropdownButtonFormField<ChainStepType>));
        await tester.pumpAndSettle();

        // Re-select "holdButton" (the current type — index 0).
        await tester.tap(
          find.byType(DropdownMenuItem<ChainStepType>).first,
        );
        await tester.pumpAndSettle();

        // onChanged must NOT have been called.
        check(callCount).equals(0);
      },
    );

    testWidgets(
      'each ChainStepType value appears as a DropdownMenuItem in the tile',
      (tester) async {
        await tester.pumpWidget(hostScreen(
          child: SingleChildScrollView(
            child: ChainStepTile(
              step: _step(),
              onChanged: (_) {},
              onDelete: () {},
            ),
          ),
        ));
        await tester.pumpAndSettle();

        // Expand the tile.
        await tester.tap(find.byType(ExpansionTile));
        await tester.pumpAndSettle();

        // Open dropdown to enumerate all items.
        await tester.tap(find.byType(DropdownButtonFormField<ChainStepType>));
        await tester.pumpAndSettle();

        // Flutter's DropdownButton inserts one extra hidden item for the
        // currently-selected value. So total rendered items =
        // ChainStepType.values.length + 1 (the hidden copy).
        // We verify each distinct enum value has at least one item widget.
        final items = find.byType(DropdownMenuItem<ChainStepType>).evaluate();
        check(items.length).isGreaterOrEqual(ChainStepType.values.length);
        for (final t in ChainStepType.values) {
          check(
            find.byWidgetPredicate(
              (w) => w is DropdownMenuItem<ChainStepType> && w.value == t,
            ).evaluate(),
          ).isNotEmpty();
        }
      },
    );

    testWidgets(
      'type swap preserves id and order fields',
      (tester) async {
        ChainStep? received;
        final original = _step(
          id: 'custom-id',
          type: ChainStepType.holdButton,
          order: 3,
        );

        await tester.pumpWidget(hostScreen(
          child: SingleChildScrollView(
            child: ChainStepTile(
              step: original,
              onChanged: (s) => received = s,
              onDelete: () {},
            ),
          ),
        ));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(ExpansionTile));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(DropdownButtonFormField<ChainStepType>));
        await tester.pumpAndSettle();

        // Pick smsContact — use predicate to avoid index confusion with
        // the hidden selected-value copy the overlay prepends.
        final smsItem = find.byWidgetPredicate(
          (w) =>
              w is DropdownMenuItem<ChainStepType> &&
              w.value == ChainStepType.smsContact,
        );
        await tester.tap(smsItem.last);
        await tester.pumpAndSettle();

        check(received).isNotNull();
        check(received!.id).equals('custom-id');
        check(received!.order).equals(3);
      },
    );
  });

  group('ChainStepTile – delete button', () {
    testWidgets(
      'onDelete callback fires exactly once on tap',
      (tester) async {
        var deleteCount = 0;

        await tester.pumpWidget(hostScreen(
          child: ChainStepTile(
            step: _step(),
            onChanged: (_) {},
            onDelete: () => deleteCount++,
          ),
        ));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.delete_outline));
        await tester.pumpAndSettle();

        check(deleteCount).equals(1);
      },
    );

    testWidgets(
      'delete icon is visible even when tile is collapsed',
      (tester) async {
        await tester.pumpWidget(hostScreen(
          child: ChainStepTile(
            step: _step(),
            onChanged: (_) {},
            onDelete: () {},
          ),
        ));
        await tester.pumpAndSettle();

        // The tile is collapsed by default; delete icon must still be
        // visible in the trailing slot of ExpansionTile.
        check(find.byIcon(Icons.delete_outline).evaluate()).isNotEmpty();
      },
    );
  });

  group('ChainStepTile – expansion reveals StepConfigForm', () {
    testWidgets(
      'tapping the tile expands it and reveals StepConfigForm',
      (tester) async {
        await tester.pumpWidget(hostScreen(
          child: SingleChildScrollView(
            child: ChainStepTile(
              step: _step(),
              onChanged: (_) {},
              onDelete: () {},
            ),
          ),
        ));
        await tester.pumpAndSettle();

        // Collapsed state: no StepConfigForm.
        check(find.byType(StepConfigForm).evaluate()).isEmpty();

        // Expand by tapping the ListTile header area.
        await tester.tap(find.byType(ExpansionTile));
        await tester.pumpAndSettle();

        // Expanded: StepConfigForm must be present.
        check(find.byType(StepConfigForm).evaluate()).isNotEmpty();
      },
    );
  });
}
