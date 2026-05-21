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

Each entry is OUT OF SCOPE for v3 GA. Each lists the rejection rationale and (where applicable) the condition that would cause us to re-visit the decision.

### REJ-1: Shake-to-SOS (accelerometer-based emergency trigger)

**Rejected.** False-positive risk from pocket jostling, accidental device handling, or physical activity outweighs the benefit of an accelerometer-based SOS trigger. Users expect intentional escalation mechanisms. Cross-reference: `docs/rewrite/lessons-learned.md` §5.6.

### REJ-2: Photo / audio attachment to outgoing messages (cloud-upload feature)

**Rejected.** MMS is unreliable across carriers, and any HTTP-hosted attachment requires a backend infrastructure (storage, access control, retention policy) that conflicts with the offline-first invariant. Audio recordings are still **captured locally** (per spec 02 §`smsContact` Auto-Recording), and the session log carries them as evidence; they are not attached to outbound messages. The `{photo}` placeholder is removed from SMS templates per G-017. Re-visit if v3+ adds a server tier with privacy-reviewed cloud upload.

### REJ-3: Video recording (in-session video capture)

**Rejected.** Storage cost, on-device encryption overhead, privacy/legal exposure, and the additional platform-permission load (`CAMERA` continuous capture) outweigh the marginal evidence value over the shipped audio + interval-GPS log. Cross-reference: `docs/spec/05-services.md` §RecordingService.

### REJ-4: Server-side dispatch (Noonlight-style monitoring centre)

**Rejected.** Direct conflict with the offline-first invariant ("no server dependency for core features"). A monitoring-centre tier would require an ops org, 24/7 staffing, compliance certifications (e.g., 911 connectivity in the US), and a commercial SLA model none of which fits v3 GA's scope or the project's offline-first stance.

### REJ-5: Panic data-wipe ("nuke")

**Rejected.** Low value (the user can uninstall the app to remove local data). High risk: a destructive one-tap action sits next to safety actions; accidental invocation by the user under stress would destroy a legitimate session log. Backup and recovery features serve the legitimate data-loss case.

### REJ-6: Dynamic app-label rename on home screen (beyond stealth mode)

**Rejected.** The shipped stealth mode covers the threat model: `StealthConfig.fakeName` + `StealthConfig.fakeIcon` + Android activity-alias toggles (`StealthAlias_music` / `_podcast` / `_calendar`) hide the app's identity. Full dynamic label-renaming via platform APIs has high implementation risk and offers little additional concealment beyond what stealth mode already does.

### REJ-7: what3words / external location-code services

**Rejected.** what3words' free tier requires internet access; offline-first design rules out this hard dependency for core escalation. Standard lat/long + reverse-geocoded Google Maps URLs already serve the location-share use case in shipped SMS templates.

### REJ-8: Live location streaming to contacts

**Rejected.** Real-time location streaming requires a backend relay (the recipient cannot poll the user's device directly), conflicting with the offline-first invariant. The shipped interval-GPS history (`SessionMode.trackingEnabled` + `trackingIntervalSeconds`) provides a comparable evidence trail after the session ends.

### REJ-9: Companion app for emergency contacts

**Rejected.** A separate iOS + Android contact-side app expands v3 GA scope to two additional platforms with their own release pipelines, permissions, and onboarding flows. Out of scope; SMS / WhatsApp / Telegram delivery covers the contact-notification use case without a second app.

### REJ-10: Lock-screen shortcuts

**Rejected.** Android 11+ no longer allows custom lock-screen actions, and iOS does not expose a lock-screen action API for third-party apps. The shipped Home-Screen Widget (Quick Exit + Fake Call buttons) covers the "quick-trigger from outside the app" use case.

### REJ-11: Crash / accident detection (sensor fusion)

**Rejected.** Reliable crash detection requires an ML model trained against fall / impact data, careful false-positive tuning, and continuous accelerometer + gyro sampling (battery cost). Risk of false escalation undermines user trust. Outside v3 GA scope.

### REJ-12: Crisis-hotline directory (in-app curated list)

**Rejected.** A useful directory spans 195+ countries and requires constant curation (phone numbers change, services shut down, new services launch). Out of v3 GA scope; users with a relevant hotline can add it as a regular `EmergencyContact`.

### REJ-13: Telegram Bot API auto-send

**Rejected.** Auto-sending via the Telegram Bot API would require either a Bot Token embedded in the app (spoofing risk; immediate exfiltration possible) or a backend authentication service (offline-first violation). The shipped `tg://msg` deep-link path requires the user to press Send manually but is secure and offline.
