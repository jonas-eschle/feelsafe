import 'package:guardianangela/core/utils/phone_validators.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// Maps a [PhoneNumberWarning] code to its localized advisory message.
///
/// The pure-Dart [PhoneValidators] return a code (Flutter-free); this UI-glue
/// helper turns it into a user-facing string so the emergency-number dialog and
/// the contact form render identical wording for the same condition.
String phoneWarningMessage(AppLocalizations l10n, PhoneNumberWarning warning) {
  return switch (warning) {
    PhoneNumberWarning.empty => l10n.phoneWarnEmergencyEmpty,
    PhoneNumberWarning.invalidCharacters => l10n.phoneWarnInvalidChars,
    PhoneNumberWarning.tooShort => l10n.phoneWarnTooShort,
    PhoneNumberWarning.looksLikeRegularNumber => l10n.phoneWarnLooksLikeRegular,
  };
}
