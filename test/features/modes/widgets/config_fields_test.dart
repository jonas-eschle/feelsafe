/// Widget tests for the shared config-field editors' external-value sync
/// (`didUpdateWidget`): when the PARENT swaps in a new value (e.g. Reset to
/// defaults replaces the staged config), the text controller must follow —
/// and must NOT clobber user-typed text when the value is unchanged.
library;

import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/features/modes/widgets/config_fields.dart';

Future<void> _pump(WidgetTester tester, Widget field) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(body: Center(child: field)),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('LabeledTextField — external value sync', () {
    testWidgets('a new parent value replaces the controller text', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        LabeledTextField(label: 'Name', value: 'Angela', onChanged: (_) {}),
      );
      expect(find.text('Angela'), findsOneWidget);

      // Parent rebuild with a different value (e.g. Reset to defaults).
      await _pump(
        tester,
        LabeledTextField(label: 'Name', value: 'Mom', onChanged: (_) {}),
      );
      expect(find.text('Mom'), findsOneWidget);
      expect(find.text('Angela'), findsNothing);
    });

    testWidgets('an unchanged parent value keeps user-typed text', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        LabeledTextField(label: 'Name', value: 'Angela', onChanged: (_) {}),
      );
      await tester.enterText(find.byType(TextField), 'typing…');

      // Parent rebuild with the SAME value must not clobber the draft.
      await _pump(
        tester,
        LabeledTextField(label: 'Name', value: 'Angela', onChanged: (_) {}),
      );
      expect(find.text('typing…'), findsOneWidget);
    });
  });

  group('MessageTemplateField — external value sync', () {
    testWidgets('a new parent value replaces the controller text', (
      WidgetTester tester,
    ) async {
      MessageTemplateField field(String? value) => MessageTemplateField(
        label: 'Template',
        hint: 'default',
        value: value,
        placeholders: const <String>['{name}'],
        onChanged: (_) {},
      );
      await _pump(tester, field(null));
      await _pump(tester, field('Help {name}'));
      expect(find.text('Help {name}'), findsOneWidget);

      // And back to null → the field empties (use the seeded default).
      await _pump(tester, field(null));
      expect(find.text('Help {name}'), findsNothing);
    });
  });

  group('IntTextField — external value sync', () {
    testWidgets('a new parent value replaces the controller text', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        IntTextField(label: 'Wait', value: 10, onChanged: (_) {}),
      );
      expect(find.text('10'), findsOneWidget);

      await _pump(
        tester,
        IntTextField(label: 'Wait', value: 25, onChanged: (_) {}),
      );
      expect(find.text('25'), findsOneWidget);
      expect(find.text('10'), findsNothing);
    });
  });
}
