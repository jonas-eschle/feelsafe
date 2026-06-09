// Coverage for small interactive tails of shared core widgets: the PinKeypad
// optional action-button callback, the DeceptiveOldPinDialog button taps, and
// the GuardianAngelaLogo CustomPainter (paint + shouldRepaint).

import 'package:flutter/material.dart';

import 'package:checks/checks.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/core/theme/guardian_angela_logo.dart';
import 'package:guardianangela/core/widgets/deceptive_old_pin_dialog.dart';
import 'package:guardianangela/core/widgets/pin_keypad.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

Widget _localizedHome(Widget child, {ThemeData? theme}) => MaterialApp(
  theme: theme,
  localizationsDelegates: const <LocalizationsDelegate<Object>>[
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: Center(child: child)),
);

void main() {
  group('PinKeypad', () {
    testWidgets('tapping the optional action button fires onAction', (
      tester,
    ) async {
      var fired = 0;
      await tester.pumpWidget(
        _localizedHome(
          PinKeypad(
            onDigit: (_) {},
            onBackspace: () {},
            onAction: () => fired++,
            biometricAvailable: true,
          ),
        ),
      );
      // The action slot renders the fingerprint icon by default.
      await tester.tap(find.byIcon(Icons.fingerprint));
      await tester.pump();
      check(fired).equals(1);
    });

    testWidgets('a digit tap fires onDigit with the digit value', (
      tester,
    ) async {
      final digits = <int>[];
      await tester.pumpWidget(
        _localizedHome(PinKeypad(onDigit: digits.add, onBackspace: () {})),
      );
      await tester.tap(find.text('7'));
      await tester.pump();
      check(digits).deepEquals([7]);
    });
  });

  group('DeceptiveOldPinDialog', () {
    testWidgets('Cancel pops the dialog', (tester) async {
      await tester.pumpWidget(
        _localizedHome(
          Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => DeceptiveOldPinDialog.show(context),
              child: const Text('open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      // Two action buttons are present; tap the first (cancel) by its key role.
      final l10n = AppLocalizations.of(
        tester.element(find.byType(AlertDialog)),
      );
      await tester.tap(find.text(l10n.angelaDialogCancel));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('Confirm pops the dialog', (tester) async {
      await tester.pumpWidget(
        _localizedHome(
          Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => DeceptiveOldPinDialog.show(context),
              child: const Text('open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      final l10n = AppLocalizations.of(
        tester.element(find.byType(AlertDialog)),
      );
      await tester.tap(find.text(l10n.angelaDialogConfirm));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
    });
  });

  group('GuardianAngelaLogo', () {
    testWidgets('paints, and repaints when the theme colors change', (
      tester,
    ) async {
      await tester.pumpWidget(
        _localizedHome(
          const GuardianAngelaLogo(size: 64),
          theme: ThemeData(
            colorScheme: const ColorScheme.light(primary: Color(0xFF112233)),
          ),
        ),
      );
      expect(find.byType(GuardianAngelaLogo), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);

      // Rebuild with a different color scheme so the painter's shieldColor /
      // haloColor differ → shouldRepaint returns true.
      await tester.pumpWidget(
        _localizedHome(
          const GuardianAngelaLogo(size: 64),
          theme: ThemeData(
            colorScheme: const ColorScheme.dark(primary: Color(0xFFAABBCC)),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(GuardianAngelaLogo), findsOneWidget);
    });
  });
}
