/// Widget tests for [EventSpecificConfig]'s #20 additions: the iOS
/// platform-limitation warnings (spec 02:325, 02:479) and the SMS
/// message-template editor (spec 02:287-304).
///
/// The iOS warnings are gated on `Theme.of(context).platform`, so the test
/// harness injects the platform via `ThemeData(platform: ...)` — a real,
/// host-testable platform override (no dependency on the runtime OS). The
/// iOS *build* itself is verified by CI's `build-ios` job; these tests cover
/// the platform-gated Dart behaviour.
library;

import 'package:flutter/material.dart';

import 'package:checks/checks.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/domain/configs/step_config.dart';
import 'package:guardianangela/domain/enums/message_channel.dart';
import 'package:guardianangela/domain/models/emergency_contact.dart';
import 'package:guardianangela/features/modes/widgets/event_specific_config.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';
import '../../../helpers/widget_test_helpers.dart';

/// Pumps [config] inside an [EventSpecificConfig] under a [MaterialApp] whose
/// theme reports [platform], so the iOS-gated warnings resolve against it.
Future<void> _pump(
  WidgetTester tester,
  StepConfig config, {
  required TargetPlatform platform,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: const <LocalizationsDelegate<Object>>[
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        platform: platform,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF131118)),
        useMaterial3: true,
      ),
      home: Scaffold(
        body: SingleChildScrollView(
          child: EventSpecificConfig(
            config: config,
            onChanged: (_) {},
            // Non-null contacts → the smsContact grid renders; harmless for the
            // template/warning assertions and exercises the real Mode-Editor
            // context path.
            contacts: const <EmergencyContact>[],
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('EventSpecificConfig — iOS SMS warning (spec 02:325)', () {
    testWidgets('shows the SMS warning on iOS with the SMS channel', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(
        tester,
        const SmsContactConfig(),
        platform: TargetPlatform.iOS,
      );
      expect(find.text(l10n.eventDefaultsSmsIosWarning), findsOneWidget);
    });

    testWidgets('hides the SMS warning on iOS when channel is WhatsApp', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(
        tester,
        const SmsContactConfig(channel: MessageChannel.whatsapp),
        platform: TargetPlatform.iOS,
      );
      expect(find.text(l10n.eventDefaultsSmsIosWarning), findsNothing);
    });

    testWidgets('hides the SMS warning on Android with the SMS channel', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(
        tester,
        const SmsContactConfig(),
        platform: TargetPlatform.android,
      );
      expect(find.text(l10n.eventDefaultsSmsIosWarning), findsNothing);
    });
  });

  group('EventSpecificConfig — iOS callEmergency warning (spec 02:479)', () {
    testWidgets('shows the call warning on iOS', (WidgetTester tester) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(
        tester,
        const CallEmergencyConfig(),
        platform: TargetPlatform.iOS,
      );
      expect(
        find.text(l10n.eventDefaultsCallEmergencyIosWarning),
        findsOneWidget,
      );
    });

    testWidgets('hides the call warning on Android', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(
        tester,
        const CallEmergencyConfig(),
        platform: TargetPlatform.android,
      );
      expect(
        find.text(l10n.eventDefaultsCallEmergencyIosWarning),
        findsNothing,
      );
    });
  });

  group('EventSpecificConfig — SMS message template (spec 02:287-304)', () {
    testWidgets('renders the template field and a placeholder chip', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(
        tester,
        const SmsContactConfig(),
        platform: TargetPlatform.android,
      );
      expect(
        find.widgetWithText(TextField, l10n.eventDefaultsSmsMessageTemplate),
        findsOneWidget,
      );
      // Every spec placeholder is offered as an insert chip.
      for (final String token in kSmsTemplatePlaceholders) {
        expect(find.widgetWithText(ActionChip, token), findsOneWidget);
      }
    });

    testWidgets('pre-fills the field from an existing template', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        const SmsContactConfig(messageTemplate: 'Help {name}'),
        platform: TargetPlatform.android,
      );
      expect(find.text('Help {name}'), findsOneWidget);
    });

    testWidgets('a blank template commits as null (use default)', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      SmsContactConfig? emitted;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const <LocalizationsDelegate<Object>>[
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          theme: ThemeData(
            platform: TargetPlatform.android,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF131118),
            ),
            useMaterial3: true,
          ),
          home: Scaffold(
            body: SingleChildScrollView(
              child: EventSpecificConfig(
                config: const SmsContactConfig(messageTemplate: 'old'),
                onChanged: (StepConfig c) => emitted = c as SmsContactConfig,
                contacts: const <EmergencyContact>[],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final Finder field = find.widgetWithText(
        TextField,
        l10n.eventDefaultsSmsMessageTemplate,
      );
      await tester.enterText(field, '   ');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      // Blank/whitespace → null (revert to the seeded default), proving the
      // direct-construct clear path (copyWith cannot null the field).
      check(emitted).isNotNull();
      check(emitted!.messageTemplate).isNull();
    });
  });
}
