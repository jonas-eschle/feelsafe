# 11 — Deferred Enhancements

> **Status (2026-05-08).** DE-1, DE-2, DE-3, DE-4 LANDED. DE-5 LANDED
> on Android; iOS interactive widget remains deferred (see iOS gap
> note below).

---

## DE-2: Per-Event GPS Override — LANDED

Per-step `LogGpsOverride` enum (`useDefault` / `forceOn` / `forceOff`)
on every relevant `StepConfig`. The strategy resolves the effective
value against `AppDefaults.gpsLogging.enabled` (with optional
`ModeOverrides.gpsLogging.enabled`). Defined in spec 03.

---

## DE-3: Interval GPS Tracking — LANDED

`SessionMode.trackingEnabled` (default `false`),
`trackingIntervalSeconds` (default `300`), and `trackingBufferSize`
(default `50`). When `trackingEnabled` is true, `LocationService`
samples at the configured interval and stores the last
`trackingBufferSize` points in `SessionLog`. Defined in spec 03.

---

## DE-1: Timer Sliders — Minimum Zero, Extended Range, Logarithmic Scale — DONE

`lib/core/widgets/timing_slider.dart` provides snap-stops over the
full `0s–1y` range, an "0s (immediate)" label, and a tap-to-edit
numeric chip. Used in `step_config_form.dart` for wait / duration /
grace; the disguised reminder's `intervalSeconds` retains a
`TextFormField` since it is already deprecated in favour of
`ChainStep.waitSeconds`.

---

## DE-4: "More Settings" Pattern for Step Configuration — DONE

`lib/features/modes/widgets/more_settings_panel.dart` provides the
collapsible host. Each step's config form mounts its rare-toggle
subset (currently the GPS-logging tri-state) inside the panel; the
collapsed header shows a "(N customized)" badge when any of the
wrapped fields differs from its default.

Applies to:
- Mode editor — per-step config dialog
- Event defaults — per-type detail screen
- Distress mode editor (`/distress-modes/edit`)

---

## DE-5: Home Screen Widget

### Android — DONE

Android AppWidget shipped:
- Quick Exit button — PIN-gated via the Session End PIN; the Duress
  PIN still fires the distress chain.
- Fake Call button — deep-links to `/fake-call` via GoRouter.
- Current session status: `Idle`, `Session active`,
  `Simulation active`, `Battery alert`, plus an `mm:ss` elapsed
  timer when applicable.

Implementation: the `home_widget` package (0.9.x) bridges Flutter
↔ Android `AppWidgetProvider`; widget metadata in
`android/app/src/main/res/xml/guardian_angela_widget_info.xml`;
layout in
`android/app/src/main/res/layout/guardian_angela_widget.xml`. Dart
wrapper: `lib/services/implementations/home_widget_service.dart`.
`SessionController` emits widget updates on every session
transition; `HomeScreen` registers the interactivity callback and
observes deep-link URIs and pending action markers.

### iOS — DEFERRED

iOS WidgetKit interactive widget is not yet implemented. The
`home_widget_service` calls become no-ops on iOS. When the iOS side
ships, it will follow the same App-Group / `AppIntent` pattern
documented in earlier drafts of this section, scoped to the same
two buttons (Quick Exit + Fake Call) and the same status text. iOS
16 fallbacks would use a deep-link `Link(destination:)` since
interactive `AppIntent` requires iOS 17+.

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

**Rejected.** False positive risk from pocket jostling, accidental
device handling, or physical activity outweighs the benefit of an
accelerometer-based SOS trigger. Users expect deliberate,
intentional escalation mechanisms. This feature will NOT be
implemented.
