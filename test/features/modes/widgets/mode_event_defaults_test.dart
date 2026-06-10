/// Widget tests for [ModeEventDefaults] (spec 04 §Mode — Safety Options
/// §Event Defaults): editing a field inside any per-type [ExpansionTile]
/// must emit an [EventDefaults] with ONLY that type's config replaced.
///
/// Parametrised over every [ChainStepType] — each case expands the type's
/// tile, mutates one of its own form fields, and asserts the per-type
/// `_replace` routing (a wrong switch arm would corrupt a sibling config
/// and go RED here): the edited slot differs from the seed default, every
/// sibling slot is still exactly the seed default.
library;

import 'package:flutter/material.dart';

import 'package:checks/checks.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/models/app_settings.dart';
import 'package:guardianangela/domain/models/event_defaults.dart';
import 'package:guardianangela/features/modes/widgets/mode_event_defaults.dart';
import 'package:guardianangela/features/modes/widgets/step_helpers.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';
import 'package:guardianangela/services/app_state_providers.dart';
import '../../../helpers/widget_test_helpers.dart';

Future<void> _pump(
  WidgetTester tester,
  EventDefaults defaults, {
  required ValueChanged<EventDefaults> onChanged,
}) async {
  await tester.pumpWidget(
    // The loudAlarm preview card inside the per-type forms watches
    // appSettingsLiveProvider (gradual-volume master); pin it to the
    // out-of-box defaults so this routing test stays deterministic.
    ProviderScope(
      overrides: <Override>[
        appSettingsLiveProvider.overrideWith((ref) async {
          return const AppSettings();
        }),
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
            child: ModeEventDefaults(defaults: defaults, onChanged: onChanged),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Taps the [SwitchListTile] labelled [label] inside the expanded form.
Future<void> _tapSwitch(WidgetTester tester, String label) async {
  final Finder toggle = find.widgetWithText(SwitchListTile, label);
  await tester.ensureVisible(toggle);
  await tester.tap(toggle);
  await tester.pumpAndSettle();
}

/// Mutates one type-specific field of [type]'s expanded form.
///
/// Each form exposes a different field set, so the mutation is per type:
/// a boolean switch where one exists, the press-count spinner for
/// hardwareButton, and the primary-contact text field for
/// phoneCallContact (its only field).
Future<void> _mutateForm(
  WidgetTester tester,
  AppLocalizations l10n,
  ChainStepType type,
) async {
  switch (type) {
    case ChainStepType.holdButton:
      await _tapSwitch(tester, l10n.eventDefaultsHoldVibrate);
    case ChainStepType.disguisedReminder:
      await _tapSwitch(tester, l10n.eventDefaultsReminderRandomInterval);
    case ChainStepType.countdownWarning:
      await _tapSwitch(tester, l10n.eventDefaultsCountdownVibrate);
    case ChainStepType.fakeCall:
      await _tapSwitch(tester, l10n.eventDefaultsFakeCallDeclineIsSafe);
    case ChainStepType.smsContact:
      await _tapSwitch(tester, l10n.eventDefaultsSmsIncludeLocation);
    case ChainStepType.phoneCallContact:
      final Finder field = find.widgetWithText(
        TextField,
        l10n.eventDefaultsPhonePrimaryContact,
      );
      await tester.ensureVisible(field);
      await tester.enterText(field, 'c9');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
    case ChainStepType.loudAlarm:
      await _tapSwitch(tester, l10n.eventDefaultsLoudAlarmFlashScreen);
    case ChainStepType.callEmergency:
      await _tapSwitch(tester, l10n.eventDefaultsCallEmergencySmsFirst);
    case ChainStepType.hardwareButton:
      final Finder plus = find.byIcon(Icons.add_circle_outline);
      await tester.ensureVisible(plus);
      await tester.tap(plus);
      await tester.pumpAndSettle();
  }
}

void main() {
  group('ModeEventDefaults — per-type _replace routing', () {
    testWidgets('renders one tile per step type', (WidgetTester tester) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(tester, const EventDefaults(), onChanged: (_) {});
      for (final ChainStepType type in ChainStepType.values) {
        expect(
          find.text(stepName(l10n, type)),
          findsOneWidget,
          reason: 'missing tile for $type',
        );
      }
    });

    for (final ChainStepType type in ChainStepType.values) {
      testWidgets('a field edit under $type replaces only that config', (
        WidgetTester tester,
      ) async {
        final l10n = await loadL10n(const Locale('en'));
        EventDefaults? emitted;
        await _pump(
          tester,
          const EventDefaults(),
          onChanged: (EventDefaults d) => emitted = d,
        );

        // Expand the type's tile; only its form is built, so its field
        // labels are unique on screen.
        final Finder tile = find.text(stepName(l10n, type));
        await tester.ensureVisible(tile);
        await tester.tap(tile);
        await tester.pumpAndSettle();

        await _mutateForm(tester, l10n, type);

        check(emitted, because: 'editing under $type must emit').isNotNull();
        // The edited type's config — and ONLY it — changed (config types
        // implement value equality, so any cross-slot corruption trips
        // the sibling comparison).
        for (final ChainStepType other in ChainStepType.values) {
          if (other == type) {
            check(
              emitted!.forType(other),
              because: 'forType($type) must carry the edit',
            ).not((it) => it.equals(const EventDefaults().forType(other)));
          } else {
            check(
              emitted!.forType(other),
              because: 'forType($other) after editing $type',
            ).equals(const EventDefaults().forType(other));
          }
        }
      });
    }
  });

  // The universal blackScreenMode DEFAULT stays editable per mode (spec
  // 06:376/388/462/501; universal per 04:1614): the shared toggle renders
  // as a sibling section below each per-type form (the form itself stays
  // free of it — pinned in event_specific_config_test.dart) and routes
  // through the same per-type _replace as every form field.
  group('ModeEventDefaults — shared blackScreen toggle below each form', () {
    for (final ChainStepType type in ChainStepType.values) {
      testWidgets('toggling blackScreen under $type flips only that flag', (
        WidgetTester tester,
      ) async {
        final l10n = await loadL10n(const Locale('en'));
        EventDefaults? emitted;
        await _pump(
          tester,
          const EventDefaults(),
          onChanged: (EventDefaults d) => emitted = d,
        );

        // Expand the type's tile; the toggle below its form is the only
        // blackScreen switch on screen.
        final Finder tile = find.text(stepName(l10n, type));
        await tester.ensureVisible(tile);
        await tester.tap(tile);
        await tester.pumpAndSettle();

        await _tapSwitch(tester, l10n.eventDefaultsBlackScreen);

        check(emitted, because: 'toggling under $type must emit').isNotNull();
        for (final ChainStepType other in ChainStepType.values) {
          if (other == type) {
            check(
              emitted!.forType(other).blackScreenMode,
              because: 'forType($type).blackScreenMode must carry the flip',
            ).isTrue();
            // …and within the edited slot ONLY the flag changed.
            check(
              emitted!.forType(other).toJson()..remove('blackScreenMode'),
              because: 'forType($type) non-flag fields after the toggle',
            ).deepEquals(
              const EventDefaults().forType(other).toJson()
                ..remove('blackScreenMode'),
            );
          } else {
            check(
              emitted!.forType(other),
              because: 'forType($other) after toggling $type',
            ).equals(const EventDefaults().forType(other));
          }
        }
      });
    }
  });
}
