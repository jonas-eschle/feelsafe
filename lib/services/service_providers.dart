// service_providers.dart — THE SINGLE WIRING OWNER.
//
// All Riverpod providers for Guardian Angela services live HERE and
// only here. No `Real*Service` constructor may be called outside this
// file (CI grep gate: `grep -rn "Real.*Service(" lib/ | grep -v
// service_providers.dart` must be empty).
//
// Phase 5A foundation. Stages 5B/5C add the remaining ~17 service
// providers. New Real*Service constructors MUST be added here only.
//
// See spec 05 §Service Providers (lines 1295–1330) and
// `docs/wiring-map.md` for the full provider inventory.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:guardianangela/data/db/database.dart';
import 'package:guardianangela/data/repositories/app_settings_repository.dart';
import 'package:guardianangela/data/repositories/battery_alert_config_repository.dart';
import 'package:guardianangela/data/repositories/json_singleton_repository.dart';
import 'package:guardianangela/data/repositories/session_log_repository.dart';
import 'package:guardianangela/data/repositories/user_profile_repository.dart';
import 'package:guardianangela/services/encryption_service.dart';
import 'package:guardianangela/services/protocols/encryption_service_protocol.dart';

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
