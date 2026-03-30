import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'data/models/app_settings.dart';
import 'data/models/emergency_contact.dart';
import 'data/models/escalation_step.dart';
import 'data/models/fake_call_config.dart';
import 'data/models/reminder_template.dart';
import 'data/models/session_mode.dart';
import 'data/repositories/settings_repository.dart';
import 'data/seed_data.dart';
import 'router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  // Register Hive adapters
  Hive.registerAdapter(MessageChannelAdapter());
  Hive.registerAdapter(EmergencyContactAdapter());
  Hive.registerAdapter(EscalationStepTypeAdapter());
  Hive.registerAdapter(EscalationStepAdapter());
  Hive.registerAdapter(ConfirmationTypeAdapter());
  Hive.registerAdapter(ReminderTemplateAdapter());
  Hive.registerAdapter(FakeCallConfigAdapter());
  Hive.registerAdapter(CheckInMechanismAdapter());
  Hive.registerAdapter(SessionModeAdapter());
  Hive.registerAdapter(AppSettingsAdapter());

  // Seed defaults on first launch
  await seedDefaults();

  // Load settings to determine initial route
  final settingsRepo = SettingsRepository();
  final settings = await settingsRepo.getSettings();

  final router = createRouter(isFirstLaunch: settings.isFirstLaunch);

  runApp(
    ProviderScope(
      child: SafeWayHomeApp(router: router),
    ),
  );
}
