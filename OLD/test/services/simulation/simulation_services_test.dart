/// Behavioral tests for every `Simulation*Service`.
///
/// Simulation implementations are pure no-op loggers — they MUST NOT
/// touch real platform APIs. Tests here cover every method + the
/// protocol contract so 100% line coverage is reached.
library;

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/models/emergency_contact.dart';
import 'package:guardianangela/domain/models/reminder_template.dart';
import 'package:guardianangela/domain/models/stealth_config.dart';
import 'package:guardianangela/services/simulation/simulation_audio_service.dart';
import 'package:guardianangela/services/simulation/simulation_battery_monitor_service.dart';
import 'package:guardianangela/services/simulation/simulation_device_state_service.dart';
import 'package:guardianangela/services/simulation/simulation_geofence_service.dart';
import 'package:guardianangela/services/simulation/simulation_hardware_button_service.dart';
import 'package:guardianangela/services/simulation/simulation_home_widget_service.dart';
import 'package:guardianangela/services/simulation/simulation_incoming_call_service.dart';
import 'package:guardianangela/services/simulation/simulation_location_service.dart';
import 'package:guardianangela/services/simulation/simulation_messaging_service.dart';
import 'package:guardianangela/services/simulation/simulation_notification_service.dart';
import 'package:guardianangela/services/simulation/simulation_phone_service.dart';
import 'package:guardianangela/services/simulation/simulation_stealth_icon_service.dart';
import 'package:guardianangela/services/simulation/simulation_system_ui_service.dart';
import 'package:guardianangela/services/simulation/simulation_vibration_service.dart';
import 'package:guardianangela/services/simulation/simulation_wakelock_service.dart';

EmergencyContact _contact({String phone = '+15551234567'}) => EmergencyContact(
  id: 'c',
  name: 'Alice',
  phoneNumber: phone,
  sortOrder: 0,
  channels: const [MessageChannel.sms],
);

ReminderTemplate _template() => const ReminderTemplate(
  id: 't1',
  name: 'ping',
  title: 'Hello',
  body: 'body',
  confirmationType: ConfirmationType.tapButton,
  displayStyle: ReminderDisplayStyle.fullScreen,
  isGlobal: true,
);

void main() {
  group('SimulationAudioService', () {
    test('every method completes without touching a platform API', () async {
      final s = SimulationAudioService();
      await s.playAlarm();
      await s.playAlarm(maxVolume: false);
      await s.stopAlarm();
      await s.playRingtone();
      await s.playRingtone(assetPath: 'custom.wav');
      await s.stopRingtone();
      await s.playVoiceRecording(assetPath: 'voice.mp3');
      await s.stopVoiceRecording();
    });
  });

  group('SimulationBatteryMonitorService', () {
    test('start/stop + isActive + broadcast stream is bound', () async {
      final s = SimulationBatteryMonitorService();
      check(s.isActive).isFalse();
      final streamRef = s.onLowBattery;
      await s.startMonitoring(thresholdPercent: 15);
      check(s.isActive).isTrue();
      await s.stopMonitoring();
      check(s.isActive).isFalse();
      check(streamRef.isBroadcast).isTrue();
      s.dispose();
    });
  });

  group('SimulationDeviceStateService', () {
    test('always returns false without throwing', () async {
      final s = SimulationDeviceStateService();
      check(await s.isDndOn()).isFalse();
      check(await s.isSilent()).isFalse();
    });
  });

  group('SimulationGeofenceService', () {
    test('register/remove are no-ops; stream is broadcast', () async {
      final s = SimulationGeofenceService();
      await s.registerGeofence(
        latitude: 10.0,
        longitude: 20.0,
        radiusMeters: 100.0,
      );
      await s.removeGeofence();
      check(s.arrivals.isBroadcast).isTrue();
      s.dispose();
    });
  });

  group('SimulationHardwareButtonService', () {
    test('start/stop + isListening + stream lifecycle', () async {
      final s = SimulationHardwareButtonService();
      check(s.isListening).isFalse();
      await s.start(buttonType: 'volume', pattern: '5x_press', pressCount: 3);
      check(s.isListening).isTrue();
      await s.stop();
      check(s.isListening).isFalse();
      check(s.panicEvents.isBroadcast).isTrue();
      s.dispose();
    });
  });

  group('SimulationHomeWidgetService', () {
    test('all methods no-op; initial uri is null', () async {
      final s = SimulationHomeWidgetService();
      await s.registerInteractivity(() {});
      check(await s.initiallyLaunchedUri()).isNull();
      await s.updateStatus(status: 'Idle', modeName: 'Walk', isRunning: false);
      await s.writeLastMarker('m');
      check(await s.consumePendingMarker()).isNull();
      check(s.widgetClicked.isBroadcast).isTrue();
      s.dispose();
    });
  });

  group('SimulationIncomingCallService', () {
    test('start/stop are no-ops', () async {
      final s = SimulationIncomingCallService();
      await s.startListening();
      await s.stopListening();
      check(s.callState.isBroadcast).isTrue();
      s.dispose();
    });
  });

  group('SimulationLocationService', () {
    test('permission granted; no fix available', () async {
      final s = SimulationLocationService();
      check(await s.requestPermission()).isTrue();
      await s.startTracking();
      await s.startTracking(interval: const Duration(seconds: 5));
      await s.stopTracking();
      check(s.getLastLocationPoint()).isNull();
      check(s.getLastLocationUrl()).isNull();
      check(s.history).isEmpty();
      s.clearHistory();
    });
  });

  group('SimulationMessagingService', () {
    test('sendMessage returns unique sim ids and does not send', () async {
      final s = SimulationMessagingService();
      check(await s.canAutoSend(MessageChannel.sms)).isTrue();
      check(await s.canAutoSend(MessageChannel.whatsapp)).isTrue();
      final a = await s.sendMessage(
        contact: _contact(),
        message: 'help',
        channel: MessageChannel.sms,
      );
      final b = await s.sendMessage(
        contact: _contact(),
        message: 'help',
        channel: MessageChannel.whatsapp,
      );
      check(a.value).equals('sim-0');
      check(b.value).equals('sim-1');
      final group = await s.sendToAll(
        contacts: [
          _contact(),
          _contact(phone: '+1'),
        ],
        message: 'hi',
      );
      check(group.length).equals(2);
      check(group.first.value).equals('sim-2');
      await s.cancelPending(group);
      await s.retryExhaustedSms('sim-0');
      check(s.deliveryUpdates.isBroadcast).isTrue();
      check(s.smsRetryExhausted.isBroadcast).isTrue();
      s.dispose();
    });
  });

  group('SimulationNotificationService', () {
    test('schedule returns monotonic ids and no-ops elsewhere', () async {
      final s = SimulationNotificationService();
      await s.init();
      await s.showSessionNotification(title: 'T', body: 'B');
      await s.showDisguisedReminder(template: _template());
      final id1 = await s.scheduleNotification(
        title: 'A',
        body: 'b',
        delay: const Duration(seconds: 5),
      );
      final id2 = await s.scheduleNotification(
        title: 'B',
        body: 'b',
        delay: const Duration(seconds: 5),
      );
      check(id2).equals(id1 + 1);
      await s.cancelNotification(id1);
      await s.cancelAll();
      await s.showToast('hi');
      check(s.actionTaps.isBroadcast).isTrue();
      s.dispose();
    });
  });

  group('SimulationPhoneService', () {
    test('call/callEmergency are no-ops', () async {
      final s = SimulationPhoneService();
      await s.call('+1234');
      await s.callEmergency('112');
    });
  });

  group('SimulationStealthIconService', () {
    test('setPreset/getCurrentPreset roundtrip', () async {
      final s = SimulationStealthIconService();
      check(await s.getCurrentPreset()).equals(StealthIconPreset.calendar);
      await s.setPreset(StealthIconPreset.fitness);
      check(await s.getCurrentPreset()).equals(StealthIconPreset.fitness);
    });
  });

  group('SimulationSystemUiService', () {
    test('quickExit/request/isBatteryOptimized are no-ops', () async {
      final s = SimulationSystemUiService();
      await s.quickExit();
      await s.requestBatteryOptimizationExemption();
      check(await s.isBatteryOptimized()).isFalse();
    });
  });

  group('SimulationVibrationService', () {
    test('all patterns + stop', () async {
      final s = SimulationVibrationService();
      await s.alarmPattern();
      await s.warningPattern();
      await s.fakeCallPattern();
      await s.stop();
    });
  });

  group('SimulationWakelockService', () {
    test('enable/disable toggle isEnabled', () async {
      final s = SimulationWakelockService();
      check(await s.isEnabled).isFalse();
      await s.enable();
      check(await s.isEnabled).isTrue();
      await s.disable();
      check(await s.isEnabled).isFalse();
    });
  });
}
