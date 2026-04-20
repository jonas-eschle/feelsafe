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
  String get commonCancel => 'Άκυρο';

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
  String get homeTitle => 'Guardian Angela';

  @override
  String get homeStartSession => 'Έναρξη συνεδρίας';

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
  String get modeFieldDistressChain => 'Αλυσίδα κινδύνου';

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
  String get distressChainsTitle => 'Αλυσίδες κινδύνου';

  @override
  String get distressChainsEmpty => 'Δεν υπάρχουν ακόμη αλυσίδες κινδύνου.';

  @override
  String get distressChainsAdd => 'Προσθήκη αλυσίδας';

  @override
  String get distressChainEditorTitleCreate => 'Νέα αλυσίδα κινδύνου';

  @override
  String get distressChainEditorTitleEdit => 'Επεξεργασία αλυσίδας κινδύνου';

  @override
  String get distressChainName => 'Όνομα αλυσίδας';

  @override
  String get distressCountdown => 'Ενεργοποίηση αλυσίδας κινδύνου...';

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
  String get settingsSectionDistressChains => 'Αλυσίδες κινδύνου';

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
  String get stealthSessionScreen =>
      'Αφαίρεση στοιχείων μάρκας από την οθόνη συνεδρίας';

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
  String get historyTitle => 'Προηγούμενες συνεδρίες';

  @override
  String get historyEmpty => 'Δεν υπάρχουν ακόμη προηγούμενες συνεδρίες.';

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
}
