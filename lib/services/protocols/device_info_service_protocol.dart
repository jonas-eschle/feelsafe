/// Outcome of a SIM-phone-number read attempt.
///
/// See spec 04 §Onboarding (Extra 28) and the per-platform expectations
/// table at spec 04:232. The Android-only happy path returns a
/// non-empty E.164-ish string in [number]; every other outcome carries a
/// reason explaining why the read failed so the UI can surface an
/// honest message rather than silently swallowing the failure.
sealed class SimNumberResult {
  const SimNumberResult();
}

/// Number successfully read from the SIM.
final class SimNumberAvailable extends SimNumberResult {
  /// Creates a successful result with the [number] read from the SIM.
  const SimNumberAvailable(this.number);

  /// Phone number reported by the SIM in raw (possibly non-E.164) form.
  final String number;
}

/// The user denied (or revoked) the runtime permission required to
/// read the SIM identity.
final class SimNumberPermissionDenied extends SimNumberResult {
  /// Creates a permission-denied outcome.
  const SimNumberPermissionDenied();
}

/// The platform does not support reading the SIM number at all
/// (iOS, web, desktop).
final class SimNumberUnsupported extends SimNumberResult {
  /// Creates an unsupported-platform outcome.
  const SimNumberUnsupported();
}

/// Generic platform failure (SIM removed, eSIM stub, etc.).
final class SimNumberUnavailable extends SimNumberResult {
  /// Creates a generic-failure outcome with an optional [reason].
  const SimNumberUnavailable([this.reason]);

  /// Human-readable failure reason, or null when unknown.
  final String? reason;
}

/// Abstract interface for reading device-level identity used by the
/// onboarding "Use my SIM number" affordance (spec 04 §Onboarding,
/// Extra 28).
///
/// Phase 7 supplies the concrete Android implementation that talks to
/// `com.guardianangela.app/device_info` via MethodChannel
/// `getSimPhoneNumber`. iOS / Web / Linux / Windows / macOS return
/// [SimNumberUnsupported] without invoking any platform code.
abstract interface class DeviceInfoServiceProtocol {
  /// Reads the SIM card's phone number, returning a structured
  /// [SimNumberResult].
  ///
  /// The protocol intentionally avoids throwing — every failure mode
  /// surfaces a typed result so the UI can pick the right message.
  Future<SimNumberResult> getSimPhoneNumber();
}
