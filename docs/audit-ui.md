# UI Audit Report — Guardian Angela

Audit date: 2026-03-31
Compared: `docs/spec/04-screens-navigation.md`, `docs/spec/06-settings.md`, `docs/issues-v4.md` against all `lib/features/` code.

---

## A. Screens That Don't Match Spec

### A1. Settings Screen — Missing Stealth Mode Toggle
**Spec** (04-screens, 06-settings): Settings should show a Stealth Mode ON/OFF toggle with a collapsible notification disguise text field underneath.
**Actual** (`lib/features/settings/settings_screen.dart`): No stealth mode toggle present. The `AppSettings` model has `stealthMode` and `notificationDisguise` fields (lines 26-29), and `SettingsController` exists, but the toggle is not rendered on the Settings screen.
**Impact**: High — stealth mode is a core safety feature per spec.

### A2. Settings Screen — Missing Reminder Templates Link
**Spec** (04-screens): Settings should link to Reminder Templates.
**Actual**: Settings screen links to Profile, Event Defaults, and Modes only. Reminder Templates is only reachable from Event Defaults > Disguised Reminder detail. The spec's navigation map shows `SETTINGS -> TEMPLATES`.

### A3. Chain Exhausted Screen — No Warm Message
**Spec** (04-screens): Should say "Session Completed" with a checkmark.
**Issues-v4 / user sessions**: Should display a warm message like "Hope you're safe home" or similar.
**Actual** (`lib/features/session/chain_exhausted_screen.dart`): Shows `l10n.sessionCompleted` and duration. No warm/empathetic message.
**Suggestion**: Add a localized warm subtitle, e.g., "We hope you got home safely."

### A4. Chain Exhausted Screen — No Stealth Mode Behavior
**Spec** (04-screens): "Stealth mode: This screen is NOT shown. App silently exits to home screen."
**Actual** (`lib/features/session/session_screen.dart:122-136`): The chain exhausted navigation always goes to `ChainExhaustedScreen`, with no check for stealth mode. Should `context.go(RouteNames.home)` when stealth is enabled.

### A5. Session Screen — Missing Stealth Mode Effects
**Spec** (06-settings): When stealth ON:
- Session progress bar: Hidden
- Missed check-in indicator: Hidden
**Actual**: `PrideProgressBar` is always shown. No conditional on stealth mode.

### A6. Session Screen — Missing "Missed: N" Counter (Date Mode)
**Spec** (04-screens): Date mode passive view should show `[Missed: 1]` (if not stealth).
**Actual** (`_PassiveBody`): Shows shield icon + "Session Active" + hint text. No missed check-in counter.

### A7. Onboarding Page Order Mismatch
**Spec**: Page 2 = Your Name, Page 3 = How It Works, Page 4 = Profile Details.
**Actual** (`onboarding_screen.dart:229-269`): Page order matches spec but the comment on line 574 says "Page 3: Your Name (mandatory)" which is wrong — it's page 2 in the array, and it's optional per the `_canAdvance()` method.

### A8. Event Defaults Screen — Lists 9 Types
**Spec** (04-screens): "List of 9 event types."
**Actual**: Uses `ChainStepType.values.length` which is 9. This matches.

### A9. Simulation Summary Screen — Not in Router
**Spec** (04-screens nav map): `SESSION -> SIMSUMMARY`.
**Actual**: `SimulationSummaryScreen` is navigated to via `Navigator.of(context).pushReplacement(MaterialPageRoute(...))` rather than GoRouter, meaning it has no route path. It works but bypasses the router.

---

## B. Missing UI Features from User Sessions / Issues-v4

### B1. Stealth Mode Toggle — NOT IMPLEMENTED in UI
The `AppSettings` model supports it, but the Settings screen does not render it. **Priority: High.**

### B2. Slider Bars — Do Display Values
**Status: IMPLEMENTED.** The `_sliderField` in `event_default_detail_screen.dart:434-453` shows `format(value)` in a `SizedBox(width: 56)` next to each slider. The `_logSliderField` does NOT show the formatted value next to the slider (lines 456-476) — it only shows the slider. Logarithmic sliders (used for record duration, long press duration) are missing the value display.

### B3. Settings Autosave — MIXED
- **Settings screen** (theme, language): Autosave via `onChanged` callbacks. No save button. CORRECT.
- **Fake Call Settings screen**: Autosave via `onChanged`. CORRECT.
- **Profile Editor screen**: Has explicit Save button (`FilledButton.icon` with `Icons.save`). Per spec, profile is a form with required fields so a save button is appropriate.
- **Mode Editor screen**: Has explicit Save button. Appropriate for complex multi-field form.
- **Event Default Detail screen**: Has explicit Save button. Could be autosave but form complexity justifies save button.
- **Contact Form screen**: Has explicit Save button. Appropriate.
- **Template Editor screen**: Has explicit Save button. Appropriate.
**Verdict**: Autosave is correctly used for simple toggles/pickers. Save buttons are used for complex forms. This is acceptable.

### B4. Background Notification Banner (Foreground Service Notification)
**Spec** (06-settings): Foreground notification with disguised text when stealth is on, "I'm Safe" / "Pause" action button.
**Actual**: No foreground notification implementation found in any screen or service. This is a platform service concern (Android foreground service) rather than a UI screen, but the notification's appearance is unimplemented.

### B5. Mode Icons — Consistent Everywhere (Issue #12)
**Status: PARTIALLY IMPLEMENTED.**
- Home screen (`_modeIcon`): Falls back to `checkInType` if `iconName` is null. Uses `modeIconOptions` map.
- Modes screen (`_ModeTile`): Uses `modeIconOptions` but falls back to `Icons.tune` (not matching home screen fallback).
- Past Events screen (`_modeIcon`): Uses step-type heuristic + name-based heuristic. Does NOT use `SessionLog.iconName` (which doesn't exist on the model).
**Issue**: Fallback icons differ between screens. Home uses `directions_walk`/`local_cafe`/`shield`, Modes uses `tune`, Past Events uses name heuristic.

### B6. Preview Button Per Step in Mode Editor (Issue #10)
**Status: IMPLEMENTED** in `escalation_step_list.dart`. Each expanded step has a Preview button that shows simulation-styled previews.

### B7. Hardware Trigger as Top Option in Mode Creation (Issue #8)
**Status: IMPLEMENTED.** `_showCheckInChoiceDialog` in `mode_editor_screen.dart:62-147` shows Hold Button, Disguised Reminder, Hardware Trigger as the 3 prominent options, with "More..." for the rest.

### B8. Hardware Button Settings in Mode Editor (Issue #9)
Would need to verify in `escalation_step_list.dart` expanded config for `hardwareButton` type. The `_hardwareButtonFields` exists in `event_default_detail_screen.dart` with button type, press pattern, press count, long press duration — but need to confirm it's also in the inline step editor.

### B9. Randomize Toggle on User-Facing Durations (Issue #11)
**Spec**: Add randomize toggle to repetition interval and fake call ring duration. NOT on SMS duration, alarm, emergency confirm.
**Status**: Need to verify in `escalation_step_list.dart` inline config. The `event_default_detail_screen.dart` has randomize toggles for disguised reminder (`randomizeInterval`, `randomizeTemplateOrder`). Not visible on fake call ring duration slider.

### B10. Real Previews for Hold Button + Fake Call (Issue #13)
**Status: IMPLEMENTED.** `event_default_detail_screen.dart`:
- Hold button preview shows actual hold button UI in simulation border (line 621-660).
- Fake call preview navigates to actual `FakeCallScreen` (line 718).

### B11. Log Tabs: Real + Simulated (Issue #15)
**Status: IMPLEMENTED.** `past_events_screen.dart` has `DefaultTabController(length: 2)` with "Real" and "Simulated" tabs.

### B12. Single-Step Chain Deletion (Issue #7)
Would need to check `ChainStepList.onRemove` behavior — whether it allows removing the last step.

### B13. Hold Button Grace Period Default = 0 (Issue #16)
Would need to check `seed_data.dart`. The `_applyCheckInChoice` in `mode_editor_screen.dart:152` still sets `gracePeriodSeconds: 10` for `holdButton`, not 0.

---

## C. Hardcoded Strings That Should Be Localized

### C1. Simulation Border
- `lib/features/session/widgets/simulation_border.dart:57` — `'SIMULATION'` hardcoded
- `lib/features/session/widgets/simulation_border.dart:76` — `'Skip'` hardcoded

### C2. Disguised Reminder Overlay
- `lib/features/session/widgets/disguised_reminder_overlay.dart:79,147,159` — `'now'` hardcoded
- `lib/features/session/widgets/disguised_reminder_overlay.dart:378` — `'Swipe to dismiss'` hardcoded
- `lib/features/session/widgets/disguised_reminder_overlay.dart:402` — `'Tap to dismiss'` hardcoded

### C3. Reminder Templates Screen
- `lib/features/templates/reminder_templates_screen.dart:159` — `'now'` hardcoded
- `lib/features/templates/reminder_templates_screen.dart:238-241` — `'Tap button'`, `'Tap word'`, `'Swipe'`, `'Tap to dismiss'` hardcoded

### C4. Event Default Detail Screen — Preview Dialogs
- Line 614: `'Hardware Button Preview'`
- Line 615: `'Hardware button panic trigger...'`
- Line 642: `'Sensitivity: ...'` / `'Style: ...'`
- Line 668: `'No Templates'`
- Line 739-740: `'Last known location...'`, `'Time: ...'`
- Line 744: `'No emergency contacts configured'`
- Line 758, 867, 1019: `'SIMULATION'`
- Line 769: `'Message that would be sent:'`
- Line 779: `'Recipients:'`
- Line 791: `'This is a simulation - no message will be sent.'`
- Line 812-814: `'WhatsApp'`, `'Telegram'`, `'Phone'`
- Line 819: `'Phone Call Preview'`
- Line 820: `'Would call ...'`
- Line 846: `'Emergency Call Preview'`
- Line 930: `'Are you safe?'`
- Line 960: `"I'm OK"`
- Line 964: `'Tap the button to cancel the countdown'`
- Line 1022: `'Loud Alarm'`
- Line 1032: `'Playing alarm...'`
- Line 1036: `'Stop'`

### C5. Escalation Step List — Preview Dialogs + Config Summaries
- Line 472: `'User'`
- Line 481: `'Sent automatically by Guardian Angela.'`
- Line 484: `'Time: ...'`
- Line 490: `'No emergency contacts configured'`
- Line 538-540: `'WhatsApp'`, `'Telegram'`, `'Phone'`
- Line 546-547: `'Phone Call Preview'`, `'Would call ...'`
- Line 573, 577: `'Emergency Call Preview'`, `'Emergency services would be called...'`
- Line 607: `'SIMULATION'`
- Line 715: `'Tap the button to cancel the countdown'`
- Line 764: `'Loud Alarm'`
- Line 773: `'Playing alarm...'`
- Line 1242: `'Android'`
- Line 1832-1834: `'Large button'`, `'Full screen'`, `'Discrete button'`
- Line 1843: `'Every $interval, $count repeats, $grace grace'`
- Line 1849-1863: Various step summary strings

### C6. Simulation Summary Screen
- Line 130: `'Unknown'`
- Line 136: `'Hardware panic trigger'`
- Step description strings (lines 125-136): `'grace period'`, `'repeats'`, `'interval'`, `'countdown'`, `'ring'`, `'Send SMS'`, `'Call'`

### C7. Session Controller
- Lines 232-261: Event description strings (`'Step started'`, `'Disguised reminder fired'`, `'Advancing to next step'`, etc.)
- Lines 253-261: Step type names (`'Hold button'`, `'Disguised reminder'`, etc.)

### C8. Fake Call Screen
- Line 176-178: `'WhatsApp Audio Call'`, `'Telegram'`, `'Signal'`

### C9. Past Events Screen
- `_formatRelativeTime` method (lines 278-285): `'y ago'`, `'mo ago'`, `'d ago'`, `'h ago'`, `'m ago'`, `'just now'` — all hardcoded English.

### C10. Event Strategy Implementations
- `sms_contact_strategy.dart:10` — `'Location unavailable'`
- `sms_contact_strategy.dart:29-30` — `'Last known location: ...'`, `'Time: ...'`
- `sms_contact_strategy.dart:41` — `'Would send to N contacts'`
- `phone_call_contact_strategy.dart:50` — `'Would call ...'`
- `call_emergency_strategy.dart:21` — `'Emergency'`
- `call_emergency_strategy.dart:38` — `'Would call ...'`
- `hardware_button_strategy.dart:20` — `'Panic button detected'`
- `loud_alarm_strategy.dart:13` — `'Would play loud alarm'`
- `countdown_warning_strategy.dart:12` — `'Countdown warning'`

### C11. Mode Editor Screen
- Line 200: `'Mode not found'`

### C12. Template Editor Screen
- Lines 104, 107, 108: `'Notification'`, `'Title'`, `'Body'` (preview placeholders)

### C13. Contact Form Screen
- Lines 247-249: `'WhatsApp'`, `'Telegram'`, `'Phone Call'` (channel names in test message dialog)

**Total hardcoded string count: ~100+ instances across 15+ files.**

---

## D. UI Inconsistencies

### D1. Button Styles — Save vs Autosave
- Settings screen: autosave (correct)
- Profile editor: `FilledButton.icon` with save icon
- Mode editor: `FilledButton.icon` with save icon
- Event default detail: `FilledButton.icon` with save icon + `OutlinedButton.icon` for preview
- Template editor: `FilledButton.icon` with save icon
- Contact form: `FilledButton` (no icon) + `OutlinedButton` cancel
- Escalation settings: `IconButton` save in AppBar (inconsistent with other forms)
**Issue**: Escalation settings uses an AppBar icon button for save while all other forms use an inline `FilledButton.icon`. However, escalation settings is a legacy screen accessible only via `/settings/escalation` route.

### D2. Padding Consistency
- Home screen: `EdgeInsets.symmetric(horizontal: 16)` — consistent
- Session screen bodies: `EdgeInsets.all(16)` — consistent
- Settings screen: `EdgeInsets.symmetric(horizontal: 16)` — consistent
- Contact form: `EdgeInsets.all(16)` — consistent
- Mode editor: `EdgeInsets.symmetric(horizontal: 16, vertical: 8)` — consistent
- Event default detail: `EdgeInsets.all(16)` — consistent
**Verdict**: Mostly consistent 16px padding. Minor variations (vertical: 8 in some places) are acceptable.

### D3. Divider Styling (Issue #2)
**Spec/Issues**: Should use only one divider type.
**Actual**: `PrideDivider()` is used as the sole divider in settings screen, mode editor, event defaults list. The old grey+white double divider issue appears to be fixed — only `PrideDivider` is used now. However, `escalation_step_list.dart` uses `const Divider(height: 1)` in some places (within expanded step configs), which is fine for internal section separation.

### D4. Info Tooltips
**Status: IMPLEMENTED** on most non-obvious options in `event_default_detail_screen.dart` and `escalation_step_list.dart` via `_infoLabel` and `_infoSwitch` helper widgets. The tooltips match the spec's info tooltip table:
- Randomize: present
- Release sensitivity: present
- Include location: present
- Auto-record: present
- Pre-send SMS: present
- Can disarm: present
- Flash light: present
- Show confirmation: present
- Stealth mode: NOT present (stealth toggle doesn't exist in UI yet)

---

## E. Dead Routes / Unreachable Screens

### E1. `/settings/fake-call` (FakeCallSettingsScreen)
**Route**: `RouteNames.fakeCallSettings = '/settings/fake-call'`
**Problem**: Fake Call Settings was moved to Event Defaults > Fake Call detail per spec ("Removed from settings: Fake Call Settings accessible in Events"). No navigation link points to `/settings/fake-call` from any screen.
**Verdict**: Dead route. The screen still exists and is registered in the router but is unreachable through normal navigation.

### E2. `/settings/escalation` (EscalationSettingsScreen)
**Route**: `RouteNames.escalationSettings = '/settings/escalation'`
**Problem**: Per spec, "Removed from settings: Escalation Chain (accessible in Modes)." No navigation link points to this route.
**Verdict**: Dead route. The screen duplicates functionality now in Mode Editor.

### E3. SimulationSummaryScreen — No Route
Not registered in the router at all. Navigated via `Navigator.of(context).pushReplacement`. Works but is outside the GoRouter graph.

---

## F. Summary of Priority Issues

| # | Issue | Severity | Section |
|---|-------|----------|---------|
| 1 | Stealth mode toggle missing from Settings UI | HIGH | A1, B1 |
| 2 | Stealth mode effects missing from Session screen | HIGH | A4, A5 |
| 3 | ~100+ hardcoded English strings in UI code | MEDIUM | C1-C13 |
| 4 | No warm message on chain exhausted screen | LOW | A3 |
| 5 | Missing "Missed: N" counter in date mode | LOW | A6 |
| 6 | Inconsistent mode icon fallbacks across screens | LOW | B5 |
| 7 | Dead routes: `/settings/fake-call`, `/settings/escalation` | LOW | E1, E2 |
| 8 | Logarithmic sliders don't show current value | LOW | B2 |
| 9 | Reminder Templates not linked from Settings | LOW | A2 |
| 10 | Hold button default grace period still 10 in mode_editor | LOW | B13 |
| 11 | Foreground service notification not implemented | MEDIUM | B4 |

---

## G. Questions for the User

1. **Stealth mode**: Should implementing the stealth mode UI toggle + session screen effects be the top priority?
2. **Hardcoded strings**: There are ~100+ hardcoded English strings. Should we create a batch task to localize all of them, or prioritize user-facing strings over simulation/preview strings?
3. **Dead routes**: Should we remove `FakeCallSettingsScreen` and `EscalationSettingsScreen` entirely, or keep them as alternative entry points?
4. **Chain exhausted warm message**: What text should be shown? "We hope you got home safely" / "Hope you're safe" / something else?
5. **Foreground service notification**: This requires platform-specific implementation (Android foreground service). Is this in scope for the current phase?
