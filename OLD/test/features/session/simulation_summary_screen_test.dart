/// Smoke tests for [SimulationSummaryScreen].
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/domain/orchestration/event_strategy.dart';
import 'package:guardianangela/features/session/simulation_summary_screen.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';
import 'package:guardianangela/l10n/l10n/app_localizations_en.dart';

import '../widget_test_helpers.dart';

void main() {
  testWidgets('SimulationSummaryScreen renders empty state', (tester) async {
    await tester.pumpWidget(
      hostScreenWithRouter(child: const SimulationSummaryScreen()),
    );
    await tester.pumpAndSettle();
    check(find.byType(SimulationSummaryScreen).evaluate().length).equals(1);
  });

  testWidgets('SimulationSummaryScreen has an AppBar', (tester) async {
    await tester.pumpWidget(
      hostScreenWithRouter(child: const SimulationSummaryScreen()),
    );
    await tester.pumpAndSettle();
    check(find.byType(AppBar).evaluate().length).equals(1);
  });

  testWidgets('SimulationSummaryScreen shows return CTA', (tester) async {
    await tester.pumpWidget(
      hostScreenWithRouter(child: const SimulationSummaryScreen()),
    );
    await tester.pumpAndSettle();
    check(find.byType(FilledButton).evaluate().length).equals(1);
  });

  // Bugs.json Warn 5 — resolveSimulationDescription rendering.
  group('resolveSimulationDescription (English locale)', () {
    final AppLocalizations l = AppLocalizationsEn();

    test('simLoudAlarm with flash=true renders flash tail', () {
      check(
        resolveSimulationDescription(
          l,
          const SimulationDescription('simLoudAlarm', {'flash': true}),
        ),
      ).equals('[SIM] Loud alarm + flash');
    });

    test('simLoudAlarm with flash=false renders vibrate tail', () {
      check(
        resolveSimulationDescription(
          l,
          const SimulationDescription('simLoudAlarm', {'flash': false}),
        ),
      ).equals('[SIM] Loud alarm + vibrate');
    });

    test('simSmsContact substitutes channel + count', () {
      check(
        resolveSimulationDescription(
          l,
          const SimulationDescription('simSmsContact', {
            'channel': 'sms',
            'count': 3,
          }),
        ),
      ).equals('[SIM] Would send sms to 3 contacts');
    });

    test('simFakeCallRing substitutes caller', () {
      check(
        resolveSimulationDescription(
          l,
          const SimulationDescription('simFakeCallRing', {'caller': 'Angela'}),
        ),
      ).equals('[SIM] Incoming call from Angela');
    });

    test('simCountdownWarning substitutes seconds', () {
      check(
        resolveSimulationDescription(
          l,
          const SimulationDescription('simCountdownWarning', {'seconds': 42}),
        ),
      ).equals('[SIM] 42s countdown warning');
    });

    test('simPhoneCall substitutes name', () {
      check(
        resolveSimulationDescription(
          l,
          const SimulationDescription('simPhoneCall', {'name': 'Alice'}),
        ),
      ).equals('[SIM] Would call Alice');
    });

    test('simNoContactToCall renders fixed phrase', () {
      check(
        resolveSimulationDescription(
          l,
          const SimulationDescription('simNoContactToCall'),
        ),
      ).equals('[SIM] No contact to call');
    });

    test('simCallEmergency substitutes number', () {
      check(
        resolveSimulationDescription(
          l,
          const SimulationDescription('simCallEmergency', {'number': '112'}),
        ),
      ).equals('[SIM] Would dial 112');
    });

    test('simHardwareButton renders fixed phrase', () {
      check(
        resolveSimulationDescription(
          l,
          const SimulationDescription('simHardwareButton'),
        ),
      ).equals('[SIM] Hardware trigger armed');
    });

    test('simHoldButton renders fixed phrase', () {
      check(
        resolveSimulationDescription(
          l,
          const SimulationDescription('simHoldButton'),
        ),
      ).equals('[SIM] Waiting for hold button');
    });

    test('simDisguisedReminder substitutes title', () {
      check(
        resolveSimulationDescription(
          l,
          const SimulationDescription('simDisguisedReminder', {
            'title': 'Milk tomorrow',
          }),
        ),
      ).equals('[SIM] Would show "Milk tomorrow"');
    });

    test('simDisguisedReminderEmpty renders fixed phrase', () {
      check(
        resolveSimulationDescription(
          l,
          const SimulationDescription('simDisguisedReminderEmpty'),
        ),
      ).equals('[SIM] No reminder template available');
    });

    test('simGpsArrivalTrigger renders fixed phrase', () {
      check(
        resolveSimulationDescription(
          l,
          const SimulationDescription('simGpsArrivalTrigger'),
        ),
      ).equals('[SIM] GPS arrival trigger fired');
    });

    test('simLowBatteryAlert renders fixed phrase', () {
      check(
        resolveSimulationDescription(
          l,
          const SimulationDescription('simLowBatteryAlert'),
        ),
      ).equals('[SIM] Low-battery alert fired');
    });

    test('unknown templateKey falls through to the raw key', () {
      check(
        resolveSimulationDescription(
          l,
          const SimulationDescription('unknownKey'),
        ),
      ).equals('unknownKey');
    });
  });
}
