/// Widget tests for [InfoIconButton].
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/core/widgets/info_icon_button.dart';

Widget _host({String title = 'About', String body = 'Help text here.'}) =>
    MaterialApp(
      home: Scaffold(
        body: InfoIconButton(title: title, body: body),
      ),
    );

void main() {
  testWidgets('renders a help_outline icon', (tester) async {
    await tester.pumpWidget(_host());
    check(find.byIcon(Icons.help_outline).evaluate().length).equals(1);
  });

  testWidgets('uses the title as the tooltip', (tester) async {
    await tester.pumpWidget(_host(title: 'Tooltip Title'));
    final iconBtn = tester.widget<IconButton>(find.byType(IconButton));
    check(iconBtn.tooltip).equals('Tooltip Title');
  });

  testWidgets('tap opens a bottom sheet with title + body', (tester) async {
    await tester.pumpWidget(_host(title: 'My Title', body: 'The body.'));
    await tester.tap(find.byType(IconButton));
    await tester.pumpAndSettle();
    check(find.text('My Title').evaluate().length).equals(1);
    check(find.text('The body.').evaluate().length).equals(1);
  });
}
