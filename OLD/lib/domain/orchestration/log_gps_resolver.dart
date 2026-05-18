/// `LogGpsResolver` — resolves the effective per-step GPS-logging
/// boolean for a `ChainStep` (spec 11 §DE-2).
///
/// Resolution order, innermost wins:
///   1. `step.config.logGps` (per-instance)
///   2. `EventDefaults.forType(step.type).logGps` (per-type default)
///   3. `SessionContext.gpsLoggingEnabled` (mode override or global)
///
/// Pure Dart, no Flutter — sits next to the orchestration layer so
/// strategies share one chokepoint. Strategies that may write a GPS
/// fix (sms_contact, phone_call_contact, call_emergency) call this
/// before invoking [LocationResolver] / `services.location`.
library;

import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/models/step_config.dart';
import 'package:guardianangela/domain/orchestration/event_services.dart';

/// Static helper namespace for the DE-2 resolution pipeline.
final class LogGpsResolver {
  // No public constructor — purely static API.
  const LogGpsResolver._();

  /// Returns the effective GPS-logging boolean for [step].
  ///
  /// Walks the three layers per spec 11 §DE-2 and returns the first
  /// non-`useDefault` answer. When every layer says `useDefault`, the
  /// session-wide [SessionContext.gpsLoggingEnabled] decides.
  ///
  /// *Why not surface the helper on `EventServices`:* keeping the
  /// resolver as a pure static avoids growing the services API and
  /// keeps the call-site obvious.
  static bool resolve(ChainStep step, EventServices services) {
    final stepValue = _stepLogGps(step);
    final defaultsValue = _defaultsLogGps(step, services);
    final sessionEnabled = services.context.gpsLoggingEnabled;
    return resolveLogGps(stepValue, defaultsValue, sessionEnabled);
  }

  /// Reads `step.config?.logGps` if a typed config is attached.
  static LogGpsOverride? _stepLogGps(ChainStep step) {
    final cfg = step.config;
    return cfg?.logGps;
  }

  /// Reads `EventDefaults.forType(step.type).logGps` from the
  /// session context, if `eventDefaults` is wired. Returns `null`
  /// when no defaults are available.
  static LogGpsOverride? _defaultsLogGps(
    ChainStep step,
    EventServices services,
  ) {
    final defaults = services.context.eventDefaults;
    if (defaults == null) return null;
    return defaults.forType(step.type).logGps;
  }
}
