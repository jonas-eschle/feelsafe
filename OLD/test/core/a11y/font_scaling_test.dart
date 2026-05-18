/// Font-scaling sanity check: pump a representative scaffold at
/// `MediaQuery.textScaler = TextScaler.linear(1.8)` and verify the
/// Flutter binding did not report any layout overflow.
///
/// Guardian Angela targets WCAG 2.1: the UI must remain usable under
/// system-level font scaling. 1.8× covers Android's "Huge" and iOS'
/// largest non-accessibility setting.
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/core/theme/app_theme.dart';
import 'package:guardianangela/core/widgets/hold_to_trigger_button.dart';
import 'package:guardianangela/core/widgets/im_safe_slider.dart';
import 'package:guardianangela/core/widgets/pin_keypad.dart';

Widget _representativeScaffold() => Scaffold(
  appBar: AppBar(title: const Text('Guardian Angela')),
  body: SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Step 1 of 3', style: TextStyle(fontSize: 16)),
        const Text('00:20', style: TextStyle(fontSize: 28)),
        const SizedBox(height: 16),
        Center(
          child: HoldToTriggerButton(
            onHoldStart: () {},
            onHoldRelease: () {},
            semanticLabel: 'Hold to stay safe',
            label: 'Hold',
          ),
        ),
        const SizedBox(height: 16),
        ImSafeSlider(label: "I'm safe", onConfirmed: () {}),
        const SizedBox(height: 16),
        PinKeypad(onDigit: (_) {}, onBackspace: () {}),
      ],
    ),
  ),
);

void main() {
  testWidgets('renders at 1.8× text scale without reported overflow', (
    tester,
  ) async {
    final exceptions = <FlutterErrorDetails>[];
    final previousHandler = FlutterError.onError;
    FlutterError.onError = exceptions.add;
    try {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.8)),
          child: MaterialApp(
            theme: AppTheme.light(),
            home: _representativeScaffold(),
          ),
        ),
      );
      await tester.pumpAndSettle();
    } finally {
      FlutterError.onError = previousHandler;
    }
    final overflows = exceptions
        .where((e) => e.exception.toString().toLowerCase().contains('overflow'))
        .toList();
    check(overflows).isEmpty();
  });
}
