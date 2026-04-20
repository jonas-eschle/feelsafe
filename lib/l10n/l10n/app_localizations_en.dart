// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Guardian Angela';

  @override
  String get commonSave => 'Save';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonAdd => 'Add';

  @override
  String get commonClose => 'Close';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonBack => 'Back';

  @override
  String get commonDone => 'Done';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonYes => 'Yes';

  @override
  String get commonNo => 'No';

  @override
  String get commonEnabled => 'Enabled';

  @override
  String get commonDisabled => 'Disabled';

  @override
  String get commonNone => 'None';

  @override
  String get commonSeconds => 'seconds';

  @override
  String get commonMinutes => 'minutes';

  @override
  String get cancel => 'Cancel';

  @override
  String get homeTitle => 'Guardian Angela';

  @override
  String get homeStartSession => 'Start session';

  @override
  String get homeSimulate => 'Simulate';

  @override
  String get homeActiveSession => 'Active session';

  @override
  String get homeResumeSession => 'Resume';

  @override
  String get homeNoModes => 'No modes yet. Tap Modes to add one.';

  @override
  String get homeNoContacts =>
      'No emergency contacts yet. Tap Contacts to add one.';

  @override
  String get homeMenuSettings => 'Settings';

  @override
  String get homeMenuContacts => 'Contacts';

  @override
  String get homeMenuModes => 'Modes';

  @override
  String get homeMenuHistory => 'Past sessions';

  @override
  String get homeSelectMode => 'Select mode';

  @override
  String get onboardingWelcomeTitle => 'Welcome to Guardian Angela';

  @override
  String get onboardingWelcomeBody =>
      'A companion that keeps you safe on the way home. Guardian Angela watches over you while you walk, run, or travel, and can alert your chosen contacts if you need help.';

  @override
  String get onboardingProfileTitle => 'Profile & first contact';

  @override
  String get onboardingProfileBody =>
      'Tell us a bit about you so Guardian Angela can share helpful details if you need emergency help. Then add one trusted contact.';

  @override
  String get onboardingPermissionsTitle => 'Permissions';

  @override
  String get onboardingPermissionsBody =>
      'Guardian Angela needs a few permissions to keep you safe. Grant them now or later from Settings.';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingFinish => 'Finish';

  @override
  String get sessionTitle => 'Session';

  @override
  String get sessionDisarm => 'I\'m safe';

  @override
  String get sessionPause => 'Pause';

  @override
  String get sessionResume => 'Resume';

  @override
  String get sessionHoldPrompt => 'Hold to stay safe';

  @override
  String get sessionHoldSemantic => 'Hold down. Lifting starts a grace period.';

  @override
  String sessionStepLabel(Object index, Object total) {
    return 'Step $index of $total';
  }

  @override
  String sessionMissCount(Object count) {
    return 'Missed: $count';
  }

  @override
  String sessionRemaining(Object seconds) {
    return '${seconds}s left';
  }

  @override
  String get sessionPausedBadge => 'Paused';

  @override
  String get sessionPhaseEnded => 'Session ended';

  @override
  String get sessionSimulationBanner => 'Simulation';

  @override
  String get sessionCompletedTitle => 'Session complete';

  @override
  String get sessionCompletedBody =>
      'You arrived safely. Guardian Angela is standing down.';

  @override
  String get sessionCompletedReturnHome => 'Return home';

  @override
  String get simulationSummaryTitle => 'Simulation summary';

  @override
  String get simulationSummaryEmpty => 'No steps fired during this simulation.';

  @override
  String get simulationSummaryReturn => 'Back to home';

  @override
  String get fakeCallTitle => 'Incoming call';

  @override
  String get fakeCallAnswer => 'Answer';

  @override
  String get fakeCallDecline => 'Decline';

  @override
  String get fakeCallHangUp => 'Hang up';

  @override
  String get contactsTitle => 'Emergency contacts';

  @override
  String get contactsEmpty =>
      'No contacts yet. Add one to receive your distress messages.';

  @override
  String get contactsAdd => 'Add contact';

  @override
  String get contactFormTitleCreate => 'New contact';

  @override
  String get contactFormTitleEdit => 'Edit contact';

  @override
  String get contactFieldName => 'Name';

  @override
  String get contactFieldPhone => 'Phone number';

  @override
  String get contactFieldRelationship => 'Relationship (optional)';

  @override
  String get contactFieldLanguage => 'SMS language (optional)';

  @override
  String get contactChannelsHeader => 'Messaging channels';

  @override
  String get contactChannelSms => 'SMS';

  @override
  String get contactChannelWhatsapp => 'WhatsApp';

  @override
  String get contactChannelTelegram => 'Telegram';

  @override
  String get contactChannelPhone => 'Phone call';

  @override
  String get contactDeleteConfirm => 'Delete contact?';

  @override
  String contactDeleteBody(Object name) {
    return '$name will be removed from your emergency list.';
  }

  @override
  String get contactRequiredError => 'Name and phone number are required.';

  @override
  String get modesTitle => 'Modes';

  @override
  String get modesEmpty => 'No modes yet. Tap Add to create a mode.';

  @override
  String get modesAdd => 'Add mode';

  @override
  String get modeEditorTitleCreate => 'New mode';

  @override
  String get modeEditorTitleEdit => 'Edit mode';

  @override
  String get modeFieldName => 'Name';

  @override
  String get modeFieldCheckInType => 'Check-in type';

  @override
  String get modeFieldDistressChain => 'Distress chain';

  @override
  String get modeFieldDistressChainDefault => 'Use default';

  @override
  String get modeChainHeader => 'Escalation chain';

  @override
  String get modeChainAddStep => 'Add step';

  @override
  String get modeChainEmpty => 'No steps yet. Tap Add step.';

  @override
  String get stepTypeHoldButton => 'Hold button';

  @override
  String get stepTypeDisguisedReminder => 'Disguised reminder';

  @override
  String get stepTypeCountdownWarning => 'Countdown warning';

  @override
  String get stepTypeFakeCall => 'Fake call';

  @override
  String get stepTypeSmsContact => 'SMS contact';

  @override
  String get stepTypePhoneCallContact => 'Phone contact';

  @override
  String get stepTypeLoudAlarm => 'Loud alarm';

  @override
  String get stepTypeCallEmergency => 'Call emergency';

  @override
  String get stepTypeHardwareButton => 'Hardware button';

  @override
  String get stepFieldDuration => 'Duration (seconds)';

  @override
  String get stepFieldGrace => 'Grace period (seconds)';

  @override
  String get stepFieldWait => 'Wait (seconds)';

  @override
  String get stepFieldRetryCount => 'Retries';

  @override
  String get stepFieldRandomize => 'Timing jitter';

  @override
  String get stepPreview => 'Preview in simulation';

  @override
  String stepPreviewFired(Object description) {
    return 'Preview ran: $description';
  }

  @override
  String get stepConfigFakeCallCaller => 'Caller name';

  @override
  String get stepConfigFakeCallDecline => 'Decline counts as disarm';

  @override
  String get stepConfigLoudAlarmFlash => 'Strobe screen';

  @override
  String get stepConfigLoudAlarmVolume => 'Max volume';

  @override
  String get stepConfigCountdownVibrate => 'Vibrate';

  @override
  String get stepConfigCountdownTone => 'Play tone';

  @override
  String get stepConfigSmsSelection => 'Recipients';

  @override
  String get stepConfigSmsAllContacts => 'All contacts';

  @override
  String get stepConfigSmsSpecific => 'Specific contacts';

  @override
  String get stepConfigSmsIncludeLocation => 'Include location';

  @override
  String get stepConfigSmsIncludeMedical => 'Include medical info';

  @override
  String get stepConfigHoldReleaseSensitivity => 'Release sensitivity (s)';

  @override
  String get stepConfigReminderInterval => 'Reminder interval (seconds)';

  @override
  String get stepConfigReminderTemplate => 'Template';

  @override
  String get stepConfigHardwarePattern => 'Pattern';

  @override
  String get stepConfigHardwarePressCount => 'Press count';

  @override
  String get stepConfigHardwareButton => 'Button';

  @override
  String get stepConfigHardwareButtonVolumeUp => 'Volume up';

  @override
  String get stepConfigHardwareButtonVolumeDown => 'Volume down';

  @override
  String get stepConfigHardwareButtonPower => 'Power';

  @override
  String get stepConfigHardwarePatternRepeat => 'Repeat press';

  @override
  String get stepConfigHardwarePatternLong => 'Long press';

  @override
  String get stepConfigEmergencyNumber => 'Emergency number override';

  @override
  String get stepConfigEmergencyConfirm => 'Confirm before calling';

  @override
  String get stepConfigPhonePreSms => 'Send pre-call SMS';

  @override
  String get distressChainsTitle => 'Distress chains';

  @override
  String get distressChainsEmpty => 'No distress chains yet.';

  @override
  String get distressChainsAdd => 'Add chain';

  @override
  String get distressChainEditorTitleCreate => 'New distress chain';

  @override
  String get distressChainEditorTitleEdit => 'Edit distress chain';

  @override
  String get distressChainName => 'Chain name';

  @override
  String get distressCountdown => 'Triggering distress chain...';

  @override
  String get distressCountdownStealth => 'Please wait...';

  @override
  String get templatesTitle => 'Reminder templates';

  @override
  String get templatesEmpty => 'No templates yet.';

  @override
  String get templatesAdd => 'Add template';

  @override
  String get templateEditorTitleCreate => 'New template';

  @override
  String get templateEditorTitleEdit => 'Edit template';

  @override
  String get templateFieldName => 'Editor name';

  @override
  String get templateFieldTitle => 'Reminder title';

  @override
  String get templateFieldBody => 'Reminder body';

  @override
  String get templateFieldConfirmationType => 'Confirmation type';

  @override
  String get templateFieldKeyword => 'Keyword';

  @override
  String get templateFieldButtonLabel => 'Button label';

  @override
  String get templateFieldDisplayStyle => 'Display style';

  @override
  String get templateConfirmTapButton => 'Tap button';

  @override
  String get templateConfirmTapWord => 'Tap word';

  @override
  String get templateConfirmSwipe => 'Swipe';

  @override
  String get templateConfirmDismiss => 'Dismiss';

  @override
  String get templateDisplayFullscreen => 'Full screen';

  @override
  String get templateDisplaySubtle => 'Subtle';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileFieldName => 'Name';

  @override
  String get profileFieldAge => 'Age';

  @override
  String get profileFieldBloodType => 'Blood type';

  @override
  String get profileFieldAllergies => 'Allergies';

  @override
  String get profileFieldMedications => 'Medications';

  @override
  String get profileFieldConditions => 'Medical conditions';

  @override
  String get profileFieldInstructions => 'Emergency instructions';

  @override
  String get profileAddItem => 'Add item';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSectionSecurity => 'Security';

  @override
  String get settingsSectionStealth => 'Stealth';

  @override
  String get settingsSectionDefaults => 'Defaults';

  @override
  String get settingsSectionHistory => 'History';

  @override
  String get settingsSectionBackup => 'Backup';

  @override
  String get settingsSectionAbout => 'About';

  @override
  String get settingsSectionFeedback => 'Feedback';

  @override
  String get settingsSectionContacts => 'Contacts';

  @override
  String get settingsSectionModes => 'Modes';

  @override
  String get settingsSectionProfile => 'Profile';

  @override
  String get settingsSectionDistressChains => 'Distress chains';

  @override
  String get settingsSectionReminderTemplates => 'Reminder templates';

  @override
  String get settingsSectionBatteryAlert => 'Battery alert';

  @override
  String get settingsSectionEventDefaults => 'Step defaults';

  @override
  String get settingsSectionGpsLogging => 'GPS logging';

  @override
  String get settingsSectionNotifications => 'Notifications';

  @override
  String get settingsSectionHistoryRetention => 'History retention';

  @override
  String get settingsSectionAppearance => 'Appearance';

  @override
  String get settingsThemeMode => 'Theme';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsEmergencyNumber => 'Emergency number';

  @override
  String get settingsAlarmDnd => 'Alarm overrides Do Not Disturb';

  @override
  String get securityTitle => 'Security';

  @override
  String get securityAppPin => 'App PIN';

  @override
  String get securitySessionEndPin => 'Session-end PIN';

  @override
  String get securityDuressPin => 'Duress PIN';

  @override
  String get securityPinTimeout => 'PIN timeout (seconds)';

  @override
  String get securityDisablePin => 'Disable';

  @override
  String get securitySetPin => 'Set PIN';

  @override
  String get securityChangePin => 'Change PIN';

  @override
  String get pinSetupTitle => 'Set PIN';

  @override
  String get pinSetupEnter => 'Enter new PIN';

  @override
  String get pinSetupConfirm => 'Confirm PIN';

  @override
  String get pinSetupMismatch => 'PINs do not match. Try again.';

  @override
  String get pinEntryTitle => 'Enter PIN';

  @override
  String get pinEntrySubtitle => 'Enter your PIN to continue.';

  @override
  String get stealthTitle => 'Stealth';

  @override
  String get stealthEnable => 'Enable stealth';

  @override
  String get stealthFakeName => 'Fake app name';

  @override
  String get stealthFakeIcon => 'Fake icon';

  @override
  String get stealthNotificationDisguise => 'Disguise notifications';

  @override
  String get stealthTimerDisplay => 'Show timer in stealth';

  @override
  String get stealthSessionScreen => 'Strip branding on session screen';

  @override
  String get batteryAlertTitle => 'Battery alert';

  @override
  String get batteryAlertEnable => 'Enable battery alert';

  @override
  String batteryAlertThreshold(Object percent) {
    return 'Threshold: $percent%';
  }

  @override
  String get eventDefaultsTitle => 'Step defaults';

  @override
  String get eventDefaultsBody =>
      'These defaults apply to any step that does not override them.';

  @override
  String get gpsLoggingTitle => 'GPS logging';

  @override
  String get gpsLoggingEnable => 'Enable GPS logging';

  @override
  String get gpsLoggingInterval => 'Sampling interval (seconds)';

  @override
  String get gpsLoggingAccuracy => 'Accuracy';

  @override
  String get gpsAccuracyLow => 'Low';

  @override
  String get gpsAccuracyMedium => 'Medium';

  @override
  String get gpsAccuracyHigh => 'High';

  @override
  String get gpsLoggingIncludeSms => 'Attach location to SMS';

  @override
  String get gpsLoggingHistoryDays => 'History retention (days)';

  @override
  String get notificationSettingsTitle => 'Notifications';

  @override
  String get notificationSettingsBody =>
      'Guardian Angela uses notifications to disguise and drive reminders.';

  @override
  String get historyRetentionTitle => 'History retention';

  @override
  String get historyRetentionBody =>
      'How long Guardian Angela keeps past session logs.';

  @override
  String historyRetentionDays(Object days) {
    return 'Retention: $days days';
  }

  @override
  String get backupTitle => 'Backup';

  @override
  String get backupExport => 'Export data';

  @override
  String get backupImport => 'Import data';

  @override
  String get backupNotReady => 'Backup is not available yet. Coming soon.';

  @override
  String get backupPinOptional => 'Optional PIN (encrypts the bundle)';

  @override
  String get backupImportOk => 'Backup imported successfully.';

  @override
  String get historyTitle => 'Past sessions';

  @override
  String get historyEmpty => 'No past sessions yet.';

  @override
  String get historyDetailTitle => 'Session details';

  @override
  String get evidenceExportTitle => 'Export evidence';

  @override
  String get evidenceExportAsText => 'Copy as text';

  @override
  String get evidenceExportAsJson => 'Copy as JSON';

  @override
  String get evidenceCopied => 'Copied to clipboard.';

  @override
  String get aboutTitle => 'About';

  @override
  String get aboutVersion => 'Version';

  @override
  String get aboutCredits => 'Built with care for people on their way home.';

  @override
  String get feedbackTitle => 'Feedback';

  @override
  String get feedbackBody => 'We would love to hear from you.';

  @override
  String get feedbackFieldMessage => 'Message';

  @override
  String get feedbackSend => 'Open email';

  @override
  String get pickerNoneLabel => '— none —';
}
