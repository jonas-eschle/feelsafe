/// Shared enums for Guardian Angela's data layer.
///
/// Pure Dart. No Flutter imports. Persistence via Drift `TypeConverter`s
/// introduced in Phase 6.
library;

/// Channels over which an emergency contact can be reached.
///
/// A single contact can enable multiple channels; every enabled channel
/// fires for every step that targets the contact unless a step config
/// narrows to one (e.g., `SmsContactConfig.channel`).
enum MessageChannel {
  /// Short Message Service. Android can send silently in the background
  /// when `SEND_SMS` is granted; iOS falls back to the `sms:` URI which
  /// requires foreground confirmation.
  sms,

  /// WhatsApp deep link via `url_launcher`. Requires the app installed
  /// on the device.
  whatsapp,

  /// Telegram deep link via `url_launcher`. Requires the app installed
  /// on the device.
  telegram,

  /// Voice phone call. Used by `PhoneCallContactStrategy`.
  phoneCall,
}

/// The nine escalation step types driving `SessionEngine`.
///
/// Ordering convention: earlier values are less severe check-in or
/// warning types; later values (`loudAlarm`, `callEmergency`) are the
/// most severe escalations.
enum ChainStepType {
  /// User holds a button; releasing starts a grace period.
  holdButton,

  /// Periodic disguised notification requiring confirmation.
  disguisedReminder,

  /// Visible countdown before the next escalation fires.
  countdownWarning,

  /// Simulated incoming call the user can answer / decline / hang up.
  fakeCall,

  /// Send a message to one or more emergency contacts.
  smsContact,

  /// Place a voice call to an emergency contact.
  phoneCallContact,

  /// Play a loud alarm + flash + vibration pattern.
  loudAlarm,

  /// Dial the configured emergency number.
  callEmergency,

  /// Panic trigger via volume / power / headphone-remote hardware.
  ///
  /// Not a step a user actively progresses through — it is the trigger
  /// that replaces the main chain with the distress chain.
  hardwareButton,
}

/// How the user confirms safety during a `disguisedReminder` step.
enum ConfirmationType {
  /// Tap a labeled confirmation button.
  tapButton,

  /// Tap a specific word from a grid of choices.
  tapWord,

  /// Swipe the on-screen affordance in a specific direction.
  swipe,

  /// Tap anywhere to dismiss (no meaningful confirmation).
  dismiss,
}

/// How a `disguisedReminder` template is rendered.
enum ReminderDisplayStyle {
  /// Takes over the entire screen.
  fullScreen,

  /// Overlay or notification card; user can keep using the device.
  subtle,
}

/// Why the session entered the distress chain.
///
/// Used by `DistressOrchestrationController.fireBecauseOfPin` and
/// related call sites to discriminate the trigger source. Drives the
/// deceptive wrong-PIN dialog (only fires for
/// [TriggerReason.wrongPinExhausted]) and the session-end reason in
/// `SessionLog`.
enum TriggerReason {
  /// Fired by a hardware-button pattern (e.g., 5× volume in 1.5s).
  hardwarePanic,

  /// Fired because the wrong-PIN threshold was hit.
  ///
  /// *Why distinguish:* the deceptive "Old PIN from Angela" dialog
  /// must show, and the session-end reason should be
  /// `EndReason.wrongPinExhausted`.
  wrongPinExhausted,

  /// Fired because the duress PIN was entered.
  ///
  /// *Why distinguish:* the dialog is suppressed (the user
  /// deliberately keyed in the duress PIN; surfacing a fake-Angela
  /// prompt would tip off an observer).
  duressPin,
}
