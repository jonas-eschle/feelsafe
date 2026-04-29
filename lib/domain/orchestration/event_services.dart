/// `EventServices` — the bundle of services + session context +
/// control hooks passed to every [EventStrategy] when it executes a
/// step.
///
/// Pure Dart. No Flutter imports. Strategies take one [EventServices]
/// argument (along with the [ChainStep]) so their signatures do not
/// change when new services are added.
library;

import 'package:guardianangela/domain/engine/tracking_buffer.dart';
import 'package:guardianangela/domain/models/session_context.dart';
import 'package:guardianangela/services/protocols/audio_service_protocol.dart';
import 'package:guardianangela/services/protocols/device_state_service_protocol.dart';
import 'package:guardianangela/services/protocols/location_service_protocol.dart';
import 'package:guardianangela/services/protocols/messaging_service_protocol.dart';
import 'package:guardianangela/services/protocols/notification_service_protocol.dart';
import 'package:guardianangela/services/protocols/phone_service_protocol.dart';
import 'package:guardianangela/services/protocols/vibration_service_protocol.dart';

/// Immutable service bundle handed to each [EventStrategy].
final class EventServices {
  /// Creates an event-services bundle.
  ///
  /// [audio] — audio playback service.
  /// [messaging] — SMS / WhatsApp / Telegram messaging service.
  /// [phone] — outbound-call service.
  /// [notification] — local-notifications service.
  /// [vibration] — haptic / vibration service.
  /// [context] — the current [SessionContext] (mode, contacts,
  /// profile, etc.).
  /// [isCancelled] — predicate the strategy polls to bail out of
  /// long-running work when the engine has moved past the step.
  /// [deviceState] — optional device-state service; null when the
  /// caller does not need DND / silent-mode introspection.
  /// [location] — optional location service used by strategies that
  /// resolve the `{location}` SMS placeholder. Strategies that need
  /// a location URL fall back to "Location unavailable" when this
  /// is null and the tracking buffer has no fix.
  /// [registerSmsWorkId] — optional callback invoked with every
  /// [MessageWorkId] the strategy enqueues so the orchestrator can
  /// cancel them if the step is preempted.
  /// [trackingBuffer] — optional spec 11 §DE-3 ephemeral GPS buffer.
  /// When non-null AND non-empty, strategies that resolve the
  /// `{location}` placeholder prefer the buffer's `latest` point
  /// over a fresh live-GPS fix.
  const EventServices({
    required this.audio,
    required this.messaging,
    required this.phone,
    required this.notification,
    required this.vibration,
    required this.context,
    required this.isCancelled,
    this.deviceState,
    this.location,
    this.registerSmsWorkId,
    this.trackingBuffer,
  });

  /// Audio playback service.
  final AudioServiceProtocol audio;

  /// Messaging service.
  final MessagingServiceProtocol messaging;

  /// Outbound-call service.
  final PhoneServiceProtocol phone;

  /// Local-notifications service.
  final NotificationServiceProtocol notification;

  /// Haptic / vibration service.
  final VibrationServiceProtocol vibration;

  /// The current session context.
  final SessionContext context;

  /// Predicate the strategy polls to bail out on cancellation.
  final bool Function() isCancelled;

  /// Optional device-state introspection service.
  final DeviceStateServiceProtocol? deviceState;

  /// Optional location service. When present, strategies that
  /// resolve `{location}` placeholders call
  /// [LocationServiceProtocol.getLastLocationUrl] to substitute the
  /// most recent fix.
  final LocationServiceProtocol? location;

  /// Optional hook invoked for each enqueued [MessageWorkId].
  final void Function(MessageWorkId)? registerSmsWorkId;

  /// Optional ephemeral tracking buffer (spec 11 §DE-3). When
  /// non-empty, strategies prefer its [TrackingBuffer.latest] point
  /// over a live GPS fix when resolving the `{location}` placeholder.
  /// Null when tracking is disabled for the active mode.
  final TrackingBuffer? trackingBuffer;
}
