# Manual device-test checklist (Phase 16)

Cross-references test-strategy.md §7.4 and the Phase 16 rollout plan.
Each row below MUST be executed by a human tester on the specified
physical device before cutting a release tag. Patrol covers the
emulator smoke paths; this list is for anything that the emulator
cannot validate.

| # | Scenario | Device | Pass criteria |
|---|----------|--------|---------------|
| 1 | Walk Mode — real escalation chain, PIN disarm | Pixel 7 (Android 14) | Full chain runs end-to-end; SMS delivered; disarm accepts PIN within 15 s timeout |
| 2 | Walk Mode — duress PIN silently triggers distress | Samsung Galaxy S23 (Android 14) | PIN prompt accepts duress PIN, UI returns to idle-looking state, distress chain fires in background (SMS sent, no visible alarm) |
| 3 | Date Mode — disguised reminder + grace-period response | iPhone 15 (iOS 17) | Reminder notification looks like a benign app (Calendar / Duolingo); tapping "respond" within grace resets the timer |
| 4 | Distress hardware trigger — 5x volume press with 500 ms cooldown | Pixel 7 | Five presses within 2 s fire distress; a 6th press within 500 ms is **ignored** (cooldown); pattern beyond the cooldown fires again |
| 5 | 14-locale render check — all screens in all languages | Any | No text overflow, no missing strings (ARB completeness), RTL (ar, fa, he) flips layout correctly |
| 6 | Simulation defense — simulation mode cannot send real SMS | Pixel 7 + Samsung S23 | Packet capture confirms 0 SMS egress during a full Walk Mode sim; toast-only messaging is visible; `SessionEngine` rejects real-session starts with a speed multiplier |
| 7 | Home widget — tap-to-arm from the launcher | Pixel 7 | Long-press Home → add widget → tap "Arm Walk Mode" → app launches into the mode-picker with the correct mode pre-selected |
| 8 | Force-close recovery | Samsung S23 | Start Walk Mode, force-stop the app from Settings, re-open: session state is restored from persistent storage; pending SMS are re-enqueued via `SmsWorker` (WorkManager) |
| 9 | Telemetry opt-out — packet capture verifies no Sentry egress | Any | With `ga_telemetry_optout=true` in secure storage, mitmproxy sees zero requests to `*.de.sentry.io` during a full session |

## Executing the checklist

1. Flash the release candidate APK (signed, not debug).
2. For each row, reset the app (`adb shell pm clear com.guardianangela.app` on Android; delete + reinstall on iOS).
3. Record pass/fail in the release ticket with a screen recording attached.
4. Any failure blocks the release — no exceptions.

## Automation status

Rows 1, 3, 7 have partial Patrol coverage (`integration_test/`) but
Patrol runs only on the emulator — a human still validates on the
physical devices above. Rows 4, 6, 8, 9 cannot be automated today and
require manual execution per release.
