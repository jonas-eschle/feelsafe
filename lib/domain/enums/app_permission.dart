/// Permissions that Guardian Angela may request at session start or
/// when toggling features in settings.
///
/// Mirrors the subset of `permission_handler.Permission` values that
/// the app actually uses; declared here so `lib/services/protocols/`
/// and `lib/domain/` stay Flutter-free. The concrete
/// `PermissionAuditService` maps each value to the corresponding
/// `permission_handler.Permission`.
///
/// See spec 05 §Permission Audit Flow §SessionStartValidator and
/// spec 10 §Permission Summary by Platform.
enum AppPermission {
  /// `SEND_SMS` / `READ_PHONE_STATE` (Android) — send SMS messages
  /// and read device state for SMS delivery.
  sms,

  /// `CALL_PHONE` (Android) / `CallKit` (iOS) — make phone calls.
  phone,

  /// `ACCESS_FINE_LOCATION` / `CoreLocation` — GPS during sessions.
  location,

  /// `RECORD_AUDIO` / `AVFoundation` — microphone for fake-call
  /// voice playback and user recordings.
  microphone,

  /// `CAMERA` / `AVFoundation` camera — camera flash SOS pattern.
  camera,

  /// `POST_NOTIFICATIONS` (Android 13+) / `UserNotifications` (iOS)
  /// — show local notifications.
  notification,
}
