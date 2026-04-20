/// Riverpod providers for every data-layer repository.
///
/// Phase 6 wires these to concrete Drift-backed repositories. Until
/// then each provider returns a stub instance whose methods throw
/// [UnimplementedError] — consumers can depend on the symbol so the
/// graph compiles, but any actual call fails loudly.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guardianangela/data/repositories/battery_alert_repository.dart';
import 'package:guardianangela/data/repositories/contacts_repository.dart';
import 'package:guardianangela/data/repositories/distress_chains_repository.dart';
import 'package:guardianangela/data/repositories/modes_repository.dart';
import 'package:guardianangela/data/repositories/session_logs_repository.dart';
import 'package:guardianangela/data/repositories/settings_repository.dart';
import 'package:guardianangela/data/repositories/templates_repository.dart';
import 'package:guardianangela/data/repositories/user_profile_repository.dart';

/// Modes repository provider.
final modesRepositoryProvider = Provider<ModesRepository>(
  (_) => ModesRepository(),
);

/// Contacts repository provider.
final contactsRepositoryProvider = Provider<ContactsRepository>(
  (_) => ContactsRepository(),
);

/// Templates repository provider.
final templatesRepositoryProvider = Provider<TemplatesRepository>(
  (_) => TemplatesRepository(),
);

/// Settings repository provider.
final settingsRepositoryProvider = Provider<SettingsRepository>(
  (_) => SettingsRepository(),
);

/// Distress-chains repository provider.
final distressChainsRepositoryProvider = Provider<DistressChainsRepository>(
  (_) => DistressChainsRepository(),
);

/// User-profile repository provider.
final userProfileRepositoryProvider = Provider<UserProfileRepository>(
  (_) => UserProfileRepository(),
);

/// Battery-alert repository provider.
final batteryAlertRepositoryProvider = Provider<BatteryAlertRepository>(
  (_) => BatteryAlertRepository(),
);

/// Session-logs repository provider.
final sessionLogsRepositoryProvider = Provider<SessionLogsRepository>(
  (_) => SessionLogsRepository(),
);
