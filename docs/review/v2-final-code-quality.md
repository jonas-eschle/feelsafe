# V2 Final Code Quality Review

Reviewed: All 110 Dart files in `lib/`
Date: 2026-04-11

---

## CRITICAL

### C1. Simulation mode does NOT inject simulation services -- real SMS/calls possible during simulation
**Files:** `lib/features/session/session_controller.dart` (lines 96-185)
**Description:** `startSession()` always reads `messagingServiceProvider` and `phoneServiceProvider` from the real service providers. The `simulationMessagingProvider` and `simulationPhoneProvider` defined in `service_providers.dart` are never used anywhere in the codebase. When `isSimulation=true`, the `MessagingService` has an `isSimulation` parameter guard on `sendMessage()` (returns early), but the battery alert SMS path at line 262 calls `messaging.sendToAll()` without passing `isSimulation`. The `SmsContactStrategy` and `PhoneCallContactStrategy` are currently stub/no-op in the orchestrator's default registry but this is not a structural guarantee -- any future wiring of real service calls through strategies could accidentally send real messages in simulation mode.

**Severity:** CRITICAL
**Fix:** Either (a) swap `messagingServiceProvider`/`phoneServiceProvider` with their simulation variants when `isSimulation=true` inside `startSession()`, or (b) wrap `_startBatteryMonitor` SMS path with `!isSimulation` check (it IS there at line 262 but only for the battery SMS branch -- the orchestrator strategies are the real risk).

### C2. Battery alert SMS bypasses simulation check at `sendToAll` call site
**File:** `lib/features/session/session_controller.dart` (line 266)
**Description:** The `sendToAll` call at line 266 correctly checks `!isSimulation` before calling. However, the `sendToAll` method on the REAL `MessagingService` does NOT receive `isSimulation: true` even in simulation mode. The guard relies solely on the `if (config.sendSmsToContacts && !isSimulation)` check at line 262. If that conditional is ever refactored, real SMS could be sent during simulation.

**Severity:** CRITICAL (defense-in-depth failure)
**Fix:** Always pass `isSimulation: isSimulation` to `sendToAll()`, and/or inject the simulation service when in simulation mode.

---

## HIGH

### H1. PIN hash stored alongside duress PIN hash in plaintext JSON -- no separation of concerns
**File:** `lib/domain/models/app_settings.dart` (lines 89-99)
**Description:** `appPinHash`, `duressPinHash`, and `sessionEndPinHash` are stored as fields in the same `AppSettings` JSON document. While they are SHA-256 hashed (with salt), they all reside in the same Hive box. An attacker who gains access to the encrypted Hive storage and the encryption key from `FlutterSecureStorage` gets all three hashes simultaneously. The PIN hashing uses single-round SHA-256, NOT a KDF like PBKDF2/Argon2. For 4-6 digit PINs (10^4 to 10^6 combinations), this is brute-forceable in milliseconds on modern hardware.

**Severity:** HIGH
**Fix:** Use PBKDF2 or Argon2 with a high iteration count. Single SHA-256 is explicitly acknowledged in the doc comment of `pin_utils.dart` but the threat model claim ("physical attacker, not offline brute-forcer") is incorrect -- an attacker with the Hive key IS an offline brute-forcer.

### H2. `_constantTimeEquals` leaks length information
**File:** `lib/core/utils/pin_utils.dart` (line 49)
**Description:** The `_constantTimeEquals` method returns `false` immediately if lengths differ (line 49). Since the hash format is `"$salt:$hexDigest"` and both candidate and stored hash use the same salt, the lengths will always match for valid PINs. However, for malformed input, the early return is a theoretical timing oracle.

**Severity:** HIGH (marginal in practice but violates the stated security goal of "constant-time comparison")
**Fix:** Pad the shorter string or always iterate over the max length.

### H3. `WalkSession.copyWith` cannot clear `currentStepType` to null
**File:** `lib/features/session/walk_session.dart` (lines 96-116)
**Description:** `copyWith(currentStepType: null)` keeps the old value because of the `?? this.currentStepType` pattern. When the engine transitions to `EngineEnded`, `currentStep` is null, but `_onEvent` in `session_controller.dart` (line 334) passes `_engine!.currentStep?.type` which IS null -- but copyWith silently preserves the old value. The UI may show a stale step type after session ends.

**Severity:** HIGH
**Fix:** Add a `clearCurrentStepType` boolean parameter (like the pattern in `AppSettings.copyWith`), or use a sentinel value.

### H4. Hardcoded strings in `session_lock.dart`, `distress_confirmation.dart`, `emergency_call_confirmation.dart`, `pin_entry_dialog.dart`
**Files:** `lib/core/utils/session_lock.dart`, `lib/core/widgets/distress_confirmation.dart`, `lib/core/widgets/emergency_call_confirmation.dart`, `lib/core/widgets/pin_entry_dialog.dart`
**Description:** These core widgets use hardcoded English strings instead of `AppLocalizations`. The strings include 'Session Active', 'Distress Activated', 'Cancel Emergency Call?', 'Enter PIN', etc. These are user-facing in critical safety moments. The l10n keys actually exist in the ARB files (`enterPin`, `enterPasscode`, `sessionActive`) but are not used.

**Severity:** HIGH
**Fix:** Thread `BuildContext` or `AppLocalizations` through and use the existing l10n keys.

### H5. `SessionMode.checkInType` crashes on empty `chainSteps`
**File:** `lib/domain/models/session_mode.dart` (line 62)
**Description:** `chainSteps.first` throws `StateError` if `chainSteps` is empty. While the validator checks for empty chains before session start, code calling `checkInType` (like `_modeLabel` in `home_screen.dart` line 171) can be reached before validation.

**Severity:** HIGH
**Fix:** Make `checkInType` return `ChainStepType?` or guard with `chainSteps.isNotEmpty`.

---

## MEDIUM

### M1. 67+ hardcoded English strings marked `// TODO: l10n` across UI screens
**Files:** `session_screen.dart`, `session_completed_screen.dart`, `fake_call_screen.dart`, `hold_button.dart`, `im_safe_slider.dart`, `home_screen.dart`, `chain_summary.dart`, `onboarding_screen.dart`
**Description:** Approximately 67 occurrences of `// TODO: l10n` comments with hardcoded English text. The app claims 14-language support but many screens bypass localization entirely.

**Severity:** MEDIUM
**Fix:** Replace all hardcoded strings with `AppLocalizations.of(context)!.xxx` calls.

### M2. `_TopBar` in `session_screen.dart` leaks a `Stream` -- no disposal
**File:** `lib/features/session/session_screen.dart` (line 307)
**Description:** `_TopBarState` creates `_ticker = Stream<void>.periodic(...)` but never cancels the underlying timer. `Stream.periodic` creates a new `Timer.periodic` internally. Since `_TopBar` is a `StatefulWidget`, each rebuild of the session screen creates a new ticker without cancelling the old one. The `StreamBuilder` will stop listening when unmounted, but the `Timer.periodic` backing the stream continues firing.

**Severity:** MEDIUM
**Fix:** Use a `Timer.periodic` directly and cancel in `dispose()`, or use a `StreamController` that is properly disposed.

### M3. `ContactsController._loadFromRepo()` fire-and-forget async in synchronous `build()`
**Files:** `lib/features/contacts/contacts_controller.dart`, `lib/features/modes/modes_controller.dart`, `lib/features/profile/profile_controller.dart`, `lib/features/settings/settings_controller.dart`, `lib/features/templates/templates_controller.dart`, `lib/features/history/history_controller.dart`, `lib/features/settings/battery_alert_controller.dart`
**Description:** All 7 controllers call `_loadFromRepo()` in their synchronous `build()` method. The async load runs as a fire-and-forget `Future` that calls `state = ...` when it completes. If the future completes after the provider is disposed (e.g., during hot restart or test teardown), this will throw. Additionally, listeners see the seed/default data first, then jump to the real data, causing a flash of incorrect content.

**Severity:** MEDIUM
**Fix:** Use `AsyncNotifier` or handle the async load with proper lifecycle management. At minimum, wrap the `state = ...` assignment in a check for whether the notifier is still alive.

### M4. `ModeEditorScreen._addStep` directly mutates the `steps` list parameter
**File:** `lib/features/modes/mode_editor_screen.dart` (line 93)
**Description:** `_addStep(List<ChainStep> steps)` calls `steps.add(step)` inside `setState`. Since `_chainSteps` and `_distressSteps` are `List<ChainStep>` fields (not `final`), this works but relies on direct mutation inside `setState`, which is fragile and does not follow immutable state patterns.

**Severity:** MEDIUM
**Fix:** Use immutable list patterns: `setState(() => _chainSteps = [..._chainSteps, step])`.

### M5. `SmsContactStrategy.executeReal` computes resolved message but discards it
**File:** `lib/domain/orchestration/strategies/sms_contact_strategy.dart` (line 39)
**Description:** `final _ = context.resolvePlaceholders(template);` explicitly discards the resolved message. The strategy is a placeholder, but this is confusing dead code that suggests incomplete implementation.

**Severity:** MEDIUM
**Fix:** Either use the resolved message or remove the line entirely.

### M6. `_TopBar._fmt` only shows minutes:seconds -- sessions over 59 minutes show wrong time
**File:** `lib/features/session/session_screen.dart` (lines 342-347)
**Description:** `_fmt(Duration d)` uses `d.inMinutes.remainder(60)` and `d.inSeconds.remainder(60)`. For sessions longer than 59 minutes, the display wraps around (e.g., 1h15m shows as "15:00"). Hours are not displayed.

**Severity:** MEDIUM
**Fix:** Add hours display for sessions over 59 minutes.

### M7. `DistressChainScreen` uses `_steps ??=` with mutable list -- stale on mode change
**File:** `lib/features/settings/distress_chain_screen.dart` (line 50)
**Description:** `_steps ??= List<ChainStep>.of(mode.distressChainSteps ?? [])` initializes once and never updates if the underlying mode changes (e.g., via another screen). Since this is a `ConsumerStatefulWidget` that watches `modesControllerProvider`, the mode can change, but `_steps` retains its first-assigned value.

**Severity:** MEDIUM
**Fix:** Use `didUpdateWidget` or recalculate when the mode ID changes.

### M8. `restartCurrentStep()` increments `_missCount` before checking retry limit
**File:** `lib/domain/engine/session_engine.dart` (line 255)
**Description:** `restartCurrentStep()` does `_missCount++` then checks `if (_missCount > step.retryCount)`. But `_onGraceExpired()` also does `_missCount++` and the same check. If both code paths are reachable for the same step, the miss count may be double-incremented. In practice, `restartCurrentStep()` is only called from `declineFakeCall()` when `declineIsSafe=false`, but the naming suggests it could be called more broadly.

**Severity:** MEDIUM
**Fix:** Document that `restartCurrentStep()` is specifically for fake-call decline retry, not a general-purpose replay. Consider extracting a shared `_handleMiss()` method.

### M9. `HoldButton` fires both `onTapDown` and `onLongPressStart` for the same gesture
**File:** `lib/features/session/widgets/hold_button.dart` (lines 51-56)
**Description:** `GestureDetector` has both `onTapDown` and `onLongPressStart` callbacks that call `onDown()`. For a long press, both `onTapDown` and `onLongPressStart` fire, calling `holdStart()` twice. The engine's `holdStart()` is edge-triggered (no-op if `_isHolding`), so this is safe, but it creates unnecessary double-calls.

**Severity:** MEDIUM (cosmetic, functionally safe)
**Fix:** Use only `onLongPressStart`/`onLongPressEnd` or use a `RawGestureDetector` to avoid double-firing.

### M10. `EventDefaults.fromJson` casts without null checks -- crashes on partial JSON
**File:** `lib/domain/models/event_defaults.dart` (lines 61-89)
**Description:** `fromJson` casts each field as `Map<String, dynamic>` without null checks. If the JSON is missing any of the 9 step-type keys (e.g., a backup from an older version), it throws `TypeError`. Other `fromJson` methods in the codebase use `?? defaultValue` fallbacks.

**Severity:** MEDIUM
**Fix:** Add null-safe fallbacks: `j['holdButton'] != null ? StepConfig.fromJson(...) : const HoldButtonConfig()`.

---

## LOW

### L1. Sub-chain terminology remnants in comments (not in code)
**Files:** `engine_state.dart:7`, `trigger_manager.dart:7`, `walk_session.dart:7,120`, `session_controller.dart:8`
**Description:** Comments like "No `EngineSubChainActive`", "instead of `engine.startSubChain()`" reference old v1 concepts. These are informational comments, not functional code.

**Severity:** LOW
**Fix:** Clean up changelog-style comments in doc blocks. They add noise for future readers who never saw v1.

### L2. `QuickExit` calls `exit(0)` on iOS -- app will be rejected by Apple
**File:** `lib/core/utils/quick_exit.dart` (line 73)
**Description:** `exit(0)` terminates the process. Apple rejects apps that call `exit()` as it violates iOS Human Interface Guidelines. The decoy screen approach is correct, but the hard exit is problematic.

**Severity:** LOW (pre-release; would be HIGH at App Store submission)
**Fix:** On iOS, rely solely on the decoy screen + app lifecycle to background the app naturally, or use `SystemNavigator.pop()`.

### L3. `step_config_form.dart` dialog title is not `const` and not localized
**File:** `lib/features/modes/widgets/step_config_form.dart` (line 51)
**Description:** `Text('Configure Step')` -- non-const string, not localized.

**Severity:** LOW
**Fix:** Use l10n.

### L4. `BatteryAlertController` recreates full `BatteryAlertConfig` on each toggle
**File:** `lib/features/settings/battery_alert_controller.dart`
**Description:** `toggleEnabled()`, `setThreshold()`, `toggleSendSms()` all create new `BatteryAlertConfig` objects manually copying fields. `BatteryAlertConfig` lacks a `copyWith` method unlike every other model.

**Severity:** LOW
**Fix:** Add `copyWith` to `BatteryAlertConfig`.

### L5. `ChainStep` is not immutable -- has no `const` constructor or `final` enforcement
**File:** `lib/domain/models/chain_step.dart` (line 44)
**Description:** `ChainStep` constructor is not `const` (cannot be, since fields are not all final -- they ARE final, but the constructor uses `required` without `const`). Actually all fields ARE final, so this CAN be `const` if desired. Not a bug, but inconsistent with the pattern of `const` constructors on other models.

**Severity:** LOW

### L6. `_ModeItem` in `home_screen.dart` is not documented
**File:** `lib/features/home/home_screen.dart` (line 214)
**Description:** Private data class `_ModeItem` lacks doc comments. Minor, but all public APIs should have docs per CLAUDE.md.

**Severity:** LOW

### L7. `HistoryController.getById` uses linear scan instead of map lookup
**File:** `lib/features/history/history_controller.dart` (lines 38-42)
**Description:** Linear scan through all logs for each lookup. With many sessions, this could be slow.

**Severity:** LOW
**Fix:** Build a `Map<String, SessionLog>` index, or use `.firstWhere` with `orElse`.

### L8. About screen has hardcoded version "1.0.0"
**File:** `lib/features/settings/about_screen.dart` (lines 51, 115)
**Description:** Version string is hardcoded rather than read from `pubspec.yaml` via `PackageInfo`.

**Severity:** LOW
**Fix:** Use `package_info_plus` to read the version at runtime.

### L9. `ImSafeSlider` default label "I'm Safe" is hardcoded English
**File:** `lib/features/session/widgets/im_safe_slider.dart` (line 15)
**Description:** Default parameter `this.label = "I'm Safe"` is not localized. The `// TODO: l10n` comment is present.

**Severity:** LOW (covered by M1 but worth noting as a default parameter)

### L10. `simulation_description_toast.dart` uses non-const `Icon`
**File:** `lib/features/session/widgets/simulation_description_toast.dart` (line 24)
**Description:** `Icon(Icons.info_outline, ...)` is not `const` because it has runtime color/size parameters. Minor widget optimization opportunity.

**Severity:** LOW

---

## Summary

| Severity | Count |
|----------|-------|
| CRITICAL | 2     |
| HIGH     | 5     |
| MEDIUM   | 10    |
| LOW      | 10    |

### Positive Observations

1. **No sub-chain code remnants** -- Only comment references remain (informational). No functional `SubChainType`, `EngineSubChainActive`, `startSubChain`, `_subChainSteps`, or `_effectiveSteps` code exists.
2. **No `print()` calls** -- All logging uses `dart:developer` `log()`. No `print()` found anywhere in `lib/`.
3. **No `.withOpacity()` calls** -- All opacity uses the modern `.withValues(alpha: ...)` API.
4. **Router is complete** -- All 26 routes map to real screens with no placeholders.
5. **PIN security is well-designed** -- Salt + SHA-256 with constant-time comparison (except the length leak noted in H2). Duress PIN triggers distress chain. Wrong PIN threshold triggers distress chain.
6. **Sealed class hierarchies** are used correctly for `EngineState`, `StepConfig`, `DistressTrigger`, `DisarmTrigger`, `HardwareTrigger`.
7. **Simulation services exist** (`SimulationMessagingService`, `SimulationPhoneService`) with structural guarantees (no telephony imports). They just are not wired in.
8. **Session engine is pure Dart** with no Flutter dependencies, injectable `Random` for testing, and proper timer lifecycle management.
9. **JSON serialization** uses explicit type discriminators (`typeName`) instead of `runtimeType.toString()`, surviving Dart obfuscation.
10. **All providers are properly typed** with explicit type parameters on `Provider`, `NotifierProvider`, etc.
11. **Theme usage is consistent** -- screens use `Theme.of(context)` and `colorScheme` throughout. No hardcoded colors outside `AppColors`.
12. **Hive encryption** is properly implemented with AES-256 via `FlutterSecureStorage` key management.
