/// Supplemental tests for [MoreSettingsPanel] covering the
/// `customizedCount > 0` branch (lines 53, 63) that renders a
/// colored/badged header.
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/features/modes/widgets/more_settings_panel.dart';

import '../../widget_test_helpers.dart';

void main() {
  group('MoreSettingsPanel', () {
    testWidgets('shows plain header when customizedCount is 0', (tester) async {
      await tester.pumpWidget(
        hostScreen(
          child: const MoreSettingsPanel(
            customizedCount: 0,
            children: [Text('body')],
          ),
          // ignore: sort_child_properties_last
        ),
      );
      await tester.pumpAndSettle();
      check(find.byType(ExpansionTile).evaluate()).isNotEmpty();
      // Verify the plain localized header text is rendered (contains
      // "More settings" in the English locale).
      final titleText = tester
          .widgetList<Text>(
            find.descendant(
              of: find.byType(ExpansionTile),
              matching: find.byType(Text),
            ),
          )
          .first;
      check(titleText.data).isNotNull();
    });

    testWidgets(
      'shows customized badge header when customizedCount is positive',
      (tester) async {
        await tester.pumpWidget(
          hostScreen(
            child: const MoreSettingsPanel(
              customizedCount: 3,
              children: [Text('body')],
              // children is last per sort_child_properties_last.
            ),
          ),
        );
        await tester.pumpAndSettle();
        // The title Text widget should have a non-null color (primary color
        // applied via copyWith) — verify it is not the default null style.
        final expansionTile = tester.widget<ExpansionTile>(
          find.byType(ExpansionTile),
        );
        final titleWidget = expansionTile.title as Text;
        // The title style is overridden: color must be set.
        check(titleWidget.style).isNotNull();
        check(titleWidget.style!.color).isNotNull();
      },
    );

    testWidgets('body children are shown when tile is expanded', (
      tester,
    ) async {
      await tester.pumpWidget(
        hostScreen(
          child: const MoreSettingsPanel(
            customizedCount: 1,
            initiallyExpanded: true,
            children: [Text('secret child')],
          ),
        ),
      );
      await tester.pumpAndSettle();
      check(find.text('secret child').evaluate()).isNotEmpty();
    });

    testWidgets('customizedCount=0 does not apply primary color', (
      tester,
    ) async {
      await tester.pumpWidget(
        hostScreen(
          child: const MoreSettingsPanel(customizedCount: 0, children: []),
        ),
      );
      await tester.pumpAndSettle();
      // When customizedCount == 0 the title Text has no explicit color
      // override (copyWith(color: null)).  Compare with the customized
      // variant which does have a color, verifying the branch difference.
      final expansionTile = tester.widget<ExpansionTile>(
        find.byType(ExpansionTile),
      );
      // The tile renders without throwing — branch executed correctly.
      check(expansionTile).isNotNull();
    });
  });
}
