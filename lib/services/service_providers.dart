// service_providers.dart — THE SINGLE WIRING OWNER.
//
// All Riverpod providers for Guardian Angela services live HERE and
// only here. No `Real*Service` constructor may be called outside this
// file (CI grep gate: `grep -rn "Real.*Service(" lib/ | grep -v
// service_providers.dart` must be empty).
//
// Phase 5A foundation. Stage 5B.1 adds 7 leaf service triplets.
// Stages 5B.2/5B.3/5C add the remaining service providers.
// New Real*Service constructors MUST be added here only.
//
// See spec 05 §Service Providers (lines 1295–1330) and
// `docs/wiring-map.md` for the full provider inventory.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:guardianangela/data/db/database.dart';
import 'package:guardianangela/data/repositories/app_settings_repository.dart';
import 'package:guardianangela/data/repositories/battery_alert_config_repository.dart';
import 'package:guardianangela/data/repositories/contacts_repository.dart';
import 'package:guardianangela/data/repositories/json_singleton_repository.dart';
import 'package:guardianangela/data/repositories/session_log_repository.dart';
import 'package:guardianangela/data/repositories/user_profile_repository.dart';
import 'package:guardianangela/services/audio_service.dart';
import 'package:guardianangela/services/contact_service.dart';
import 'package:guardianangela/services/encryption_service.dart';
import 'package:guardianangela/services/flash_service.dart';
import 'package:guardianangela/services/protocols/audio_service_protocol.dart';
import 'package:guardianangela/services/protocols/contact_service_protocol.dart';
import 'package:guardianangela/services/protocols/encryption_service_protocol.dart';
import 'package:guardianangela/services/protocols/flash_service_protocol.dart';
import 'package:guardianangela/services/protocols/recording_service_protocol.dart';
import 'package:guardianangela/services/protocols/screen_flash_service_protocol.dart';
import 'package:guardianangela/services/protocols/vibration_service_protocol.dart';
import 'package:guardianangela/services/protocols/wakelock_service_protocol.dart';
import 'package:guardianangela/services/recording_service.dart';
import 'package:guardianangela/services/screen_flash_service.dart';
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

/// The Drift database instance.
///
/// Phase 5A: returns an in-memory database so the provider graph can be
/// built without running the full app startup sequence. Stage 5C
/// replaces this with an `AsyncNotifierProvider` that awaits
/// `EncryptionServiceProtocol.openEncryptedDatabase` and applies
/// `PRAGMA key` before the first read.
///
/// Tests override this with `GuardianAngelaDatabase.memory()` directly
/// via `ProviderContainer(overrides: [databaseProvider.overrideWithValue(...)])`.
final databaseProvider = Provider<GuardianAngelaDatabase>((ref) {
  return GuardianAngelaDatabase.memory();
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

/// [BatteryAlertConfigRepository] wired to [keyProviderProvider].
final batteryAlertConfigRepositoryProvider =
    Provider<BatteryAlertConfigRepository>((ref) {
      return BatteryAlertConfigRepository(
        keyProvider: ref.read(keyProviderProvider),
      );
    });

// ---------------------------------------------------------------------------
// SessionLogRepository (Drift-backed)
// ---------------------------------------------------------------------------

/// [SessionLogRepository] backed by [databaseProvider]'s
/// [SessionLogsDao].
final sessionLogRepositoryProvider = Provider<SessionLogRepository>((ref) {
  return SessionLogRepository(ref.read(databaseProvider).sessionLogsDao);
});

// ---- Output / sensor services ----

/// [VibrationServiceProtocol] backed by `package:vibration`.
///
/// Tests override with [SimulationVibrationService] from
/// `lib/services/sim/vibration_service_sim.dart`.
final vibrationServiceProvider = Provider<VibrationServiceProtocol>((ref) {
  return RealVibrationService();
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
/// Tests override with [SimulationContactService] from
/// `lib/services/sim/contact_service_sim.dart`.
final contactServiceProvider = Provider<ContactServiceProtocol>((ref) {
  final repo = ContactsRepository(ref.read(databaseProvider).contactsDao);
  return RealContactService(repository: repo);
});

/// [AudioServiceProtocol] backed by `package:just_audio`.
///
/// Tests override with [SimulationAudioService] from
/// `lib/services/sim/audio_service_sim.dart`.
final audioServiceProvider = Provider<AudioServiceProtocol>((ref) {
  return RealAudioService();
});
