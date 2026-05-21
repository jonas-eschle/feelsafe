# 11 — Enhancement History

> **Normative status:** This document is HISTORICAL. As of the
> pre-Phase 0 spec rework (2026-05-21), every prior optional add-on
> has been either PROMOTED to a normative spec section (and is
> shipped at v3 GA) or DELETED from scope. Per the D15 decision,
> the v3 GA target ships every feature in the spec — the prior
> "post-GA add-on" doctrine is retired.

## Promotion log (where former optional enhancements now live)

The following promotions all landed in the pre-Phase 0 spec rework
commit. Each entry was an optional add-on in earlier spec drafts;
each one is now part of the normative spec set and a GA requirement.

| Enhancement | Normative home |
|---|---|
| Timer slider widget (logarithmic scale, snap stops, tap-to-edit chip, "0 s (immediate)" pill) | `04-screens-navigation.md` → Shared Widgets → TimingSlider |
| Per-step GPS-logging override (`LogGpsOverride { useDefault, forceOn, forceOff }`) | `03-data-models.md` → StepConfig (`logGps` field on every relevant subclass) + `02-event-types.md` (per-step config rows) |
| Interval GPS tracking on the active session | `03-data-models.md` → SessionMode (`trackingEnabled`, `trackingIntervalSeconds`, `trackingBufferSize`) + `05-services.md` → LocationService |
| "More settings" collapsible panel for rare step toggles | `04-screens-navigation.md` → Shared Widgets → MoreSettingsPanel |
| Android home-screen widget (Quick Exit, Fake Call, live status line) | `04-screens-navigation.md` → Shared Widgets → Home Screen Widget (Android section) + `10-platform-matrix.md` → Home Screen Widget |
| iOS home-screen widget (D14 — `AppIntent` on iOS 17+, `Link(destination:)` deep-link fallback on iOS 16) | `04-screens-navigation.md` → Shared Widgets → Home Screen Widget (iOS section) + `10-platform-matrix.md` |
| Voice recording assets for 14 locales (D14 — first-launch TTS pipeline via `flutter_tts.synthesizeToFile()`, user-recordable in Settings → Voice Recordings) | `05-services.md` → AudioService → "Voice recording assets — TTS placeholder pipeline" |

## Rejected enhancements (kept for posterity)

### REJ-1: Shake-to-SOS (Accelerometer-Based Emergency Trigger)

**Rejected.** False positive risk from pocket jostling, accidental
device handling, or physical activity outweighs the benefit of an
accelerometer-based SOS trigger. Users expect intentional escalation
mechanisms. This feature will NOT be implemented. Cross-reference:
`docs/rewrite/lessons-learned.md` §5.6.
