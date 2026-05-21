/// Barrel file re-exporting all domain models, configs, and triggers.
///
/// Imported by test helpers and code that needs a single import for the
/// entire domain model layer.
library;

// Enums (via the data/models barrel for backwards compatibility with
// test_helpers.dart which imports from data/models/enums.dart)
export 'package:guardianangela/data/models/enums.dart';

// Configs
export 'package:guardianangela/domain/configs/step_config.dart';

// Triggers
export 'package:guardianangela/domain/triggers/disarm_trigger.dart';
export 'package:guardianangela/domain/triggers/distress_trigger.dart';

// Models
export 'package:guardianangela/domain/models/app_defaults.dart';
export 'package:guardianangela/domain/models/app_settings.dart';
export 'package:guardianangela/domain/models/battery_alert_config.dart';
export 'package:guardianangela/domain/models/chain_step.dart';
export 'package:guardianangela/domain/models/emergency_contact.dart';
export 'package:guardianangela/domain/models/event_defaults.dart';
export 'package:guardianangela/domain/models/gps_logging_config.dart';
export 'package:guardianangela/domain/models/mode_overrides.dart';
export 'package:guardianangela/domain/models/reminder_template.dart';
export 'package:guardianangela/domain/models/session_log.dart';
export 'package:guardianangela/domain/models/session_log_event.dart';
export 'package:guardianangela/domain/models/session_mode.dart';
export 'package:guardianangela/domain/models/stealth_config.dart';
export 'package:guardianangela/domain/models/user_profile.dart';
export 'package:guardianangela/domain/models/walk_session.dart';
