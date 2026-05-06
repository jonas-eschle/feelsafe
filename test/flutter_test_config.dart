/// Test runner config — alchemist hooks for the golden tests under
/// `test/goldens/`.
///
/// alchemist replaces the discontinued `golden_toolkit` package here.
/// CI runs the "ci" goldens (deterministic; produced via Flutter's
/// built-in renderer). Platform-specific goldens are disabled because
/// we don't run the goldens against real devices.
library;

import 'dart:async';

import 'package:alchemist/alchemist.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  return AlchemistConfig.runWithConfig(
    config: const AlchemistConfig(
      platformGoldensConfig: PlatformGoldensConfig(enabled: false),
    ),
    run: testMain,
  );
}
