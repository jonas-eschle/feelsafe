/// Riverpod providers for the Drift-backed data layer.
///
/// The single [AppDatabase] is created lazily on first read and
/// closed when its provider is disposed. Every repository sits on
/// top of one DAO, and each DAO closes over the shared database.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:guardianangela/data/db/app_database.dart';
import 'package:guardianangela/data/db/daos/battery_alert_dao.dart';
import 'package:guardianangela/data/db/daos/contacts_dao.dart';
import 'package:guardianangela/data/db/daos/distress_chains_dao.dart';
import 'package:guardianangela/data/db/daos/modes_dao.dart';
import 'package:guardianangela/data/db/daos/session_logs_dao.dart';
import 'package:guardianangela/data/db/daos/settings_dao.dart';
import 'package:guardianangela/data/db/daos/templates_dao.dart';
import 'package:guardianangela/data/db/daos/user_profile_dao.dart';
import 'package:guardianangela/data/repositories/battery_alert_repository.dart';
import 'package:guardianangela/data/repositories/contacts_repository.dart';
import 'package:guardianangela/data/repositories/distress_chains_repository.dart';
import 'package:guardianangela/data/repositories/modes_repository.dart';
import 'package:guardianangela/data/repositories/session_logs_repository.dart';
import 'package:guardianangela/data/repositories/settings_repository.dart';
import 'package:guardianangela/data/repositories/templates_repository.dart';
import 'package:guardianangela/data/repositories/user_profile_repository.dart';

/// Singleton [AppDatabase] provider.
///
/// The instance is created on first read and closed when the
/// provider is disposed (e.g., when the app shuts down). Tests may
/// override this provider with an in-memory instance.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

/// Modes repository provider.
final modesRepositoryProvider = Provider<ModesRepository>(
  (ref) => ModesRepository(ModesDao(ref.watch(appDatabaseProvider))),
);

/// Contacts repository provider.
final contactsRepositoryProvider = Provider<ContactsRepository>(
  (ref) => ContactsRepository(ContactsDao(ref.watch(appDatabaseProvider))),
);

/// Templates repository provider.
final templatesRepositoryProvider = Provider<TemplatesRepository>(
  (ref) => TemplatesRepository(TemplatesDao(ref.watch(appDatabaseProvider))),
);

/// Settings repository provider.
final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(SettingsDao(ref.watch(appDatabaseProvider))),
);

/// Distress-chains repository provider.
final distressChainsRepositoryProvider = Provider<DistressChainsRepository>(
  (ref) => DistressChainsRepository(
    DistressChainsDao(ref.watch(appDatabaseProvider)),
  ),
);

/// User-profile repository provider.
final userProfileRepositoryProvider = Provider<UserProfileRepository>(
  (ref) =>
      UserProfileRepository(UserProfileDao(ref.watch(appDatabaseProvider))),
);

/// Battery-alert repository provider.
final batteryAlertRepositoryProvider = Provider<BatteryAlertRepository>(
  (ref) =>
      BatteryAlertRepository(BatteryAlertDao(ref.watch(appDatabaseProvider))),
);

/// Session-logs repository provider.
final sessionLogsRepositoryProvider = Provider<SessionLogsRepository>(
  (ref) =>
      SessionLogsRepository(SessionLogsDao(ref.watch(appDatabaseProvider))),
);
