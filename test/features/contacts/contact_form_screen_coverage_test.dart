/// Coverage filler for [ContactFormScreen]:
///   * Save happy-path with blank relationship + language (nulls
///     hit the ternary-else on lines 90-95).
///   * Save happy-path navigates back via pop after persisting
///     (covers the `if (mounted) context.pop()` branch line 105).
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/features/contacts/contact_form_screen.dart';

import '../fake_repositories.dart';
import '../widget_test_helpers.dart';

void main() {
  testWidgets(
    'ContactFormScreen Save with blank relationship + language persists nulls',
    (tester) async {
      final repo = FakeContactsRepository();
      await tester.pumpWidget(hostScreenPushed(
        overrides: [contactsRepositoryProvider.overrideWithValue(repo)],
        child: const ContactFormScreen(),
      ));
      await tester.pumpAndSettle();
      final fields = find.descendant(
        of: find.byType(ContactFormScreen),
        matching: find.byType(TextFormField),
      );
      // Name + phone only (rel + lang left blank).
      await tester.enterText(fields.at(0), 'Blank');
      await tester.enterText(fields.at(1), '+15550000');
      await tester.pump();
      final save = find.descendant(
        of: find.byType(ContactFormScreen),
        matching: find.widgetWithText(FilledButton, 'Save'),
      );
      await tester.dragUntilVisible(
        save,
        find.descendant(
          of: find.byType(ContactFormScreen),
          matching: find.byType(Scrollable),
        ).first,
        const Offset(0, -100),
      );
      await tester.tap(save);
      await tester.pumpAndSettle();
      final stored = await repo.getAll();
      check(stored.length).equals(1);
      check(stored.single.relationship).isNull();
      check(stored.single.languageCode).isNull();
    },
  );

  testWidgets(
    'ContactFormScreen toggling channels off after turning on removes them',
    (tester) async {
      // Spec 04 §Contact Form lines 1351-1354: channel toggles are
      // CheckboxListTile rows, not FilterChips. Tap each non-SMS
      // checkbox twice (on, then off); SMS starts on.
      final repo = FakeContactsRepository();
      await tester.pumpWidget(hostScreenPushed(
        overrides: [contactsRepositoryProvider.overrideWithValue(repo)],
        child: const ContactFormScreen(),
      ));
      await tester.pumpAndSettle();
      final boxes = find.byType(CheckboxListTile);
      // 0=SMS, 1=WhatsApp, 2=Telegram, 3=Phone (per the form layout).
      for (final i in const [1, 2, 3]) {
        await tester.tap(boxes.at(i));
        await tester.pumpAndSettle();
        await tester.tap(boxes.at(i));
        await tester.pumpAndSettle();
      }
      // SMS starts on; tap it once (off), tap again (on).
      await tester.tap(boxes.at(0));
      await tester.pumpAndSettle();
      await tester.tap(boxes.at(0));
      await tester.pumpAndSettle();
      // All four checkboxes end up with SMS-on-only.
      final sms = tester.widget<CheckboxListTile>(boxes.at(0));
      check(sms.value).equals(true);
      final wa = tester.widget<CheckboxListTile>(boxes.at(1));
      check(wa.value).equals(false);
    },
  );

  testWidgets(
    'ContactFormScreen Save flows through the mounted pop guard',
    (tester) async {
      final repo = FakeContactsRepository();
      await tester.pumpWidget(hostScreenPushed(
        overrides: [contactsRepositoryProvider.overrideWithValue(repo)],
        child: const ContactFormScreen(),
      ));
      await tester.pumpAndSettle();
      final fields = find.descendant(
        of: find.byType(ContactFormScreen),
        matching: find.byType(TextFormField),
      );
      await tester.enterText(fields.at(0), 'Pop');
      await tester.enterText(fields.at(1), '+15551111');
      await tester.pump();
      final save = find.descendant(
        of: find.byType(ContactFormScreen),
        matching: find.widgetWithText(FilledButton, 'Save'),
      );
      await tester.dragUntilVisible(
        save,
        find.descendant(
          of: find.byType(ContactFormScreen),
          matching: find.byType(Scrollable),
        ).first,
        const Offset(0, -100),
      );
      await tester.tap(save);
      await tester.pumpAndSettle();
      // After pop, the form screen should no longer be visible.
      check(find.byType(ContactFormScreen).evaluate()).isEmpty();
    },
  );
}
