> **Status:** DEFERRED — these enhancements are specified here for future
> implementation. They are NOT part of the current release scope. Each
> section is self-contained and can be implemented independently.

# 11 — Deferred Enhancements

---

## DE-1: Timer Sliders — Minimum Zero, Extended Range, Logarithmic Scale

### Problem

Current timing sliders (wait, duration, grace) have arbitrary minimums
and fixed linear ranges that don't cover real-world needs well. Users
can't set a grace period to 0 seconds, and can't easily set a reminder
interval to 4 hours.

### Specification

**Minimum value:** All timing fields (waitSeconds, durationSeconds,
gracePeriodSeconds) MUST allow 0. A 0-second phase means it fires
immediately / is skipped.

**Maximum value:** 1 year (31 536 000 seconds). The slider range does
not need to reach this — direct numeric entry covers it.

**Slider behavior — logarithmic snap stops:**

The slider uses a logarithmic-like scale with human-friendly snap stops.
Dragging the slider snaps to the nearest value from the stop list:

```
Seconds:  0, 1, 2, 3, 5, 10, 15, 20, 30, 45
Minutes:  1, 2, 3, 5, 10, 15, 20, 30, 45
Hours:    1, 2, 3, 4, 6, 8, 12, 18, 24
Days:     1, 2, 3, 5, 7, 14, 30, 60, 90, 180, 365
```

The label displays human-readable text:
- 0 → "0s (immediate)"
- 1–59s → "Ns"
- 60–3599s → "Nm" or "Nm Ns"
- 3600–86399s → "Nh" or "Nh Nm"
- 86400+ → "Nd" or "Nd Nh"

**Direct numeric entry:** Every timing slider has an edit icon (or tap
on the value label) that opens a text field where the user can type any
integer value in seconds. Validation: 0 ≤ value ≤ 31 536 000.

**Affected UI locations:**
- Mode editor: ChainStep timing fields (wait, duration, grace)
- Event defaults editor: per-type default timing fields
- Settings: any timing configuration (e.g., alarm ramp duration)
- Distress Chain editor (`/distress-chains/edit`)

**Implementation notes:**
- Use the existing `LogarithmicSlider` widget in `lib/core/widgets/`
  as a starting point, extend with snap stops and direct entry.
- All timing fields in the model already accept 0. The change is
  purely UI — remove minimum constraints from sliders.

---

## DE-2: Per-Event GPS Logging with Global Default

### Problem

GPS logging is currently configured globally via `GpsLoggingConfig`
in `AppDefaults` (or overridden per-mode in `ModeOverrides.gpsLogging`).
Users may want GPS on escalation steps (SMS, call) but not on check-in
steps (holdButton, disguisedReminder) to save battery.

### Specification

**Per-event GPS override:**

Every `ChainStep` gains a config key `logGps` with three possible
values:
- `"default"` — use the global default (initial value for all steps)
- `"true"` — always log GPS when this step fires
- `"false"` — never log GPS for this step

```dart
// In ChainStep.config:
'logGps': 'default'  // or 'true' or 'false'
```

**Global default toggle:**

`AppDefaults.gpsLogging.enabled` (the `GpsLoggingConfig.enabled` field)
serves as the fallback when a step's `logGps` is `"default"` or absent.

The global GPS config lives in Settings → Defaults → GPS Logging.

**EventDefaults integration:**

Each step type in `EventDefaults` gains a `logGps` key (default
`"default"`) so that users can set per-type defaults (e.g., "always
log GPS for smsContact, never for holdButton").

Resolution order:
1. ChainStep.config['logGps'] (per-instance)
2. EventDefaults.forType(stepType)['logGps'] (per-type default)
3. AppDefaults.gpsLogging.enabled (global default via GpsLoggingConfig)

**UI: "More Settings" collapsible section:**

In the mode editor (chain step edit dialog) and in the event defaults
detail screen, add a collapsible "More settings" section at the bottom
of each step's config panel. This section contains non-common settings:
- GPS logging: tri-state selector (Default / On / Off)
- Future: other per-step overrides

When set to "Default", show the effective resolved value in muted text
(e.g., "Default (On)" or "Default (Off)").

---

## DE-3: Session Tracking — Interval-Based GPS Recording

### Problem

Current GPS logging is event-driven (only captured when a chain step
fires). For long sessions (e.g., Date Mode with 30-min reminder
intervals), there can be 30+ minute gaps with no location data. If
the user needs help, "last known location" may be stale.

### Specification

**Tracking section in session modes:**

Each `SessionMode` gains an optional tracking configuration:

```dart
// New fields in SessionMode (or in a separate TrackingConfig model):
bool trackingEnabled;           // default false
int trackingIntervalSeconds;    // default 300 (5 min)
bool trackingOnlyDuringSession; // default true
```

**Behavior when enabled:**
- During an active session, the app records GPS coordinates at
  `trackingIntervalSeconds` intervals.
- Recordings are stored in a local buffer (not in SessionLog events
  to avoid clutter — separate `TrackingPoint` list).
- The buffer holds the last N points (configurable, default 50).
- When an SMS or call step fires and includes `{location}`, the
  message uses the most recent tracking point (not a fresh GPS fix,
  which may take seconds).
- If tracking is disabled, `{location}` falls back to a fresh
  `Geolocator.getCurrentPosition()` call.

**TrackingPoint model (new):**

```dart
class TrackingPoint {
  final DateTime timestamp;
  final double latitude;
  final double longitude;
  final double? accuracy;    // meters
  final double? altitude;    // meters
  final double? speed;       // m/s
}
```

**Buffer management:**
- Circular buffer, oldest points evicted when capacity reached.
- Buffer cleared when session ends.
- Buffer NOT persisted to Hive (ephemeral, session-lifetime only).
- Buffer accessible to strategies via `EventServices.trackingBuffer`.

**UI: Tracking section in mode editor:**

Below the chain step list in the mode editor, add a "Tracking"
collapsible section:
- Enable/disable toggle
- Interval slider (using DE-1 logarithmic slider, range 10s–1h,
  snap stops: 10s, 30s, 1m, 2m, 5m, 10m, 15m, 30m, 1h)
- Buffer size slider (10–200 points, default 50)
- Note: "Frequent GPS tracking increases battery drain"

**Message template integration:**

The `{location}` placeholder in SMS templates resolves to:
1. Latest tracking point (if tracking enabled and buffer non-empty)
2. Fresh `Geolocator.getCurrentPosition()` (if no tracking or empty)
3. "Location unavailable" (if GPS permission denied or no fix)

Include accuracy info: "Last known location (±15m, 2 min ago): URL"

**Session log integration:**

Optionally export tracking points alongside session events in the
session log detail view. Show a map view (if a mapping library is
added) or a list of timestamped coordinates.

---

## DE-4: "More Settings" Pattern for Step Configuration

### Problem

Step configuration panels in the mode editor and event defaults editor
show all config keys at once. Some are commonly adjusted (timing,
caller name) and some are rarely changed (GPS logging, non-blocking
on failure, custom sound paths). Showing everything creates clutter.

### Specification

**Two-tier config layout:**

Each step's config panel is split into:

1. **Common settings** (always visible):
   - Timing group (wait, duration, grace — using DE-1 sliders)
   - Retry count
   - Type-specific primary settings (e.g., callerName for fakeCall,
     volume for loudAlarm)

2. **More settings** (collapsible, hidden by default):
   - GPS logging override (DE-2)
   - Non-blocking on failure toggle
   - Randomize toggle + per-field randomize overrides
   - Custom sound/recording paths
   - Advanced timing (sensitivity for holdButton)
   - Any future per-step config that doesn't warrant top-level placement

**Visual design:**
- "More settings" uses a `ExpansionTile` or similar collapsible widget.
- Chevron icon indicates expandability.
- When any "more" setting differs from its default, show a badge
  or indicator on the collapsed header (e.g., "More settings (2
  customized)").
- Inside, each setting shows its current value and the effective
  default in muted text when set to "default".

**Applies to:**
- Mode editor: per-step config dialog
- Event defaults: per-type detail screen
- Distress Chain editor (`/distress-chains/edit`)

---

## Summary of Model Changes Required

| Enhancement | Model changes | New models |
|-------------|--------------|------------|
| DE-1 | None (UI only) | None |
| DE-2 | Add `logGps` config key to EventDefaults maps | None |
| DE-3 | Add tracking fields to SessionMode or new TrackingConfig | TrackingPoint (ephemeral) |
| DE-4 | None (UI only) | None |

---

## Implementation Priority (suggested)

1. **DE-1** (slider improvements) — pure UI, no model changes, high UX impact
2. **DE-4** ("More settings" pattern) — UI restructure, enables DE-2
3. **DE-2** (per-event GPS) — requires DE-4 for UI, adds config keys
4. **DE-3** (interval tracking) — most complex, needs new model + service

---

## DE-5: Home Screen Widget — **DONE**

### Status

**Implemented** — Android AppWidget + iOS 17 WidgetExtension with
AppIntent-based interactive buttons. See
`docs/spec/00-overview.md` §11 for the normative description and
`docs/spec/10-platform-matrix.md` → "Home widget interactivity" for
the per-platform capability matrix.

### Shipped scope

- Quick Exit button (PIN-gated via Session End PIN; Duress PIN still
  fires the distress chain).
- Fake Call button (deep-links to `/fake-call` via GoRouter).
- Current session status: `"Idle"`, `"Session active"`,
  `"Simulation active"`, `"Battery alert"` plus an `mm:ss` elapsed
  timer when applicable.

### Implementation summary

- `home_widget` package (0.9.x) bridges Flutter ↔ Android
  AppWidgetProvider ↔ iOS WidgetKit extension.
- Android: `GuardianAngelaAppWidget.kt` extends `HomeWidgetProvider`;
  widget metadata in `android/app/src/main/res/xml/guardian_angela_widget_info.xml`;
  layout in `android/app/src/main/res/layout/guardian_angela_widget.xml`.
- iOS: WidgetKit extension under `ios/GuardianAngelaWidget/`
  (`GuardianAngelaWidget.swift` + `Info.plist` + entitlements). iOS
  17+ uses `AppIntent` for interactive buttons; iOS 16 falls back to
  a deep-link `Link(destination:)`. App Group
  `group.com.guardianangela.app.widget` is declared in both target
  entitlements files.
- Dart: `HomeWidgetService` wrapper
  (`lib/services/implementations/home_widget_service.dart`);
  `SessionController` emits widget updates on every session
  transition; `HomeScreen` registers the interactivity callback and
  observes deep-link URIs and pending action markers.

---

## Voice Recording Assets (14 Languages)

Referenced by `FakeCallConfig.voiceRecordingPath = null` fallback.
Files needed at `assets/voice/angela_<langCode>.m4a` for all 14
supported languages. Current state: the asset manifest is declared
but the M4A files are placeholders / missing. Implementing this task
is pure content production (voice-talent recording + licensing).

---

## Rejected Enhancements

### REJ-1: Shake-to-SOS (Accelerometer-Based Emergency Trigger)

**Rejected.** False positive risk from pocket jostling, accidental device handling, or physical activity outweighs the benefit of an accelerometer-based SOS trigger. Users expect deliberate, intentional escalation mechanisms. This feature will NOT be implemented.
