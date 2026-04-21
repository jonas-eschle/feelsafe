/// Flutter test-suite configuration hook.
///
/// Called once per test process. Used to load application fonts so
/// goldens render with real glyphs instead of `Ahem`-style boxes.
library;

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await loadAppFonts();
  return GoldenToolkit.runWithConfiguration(
    () async => testMain(),
    config: GoldenToolkitConfiguration(
      // Only enforce pixel-match on Linux host, as CI and developer
      // machines generate platform-specific anti-aliasing.
      skipGoldenAssertion: () => false,
      enableRealShadows: true,
    ),
  );
}
