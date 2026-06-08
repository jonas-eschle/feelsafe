/// Identifies a user-facing notification channel for per-channel
/// enablement queries.
///
/// Maps onto the four Android notification channels created in
/// [RealNotificationService._createAndroidChannels]:
/// `alarm`, `reminders`, and the dedicated fake-call escalation
/// channel. The session-service channel is omitted because it is
/// required for the foreground service to run.
enum NotificationChannelKey {
  /// `alarm` channel — critical escalations that bypass DND.
  alarm,

  /// `reminders` channel — disguised check-in reminders.
  reminder,

  /// `fake_call` channel — full-screen incoming-call notifications.
  fakeCall,
}

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
  ///
  /// When [stealth] is `true` the notification additionally adopts a generic
  /// channel name and a neutral status-bar icon so neither the notification
  /// shade nor the lock screen reveals the app's true identity (spec 05
  /// §Notification UI §Stealth Mode, spec 06:97 `notificationDisguise`). The
  /// [title]/[body] are already the disguised template strings supplied by the
  /// caller; [stealth] governs only the channel/icon chrome.
  Future<void> showDisguisedReminder({
    required int id,
    required String title,
    required String body,
    bool stealth = false,
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
  /// [stealth] is `true`, the notification adopts the disguised appearance: a
  /// generic channel name and a neutral status-bar icon so it does not reveal
  /// the app's purpose. The disguise app name itself ([fakeName]) is supplied
  /// by the caller as [title]; [fakeName] is threaded through so the underlying
  /// service can reuse it for derived text (e.g. the `"<name> paused"` state).
  Future<void> showForegroundServiceNotification({
    required String title,
    required String body,
    bool stealth = false,
    String? fakeName,
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

  /// Returns whether [channel] is currently enabled at the OS level.
  ///
  /// On Android this reflects the per-channel toggle in System Settings;
  /// on iOS this returns the overall app-level setting because iOS does
  /// not expose per-channel state via the public API.
  Future<bool> isChannelEnabled(NotificationChannelKey channel);

  /// Opens the system settings page for [channel].
  ///
  /// On Android calls `flutter_local_notifications`'
  /// `openNotificationSettings` with the channel id. On iOS / desktop
  /// the OS opens the general app notification settings (no per-channel
  /// drill-down is available).
  Future<void> openChannelSettings(NotificationChannelKey channel);
}
