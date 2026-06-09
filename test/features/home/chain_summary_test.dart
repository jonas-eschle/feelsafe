/// Tests for [ChainSummary] — the empty-chain fallback plus the
/// per-step-type icon / display-name mappings (top-level functions,
/// exposed exactly so tests can verify the mapping without rendering).
///
/// Spec ref: `docs/spec/04-screens-navigation.md §Home Screen — Chain
/// Summary` and `docs/spec/02-event-types.md` (the 9 step types).
library;

import 'package:flutter/material.dart';

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/features/home/widgets/chain_summary.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';
import '../../helpers/widget_test_helpers.dart';

void main() {
  group('ChainSummary — empty chain', () {
    testWidgets('renders the empty-chain hint instead of pills', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        Scaffold(
          body: ChainSummary(key: UniqueKey(), steps: const []),
        ),
      );

      expect(find.text(l10n.homeChainSummaryTitle), findsOneWidget);
      expect(find.text(l10n.homeChainSummaryEmpty), findsOneWidget);
    });
  });

  group('chainStepIcon', () {
    test('maps every step type to its distinct pill icon', () {
      final icons = <ChainStepType, IconData>{
        for (final t in ChainStepType.values) t: chainStepIcon(t),
      };

      check(icons).deepEquals(<ChainStepType, IconData>{
        ChainStepType.holdButton: Icons.touch_app,
        ChainStepType.disguisedReminder: Icons.notifications_active,
        ChainStepType.countdownWarning: Icons.timer_outlined,
        ChainStepType.fakeCall: Icons.phone_in_talk,
        ChainStepType.smsContact: Icons.sms_outlined,
        ChainStepType.phoneCallContact: Icons.phone_forwarded,
        ChainStepType.loudAlarm: Icons.volume_up,
        ChainStepType.callEmergency: Icons.emergency,
        ChainStepType.hardwareButton: Icons.bolt,
      });
      // Distinctness: two step types must never share a pill glyph.
      check(icons.values.toSet().length).equals(ChainStepType.values.length);
    });
  });

  group('chainStepDisplayName', () {
    test('maps every step type to its localized display name', () async {
      final AppLocalizations l10n = await loadL10n(const Locale('en'));
      final names = <ChainStepType, String>{
        for (final t in ChainStepType.values) t: chainStepDisplayName(t, l10n),
      };

      check(names).deepEquals(<ChainStepType, String>{
        ChainStepType.holdButton: l10n.chainStepNameHoldButton,
        ChainStepType.disguisedReminder: l10n.chainStepNameDisguisedReminder,
        ChainStepType.countdownWarning: l10n.chainStepNameCountdownWarning,
        ChainStepType.fakeCall: l10n.chainStepNameFakeCall,
        ChainStepType.smsContact: l10n.chainStepNameSmsContact,
        ChainStepType.phoneCallContact: l10n.chainStepNamePhoneCallContact,
        ChainStepType.loudAlarm: l10n.chainStepNameLoudAlarm,
        ChainStepType.callEmergency: l10n.chainStepNameCallEmergency,
        ChainStepType.hardwareButton: l10n.chainStepNameHardwareButton,
      });
      // Every localized name is non-empty and unique.
      check(names.values.toSet().length).equals(ChainStepType.values.length);
      for (final n in names.values) {
        check(n).isNotEmpty();
      }
    });
  });
}
