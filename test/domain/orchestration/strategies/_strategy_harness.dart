/// Shared test harness for strategy tests. Wires up fake services
/// and exposes the call logs so tests can assert on side-effects.
library;

import 'package:guardianangela/domain/models/emergency_contact.dart';
import 'package:guardianangela/domain/models/event_defaults.dart';
import 'package:guardianangela/domain/models/reminder_template.dart';
import 'package:guardianangela/domain/models/session_context.dart';
import 'package:guardianangela/domain/models/session_mode.dart';
import 'package:guardianangela/domain/models/user_profile.dart';
import 'package:guardianangela/domain/orchestration/event_services.dart';
import 'package:guardianangela/services/fakes/fake_audio_service.dart';
import 'package:guardianangela/services/fakes/fake_messaging_service.dart';
import 'package:guardianangela/services/fakes/fake_notification_service.dart';
import 'package:guardianangela/services/fakes/fake_phone_service.dart';
import 'package:guardianangela/services/fakes/fake_vibration_service.dart';
import 'package:guardianangela/services/protocols/messaging_service_protocol.dart';

/// Harness that owns the fake services and constructs an
/// [EventServices] bundle on demand. Tests read the recorded calls
/// off the respective `fake*.calls` lists.
final class StrategyHarness {
  /// Creates the harness with optional overrides.
  StrategyHarness({
    SessionMode? mode,
    List<EmergencyContact>? contacts,
    UserProfile? userProfile,
    bool isSimulation = false,
    List<ReminderTemplate>? reminderTemplates,
    EventDefaults? eventDefaults,
  }) : context = SessionContext(
         mode: mode,
         contacts: contacts ?? const [],
         userProfile: userProfile,
         isSimulation: isSimulation,
         reminderTemplates: reminderTemplates ?? const [],
         eventDefaults: eventDefaults,
       );

  /// Fake audio service.
  final FakeAudioService audio = FakeAudioService();

  /// Fake messaging service.
  final FakeMessagingService messaging = FakeMessagingService();

  /// Fake phone service.
  final FakePhoneService phone = FakePhoneService();

  /// Fake notification service.
  final FakeNotificationService notification = FakeNotificationService();

  /// Fake vibration service.
  final FakeVibrationService vibration = FakeVibrationService();

  /// Session context passed into the bundle.
  final SessionContext context;

  /// Accumulator for IDs routed through `registerSmsWorkId`.
  final List<MessageWorkId> registered = <MessageWorkId>[];

  /// Last-cancellation latch — set by [isCancelled] callers.
  bool _cancelled = false;

  /// Sets the cancellation flag surfaced to strategies.
  // ignore: avoid_positional_boolean_parameters
  void setCancelled(bool value) => _cancelled = value;

  /// Builds an [EventServices] bundle wired to these fakes.
  EventServices build() => EventServices(
    audio: audio,
    messaging: messaging,
    phone: phone,
    notification: notification,
    vibration: vibration,
    context: context,
    isCancelled: () => _cancelled,
    registerSmsWorkId: registered.add,
  );

  /// Disposes every fake that holds a StreamController.
  void dispose() {
    audio.dispose();
    messaging.dispose();
    phone.dispose();
    notification.dispose();
    vibration.dispose();
  }
}
