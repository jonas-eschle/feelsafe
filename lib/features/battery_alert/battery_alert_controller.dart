/// Battery-alert controller stub.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:guardianangela/domain/models/models.dart';

/// Stub AsyncNotifier exposing the current `BatteryAlertConfig`.
class BatteryAlertController extends AsyncNotifier<BatteryAlertConfig> {
  @override
  Future<BatteryAlertConfig> build() async => const BatteryAlertConfig();
}

/// Provider for `BatteryAlertController`.
final AsyncNotifierProvider<BatteryAlertController, BatteryAlertConfig>
    batteryAlertControllerProvider =
    AsyncNotifierProvider<BatteryAlertController, BatteryAlertConfig>(
  BatteryAlertController.new,
);
