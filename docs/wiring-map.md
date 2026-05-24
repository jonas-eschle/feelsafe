# Guardian Angela — Riverpod Wiring Map

Single source of truth for every Riverpod `Provider<T>` registered in
`lib/services/service_providers.dart`. The CI test
`test/wiring/wiring_map_coverage_test.dart` parses this file and verifies
bidirectional consistency with the live provider declarations.

Any row missing a provider, or any provider missing a row, is a CI failure.

**Status values:**
- `wired-real` — Real impl wired; simulation override available via `ProviderContainer.overrideWithValue`.
- `wired-sim-only` — Only the simulation impl exists; real impl pending.
- `pending-5b` — Protocol interface exists under `lib/services/protocols/`; Real + Simulation impls land in Stage 5B.
- `pending-5c` — Wiring deferred to Stage 5C (main.dart / startup-gate rework).

---

## Provider inventory

| Provider | Type | Real impl | Simulation impl | Status | Spec ref |
|---|---|---|---|---|---|
| `encryptionServiceProvider` | `EncryptionServiceProtocol` | `RealEncryptionService` | `SimulationEncryptionService` | `wired-real` | spec 05 §EncryptionService |
| `keyProviderProvider` | `KeyProvider` | derived from `encryptionServiceProvider` | derived from `encryptionServiceProvider` | `wired-real` | spec 05 §EncryptionService |
| `databaseProvider` | `GuardianAngelaDatabase` | `GuardianAngelaDatabase.open(...)` | `GuardianAngelaDatabase.memory()` | `pending-5c` | spec 03 §Storage Architecture |
| `appSettingsRepositoryProvider` | `AppSettingsRepository` | `AppSettingsRepository(keyProvider:)` | override `encryptionServiceProvider` with `SimulationEncryptionService` | `wired-real` | spec 03 §AppSettings |
| `userProfileRepositoryProvider` | `UserProfileRepository` | `UserProfileRepository(keyProvider:)` | override `encryptionServiceProvider` with `SimulationEncryptionService` | `wired-real` | spec 03 §UserProfile |
| `batteryAlertConfigRepositoryProvider` | `BatteryAlertConfigRepository` | `BatteryAlertConfigRepository(keyProvider:)` | override `encryptionServiceProvider` with `SimulationEncryptionService` | `wired-real` | spec 03 §BatteryAlertConfig |
| `sessionLogRepositoryProvider` | `SessionLogRepository` | `SessionLogRepository(dao)` | override `databaseProvider` with `GuardianAngelaDatabase.memory()` | `wired-real` | spec 03 §SessionLog |
| `vibrationServiceProvider` | `VibrationServiceProtocol` | `RealVibrationService` | `SimulationVibrationService` | `wired-real` | spec 05 §VibrationService |
| `wakelockServiceProvider` | `WakelockServiceProtocol` | `RealWakelockService` | `SimulationWakelockService` | `wired-real` | spec 05 §WakelockService |
| `flashServiceProvider` | `FlashServiceProtocol` | `RealFlashService` | `SimulationFlashService` | `wired-real` | spec 05 §FlashService |
| `screenFlashServiceProvider` | `ScreenFlashServiceProtocol` | `RealScreenFlashService` | `SimulationScreenFlashService` | `wired-real` | spec 05 §ScreenFlashService |
| `recordingServiceProvider` | `RecordingServiceProtocol` | `RealRecordingService` | `SimulationRecordingService` | `wired-real` | spec 05 §RecordingService |
| `contactServiceProvider` | `ContactServiceProtocol` | `RealContactService` | `SimulationContactService` | `wired-real` | spec 05 §ContactService |
| `audioServiceProvider` | `AudioServiceProtocol` | `RealAudioService` | `SimulationAudioService` | `wired-real` | spec 05 §AudioService |
| `notificationServiceProvider` | `NotificationServiceProtocol` | `RealNotificationService` | `SimulationNotificationService` | `pending-5b` | spec 05 §Notification Channel Architecture — [protocol](../lib/services/protocols/notification_service_protocol.dart) |
| `backgroundSessionServiceProvider` | `BackgroundSessionServiceProtocol` | `RealBackgroundSessionService` | `SimulationBackgroundSessionService` | `pending-5b` | spec 05 §BackgroundSessionService — [protocol](../lib/services/protocols/background_session_service_protocol.dart) |
| `hardwareButtonServiceProvider` | `HardwareButtonServiceProtocol` | `RealHardwareButtonService` | `SimulationHardwareButtonService` | `pending-5b` | spec 05 §HardwareButtonService — [protocol](../lib/services/protocols/hardware_button_service_protocol.dart) |
| `batteryMonitorServiceProvider` | `BatteryMonitorServiceProtocol` | `RealBatteryMonitorService` | `SimulationBatteryMonitorService` | `pending-5b` | spec 05 §BatteryMonitorService — [protocol](../lib/services/protocols/battery_monitor_service_protocol.dart) |
| `systemUiServiceProvider` | `SystemUiServiceProtocol` | `RealSystemUiService` | `SimulationSystemUiService` | `pending-5b` | spec 05 §BackgroundSessionService §Stealth Mode — [protocol](../lib/services/protocols/system_ui_service_protocol.dart) |
| `callStateServiceProvider` | `CallStateServiceProtocol` | `RealCallStateService` | `SimulationCallStateService` | `pending-5b` | spec 05 §PhoneService, spec 10 §Real Incoming Call Detection — [protocol](../lib/services/protocols/call_state_service_protocol.dart) |
| `messagingServiceProvider` | `MessagingServiceProtocol` | `RealMessagingService` | `SimulationMessagingService` | `pending-5b` | spec 05 §MessagingService — [protocol](../lib/services/protocols/messaging_service_protocol.dart) |
| `phoneServiceProvider` | `PhoneServiceProtocol` | `RealPhoneService` | `SimulationPhoneService` | `pending-5b` | spec 05 §PhoneService — [protocol](../lib/services/protocols/phone_service_protocol.dart) |
| `locationServiceProvider` | `LocationServiceProtocol` | `RealLocationService` | `SimulationLocationService` | `wired-real` | spec 05 §LocationService — [protocol](../lib/services/protocols/location_service_protocol.dart) |
| `sentryServiceProvider` | `SentryServiceProtocol` | `RealSentryService` | `SimulationSentryService` | `pending-5b` | spec 05 §Service Providers, decision D2 — [protocol](../lib/services/protocols/sentry_service_protocol.dart) |
| `sessionLogRecorderProvider` | `SessionLogRecorderProtocol` | `SessionLogRecorder` | `SimulationSessionLogRecorder` | `pending-5b` | spec 05 §SessionLogRecorder — [protocol](../lib/services/protocols/session_log_recorder_protocol.dart) |
| `permissionAuditServiceProvider` | `PermissionAuditServiceProtocol` | `RealPermissionAuditService` | `SimulationPermissionAuditService` | `pending-5b` | spec 05 §Permission Audit Flow — [protocol](../lib/services/protocols/permission_audit_service_protocol.dart) |
| `sessionStartValidatorProvider` | `SessionStartValidatorProtocol` | `RealSessionStartValidator` | `SimulationSessionStartValidator` | `pending-5b` | spec 05 §SessionStartValidator — [protocol](../lib/services/protocols/session_start_validator_protocol.dart) |
| `backupServiceProvider` | `BackupServiceProtocol` | `RealBackupService` | `SimulationBackupService` | `pending-5b` | spec 05 §BackupService — [protocol](../lib/services/protocols/backup_service_protocol.dart) |
