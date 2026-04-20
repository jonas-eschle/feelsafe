# Phase A Refactoring Review

Actionable findings from code review of model serialization,
sub-chain implementation, and engine correctness.

---

## 1. BUG: `_emit` does not populate `ChainEventData.subChainType`

**Files:** `lib/domain/engine/session_engine.dart:346,458`,
`lib/domain/models/chain_event.dart:57`

`ChainEventData` has a dedicated `subChainType` field (line 57), but the
`_emit` method has no `subChainType` parameter. Instead, the sub-chain
type is passed via the `error` field:

```dart
_emit(ChainEvent.subChainStarted, error: type.name);  // line 346
_emit(ChainEvent.subChainCompleted, error: type.name); // line 458
```

**Fix:** Add `subChainType` parameter to `_emit` and wire it to
`ChainEventData.subChainType`. Stop abusing `error` for this purpose.
Any downstream listener reading `subChainType` gets null today, and any
listener reading `error` gets the sub-chain type string when it expects
an error message.

---

## 2. BUG: `advanceFromHardwarePanic` uses `_steps` not `_effectiveSteps`

**File:** `lib/domain/engine/session_engine.dart:243,244`

```dart
if (_stepIndex >= _steps.length - 1) {
  return true;
}
```

During a sub-chain, `_stepIndex` refers to the sub-chain's step list,
but this method checks against `_steps` (the main chain). This produces
wrong results: if the sub-chain has 2 steps and the main chain has 5,
calling `advanceFromHardwarePanic` at sub-chain step 1 would NOT return
true (1 < 4), and `_advanceToNextStep` would use `_effectiveSteps`
correctly. But if the sub-chain has more steps than the main chain, the
method could return true prematurely.

**Fix:** Replace `_steps` with `_effectiveSteps` on line 243.

---

## 3. BUG: `jumpToStep` uses `_steps` not `_effectiveSteps`

**File:** `lib/domain/engine/session_engine.dart:253-256`

```dart
if (index < 0 || index >= _steps.length) {
  throw RangeError.range(index, 0, _steps.length - 1);
}
```

Same issue as above. During a sub-chain, bounds check and error message
reference the main chain length, not the active sub-chain.

**Fix:** Replace `_steps` with `_effectiveSteps` on lines 254-255.

---

## 4. BUG: `disarm()` during sub-chain leaves orphaned sub-chain state

**File:** `lib/domain/engine/session_engine.dart:174-181`

`disarm()` calls `_advanceToStep(0)`, which uses `_effectiveSteps`. So
during a sub-chain, disarm resets to step 0 of the sub-chain -- it
restarts the sub-chain from the beginning rather than completing or
aborting it. Meanwhile `_subChainSteps`, `_activeSubChainType`, and
`_mainChainSnapshot` remain set.

This means:
- After disarm, the user is still "in" the sub-chain.
- The main chain snapshot is never restored.
- The engine never transitions back to main chain execution.

**Fix:** `disarm()` during a sub-chain should either (a) complete the
sub-chain and restore main chain, or (b) abort the sub-chain, clear all
sub-chain state, and reset to main chain step 0. Decide which behavior
is correct for the safety domain and implement it. Also clear the
`_subChainQueue`.

---

## 5. Memory: `endSession`/`dispose` do not clear sub-chain state

**File:** `lib/domain/engine/session_engine.dart:110-116,394-398`

Neither `endSession()` nor `dispose()` clear `_subChainSteps`,
`_subChainQueue`, `_mainChainSnapshot`, `_activeSubChainType`, or
`_pendingEvents`. These hold references to `ChainStep` lists and
`EngineRunning` snapshots.

**Fix:** Add cleanup in `dispose()`:
```dart
void dispose() {
  _cancelTimer();
  _subChainSteps = null;
  _activeSubChainType = null;
  _mainChainSnapshot = null;
  _subChainQueue.clear();
  _pendingEvents.clear();
  if (!_controller.isClosed) _controller.close();
}
```

---

## 6. Fragile: `runtimeType.toString()` for serialization discriminator

**File:** `lib/domain/models/step_config.dart:13`

```dart
'type': runtimeType.toString(),
```

`runtimeType.toString()` is not guaranteed to be stable across Dart
minification/obfuscation (e.g., `dart compile` with `--obfuscate`, or
Flutter release builds with `--obfuscate`). If the app ever enables
obfuscation, all persisted JSON will fail to deserialize.

**Fix:** Add an explicit `String get typeName` getter to each
`StepConfig` subclass (or a `static const` field), matching the string
used in `fromJson`. Example:

```dart
sealed class StepConfig {
  String get typeName;
  Map<String, dynamic> toJson() => {
    'type': typeName,
    'data': _dataToJson(),
  };
}

class HoldButtonConfig extends StepConfig {
  @override
  String get typeName => 'HoldButtonConfig';
  // ...
}
```

---

## 7. Duplication: Three sub-chain config models are near-identical

**Files:**
- `lib/domain/models/duress_chain_config.dart`
- `lib/domain/models/battery_alert_config.dart`
- `lib/domain/models/wrong_pin_chain_config.dart`

All three models share the same structure: `chainSteps` +
`isEnabled` + identical `toJson`/`fromJson` boilerplate. The only
difference is that `BatteryAlertConfig` adds a `threshold` field.

**Fix:** Extract a common base class or use a single generic model:

```dart
class SubChainConfig {
  const SubChainConfig({
    this.chainSteps = const [],
    this.isEnabled = false,
  });
  final List<ChainStep> chainSteps;
  final bool isEnabled;
  // shared toJson/fromJson
}

class BatteryAlertConfig extends SubChainConfig {
  const BatteryAlertConfig({
    this.threshold = 10,
    super.chainSteps,
    super.isEnabled,
  });
  final int threshold;
}
```

This eliminates ~40 lines of duplicated serialization code.

---

## 8. Missing null-safety: `EventDefaults.fromJson` hard-casts all fields

**File:** `lib/domain/models/event_defaults.dart:41-70`

Every field does `j['holdButton'] as Map<String, dynamic>` without null
checks. If any key is missing from the JSON (e.g., a new field added in
a future version), this throws `TypeError` at runtime with no useful
message.

**Fix:** Provide fallbacks using the const default configs:

```dart
holdButton: j['holdButton'] != null
    ? StepConfig.fromJson(j['holdButton'] as Map<String, dynamic>)
        as HoldButtonConfig
    : const HoldButtonConfig(),
```

Apply to all 9 fields. This also makes `EventDefaults` forward-
compatible: adding a 10th step type won't break deserialization of
existing data.

---

## 9. Missing null-safety: `LocationPoint.fromJson` hard-casts

**File:** `lib/domain/models/location_point.dart:23-25`

```dart
latitude: (j['latitude'] as num).toDouble(),
longitude: (j['longitude'] as num).toDouble(),
timestamp: DateTime.parse(j['timestamp'] as String),
```

All three fields are hard-cast with no null checks. A missing or
malformed key throws a cryptic `TypeError` or `FormatException`.

**Fix:** These are genuinely required fields, but the error should be
clear. Wrap in a descriptive check or use `ArgumentError`:

```dart
latitude: (j['latitude'] as num?)?.toDouble()
    ?? (throw ArgumentError('latitude required in LocationPoint JSON')),
```

This is consistent with `ChainStep.fromJson` which also hard-casts
required fields (`id`, `type`, `order`) but at least those will throw
a `TypeError` with a meaningful cast expression.

---

## 10. Missing null-safety: `SessionLog.fromJson` hard-casts required fields

**File:** `lib/domain/models/session_log.dart:107-111`

```dart
id: j['id'] as String,
startTime: DateTime.parse(j['startTime'] as String),
modeName: j['modeName'] as String,
modeId: j['modeId'] as String,
```

Same issue as LocationPoint. Hard casts on required fields produce
unhelpful error messages. Consider the same `ArgumentError` pattern.

---

## 11. Inconsistent envelope pattern in serialization

**Files:** `lib/domain/models/step_config.dart` vs all other models

`StepConfig` uses a type envelope (`{"type": "...", "data": {...}}`),
`HardwareTrigger` uses a flat type tag (`{"type": "...", ...fields}`),
`DistressTrigger`/`DisarmTrigger` use a flat type tag. All other models
use flat serialization with no type discriminator.

This inconsistency is not a bug (the non-sealed classes don't need a
discriminator), but the two sealed hierarchies -- `StepConfig` (envelope)
vs `HardwareTrigger`/`DistressTrigger`/`DisarmTrigger` (flat) -- use
different patterns for the same problem.

**Fix:** Pick one pattern and use it consistently across all sealed
hierarchies. The flat pattern is simpler and more conventional (no
nested `data` key). Migrate `StepConfig` to the flat pattern:

```dart
// Before (envelope):
{'type': 'HoldButtonConfig', 'data': {'holdStyle': 'largeButton', ...}}

// After (flat):
{'type': 'HoldButtonConfig', 'holdStyle': 'largeButton', ...}
```

This also simplifies `_dataToJson()` to just `toJson()` with
the type field merged in.

**Migration note:** Since the CLAUDE.md says "no backwards
compatibility -- on schema mismatch, all boxes are nuked and re-seeded",
this is safe to change.

---

## 12. `byName` on enums can throw with no recovery path

**Files:** All models using `.byName()` (14 call sites across 6 files)

`EnumType.values.byName(str)` throws `ArgumentError` if the string
doesn't match any enum value. Most call sites provide a fallback via
`as String? ?? 'default'`, which handles null but not an invalid string.

Example: if stored JSON has `"holdStyle": "newFutureValue"` (from a
newer app version), `HoldStyle.values.byName('newFutureValue')` throws.

**Fix:** Create a helper extension:

```dart
extension EnumByNameOrDefault<T extends Enum> on Iterable<T> {
  T byNameOr(String? name, T defaultValue) {
    if (name == null) return defaultValue;
    for (final value in this) {
      if (value.name == name) return value;
    }
    return defaultValue;
  }
}
```

Replace all `EnumType.values.byName(j['x'] as String? ?? 'default')`
with `EnumType.values.byNameOr(j['x'] as String?, EnumType.default)`.

This is a single helper that eliminates the crash-on-unknown-value
risk at all 14 call sites.

---

## 13. `ChainStep` and `EmergencyContact` lack `copyWith`

**Files:**
- `lib/domain/models/chain_step.dart`
- `lib/domain/models/emergency_contact.dart`

`AppSettings` and `UserProfile` have `copyWith` methods.
`ChainStep` and `EmergencyContact` do not.

Both are immutable data classes that will need field-level updates in
edit screens (e.g., changing a step's `waitSeconds` or a contact's
`phoneNumber`).

**Fix:** Add `copyWith` to both classes. This prevents UI code from
reconstructing the full object manually, which is error-prone as fields
are added.

---

## 14. `SessionLog.events` is mutable despite model being "persistent"

**File:** `lib/domain/models/session_log.dart:81,92`

```dart
final List<SessionLogEvent> events;
```

The doc says "Events appended immediately as they occur," so mutability
is intentional. But the `events` list is exposed as a raw `List` that
callers can modify (clear, reorder, etc.). `endTime` is also mutable
(`DateTime? endTime;` not `final`).

**Fix:** Either:
- Make `events` an `UnmodifiableListView` getter backed by a private
  mutable list, with an explicit `addEvent()` method, or
- Accept the mutability but document it clearly in the class doc.

The current state is a halfway design: `final` keyword prevents
reassignment but not mutation of the list contents.

---

## Summary by priority

| # | Severity | Item |
|---|----------|------|
| 1 | Bug | `_emit` does not populate `subChainType` field |
| 2 | Bug | `advanceFromHardwarePanic` uses wrong step list |
| 3 | Bug | `jumpToStep` uses wrong step list |
| 4 | Bug | `disarm()` during sub-chain leaves orphaned state |
| 5 | Medium | `dispose`/`endSession` do not clear sub-chain state |
| 6 | Medium | `runtimeType.toString()` fragile under obfuscation |
| 7 | Low | Three sub-chain config models duplicated |
| 8 | Medium | `EventDefaults.fromJson` hard-casts all fields |
| 9 | Low | `LocationPoint.fromJson` hard-casts required fields |
| 10 | Low | `SessionLog.fromJson` hard-casts required fields |
| 11 | Low | Inconsistent envelope vs flat serialization |
| 12 | Medium | `byName` throws on unknown enum values |
| 13 | Low | Missing `copyWith` on ChainStep, EmergencyContact |
| 14 | Low | `SessionLog.events` mutability design |
