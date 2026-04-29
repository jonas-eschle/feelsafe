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
      final repo = FakeContactsRepository();
      await tester.pumpWidget(hostScreenPushed(
        overrides: [contactsRepositoryProvider.overrideWithValue(repo)],
        child: const ContactFormScreen(),
      ));
      await tester.pumpAndSettle();
      // 0=SMS (on by default), 1=WhatsApp, 2=Telegram, 3=Phone.
      final chips = find.byType(FilterChip);
      // Tap each non-SMS chip twice (on, then off).
      for (final i in const [1, 2, 3]) {
        await tester.tap(chips.at(i));
        await tester.pumpAndSettle();
        await tester.tap(chips.at(i));
        await tester.pumpAndSettle();
      }
      // SMS starts on; tap it once (off), tap again (on).
      await tester.tap(chips.at(0));
      await tester.pumpAndSettle();
      await tester.tap(chips.at(0));
      await tester.pumpAndSettle();
      // All four chips end up with SMS-on-only.
      final sms = tester.widget<FilterChip>(chips.at(0));
      check(sms.selected).equals(true);
      final wa = tester.widget<FilterChip>(chips.at(1));
      check(wa.selected).equals(false);
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
