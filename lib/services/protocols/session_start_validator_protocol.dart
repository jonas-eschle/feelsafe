import 'package:guardianangela/domain/models/session_mode.dart';
import 'package:guardianangela/domain/models/validation_result.dart';

/// Abstract interface for pre-session validation.
///
/// See spec 05 §SessionStartValidator. The `SessionController` calls
/// [validate] before allowing a session to start. Errors block start;
/// warnings are surfaced but do not block.
abstract interface class SessionStartValidatorProtocol {
  /// Validates session prerequisites for [mode].
  ///
  /// Checks (spec 05 §SessionStartValidator §Validation Checks):
  /// 1. Notification permission granted.
  /// 2. At least one emergency contact configured iff the chain has
  ///    `smsContact` or `phoneCallContact` steps (warning).
  /// 3. Required third-party apps installed (WhatsApp / Telegram /
  ///    Signal) if the chain uses those channels (warning).
  /// 4. Emergency number configured iff the chain has `callEmergency`.
  /// 5. Location permission granted iff steps use `includeLocation`.
  /// 6. SMS / Phone permissions granted for corresponding step types.
  /// 7. Microphone permission granted iff `autoRecordAudio` is enabled.
  /// 8. Battery optimization whitelist (warning only — not blocking).
  ///
  /// Returns a [ValidationResult] with [errors] (blocking) and
  /// [warnings] (non-blocking). The controller blocks session start
  /// when [ValidationResult.isValid] is `false`.
  ValidationResult validate(SessionMode mode);
}
