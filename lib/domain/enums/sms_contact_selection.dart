/// Selects which contacts an [smsContact] step targets at runtime.
///
/// See spec 03 §SmsContactConfig. The UI contact-button picker infers
/// [allContacts] or [specificIds] at save time; [firstContact] is a
/// write-only legacy value honoured at runtime but not reachable from
/// the redesigned contact-button picker.
enum SmsContactSelection {
  /// Every emergency contact whose [channels] list includes the step's
  /// channel. Dynamic: newly added contacts are auto-included.
  allContacts,

  /// Only the contact with the lowest [sortOrder] (ties broken by list
  /// order). Used by the default distress chain.
  firstContact,

  /// Only contacts whose IDs appear in [SmsContactConfig.contactIds].
  /// Static: newly added contacts are NOT auto-included.
  specificIds,
}
