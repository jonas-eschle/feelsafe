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
  String get angelaDialogTitle => 'Old PIN entered';

  @override
  String get angelaDialogBody =>
      'It looks like you used an old PIN. Are you sure you want to proceed?';

  @override
  String get angelaDialogCancel => 'Cancel';

  @override
  String get angelaDialogConfirm => 'Continue';

  @override
  String get commonCancel => 'Άκυρο';

  @override
  String get commonOk => 'OK';

  @override
  String get profileAngelaWarningTitle => 'Heads up about the name \"Angela\"';

  @override
  String get profileAngelaWarningBody =>
      'Guardian Angela uses \"Angela\" as a safety keyword. Using it as your own name could be confusing. Save anyway?';

  @override
  String get commonDelete => 'Διαγραφή';

  @override
  String get commonEdit => 'Επεξεργασία';

  @override
  String get commonAdd => 'Προσθήκη';

  @override
  String get commonClose => 'Κλείσιμο';

  @override
  String get commonConfirm => 'Επιβεβαίωση';

  @override
  String get commonBack => 'Πίσω';

  @override
  String get commonDone => 'Τέλος';

  @override
  String get commonRetry => 'Επανάληψη';

  @override
  String get commonYes => 'Ναι';

  @override
  String get commonNo => 'Όχι';

  @override
  String get commonEnabled => 'Ενεργοποιημένο';

  @override
  String get commonDisabled => 'Απενεργοποιημένο';

  @override
  String get commonNone => 'Κανένα';

  @override
  String get commonSeconds => 'δευτερόλεπτα';

  @override
  String get commonMinutes => 'λεπτά';

  @override
  String get cancel => 'Άκυρο';

  @override
  String get pinSubmit => 'Submit';

  @override
  String get homeTitle => 'Guardian Angela';

  @override
  String get homeStartSession => 'Έναρξη συνεδρίας';

  @override
  String get homeStartConfirmTitle => 'Start a session?';

  @override
  String get homeStartConfirmBody =>
      'Make sure your contacts and PIN are configured. The session will run in the foreground and your selected mode will guide check-ins.';

  @override
  String get homeSimulate => 'Προσομοίωση';

  @override
  String get homeActiveSession => 'Ενεργή συνεδρία';

  @override
  String get homeResumeSession => 'Συνέχιση';

  @override
  String get homeNoModes =>
      'Δεν υπάρχουν ακόμη λειτουργίες. Πατήστε Λειτουργίες για να προσθέσετε μία.';

  @override
  String get homeNoContacts =>
      'Δεν υπάρχουν ακόμη επαφές έκτακτης ανάγκης. Πατήστε Επαφές για να προσθέσετε μία.';

  @override
  String get homeContactsBannerNone => 'No emergency contacts configured.';

  @override
  String homeContactsBannerFew(int count) {
    return '$count contact(s) configured. We recommend at least 3.';
  }

  @override
  String get homeMenuSettings => 'Ρυθμίσεις';

  @override
  String get homeMenuContacts => 'Επαφές';

  @override
  String get homeMenuModes => 'Λειτουργίες';

  @override
  String get homeMenuHistory => 'Προηγούμενες συνεδρίες';

  @override
  String get homeSelectMode => 'Επιλογή λειτουργίας';

  @override
  String get onboardingWelcomeTitle => 'Καλώς ήρθατε στο Guardian Angela';

  @override
  String get onboardingWelcomeBody =>
      'Ένας σύντροφος που σας κρατά ασφαλείς στο δρόμο για το σπίτι. Το Guardian Angela σας επιτηρεί όσο περπατάτε, τρέχετε ή ταξιδεύετε, και μπορεί να ειδοποιήσει τις επαφές που έχετε επιλέξει αν χρειαστείτε βοήθεια.';

  @override
  String get onboardingProfileTitle => 'Προφίλ και πρώτη επαφή';

  @override
  String get onboardingProfileBody =>
      'Πείτε μας λίγα λόγια για εσάς ώστε το Guardian Angela να μπορεί να μοιραστεί χρήσιμες λεπτομέρειες αν χρειαστείτε βοήθεια έκτακτης ανάγκης. Έπειτα, προσθέστε μία έμπιστη επαφή.';

  @override
  String get onboardingPermissionsTitle => 'Άδειες';

  @override
  String get onboardingPermissionsBody =>
      'Το Guardian Angela χρειάζεται μερικές άδειες για να σας κρατήσει ασφαλείς. Παραχωρήστε τις τώρα ή αργότερα από τις Ρυθμίσεις.';

  @override
  String get onboardingNext => 'Επόμενο';

  @override
  String get onboardingSkip => 'Παράλειψη';

  @override
  String get onboardingFinish => 'Τέλος';

  @override
  String get sessionTitle => 'Συνεδρία';

  @override
  String get sessionDisarm => 'Είμαι ασφαλής';

  @override
  String get sessionPause => 'Παύση';

  @override
  String get sessionResume => 'Συνέχιση';

  @override
  String get sessionHoldPrompt =>
      'Κρατήστε πατημένο για να παραμείνετε ασφαλείς';

  @override
  String get sessionHoldSemantic =>
      'Κρατήστε πατημένο. Η απελευθέρωση ξεκινά περίοδο χάριτος.';

  @override
  String sessionStepLabel(Object index, Object total) {
    return 'Βήμα $index από $total';
  }

  @override
  String sessionMissCount(Object count) {
    return 'Χαμένα: $count';
  }

  @override
  String sessionRemaining(Object seconds) {
    return '$seconds δευτ. απομένουν';
  }

  @override
  String get sessionPausedBadge => 'Σε παύση';

  @override
  String get sessionPhaseEnded => 'Η συνεδρία τερματίστηκε';

  @override
  String get sessionSimulationBanner => 'Προσομοίωση';

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
  String get fakeCallAnswer => 'Απάντηση';

  @override
  String get fakeCallDecline => 'Απόρριψη';

  @override
  String get fakeCallHangUp => 'Τερματισμός';

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
  String get contactLanguageDefault => 'Default (use app language)';

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
  String get contactRequiredError =>
      'Το όνομα και ο αριθμός τηλεφώνου είναι υποχρεωτικά.';

  @override
  String get modesTitle => 'Λειτουργίες';

  @override
  String get modesEmpty =>
      'Δεν υπάρχουν ακόμη λειτουργίες. Πατήστε Προσθήκη για να δημιουργήσετε μία.';

  @override
  String get modesAdd => 'Προσθήκη λειτουργίας';

  @override
  String get modeEditorTitleCreate => 'Νέα λειτουργία';

  @override
  String get modeEditorTitleEdit => 'Επεξεργασία λειτουργίας';

  @override
  String get modeFieldName => 'Όνομα';

  @override
  String get modeFieldCheckInType => 'Τύπος ελέγχου';

  @override
  String get modeFieldDistressChain => 'Λειτουργία κινδύνου';

  @override
  String get modeFieldDistressChainDefault => 'Χρήση προεπιλογής';

  @override
  String get modeChainHeader => 'Αλυσίδα κλιμάκωσης';

  @override
  String get modeChainAddStep => 'Προσθήκη βήματος';

  @override
  String get modeChainEmpty =>
      'Δεν υπάρχουν ακόμη βήματα. Πατήστε Προσθήκη βήματος.';

  @override
  String get modeFieldIcon => 'Εικονίδιο';

  @override
  String get modeIconPickerTitle => 'Επιλογή εικονιδίου';

  @override
  String get modeIconClear => 'Κανένα εικονίδιο';

  @override
  String get modeDistressHeader => 'Σκανδάλες κινδύνου';

  @override
  String get modeDistressEmpty => 'Δεν έχουν ρυθμιστεί σκανδάλες κινδύνου.';

  @override
  String get modeDistressAdd => 'Προσθήκη σκανδάλης';

  @override
  String get modeDistressTypeHardware => 'Φυσικό κουμπί';

  @override
  String get modeDistressButtonType => 'Κουμπί';

  @override
  String get modeDistressButtonVolumeUp => 'Αύξηση έντασης';

  @override
  String get modeDistressButtonVolumeDown => 'Μείωση έντασης';

  @override
  String get modeDistressButtonPower => 'Λειτουργίας';

  @override
  String get modeDistressPattern => 'Μοτίβο';

  @override
  String get modeDistressPatternRepeat => 'Επαναλαμβανόμενο πάτημα';

  @override
  String get modeDistressPatternLong => 'Παρατεταμένο πάτημα';

  @override
  String get modeDistressPressCount => 'Αριθμός πατημάτων';

  @override
  String get modeDistressPressWindow => 'Παράθυρο (ms)';

  @override
  String get modeDistressLongDuration => 'Διάρκεια κρατήματος (δευτ.)';

  @override
  String modeDistressSummaryRepeat(Object count, Object windowMs) {
    return '$count πατήματα / $windowMs ms';
  }

  @override
  String modeDistressSummaryLong(Object seconds) {
    return 'Κράτημα $secondsδ';
  }

  @override
  String get modeOverridesHeader => 'Παρακάμψεις λειτουργίας';

  @override
  String get modeOverridesUseDefault => 'Χρήση προεπιλογής εφαρμογής';

  @override
  String get modeOverridesGpsLabel => 'Καταγραφή GPS';

  @override
  String get modeOverridesStealthLabel => 'Κρυφή λειτουργία';

  @override
  String get modeOverridesEventDefaultsLabel => 'Προεπιλογές συμβάντων';

  @override
  String get modeOverridesLocalTemplatesLabel => 'Τοπικά πρότυπα υπενθύμισης';

  @override
  String get modeOverridesGpsEnabled => 'GPS ενεργό';

  @override
  String get modeOverridesGpsIntervalLabel => 'Διάστημα δειγματοληψίας (δευτ.)';

  @override
  String get modeOverridesGpsIncludeInSms => 'Προσθήκη τοποθεσίας στα SMS';

  @override
  String get modeOverridesStealthEnabled => 'Κρυφή λειτουργία ενεργή';

  @override
  String get modeOverridesStealthFakeName => 'Ψεύτικο όνομα εφαρμογής';

  @override
  String get modeOverridesEventDefaultsHint =>
      'Προσαρμοσμένες προεπιλογές ενεργές για αυτή τη λειτουργία.';

  @override
  String modeOverridesLocalTemplatesCount(Object count) {
    return '$count τοπικά πρότυπα';
  }

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
  String get stepDuplicate => 'Διπλασιασμός βήματος';

  @override
  String get stepTimingHeader => 'Χρονισμός';

  @override
  String stepTimingSummary(Object wait, Object duration, Object grace) {
    return 'αναμονή $waitδ / διάρκεια $durationδ / περιθώριο $graceδ';
  }

  @override
  String get stepCategoryAll => 'Όλα';

  @override
  String get stepCategoryAction => 'Ενέργεια';

  @override
  String get stepCategoryReminder => 'Υπενθύμιση';

  @override
  String get stepCategoryDisarm => 'Επιβεβαίωση';

  @override
  String get modeTrackingHeader => 'Εντοπισμός θέσης';

  @override
  String get modeTrackingEnabled => 'Καταγραφή GPS κατά τη συνεδρία';

  @override
  String get modeTrackingIntervalLabel => 'Διάστημα δειγματοληψίας';

  @override
  String get modeTrackingBufferSizeLabel => 'Μέγεθος buffer';

  @override
  String modeTrackingBufferSizeValue(Object count) {
    return '$count σημεία';
  }

  @override
  String get modeTrackingBatteryNote =>
      'Η συχνή καταγραφή GPS αυξάνει την κατανάλωση μπαταρίας.';

  @override
  String get stepConfigLogGpsLabel => 'Καταγραφή GPS';

  @override
  String get stepConfigLogGpsDefault => 'Προεπιλογή';

  @override
  String get stepConfigLogGpsOn => 'Ενεργό';

  @override
  String get stepConfigLogGpsOff => 'Ανενεργό';

  @override
  String get stepConfigLogGpsDefaultOn => 'Προεπιλογή (Ενεργό)';

  @override
  String get stepConfigLogGpsDefaultOff => 'Προεπιλογή (Ανενεργό)';

  @override
  String get moreSettingsHeader => 'Περισσότερες ρυθμίσεις';

  @override
  String moreSettingsHeaderCustomized(int count) {
    return 'Περισσότερες ρυθμίσεις ($count προσαρμοσμένες)';
  }

  @override
  String get stepTypePickerLabel => 'Step type';

  @override
  String get stepTypeHoldButton => 'Κουμπί κράτησης';

  @override
  String get stepTypeDisguisedReminder => 'Μεταμφιεσμένη υπενθύμιση';

  @override
  String get stepTypeCountdownWarning => 'Προειδοποίηση αντίστροφης μέτρησης';

  @override
  String get stepTypeFakeCall => 'Ψεύτικη κλήση';

  @override
  String get stepTypeSmsContact => 'SMS σε επαφή';

  @override
  String get stepTypePhoneCallContact => 'Κλήση επαφής';

  @override
  String get stepTypeLoudAlarm => 'Δυνατός συναγερμός';

  @override
  String get stepTypeCallEmergency => 'Κλήση έκτακτης ανάγκης';

  @override
  String get stepTypeHardwareButton => 'Κουμπί συσκευής';

  @override
  String get stepFieldDuration => 'Διάρκεια (δευτερόλεπτα)';

  @override
  String get stepFieldGrace => 'Περίοδος χάριτος (δευτερόλεπτα)';

  @override
  String get stepFieldWait => 'Αναμονή (δευτερόλεπτα)';

  @override
  String get stepFieldRetryCount => 'Επαναλήψεις';

  @override
  String get stepFieldRandomize => 'Διακύμανση χρονισμού';

  @override
  String get stepPreview => 'Προεπισκόπηση σε προσομοίωση';

  @override
  String stepPreviewFired(Object description) {
    return 'Η προεπισκόπηση εκτελέστηκε: $description';
  }

  @override
  String get stepConfigFakeCallCaller => 'Όνομα καλούντος';

  @override
  String get stepConfigFakeCallDecline => 'Η απόρριψη μετρά ως αποδέσμευση';

  @override
  String get stepConfigLoudAlarmFlash => 'Αναλαμπή οθόνης';

  @override
  String get stepConfigLoudAlarmVolume => 'Μέγιστη ένταση';

  @override
  String get stepConfigCountdownVibrate => 'Δόνηση';

  @override
  String get stepConfigCountdownTone => 'Αναπαραγωγή ήχου';

  @override
  String get stepConfigSmsSelection => 'Παραλήπτες';

  @override
  String get stepConfigSmsAllContacts => 'Όλες οι επαφές';

  @override
  String get stepConfigSmsSpecific => 'Συγκεκριμένες επαφές';

  @override
  String get stepConfigSmsIncludeLocation => 'Συμπερίληψη τοποθεσίας';

  @override
  String get stepConfigSmsIncludeMedical => 'Συμπερίληψη ιατρικών πληροφοριών';

  @override
  String get stepConfigHoldReleaseSensitivity => 'Ευαισθησία απελευθέρωσης (δ)';

  @override
  String get stepConfigReminderInterval =>
      'Διάστημα υπενθύμισης (δευτερόλεπτα)';

  @override
  String get stepConfigReminderTemplate => 'Πρότυπο';

  @override
  String get stepConfigHardwarePattern => 'Μοτίβο';

  @override
  String get stepConfigHardwarePressCount => 'Αριθμός πατημάτων';

  @override
  String get stepConfigHardwareButton => 'Κουμπί';

  @override
  String get stepConfigHardwareButtonVolumeUp => 'Αύξηση έντασης';

  @override
  String get stepConfigHardwareButtonVolumeDown => 'Μείωση έντασης';

  @override
  String get stepConfigHardwareButtonPower => 'Λειτουργία';

  @override
  String get stepConfigHardwarePatternRepeat => 'Επαναλαμβανόμενο πάτημα';

  @override
  String get stepConfigHardwarePatternLong => 'Παρατεταμένο πάτημα';

  @override
  String get stepConfigEmergencyNumber => 'Παράκαμψη αριθμού έκτακτης ανάγκης';

  @override
  String get stepConfigEmergencyConfirm => 'Επιβεβαίωση πριν την κλήση';

  @override
  String get stepConfigPhonePreSms => 'Αποστολή SMS πριν την κλήση';

  @override
  String get distressModesTitle => 'Λειτουργίες κινδύνου';

  @override
  String get distressModeInUseTitle => 'Η λειτουργία κινδύνου χρησιμοποιείται';

  @override
  String distressModeInUseBody(Object modes) {
    return 'Αυτή η λειτουργία κινδύνου είναι ακόμη συνδεδεμένη με: $modes. Συνδέστε αυτές τις λειτουργίες με άλλη λειτουργία κινδύνου πριν τη διαγράψετε.';
  }

  @override
  String get distressModesEmpty => 'Δεν υπάρχουν ακόμη λειτουργίες κινδύνου.';

  @override
  String get distressModesAdd => 'Προσθήκη λειτουργίας κινδύνου';

  @override
  String get distressModeEditorTitleCreate => 'Νέα λειτουργία κινδύνου';

  @override
  String get distressModeEditorTitleEdit => 'Επεξεργασία λειτουργίας κινδύνου';

  @override
  String get distressModeName => 'Όνομα λειτουργίας κινδύνου';

  @override
  String get distressCountdown => 'Ενεργοποίηση λειτουργίας κινδύνου...';

  @override
  String get distressCountdownStealth => 'Παρακαλώ περιμένετε...';

  @override
  String get templatesTitle => 'Πρότυπα υπενθύμισης';

  @override
  String get templatesEmpty => 'Δεν υπάρχουν ακόμη πρότυπα.';

  @override
  String get templatesAdd => 'Προσθήκη προτύπου';

  @override
  String get templateEditorTitleCreate => 'Νέο πρότυπο';

  @override
  String get templateEditorTitleEdit => 'Επεξεργασία προτύπου';

  @override
  String get templateFieldName => 'Όνομα στον επεξεργαστή';

  @override
  String get templateFieldTitle => 'Τίτλος υπενθύμισης';

  @override
  String get templateFieldBody => 'Κείμενο υπενθύμισης';

  @override
  String get templateFieldConfirmationType => 'Τύπος επιβεβαίωσης';

  @override
  String get templateFieldKeyword => 'Λέξη-κλειδί';

  @override
  String get templateFieldButtonLabel => 'Ετικέτα κουμπιού';

  @override
  String get templateFieldDisplayStyle => 'Στυλ εμφάνισης';

  @override
  String get templateConfirmTapButton => 'Πάτημα κουμπιού';

  @override
  String get templateConfirmTapWord => 'Πάτημα λέξης';

  @override
  String get templateConfirmSwipe => 'Σύρσιμο';

  @override
  String get templateConfirmDismiss => 'Απόρριψη';

  @override
  String get templateDisplayFullscreen => 'Πλήρης οθόνη';

  @override
  String get templateDisplaySubtle => 'Διακριτική';

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
  String get profileFieldConditions => 'Παθήσεις';

  @override
  String get profileFieldInstructions => 'Οδηγίες έκτακτης ανάγκης';

  @override
  String get profileAddItem => 'Προσθήκη στοιχείου';

  @override
  String get settingsTitle => 'Ρυθμίσεις';

  @override
  String get settingsSectionSecurity => 'Ασφάλεια';

  @override
  String get settingsSectionStealth => 'Κρυφή λειτουργία';

  @override
  String get settingsSectionDefaults => 'Προεπιλογές';

  @override
  String get settingsSectionHistory => 'Ιστορικό';

  @override
  String get settingsSectionBackup => 'Αντίγραφο ασφαλείας';

  @override
  String get settingsSectionAbout => 'Σχετικά';

  @override
  String get settingsSectionFeedback => 'Σχόλια';

  @override
  String get settingsSectionContacts => 'Επαφές';

  @override
  String get settingsSectionModes => 'Λειτουργίες';

  @override
  String get settingsSectionProfile => 'Προφίλ';

  @override
  String get settingsSectionDistressModes => 'Λειτουργίες κινδύνου';

  @override
  String get settingsSectionReminderTemplates => 'Πρότυπα υπενθύμισης';

  @override
  String get settingsSectionBatteryAlert => 'Ειδοποίηση μπαταρίας';

  @override
  String get settingsSectionEventDefaults => 'Προεπιλογές βημάτων';

  @override
  String get settingsSectionGpsLogging => 'Καταγραφή GPS';

  @override
  String get settingsSectionNotifications => 'Ειδοποιήσεις';

  @override
  String get settingsSectionHistoryRetention => 'Διατήρηση ιστορικού';

  @override
  String get settingsSectionAppearance => 'Εμφάνιση';

  @override
  String get settingsThemeMode => 'Θέμα';

  @override
  String get settingsThemeLight => 'Φωτεινό';

  @override
  String get settingsThemeDark => 'Σκοτεινό';

  @override
  String get settingsThemeSystem => 'Συστήματος';

  @override
  String get settingsLanguage => 'Γλώσσα';

  @override
  String get settingsEmergencyNumber => 'Αριθμός έκτακτης ανάγκης';

  @override
  String get settingsAlarmDnd => 'Ο συναγερμός παρακάμπτει το Μην Ενοχλείτε';

  @override
  String get securityTitle => 'Ασφάλεια';

  @override
  String get securityAppPin => 'PIN εφαρμογής';

  @override
  String get securitySessionEndPin => 'PIN τερματισμού συνεδρίας';

  @override
  String get securityDuressPin => 'PIN εξαναγκασμού';

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
  String get securityPinTimeout => 'Χρονικό όριο PIN (δευτερόλεπτα)';

  @override
  String get securityDisablePin => 'Απενεργοποίηση';

  @override
  String get securitySetPin => 'Ορισμός PIN';

  @override
  String get securityChangePin => 'Αλλαγή PIN';

  @override
  String get pinSetupTitle => 'Ορισμός PIN';

  @override
  String get pinSetupEnter => 'Εισαγάγετε νέο PIN';

  @override
  String get pinSetupConfirm => 'Επιβεβαιώστε το PIN';

  @override
  String get pinSetupMismatch => 'Τα PIN δεν ταιριάζουν. Δοκιμάστε ξανά.';

  @override
  String get pinEntryTitle => 'Εισαγωγή PIN';

  @override
  String get pinEntrySubtitle => 'Εισαγάγετε το PIN σας για να συνεχίσετε.';

  @override
  String get pinEntryBiometricReason => 'Authenticate to continue';

  @override
  String get stealthTitle => 'Κρυφή λειτουργία';

  @override
  String get stealthEnable => 'Ενεργοποίηση κρυφής λειτουργίας';

  @override
  String get stealthFakeName => 'Ψεύτικο όνομα εφαρμογής';

  @override
  String get stealthFakeIcon => 'Ψεύτικο εικονίδιο';

  @override
  String get stealthNotificationDisguise => 'Μεταμφίεση ειδοποιήσεων';

  @override
  String get stealthTimerDisplay => 'Εμφάνιση χρονομέτρου σε κρυφή λειτουργία';

  @override
  String get stealthTimerDisplayNormal => 'Show full text';

  @override
  String get stealthTimerDisplaySmall => 'Show numbers only';

  @override
  String get stealthTimerDisplayNone => 'Hide timer';

  @override
  String get stealthSessionScreen =>
      'Αφαίρεση στοιχείων μάρκας από την οθόνη συνεδρίας';

  @override
  String get stealthPickerTitle => 'Εικονίδιο εφαρμογής';

  @override
  String get stealthPickerIntro =>
      'Επίλεξε την εμφάνιση του εικονιδίου στην αρχική οθόνη.';

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
  String get distressConfirmationTitle => 'Βρίσκεσαι σε κίνδυνο;';

  @override
  String get distressConfirmationCancel => 'Άκυρο';

  @override
  String distressConfirmationCountdown(Object seconds) {
    return 'Η αλυσίδα κινδύνου ξεκινά σε $seconds δευτ.';
  }

  @override
  String get imSafeSliderLabel => 'Σύρε για να επιβεβαιώσεις «Είμαι ασφαλής»';

  @override
  String get batteryAlertTitle => 'Ειδοποίηση μπαταρίας';

  @override
  String get batteryAlertEnable => 'Ενεργοποίηση ειδοποίησης μπαταρίας';

  @override
  String batteryAlertThreshold(Object percent) {
    return 'Όριο: $percent%';
  }

  @override
  String get eventDefaultsTitle => 'Προεπιλογές βημάτων';

  @override
  String get eventDefaultsBody =>
      'Αυτές οι προεπιλογές ισχύουν για κάθε βήμα που δεν τις παρακάμπτει.';

  @override
  String get gpsLoggingTitle => 'Καταγραφή GPS';

  @override
  String get gpsLoggingEnable => 'Ενεργοποίηση καταγραφής GPS';

  @override
  String get gpsLoggingInterval => 'Διάστημα δειγματοληψίας (δευτερόλεπτα)';

  @override
  String get gpsLoggingAccuracy => 'Ακρίβεια';

  @override
  String get gpsAccuracyLow => 'Χαμηλή';

  @override
  String get gpsAccuracyMedium => 'Μεσαία';

  @override
  String get gpsAccuracyHigh => 'Υψηλή';

  @override
  String get gpsLoggingIncludeSms => 'Επισύναψη τοποθεσίας στο SMS';

  @override
  String get gpsLoggingHistoryDays => 'Διατήρηση ιστορικού (ημέρες)';

  @override
  String get notificationSettingsTitle => 'Ειδοποιήσεις';

  @override
  String get notificationSettingsBody =>
      'Το Guardian Angela χρησιμοποιεί ειδοποιήσεις για τη μεταμφίεση και την προώθηση υπενθυμίσεων.';

  @override
  String get historyRetentionTitle => 'Διατήρηση ιστορικού';

  @override
  String get historyRetentionBody =>
      'Για πόσο καιρό το Guardian Angela διατηρεί τα αρχεία προηγούμενων συνεδριών.';

  @override
  String historyRetentionDays(Object days) {
    return 'Διατήρηση: $days ημέρες';
  }

  @override
  String get backupTitle => 'Αντίγραφο ασφαλείας';

  @override
  String get backupExport => 'Εξαγωγή δεδομένων';

  @override
  String get backupImport => 'Εισαγωγή δεδομένων';

  @override
  String get backupNotReady =>
      'Το αντίγραφο ασφαλείας δεν είναι ακόμη διαθέσιμο. Σύντομα διαθέσιμο.';

  @override
  String get backupPinOptional => 'Προαιρετικό PIN (κρυπτογραφεί το πακέτο)';

  @override
  String get backupImportOk => 'Η εισαγωγή αντιγράφου ασφαλείας ολοκληρώθηκε.';

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
  String get historyTitle => 'Προηγούμενες συνεδρίες';

  @override
  String get historyEmpty => 'Δεν υπάρχουν ακόμη προηγούμενες συνεδρίες.';

  @override
  String get historySearchHint => 'Search by mode name';

  @override
  String get historyFilterModeAll => 'All modes';

  @override
  String get historyFilterModeLabel => 'Mode';

  @override
  String get historyDateRangePick => 'Date range';

  @override
  String get historyDetailTitle => 'Λεπτομέρειες συνεδρίας';

  @override
  String get evidenceExportTitle => 'Εξαγωγή στοιχείων';

  @override
  String get evidenceExportAsText => 'Αντιγραφή ως κείμενο';

  @override
  String get evidenceExportAsJson => 'Αντιγραφή ως JSON';

  @override
  String get evidenceCopied => 'Αντιγράφηκε στο πρόχειρο.';

  @override
  String get aboutTitle => 'Σχετικά';

  @override
  String get aboutVersion => 'Έκδοση';

  @override
  String get aboutCredits =>
      'Φτιαγμένο με φροντίδα για ανθρώπους στο δρόμο προς το σπίτι.';

  @override
  String get feedbackTitle => 'Σχόλια';

  @override
  String get feedbackBody => 'Θα θέλαμε πολύ να ακούσουμε τα σχόλιά σας.';

  @override
  String get feedbackFieldMessage => 'Μήνυμα';

  @override
  String get feedbackSend => 'Άνοιγμα email';

  @override
  String get pickerNoneLabel => '— κανένα —';

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
}
