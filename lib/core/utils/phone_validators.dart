/// Non-blocking phone-number validators for the emergency number (Extra 25)
/// and per-contact phone fields (Extra 26).
///
/// Pure Dart, Flutter-free: the validators return a [PhoneNumberWarning] code
/// (or `null` when the input looks fine) and the UI layer maps the code to a
/// localized message. They never throw and never block on their own — the
/// caller decides what to do with each code. See spec 06 §Emergency Number.
library;

/// A non-blocking advisory about a phone-number field.
///
/// All warnings are advisory (rendered below the input) EXCEPT [empty] on the
/// emergency-number field, where the editor blocks Save until non-empty
/// (spec 06: "The editor never allows saving an empty string").
enum PhoneNumberWarning {
  /// The field is empty. Advisory for contacts; Save-blocking for the
  /// emergency number (the caller enforces the block).
  empty,

  /// Contains a character outside the allowed set (digits, `+`, `*`, `#`).
  /// Letters, hyphens, spaces, and parentheses trigger this.
  invalidCharacters,

  /// Fewer than 3 digits — unusually short for an emergency services number.
  tooShort,

  /// More than 6 digits — looks like a regular phone number rather than an
  /// emergency services short code.
  looksLikeRegularNumber,
}

/// Allowed characters in an emergency / dialable short number: the ASCII
/// digits plus the DTMF-relevant `+`, `*`, and `#`.
final RegExp _kAllowedChars = RegExp(r'^[0-9+*#]+$');

/// Counts the ASCII digits (`0`-`9`) in [value].
int _digitCount(String value) => value
    .split('')
    .where((String c) => c.compareTo('0') >= 0 && c.compareTo('9') <= 0)
    .length;

/// Validators for dialable phone-number fields.
///
/// Stateless; all members are static. See the library doc-comment.
abstract final class PhoneValidators {
  /// Validates an emergency-services number (spec 06 §Emergency Number,
  /// Extra 25). Returns the first applicable [PhoneNumberWarning], or `null`
  /// when the value looks like a valid emergency number.
  ///
  /// Order of checks:
  /// 1. [PhoneNumberWarning.empty] — the caller blocks Save on this.
  /// 2. [PhoneNumberWarning.invalidCharacters] — anything outside `0-9 + * #`.
  /// 3. [PhoneNumberWarning.tooShort] — fewer than 3 digits.
  /// 4. [PhoneNumberWarning.looksLikeRegularNumber] — more than 6 digits.
  ///
  /// The input is **not** trimmed here — a leading/trailing space is itself an
  /// invalid character and is reported as such, matching the spec's
  /// "any other character … emits a warning". Callers that store the value
  /// should trim before persisting.
  static PhoneNumberWarning? warnEmergencyNumber(String value) {
    if (value.isEmpty) {
      return PhoneNumberWarning.empty;
    }
    if (!_kAllowedChars.hasMatch(value)) {
      return PhoneNumberWarning.invalidCharacters;
    }
    final int digits = _digitCount(value);
    if (digits < 3) {
      return PhoneNumberWarning.tooShort;
    }
    if (digits > 6) {
      return PhoneNumberWarning.looksLikeRegularNumber;
    }
    return null;
  }

  /// Validates a per-contact phone number (spec 06 §Emergency Number, Extra
  /// 26). Returns a [PhoneNumberWarning] code, or `null` when the value looks
  /// fine.
  ///
  /// A contact's number is a *regular* phone number, so — unlike
  /// [warnEmergencyNumber] — there are no length warnings: a 10-digit mobile
  /// is expected, not suspicious. Only the character-class check applies (the
  /// allowed set additionally tolerates spaces and hyphens commonly used to
  /// format a phone number; letters and parentheses still warn). [empty] is
  /// advisory here — the contact form already blocks an empty phone via its
  /// own required-field check (`validationPhoneRequired`).
  static PhoneNumberWarning? warnContactNumber(String value) {
    if (value.isEmpty) {
      return PhoneNumberWarning.empty;
    }
    if (!_kContactAllowedChars.hasMatch(value)) {
      return PhoneNumberWarning.invalidCharacters;
    }
    return null;
  }
}

/// Allowed characters in a contact phone number: the emergency set plus the
/// common visual separators (space and hyphen) people type into a phone field.
/// Letters and parentheses are still flagged.
final RegExp _kContactAllowedChars = RegExp(r'^[0-9+*#\s-]+$');
