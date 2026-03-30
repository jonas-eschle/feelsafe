import 'package:wakelock_plus/wakelock_plus.dart';

class WakelockService {
  Future<void> enable() async {
    await WakelockPlus.enable();
  }

  Future<void> disable() async {
    await WakelockPlus.disable();
  }

  Future<bool> get isEnabled => WakelockPlus.enabled;
}
