// Package-private phone number utilities shared by [PhoneService] and
// [MessagingService].
//
// Leading underscore marks this file as package-private per Dart convention.
// Pure Dart — no Flutter dependency.

/// Sanitizes a phone number by removing all non-digit characters except a
/// leading `+` prefix for international numbers.
///
/// Examples:
/// - `'+1 (555) 123-4567'` → `'+15551234567'`
/// - `'0044 20 7946 0958'` → `'00442079460958'`
///
/// Throws [ArgumentError] if [phoneNumber] is empty after sanitization.
String sanitizePhoneNumber(String phoneNumber) {
  final trimmed = phoneNumber.trim();

  // Preserve leading '+' for international format.
  final hasPlus = trimmed.startsWith('+');

  // Strip every character that is not a digit.
  final digitsOnly = trimmed.replaceAll(RegExp(r'[^\d]'), '');

  final result = hasPlus ? '+$digitsOnly' : digitsOnly;

  if (result.isEmpty || result == '+') {
    throw ArgumentError.value(
      phoneNumber,
      'phoneNumber',
      'Phone number is empty after sanitization',
    );
  }

  return result;
}
