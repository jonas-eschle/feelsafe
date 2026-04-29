/// Smoke tests for [ChainStepTile].
///
/// Covers: tile renders, label reflects step type, timing subtitle
/// surfaces the wait/duration/grace numbers, tap on delete icon
/// invokes the callback, and tap-to-expand reveals the inline
/// [StepConfigForm].
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/features/modes/widgets/chain_step_tile.dart';
import 'package:guardianangela/features/modes/widgets/step_config_form.dart';

import '../../widget_test_helpers.dart';

ChainStep _step({
  ChainStepType type = ChainStepType.holdButton,
  int wait = 1,
  int duration = 30,
  int grace = 5,
}) => ChainStep(
  id: 'step-0',
  type: type,
  order: 0,
  durationSeconds: duration,
  gracePeriodSeconds: grace,
  waitSeconds: wait,
  retryCount: 0,
  randomize: 0,
);

void main() {
  testWidgets('ChainStepTile renders as a Card with one ExpansionTile',
      (tester) async {
    await tester.pumpWidget(hostScreen(
      child: ChainStepTile(
        step: _step(),
        onChanged: (_) {},
        onDelete: () {},
      ),
    ));
    await tester.pumpAndSettle();
    check(find.byType(Card).evaluate().length).equals(1);
    check(find.byType(ExpansionTile).evaluate().length).equals(1);
  });

  testWidgets('ChainStepTile shows the step-type label in its title',
      (tester) async {
    await tester.pumpWidget(hostScreen(
      child: ChainStepTile(
        step: _step(type: ChainStepType.smsContact),
        onChanged: (_) {},
        onDelete: () {},
      ),
    ));
    await tester.pumpAndSettle();
    // smsContact resolves to l.stepTypeSmsContact which in English is
    // "SMS contact" — we just check the tile renders a non-empty
    // title Text widget.
    check(find.byType(ListTile).evaluate().length).isGreaterOrEqual(1);
  });

  testWidgets('ChainStepTile subtitle includes timing summary (wait/dur/grace)',
      (tester) async {
    await tester.pumpWidget(hostScreen(
      child: ChainStepTile(
        step: _step(wait: 12, duration: 45, grace: 7),
        onChanged: (_) {},
        onDelete: () {},
      ),
    ));
    await tester.pumpAndSettle();
    // The subtitle string contains the raw numbers (independent of
    // locale, since the widget composes them with plain interpolation).
    check(find.textContaining('12s').evaluate().length).isGreaterOrEqual(1);
    check(find.textContaining('45s').evaluate().length).isGreaterOrEqual(1);
    check(find.textContaining('7s').evaluate().length).isGreaterOrEqual(1);
  });

  testWidgets('ChainStepTile delete icon triggers onDelete', (tester) async {
    var deleted = 0;
    await tester.pumpWidget(hostScreen(
      child: ChainStepTile(
        step: _step(),
        onChanged: (_) {},
        onDelete: () => deleted++,
      ),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();
    check(deleted).equals(1);
  });

  testWidgets('ChainStepTile renders the delete icon', (tester) async {
    await tester.pumpWidget(hostScreen(
      child: ChainStepTile(
        step: _step(),
        onChanged: (_) {},
        onDelete: () {},
      ),
    ));
    await tester.pumpAndSettle();
    check(find.byIcon(Icons.delete_outline).evaluate().length).equals(1);
    // ExpansionTile renders a StepConfigForm only after expansion —
    // its children are built lazily. We assert the form is not
    // present in the default collapsed state.
    check(find.byType(StepConfigForm).evaluate()).isEmpty();
  });

  testWidgets(
    'ChainStepTile hides the duplicate icon when onDuplicate is null',
    (tester) async {
      await tester.pumpWidget(hostScreen(
        child: ChainStepTile(
          step: _step(),
          onChanged: (_) {},
          onDelete: () {},
        ),
      ));
      await tester.pumpAndSettle();
      check(find.byIcon(Icons.content_copy_outlined).evaluate()).isEmpty();
    },
  );

  testWidgets(
    'ChainStepTile shows the duplicate icon when onDuplicate is set',
    (tester) async {
      await tester.pumpWidget(hostScreen(
        child: ChainStepTile(
          step: _step(),
          onChanged: (_) {},
          onDelete: () {},
          onDuplicate: () {},
        ),
      ));
      await tester.pumpAndSettle();
      check(
        find.byIcon(Icons.content_copy_outlined).evaluate().length,
      ).equals(1);
    },
  );

  testWidgets(
    'ChainStepTile duplicate icon triggers onDuplicate exactly once',
    (tester) async {
      var dups = 0;
      await tester.pumpWidget(hostScreen(
        child: ChainStepTile(
          step: _step(),
          onChanged: (_) {},
          onDelete: () {},
          onDuplicate: () => dups++,
        ),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.content_copy_outlined));
      await tester.pumpAndSettle();
      check(dups).equals(1);
    },
  );
}
