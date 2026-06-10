/// Widget tests for [GpsLoggingFields]: each control must emit an updated
/// [GpsLoggingConfig] with only the edited field replaced (spec 04 §Mode —
/// Safety Options §GPS logging).
library;

import 'package:flutter/material.dart';

import 'package:checks/checks.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/domain/enums/gps_accuracy.dart';
import 'package:guardianangela/domain/models/gps_logging_config.dart';
import 'package:guardianangela/features/modes/widgets/gps_logging_fields.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';
import '../../../helpers/widget_test_helpers.dart';

Future<void> _pump(
  WidgetTester tester,
  GpsLoggingConfig config, {
  required ValueChanged<GpsLoggingConfig> onChanged,
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
      home: Scaffold(
        body: SingleChildScrollView(
          child: GpsLoggingFields(config: config, onChanged: onChanged),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Opens the dropdown showing [current] and selects [next].
Future<void> _pickDropdown(
  WidgetTester tester,
  String current,
  String next,
) async {
  await tester.tap(find.text(current));
  await tester.pumpAndSettle();
  await tester.tap(find.text(next).last);
  await tester.pumpAndSettle();
}

void main() {
  group('GpsLoggingFields — interval slider', () {
    testWidgets('dragging the interval slider emits a new intervalSeconds', (
      WidgetTester tester,
    ) async {
      GpsLoggingConfig? emitted;
      await _pump(
        tester,
        const GpsLoggingConfig(),
        onChanged: (GpsLoggingConfig c) => emitted = c,
      );

      await tester.drag(find.byType(Slider), const Offset(120, 0));
      await tester.pumpAndSettle();

      check(emitted).isNotNull();
      check(emitted!.intervalSeconds).not((it) => it.equals(30));
      // Untouched fields ride along unchanged.
      check(emitted!.accuracy).equals(GpsAccuracy.high);
    });
  });

  group('GpsLoggingFields — accuracy dropdown', () {
    testWidgets('selecting Balanced emits accuracy: medium', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      GpsLoggingConfig? emitted;
      await _pump(
        tester,
        const GpsLoggingConfig(),
        onChanged: (GpsLoggingConfig c) => emitted = c,
      );

      await _pickDropdown(
        tester,
        l10n.gpsLoggingAccuracyHigh,
        l10n.gpsLoggingAccuracyBalanced,
      );

      check(emitted).isNotNull();
      check(emitted!.accuracy).equals(GpsAccuracy.medium);
    });
  });

  group('GpsLoggingFields — trimmed controls (D-DATA-22)', () {
    testWidgets(
      'renders only the interval slider and the accuracy dropdown — the '
      'format dropdown and include-in-SMS switch are gone because '
      'GpsLoggingConfig was trimmed to {enabled, intervalSeconds, accuracy} '
      '(location-in-SMS is per-step SmsContactConfig.includeLocation)',
      (WidgetTester tester) async {
        await _pump(tester, const GpsLoggingConfig(), onChanged: (_) {});

        expect(find.byType(Slider), findsOneWidget);
        expect(
          find.byWidgetPredicate((w) => w is DropdownButton<Object?>),
          findsOneWidget,
        );
        expect(find.byType(DropdownButton<GpsAccuracy>), findsOneWidget);
        // No switch at all: the master `enabled` toggle is the caller's
        // tri-state selector, and the trimmed include-in-SMS switch must
        // not come back without a new decision.
        expect(find.byType(SwitchListTile), findsNothing);
      },
    );
  });
}
