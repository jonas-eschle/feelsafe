// ignore_for_file: one_member_abstracts

import 'dart:async';

import 'package:guardianangela/domain/models/emergency_contact.dart';
import 'package:guardianangela/domain/models/location_point.dart';
import 'package:guardianangela/domain/orchestration/event_services.dart';
import 'package:guardianangela/services/protocols/audio_service_protocol.dart';
import 'package:guardianangela/services/protocols/contact_service_protocol.dart';
import 'package:guardianangela/services/protocols/flash_service_protocol.dart';
import 'package:guardianangela/services/protocols/location_service_protocol.dart';
import 'package:guardianangela/services/protocols/messaging_service_protocol.dart';
import 'package:guardianangela/services/protocols/notification_service_protocol.dart';
import 'package:guardianangela/services/protocols/phone_service_protocol.dart';
import 'package:guardianangela/services/protocols/recording_service_protocol.dart';
import 'package:guardianangela/services/protocols/screen_flash_service_protocol.dart';
import 'package:guardianangela/services/protocols/vibration_service_protocol.dart';

// ─── Fake implementations ──────────────────────────────────────────────────

/// Fake [AudioServiceProtocol] that records every call.
final class FakeAudioService implements AudioServiceProtocol {
  /// All calls recorded in the order they occurred.
  ///
  /// Each entry is a `Map<String, Object?>` whose `'method'` key holds the
  /// method name and remaining keys hold the named parameters.
  final List<Map<String, Object?>> calls = [];

  @override
  Future<void> playRingtone(String? assetPath) async {
    calls.add({'method': 'playRingtone', 'assetPath': assetPath});
  }

  @override
  Future<void> playAlarm({bool alarmDndOverride = true}) async {
    calls.add({'method': 'playAlarm', 'alarmDndOverride': alarmDndOverride});
  }

  @override
  Future<void> playAlarmWithConfig({
    String soundChoice = 'siren',
    String? customSoundPath,
    double volume = 1.0,
    bool isSimulation = false,
    int rampSeconds = kDefaultAlarmRampSeconds,
    bool alarmDndOverride = true,
  }) async {
    calls.add({
      'method': 'playAlarmWithConfig',
      'soundChoice': soundChoice,
      'customSoundPath': customSoundPath,
      'volume': volume,
      'rampSeconds': rampSeconds,
      'isSimulation': isSimulation,
      'alarmDndOverride': alarmDndOverride,
    });
  }

  @override
  Future<void> playSound(String assetPath) async {
    calls.add({'method': 'playSound', 'assetPath': assetPath});
  }

  @override
  Future<void> stop() async {
    calls.add({'method': 'stop'});
  }
}

/// Fake [VibrationServiceProtocol] that records every call.
final class FakeVibrationService implements VibrationServiceProtocol {
  /// All calls recorded in the order they occurred.
  final List<Map<String, Object?>> calls = [];

  @override
  Future<void> warningPattern({bool isSimulation = false}) async {
    calls.add({'method': 'warningPattern', 'isSimulation': isSimulation});
  }

  @override
  Future<void> confirmPulse() async {
    calls.add({'method': 'confirmPulse'});
  }

  @override
  Future<void> alarmPattern({bool isSimulation = false}) async {
    calls.add({'method': 'alarmPattern', 'isSimulation': isSimulation});
  }

  @override
  Future<void> fakeCallPattern() async {
    calls.add({'method': 'fakeCallPattern'});
  }

  @override
  Future<void> reminderPattern() async {
    calls.add({'method': 'reminderPattern'});
  }

  @override
  Future<void> cancel() async {
    calls.add({'method': 'cancel'});
  }
}

/// Fake [MessagingServiceProtocol] that records every call.
///
/// Optionally accepts a [sendHook] to inject custom behaviour (e.g., to
/// simulate delivery failures or return specific [MessageWorkId] values).
final class FakeMessagingService implements MessagingServiceProtocol {
  /// Creates a [FakeMessagingService].
  ///
  /// [sendHook] — optional callback invoked instead of the default no-op.
  /// Receives the same named parameters passed to [sendMessage].
  FakeMessagingService({this.sendHook});

  /// Optional hook injected for tests that need custom `sendMessage` behaviour.
  final Future<MessageWorkId?> Function({
    required EmergencyContact contact,
    required String message,
    bool isSimulation,
  })?
  sendHook;

  /// All calls recorded in the order they occurred.
  final List<Map<String, Object?>> calls = [];

  @override
  Future<MessageWorkId?> sendMessage({
    required EmergencyContact contact,
    required String message,
    bool isSimulation = false,
  }) async {
    calls.add({
      'method': 'sendMessage',
      'contact': contact,
      'message': message,
      'isSimulation': isSimulation,
    });
    if (sendHook != null) {
      return sendHook!(
        contact: contact,
        message: message,
        isSimulation: isSimulation,
      );
    }
    return null;
  }
}

/// Fake [PhoneServiceProtocol] that records every call.
final class FakePhoneService implements PhoneServiceProtocol {
  /// All calls recorded in the order they occurred.
  final List<Map<String, Object?>> calls = [];

  @override
  Future<bool> call(String phoneNumber, {bool isSimulation = false}) async {
    calls.add({
      'method': 'call',
      'phoneNumber': phoneNumber,
      'isSimulation': isSimulation,
    });
    return true;
  }

  @override
  Future<bool> callEmergency(
    String emergencyNumber, {
    bool isSimulation = false,
  }) async {
    calls.add({
      'method': 'callEmergency',
      'emergencyNumber': emergencyNumber,
      'isSimulation': isSimulation,
    });
    return true;
  }
}

/// Fake [LocationServiceProtocol] that returns configurable values.
final class FakeLocationService implements LocationServiceProtocol {
  /// Creates a [FakeLocationService].
  ///
  /// [lastLocationUrl] defaults to `'https://maps.google.com/?q=0.0,0.0'`.
  /// [lastLocationDescription] defaults to `null`.
  FakeLocationService({
    this.lastLocationUrl = 'https://maps.google.com/?q=0.0,0.0',
    this.lastLocationDescription,
  });

  /// The URL returned by [getLastLocationUrl].
  final String? lastLocationUrl;

  /// The description returned by [getLastLocationDescription].
  final String? lastLocationDescription;

  @override
  String? getLastLocationUrl() => lastLocationUrl;

  @override
  String? getLastLocationDescription() => lastLocationDescription;

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<void> startTracking({
    Duration interval = const Duration(seconds: 30),
  }) async {}

  @override
  void stopTracking() {}

  @override
  LocationPoint? getLastLocationPoint() => null;

  @override
  Future<LocationFallbackResult?> getLastLocationWithFallback() async => null;

  @override
  List<LocationPoint> get history => const [];

  @override
  void clearHistory() {}
}

/// Fake [RecordingServiceProtocol] that records every call.
final class FakeRecordingService implements RecordingServiceProtocol {
  /// All calls recorded in the order they occurred.
  final List<Map<String, Object?>> calls = [];

  @override
  Future<String?> recordForDuration({
    required Duration duration,
    String? fileName,
    bool isSimulation = false,
  }) async {
    calls.add({
      'method': 'recordForDuration',
      'duration': duration,
      'fileName': fileName,
      'isSimulation': isSimulation,
    });
    return null;
  }
}

/// Fake [FlashServiceProtocol] that records every call.
final class FakeFlashService implements FlashServiceProtocol {
  /// All calls recorded in the order they occurred.
  final List<Map<String, Object?>> calls = [];

  @override
  Future<void> startSosFlash() async {
    calls.add({'method': 'startSosFlash'});
  }

  @override
  Future<void> stopFlash() async {
    calls.add({'method': 'stopFlash'});
  }
}

/// Fake [ScreenFlashServiceProtocol] that records every call.
final class FakeScreenFlashService implements ScreenFlashServiceProtocol {
  /// All calls recorded in the order they occurred.
  final List<Map<String, Object?>> calls = [];

  @override
  Future<void> startScreenFlash({String speed = 'slow'}) async {
    calls.add({'method': 'startScreenFlash', 'speed': speed});
  }

  @override
  Future<void> stopScreenFlash() async {
    calls.add({'method': 'stopScreenFlash'});
  }
}

/// Fake [NotificationServiceProtocol] that records every call.
final class FakeNotificationService implements NotificationServiceProtocol {
  /// All calls recorded in the order they occurred.
  final List<Map<String, Object?>> calls = [];

  @override
  Future<void> showDisguisedReminder({
    required int id,
    required String title,
    required String body,
  }) async {
    calls.add({
      'method': 'showDisguisedReminder',
      'id': id,
      'title': title,
      'body': body,
    });
  }

  @override
  Future<void> showSmsRetryExhaustedNotification({
    required String contactName,
    required String actionPayload,
  }) async {
    calls.add({
      'method': 'showSmsRetryExhaustedNotification',
      'contactName': contactName,
      'actionPayload': actionPayload,
    });
  }

  @override
  Future<void> showForegroundServiceNotification({
    required String title,
    required String body,
    bool stealth = false,
  }) async {
    calls.add({
      'method': 'showForegroundServiceNotification',
      'title': title,
      'body': body,
      'stealth': stealth,
    });
  }

  @override
  Future<void> showAlarmEscalation({
    required int id,
    required String title,
    required String body,
    String sound = 'critical_alert.wav',
  }) async {
    calls.add({
      'method': 'showAlarmEscalation',
      'id': id,
      'title': title,
      'body': body,
      'sound': sound,
    });
  }

  @override
  Future<void> cancel(int id) async {
    calls.add({'method': 'cancel', 'id': id});
  }

  @override
  Stream<String> get actionTaps => const Stream.empty();

  @override
  Future<bool> requestPermission() async => true;
}

/// Fake [ContactServiceProtocol] backed by a provided contact list.
final class FakeContactService implements ContactServiceProtocol {
  /// Creates a [FakeContactService] with the given [contacts].
  FakeContactService(this._contacts);

  final List<EmergencyContact> _contacts;

  @override
  List<EmergencyContact> get all => List.unmodifiable(_contacts);

  @override
  EmergencyContact? byId(String id) {
    for (final c in _contacts) {
      if (c.id == id) {
        return c;
      }
    }
    return null;
  }
}

// ─── buildServices factory ─────────────────────────────────────────────────

/// Builds an [EventServices] instance with fake service implementations.
///
/// All fake parameters are optional. When omitted, sensible defaults are
/// used so tests can target only the fields they care about.
///
/// The returned [EventServices.isSimulation] is `false` by default — set
/// to `true` to exercise the Layer 2 simulation guard in strategies.
///
/// Example — assert that [SmsContactStrategy] recorded the send:
/// ```dart
/// final messaging = FakeMessagingService();
/// final services = buildServices(messaging: messaging, contacts: [contact]);
/// await SmsContactStrategy().executeReal(step, services);
/// expect(messaging.calls, hasLength(1));
/// expect(messaging.calls.first['method'], equals('sendMessage'));
/// ```
EventServices buildServices({
  bool isSimulation = false,
  List<EmergencyContact> contacts = const [],
  String? userName,
  String? userDescription,
  String? userMedicalInfo,
  String? emergencyNumberDefault,
  String? lastLocationUrl = 'https://maps.google.com/?q=0.0,0.0',
  String? lastLocationDescription,
  AudioServiceProtocol? audio,
  VibrationServiceProtocol? vibration,
  MessagingServiceProtocol? messaging,
  PhoneServiceProtocol? phone,
  LocationServiceProtocol? location,
  RecordingServiceProtocol? recording,
  FlashServiceProtocol? flash,
  ScreenFlashServiceProtocol? screenFlash,
  ContactServiceProtocol? contactsService,
  NotificationServiceProtocol? notification,
  bool Function()? isCancelled,
}) => EventServices(
  audio: audio ?? FakeAudioService(),
  vibration: vibration ?? FakeVibrationService(),
  messaging: messaging ?? FakeMessagingService(),
  phone: phone ?? FakePhoneService(),
  location:
      location ??
      FakeLocationService(
        lastLocationUrl: lastLocationUrl,
        lastLocationDescription: lastLocationDescription,
      ),
  recording: recording ?? FakeRecordingService(),
  flash: flash ?? FakeFlashService(),
  screenFlash: screenFlash ?? FakeScreenFlashService(),
  contacts: contactsService ?? FakeContactService(contacts),
  notification: notification ?? FakeNotificationService(),
  isSimulation: isSimulation,
  userName: userName,
  userDescription: userDescription,
  userMedicalInfo: userMedicalInfo,
  emergencyNumberDefault: emergencyNumberDefault,
  isCancelled: isCancelled,
);
