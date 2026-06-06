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

/// Immutable bundle of all service dependencies and session-scoped data
/// passed to every [EventStrategy].
///
/// Constructing a single [EventServices] per session and sharing it across
/// all strategy invocations avoids service-locator lookups inside hot paths.
///
/// The [isSimulation] flag is the Layer 2 simulation safety guard. Every
/// [EventStrategy.executeReal] MUST short-circuit and return immediately
/// when `services.isSimulation == true`, logging a `sim_blocked` line via
/// `dart:developer.log`. This is defence-in-depth on top of the engine's
/// Layer 1 flag (spec 01 §Sim Defense).
final class EventServices {
  /// Creates an immutable [EventServices] bundle.
  const EventServices({
    required this.audio,
    required this.vibration,
    required this.messaging,
    required this.phone,
    required this.location,
    required this.recording,
    required this.flash,
    required this.screenFlash,
    required this.contacts,
    required this.notification,
    required this.isSimulation,
    this.userName,
    this.userDescription,
    this.userMedicalInfo,
    this.emergencyNumberDefault,
    this.alarmDndOverride = false,
    this.alarmGradualVolume = false,
    this.alarmGradualVolumeDurationSeconds = 5,
    this.isCancelled,
  });

  // ─── Service protocols ─────────────────────────────────────────────────────

  /// Audio playback service (alarms, countdown sounds).
  final AudioServiceProtocol audio;

  /// Haptic feedback service (warning pattern, alarm pattern).
  final VibrationServiceProtocol vibration;

  /// Outbound messaging service (SMS, WhatsApp, Telegram).
  final MessagingServiceProtocol messaging;

  /// Phone call service (contact calls, emergency calls).
  final PhoneServiceProtocol phone;

  /// GPS location service (Maps URL, fallback description).
  final LocationServiceProtocol location;

  /// Audio recording service (auto-record before SMS).
  final RecordingServiceProtocol recording;

  /// Camera flashlight service (SOS strobe).
  final FlashServiceProtocol flash;

  /// Screen flash service (white/red alternating strobe).
  final ScreenFlashServiceProtocol screenFlash;

  /// Emergency contact lookup service.
  final ContactServiceProtocol contacts;

  /// Notification service for alarm-escalation and disguised-reminder
  /// notifications. Used by [FakeCallStrategy], [LoudAlarmStrategy],
  /// [CallEmergencyStrategy], and [DisguisedReminderStrategy].
  final NotificationServiceProtocol notification;

  // ─── Session-scoped data ───────────────────────────────────────────────────

  /// Layer 2 simulation safety guard.
  ///
  /// When `true`, every [EventStrategy.executeReal] MUST immediately log
  /// a `sim_blocked` message via `dart:developer.log` and return without
  /// performing any real action (sending SMS, making calls, etc.). This
  /// guards against simulation flag bugs at the engine level.
  final bool isSimulation;

  /// The user's display name from [UserProfile].
  ///
  /// Used for the `{name}` placeholder in message templates. When `null`,
  /// strategies substitute `'the owner of this phone'` per spec 02
  /// §smsContact §Placeholders.
  final String? userName;

  /// The user's physical description from [UserProfile].
  ///
  /// Used for the `{description}` placeholder in message templates.
  /// When `null`, the placeholder is substituted with an empty string.
  final String? userDescription;

  /// The user's medical information from [UserProfile].
  ///
  /// Appended to SMS messages when `SmsContactConfig.includeMedicalInfo`
  /// is `true`. When `null`, no medical info is appended even if the
  /// config flag is set.
  final String? userMedicalInfo;

  /// The app-wide emergency call number from [AppSettings.emergencyCallNumber].
  ///
  /// Used by [CallEmergencyStrategy] when no per-step override is set in
  /// [CallEmergencyConfig.emergencyNumber]. `null` means no default was
  /// configured (throws [StateError] in the strategy if the step also
  /// has no override).
  final String? emergencyNumberDefault;

  /// Whether the loud alarm may override silent/DND (spec 06 §Override Silent).
  ///
  /// Mirrors [AppSettings.alarmDndOverride] (default `false`, opt-in per Q19).
  /// [LoudAlarmStrategy] plumbs this into
  /// [AudioServiceProtocol.playAlarmWithConfig] so STREAM_ALARM only bypasses
  /// silent/DND when the user opted in.
  final bool alarmDndOverride;

  /// App-wide gradual-volume master toggle (spec 06 §Gradual Volume Increase).
  ///
  /// Mirrors [AppSettings.alarmGradualVolume] (default `false`). The volume
  /// ramp fires only when this AND the per-step [LoudAlarmConfig.gradualVolume]
  /// are both `true` (spec 02 §loudAlarm).
  final bool alarmGradualVolume;

  /// Gradual-volume ramp duration in seconds (spec 06 §Gradual Volume Duration).
  ///
  /// Mirrors [AppSettings.alarmGradualVolumeDurationSeconds] (default 5).
  /// Applied only when the ramp is active.
  final int alarmGradualVolumeDurationSeconds;

  /// Cooperative cancellation poll for long-running operations.
  ///
  /// Pure-Dart callback (`bool Function()?`) — not Flutter's `VoidCallback`.
  /// Long-running strategies (e.g. [LoudAlarmStrategy]) can poll this to
  /// detect session cancellation. `null` means no cancellation check is
  /// available (no-op; strategy runs to natural completion).
  ///
  /// Returns `true` when the session has been cancelled and the strategy
  /// should stop as soon as possible.
  // ignore: avoid_returning_null_for_void (this is intentionally a bool poll)
  final bool Function()? isCancelled;
}
