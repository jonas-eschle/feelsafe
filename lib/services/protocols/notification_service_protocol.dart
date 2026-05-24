/// Action-ID prefix for SMS-retry notification buttons.
///
/// The `actionTaps` stream emits raw action IDs; controllers match
/// against this prefix to extract the retry payload (spec 05:293).
const String kActionRetrySmsPrefix = 'ga_retry_sms_';

/// Abstract interface for local notifications across all four Guardian
/// Angela notification channels.
///
/// See spec 05 §Notification Channel Architecture (lines 1279–1293) and
/// §BackgroundSessionService §Notification Channels (lines 794–870).
/// Phase 5 supplies the concrete implementation.
///
/// Channel IDs:
/// - `session_service` — Low importance, foreground-service persistent.
/// - `reminders`       — High importance, disguised check-in reminders.
/// - `alarm`           — Max importance, urgent escalation / emergency.
/// - `updates`         — Default importance, app info updates.
abstract interface class NotificationServiceProtocol {
  /// Shows a disguised reminder notification on the `reminders` channel.
  ///
  /// Every call automatically applies maximum-urgency flags so the
  /// reminder surfaces when the device is locked (Extra 35):
  /// - Android: `Importance.max`, `Priority.max`, `fullScreenIntent: true`,
  ///   `category=alarm`, `visibility=public`.
  /// - iOS: `InterruptionLevel.timeSensitive`.
  ///
  /// [title] and [body] are the displayed (possibly disguised) strings.
  /// [id] uniquely identifies this notification for later cancellation.
  Future<void> showDisguisedReminder({
    required int id,
    required String title,
    required String body,
  });

  /// Shows an SMS-retry-exhausted notification on the `alarm` channel.
  ///
  /// Posted when an Android WorkManager SMS job exhausts all retries.
  /// Includes a "Retry" action button whose tap ID is
  /// `kActionRetrySmsPrefix + actionPayload`. See spec 05:293.
  ///
  /// [contactName] is the contact's display name used in the
  /// notification title. [actionPayload] is the opaque payload embedded
  /// in the action ID (callers use it to look up the cached
  /// `SmsRetryExhaustedEvent`).
  Future<void> showSmsRetryExhaustedNotification({
    required String contactName,
    required String actionPayload,
  });

  /// Shows or updates the foreground-service persistent notification on
  /// the `session_service` channel.
  ///
  /// [title] and [body] reflect the current session state. When
  /// [stealth] is `true`, the notification uses the configured disguise
  /// text and a neutral icon preset so it does not reveal the app's
  /// purpose.
  Future<void> showForegroundServiceNotification({
    required String title,
    required String body,
    bool stealth = false,
  });

  /// Shows an escalation notification that bypasses Do Not Disturb.
  ///
  /// Used by alarm, fake-call, and emergency escalation steps when the user
  /// needs to be alerted regardless of device DND/silent mode.
  ///
  /// On iOS: uses `DarwinNotificationDetails(criticalAlert: true, sound: sound)`
  /// which requires the `com.apple.developer.usernotifications.critical-alerts`
  /// entitlement provisioned in `Runner/Runner.entitlements` (spec 05:880-886).
  ///
  /// On Android: uses the `alarm` channel with `Importance.max`,
  /// `fullScreenIntent: true`, and `AndroidNotificationCategory.alarm`.
  ///
  /// [sound] on iOS is the filename of a bundled `.wav` sound resource.
  /// Ignored on Android (the channel provides the sound).
  Future<void> showAlarmEscalation({
    required int id,
    required String title,
    required String body,
    String sound = 'critical_alert.wav',
  });

  /// Cancels the notification with the given [id].
  ///
  /// No-op if no notification with that ID exists.
  Future<void> cancel(int id);

  /// Broadcast stream of raw action-button tap IDs.
  ///
  /// Each value is the raw action-ID string embedded in the notification
  /// button. Controllers test against `kActionRetrySmsPrefix` to handle
  /// retry taps; future action IDs follow the same prefix-keyed pattern.
  Stream<String> get actionTaps;

  /// Requests notification permission from the OS.
  ///
  /// Returns `true` if permission is granted (or was already granted).
  Future<bool> requestPermission();
}
