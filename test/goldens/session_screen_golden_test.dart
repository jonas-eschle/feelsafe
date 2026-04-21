/// Goldens for the session screen in three representative phases:
/// hold-button, fake-call, and loud-alarm.
///
/// See `home_screen_golden_test.dart` for the stand-in rationale.
library;

import 'package:flutter/material.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import 'package:guardianangela/core/widgets/hold_to_trigger_button.dart';
import 'package:guardianangela/core/widgets/im_safe_slider.dart';

import 'goldens_setup.dart';

enum _Phase { holdButton, fakeCall, loudAlarm }

Widget _sessionStandin(_Phase phase) => Scaffold(
  appBar: AppBar(title: const Text('Session')),
  body: Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        const SizedBox(height: 16),
        const Text('Step 1 of 3', style: TextStyle(fontSize: 16)),
        const Text('00:20', style: TextStyle(fontSize: 28)),
        const Text('Misses: 0'),
        const SizedBox(height: 24),
        Expanded(
          child: Center(
            child: switch (phase) {
              _Phase.holdButton => HoldToTriggerButton(
                semanticLabel: 'hold button',
                label: 'Hold',
                onHoldStart: () {},
                onHoldRelease: () {},
              ),
              _Phase.fakeCall => const Icon(
                Icons.call,
                size: 80,
                color: Colors.green,
              ),
              _Phase.loudAlarm => const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.volume_up, size: 80),
                  SizedBox(height: 16),
                  Text('Loud alarm playing'),
                ],
              ),
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            OutlinedButton(onPressed: () {}, child: const Text('Pause')),
          ],
        ),
        const SizedBox(height: 12),
        ImSafeSlider(label: "I'm safe", onConfirmed: () {}),
      ],
    ),
  ),
);

void main() {
  for (final themeMode in [ThemeMode.light, ThemeMode.dark]) {
    final themeName = themeMode == ThemeMode.light ? 'light' : 'dark';
    for (final phase in _Phase.values) {
      final phaseName = phase.name;
      testGoldens('session_screen_${phaseName}_$themeName', (tester) async {
        final builder = buildDevices(
          child: _sessionStandin(phase),
          themeMode: themeMode,
          scenarioName: phaseName,
        );
        await tester.pumpDeviceBuilder(
          builder,
          wrapper: (child) => goldenWrapper(child: child, themeMode: themeMode),
        );
        await screenMatchesGolden(
          tester,
          'session_screen_${phaseName}_$themeName',
        );
      });
    }
  }
}
