/// Riverpod providers for every service layer in Guardian Angela.
///
/// For each service the file declares two providers:
/// * the `xxxServiceProvider` — returns the real platform-backed
///   implementation used in production.
/// * the `simulationXxxProvider` — returns the dry-run simulation
///   implementation used by the "simulate session" flow (no real
///   SMS, calls, or GPS touch).
///
/// Consumers pick between them via a `simulationMode` flag the
/// session controller exposes.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:guardianangela/services/implementations/audio_service.dart';
import 'package:guardianangela/services/implementations/battery_monitor_service.dart';
import 'package:guardianangela/services/implementations/biometric_service.dart';
import 'package:guardianangela/services/implementations/device_state_service.dart';
import 'package:guardianangela/services/implementations/flash_service.dart';
import 'package:guardianangela/services/implementations/geofence_service.dart';
import 'package:guardianangela/services/implementations/hardware_button_service.dart';
import 'package:guardianangela/services/implementations/home_widget_service.dart';
import 'package:guardianangela/services/implementations/incoming_call_service.dart';
import 'package:guardianangela/services/implementations/location_service.dart';
import 'package:guardianangela/services/implementations/messaging_service.dart';
import 'package:guardianangela/services/implementations/notification_service.dart';
import 'package:guardianangela/services/implementations/phone_service.dart';
import 'package:guardianangela/services/implementations/recording_service.dart';
import 'package:guardianangela/services/implementations/stealth_icon_service.dart';
import 'package:guardianangela/services/implementations/system_ui_service.dart';
import 'package:guardianangela/services/implementations/vibration_service.dart';
import 'package:guardianangela/services/implementations/wakelock_service.dart';
import 'package:guardianangela/services/protocols/audio_service_protocol.dart';
import 'package:guardianangela/services/protocols/battery_monitor_service_protocol.dart';
import 'package:guardianangela/services/protocols/biometric_service_protocol.dart';
import 'package:guardianangela/services/protocols/device_state_service_protocol.dart';
import 'package:guardianangela/services/protocols/flash_service_protocol.dart';
import 'package:guardianangela/services/protocols/geofence_service_protocol.dart';
import 'package:guardianangela/services/protocols/hardware_button_service_protocol.dart';
import 'package:guardianangela/services/protocols/home_widget_service_protocol.dart';
import 'package:guardianangela/services/protocols/incoming_call_service_protocol.dart';
import 'package:guardianangela/services/protocols/location_service_protocol.dart';
import 'package:guardianangela/services/protocols/messaging_service_protocol.dart';
import 'package:guardianangela/services/protocols/notification_service_protocol.dart';
import 'package:guardianangela/services/protocols/phone_service_protocol.dart';
import 'package:guardianangela/services/protocols/recording_service_protocol.dart';
import 'package:guardianangela/services/protocols/stealth_icon_service_protocol.dart';
import 'package:guardianangela/services/protocols/system_ui_service_protocol.dart';
import 'package:guardianangela/services/protocols/vibration_service_protocol.dart';
import 'package:guardianangela/services/protocols/wakelock_service_protocol.dart';
import 'package:guardianangela/services/simulation/simulation_audio_service.dart';
import 'package:guardianangela/services/simulation/simulation_battery_monitor_service.dart';
import 'package:guardianangela/services/simulation/simulation_device_state_service.dart';
import 'package:guardianangela/services/simulation/simulation_flash_service.dart';
import 'package:guardianangela/services/simulation/simulation_geofence_service.dart';
import 'package:guardianangela/services/simulation/simulation_hardware_button_service.dart';
import 'package:guardianangela/services/simulation/simulation_home_widget_service.dart';
import 'package:guardianangela/services/simulation/simulation_incoming_call_service.dart';
import 'package:guardianangela/services/simulation/simulation_location_service.dart';
import 'package:guardianangela/services/simulation/simulation_messaging_service.dart';
import 'package:guardianangela/services/simulation/simulation_notification_service.dart';
import 'package:guardianangela/services/simulation/simulation_phone_service.dart';
import 'package:guardianangela/services/simulation/simulation_recording_service.dart';
import 'package:guardianangela/services/simulation/simulation_stealth_icon_service.dart';
import 'package:guardianangela/services/simulation/simulation_system_ui_service.dart';
import 'package:guardianangela/services/simulation/simulation_vibration_service.dart';
import 'package:guardianangela/services/simulation/simulation_wakelock_service.dart';

export 'package:guardianangela/services/implementations/audio_service.dart';
export 'package:guardianangela/services/implementations/battery_monitor_service.dart';
export 'package:guardianangela/services/implementations/device_state_service.dart';
export 'package:guardianangela/services/implementations/flash_service.dart';
export 'package:guardianangela/services/implementations/geofence_service.dart';
export 'package:guardianangela/services/implementations/hardware_button_service.dart';
export 'package:guardianangela/services/implementations/home_widget_service.dart';
export 'package:guardianangela/services/implementations/incoming_call_service.dart';
export 'package:guardianangela/services/implementations/location_service.dart';
export 'package:guardianangela/services/implementations/messaging_service.dart';
export 'package:guardianangela/services/implementations/notification_service.dart';
export 'package:guardianangela/services/implementations/phone_service.dart';
export 'package:guardianangela/services/implementations/recording_service.dart';
export 'package:guardianangela/services/implementations/stealth_icon_service.dart';
export 'package:guardianangela/services/implementations/system_ui_service.dart';
export 'package:guardianangela/services/implementations/vibration_service.dart';
export 'package:guardianangela/services/implementations/wakelock_service.dart';
export 'package:guardianangela/services/protocols/audio_service_protocol.dart';
export 'package:guardianangela/services/protocols/battery_monitor_service_protocol.dart';
export 'package:guardianangela/services/protocols/device_state_service_protocol.dart';
export 'package:guardianangela/services/protocols/flash_service_protocol.dart';
export 'package:guardianangela/services/protocols/geofence_service_protocol.dart';
export 'package:guardianangela/services/protocols/hardware_button_service_protocol.dart';
export 'package:guardianangela/services/protocols/home_widget_service_protocol.dart';
export 'package:guardianangela/services/protocols/incoming_call_service_protocol.dart';
export 'package:guardianangela/services/protocols/location_service_protocol.dart';
export 'package:guardianangela/services/protocols/messaging_service_protocol.dart';
export 'package:guardianangela/services/protocols/notification_service_protocol.dart';
export 'package:guardianangela/services/protocols/phone_service_protocol.dart';
export 'package:guardianangela/services/protocols/recording_service_protocol.dart';
export 'package:guardianangela/services/protocols/stealth_icon_service_protocol.dart';
export 'package:guardianangela/services/protocols/system_ui_service_protocol.dart';
export 'package:guardianangela/services/protocols/vibration_service_protocol.dart';
export 'package:guardianangela/services/protocols/wakelock_service_protocol.dart';

/// Real audio service.
final audioServiceProvider = Provider<AudioServiceProtocol>((ref) {
  final service = AudioService();
  ref.onDispose(service.dispose);
  return service;
});

/// Simulation audio service.
final simulationAudioProvider = Provider<AudioServiceProtocol>(
  (_) => SimulationAudioService(),
);

/// Real biometric authentication service. There is no simulation
/// variant — biometric is a user-presence check, not a side effect.
final biometricServiceProvider = Provider<BiometricServiceProtocol>(
  (_) => BiometricService(),
);

/// Real vibration service.
final vibrationServiceProvider = Provider<VibrationServiceProtocol>(
  (_) => VibrationService(),
);

/// Simulation vibration service.
final simulationVibrationProvider = Provider<VibrationServiceProtocol>(
  (_) => SimulationVibrationService(),
);

/// Real messaging service.
final messagingServiceProvider = Provider<MessagingServiceProtocol>(
  (_) => MessagingService(),
);

/// Simulation messaging service.
final simulationMessagingProvider = Provider<MessagingServiceProtocol>(
  (_) => SimulationMessagingService(),
);

/// Real phone service.
final phoneServiceProvider = Provider<PhoneServiceProtocol>(
  (_) => PhoneService(),
);

/// Simulation phone service.
final simulationPhoneProvider = Provider<PhoneServiceProtocol>(
  (_) => SimulationPhoneService(),
);

/// Real recording service. Single-slot mic-capture wrapper extracted
/// from `AudioService` (audit Q2). New code should depend on this
/// provider directly; `AudioService.playVoiceRecording` remains for
/// playback only.
final recordingServiceProvider = Provider<RecordingServiceProtocol>(
  (_) => RecordingService(),
);

/// Simulation recording service.
final simulationRecordingProvider = Provider<RecordingServiceProtocol>(
  (_) => SimulationRecordingService(),
);

/// Real flash (camera-LED) service. Wraps `torch_light` and is used
/// by `LoudAlarmStrategy` (audit Q2 extraction). The provider stops
/// any in-flight strobe on dispose so a hot-reload doesn't leave the
/// torch hanging on.
final flashServiceProvider = Provider<FlashServiceProtocol>((ref) {
  final service = FlashService();
  ref.onDispose(service.stopStrobe);
  return service;
});

/// Simulation flash service.
final simulationFlashProvider = Provider<FlashServiceProtocol>(
  (_) => SimulationFlashService(),
);

/// Real location service.
final locationServiceProvider = Provider<LocationServiceProtocol>(
  (_) => LocationService(),
);

/// Simulation location service.
final simulationLocationProvider = Provider<LocationServiceProtocol>(
  (_) => SimulationLocationService(),
);

/// Real notification service.
///
/// Fix for bugs.json Warn (leak — _actionController never closed).
final notificationServiceProvider = Provider<NotificationServiceProtocol>((
  ref,
) {
  final service = NotificationService();
  ref.onDispose(service.dispose);
  return service;
});

/// Simulation notification service.
final simulationNotificationProvider = Provider<NotificationServiceProtocol>(
  (_) => SimulationNotificationService(),
);

/// Real hardware-button service.
///
/// Fix for bugs.json Warn (leak — controller never closed).
final hardwareButtonServiceProvider = Provider<HardwareButtonServiceProtocol>((
  ref,
) {
  final service = HardwareButtonService();
  ref.onDispose(service.dispose);
  return service;
});

/// Simulation hardware-button service.
final simulationHardwareButtonProvider =
    Provider<HardwareButtonServiceProtocol>(
      (_) => SimulationHardwareButtonService(),
    );

/// Real incoming-call service.
///
/// Fix for bugs.json Warn (leak — controller never closed): wire the
/// service's `dispose()` into the Riverpod provider lifecycle.
final incomingCallServiceProvider = Provider<IncomingCallServiceProtocol>((
  ref,
) {
  final service = IncomingCallService();
  ref.onDispose(service.dispose);
  return service;
});

/// Simulation incoming-call service.
final simulationIncomingCallProvider = Provider<IncomingCallServiceProtocol>(
  (_) => SimulationIncomingCallService(),
);

/// Real battery-monitor service.
final batteryMonitorServiceProvider = Provider<BatteryMonitorServiceProtocol>(
  (_) => BatteryMonitorService(),
);

/// Simulation battery-monitor service.
final simulationBatteryMonitorProvider =
    Provider<BatteryMonitorServiceProtocol>(
      (_) => SimulationBatteryMonitorService(),
    );

/// Real device-state service.
final deviceStateServiceProvider = Provider<DeviceStateServiceProtocol>(
  (_) => DeviceStateService(),
);

/// Simulation device-state service.
final simulationDeviceStateProvider = Provider<DeviceStateServiceProtocol>(
  (_) => SimulationDeviceStateService(),
);

/// Real geofence service.
///
/// Fix for bugs.json Warn (leak — controller never closed).
final geofenceServiceProvider = Provider<GeofenceServiceProtocol>((ref) {
  final service = GeofenceService();
  ref.onDispose(service.dispose);
  return service;
});

/// Simulation geofence service.
final simulationGeofenceProvider = Provider<GeofenceServiceProtocol>(
  (_) => SimulationGeofenceService(),
);

/// Real stealth-icon service.
final stealthIconServiceProvider = Provider<StealthIconServiceProtocol>(
  (_) => StealthIconService(),
);

/// Simulation stealth-icon service.
final simulationStealthIconProvider = Provider<StealthIconServiceProtocol>(
  (_) => SimulationStealthIconService(),
);

/// Real home-widget service.
final homeWidgetServiceProvider = Provider<HomeWidgetServiceProtocol>(
  (_) => HomeWidgetService(),
);

/// Simulation home-widget service.
final simulationHomeWidgetProvider = Provider<HomeWidgetServiceProtocol>(
  (_) => SimulationHomeWidgetService(),
);

/// Real wakelock service.
final wakelockServiceProvider = Provider<WakelockServiceProtocol>(
  (_) => WakelockService(),
);

/// Simulation wakelock service.
final simulationWakelockProvider = Provider<WakelockServiceProtocol>(
  (_) => SimulationWakelockService(),
);

/// Real system-UI service.
final systemUiServiceProvider = Provider<SystemUiServiceProtocol>(
  (_) => SystemUiService(),
);

/// Simulation system-UI service.
final simulationSystemUiProvider = Provider<SystemUiServiceProtocol>(
  (_) => SimulationSystemUiService(),
);
