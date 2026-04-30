/// Coverage for [EventStrategyRegistry] — exercises the `hardwareButton`
/// arm (line 24 in the switch, previously uncovered).
library;

import 'package:checks/checks.dart';
import 'package:test/test.dart';

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/orchestration/event_strategy_registry.dart';
import 'package:guardianangela/domain/orchestration/strategies/hardware_button_strategy.dart';

import '../../helpers/test_helpers.dart';

void main() {
  group('EventStrategyRegistry', () {
    test('hardwareButton step returns HardwareButtonStrategy', () {
      final s = step(type: ChainStepType.hardwareButton);
      final strategy = EventStrategyRegistry.forStep(s);
      check(strategy).isA<HardwareButtonStrategy>();
    });

    test('holdButton step returns HoldButtonStrategy', () {
      final s = step(type: ChainStepType.holdButton);
      final strategy = EventStrategyRegistry.forStep(s);
      check(strategy.runtimeType.toString()).contains('HoldButton');
    });
  });
}
