/// Widget tests for [StepConfigPanel]'s timing / retry / randomize /
/// black-screen editors (spec 04 §Step Expansion): each field change must
/// emit an updated [ChainStep] via `onChanged` with only that field
/// replaced.
library;

import 'dart:io';

import 'package:flutter/material.dart';

import 'package:checks/checks.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/repositories/app_settings_repository.dart';
import 'package:guardianangela/domain/configs/step_config.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/enums/confirmation_type.dart';
import 'package:guardianangela/domain/enums/reminder_display_style.dart';
import 'package:guardianangela/domain/models/app_settings.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/models/reminder_template.dart';
import 'package:guardianangela/features/modes/widgets/step_config_panel.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';
import 'package:guardianangela/services/service_providers.dart';
import '../../../helpers/widget_test_helpers.dart';

/// Fake [AppSettingsRepository] serving out-of-box [AppSettings]; backs
/// `appSettingsLiveProvider` for the loudAlarm form's preview card.
class _FakeSettingsRepo extends AppSettingsRepository {
  _FakeSettingsRepo()
    : super(
        keyProvider: () async => '00' * 32,
        resolveDir: () async =>
            Directory.systemTemp.createTempSync('panel_test_'),
      );

  @override
  Future<AppSettings> load() async => const AppSettings();
}

ChainStep _step({
  ChainStepType type = ChainStepType.holdButton,
  int retryCount = 0,
  bool randomize = false,
}) => ChainStep(
  id: 's1',
  type: type,
  order: 0,
  waitSeconds: 5,
  durationSeconds: 30,
  gracePeriodSeconds: 10,
  retryCount: retryCount,
  randomize: randomize,
);

Future<void> _pump(
  WidgetTester tester,
  ChainStep step, {
  required ValueChanged<ChainStep> onChanged,
  StepConfig defaultConfig = const HoldButtonConfig(),
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        appSettingsRepositoryProvider.overrideWithValue(_FakeSettingsRepo()),
      ],
      child: MaterialApp(
        localizationsDelegates: const <LocalizationsDelegate<Object>>[
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: StepConfigPanel(
              step: step,
              defaultConfig: defaultConfig,
              onChanged: onChanged,
              onDuplicate: () {},
              onReset: () {},
              onDelete: () {},
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Commits [text] into the timing field labelled [label].
Future<void> _commitText(WidgetTester tester, String label, String text) async {
  final Finder field = find.widgetWithText(TextField, label);
  await tester.ensureVisible(field);
  await tester.enterText(field, text);
  await tester.testTextInput.receiveAction(TextInputAction.done);
  await tester.pumpAndSettle();
}

/// Expands the initially-collapsed "Retry & advanced" subsection.
Future<void> _openAdvanced(WidgetTester tester, AppLocalizations l10n) async {
  final Finder header = find.text(l10n.stepConfigAdvancedHeader);
  await tester.ensureVisible(header);
  await tester.tap(header);
  await tester.pumpAndSettle();
}

void main() {
  group('StepConfigPanel — timing fields', () {
    testWidgets('committing a new active duration emits the updated step', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      ChainStep? emitted;
      await _pump(tester, _step(), onChanged: (ChainStep s) => emitted = s);

      await _commitText(tester, l10n.stepFieldDuration, '45');

      check(emitted).isNotNull();
      check(emitted!.durationSeconds).equals(45);
      // Only the duration changed.
      check(emitted!.waitSeconds).equals(5);
      check(emitted!.gracePeriodSeconds).equals(10);
    });

    testWidgets('committing a new grace period emits the updated step', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      ChainStep? emitted;
      await _pump(tester, _step(), onChanged: (ChainStep s) => emitted = s);

      await _commitText(tester, l10n.stepFieldGrace, '20');

      check(emitted).isNotNull();
      check(emitted!.gracePeriodSeconds).equals(20);
      check(emitted!.durationSeconds).equals(30);
    });
  });

  group('StepConfigPanel — retry & advanced', () {
    testWidgets('incrementing the retry spinner emits retryCount + 1', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      ChainStep? emitted;
      await _pump(
        tester,
        _step(retryCount: 2),
        onChanged: (ChainStep s) => emitted = s,
      );
      await _openAdvanced(tester, l10n);

      final Finder plus = find.byIcon(Icons.add_circle_outline);
      await tester.ensureVisible(plus);
      await tester.tap(plus);
      await tester.pumpAndSettle();

      check(emitted).isNotNull();
      check(emitted!.retryCount).equals(3);
    });

    testWidgets('toggling Randomise timing emits randomize: true', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      ChainStep? emitted;
      await _pump(tester, _step(), onChanged: (ChainStep s) => emitted = s);
      await _openAdvanced(tester, l10n);

      final Finder toggle = find.widgetWithText(
        SwitchListTile,
        l10n.stepFieldRandomize,
      );
      await tester.ensureVisible(toggle);
      await tester.tap(toggle);
      await tester.pumpAndSettle();

      check(emitted).isNotNull();
      check(emitted!.randomize).isTrue();
    });
  });

  group('StepConfigPanel — manage-templates link (spec 04:1635)', () {
    testWidgets(
      'a disguisedReminder step forwards onManageTemplates to its form',
      (WidgetTester tester) async {
        final l10n = await loadL10n(const Locale('en'));
        var tapped = 0;
        final ChainStep step = ChainStep(
          id: 's1',
          type: ChainStepType.disguisedReminder,
          order: 0,
          waitSeconds: 5,
          durationSeconds: 30,
          gracePeriodSeconds: 10,
          retryCount: 0,
          randomize: false,
        );
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: const <LocalizationsDelegate<Object>>[
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: SingleChildScrollView(
                child: StepConfigPanel(
                  step: step,
                  defaultConfig: const DisguisedReminderConfig(),
                  onChanged: (_) {},
                  onDuplicate: () {},
                  onReset: () {},
                  onDelete: () {},
                  onManageTemplates: () => tapped++,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final Finder link = find.widgetWithText(
          ListTile,
          l10n.safetyOptionsManageTemplates,
        );
        expect(link, findsOneWidget);
        await tester.ensureVisible(link);
        await tester.tap(link);
        check(tapped).equals(1);
      },
    );

    testWidgets(
      'a disguisedReminder step threads the template pool to the picker; '
      'a chip toggle materialises the step config with the new templateIds',
      (WidgetTester tester) async {
        ChainStep? emitted;
        // config: null → the picker edits the seeded default, and the first
        // toggle must materialise a concrete per-step config (spec 04:1594).
        final ChainStep step = ChainStep(
          id: 's1',
          type: ChainStepType.disguisedReminder,
          order: 0,
          waitSeconds: 5,
          durationSeconds: 30,
          gracePeriodSeconds: 10,
          retryCount: 0,
          randomize: false,
        );
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: const <LocalizationsDelegate<Object>>[
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: SingleChildScrollView(
                child: StepConfigPanel(
                  step: step,
                  defaultConfig: const DisguisedReminderConfig(),
                  onChanged: (ChainStep s) => emitted = s,
                  onDuplicate: () {},
                  onReset: () {},
                  onDelete: () {},
                  templates: <ReminderTemplate>[
                    ReminderTemplate(
                      id: 'tpl_cal',
                      name: 'Calendar',
                      title: 'Meeting in 15 min',
                      body: 'Conference Room B',
                      confirmationType: ConfirmationType.dismiss,
                      isCustom: false,
                      displayStyle: ReminderDisplayStyle.subtle,
                      isGlobal: true,
                    ),
                  ],
                  onManageTemplates: () {},
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final Finder chip = find.widgetWithText(FilterChip, 'Calendar');
        expect(chip, findsOneWidget);
        await tester.ensureVisible(chip);
        await tester.tap(chip);
        await tester.pumpAndSettle();

        check(emitted).isNotNull();
        final StepConfig? config = emitted!.config;
        check(config).isA<DisguisedReminderConfig>();
        check(
          (config! as DisguisedReminderConfig).templateIds,
        ).deepEquals(<String>['tpl_cal']);
      },
    );
  });

  // ── blackScreenMode in Retry & Advanced (spec 04:1592/1614) ────────────────
  //
  // Group 3 "Retry & Advanced — retryCount, ±20% randomisation jitter,
  // black-screen mode": for EVERY step type the toggle lives in the
  // initially-collapsed advanced group (not the event form), toggling it
  // materialises the resolved config with `blackScreenMode` flipped through
  // the same step.copyWith(config:) path the event form uses, and its
  // relocated InfoIconButton still opens the explanation sheet (04:1591).

  group('StepConfigPanel — blackScreenMode in Retry & Advanced '
      '(spec 04:1592/1614)', () {
    const List<(ChainStepType, StepConfig)> cases =
        <(ChainStepType, StepConfig)>[
          (ChainStepType.holdButton, HoldButtonConfig()),
          (ChainStepType.disguisedReminder, DisguisedReminderConfig()),
          (ChainStepType.countdownWarning, CountdownWarningConfig()),
          (ChainStepType.fakeCall, FakeCallConfig()),
          (ChainStepType.smsContact, SmsContactConfig()),
          (ChainStepType.phoneCallContact, PhoneCallContactConfig()),
          (ChainStepType.loudAlarm, LoudAlarmConfig()),
          (ChainStepType.callEmergency, CallEmergencyConfig()),
          (ChainStepType.hardwareButton, HardwareButtonConfig()),
        ];

    for (final (ChainStepType type, StepConfig defaultConfig) in cases) {
      testWidgets(
        '${type.name}: hidden until Advanced expands; toggling writes '
        'blackScreenMode; info sheet opens',
        (WidgetTester tester) async {
          final l10n = await loadL10n(const Locale('en'));
          ChainStep? emitted;
          await _pump(
            tester,
            _step(type: type),
            defaultConfig: defaultConfig,
            onChanged: (ChainStep s) => emitted = s,
          );

          final Finder toggle = find.widgetWithText(
            SwitchListTile,
            l10n.eventDefaultsBlackScreen,
          );
          // Initially-collapsed group 3 owns the toggle — it must NOT
          // render with the (initially expanded) event form.
          expect(toggle, findsNothing);

          await _openAdvanced(tester, l10n);
          expect(toggle, findsOneWidget);

          // Write path: same field, same step.copyWith(config:) route —
          // a null step.config materialises from the resolved default.
          await tester.ensureVisible(toggle);
          await tester.tap(toggle);
          await tester.pumpAndSettle();
          check(emitted).isNotNull();
          final StepConfig? written = emitted!.config;
          check(written).isNotNull();
          check(written!.runtimeType).equals(defaultConfig.runtimeType);
          check(written.blackScreenMode).isTrue();

          // The info button relocated with the field (m6-p3 rule).
          final Finder info = find.byTooltip(l10n.eventDefaultsBlackScreen);
          await tester.ensureVisible(info);
          await tester.tap(info);
          await tester.pumpAndSettle();
          expect(find.text(l10n.eventDefaultsBlackScreenInfo), findsOneWidget);
          await tester.tap(find.text(l10n.commonGotIt));
          await tester.pumpAndSettle();
        },
      );
    }
  });
}
