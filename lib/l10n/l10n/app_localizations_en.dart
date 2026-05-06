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
  String get angelaDialogTitle => 'Old PIN entered';

  @override
  String get angelaDialogBody =>
      'It looks like you used an old PIN. Are you sure you want to proceed?';

  @override
  String get angelaDialogCancel => 'Cancel';

  @override
  String get angelaDialogConfirm => 'Continue';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonOk => 'OK';

  @override
  String get profileAngelaWarningTitle => 'Heads up about the name \"Angela\"';

  @override
  String get profileAngelaWarningBody =>
      'Guardian Angela uses \"Angela\" as a safety keyword. Using it as your own name could be confusing. Save anyway?';

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
  String get pinSubmit => 'Submit';

  @override
  String get homeTitle => 'Guardian Angela';

  @override
  String get homeStartSession => 'Start session';

  @override
  String get homeStartConfirmTitle => 'Start a session?';

  @override
  String get homeStartConfirmBody =>
      'Make sure your contacts and PIN are configured. The session will run in the foreground and your selected mode will guide check-ins.';

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
  String get homeContactsBannerNone => 'No emergency contacts configured.';

  @override
  String homeContactsBannerFew(int count) {
    return '$count contact(s) configured. We recommend at least 3.';
  }

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
  String get sessionCheckIn => 'I\'m checked in';

  @override
  String get sessionDisarmTriggerTitle => 'Disarm trigger fired';

  @override
  String get sessionDisarmTriggerBody =>
      'A disarm trigger fired. End the session?';

  @override
  String get sessionDisarmTriggerConfirm => 'End session';

  @override
  String get sessionDisarmTriggerCancel => 'Continue';

  @override
  String get wrongPinAngelaTitle => 'Old PIN from Angela';

  @override
  String get wrongPinAngelaBody =>
      'Are you sure you want to proceed with this old PIN?';

  @override
  String get wrongPinAngelaConfirm => 'OK';

  @override
  String get wrongPinAngelaCancel => 'Cancel';

  @override
  String get sessionStepCountdownTitle => 'Warning';

  @override
  String get sessionStepCountdownBody =>
      'The next escalation fires when the countdown ends. Swipe \'I\'m safe\' below to disarm.';

  @override
  String get sessionStepDisguisedDefaultTitle => 'Reminder';

  @override
  String get sessionStepDisguisedDefaultBody =>
      'Tap \'I\'m checked in\' to confirm you\'re safe.';

  @override
  String get sessionStepSmsStatus => 'Sending message to contacts…';

  @override
  String get sessionStepSmsDelivered => 'Delivered';

  @override
  String get sessionStepSmsSent => 'Sent';

  @override
  String get sessionStepSmsQueued => 'Queued';

  @override
  String get sessionStepSmsFailed => 'Failed';

  @override
  String get sessionStepPhoneCallStatus => 'Calling emergency contact…';

  @override
  String get sessionStepPhoneCallCancel => 'Cancel call';

  @override
  String get sessionStepLoudAlarmTitle => 'Alarm playing';

  @override
  String get sessionStepLoudAlarmBody =>
      'The alarm is sounding to attract attention.';

  @override
  String get sessionStepLoudAlarmFlashWarning =>
      'Photosensitive warning: screen is flashing.';

  @override
  String get sessionStepCallEmergencyStatus => 'Calling emergency services…';

  @override
  String sessionStepCallEmergencyNumber(Object number) {
    return 'Number: $number';
  }

  @override
  String sessionStepHardwareButtonRepeat(
    Object button,
    Object count,
    Object windowMs,
  ) {
    return 'Press $button $count times within ${windowMs}ms';
  }

  @override
  String sessionStepHardwareButtonLong(Object button, Object seconds) {
    return 'Hold $button for $seconds seconds';
  }

  @override
  String get sessionStepHardwareButtonVolumeUp => 'volume up';

  @override
  String get sessionStepHardwareButtonVolumeDown => 'volume down';

  @override
  String get sessionStepHardwareButtonPower => 'power';

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
  String get fakeCallSlideToAnswer => 'slide to answer';

  @override
  String get fakeCallUnknownCaller => 'Unknown';

  @override
  String get fakeCallIncomingWhatsapp => 'WhatsApp voice call';

  @override
  String get fakeCallIncomingTelegram => 'Telegram voice call';

  @override
  String get fakeCallIncomingSignal => 'Signal voice call';

  @override
  String get fakeCallBrandWhatsapp => 'WHATSAPP';

  @override
  String get fakeCallBrandTelegram => 'TELEGRAM';

  @override
  String get fakeCallBrandSignal => 'SIGNAL';

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
  String get contactLanguageDefault => 'Default (use app language)';

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
  String get modeFieldDistressMode => 'Distress mode';

  @override
  String get modeFieldDistressModeDefault => 'Use default';

  @override
  String get modeChainHeader => 'Escalation chain';

  @override
  String get modeChainAddStep => 'Add step';

  @override
  String get modeChainEmpty => 'No steps yet. Tap Add step.';

  @override
  String get modeFieldIcon => 'Icon';

  @override
  String get modeIconPickerTitle => 'Pick an icon';

  @override
  String get modeIconClear => 'No icon';

  @override
  String get modeDistressHeader => 'Distress triggers';

  @override
  String get modeDistressEmpty => 'No distress triggers configured.';

  @override
  String get modeDistressAdd => 'Add distress trigger';

  @override
  String get modeDistressTypeHardware => 'Hardware button';

  @override
  String get modeDistressButtonType => 'Button';

  @override
  String get modeDistressButtonVolumeUp => 'Volume up';

  @override
  String get modeDistressButtonVolumeDown => 'Volume down';

  @override
  String get modeDistressButtonPower => 'Power';

  @override
  String get modeDistressPattern => 'Pattern';

  @override
  String get modeDistressPatternRepeat => 'Repeat press';

  @override
  String get modeDistressPatternLong => 'Long press';

  @override
  String get modeDistressPressCount => 'Press count';

  @override
  String get modeDistressPressWindow => 'Press window (ms)';

  @override
  String get modeDistressLongDuration => 'Hold duration (seconds)';

  @override
  String modeDistressSummaryRepeat(Object count, Object windowMs) {
    return '$count presses / $windowMs ms';
  }

  @override
  String modeDistressSummaryLong(Object seconds) {
    return 'Hold ${seconds}s';
  }

  @override
  String get modeOverridesHeader => 'Mode overrides';

  @override
  String get modeOverridesUseDefault => 'Use app default';

  @override
  String get modeOverridesGpsLabel => 'GPS logging';

  @override
  String get modeOverridesStealthLabel => 'Stealth';

  @override
  String get modeOverridesEventDefaultsLabel => 'Event defaults';

  @override
  String get modeOverridesLocalTemplatesLabel => 'Local reminder templates';

  @override
  String get modeOverridesGpsEnabled => 'GPS logging enabled';

  @override
  String get modeOverridesGpsIntervalLabel => 'Sampling interval (seconds)';

  @override
  String get modeOverridesGpsIncludeInSms => 'Append location to SMS';

  @override
  String get modeOverridesStealthEnabled => 'Stealth enabled';

  @override
  String get modeOverridesStealthFakeName => 'Fake app name';

  @override
  String get modeOverridesEventDefaultsHint =>
      'Custom event defaults active for this mode.';

  @override
  String modeOverridesLocalTemplatesCount(Object count) {
    return '$count mode-local templates';
  }

  @override
  String get modeUnsavedTitle => 'Discard changes?';

  @override
  String get modeUnsavedBody =>
      'You have unsaved changes. Discard them and leave the editor?';

  @override
  String get modeUnsavedDiscard => 'Discard';

  @override
  String get modeUnsavedKeep => 'Keep editing';

  @override
  String get stepDuplicate => 'Duplicate step';

  @override
  String get stepTimingHeader => 'Timing';

  @override
  String stepTimingSummary(Object wait, Object duration, Object grace) {
    return 'wait ${wait}s / duration ${duration}s / grace ${grace}s';
  }

  @override
  String get stepCategoryAll => 'All';

  @override
  String get stepPickerMore => 'More options...';

  @override
  String get stepCategoryAction => 'Action';

  @override
  String get stepCategoryReminder => 'Reminder';

  @override
  String get stepCategoryDisarm => 'Check-in';

  @override
  String get modeTrackingHeader => 'Tracking';

  @override
  String get modeTrackingEnabled => 'Record GPS during session';

  @override
  String get modeTrackingIntervalLabel => 'Sampling interval';

  @override
  String get modeTrackingBufferSizeLabel => 'Buffer size';

  @override
  String modeTrackingBufferSizeValue(Object count) {
    return '$count points';
  }

  @override
  String get modeTrackingBatteryNote =>
      'Frequent GPS tracking increases battery drain.';

  @override
  String get stepConfigLogGpsLabel => 'GPS logging';

  @override
  String get stepConfigLogGpsDefault => 'Default';

  @override
  String get stepConfigLogGpsOn => 'On';

  @override
  String get stepConfigLogGpsOff => 'Off';

  @override
  String get stepConfigLogGpsDefaultOn => 'Default (On)';

  @override
  String get stepConfigLogGpsDefaultOff => 'Default (Off)';

  @override
  String get moreSettingsHeader => 'More settings';

  @override
  String moreSettingsHeaderCustomized(int count) {
    return 'More settings ($count customized)';
  }

  @override
  String get stepTypePickerLabel => 'Step type';

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
  String get stepFieldRetryCount => 'Number of retries';

  @override
  String get stepFieldRandomize => 'Timing jitter';

  @override
  String get stepFieldRandomizeToggle => 'Randomize timing (±20%)';

  @override
  String get stepFieldWaitTooltip =>
      'How long to wait before this step starts.';

  @override
  String get stepFieldDurationTooltip =>
      'How long the step is active before the grace window starts.';

  @override
  String get stepFieldGraceTooltip =>
      'Time after the active phase to confirm safety before the next step fires.';

  @override
  String get stepFieldRetryCountTooltip =>
      'How many times to repeat this step before escalating.';

  @override
  String get stepFieldReminderIntervalTooltip =>
      'How often the disguised reminder fires while waiting for a check-in.';

  @override
  String get stepFieldReminderGraceTooltip =>
      'How long the user has to confirm safety after the reminder appears.';

  @override
  String get stepPreview => 'Preview in simulation';

  @override
  String stepPreviewFired(Object description) {
    return 'Preview ran: $description';
  }

  @override
  String get stepPreviewTitle => 'Step preview';

  @override
  String get stepPreviewMissingParams => 'Missing step or mode reference.';

  @override
  String get stepPreviewModeNotFound => 'Mode not found.';

  @override
  String get stepPreviewStepNotFound => 'Step not found in this mode.';

  @override
  String stepPreviewError(Object error) {
    return 'Preview failed: $error';
  }

  @override
  String get stepPreviewReplay => 'Replay';

  @override
  String get stepPreviewHoldButtonHint =>
      'Press and hold the button to feel the live response.';

  @override
  String get stepPreviewHoldButtonLabel => 'Hold';

  @override
  String get stepPreviewHoldButtonSemantic => 'Hold to preview';

  @override
  String get stepPreviewHoldButtonReleased =>
      'Released. The session would now enter the grace window.';

  @override
  String get stepPreviewFakeCallHint =>
      'The fake call screen will appear. Slide to answer or hold the red button to simulate distress.';

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
  String get stepConfigSmsAutoRecordAudio => 'Auto-record audio';

  @override
  String get stepConfigSmsAutoRecordVideo => 'Auto-record video';

  @override
  String get stepConfigSmsRecordDuration => 'Recording duration';

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
  String get stepConfigHardwarePressWindow => 'Press window (ms)';

  @override
  String get stepConfigHardwareLongDuration => 'Long-press duration (s)';

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
  String get distressModesTitle => 'Distress modes';

  @override
  String get distressModeInUseTitle => 'Distress mode is in use';

  @override
  String distressModeInUseBody(Object modes) {
    return 'This distress mode is still bound to: $modes. Rebind those modes to a different distress mode before deleting.';
  }

  @override
  String get distressModesEmpty => 'No distress modes yet.';

  @override
  String get distressModesAdd => 'Add distress mode';

  @override
  String get distressModeEditorTitleCreate => 'New distress mode';

  @override
  String get distressModeEditorTitleEdit => 'Edit distress mode';

  @override
  String get distressModeName => 'Distress mode name';

  @override
  String get distressCountdown => 'Triggering distress mode...';

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
  String get settingsSectionDistressModes => 'Distress modes';

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
  String get securityAppPinBiometric => 'Use biometrics for App PIN';

  @override
  String get securitySessionEndPinBiometric =>
      'Use biometrics for Session-end PIN';

  @override
  String get securityDistressCancelBiometric =>
      'Use biometrics to cancel distress';

  @override
  String get securityDuressTest => 'Test duress PIN';

  @override
  String get securityDuressTestSubtitle => 'Verify your duress PIN works.';

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
  String get pinEntryBiometricReason => 'Authenticate to continue';

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
  String get stealthTimerDisplay => 'Timer display';

  @override
  String get stealthTimerDisplayNormal => 'Show full text';

  @override
  String get stealthTimerDisplaySmall => 'Show numbers only';

  @override
  String get stealthTimerDisplayNone => 'Hide timer';

  @override
  String get stealthSessionScreen => 'Strip branding on session screen';

  @override
  String get stealthPickerTitle => 'App icon';

  @override
  String get stealthPickerIntro => 'Pick how the launcher icon looks.';

  @override
  String get stealthPresetMusic => 'Music';

  @override
  String get stealthPresetCalendar => 'Calendar';

  @override
  String get stealthPresetFitness => 'Fitness';

  @override
  String get stealthPresetWeather => 'Weather';

  @override
  String get stealthPresetNews => 'News';

  @override
  String get stealthPresetPhotos => 'Photos';

  @override
  String get stealthPresetNotes => 'Notes';

  @override
  String get stealthPresetClock => 'Clock';

  @override
  String get distressConfirmationTitle => 'Are you in danger?';

  @override
  String get distressConfirmationCancel => 'Cancel';

  @override
  String distressConfirmationCountdown(Object seconds) {
    return '${seconds}s until distress fires';
  }

  @override
  String get imSafeSliderLabel => 'Swipe to confirm I\'m safe';

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
  String get backupSelectionHeader => 'Include in export';

  @override
  String get backupToggleSettings => 'Settings';

  @override
  String get backupToggleSettingsSubtitle =>
      'Always included so the backup can be restored.';

  @override
  String get backupToggleContacts => 'Emergency contacts';

  @override
  String get backupToggleModes => 'Modes';

  @override
  String get backupToggleDistressModes => 'Distress modes';

  @override
  String get backupToggleTemplates => 'Reminder templates';

  @override
  String get backupToggleSessionLogs => 'Session history';

  @override
  String get backupToggleRecordings => 'Audio recordings';

  @override
  String get historyTitle => 'Past sessions';

  @override
  String get historyEmpty => 'No past sessions yet.';

  @override
  String get historyTabReal => 'Real';

  @override
  String get historyTabSimulated => 'Simulated';

  @override
  String get historySearchHint => 'Search by mode name';

  @override
  String get historyFilterModeAll => 'All modes';

  @override
  String get historyFilterModeLabel => 'Mode';

  @override
  String get historyDateRangePick => 'Date range';

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

  @override
  String emergencyConfirmTitle(Object number) {
    return 'Calling $number';
  }

  @override
  String get emergencyConfirmSubtitle => 'Hold the cancel button to abort.';

  @override
  String emergencyConfirmCountdown(Object seconds) {
    return 'Calling in ${seconds}s';
  }

  @override
  String get emergencyConfirmCancel => 'Cancel';

  @override
  String get stealthCalendarUpcoming => 'Upcoming';

  @override
  String get stealthCalendarUpcomingEvent => 'Meeting';

  @override
  String stealthCalendarUntilEvent(Object minutes) {
    return 'in $minutes min';
  }

  @override
  String get stealthCalendarToday => 'Today';

  @override
  String get stealthCalendarEvent1 => 'Coffee with Alex';

  @override
  String get stealthCalendarEvent2 => 'Standup';

  @override
  String get stealthCalendarEvent3 => 'Lunch';

  @override
  String get stealthCalendarEvent4 => 'Workout';

  @override
  String get stealthCalendarEvent5 => 'Dinner with Sam';

  @override
  String get stealthDisarmGestureHint => 'Swipe up to end';

  @override
  String get stealthMusicTrackTitle => 'Untitled Track';

  @override
  String get stealthMusicArtist => 'Unknown Artist';

  @override
  String get stealthMusicAlbum => 'Unknown Album';

  @override
  String get stealthMusicNowPlaying => 'Now playing';

  @override
  String get stealthMusicSwipeHint => 'Swipe to disarm';

  @override
  String get stealthMusicPrevious => 'Previous';

  @override
  String get stealthMusicPause => 'Pause';

  @override
  String get stealthMusicNext => 'Next';

  @override
  String get stealthPodcastShowName => 'Podcast';

  @override
  String get stealthPodcastEpisodeTitle => 'Episode';

  @override
  String get stealthPodcastEpisodesHeader => 'Episodes';

  @override
  String get stealthPodcastSpeedLabel => '1x';

  @override
  String get stealthPodcastEpisode1 => 'Episode 1';

  @override
  String get stealthPodcastEpisode2 => 'Episode 2';

  @override
  String get stealthPodcastEpisode3 => 'Episode 3';

  @override
  String get stealthPodcastEpisode4 => 'Episode 4';

  @override
  String get stealthPresetPodcast => 'Podcast';

  @override
  String get stealthPresetNone => 'None';

  @override
  String get sessionSimSpeedLabel => 'Speed';

  @override
  String sessionSimSpeedValue(Object value) {
    return '${value}x';
  }

  @override
  String get sessionSimSpeedBackgroundCap => 'Capped at 60× in background';

  @override
  String get sessionSimAdvancedLabel => 'Advanced';

  @override
  String get sessionSimTriggerPanic => 'Trigger panic';

  @override
  String get sessionSimTriggerArrival => 'Trigger arrival';

  @override
  String get sessionSimTriggerBattery => 'Trigger low battery';

  @override
  String get simulateGpsArrival => 'Simulate arrival';

  @override
  String get simulateLowBattery => 'Simulate low battery';

  @override
  String get launchGateTitle => 'Unlock Guardian Angela';

  @override
  String get launchGateSubtitle => 'Enter your PIN or use biometrics.';

  @override
  String get launchGateWrong => 'Wrong PIN';

  @override
  String get launchGateBiometricReason => 'Unlock Guardian Angela';

  @override
  String get launchGateUseBiometric => 'Use biometrics';

  @override
  String get audioRunningLatePhrase =>
      'Hi, I am running late. I will call you back soon.';

  @override
  String smsDefaultTemplate(Object name, Object location, Object time) {
    return '$name may need help. Location: $location. Time: $time.';
  }

  @override
  String smsDefaultPreCallTemplate(Object name) {
    return '$name is trying to reach you. Please expect a call.';
  }

  @override
  String simLoudAlarm(Object tail) {
    return '[SIM] Loud alarm + $tail';
  }

  @override
  String get simLoudAlarmTailFlash => 'flash';

  @override
  String get simLoudAlarmTailVibrate => 'vibrate';

  @override
  String simSmsContact(Object channel, int count) {
    return '[SIM] Would send $channel to $count contacts';
  }

  @override
  String simFakeCallRing(Object caller) {
    return '[SIM] Incoming call from $caller';
  }

  @override
  String simCountdownWarning(int seconds) {
    return '[SIM] ${seconds}s countdown warning';
  }

  @override
  String simPhoneCall(Object name) {
    return '[SIM] Would call $name';
  }

  @override
  String get simNoContactToCall => '[SIM] No contact to call';

  @override
  String simCallEmergency(Object number) {
    return '[SIM] Would dial $number';
  }

  @override
  String get simHardwareButton => '[SIM] Hardware trigger armed';

  @override
  String get simHoldButton => '[SIM] Waiting for hold button';

  @override
  String simDisguisedReminder(Object title) {
    return '[SIM] Would show \"$title\"';
  }

  @override
  String get simDisguisedReminderEmpty =>
      '[SIM] No reminder template available';

  @override
  String get simGpsArrivalTrigger => '[SIM] GPS arrival trigger fired';

  @override
  String get simLowBatteryAlert => '[SIM] Low-battery alert fired';
}
