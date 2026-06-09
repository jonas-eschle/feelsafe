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
  String get commonDelete => 'Delete';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonGotIt => 'Got it';

  @override
  String get commonClose => 'Close';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonBack => 'Back';

  @override
  String get pinSubmit => 'Submit';

  @override
  String get homeTitle => 'Guardian Angela';

  @override
  String get homeStartSession => 'Start session';

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
  String get homeNoModes => 'No modes yet. Tap Modes to add one.';

  @override
  String get homeContactsBannerNone => 'No emergency contacts configured.';

  @override
  String get homeMenuSettings => 'Settings';

  @override
  String get homeMenuContacts => 'Contacts';

  @override
  String get homeMenuHistory => 'Past sessions';

  @override
  String get onboardingProfileTitle => 'Profile & first contact';

  @override
  String get onboardingPermissionsTitle => 'Permissions';

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
  String get sessionTitle => 'Session';

  @override
  String get sessionDisarm => 'I\'m safe';

  @override
  String get sessionDisarmStealth => 'No Angela needed';

  @override
  String get homeChainSummaryTitle => 'Chain Summary';

  @override
  String get homeChainSummaryEmpty =>
      'This mode has no steps yet — tap the mode to edit.';

  @override
  String homeChainSummaryTimingTitle(Object name) {
    return 'Step: $name';
  }

  @override
  String homeChainSummaryWait(Object seconds) {
    return 'Wait: ${seconds}s';
  }

  @override
  String homeChainSummaryDuration(Object seconds) {
    return 'Active: ${seconds}s';
  }

  @override
  String homeChainSummaryGrace(Object seconds) {
    return 'Grace period: ${seconds}s';
  }

  @override
  String homeChainSummaryRetry(Object count) {
    return 'Retries: $count';
  }

  @override
  String homeChainSummaryNextStep(Object name) {
    return 'Next step: $name';
  }

  @override
  String get homeChainSummaryNextStepNone => 'Next step: end of chain';

  @override
  String get homeChainSummaryClose => 'Close';

  @override
  String get chainStepNameHoldButton => 'Hold to stay safe';

  @override
  String get chainStepNameDisguisedReminder => 'Disguised reminder';

  @override
  String get chainStepNameCountdownWarning => 'Countdown warning';

  @override
  String get chainStepNameFakeCall => 'Fake call';

  @override
  String get chainStepNameSmsContact => 'SMS contact';

  @override
  String get chainStepNamePhoneCallContact => 'Phone call contact';

  @override
  String get chainStepNameLoudAlarm => 'Loud alarm';

  @override
  String get chainStepNameCallEmergency => 'Emergency call';

  @override
  String get chainStepNameHardwareButton => 'Hardware button';

  @override
  String get homeChecklistTitle => 'Safety Setup';

  @override
  String get homeChecklistDismissTooltip => 'Dismiss checklist';

  @override
  String get homeChecklistExpandTooltip => 'Show checklist';

  @override
  String get homeChecklistCollapseTooltip => 'Hide checklist';

  @override
  String homeChecklistProgress(Object done, Object total) {
    return '$done of $total done';
  }

  @override
  String get homeChecklistAllDoneBanner => 'All set — you\'re protected!';

  @override
  String get homeChecklistInfoTooltip => 'Why this matters';

  @override
  String get homeChecklistGotIt => 'Got it';

  @override
  String get homeChecklistGoThere => 'Go there';

  @override
  String get homeChecklistItem1Title => 'Add an emergency contact';

  @override
  String get homeChecklistItem2Title => 'Set a session-end PIN';

  @override
  String get homeChecklistItem3Title => 'Configure stealth mode';

  @override
  String get homeChecklistItem4Title => 'Test a simulation';

  @override
  String get homeChecklistItem5Title => 'Customize a safety mode';

  @override
  String get homeChecklistItem6Title => 'Grant required permissions';

  @override
  String get checklistInfo1Body =>
      'Emergency contacts are the people Guardian Angela messages and calls when you fail to check in. Without at least one contact, the chain has nowhere to escalate.';

  @override
  String get checklistInfo2Body =>
      'A session-end PIN prevents an attacker from quietly ending an active session. They can still attempt it, but typing the wrong PIN five times silently fires your distress chain.';

  @override
  String get checklistInfo3Body =>
      'Stealth mode disguises the active session as something innocuous on your screen — a music player, a paused timer, a blank lock screen. Use it when somebody nearby cannot see you running a safety app.';

  @override
  String get checklistInfo4Body =>
      'Simulation runs your safety mode end-to-end without sending real SMS, placing real calls, or sounding the loud alarm. Use it to learn the timings before you ever need them.';

  @override
  String get checklistInfo5Body =>
      'Custom modes let you tune the steps, timings, and triggers to a specific situation — walking home, a first date, a late shift. The two seed modes are starting points, not the destination.';

  @override
  String get checklistInfo6Body =>
      'Without notification permission, Guardian Angela cannot keep its persistent foreground status, deliver disguised reminders, or warn you that the chain is about to escalate.';

  @override
  String get checklistTutorial3Body =>
      'Open the stealth defaults and toggle \'Enable stealth mode\'. From there you can pick a fake music brand, hide the session timer, or disguise the home-screen icon.';

  @override
  String get checklistTutorial4Body =>
      'Tap the outlined \'Simulate\' button on the home screen after selecting a mode. The session runs with an orange border and the [SIM] badge — nothing leaves your phone.';

  @override
  String get checklistTutorial5Body =>
      'Open the Modes screen and either edit a seed mode (Walk / Date) or create a new one from scratch. Tweak the chain, add a fake call, set custom timings.';

  @override
  String get sessionHoldPrompt => 'Hold to stay safe';

  @override
  String sessionStepLabel(Object index, Object total) {
    return 'Step $index of $total';
  }

  @override
  String sessionMissCount(Object count) {
    return 'Missed: $count';
  }

  @override
  String get sessionPausedBadge => 'Paused';

  @override
  String get sessionPausedIncomingCall => 'Paused — incoming call';

  @override
  String get sessionPhaseEnded => 'Session ended';

  @override
  String get sessionSimulationBanner => 'Simulation';

  @override
  String get sessionCheckIn => 'I\'m checked in';

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
  String get sessionReminderEarlyCheckInHint => 'Tap to check in now';

  @override
  String get sessionReminderDefaultButton => 'OK';

  @override
  String get sessionReminderTapWordHint => 'Tap to continue';

  @override
  String get sessionReminderDecoyWords =>
      'LATER,SKIP,DONE,OPEN,VIEW,OKAY,NEXT,MORE,SNOOZE,CLOSE';

  @override
  String get sessionReminderSwipeLabel => 'Swipe to dismiss';

  @override
  String get sessionReminderDismissLabel => 'Dismiss';

  @override
  String get sessionStepSmsStatus => 'Sending message to contacts…';

  @override
  String get sessionStepPhoneCallStatus => 'Calling emergency contact…';

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
  String get sessionStealthNowPlaying => 'Now playing';

  @override
  String get sessionServiceTitle => 'Guardian Angela is active';

  @override
  String get sessionServiceBody => 'Your safety session is running.';

  @override
  String get sessionServiceStealthBody => 'Playing';

  @override
  String get sessionStealthTrackTitle => 'Untitled Track';

  @override
  String get sessionStealthArtistName => 'Unknown Artist';

  @override
  String get sessionStealthAlbumArtLabel => 'Album art';

  @override
  String get sessionStealthPlay => 'Play';

  @override
  String get sessionStealthPause => 'Pause';

  @override
  String get simulationSummaryTitle => 'Simulation summary';

  @override
  String get simulationSummaryEmpty => 'No steps fired during this simulation.';

  @override
  String get simulationSummaryReturn => 'Back to home';

  @override
  String get fakeCallTitle => 'Incoming call';

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
  String get contactFormIosSmsWarning =>
      'On iOS, SMS opens the Messages app. You must tap Send manually.';

  @override
  String get modesTitle => 'Modes';

  @override
  String get modesEmpty => 'No modes yet. Tap Add to create a mode.';

  @override
  String get modesAdd => 'Add mode';

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
  String get modeEditorTitleCreate => 'New mode';

  @override
  String get modeEditorTitleEdit => 'Edit mode';

  @override
  String get modeFieldName => 'Name';

  @override
  String get modeChainHeader => 'Chain';

  @override
  String get modeChainAddStep => 'Add step';

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
  String stepTimingSummary(Object wait, Object duration, Object grace) {
    return 'wait ${wait}s / duration ${duration}s / grace ${grace}s';
  }

  @override
  String get stepConfigTimingHeader => 'Timing';

  @override
  String get stepConfigEventHeader => 'Event configuration';

  @override
  String get stepConfigAdvancedHeader => 'Retry & advanced';

  @override
  String get stepFieldWait => 'Wait before firing (seconds)';

  @override
  String get stepFieldDuration => 'Active duration (seconds)';

  @override
  String get stepFieldGrace => 'Grace period (seconds)';

  @override
  String get stepFieldRetryCount => 'Retries';

  @override
  String get stepFieldRandomize => 'Randomise timing (±20%)';

  @override
  String get stepDuplicate => 'Duplicate step';

  @override
  String get stepResetDefaults => 'Reset to defaults';

  @override
  String get smsContactRecipientsHeader => 'Contacts to message';

  @override
  String get smsContactSummaryAll => 'To: all enabled contacts';

  @override
  String get smsContactSummaryNone => 'No recipients selected';

  @override
  String smsContactSummaryTo(Object names) {
    return 'To: $names';
  }

  @override
  String get smsContactChannelDisabledTooltip =>
      'Not enabled for this contact — edit the contact to add this channel.';

  @override
  String get smsContactEmptyAddPrompt =>
      'No contacts yet — add one in Contacts';

  @override
  String get safetyOptionsHeader => 'Safety options';

  @override
  String get safetyOptionsDistressModeTitle => 'Distress mode';

  @override
  String get safetyOptionsDistressModeUseDefault => 'Use default distress mode';

  @override
  String safetyOptionsDistressModeUseDefaultNamed(Object name) {
    return 'Use default ($name)';
  }

  @override
  String get safetyOptionsDistressModeInfo =>
      'When a distress trigger fires (duress PIN, hardware panic, or a wrong-PIN threshold), this mode\'s chain is replaced by the chosen distress mode\'s chain. Leave on the default to use the app-wide distress mode.';

  @override
  String get safetyOptionsManageDistressModes => 'Manage distress modes';

  @override
  String get safetyOptionsDistressTriggersTitle => 'Distress triggers';

  @override
  String get safetyOptionsDistressTriggersInfo =>
      'Distress triggers fire the distress chain immediately, in parallel with the main chain. The hardware panic button watches a physical button for the configured press pattern.';

  @override
  String get safetyOptionsDistressTriggersEmpty => 'No distress triggers';

  @override
  String get safetyOptionsAddHardwarePanic => 'Add hardware panic button';

  @override
  String safetyOptionsTriggerHardwareRepeat(Object button, Object count) {
    return '$button: $count× press';
  }

  @override
  String safetyOptionsTriggerHardwareLong(Object button, Object seconds) {
    return '$button: hold ${seconds}s';
  }

  @override
  String get safetyOptionsButtonVolumeUp => 'Volume up';

  @override
  String get safetyOptionsButtonVolumeDown => 'Volume down';

  @override
  String get safetyOptionsTriggerPattern => 'Press pattern';

  @override
  String get safetyOptionsPatternRepeat => 'Repeat press';

  @override
  String get safetyOptionsPatternLong => 'Long press';

  @override
  String get safetyOptionsTriggerButton => 'Button';

  @override
  String get safetyOptionsTriggerPressCount => 'Press count';

  @override
  String get safetyOptionsTriggerHoldDuration => 'Hold duration (seconds)';

  @override
  String get safetyOptionsDisarmTriggersTitle => 'Disarm triggers';

  @override
  String get safetyOptionsGpsArrivalTitle => 'GPS arrival disarm';

  @override
  String get safetyOptionsGpsArrivalInfo =>
      'Session ends automatically when you arrive within the configured radius of your destination. You set the destination when starting a session.';

  @override
  String get safetyOptionsGpsArrivalRadius => 'Arrival radius';

  @override
  String safetyOptionsRadiusMeters(Object meters) {
    return '$meters m';
  }

  @override
  String safetyOptionsRadiusKilometers(Object km) {
    return '$km km';
  }

  @override
  String get safetyOptionsDestinationSource => 'Destination';

  @override
  String get safetyOptionsDestinationPrompt =>
      'Set destination at session start';

  @override
  String get safetyOptionsDestinationFixed => 'Fixed coordinates';

  @override
  String get safetyOptionsLatitude => 'Latitude';

  @override
  String get safetyOptionsLongitude => 'Longitude';

  @override
  String get safetyOptionsTimerDisarmTitle => 'Timer disarm';

  @override
  String get safetyOptionsTimerDisarmInfo =>
      'Session ends automatically after the configured time, regardless of whether escalation has started.';

  @override
  String get safetyOptionsTimerDuration => 'Duration';

  @override
  String safetyOptionsDurationMinutes(Object minutes) {
    return '$minutes min';
  }

  @override
  String safetyOptionsDurationHoursMinutes(Object hours, Object minutes) {
    return '$hours h $minutes min';
  }

  @override
  String get safetyOptionsGpsLoggingTitle => 'GPS logging';

  @override
  String get safetyOptionsGpsLoggingInfo =>
      'Choose whether this mode records your location during a session. Inherit uses your global GPS-logging settings; Custom overrides them for this mode; Off disables logging entirely.';

  @override
  String get safetyOptionsStealthTitle => 'Stealth';

  @override
  String get safetyOptionsStealthInfo =>
      'Choose whether this mode disguises the app during a session. Inherit uses your global stealth settings; Custom overrides them for this mode; Off disables stealth entirely.';

  @override
  String get safetyOptionsTriStateInherit => 'Inherit';

  @override
  String get safetyOptionsTriStateCustom => 'Custom';

  @override
  String get safetyOptionsTriStateOff => 'Off';

  @override
  String get safetyOptionsLocalTemplatesTitle => 'Local templates';

  @override
  String get safetyOptionsLocalTemplatesInfo =>
      'Local templates are added to the global reminder-template pool for this mode only. Use them for disguised-reminder steps specific to this mode.';

  @override
  String get safetyOptionsLocalTemplatesEmpty => 'No local templates';

  @override
  String get safetyOptionsAddTemplate => 'Add template';

  @override
  String get safetyOptionsManageTemplates => 'Manage reminder templates';

  @override
  String get safetyOptionsEventDefaultsTitle => 'Event defaults';

  @override
  String get safetyOptionsEventDefaultsInfo =>
      'Event defaults set the starting configuration for each step type. Inherit uses your global event defaults; Custom overrides them for steps in this mode that have no explicit configuration.';

  @override
  String get safetyOptionsEventDefaultsTwoStateInherit => 'Inherit';

  @override
  String get safetyOptionsAllowDisarmAsDistressTitle =>
      'Allow disarm while active as distress';

  @override
  String get safetyOptionsAllowDisarmAsDistressInfo =>
      'Enabling allows you to stop the alert by reaching safety or letting a timer expire. Disabling means only chain completion or shutting down the app stops the alert — stronger against coercion.';

  @override
  String get distressModesEmpty => 'No distress modes yet.';

  @override
  String get distressModeEditorTitleCreate => 'New distress mode';

  @override
  String get distressModeEditorTitleEdit => 'Edit distress mode';

  @override
  String get templatesTitle => 'Reminder templates';

  @override
  String get templatesEmpty => 'No templates yet';

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
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsEmergencyNumberLabel => 'Emergency number';

  @override
  String get settingsRedoOnboardingActiveSessionTooltip =>
      'Cannot redo onboarding during an active session';

  @override
  String get settingsEmergencyNumberCountryPickerTitle =>
      'Choose emergency number';

  @override
  String get settingsEmergencyNumberEditTitle => 'Emergency number';

  @override
  String get settingsEmergencyNumberFieldLabel => 'Number to dial';

  @override
  String get settingsEmergencyNumberPresetsLabel => 'Common numbers';

  @override
  String get phoneWarnInvalidChars => 'Only digits, +, *, and # are allowed.';

  @override
  String get phoneWarnTooShort =>
      'Emergency numbers are usually at least 3 digits.';

  @override
  String get phoneWarnLooksLikeRegular =>
      'This looks like a regular phone number, not an emergency services number.';

  @override
  String get phoneWarnEmergencyEmpty =>
      'Enter a number — this can\'t be empty.';

  @override
  String get settingsRedoOnboarding => 'Redo onboarding';

  @override
  String get settingsRedoOnboardingConfirm =>
      'This will reset your setup. Continue?';

  @override
  String get securitySessionEndPinBiometric =>
      'Use biometrics for Session-end PIN';

  @override
  String get securityAppPinBiometric => 'Use biometrics for App lock';

  @override
  String get securityDistressCancelBiometric =>
      'Use biometrics to cancel distress';

  @override
  String get launchPinTitle => 'Enter your App PIN';

  @override
  String get launchPinBiometricReason => 'Unlock Guardian Angela';

  @override
  String get sessionEndBiometricReason => 'Confirm to end the session';

  @override
  String get distressCancelBiometricReason => 'Confirm it\'s you to cancel';

  @override
  String get launchPinIncorrect => 'Incorrect PIN';

  @override
  String get securitySetPin => 'Set PIN';

  @override
  String get securityChangePin => 'Change PIN';

  @override
  String get pinSetupMismatch => 'PINs don\'t match. Try again.';

  @override
  String get stealthTimerDisplayNormal => 'Normal';

  @override
  String get stealthTimerDisplaySmall => 'Small (corner)';

  @override
  String get stealthTimerDisplayNone => 'Hidden';

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
  String get eventDefaultsTitle => 'Event defaults';

  @override
  String get historyRetentionTitle => 'History & retention';

  @override
  String get backupTitle => 'Backup & restore';

  @override
  String get aboutTitle => 'About';

  @override
  String aboutVersion(Object version) {
    return 'Version: $version';
  }

  @override
  String get feedbackTitle => 'Send feedback';

  @override
  String get feedbackSend => 'Send';

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
  String get stealthLockTaskInfo =>
      'Pins Guardian Angela to the screen for the whole session so it can\'t be swiped away or switched out of. Trade-off: Android shows a system \"App is pinned\" banner and blocks app-switching until the session ends — visible to anyone watching the screen. Leave this off if you\'d rather move freely between apps during a session. No effect on platforms without screen-pinning.';

  @override
  String get homeTagline => 'Your angel\'s got your back.';

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
  String get onboardingEmergencyContactHeader => 'Emergency contact';

  @override
  String get onboardingEmergencyContactPrompt =>
      'Who should we contact if something goes wrong?';

  @override
  String get onboardingEmergencyContactAdd => 'Add emergency contact';

  @override
  String get onboardingPermissionsIntro =>
      'These permissions keep you safe during sessions.';

  @override
  String get onboardingPermissionsGrantAll => 'Grant all';

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
  String get sessionGpsDestinationSkip => 'Skip for this session';

  @override
  String get sessionGpsDestinationConfirm => 'Use destination';

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
  String get distressCancelPinPromptTitle => 'Enter Session End PIN';

  @override
  String distressCancelPinTimeoutLabel(int seconds) {
    return '${seconds}s remaining';
  }

  @override
  String get distressCancelPinIncorrect => 'Incorrect PIN';

  @override
  String get distressCancelPinAppPinMismatch =>
      'Use the Session End PIN, not the app lock PIN.';

  @override
  String get distressCancelPinSimSkip => 'Skip (sim only)';

  @override
  String get distressCancelSimDistressWouldFire =>
      'Distress chain would fire (5 wrong PINs)';

  @override
  String get distressCancelPinBack => 'Cancel';

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
  String get securityRemovePinPrompt => 'Enter your current PIN to remove it.';

  @override
  String get securityRemovePinIncorrect => 'Incorrect PIN';

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
  String get eventDefaultsCheckInHeader => 'Check-in methods';

  @override
  String get eventDefaultsEscalationHeader => 'Escalation steps';

  @override
  String get eventDefaultsPanicHeader => 'Panic trigger';

  @override
  String get templatesCreate => 'Create template';

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
  String get contactUnsavedDiscardTitle => 'Discard unsaved changes?';

  @override
  String get contactUnsavedDiscardKeep => 'Keep editing';

  @override
  String get contactUnsavedDiscardDiscard => 'Discard';

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
  String get validationNameTooShort => 'Name must be at least 2 characters.';

  @override
  String get validationPhoneRequired => 'Phone number is required.';

  @override
  String get validationChannelsRequired => 'Select at least one channel.';

  @override
  String get validationChainEmpty => 'Add at least one step before saving.';

  @override
  String get validationGpsFixedCoords =>
      'Set both latitude and longitude for the fixed arrival destination.';

  @override
  String get validationHardwareTrigger =>
      'Hardware panic trigger is incomplete — check its press count or hold duration.';

  @override
  String get validationSmsChannelNotOnContacts =>
      'None of the chosen contacts can receive on this step\'s channel. Pick a different channel or add it to a contact.';

  @override
  String get validationDistressNoActionTitle => 'No outbound alert step';

  @override
  String get validationDistressNoActionBody =>
      'This distress mode has no SMS or call step, so it leaves no outbound trail. Save it anyway?';

  @override
  String get validationSaveAnyway => 'Save anyway';

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
  String sessionStepNextCheckIn(Object time) {
    return 'Next check-in in $time';
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
  String get pastEventsRestore => 'Restore';

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
  String get eventDefaultsSmsMessageTemplate => 'Message template';

  @override
  String get eventDefaultsSmsMessageTemplateHint =>
      'Leave blank to use the default alert. Tap a placeholder to insert it.';

  @override
  String get eventDefaultsSmsIosWarning =>
      'On iPhone, SMS requires you to manually press Send in the Messages app. If you cannot interact with your phone, the message will not send. Consider using WhatsApp or Telegram instead.';

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
  String get eventDefaultsCallEmergencyIosWarning =>
      'On iPhone, a confirmation dialog will appear before dialing. Tap \'Call\' quickly.';

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

  @override
  String get homeWidgetStatusIdle => 'Idle';

  @override
  String get homeWidgetStatusSession => 'Session active';

  @override
  String get homeWidgetStatusSim => 'Simulation active';

  @override
  String get homeWidgetQuickExit => 'Quick Exit';

  @override
  String get homeWidgetFakeCall => 'Fake Call';

  @override
  String get settingsAlarmHeader => 'Alarm';

  @override
  String get settingsAlarmDndOverrideLabel =>
      'Alarm overrides silent/vibrate mode';

  @override
  String get settingsAlarmDndOverrideWarning =>
      'Warning: the alarm will be silent if your phone is on silent mode.';

  @override
  String get settingsAlarmDndOverrideInfo =>
      'When enabled, the loud alarm plays at full volume even if your phone is on silent or vibrate. On Android it uses the alarm audio stream to bypass Do Not Disturb. The alarm is the only event that can override your phone\'s sound settings.';

  @override
  String get settingsAlarmGradualLabel => 'Gradually increase alarm volume';

  @override
  String get settingsAlarmGradualInfo =>
      'Starts the alarm quietly and ramps it up to full volume. This is the app-wide master switch; each alarm step also has its own gradual-volume option, and both must be on for the ramp to apply.';

  @override
  String get settingsAlarmRampLabel => 'Ramp duration';

  @override
  String get settingsAlarmRampInfo =>
      'How long the alarm takes to reach full volume from zero, ramping evenly over this time. Has no effect when gradual volume is off.';
}
