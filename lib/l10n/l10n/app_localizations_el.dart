// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Modern Greek (`el`).
class AppLocalizationsEl extends AppLocalizations {
  AppLocalizationsEl([String locale = 'el']) : super(locale);

  @override
  String get appTitle => 'Guardian Angela';

  @override
  String get commonSave => 'Αποθήκευση';

  @override
  String get angelaDialogTitle => 'Εισήχθη παλιό PIN';

  @override
  String get angelaDialogBody =>
      'Φαίνεται ότι χρησιμοποιήσατε ένα παλιό PIN. Είστε σίγουροι ότι θέλετε να συνεχίσετε;';

  @override
  String get angelaDialogCancel => 'Άκυρο';

  @override
  String get angelaDialogConfirm => 'Συνέχεια';

  @override
  String get commonCancel => 'Άκυρο';

  @override
  String get commonOk => 'OK';

  @override
  String get commonDelete => 'Διαγραφή';

  @override
  String get commonEdit => 'Επεξεργασία';

  @override
  String get commonClose => 'Κλείσιμο';

  @override
  String get commonConfirm => 'Επιβεβαίωση';

  @override
  String get commonBack => 'Πίσω';

  @override
  String get pinSubmit => 'Υποβολή';

  @override
  String get homeTitle => 'Guardian Angela';

  @override
  String get homeStartSession => 'Έναρξη συνεδρίας';

  @override
  String get homePermissionsNotification => 'Ειδοποιήσεις';

  @override
  String get homePermissionsLocation => 'Τοποθεσία';

  @override
  String get homePermissionsCallPhone => 'Τηλεφωνικές κλήσεις';

  @override
  String get homePermissionsSendSms => 'Αποστολή SMS';

  @override
  String get homeSimulate => 'Προσομοίωση';

  @override
  String get homeNoModes =>
      'Δεν υπάρχουν ακόμη λειτουργίες. Πατήστε Λειτουργίες για να προσθέσετε μία.';

  @override
  String get homeContactsBannerNone =>
      'Δεν έχουν ρυθμιστεί επαφές έκτακτης ανάγκης.';

  @override
  String get homeMenuSettings => 'Ρυθμίσεις';

  @override
  String get homeMenuContacts => 'Επαφές';

  @override
  String get homeMenuHistory => 'Προηγούμενες συνεδρίες';

  @override
  String get onboardingProfileTitle => 'Προφίλ και πρώτη επαφή';

  @override
  String get onboardingPermissionsTitle => 'Άδειες';

  @override
  String get onboardingNext => 'Επόμενο';

  @override
  String get onboardingSkip => 'Παράλειψη';

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
  String get sessionTitle => 'Συνεδρία';

  @override
  String get sessionDisarm => 'Είμαι ασφαλής';

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
  String get sessionHoldPrompt =>
      'Κρατήστε πατημένο για να παραμείνετε ασφαλείς';

  @override
  String sessionStepLabel(Object index, Object total) {
    return 'Βήμα $index από $total';
  }

  @override
  String sessionMissCount(Object count) {
    return 'Χαμένα: $count';
  }

  @override
  String get sessionPausedBadge => 'Σε παύση';

  @override
  String get sessionPhaseEnded => 'Η συνεδρία τερματίστηκε';

  @override
  String get sessionSimulationBanner => 'Προσομοίωση';

  @override
  String get sessionCheckIn => 'Είμαι σε ασφάλεια';

  @override
  String get sessionStepCountdownTitle => 'Προειδοποίηση';

  @override
  String get sessionStepCountdownBody =>
      'Η επόμενη κλιμάκωση ενεργοποιείται όταν λήξει η αντίστροφη μέτρηση. Σύρετε «Είμαι ασφαλής» παρακάτω για αποδέσμευση.';

  @override
  String get sessionStepDisguisedDefaultTitle => 'Υπενθύμιση';

  @override
  String get sessionStepDisguisedDefaultBody =>
      'Πατήστε «Είμαι σε ασφάλεια» για να επιβεβαιώσετε ότι είστε ασφαλείς.';

  @override
  String get sessionStepSmsStatus => 'Αποστολή μηνύματος στις επαφές…';

  @override
  String get sessionStepPhoneCallStatus => 'Κλήση επαφής έκτακτης ανάγκης…';

  @override
  String get sessionStepLoudAlarmTitle => 'Ηχεί συναγερμός';

  @override
  String get sessionStepLoudAlarmBody =>
      'Ο συναγερμός ηχεί για να τραβήξει την προσοχή.';

  @override
  String get sessionStepLoudAlarmFlashWarning =>
      'Προειδοποίηση φωτοευαισθησίας: η οθόνη αναβοσβήνει.';

  @override
  String get sessionStepCallEmergencyStatus =>
      'Κλήση υπηρεσιών έκτακτης ανάγκης…';

  @override
  String sessionStepCallEmergencyNumber(Object number) {
    return 'Αριθμός: $number';
  }

  @override
  String sessionStepHardwareButtonRepeat(
    Object button,
    Object count,
    Object windowMs,
  ) {
    return 'Πατήστε $button $count φορές μέσα σε ${windowMs}ms';
  }

  @override
  String sessionStepHardwareButtonLong(Object button, Object seconds) {
    return 'Κρατήστε $button για $seconds δευτερόλεπτα';
  }

  @override
  String get sessionStepHardwareButtonVolumeUp => 'αύξηση έντασης';

  @override
  String get sessionStepHardwareButtonVolumeDown => 'μείωση έντασης';

  @override
  String get sessionStepHardwareButtonPower => 'λειτουργίας';

  @override
  String get sessionCompletedTitle => 'Η συνεδρία ολοκληρώθηκε';

  @override
  String get sessionCompletedBody =>
      'Φτάσατε με ασφάλεια. Το Guardian Angela αποδεσμεύεται.';

  @override
  String get sessionCompletedReturnHome => 'Επιστροφή στην αρχική';

  @override
  String get simulationSummaryTitle => 'Σύνοψη προσομοίωσης';

  @override
  String get simulationSummaryEmpty =>
      'Δεν ενεργοποιήθηκαν βήματα κατά την προσομοίωση.';

  @override
  String get simulationSummaryReturn => 'Επιστροφή στην αρχική';

  @override
  String get fakeCallTitle => 'Εισερχόμενη κλήση';

  @override
  String get fakeCallHangUp => 'Τερματισμός';

  @override
  String get fakeCallSlideToAnswer => 'σύρετε για απάντηση';

  @override
  String get fakeCallUnknownCaller => 'Άγνωστος';

  @override
  String get fakeCallIncomingWhatsapp => 'Φωνητική κλήση WhatsApp';

  @override
  String get fakeCallIncomingTelegram => 'Φωνητική κλήση Telegram';

  @override
  String get fakeCallIncomingSignal => 'Φωνητική κλήση Signal';

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
  String get contactsTitle => 'Επαφές έκτακτης ανάγκης';

  @override
  String get contactsEmpty =>
      'Δεν υπάρχουν ακόμη επαφές. Προσθέστε μία για να λαμβάνει τα μηνύματα κινδύνου.';

  @override
  String get contactsAdd => 'Προσθήκη επαφής';

  @override
  String get contactFormTitleCreate => 'Νέα επαφή';

  @override
  String get contactFormTitleEdit => 'Επεξεργασία επαφής';

  @override
  String get contactFieldName => 'Όνομα';

  @override
  String get contactFieldPhone => 'Αριθμός τηλεφώνου';

  @override
  String get contactFieldRelationship => 'Σχέση (προαιρετικό)';

  @override
  String get contactFieldLanguage => 'Γλώσσα SMS (προαιρετικό)';

  @override
  String get contactLanguageDefault => 'Προεπιλογή (γλώσσα εφαρμογής)';

  @override
  String get contactChannelsHeader => 'Κανάλια επικοινωνίας';

  @override
  String get contactChannelSms => 'SMS';

  @override
  String get contactChannelWhatsapp => 'WhatsApp';

  @override
  String get contactChannelTelegram => 'Telegram';

  @override
  String get contactChannelPhone => 'Τηλεφωνική κλήση';

  @override
  String get contactDeleteConfirm => 'Διαγραφή επαφής;';

  @override
  String contactDeleteBody(Object name) {
    return 'Η επαφή $name θα αφαιρεθεί από τη λίστα έκτακτης ανάγκης.';
  }

  @override
  String get contactFormIosSmsWarning =>
      'On iOS, SMS opens the Messages app. You must tap Send manually.';

  @override
  String get modesTitle => 'Λειτουργίες';

  @override
  String get modesEmpty =>
      'Δεν υπάρχουν ακόμη λειτουργίες. Πατήστε Προσθήκη για να δημιουργήσετε μία.';

  @override
  String get modesAdd => 'Προσθήκη λειτουργίας';

  @override
  String get modesNewPickerBlank => 'Κενή λειτουργία';

  @override
  String get modesNewPickerBlankSubtitle => 'Ξεκινήστε με άδεια αλυσίδα';

  @override
  String modesNewPickerFromTemplate(String name) {
    return 'Από $name';
  }

  @override
  String get modesNewPickerFromTemplateSubtitle =>
      'Αντιγραφή αλυσίδας και σκανδαλών αυτής της λειτουργίας';

  @override
  String get modeEditorTitleCreate => 'Νέα λειτουργία';

  @override
  String get modeEditorTitleEdit => 'Επεξεργασία λειτουργίας';

  @override
  String get modeFieldName => 'Όνομα';

  @override
  String get modeChainHeader => 'Αλυσίδα';

  @override
  String get modeChainAddStep => 'Προσθήκη βήματος';

  @override
  String get modeUnsavedTitle => 'Απόρριψη αλλαγών;';

  @override
  String get modeUnsavedBody =>
      'Έχετε μη αποθηκευμένες αλλαγές. Απόρριψη και έξοδος;';

  @override
  String get modeUnsavedDiscard => 'Απόρριψη';

  @override
  String get modeUnsavedKeep => 'Συνέχιση επεξεργασίας';

  @override
  String stepTimingSummary(Object wait, Object duration, Object grace) {
    return 'αναμονή $waitδ / διάρκεια $durationδ / περιθώριο $graceδ';
  }

  @override
  String get distressModesEmpty => 'Δεν υπάρχουν ακόμη λειτουργίες κινδύνου.';

  @override
  String get distressModeEditorTitleCreate => 'Νέα λειτουργία κινδύνου';

  @override
  String get distressModeEditorTitleEdit => 'Επεξεργασία λειτουργίας κινδύνου';

  @override
  String get templatesTitle => 'Πρότυπα υπενθύμισης';

  @override
  String get templatesEmpty => 'Δεν υπάρχουν ακόμη πρότυπα.';

  @override
  String get profileTitle => 'Προφίλ';

  @override
  String get profileFieldName => 'Όνομα';

  @override
  String get profileFieldAge => 'Ηλικία';

  @override
  String get profileFieldBloodType => 'Ομάδα αίματος';

  @override
  String get profileFieldAllergies => 'Αλλεργίες';

  @override
  String get profileFieldMedications => 'Φάρμακα';

  @override
  String get settingsThemeLight => 'Φωτεινό';

  @override
  String get settingsThemeDark => 'Σκοτεινό';

  @override
  String get settingsThemeSystem => 'Συστήματος';

  @override
  String get settingsEmergencyNumberLabel => 'Αριθμός έκτακτης ανάγκης';

  @override
  String get settingsRedoOnboardingActiveSessionTooltip =>
      'Cannot redo onboarding during an active session';

  @override
  String get settingsEmergencyNumberCountryPickerTitle =>
      'Choose emergency number';

  @override
  String get settingsRedoOnboarding => 'Επανεκκίνηση εισαγωγής';

  @override
  String get settingsRedoOnboardingConfirm => 'Επανεκκίνηση εισαγωγής;';

  @override
  String get securitySessionEndPinBiometric =>
      'Χρήση βιομετρικών για το PIN τερματισμού συνεδρίας';

  @override
  String get securitySetPin => 'Ορισμός PIN';

  @override
  String get securityChangePin => 'Αλλαγή PIN';

  @override
  String get pinSetupMismatch => 'Τα PIN δεν ταιριάζουν. Δοκιμάστε ξανά.';

  @override
  String get stealthTimerDisplayNormal => 'Εμφάνιση πλήρους κειμένου';

  @override
  String get stealthTimerDisplaySmall => 'Εμφάνιση μόνο αριθμών';

  @override
  String get stealthTimerDisplayNone => 'Απόκρυψη χρονομέτρου';

  @override
  String get stealthPresetMusic => 'Μουσική';

  @override
  String get stealthPresetCalendar => 'Ημερολόγιο';

  @override
  String get stealthPresetFitness => 'Φυσική κατάσταση';

  @override
  String get stealthPresetWeather => 'Καιρός';

  @override
  String get stealthPresetNews => 'Ειδήσεις';

  @override
  String get stealthPresetPhotos => 'Φωτογραφίες';

  @override
  String get stealthPresetNotes => 'Σημειώσεις';

  @override
  String get stealthPresetClock => 'Ρολόι';

  @override
  String get batteryAlertTitle => 'Ειδοποίηση μπαταρίας';

  @override
  String get eventDefaultsTitle => 'Προεπιλογές βημάτων';

  @override
  String get historyRetentionTitle => 'Διατήρηση ιστορικού';

  @override
  String get backupTitle => 'Αντίγραφο ασφαλείας';

  @override
  String get aboutTitle => 'Σχετικά';

  @override
  String aboutVersion(Object version) {
    return 'Έκδοση';
  }

  @override
  String get feedbackTitle => 'Σχόλια';

  @override
  String get feedbackSend => 'Άνοιγμα email';

  @override
  String get stealthPresetPodcast => 'Podcast';

  @override
  String get stealthPresetNone => 'Καμία';

  @override
  String get stealthLockTaskLabel => 'Pin app during session';

  @override
  String get stealthLockTaskSubtitle =>
      'Prevents leaving the app while a session is running. On Android this engages screen-pinning; on other platforms this is a no-op.';

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
