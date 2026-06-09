// service_providers.dart — THE SINGLE WIRING OWNER.
//
// All Riverpod providers for Guardian Angela services live HERE and
// only here. No `Real*Service` constructor may be called outside this
// file (CI grep gate: `grep -rn "Real.*Service(" lib/ | grep -v
// service_providers.dart` must be empty).
//
// Phase 5A foundation. Stage 5B.1 adds 7 leaf service triplets.
// Stage 5B.2 adds: location, notification, hardwareButton,
//   callState, systemUi.
// Stage 5B.3 adds: phone, messaging, backgroundSession, sentry,
//   sessionLogRecorder.
// Stage 5C adds: permissionAudit, sessionStartValidator, backup.
//   Also reworks databaseProvider → FutureProvider backed by EncryptionService.
// New Real*Service constructors MUST be added here only.
//
// See spec 05 §Service Providers (lines 1295–1330) and
// `docs/wiring-map.md` for the full provider inventory.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:guardianangela/data/db/database.dart';
import 'package:guardianangela/data/repositories/app_settings_repository.dart';
import 'package:guardianangela/data/repositories/contacts_repository.dart';
import 'package:guardianangela/data/repositories/feedback_history_repository.dart';
import 'package:guardianangela/data/repositories/json_singleton_repository.dart';
import 'package:guardianangela/data/repositories/session_log_repository.dart';
import 'package:guardianangela/data/repositories/user_profile_repository.dart';
import 'package:guardianangela/domain/models/session_context.dart';
import 'package:guardianangela/features/feedback_form/feedback_prompt_repository.dart';
import 'package:guardianangela/features/home/home_checklist_repository.dart';
import 'package:guardianangela/services/audio_service.dart';
import 'package:guardianangela/services/background_session_service.dart';
import 'package:guardianangela/services/backup_service.dart';
import 'package:guardianangela/services/biometric_service.dart';
import 'package:guardianangela/services/call_state_service.dart';
import 'package:guardianangela/services/contact_service.dart';
import 'package:guardianangela/services/device_info_service.dart';
import 'package:guardianangela/services/encryption_service.dart';
import 'package:guardianangela/services/flash_service.dart';
import 'package:guardianangela/services/hardware_button_service.dart';
import 'package:guardianangela/services/home_widget_service.dart';
import 'package:guardianangela/services/location_service.dart';
import 'package:guardianangela/services/messaging_service.dart';
import 'package:guardianangela/services/notification_service.dart';
import 'package:guardianangela/services/permission_audit_service.dart';
import 'package:guardianangela/services/phone_service.dart';
import 'package:guardianangela/services/protocols/audio_service_protocol.dart';
import 'package:guardianangela/services/protocols/background_session_service_protocol.dart';
import 'package:guardianangela/services/protocols/backup_service_protocol.dart';
import 'package:guardianangela/services/protocols/biometric_service_protocol.dart';
import 'package:guardianangela/services/protocols/call_state_service_protocol.dart';
import 'package:guardianangela/services/protocols/contact_service_protocol.dart';
import 'package:guardianangela/services/protocols/device_info_service_protocol.dart';
import 'package:guardianangela/services/protocols/encryption_service_protocol.dart';
import 'package:guardianangela/services/protocols/flash_service_protocol.dart';
import 'package:guardianangela/services/protocols/hardware_button_service_protocol.dart';
import 'package:guardianangela/services/protocols/home_widget_service_protocol.dart';
import 'package:guardianangela/services/protocols/location_service_protocol.dart';
import 'package:guardianangela/services/protocols/messaging_service_protocol.dart';
import 'package:guardianangela/services/protocols/notification_service_protocol.dart';
import 'package:guardianangela/services/protocols/permission_audit_service_protocol.dart';
import 'package:guardianangela/services/protocols/phone_service_protocol.dart';
import 'package:guardianangela/services/protocols/quick_exit_service_protocol.dart';
import 'package:guardianangela/services/protocols/recording_service_protocol.dart';
import 'package:guardianangela/services/protocols/screen_flash_service_protocol.dart';
import 'package:guardianangela/services/protocols/sentry_service_protocol.dart';
import 'package:guardianangela/services/protocols/session_start_validator_protocol.dart';
import 'package:guardianangela/services/protocols/system_ui_service_protocol.dart';
import 'package:guardianangela/services/protocols/vibration_service_protocol.dart';
import 'package:guardianangela/services/protocols/wakelock_service_protocol.dart';
import 'package:guardianangela/services/quick_exit_service.dart';
import 'package:guardianangela/services/recording_service.dart';
import 'package:guardianangela/services/screen_flash_service.dart';
import 'package:guardianangela/services/sentry_service.dart';
import 'package:guardianangela/services/session_log_recorder.dart';
import 'package:guardianangela/services/session_start_validator.dart';
import 'package:guardianangela/services/system_ui_service.dart';
import 'package:guardianangela/services/vibration_service.dart';
import 'package:guardianangela/services/wakelock_service.dart';

// ---------------------------------------------------------------------------
// EncryptionService — key lifecycle + database open
// ---------------------------------------------------------------------------

/// The encryption service that manages the AES-256 key stored in
/// `flutter_secure_storage`.
///
/// Tests override this with
/// `encryptionServiceProvider.overrideWithValue(SimulationEncryptionService())`
/// so no real secure-storage calls are made.
final encryptionServiceProvider = Provider<EncryptionServiceProtocol>((ref) {
  return RealEncryptionService();
});

// ---------------------------------------------------------------------------
// KeyProvider — bridge between EncryptionService and repositories
// ---------------------------------------------------------------------------

/// A [KeyProvider] backed by [encryptionServiceProvider].
///
/// Every [JsonSingletonRepository] that needs the AES-256 key reads
/// its key from here. Overriding [encryptionServiceProvider] in tests
/// automatically gives all repositories an ephemeral in-memory key.
final keyProviderProvider = Provider<KeyProvider>((ref) {
  final enc = ref.read(encryptionServiceProvider);
  return enc.getOrCreateKeyAsBase64;
});

// ---------------------------------------------------------------------------
// GuardianAngelaDatabase
// ---------------------------------------------------------------------------

/// The Drift database instance, opened with AES-256 encryption.
///
/// Stage 5C: changed from a synchronous [Provider] to a [FutureProvider]
/// that awaits `EncryptionServiceProtocol.getOrCreateKeyAsBase64()` and
/// opens the on-disk database via `GuardianAngelaDatabase.open(encryptionKey)`.
/// The database path is resolved internally by [GuardianAngelaDatabase.open].
///
/// Tests override this with
/// `databaseProvider.overrideWith((_) async => GuardianAngelaDatabase.memory())`.
final databaseProvider = FutureProvider<GuardianAngelaDatabase>((ref) async {
  final enc = ref.read(encryptionServiceProvider);
  final key = await enc.getOrCreateKeyAsBase64();
  return GuardianAngelaDatabase.open(encryptionKey: key);
});

// ---------------------------------------------------------------------------
// JSON-singleton repositories
// ---------------------------------------------------------------------------

/// [AppSettingsRepository] wired to [keyProviderProvider].
final appSettingsRepositoryProvider = Provider<AppSettingsRepository>((ref) {
  return AppSettingsRepository(keyProvider: ref.read(keyProviderProvider));
});

/// [UserProfileRepository] wired to [keyProviderProvider].
final userProfileRepositoryProvider = Provider<UserProfileRepository>((ref) {
  return UserProfileRepository(keyProvider: ref.read(keyProviderProvider));
});

/// [HomeChecklistRepository] backing the Safety Setup Checklist's
/// dismissed / simulation-done / first-visit-done flags.
final homeChecklistRepositoryProvider = Provider<HomeChecklistRepository>((
  ref,
) {
  return HomeChecklistRepository();
});

// ---------------------------------------------------------------------------
// SessionLogRepository (Drift-backed)
// ---------------------------------------------------------------------------

/// [SessionLogRepository] backed by [databaseProvider]'s
/// [SessionLogsDao].
///
/// The provider is a [FutureProvider] because [databaseProvider] is now
/// async (Stage 5C).
final sessionLogRepositoryProvider = FutureProvider<SessionLogRepository>((
  ref,
) async {
  final db = await ref.watch(databaseProvider.future);
  return SessionLogRepository(db.sessionLogsDao);
});

/// [FeedbackHistoryRepository] backed by the Drift database.
///
/// Spec 04 §Feedback Form: the screen writes locally before opening
/// the mailto link so the user keeps a copy regardless of the email
/// round-trip outcome.
final feedbackHistoryRepositoryProvider =
    FutureProvider<FeedbackHistoryRepository>((ref) async {
      final db = await ref.watch(databaseProvider.future);
      return FeedbackHistoryRepository(db.feedbackHistoryDao);
    });

/// [FeedbackPromptRepository] gating the optional post-session feedback
/// prompt by counting clean real-session completions (spec 04 §Chain
/// Exhausted Screen — Tier-F F5). SharedPreferences-backed; no DB needed.
final feedbackPromptRepositoryProvider = Provider<FeedbackPromptRepository>((
  ref,
) {
  return FeedbackPromptRepository();
});

// ---- Output / sensor services ----

/// [VibrationServiceProtocol] backed by `package:vibration`.
///
/// Tests override with [SimulationVibrationService] from
/// `lib/services/sim/vibration_service_sim.dart`.
final vibrationServiceProvider = Provider<VibrationServiceProtocol>((ref) {
  return RealVibrationService();
});

/// [BiometricServiceProtocol] backed by `package:local_auth`.
///
/// Powers the App-lock launch gate's optional biometric unlock (opt-in via
/// `AppSettings.appPinBiometricEnabled`). Tests override with
/// [SimulationBiometricService] from
/// `lib/services/sim/biometric_service_sim.dart`.
final biometricServiceProvider = Provider<BiometricServiceProtocol>((ref) {
  return RealBiometricService();
});

/// [WakelockServiceProtocol] backed by `package:wakelock_plus`.
///
/// Tests override with [SimulationWakelockService] from
/// `lib/services/sim/wakelock_service_sim.dart`.
final wakelockServiceProvider = Provider<WakelockServiceProtocol>((ref) {
  return RealWakelockService();
});

/// [FlashServiceProtocol] backed by `package:torch_light`.
///
/// Tests override with [SimulationFlashService] from
/// `lib/services/sim/flash_service_sim.dart`.
final flashServiceProvider = Provider<FlashServiceProtocol>((ref) {
  return RealFlashService();
});

/// [ScreenFlashServiceProtocol] — pure-Dart Stream-based service.
///
/// Tests override with [SimulationScreenFlashService] from
/// `lib/services/sim/screen_flash_service_sim.dart`.
final screenFlashServiceProvider = Provider<ScreenFlashServiceProtocol>((ref) {
  return RealScreenFlashService();
});

/// [RecordingServiceProtocol] backed by `package:record`.
///
/// Tests override with [SimulationRecordingService] from
/// `lib/services/sim/recording_service_sim.dart`.
final recordingServiceProvider = Provider<RecordingServiceProtocol>((ref) {
  return RealRecordingService();
});

/// [ContactServiceProtocol] backed by [ContactsRepository] which wraps
/// [ContactsDao] from [databaseProvider].
///
/// The provider is a [FutureProvider] because [databaseProvider] is now
/// async (Stage 5C).
///
/// Tests override with [SimulationContactService] from
/// `lib/services/sim/contact_service_sim.dart`.
final contactServiceProvider = FutureProvider<ContactServiceProtocol>((
  ref,
) async {
  final db = await ref.watch(databaseProvider.future);
  final repo = ContactsRepository(db.contactsDao);
  return RealContactService(repository: repo);
});

/// [AudioServiceProtocol] backed by `package:just_audio`.
///
/// Tests override with [SimulationAudioService] from
/// `lib/services/sim/audio_service_sim.dart`.
final audioServiceProvider = Provider<AudioServiceProtocol>((ref) {
  return RealAudioService();
});

// ---- Streaming / sensor services ----

/// [LocationServiceProtocol] backed by `package:geolocator`.
///
/// Tracks GPS position during sessions and provides location URLs for
/// message templates. Tests override with [SimulationLocationService]
/// from `lib/services/sim/location_service_sim.dart`.
final locationServiceProvider = Provider<LocationServiceProtocol>((ref) {
  return RealLocationService();
});

/// [NotificationServiceProtocol] backed by `package:flutter_local_notifications`.
///
/// Must call [RealNotificationService.init] at app startup. Tests override
/// with [SimulationNotificationService] from
/// `lib/services/sim/notification_service_sim.dart`.
final notificationServiceProvider = Provider<NotificationServiceProtocol>((
  ref,
) {
  return RealNotificationService();
});

/// [HardwareButtonServiceProtocol] — Android volume-key EventChannel +
/// iOS audio_service headphone-remote handler.
///
/// Native handler registered in `MainActivity.kt`
/// (`com.guardianangela.app/hardware_button` EventChannel →
/// `HardwareButtonChannel.kt`; iOS: `audio_service` media-button handler).
/// Tests override with [SimulationHardwareButtonService] from
/// `lib/services/sim/hardware_button_service_sim.dart`.
final hardwareButtonServiceProvider = Provider<HardwareButtonServiceProtocol>((
  ref,
) {
  return RealHardwareButtonService();
});

/// [CallStateServiceProtocol] — Android PhoneStateListener + iOS
/// CXCallObserver via platform channels.
///
/// Native handler registered in `MainActivity.kt`
/// (`com.guardianangela.app/call_state` Method+Event channel →
/// `CallStateChannel.kt`; iOS: `CallStatePlugin.swift`, registered in
/// `AppDelegate.swift`).
/// Tests override with [SimulationCallStateService] from
/// `lib/services/sim/call_state_service_sim.dart`.
final callStateServiceProvider = Provider<CallStateServiceProtocol>((ref) {
  return RealCallStateService();
});

/// [SystemUiServiceProtocol] — Android MethodChannels for stealth-icon
/// toggling and lock-task pinning; iOS no-op.
///
/// Native handlers are registered in MainActivity.kt
/// (Android: SystemUiChannel.kt + StealthIconChannel.kt; iOS: no-op stubs).
/// Tests override with [SimulationSystemUiService] from
/// `lib/services/sim/system_ui_service_sim.dart`.
final systemUiServiceProvider = Provider<SystemUiServiceProtocol>((ref) {
  return RealSystemUiService();
});

/// [DeviceInfoServiceProtocol] — exposes the SIM-card phone number to
/// the onboarding "Use my SIM number" affordance (spec 04 Extra 28).
///
/// Android invokes `getSimPhoneNumber` via
/// `com.guardianangela.app/device_info`, whose handler (`DeviceInfoChannel.kt`)
/// is registered in `MainActivity.kt`.
/// iOS/web/desktop return [SimNumberUnsupported] without touching the
/// platform channel.
///
/// Tests override with [SimulationDeviceInfoService] from
/// `lib/services/sim/device_info_service_sim.dart`.
final deviceInfoServiceProvider = Provider<DeviceInfoServiceProtocol>((ref) {
  return RealDeviceInfoService();
});

// ---- Communication / cross-cutter services ----

/// [PhoneServiceProtocol] backed by `package:url_launcher` via `tel:` URIs.
///
/// Android: `ACTION_CALL` intent with `CALL_PHONE` permission auto-dials.
/// iOS: system confirmation dialog always shown (documented OS limitation).
///
/// Phone number sanitization strips non-digit characters, preserves leading
/// `+`. Empty sanitized numbers throw [ArgumentError] (fail-loud).
///
/// Tests override with [SimulationPhoneService] from
/// `lib/services/sim/phone_service_sim.dart`.
final phoneServiceProvider = Provider<PhoneServiceProtocol>((ref) {
  return const RealPhoneService();
});

/// [MessagingServiceProtocol] — SMS (Android native WorkManager, iOS
/// url_launcher), WhatsApp, Telegram, and phone-call channel dispatch.
///
/// Depends on [notificationServiceProvider] to show SMS-retry-exhausted
/// notifications and to listen for retry-action taps. The phone-call channel
/// dispatches via [phoneServiceProvider].
///
/// Android native dependency: `SmsChannel.kt` + `SmsWorker.kt` (MethodChannel
/// `com.guardianangela.app/sms`, registered in `MainActivity.kt`).
///
/// Tests override with [SimulationMessagingService] from
/// `lib/services/sim/messaging_service_sim.dart`.
final messagingServiceProvider = Provider<MessagingServiceProtocol>((ref) {
  final notification = ref.read(notificationServiceProvider);
  final phone = ref.read(phoneServiceProvider);
  return RealMessagingService(
    notification: notification,
    phoneCallDispatcher: phone.call,
  );
});

/// [BackgroundSessionServiceProtocol] — manages the Android foreground
/// service and iOS background execution to keep the app alive during active
/// sessions. Provides persistent notification with "I'm Safe", "Pause", and
/// "Resume" action buttons.
///
/// Native dependency: the `flutter_background_service` plugin handles the
/// Android foreground service promotion (its `BackgroundService` is declared
/// in `AndroidManifest.xml` with `foregroundServiceType="specialUse"`) and the
/// iOS background task; the plugin self-registers via the generated plugin
/// registrant (no custom channel in `MainActivity.kt`). `start`/`stop` are
/// wired into the session lifecycle by `SessionController` (M3 C3). The Dart
/// side manages notification content and action routing via
/// [notificationServiceProvider].
///
/// Tests override with [SimulationBackgroundSessionService] from
/// `lib/services/sim/background_session_service_sim.dart`.
final backgroundSessionServiceProvider =
    Provider<BackgroundSessionServiceProtocol>((ref) {
      return RealBackgroundSessionService(
        notification: ref.read(notificationServiceProvider),
      );
    });

/// [QuickExitServiceProtocol] — terminates the app on demand via the
/// `com.guardianangela.app/quick_exit` MethodChannel, whose handler is
/// registered in `MainActivity.kt`.
///
/// On Android the native handler invokes `finishAndRemoveTask()` so the
/// activity also vanishes from the recents stack; on iOS it invokes
/// `exit(0)`. If the channel is ever unavailable (e.g. an error response),
/// the Real implementation falls back to `SystemNavigator.pop(animated:
/// false)` so the gesture still has a visible effect — a defensive fallback,
/// not a missing-handler placeholder.
///
/// Tests override with [SimulationQuickExitService] from
/// `lib/services/sim/quick_exit_service_sim.dart`.
final quickExitServiceProvider = Provider<QuickExitServiceProtocol>((ref) {
  return RealQuickExitService();
});

/// [SentryServiceProtocol] backed by `package:sentry_flutter`.
///
/// Sentry is opt-in by default (decision D2). [RealSentryService.initialize]
/// must be called at app startup with the user's telemetry consent from
/// [AppSettings]. When `enabled: false`, the SDK is never initialized and
/// all [captureException] calls are no-ops.
///
/// The DSN MUST point to an EU-region Sentry project (D2 GDPR data
/// residency). The DSN is supplied at startup from compile-time
/// `--dart-define=SENTRY_DSN=...` or a remote config; it is NOT hardcoded
/// in this file.
///
/// Tests override with [SimulationSentryService] from
/// `lib/services/sim/sentry_service_sim.dart`.
final sentryServiceProvider = Provider<SentryServiceProtocol>((ref) {
  return RealSentryService();
});

/// A [SessionLogRecorderFactory] that constructs one [SessionLogRecorder]
/// per session.
///
/// The provider exposes a factory function rather than a singleton because
/// [SessionLogRecorder] is a short-lived per-session object. The session
/// controller calls `ref.read(sessionLogRecorderProvider)(context)` at
/// session start to receive a fresh recorder.
///
/// For real sessions the recorder performs a single atomic write to
/// [SessionLogRepository] on `finalise`. Simulation sessions use
/// [SimulationSessionLogRecorder] (injected via
/// `sessionLogRecorderProvider.overrideWithValue(...)`) which assembles the
/// log but never persists it.
///
/// The provider is a [FutureProvider] because [sessionLogRepositoryProvider]
/// is now async (Stage 5C).
///
/// Tests override with [SimulationSessionLogRecorder] from
/// `lib/services/session_log_recorder.dart`.
final sessionLogRecorderProvider = FutureProvider<SessionLogRecorderFactory>((
  ref,
) async {
  final repo = await ref.watch(sessionLogRepositoryProvider.future);
  return (SessionContext context) =>
      SessionLogRecorder(context: context, repo: repo);
});

// ---------------------------------------------------------------------------
// PermissionAuditService — Stage 5C
// ---------------------------------------------------------------------------

/// [PermissionAuditServiceProtocol] backed by `package:permission_handler`.
///
/// Inspects only the permissions that the mode actually needs (spec 05
/// §Permission Audit Flow §step 2). The [revocations] stream polls for
/// mid-session permission changes.
///
/// Mid-session revocation detection is **Dart-side polling** via
/// `package:permission_handler` — there is no native push channel for
/// permission-change events (no such Android channel is registered in
/// `MainActivity.kt`). The polling cadence is owned by the service.
///
/// Tests override with [SimulationPermissionAuditService] from
/// `lib/services/sim/permission_audit_service_sim.dart`.
final permissionAuditServiceProvider = Provider<PermissionAuditServiceProtocol>(
  (ref) {
    return RealPermissionAuditService();
  },
);

// ---------------------------------------------------------------------------
// SessionStartValidator — Stage 5C
// ---------------------------------------------------------------------------

/// [SessionStartValidatorProtocol] backed by [RealSessionStartValidator].
///
/// Validates session prerequisites synchronously using cached state
/// (permissions, contact count, emergency number). The session controller
/// must call [RealSessionStartValidator.updateCachedState] before calling
/// [validate] to refresh the cache.
///
/// Tests override with [SimulationSessionStartValidator] from
/// `lib/services/sim/session_start_validator_sim.dart`.
final sessionStartValidatorProvider = Provider<SessionStartValidatorProtocol>((
  ref,
) {
  return RealSessionStartValidator();
});

// ---------------------------------------------------------------------------
// BackupService — Stage 5C
// ---------------------------------------------------------------------------

/// [BackupServiceProtocol] backed by [RealBackupService].
///
/// Exports / imports all app data (contacts, modes, settings, session logs).
/// Export returns a JSON string; the UI layer calls `share_plus` to share
/// it. Import writes to the Drift database inside a single transaction.
///
/// The provider is a [FutureProvider] because [databaseProvider] and
/// [sessionLogRepositoryProvider] are now async (Stage 5C).
///
/// Tests override with [SimulationBackupService] from
/// `lib/services/sim/backup_service_sim.dart`.
final backupServiceProvider = FutureProvider<BackupServiceProtocol>((
  ref,
) async {
  final db = await ref.watch(databaseProvider.future);
  final sessionLogRepo = await ref.watch(sessionLogRepositoryProvider.future);
  return RealBackupService(
    db: db,
    contacts: ContactsRepository(db.contactsDao),
    appSettings: ref.read(appSettingsRepositoryProvider),
    userProfile: ref.read(userProfileRepositoryProvider),
    sessionLogs: sessionLogRepo,
  );
});

// ---------------------------------------------------------------------------
// HomeWidgetService
// ---------------------------------------------------------------------------

/// [HomeWidgetServiceProtocol] backed by `package:home_widget 0.9.x`.
///
/// Writes five pre-localised string keys to the shared widget data store and
/// triggers a native widget refresh on every session-state transition. The
/// Android home-screen widget is the `GuardianAngelaAppWidget.kt` RemoteViews
/// provider declared in `AndroidManifest.xml`; the plugin self-registers via
/// the generated plugin registrant (no custom channel in `MainActivity.kt`).
/// The interactivity callback [homeWidgetCallback] handles Android background
/// taps; iOS taps use the `guardianangela://` URL scheme directly.
///
/// Tests override with [SimulationHomeWidgetService] from
/// `lib/services/sim/home_widget_service_sim.dart`.
final homeWidgetServiceProvider = Provider<HomeWidgetServiceProtocol>((ref) {
  return RealHomeWidgetService();
});
