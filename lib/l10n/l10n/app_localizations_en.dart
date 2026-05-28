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
  String get homePermissionsMissingTitle => 'Some permissions are missing';

  @override
  String get homePermissionsMissingBody =>
      'The following permissions were not granted. Without them, the corresponding chain steps will fail silently:';

  @override
  String get homePermissionsContinueAnyway => 'Start anyway';

  @override
  String get homePermissionsNotification => 'Notifications';

  @override
  String get homePermissionsLocation => 'Location';

  @override
  String get homePermissionsCallPhone => 'Phone calls';

  @override
  String get homePermissionsSendSms => 'Send SMS';

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
  String get onboardingUseSimNumber => 'Use my SIM number';

  @override
  String onboardingUseSimNumberHint(Object number) {
    return '$number';
  }

  @override
  String get onboardingUseSimNumberUnsupported => 'Not available on iOS';

  @override
  String get onboardingUseSimNumberUnavailable => 'Couldn\'t read number';

  @override
  String get onboardingUseSimNumberPermissionDenied => 'Permission denied';

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
  String get fakeCallBrandAndroid => 'PHONE';

  @override
  String get fakeCallBrandIos => 'PHONE';

  @override
  String get fakeCallBrandMinimal => 'CALL';

  @override
  String get fakeCallDeclineSafeLabel => 'Decline (I\'m Safe)';

  @override
  String get fakeCallDeclineUnsafeLabel => 'Decline (Stay on alert)';

  @override
  String get fakeCallHoldForDistress => 'Hold 5s for distress';

  @override
  String fakeCallVoicePrompt(String name) {
    return 'TTS prompt: $name';
  }

  @override
  String fakeCallVibrationLabel(String pattern) {
    return 'Vibration: $pattern';
  }

  @override
  String get fakeCallVibrationPatternDefault => 'default';

  @override
  String get fakeCallSlideToAnswerHint => 'Slide to answer';

  @override
  String fakeCallActiveDuration(String mm, String ss) {
    return '$mm:$ss';
  }

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
  String get contactFormIosSmsWarning =>
      'On iOS, SMS opens the Messages app. You must tap Send manually.';

  @override
  String get modesTitle => 'Modes';

  @override
  String get modesEmpty => 'No modes yet. Tap Add to create a mode.';

  @override
  String get modesAdd => 'Add mode';

  @override
  String get modesNewPickerTitle => 'Start from';

  @override
  String get modesNewPickerBlank => 'Blank mode';

  @override
  String get modesNewPickerBlankSubtitle => 'Start with an empty chain';

  @override
  String modesNewPickerFromTemplate(String name) {
    return 'From $name';
  }

  @override
  String get modesNewPickerFromTemplateSubtitle =>
      'Copy this mode\'s chain and triggers';

  @override
  String modesNewPickerCopyName(String name) {
    return 'Copy of $name';
  }

  @override
  String get modesNewPickerBuiltinBadge => 'Built-in';

  @override
  String get modeEditorTitleCreate => 'New mode';

  @override
  String get modeEditorTitleEdit => 'Edit mode';

  @override
  String get modeFieldName => 'Name';

  @override
  String get modeFieldDistressMode => 'Distress mode';

  @override
  String get modeFieldDistressModeDefault => 'Use default';

  @override
  String get modeChainHeader => 'Chain';

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
  String get templatesEmpty => 'No templates yet';

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
  String get settingsLanguagePicker => 'Language';

  @override
  String get settingsEmergencyNumberLabel => 'Emergency number';

  @override
  String get settingsRedoOnboardingActiveSessionTooltip =>
      'Cannot redo onboarding during an active session';

  @override
  String get settingsEmergencyNumberCountryPickerTitle =>
      'Choose emergency number';

  @override
  String get settingsEmergencyNumberHint => 'e.g., 112';

  @override
  String get settingsEmergencyNumberSave => 'Save';

  @override
  String get settingsRedoOnboarding => 'Redo onboarding';

  @override
  String get settingsRedoOnboardingConfirm =>
      'This will reset your setup. Continue?';

  @override
  String get settingsRedoOnboardingBody =>
      'Your current configuration is preserved.';

  @override
  String get settingsRedoOnboardingProceed => 'Restart';

  @override
  String get settingsAlarmGradualVolume => 'Gradual alarm volume';

  @override
  String settingsAlarmGradualVolumeDuration(int seconds) {
    return 'Ramp duration: ${seconds}s';
  }

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
  String get pinSetupMismatch => 'PINs don\'t match. Try again.';

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
  String get stealthTimerDisplayNormal => 'Normal';

  @override
  String get stealthTimerDisplaySmall => 'Small (corner)';

  @override
  String get stealthTimerDisplayNone => 'Hidden';

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
  String get eventDefaultsTitle => 'Event defaults';

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
  String get historyRetentionTitle => 'History & retention';

  @override
  String get historyRetentionBody =>
      'How long Guardian Angela keeps past session logs.';

  @override
  String historyRetentionDays(Object days) {
    return 'Retention: $days days';
  }

  @override
  String get backupTitle => 'Backup & restore';

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
  String aboutVersion(Object version) {
    return 'Version: $version';
  }

  @override
  String get aboutCredits => 'Built with care for people on their way home.';

  @override
  String get feedbackTitle => 'Send feedback';

  @override
  String get feedbackBody => 'We would love to hear from you.';

  @override
  String get feedbackFieldMessage => 'Message';

  @override
  String get feedbackSend => 'Send';

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
  String get stealthLockTaskLabel => 'Pin app during session';

  @override
  String get stealthLockTaskSubtitle =>
      'Prevents leaving the app while a session is running. On Android this engages screen-pinning; on other platforms this is a no-op.';

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

  @override
  String get homeTagline => 'Your angel\'s got your back.';

  @override
  String get homeSafetyChecklistTitle => 'Safety setup';

  @override
  String get homeSafetyChecklistDismiss => 'Dismiss checklist';

  @override
  String get homeSafetyChecklistContact => 'Add an emergency contact';

  @override
  String get homeSafetyChecklistPin => 'Set a session-end PIN';

  @override
  String get homeSafetyChecklistStealth => 'Configure stealth mode';

  @override
  String get homeSafetyChecklistSimulation => 'Test a simulation';

  @override
  String get homeSafetyChecklistMode => 'Customize a safety mode';

  @override
  String get homeSafetyChecklistPermissions => 'Grant required permissions';

  @override
  String homeSafetyChecklistProgress(int done, int total) {
    return '$done of $total done';
  }

  @override
  String get onboardingWelcomeGreeting => 'Hi, I\'m Angela';

  @override
  String get onboardingWelcomeBodyFull =>
      'I\'m your personal guardian. I walk with you, watch over your evening out, and take action if something feels wrong.';

  @override
  String get onboardingGetStarted => 'Get started';

  @override
  String get onboardingProfileNameLabel => 'Name';

  @override
  String get onboardingProfilePhoneLabel => 'Phone number';

  @override
  String get onboardingProfilePhoneHelper => 'Included in emergency messages.';

  @override
  String get onboardingProfileUseSimNumber => 'Use my SIM number';

  @override
  String get onboardingProfileUseSimUnsupported =>
      'Not available on this platform; please enter manually.';

  @override
  String get onboardingEmergencyContactHeader => 'Emergency contact';

  @override
  String get onboardingEmergencyContactPrompt =>
      'Who should we contact if something goes wrong?';

  @override
  String get onboardingEmergencyContactNoneAdded => 'No contact added yet';

  @override
  String get onboardingEmergencyContactAdd => 'Add emergency contact';

  @override
  String get onboardingPermissionsIntro =>
      'These permissions keep you safe during sessions.';

  @override
  String get onboardingPermissionsGrantAll => 'Grant all';

  @override
  String get onboardingPermissionsAllGranted => 'All granted';

  @override
  String get onboardingPermissionsGrant => 'Grant';

  @override
  String get onboardingPermissionsOpenSettings => 'Open settings';

  @override
  String get onboardingPermissionsRequired => 'REQUIRED';

  @override
  String get onboardingPermissionsOptional => 'OPTIONAL';

  @override
  String get onboardingPermissionsMicrophone => 'Microphone';

  @override
  String get onboardingPermissionsCamera => 'Camera';

  @override
  String get onboardingPermissionsNotificationDesc =>
      'Required for session alerts and reminders.';

  @override
  String get onboardingPermissionsSmsDesc =>
      'Required to send emergency text alerts.';

  @override
  String get onboardingPermissionsPhoneDesc =>
      'Required to make emergency and fake calls.';

  @override
  String get onboardingPermissionsLocationDesc =>
      'Included in emergency messages when GPS logging is on.';

  @override
  String get onboardingPermissionsMicrophoneDesc =>
      'Used for audio recording during distress.';

  @override
  String get onboardingPermissionsCameraDesc => 'Used for flash SOS signaling.';

  @override
  String get sessionInterruptedTitle => 'Session interrupted';

  @override
  String get sessionInterruptedBody =>
      'A session was running when the app stopped. The session state is gone — nothing was restored. We\'re showing this so you know.';

  @override
  String get sessionInterruptedStartSameMode => 'Start same mode';

  @override
  String get sessionInterruptedAcknowledge => 'Acknowledge';

  @override
  String sessionInterruptedMode(Object name) {
    return 'Mode: $name';
  }

  @override
  String sessionInterruptedStarted(Object time) {
    return 'Started: $time';
  }

  @override
  String get sessionGpsDestinationTitle => 'Destination';

  @override
  String get sessionGpsDestinationBody =>
      'Enter the destination coordinates for the GPS arrival disarm trigger.';

  @override
  String get sessionGpsDestinationLat => 'Latitude';

  @override
  String get sessionGpsDestinationLng => 'Longitude';

  @override
  String get sessionGpsDestinationUseCurrent => 'Use current location';

  @override
  String get sessionGpsDestinationSkip => 'Skip for this session';

  @override
  String get sessionGpsDestinationConfirm => 'Use destination';

  @override
  String get sessionStartChainSummary => 'Chain summary';

  @override
  String get sessionEndConfirmTitle => 'End session?';

  @override
  String get sessionEndConfirmSwipe =>
      'Swipe to confirm you want to end the session';

  @override
  String get sessionEndOverlayTitle => 'End session?';

  @override
  String get sessionEndOverlayBody =>
      'Swipe to confirm you want to end the session';

  @override
  String get sessionEndOverlaySwipeLabel => 'Swipe to end';

  @override
  String get sessionEndOverlaySimBadge => '[SIM] Practice mode';

  @override
  String get sessionEndPinPromptTitle => 'Enter Session End PIN';

  @override
  String get sessionEndPinAppPinMismatch =>
      'Use the Session End PIN, not the app lock PIN.';

  @override
  String get sessionEndPinIncorrect => 'Incorrect PIN';

  @override
  String get sessionEndPinSimSkip => 'Skip (sim only)';

  @override
  String get sessionEndSimDistressWouldFire =>
      'Distress chain would fire (5 wrong PINs)';

  @override
  String get sessionEmergencyDisarmTitle => 'Are you sure?';

  @override
  String get sessionEmergencyDisarmBody =>
      'The emergency call will NOT be made if you disarm now.';

  @override
  String get sessionEmergencyDisarmCancel => 'Cancel (keep disarming)';

  @override
  String get sessionEmergencyDisarmGoBack => 'Go back (keep session)';

  @override
  String get distressConfirmTitle => 'Distress activated';

  @override
  String distressConfirmCountdown(int seconds) {
    return 'Tap to cancel — you have $seconds seconds';
  }

  @override
  String get distressConfirmCancel => 'Tap to cancel';

  @override
  String get distressConfirmFooter =>
      'If not cancelled, distress chain will begin immediately.';

  @override
  String get simulationPinPromptTitle => 'Enter PIN';

  @override
  String get simulationPinPromptBody =>
      'Practice entering your Session End PIN';

  @override
  String get simulationPinPromptSkip => 'Skip';

  @override
  String get simulationPinIncorrect => 'Incorrect PIN';

  @override
  String simulationSummaryDuration(String duration) {
    return 'Duration: $duration';
  }

  @override
  String get simulationSummaryTimelineHeader => 'Event timeline';

  @override
  String get simulationSummaryShare => 'Share';

  @override
  String simulationSummaryMissedEventsBadge(int count) {
    return 'Missed: $count';
  }

  @override
  String simulationSummaryDistressBadge(int count) {
    return 'Distress: $count';
  }

  @override
  String simulationSummaryStepsFiredBadge(int count) {
    return 'Steps fired: $count';
  }

  @override
  String get simulationSummaryShareSubject =>
      'Guardian Angela simulation summary';

  @override
  String get notificationsChannelAlarm => 'Alarm escalation';

  @override
  String get notificationsChannelAlarmDescription =>
      'Critical alerts that bypass DND';

  @override
  String get notificationsChannelReminder => 'Disguised reminder';

  @override
  String get notificationsChannelReminderDescription =>
      'Check-in reminders during active session';

  @override
  String get notificationsChannelFakeCall => 'Fake call';

  @override
  String get notificationsChannelFakeCallDescription =>
      'Full-screen incoming-call notifications';

  @override
  String get notificationsChannelEnabled => 'Enabled';

  @override
  String get notificationsChannelDisabled => 'Disabled';

  @override
  String get notificationsChannelsHeader => 'Notification channels';

  @override
  String get contactsImportFromDevice => 'Import from contacts';

  @override
  String get contactsImportNotSupported => 'Not available on this platform';

  @override
  String get contactsImportPermissionDenied =>
      'Contact access denied. Enable in system settings.';

  @override
  String get contactsDeleteAllMenu => 'Delete all';

  @override
  String get contactsDeleteAllConfirmTitle => 'Delete all contacts?';

  @override
  String get contactsDeleteAllConfirmBody =>
      'This removes every emergency contact. There is no undo.';

  @override
  String get contactsDeleteAllTypeConfirmTitle => 'Confirm by typing';

  @override
  String get contactsDeleteAllTypeConfirmHint => 'Type DELETE ALL to continue';

  @override
  String get contactsDeleteAllTypeConfirmSentinel => 'DELETE ALL';

  @override
  String get contactsDeleteAllConfirmButton => 'Delete all';

  @override
  String get contactsReorderHint => 'Drag to reorder';

  @override
  String get modesBuiltinBadge => 'Built-in';

  @override
  String get modesBuiltinNoDelete => 'Built-in modes cannot be deleted';

  @override
  String get sessionCompletedSimulationBanner => 'Simulation completed';

  @override
  String get sessionCompletedViewEventLog => 'View event log';

  @override
  String get settingsGeneralHeader => 'General';

  @override
  String get settingsAppHeader => 'App';

  @override
  String get settingsConfigurationHeader => 'Configuration';

  @override
  String get settingsThemeLabel => 'Theme';

  @override
  String get settingsLanguageLabel => 'Language';

  @override
  String get settingsSessionLockedBlocker => 'End your session first.';

  @override
  String get settingsSecurityRow => 'Security';

  @override
  String get settingsSecuritySubtitle => 'App PIN, Session End PIN, Duress PIN';

  @override
  String get settingsStealthRow => 'Stealth';

  @override
  String get settingsStealthSummaryOff => 'Stealth: OFF';

  @override
  String get settingsStealthSummaryOn => 'Stealth: ON';

  @override
  String get settingsProfileRow => 'Profile';

  @override
  String get settingsModesRow => 'Modes';

  @override
  String get settingsDistressModesRow => 'Distress modes';

  @override
  String get settingsBatteryAlertRow => 'Battery alert';

  @override
  String get settingsEventDefaultsRow => 'Event defaults';

  @override
  String get settingsGpsLoggingRow => 'GPS logging';

  @override
  String get settingsRemindersRow => 'Reminder templates';

  @override
  String get settingsNotificationsRow => 'Notifications';

  @override
  String get settingsHistoryRetentionRow => 'History & retention';

  @override
  String get settingsAboutRow => 'About';

  @override
  String get settingsFeedbackRow => 'Send feedback';

  @override
  String get settingsBackupRow => 'Backup & restore';

  @override
  String get settingsOssLicenses => 'Open source licenses';

  @override
  String get settingsExport => 'Export settings';

  @override
  String get settingsImport => 'Import settings';

  @override
  String get settingsImportConfirmBody =>
      'This will overwrite all current data. Continue?';

  @override
  String get securityAppPinTitle => 'App PIN';

  @override
  String get securityAppPinBody => 'Locks the app each time you open it.';

  @override
  String get securitySessionEndPinTitle => 'Session End PIN';

  @override
  String get securitySessionEndPinBody =>
      'Required to disarm or end a running session.';

  @override
  String get securityDuressPinTitle => 'Duress PIN';

  @override
  String get securityDuressPinBody =>
      'Entered at any prompt to silently fire the distress chain.';

  @override
  String get securityRemovePin => 'Remove';

  @override
  String get securityBiometricToggle => 'Allow biometric';

  @override
  String get securityWhatIsThis => 'What is this?';

  @override
  String get securityAppPinInfo =>
      'Locks the app when you open it. The keypad appears before any screen. Useful if someone briefly handles your unlocked phone.';

  @override
  String get securitySessionEndPinInfo =>
      'Required to disarm or end a running safety session. Without it, an attacker who takes your phone cannot stop the chain. Set a different code from your App PIN.';

  @override
  String get securityDuressPinInfo =>
      'If you ever enter this PIN at any prompt, the distress chain runs silently — your contacts get alerted and the alarm primes without the attacker noticing. Pick a code different from every other PIN.';

  @override
  String get securityPinTimeoutLabel => 'PIN timeout (seconds)';

  @override
  String get securityWrongPinThresholdLabel =>
      'Wrong PIN attempts before escalation';

  @override
  String get securityDeceptiveDialogToggle =>
      'Show deceptive dialog on wrong PIN';

  @override
  String get pinSetupEnterNew => 'Enter new PIN';

  @override
  String get pinSetupConfirmNew => 'Confirm new PIN';

  @override
  String get pinSetupTooShort => 'PIN must be at least 4 digits.';

  @override
  String get pinSetupCollision =>
      'This PIN conflicts with another configured PIN.';

  @override
  String get pinSetupSaved => 'PIN saved';

  @override
  String get stealthEnabledLabel => 'Enable stealth';

  @override
  String get stealthFakeNameLabel => 'Fake app name';

  @override
  String get stealthFakeIconLabel => 'Fake icon';

  @override
  String get stealthNotificationDisguiseLabel => 'Notification disguise';

  @override
  String get stealthTimerDisplayLabel => 'Timer display';

  @override
  String get stealthSessionScreenLabel => 'Session screen stealth';

  @override
  String get gpsLoggingEnabled => 'Log GPS during sessions';

  @override
  String get gpsLoggingIntervalLabel => 'Interval';

  @override
  String get gpsLoggingAccuracyLabel => 'Accuracy';

  @override
  String get gpsLoggingAccuracyHigh => 'High';

  @override
  String get gpsLoggingAccuracyBalanced => 'Balanced';

  @override
  String get gpsLoggingAccuracyLow => 'Low';

  @override
  String get gpsLoggingFormatLabel => 'Coordinate format';

  @override
  String get gpsLoggingFormatDecimal => 'Decimal';

  @override
  String get gpsLoggingFormatDms => 'DMS';

  @override
  String get gpsLoggingFormatAddress => 'Plus Code';

  @override
  String get gpsLoggingIncludeInSms => 'Append location to SMS';

  @override
  String get gpsLoggingHistoryRetentionLabel => 'History retention (days)';

  @override
  String get historyRetentionLogsLabel => 'Session log retention (days)';

  @override
  String get historyRetentionLogsHelper =>
      'Logs older than this move into the trash.';

  @override
  String get historyRetentionTrashLabel => 'Trash retention (days)';

  @override
  String get historyRetentionTrashHelper =>
      'Trashed logs are permanently deleted after this window.';

  @override
  String get historyRetentionUpdated => 'Retention updated';

  @override
  String get historyRetentionPurgeNow => 'Purge now';

  @override
  String historyRetentionPurged(Object count) {
    return 'Purged $count logs';
  }

  @override
  String get batteryAlertEnableLabel => 'Enable battery alert';

  @override
  String get batteryAlertThresholdLabel => 'Battery threshold (%)';

  @override
  String get batteryAlertChainHeader => 'Alert chain';

  @override
  String get batteryAlertResetChain => 'Reset';

  @override
  String get eventDefaultsCheckInHeader => 'Check-in methods';

  @override
  String get eventDefaultsEscalationHeader => 'Escalation steps';

  @override
  String get eventDefaultsPanicHeader => 'Panic trigger';

  @override
  String get templatesCreate => 'Create template';

  @override
  String get templatesFromTemplateSheet => 'From template';

  @override
  String get templatesFromScratchSheet => 'From scratch';

  @override
  String get templatesEditTitle => 'Edit template';

  @override
  String get templatesCreateTitle => 'New template';

  @override
  String get templatesNameLabel => 'Name';

  @override
  String get templatesTitleLabel => 'Title';

  @override
  String get templatesBodyLabel => 'Body';

  @override
  String get templatesBuiltinNoDelete => 'Built-in templates cannot be deleted';

  @override
  String get templatesAddFromTemplate => 'From template';

  @override
  String get templatesAddFromScratch => 'From scratch';

  @override
  String templatesDeleteConfirmTitle(Object name) {
    return 'Delete \"$name\"?';
  }

  @override
  String get templatesDeleteConfirmBody =>
      'This template will be removed permanently.';

  @override
  String get templatesEmptyAddFirst => 'Add your first template';

  @override
  String get templatesPickFromBuiltinTitle => 'Pick a built-in template';

  @override
  String get templatesIconLabel => 'Icon';

  @override
  String get templatesIconCalendar => 'Calendar';

  @override
  String get templatesIconAppNotification => 'App notification';

  @override
  String get templatesIconFitness => 'Fitness';

  @override
  String get templatesIconHealth => 'Health';

  @override
  String get templatesIconFood => 'Food';

  @override
  String get templatesIconCoffee => 'Coffee';

  @override
  String get templatesIconBattery => 'Battery';

  @override
  String get templatesIconWeather => 'Weather';

  @override
  String get templatesPreviewHeading => 'Live preview';

  @override
  String get templatesDiscardChangesTitle => 'Discard changes?';

  @override
  String get templatesDiscardChangesBody => 'Unsaved edits will be lost.';

  @override
  String get templatesDiscardKeep => 'Keep editing';

  @override
  String get templatesDiscardDiscard => 'Discard';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsStatusGranted => 'Granted';

  @override
  String get notificationsStatusDenied => 'Denied';

  @override
  String get notificationsStatusUnknown => 'Not yet asked';

  @override
  String get notificationsRequest => 'Request permission';

  @override
  String get notificationsOpenSettings => 'Open system settings';

  @override
  String get profileFieldPhone => 'Phone number';

  @override
  String get profileFieldDescription => 'Physical description';

  @override
  String get profileFieldMedicalConditions => 'Medical conditions';

  @override
  String get profileFieldEmergencyInstructions => 'Emergency instructions';

  @override
  String get profilePhotoLabel => 'Photo';

  @override
  String get profileSaved => 'Profile saved';

  @override
  String get aboutAuthor => 'Author: Jonas Eschle';

  @override
  String get aboutEmail => 'guardian.angela.app@gmail.com';

  @override
  String get aboutPrivacyPolicy => 'Privacy policy';

  @override
  String get aboutTermsOfService => 'Terms of service';

  @override
  String get aboutSourceCode => 'Source code';

  @override
  String get aboutSupport => 'Support / donate';

  @override
  String get aboutLicenses => 'Open source licenses';

  @override
  String get aboutTagline => 'Made with love for LGBTQ+ safety.';

  @override
  String get aboutTechnicalSection => 'Technical information';

  @override
  String aboutBundleId(Object id) {
    return 'Bundle ID: $id';
  }

  @override
  String aboutPlatforms(Object list) {
    return 'Platforms: $list';
  }

  @override
  String get feedbackHeading => 'We\'d love to hear from you';

  @override
  String get feedbackCategoryLabel => 'Category';

  @override
  String get feedbackCategoryBug => 'Bug report';

  @override
  String get feedbackCategoryFeature => 'Feature request';

  @override
  String get feedbackCategoryOther => 'Other';

  @override
  String get feedbackEmailLabel => 'Email (optional)';

  @override
  String get feedbackMessageLabel => 'Message';

  @override
  String get feedbackIncludeLog => 'Include last session log';

  @override
  String get feedbackSent => 'Thanks for your feedback!';

  @override
  String get feedbackMessageRequired =>
      'Message must be at least 10 characters.';

  @override
  String get backupIncludeLogs => 'Include session logs';

  @override
  String get backupIncludeMedia => 'Include media';

  @override
  String get backupExportButton => 'Export';

  @override
  String get backupImportButton => 'Import';

  @override
  String get backupOverwriteWarning => 'Importing overwrites all current data.';

  @override
  String get backupImportSuccess => 'Import complete. Restart to apply.';

  @override
  String backupImportError(Object message) {
    return 'Import failed: $message';
  }

  @override
  String get backupActiveSessionBanner =>
      'Backup is unavailable during an active session.';

  @override
  String backupLastBackupAtLabel(Object when) {
    return 'Last backup at $when';
  }

  @override
  String get backupNeverExportedLabel => 'No backup yet';

  @override
  String get pastEventsTitle => 'Past sessions';

  @override
  String get pastEventsTabReal => 'Real';

  @override
  String get pastEventsTabSimulated => 'Simulated';

  @override
  String get pastEventsEmpty => 'No sessions yet';

  @override
  String get pastEventsSearch => 'Search by mode name';

  @override
  String get pastEventsDeleteConfirm => 'Delete session log?';

  @override
  String get pastEventsDetailShareText => 'Share as text';

  @override
  String get pastEventsDetailSharePdf => 'Share as PDF';

  @override
  String get pastEventsDetailDelete => 'Delete';

  @override
  String get pastEventsOutcomeCompleted => 'Completed';

  @override
  String get pastEventsOutcomeDistress => 'Distress';

  @override
  String get pastEventsOutcomeInterrupted => 'Interrupted';

  @override
  String get pastEventsDeleteAll => 'Delete all';

  @override
  String get pastEventsTrash => 'Trash';

  @override
  String get pastEventsUndo => 'Undo';

  @override
  String get pastEventsSoftDeleted => 'Moved to trash';

  @override
  String get pastEventsDetailTitle => 'Session log';

  @override
  String get pastEventsDetailShare => 'Share';

  @override
  String get contactImportFromDevice => 'Import from contacts';

  @override
  String get contactImportPermissionDenied =>
      'Permission denied — open Settings to enable.';

  @override
  String get contactUnsavedDiscardTitle => 'Discard unsaved changes?';

  @override
  String get contactUnsavedDiscardKeep => 'Keep editing';

  @override
  String get contactUnsavedDiscardDiscard => 'Discard';

  @override
  String get modesNewModeChoiceTitle => 'New mode';

  @override
  String get modesDuplicate => 'Duplicate';

  @override
  String get modesDeleteConfirmTitle => 'Delete mode?';

  @override
  String modesDeleteConfirmBody(Object name) {
    return '$name will be permanently removed.';
  }

  @override
  String get modesDistressDefaultBadge => 'Default';

  @override
  String get modesDistressSetDefault => 'Set as default';

  @override
  String get modesDistressCantDeleteLast =>
      'At least one distress mode is required.';

  @override
  String get modesDistressInUse =>
      'This distress mode is in use by another mode.';

  @override
  String get modesDistressTitle => 'Distress modes';

  @override
  String get modesAllowDisarmAsDistress =>
      'Allow disarm while active as distress';

  @override
  String get quickExitTitle => 'Quick exit';

  @override
  String get quickExitBody => 'Session data will be preserved and encrypted.';

  @override
  String get quickExitConfirm => 'Exit';

  @override
  String get validationNameRequired => 'Name is required.';

  @override
  String get validationNameTooShort => 'Name must be at least 2 characters.';

  @override
  String get validationPhoneRequired => 'Phone number is required.';

  @override
  String get validationChannelsRequired => 'Select at least one channel.';

  @override
  String get sessionHoldTouchToBegin => 'Touch to begin';

  @override
  String sessionHoldReleaseCountdown(Object seconds) {
    return 'Countdown: ${seconds}s';
  }

  @override
  String sessionHoldGraceCountdown(Object seconds) {
    return 'Grace: ${seconds}s — re-hold to stay safe';
  }

  @override
  String get sessionHoldAgain => 'Hold again to stay safe';

  @override
  String get sessionEscalating => 'Escalating…';

  @override
  String get sessionDisarmedToast => 'Disarmed — chain reset to step 1.';

  @override
  String sessionStepNextCheckIn(Object time) {
    return 'Next check-in in $time';
  }

  @override
  String sessionStepGraceCountdown(Object time) {
    return 'Grace period: $time';
  }

  @override
  String sessionStepFakeCallActive(Object caller) {
    return 'Incoming call from $caller';
  }

  @override
  String get sessionStepFakeCallOpen => 'Open call screen';

  @override
  String sessionStepSimBlockedSms(Object count) {
    return '[SIM] Would send SMS to $count contacts';
  }

  @override
  String get sessionStepSimBlockedPhone => '[SIM] Would call emergency contact';

  @override
  String get sessionStepSimBlockedEmergency =>
      '[SIM] Would call emergency services';

  @override
  String get sessionStepSimBlockedAlarm =>
      '[SIM] Alarm would have sounded at full volume';

  @override
  String get sessionStartFailedTitle => 'Cannot start session';

  @override
  String get sessionStartFailedBody =>
      'Fix the following issues before starting:';

  @override
  String get sessionQuickExitTitle => 'Quick exit';

  @override
  String get sessionQuickExitBody =>
      'Session data will be preserved and encrypted. Reopen the app any time to recover it.';

  @override
  String get sessionQuickExitConfirm => 'Exit app';

  @override
  String get sessionStealthMusicTrack => 'Now playing';

  @override
  String get sessionStealthMusicArtist => 'Various artists';

  @override
  String get homeStartingSession => 'Starting session…';

  @override
  String get pastEventsRestore => 'Restore';

  @override
  String get batteryAlertAddStep => 'Add step';

  @override
  String batteryAlertForbiddenStep(Object type) {
    return '$type is not allowed in the battery-alert chain.';
  }

  @override
  String get stepEditorWait => 'Wait (s)';

  @override
  String get stepEditorDuration => 'Duration (s)';

  @override
  String get stepEditorGrace => 'Grace (s)';

  @override
  String get stepEditorRetryCount => 'Retry count';

  @override
  String get stepEditorRandomize => 'Randomize timing (±20%)';

  @override
  String get stepEditorRemove => 'Remove step';

  @override
  String get eventDefaultsSavedToast => 'Saved';

  @override
  String get eventDefaultsHoldStyle => 'Hold style';

  @override
  String get eventDefaultsHoldSensitivity => 'Release sensitivity';

  @override
  String get eventDefaultsHoldVibrate => 'Vibrate on release';

  @override
  String get eventDefaultsHoldSound => 'Sound on release';

  @override
  String get eventDefaultsBlackScreen => 'Black screen overlay';

  @override
  String get eventDefaultsReminderRandomInterval => 'Randomize interval';

  @override
  String get eventDefaultsReminderRandomTemplate => 'Randomize template order';

  @override
  String get eventDefaultsReminderResetOnEarly => 'Reset on early check-in';

  @override
  String get eventDefaultsCountdownStyle => 'Countdown style';

  @override
  String get eventDefaultsCountdownVibrate => 'Vibrate';

  @override
  String get eventDefaultsCountdownSound => 'Sound';

  @override
  String get eventDefaultsFakeCallStyle => 'Call style';

  @override
  String get eventDefaultsFakeCallCallerName => 'Caller name';

  @override
  String get eventDefaultsFakeCallRingDuration => 'Ring duration (s)';

  @override
  String get eventDefaultsFakeCallDeclineIsSafe => 'Decline counts as safe';

  @override
  String get eventDefaultsFakeCallVoiceOutput => 'Voice output';

  @override
  String get eventDefaultsSmsChannel => 'Channel';

  @override
  String get eventDefaultsSmsIncludeLocation => 'Include location';

  @override
  String get eventDefaultsSmsIncludeMedical => 'Include medical info';

  @override
  String get eventDefaultsSmsAutoRecord => 'Record audio before sending';

  @override
  String get eventDefaultsSmsRecordDuration => 'Recording duration (s)';

  @override
  String get eventDefaultsLoudAlarmVolume => 'Volume';

  @override
  String get eventDefaultsLoudAlarmSound => 'Sound';

  @override
  String get eventDefaultsLoudAlarmFlashScreen => 'Flash screen';

  @override
  String get eventDefaultsLoudAlarmFlashLight => 'Flash camera light';

  @override
  String get eventDefaultsLoudAlarmGradual => 'Gradual volume ramp';

  @override
  String get eventDefaultsCallEmergencyNumber => 'Emergency number (override)';

  @override
  String get eventDefaultsCallEmergencyConfirm => 'Show confirmation countdown';

  @override
  String get eventDefaultsCallEmergencyConfirmDuration =>
      'Confirmation seconds';

  @override
  String get eventDefaultsCallEmergencySmsFirst => 'Send location SMS first';

  @override
  String get eventDefaultsPhonePrimaryContact => 'Primary contact (id)';

  @override
  String get eventDefaultsHardwareButton => 'Button';

  @override
  String get eventDefaultsHardwarePattern => 'Press pattern';

  @override
  String get eventDefaultsHardwarePressCount => 'Press count';

  @override
  String get eventDefaultsHardwareLongDuration => 'Long-press duration (s)';

  @override
  String get pastEventsTrashTitle => 'Trash';

  @override
  String get pastEventsTrashEmpty => 'Trash is empty';

  @override
  String get pastEventsTrashEmptyAll => 'Empty trash';

  @override
  String get pastEventsTrashEmptyAllConfirmTitle => 'Empty trash?';

  @override
  String get pastEventsTrashEmptyAllConfirmBody =>
      'Type EMPTY TRASH below to confirm. This deletes every trashed log permanently.';

  @override
  String pastEventsTrashEmptyAllSuccess(Object count) {
    return 'Trash emptied ($count logs)';
  }

  @override
  String pastEventsTrashRetentionNote(int days) {
    return 'Logs in the trash are permanently deleted after $days days.';
  }

  @override
  String pastEventsTrashRemainingDays(int days) {
    return '$days day(s) until permanent deletion';
  }

  @override
  String get pastEventsTrashDeletePermanently => 'Delete permanently';

  @override
  String get pastEventsTrashDeletePermanentlyBody =>
      'This action cannot be undone.';

  @override
  String sessionEmergencyConfirmTitle(String number, int seconds) {
    return 'Calling $number in ${seconds}s';
  }

  @override
  String get sessionEmergencyConfirmSwipe => 'Swipe to cancel';

  @override
  String get sessionEmergencyConfirmKeep => 'Keep calling';

  @override
  String get sessionEmergencyConfirmSimBadge => '[SIM] Practice mode';

  @override
  String get sessionEmergencyConfirmSimCancelled =>
      'Simulated cancel — call would not have been placed';

  @override
  String get swipeSliderSemantics => 'Swipe to confirm';
}
