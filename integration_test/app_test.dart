/// Patrol E2E entrypoint.
///
/// Aggregates the individual smoke-flow tests in this folder so CI can
/// invoke a single entrypoint. Each flow is also runnable standalone.
///
/// Run locally:
/// ```bash
/// patrol test -t integration_test/app_test.dart
/// ```
///
/// Note: this file is **not** executed by `flutter test` — Patrol +
/// integration_test require a live Android emulator or iOS simulator.
/// See `.github/workflows/ci.yml` job `e2e` (release-tag gated).
library;

import 'walk_mode_flow_test.dart' as walk_mode;
import 'date_mode_flow_test.dart' as date_mode;
import 'distress_flow_test.dart' as distress;

void main() {
  walk_mode.main();
  date_mode.main();
  distress.main();
}
