/// The nine escalation step types that a [ChainStep] can represent.
///
/// See spec 03 §ChainStepType. **Order matters** (spec 03:284) —
/// `ChainStepType.values.byIndex` is used as a persistence
/// discriminator in some code paths (e.g., per-type lookups into
/// `EventDefaults`). Earlier members tend to be less severe than
/// later ones.
enum ChainStepType {
  /// Check-in step: user holds a button continuously.
  holdButton,

  /// Check-in step: a disguised notification that the user must interact
  /// with to confirm safety.
  disguisedReminder,

  /// Visible countdown before the chain escalates, giving the user a
  /// last chance to disarm.
  countdownWarning,

  /// Simulated incoming call that appears to come from a known contact.
  fakeCall,

  /// Send an SMS/WhatsApp/Telegram message to one or more emergency contacts.
  smsContact,

  /// Call an emergency contact directly.
  phoneCallContact,

  /// Play a loud alarm (siren or custom sound).
  loudAlarm,

  /// Call emergency services (112, 911, etc.).
  callEmergency,

  /// Panic/escalation trigger via a physical hardware button on the device.
  hardwareButton,
}
