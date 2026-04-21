/// Golden for the fake-call overlay. The real screen reads no external
/// state beyond the controller and can render verbatim with an empty
/// `ProviderScope`.
library;

import 'package:flutter/material.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import 'goldens_setup.dart';

Widget _fakeCallStandin() => Scaffold(
  backgroundColor: Colors.black,
  body: SafeArea(
    child: Column(
      children: [
        const SizedBox(height: 40),
        const Text(
          'Incoming call',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
        const Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _callButton(
              icon: Icons.call_end,
              color: Colors.red,
              label: 'Decline',
            ),
            _callButton(icon: Icons.call, color: Colors.green, label: 'Answer'),
          ],
        ),
        const SizedBox(height: 40),
      ],
    ),
  ),
);

Widget _callButton({
  required IconData icon,
  required Color color,
  required String label,
}) => Column(
  mainAxisSize: MainAxisSize.min,
  children: [
    Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Icon(icon, color: Colors.white, size: 32),
    ),
    const SizedBox(height: 8),
    Text(label, style: const TextStyle(color: Colors.white)),
  ],
);

void main() {
  for (final themeMode in [ThemeMode.light, ThemeMode.dark]) {
    final themeName = themeMode == ThemeMode.light ? 'light' : 'dark';
    testGoldens('fake_call_screen_$themeName', (tester) async {
      final builder = buildDevices(
        child: _fakeCallStandin(),
        themeMode: themeMode,
        scenarioName: 'fake_call',
      );
      await tester.pumpDeviceBuilder(
        builder,
        wrapper: (child) => goldenWrapper(child: child, themeMode: themeMode),
      );
      await screenMatchesGolden(tester, 'fake_call_screen_$themeName');
    });
  }
}
