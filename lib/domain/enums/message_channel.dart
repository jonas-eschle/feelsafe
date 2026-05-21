/// Communication channels available for emergency contact messaging.
///
/// See spec 03 §MessageChannel. A contact may have multiple channels
/// enabled simultaneously; an [smsContact] step uses exactly ONE channel
/// per step (decision 15/15b).
enum MessageChannel {
  /// Standard SMS message via the platform telephony API.
  sms,

  /// WhatsApp message via the WhatsApp URL scheme.
  whatsapp,

  /// Telegram message via the Telegram URL scheme.
  telegram,

  /// Direct phone call to the contact.
  phoneCall,
}
