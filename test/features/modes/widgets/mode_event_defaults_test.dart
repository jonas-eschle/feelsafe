/// Widget tests for [ModeEventDefaults] (spec 04 §Mode — Safety Options
/// §Event Defaults): editing a field inside any per-type [ExpansionTile]
/// must emit an [EventDefaults] with ONLY that type's config replaced.
///
/// Parametrised over every [ChainStepType] — each case expands the type's
/// tile, toggles the shared black-screen switch, and asserts the per-type
/// `_replace` routing (a wrong switch arm would corrupt a sibling config
/// and go RED here).
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
      testWidgets('black-screen toggle under $type replaces only that config', (
        WidgetTester tester,
      ) async {
        final l10n = await loadL10n(const Locale('en'));
        EventDefaults? emitted;
        await _pump(
          tester,
          const EventDefaults(),
          onChanged: (EventDefaults d) => emitted = d,
        );

        // Expand the type's tile; only its form is built, so the shared
        // black-screen switch label is unique on screen.
        final Finder tile = find.text(stepName(l10n, type));
        await tester.ensureVisible(tile);
        await tester.tap(tile);
        await tester.pumpAndSettle();

        final Finder blackScreen = find.widgetWithText(
          SwitchListTile,
          l10n.eventDefaultsBlackScreen,
        );
        await tester.ensureVisible(blackScreen);
        await tester.tap(blackScreen);
        await tester.pumpAndSettle();

        check(emitted, because: 'toggling under $type must emit').isNotNull();
        // The edited type's config — and ONLY it — carries the change.
        for (final ChainStepType other in ChainStepType.values) {
          check(
            emitted!.forType(other).blackScreenMode,
            because: 'forType($other) after editing $type',
          ).equals(other == type);
        }
      });
    }
  });
}
