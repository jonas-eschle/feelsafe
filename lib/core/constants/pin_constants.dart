/// PIN length bounds shared by every PIN keypad (spec 06 §PIN Length).
///
/// PINs are [kPinMinLength]–[kPinMaxLength] digits. The entry keypads
/// auto-submit as soon as the entered prefix matches a stored PIN hash, so a
/// correct PIN of any length succeeds the instant it is fully typed.
///
/// A wrong attempt is counted **only** once the entry reaches [kPinMaxLength]
/// with no match: a shorter non-matching entry may still be the prefix of a
/// longer correct PIN, so counting it as wrong would lock a legitimate user
/// out — and, at a distress-firing prompt (launch gate, session-end,
/// distress-cancel), would trigger a *false distress chain*. Entry is capped
/// at [kPinMaxLength] digits.
library;

/// Minimum PIN length (digits).
const int kPinMinLength = 4;

/// Maximum PIN length (digits). Also the entry cap and the point at which a
/// non-matching entry is finally counted as a wrong attempt.
const int kPinMaxLength = 8;
