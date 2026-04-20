# Guardian Angela — Wiring Map

Checked-in artifact tracking every `field → provider → service → side-effect` chain in the app. A test at `test/wiring/wiring_map_coverage_test.dart` parses this table and verifies every row maps to a real provider binding. Any row missing a provider, or any provider missing a row, fails CI.

Closes failure modes L8 (wiring-map drift) and L11 (implicit wiring) per `docs/rebuild-strategy.md` §2.

## Schema

Each row in the table below documents one wiring chain:

| Field | Provider | Service | Side-effect | Closes |
|-------|----------|---------|-------------|--------|
| `<model.field>` | `<riverpodProvider>` | `<ServiceProtocol.method>` | `<real-world effect>` | `L<n>` or `—` |

## Rules

1. **One row per persisted field that leads to a real-world side-effect.** Pure-data fields (e.g., `name`) don't need a row. A field like `AppSettings.emergencyCallNumber` that ends up as a phone call needs a row.
2. **Provider column must cite a real Riverpod provider** that lives in `lib/services/service_providers.dart` or `lib/data/repositories/repository_providers.dart`.
3. **Service column cites a protocol + method**, e.g., `PhoneServiceProtocol.callEmergency`. Never a concrete class.
4. **Side-effect column is human-readable** — "dials emergency number", "sends SMS with location", "shows notification".
5. **Closes column** links to the failure mode this wiring prevents (L1–L14) or `—` if not safety-critical.

## Table

| Field | Provider | Service | Side-effect | Closes |
|-------|----------|---------|-------------|--------|
| `AppSettings.emergencyCallNumber` | `settingsControllerProvider` | `PhoneServiceProtocol.callEmergency` | Dials configured emergency number (default `112`) on `callEmergency` step | L1 |
| `SessionMode.chainSteps[callEmergency]` | `modesRepositoryProvider` | `PhoneServiceProtocol.callEmergency` | Per-step override dials configured number via `CallEmergencyStrategy` | L1 |
| `SessionMode.chainSteps[smsContact]` | `modesRepositoryProvider` | `MessagingServiceProtocol.sendToAll` | Sends SMS (+ WhatsApp/Telegram when enabled) to filtered contacts | L1 |
| `SessionMode.chainSteps[phoneCallContact]` | `modesRepositoryProvider` | `PhoneServiceProtocol.callContact` | Places a voice call to the configured emergency contact | L1 |
| `SessionMode.chainSteps[fakeCall]` | `modesRepositoryProvider` | `AudioServiceProtocol.playRingtone` | Plays a simulated ringtone; user can answer/decline/hang-up | L1 |
| `SessionMode.chainSteps[fakeCall]` | `modesRepositoryProvider` | `VibrationServiceProtocol.fakeCallPattern` | Vibrates with a phone-call pattern during the fake-call step | L1 |
| `SessionMode.chainSteps[loudAlarm]` | `modesRepositoryProvider` | `AudioServiceProtocol.playAlarm` | Plays a loud alarm tone, looped until the step ends | L1 |
| `SessionMode.chainSteps[loudAlarm]` | `modesRepositoryProvider` | `VibrationServiceProtocol.alarmPattern` | Vibrates with an intense alarm pattern during `loudAlarm` | L1 |
| `SessionMode.chainSteps[disguisedReminder]` | `modesRepositoryProvider` | `NotificationServiceProtocol.showDisguised` | Posts a disguised notification (Calendar, Duolingo, etc.) | L1 |
| `SessionMode.chainSteps[countdownWarning]` | `modesRepositoryProvider` | `NotificationServiceProtocol.showWarning` | Shows a visible countdown warning before escalation | L1 |
| `SessionMode.distressTriggers[hardwareButton]` | `hardwareButtonServiceProvider` | `HardwareButtonServiceProtocol.panicEvents` | Volume-up × 5 → `SessionEngine.replaceWithDistressChain` | L4 |
| `SessionMode.disarmTriggers[gpsArrival]` | `geofenceServiceProvider` | `GeofenceServiceProtocol.arrivals` | GPS arrival inside configured radius disarms the session | L4 |
| `SessionMode.distressChainId` | `distressChainsRepositoryProvider` | `SessionEngine.replaceWithDistressChain` | Resolves to the chain fired by distress triggers (first in repo when null) | L9 |
| `BatteryAlertConfig.thresholdPercent` | `batteryAlertControllerProvider` | `BatteryMonitorServiceProtocol.alerts` | Fires one-shot alert when battery drops below threshold | L1 |
| `BatteryAlertConfig.chain` | `batteryAlertControllerProvider` | `SessionEngine` + `SessionOrchestrator` | Runs configured chain in a background session (same pipeline as user sessions) | L14 |
| `StealthConfig.enabled` | `settingsControllerProvider` | `StealthIconServiceProtocol.setPreset` | Toggles UI to stealth mode + activates icon alias | L8 |
| `StealthConfig.fakeIcon` | `settingsControllerProvider` | `StealthIconServiceProtocol.setPreset` | Selects which icon alias is enabled on the home screen | L8 |
| `AppSettings.appPinHash` | `settingsControllerProvider` | `SessionController.handlePinResult` | Gate entry to app / settings; wrong-PIN threshold fires distress | L7 |
| `AppSettings.duressPinHash` | `settingsControllerProvider` | `SessionController.handlePinResult` | Duress PIN entry silently fires the distress chain | L9 |
| `AppSettings.sessionEndPinHash` | `settingsControllerProvider` | `SessionController.handlePinResult` | Gates the disarm flow from the session screen | L7 |
| `GpsLoggingConfig.enabled` | `settingsControllerProvider` | `LocationServiceProtocol.startLogging` | Toggles on/off periodic GPS location logging | L1 |
| `GpsLoggingConfig.intervalSeconds` | `settingsControllerProvider` | `LocationServiceProtocol.startLogging` | Controls location polling cadence | L1 |
| `EmergencyContact.channels[phoneCall]` | `contactsRepositoryProvider` | `PhoneServiceProtocol.callContact` | Voice call leg of a `phoneCallContact` step | L1 |
| `EmergencyContact.channels[sms]/[whatsapp]/[telegram]` | `contactsRepositoryProvider` | `MessagingServiceProtocol.sendMessage` | Sends message on each enabled channel per contact | L1 |
| `UserProfile.allergies` / `medicalConditions` / `medications` | `userProfileRepositoryProvider` | `MessagingServiceProtocol.sendToAll` | Medical fields injected into distress SMS body | L1 |
| `AppSettings.alarmDndOverride` | `settingsControllerProvider` | `DeviceStateServiceProtocol.requestDndOverride` | Allows loud-alarm step to bypass Do-Not-Disturb | L1 |
| `AppSettings.isFirstLaunch` | `settingsControllerProvider` | `OnboardingController.completeOnboarding` | Controls onboarding routing on first launch | — |
| `AppSettings.selectedModeId` | `settingsControllerProvider` | `SessionController.startSession` | Default mode preselected on home screen | — |

*(Provider existence verified by `test/wiring/wiring_map_coverage_test.dart`.)*
