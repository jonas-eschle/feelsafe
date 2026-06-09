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
  String get commonGotIt => 'Το κατάλαβα';

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
  String get onboardingUseSimNumber => 'Χρήση του αριθμού της SIM μου';

  @override
  String onboardingUseSimNumberHint(Object number) {
    return '$number';
  }

  @override
  String get onboardingUseSimNumberUnsupported => 'Μη διαθέσιμο σε iOS';

  @override
  String get onboardingUseSimNumberUnavailable => 'Αδυναμία ανάγνωσης αριθμού';

  @override
  String get onboardingUseSimNumberPermissionDenied => 'Η άδεια απορρίφθηκε';

  @override
  String get sessionTitle => 'Συνεδρία';

  @override
  String get sessionDisarm => 'Είμαι ασφαλής';

  @override
  String get sessionDisarmStealth => 'Δεν χρειάζεται η Άντζελα';

  @override
  String get homeChainSummaryTitle => 'Σύνοψη αλυσίδας';

  @override
  String get homeChainSummaryEmpty =>
      'Αυτή η κατάσταση δεν έχει ακόμη βήματα — πατήστε την για επεξεργασία.';

  @override
  String homeChainSummaryTimingTitle(Object name) {
    return 'Βήμα: $name';
  }

  @override
  String homeChainSummaryWait(Object seconds) {
    return 'Αναμονή: $seconds δευτ.';
  }

  @override
  String homeChainSummaryDuration(Object seconds) {
    return 'Ενεργό: $seconds δευτ.';
  }

  @override
  String homeChainSummaryGrace(Object seconds) {
    return 'Περίοδος χάριτος: $seconds δευτ.';
  }

  @override
  String homeChainSummaryRetry(Object count) {
    return 'Επαναλήψεις: $count';
  }

  @override
  String homeChainSummaryNextStep(Object name) {
    return 'Επόμενο βήμα: $name';
  }

  @override
  String get homeChainSummaryNextStepNone => 'Επόμενο βήμα: τέλος αλυσίδας';

  @override
  String get homeChainSummaryClose => 'Κλείσιμο';

  @override
  String get chainStepNameHoldButton => 'Κρατήστε για να μείνετε ασφαλείς';

  @override
  String get chainStepNameDisguisedReminder => 'Καμουφλαρισμένη υπενθύμιση';

  @override
  String get chainStepNameCountdownWarning =>
      'Προειδοποίηση αντίστροφης μέτρησης';

  @override
  String get chainStepNameFakeCall => 'Ψεύτικη κλήση';

  @override
  String get chainStepNameSmsContact => 'SMS σε επαφή';

  @override
  String get chainStepNamePhoneCallContact => 'Κλήση σε επαφή';

  @override
  String get chainStepNameLoudAlarm => 'Δυνατός συναγερμός';

  @override
  String get chainStepNameCallEmergency => 'Κλήση έκτακτης ανάγκης';

  @override
  String get chainStepNameHardwareButton => 'Πλήκτρο υλικού';

  @override
  String get homeChecklistTitle => 'Ρύθμιση ασφάλειας';

  @override
  String get homeChecklistDismissTooltip => 'Απόκρυψη λίστας';

  @override
  String get homeChecklistExpandTooltip => 'Εμφάνιση λίστας';

  @override
  String get homeChecklistCollapseTooltip => 'Σύμπτυξη λίστας';

  @override
  String homeChecklistProgress(Object done, Object total) {
    return '$done από $total ολοκληρώθηκαν';
  }

  @override
  String get homeChecklistAllDoneBanner => 'Έτοιμα — προστατεύεσαι!';

  @override
  String get homeChecklistInfoTooltip => 'Γιατί έχει σημασία';

  @override
  String get homeChecklistGotIt => 'Εντάξει';

  @override
  String get homeChecklistGoThere => 'Πήγαινε εκεί';

  @override
  String get homeChecklistItem1Title => 'Προσθήκη επαφής έκτακτης ανάγκης';

  @override
  String get homeChecklistItem2Title => 'Ορισμός PIN λήξης συνεδρίας';

  @override
  String get homeChecklistItem3Title => 'Ρύθμιση κρυφής λειτουργίας';

  @override
  String get homeChecklistItem4Title => 'Δοκιμή προσομοίωσης';

  @override
  String get homeChecklistItem5Title => 'Προσαρμογή λειτουργίας ασφαλείας';

  @override
  String get homeChecklistItem6Title => 'Παραχώρηση απαιτούμενων αδειών';

  @override
  String get checklistInfo1Body =>
      'Οι επαφές έκτακτης ανάγκης είναι τα άτομα που η Guardian Angela ειδοποιεί με μήνυμα και κλήση όταν δεν δηλώσεις ότι είσαι ασφαλής. Χωρίς τουλάχιστον μία επαφή, η αλυσίδα δεν έχει πού να κλιμακωθεί.';

  @override
  String get checklistInfo2Body =>
      'Το PIN λήξης συνεδρίας εμποδίζει κάποιον επιτιθέμενο να τερματίσει αθόρυβα μια ενεργή συνεδρία. Μπορεί να προσπαθήσει, αλλά πέντε λανθασμένες πληκτρολογήσεις ενεργοποιούν σιωπηλά την αλυσίδα κινδύνου σου.';

  @override
  String get checklistInfo3Body =>
      'Η κρυφή λειτουργία μεταμφιέζει την ενεργή συνεδρία ως κάτι αθώο στην οθόνη — αναπαραγωγή μουσικής, παγωμένο χρονόμετρο, κενή οθόνη κλειδώματος. Χρησιμοποίησέ την όταν κάποιος δίπλα σου δεν πρέπει να δει εφαρμογή ασφαλείας.';

  @override
  String get checklistInfo4Body =>
      'Η προσομοίωση εκτελεί τη λειτουργία ασφαλείας σου από άκρη σε άκρη χωρίς να στέλνει πραγματικά SMS, να κάνει πραγματικές κλήσεις ή να ηχεί τον δυνατό συναγερμό. Χρησιμοποίησέ την για να μάθεις τους χρονισμούς πριν τους χρειαστείς.';

  @override
  String get checklistInfo5Body =>
      'Οι προσαρμοσμένες λειτουργίες σου επιτρέπουν να ρυθμίσεις βήματα, χρονισμούς και ενεργοποιητές για μια συγκεκριμένη κατάσταση — επιστροφή στο σπίτι, πρώτο ραντεβού, βραδινή βάρδια. Οι δύο ενσωματωμένες λειτουργίες είναι αφετηρία, όχι προορισμός.';

  @override
  String get checklistInfo6Body =>
      'Χωρίς άδεια ειδοποιήσεων, η Guardian Angela δεν μπορεί να διατηρήσει τη μόνιμη κατάσταση προσκηνίου, να παραδώσει καμουφλαρισμένες υπενθυμίσεις ή να σε προειδοποιήσει ότι η αλυσίδα πρόκειται να κλιμακωθεί.';

  @override
  String get checklistTutorial3Body =>
      'Άνοιξε τις προεπιλογές κρυφής λειτουργίας και ενεργοποίησε το «Ενεργοποίηση κρυφής λειτουργίας». Από εκεί διαλέγεις μια ψεύτικη μάρκα μουσικής, κρύβεις το χρονόμετρο συνεδρίας ή μεταμφιέζεις το εικονίδιο στην αρχική οθόνη.';

  @override
  String get checklistTutorial4Body =>
      'Στην αρχική οθόνη, αφού επιλέξεις λειτουργία, πάτα το περιγραμμένο κουμπί «Προσομοίωση». Η συνεδρία τρέχει με πορτοκαλί πλαίσιο και σήμα [SIM] — τίποτα δεν φεύγει από το τηλέφωνό σου.';

  @override
  String get checklistTutorial5Body =>
      'Άνοιξε την οθόνη Λειτουργιών και είτε επεξεργάσου μια ενσωματωμένη λειτουργία (Περπάτημα / Ραντεβού) είτε δημιούργησε μία από την αρχή. Ρύθμισε την αλυσίδα, πρόσθεσε ψεύτικη κλήση, όρισε δικούς σου χρονισμούς.';

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
  String get sessionPausedIncomingCall => 'Σε παύση — εισερχόμενη κλήση';

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
  String get sessionReminderEarlyCheckInHint => 'Πατήστε για σύνδεση τώρα';

  @override
  String get sessionReminderDefaultButton => 'OK';

  @override
  String get sessionReminderTapWordHint => 'Πατήστε για συνέχεια';

  @override
  String get sessionReminderDecoyWords =>
      'ΑΡΓΟΤΕΡΑ,ΠΑΡΑΛΕΙΨΗ,ΕΓΙΝΕ,ΑΝΟΙΓΜΑ,ΠΡΟΒΟΛΗ,ΕΝΤΑΞΕΙ,ΕΠΟΜΕΝΟ,ΠΕΡΙΣΣΟΤΕΡΑ,ΑΝΑΒΟΛΗ,ΚΛΕΙΣΙΜΟ';

  @override
  String get sessionReminderSwipeLabel => 'Σύρτε για απόρριψη';

  @override
  String get sessionReminderDismissLabel => 'Απόρριψη';

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
  String get sessionStealthNowPlaying => 'Αναπαραγωγή τώρα';

  @override
  String get sessionServiceTitle => 'Το Guardian Angela είναι ενεργό';

  @override
  String get sessionServiceBody => 'Η συνεδρία ασφάλειάς σου εκτελείται.';

  @override
  String get sessionServiceStealthBody => 'Αναπαραγωγή';

  @override
  String get sessionStealthTrackTitle => 'Κομμάτι χωρίς τίτλο';

  @override
  String get sessionStealthArtistName => 'Άγνωστος καλλιτέχνης';

  @override
  String get sessionStealthAlbumArtLabel => 'Εξώφυλλο άλμπουμ';

  @override
  String get sessionStealthPlay => 'Αναπαραγωγή';

  @override
  String get sessionStealthPause => 'Παύση';

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
  String get fakeCallBrandAndroid => 'ΤΗΛΕΦΩΝΟ';

  @override
  String get fakeCallBrandIos => 'ΤΗΛΕΦΩΝΟ';

  @override
  String get fakeCallBrandMinimal => 'ΚΛΗΣΗ';

  @override
  String get fakeCallDeclineSafeLabel => 'Απόρριψη (Είμαι ασφαλής)';

  @override
  String get fakeCallDeclineUnsafeLabel => 'Απόρριψη (Παραμονή σε επιφυλακή)';

  @override
  String get fakeCallHoldForDistress => 'Κρατήστε 5 δευτ. για κίνδυνο';

  @override
  String fakeCallVoicePrompt(String name) {
    return 'Φωνητική προτροπή: $name';
  }

  @override
  String fakeCallVibrationLabel(String pattern) {
    return 'Δόνηση: $pattern';
  }

  @override
  String get fakeCallVibrationPatternDefault => 'προεπιλογή';

  @override
  String get fakeCallSlideToAnswerHint => 'Σύρετε για απάντηση';

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
      'Στο iOS, το SMS ανοίγει την εφαρμογή Μηνύματα. Πρέπει να πατήσετε «Αποστολή» χειροκίνητα.';

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
  String get stepConfigTimingHeader => 'Χρονισμός';

  @override
  String get stepConfigEventHeader => 'Ρύθμιση συμβάντος';

  @override
  String get stepConfigAdvancedHeader => 'Επανάληψη & σύνθετα';

  @override
  String get stepFieldWait => 'Αναμονή πριν την ενεργοποίηση (δευτερόλεπτα)';

  @override
  String get stepFieldDuration => 'Διάρκεια ενεργοποίησης (δευτερόλεπτα)';

  @override
  String get stepFieldGrace => 'Περίοδος χάριτος (δευτερόλεπτα)';

  @override
  String get stepFieldRetryCount => 'Επαναλήψεις';

  @override
  String get stepFieldRandomize => 'Τυχαιοποίηση χρονισμού (±20%)';

  @override
  String get stepDuplicate => 'Διπλασιασμός βήματος';

  @override
  String get stepResetDefaults => 'Επαναφορά στις προεπιλογές';

  @override
  String get smsContactRecipientsHeader => 'Επαφές προς ειδοποίηση';

  @override
  String get smsContactSummaryAll => 'Προς: όλες τις ενεργοποιημένες επαφές';

  @override
  String get smsContactSummaryNone => 'Δεν επιλέχθηκαν παραλήπτες';

  @override
  String smsContactSummaryTo(Object names) {
    return 'Προς: $names';
  }

  @override
  String get smsContactChannelDisabledTooltip =>
      'Δεν είναι ενεργοποιημένο για αυτή την επαφή — επεξεργαστείτε την επαφή για να προσθέσετε αυτό το κανάλι.';

  @override
  String get smsContactEmptyAddPrompt =>
      'Δεν υπάρχουν ακόμη επαφές — προσθέστε μία στις Επαφές';

  @override
  String get safetyOptionsHeader => 'Επιλογές ασφάλειας';

  @override
  String get safetyOptionsDistressModeTitle => 'Λειτουργία κινδύνου';

  @override
  String get safetyOptionsDistressModeUseDefault =>
      'Χρήση προεπιλεγμένης λειτουργίας κινδύνου';

  @override
  String safetyOptionsDistressModeUseDefaultNamed(Object name) {
    return 'Χρήση προεπιλογής ($name)';
  }

  @override
  String get safetyOptionsDistressModeInfo =>
      'Όταν ενεργοποιηθεί ένας ενεργοποιητής κινδύνου (PIN υπό εξαναγκασμό, πανικός υλικού ή υπέρβαση λανθασμένων PIN), η αλυσίδα αυτής της λειτουργίας αντικαθίσταται από την αλυσίδα της επιλεγμένης λειτουργίας κινδύνου. Αφήστε την προεπιλογή για να χρησιμοποιηθεί η καθολική λειτουργία κινδύνου της εφαρμογής.';

  @override
  String get safetyOptionsManageDistressModes =>
      'Διαχείριση λειτουργιών κινδύνου';

  @override
  String get safetyOptionsDistressTriggersTitle => 'Ενεργοποιητές κινδύνου';

  @override
  String get safetyOptionsDistressTriggersInfo =>
      'Οι ενεργοποιητές κινδύνου εκκινούν αμέσως την αλυσίδα κινδύνου, παράλληλα με την κύρια αλυσίδα. Το κουμπί πανικού υλικού παρακολουθεί ένα φυσικό κουμπί σύμφωνα με το ρυθμισμένο μοτίβο πατημάτων.';

  @override
  String get safetyOptionsDistressTriggersEmpty =>
      'Δεν υπάρχουν ενεργοποιητές κινδύνου';

  @override
  String get safetyOptionsAddHardwarePanic =>
      'Προσθήκη κουμπιού πανικού υλικού';

  @override
  String safetyOptionsTriggerHardwareRepeat(Object button, Object count) {
    return '$button: $count× πάτημα';
  }

  @override
  String safetyOptionsTriggerHardwareLong(Object button, Object seconds) {
    return '$button: κράτημα ${seconds}s';
  }

  @override
  String get safetyOptionsButtonVolumeUp => 'Αύξηση έντασης';

  @override
  String get safetyOptionsButtonVolumeDown => 'Μείωση έντασης';

  @override
  String get safetyOptionsTriggerPattern => 'Μοτίβο πατήματος';

  @override
  String get safetyOptionsPatternRepeat => 'Επαναλαμβανόμενο πάτημα';

  @override
  String get safetyOptionsPatternLong => 'Παρατεταμένο πάτημα';

  @override
  String get safetyOptionsTriggerButton => 'Κουμπί';

  @override
  String get safetyOptionsTriggerPressCount => 'Αριθμός πατημάτων';

  @override
  String get safetyOptionsTriggerHoldDuration =>
      'Διάρκεια κρατήματος (δευτερόλεπτα)';

  @override
  String get safetyOptionsDisarmTriggersTitle =>
      'Ενεργοποιητές απενεργοποίησης';

  @override
  String get safetyOptionsGpsArrivalTitle =>
      'Απενεργοποίηση κατά την άφιξη GPS';

  @override
  String get safetyOptionsGpsArrivalInfo =>
      'Η συνεδρία τερματίζεται αυτόματα όταν φτάσετε εντός της ρυθμισμένης ακτίνας από τον προορισμό σας. Ορίζετε τον προορισμό κατά την έναρξη μιας συνεδρίας.';

  @override
  String get safetyOptionsGpsArrivalRadius => 'Ακτίνα άφιξης';

  @override
  String safetyOptionsRadiusMeters(Object meters) {
    return '$meters m';
  }

  @override
  String safetyOptionsRadiusKilometers(Object km) {
    return '$km km';
  }

  @override
  String get safetyOptionsDestinationSource => 'Προορισμός';

  @override
  String get safetyOptionsDestinationPrompt =>
      'Ορισμός προορισμού στην έναρξη της συνεδρίας';

  @override
  String get safetyOptionsDestinationFixed => 'Σταθερές συντεταγμένες';

  @override
  String get safetyOptionsLatitude => 'Γεωγραφικό πλάτος';

  @override
  String get safetyOptionsLongitude => 'Γεωγραφικό μήκος';

  @override
  String get safetyOptionsTimerDisarmTitle => 'Απενεργοποίηση με χρονόμετρο';

  @override
  String get safetyOptionsTimerDisarmInfo =>
      'Η συνεδρία τερματίζεται αυτόματα μετά τον ρυθμισμένο χρόνο, ανεξάρτητα από το αν έχει ξεκινήσει η κλιμάκωση.';

  @override
  String get safetyOptionsTimerDuration => 'Διάρκεια';

  @override
  String safetyOptionsDurationMinutes(Object minutes) {
    return '$minutes λεπτά';
  }

  @override
  String safetyOptionsDurationHoursMinutes(Object hours, Object minutes) {
    return '$hours ώρες $minutes λεπτά';
  }

  @override
  String get safetyOptionsGpsLoggingTitle => 'Καταγραφή GPS';

  @override
  String get safetyOptionsGpsLoggingInfo =>
      'Επιλέξτε αν αυτή η λειτουργία καταγράφει την τοποθεσία σας κατά τη διάρκεια μιας συνεδρίας. Η «Κληρονόμηση» χρησιμοποιεί τις καθολικές ρυθμίσεις GPS· το «Προσαρμοσμένο» τις αντικαθιστά για αυτή τη λειτουργία· το «Ανενεργό» απενεργοποιεί εντελώς την καταγραφή.';

  @override
  String get safetyOptionsStealthTitle => 'Κρυφή λειτουργία';

  @override
  String get safetyOptionsStealthInfo =>
      'Επιλέξτε αν αυτή η λειτουργία μεταμφιέζει την εφαρμογή κατά τη διάρκεια μιας συνεδρίας. Η «Κληρονόμηση» χρησιμοποιεί τις καθολικές ρυθμίσεις κρυφής λειτουργίας· το «Προσαρμοσμένο» τις αντικαθιστά για αυτή τη λειτουργία· το «Ανενεργό» την απενεργοποιεί εντελώς.';

  @override
  String get safetyOptionsTriStateInherit => 'Κληρονόμηση';

  @override
  String get safetyOptionsTriStateCustom => 'Προσαρμοσμένο';

  @override
  String get safetyOptionsTriStateOff => 'Ανενεργό';

  @override
  String get safetyOptionsLocalTemplatesTitle => 'Τοπικά πρότυπα';

  @override
  String get safetyOptionsLocalTemplatesInfo =>
      'Τα τοπικά πρότυπα προστίθενται στο καθολικό σύνολο προτύπων υπενθύμισης μόνο για αυτή τη λειτουργία. Χρησιμοποιήστε τα για βήματα μεταμφιεσμένης υπενθύμισης ειδικά για αυτή τη λειτουργία.';

  @override
  String get safetyOptionsLocalTemplatesEmpty => 'Δεν υπάρχουν τοπικά πρότυπα';

  @override
  String get safetyOptionsAddTemplate => 'Προσθήκη προτύπου';

  @override
  String get safetyOptionsManageTemplates => 'Διαχείριση προτύπων υπενθύμισης';

  @override
  String get safetyOptionsEventDefaultsTitle => 'Προεπιλογές συμβάντων';

  @override
  String get safetyOptionsEventDefaultsInfo =>
      'Οι προεπιλογές συμβάντων ορίζουν την αρχική διαμόρφωση για κάθε τύπο βήματος. Η «Κληρονόμηση» χρησιμοποιεί τις καθολικές προεπιλογές· το «Προσαρμοσμένο» τις αντικαθιστά για βήματα αυτής της λειτουργίας χωρίς δική τους διαμόρφωση.';

  @override
  String get safetyOptionsEventDefaultsTwoStateInherit => 'Κληρονόμηση';

  @override
  String get safetyOptionsAllowDisarmAsDistressTitle =>
      'Να επιτρέπεται η απενεργοποίηση κατά τον ενεργό κίνδυνο';

  @override
  String get safetyOptionsAllowDisarmAsDistressInfo =>
      'Όταν είναι ενεργό, μπορείτε να σταματήσετε τον συναγερμό φτάνοντας σε ασφαλές μέρος ή αφήνοντας ένα χρονόμετρο να λήξει. Όταν είναι ανενεργό, μόνο η ολοκλήρωση της αλυσίδας ή το κλείσιμο της εφαρμογής σταματά τον συναγερμό — ισχυρότερη προστασία έναντι εξαναγκασμού.';

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
      'Δεν είναι δυνατή η επανεκκίνηση εισαγωγής κατά τη διάρκεια ενεργής συνεδρίας';

  @override
  String get settingsEmergencyNumberCountryPickerTitle =>
      'Επιλογή αριθμού έκτακτης ανάγκης';

  @override
  String get settingsEmergencyNumberEditTitle => 'Αριθμός έκτακτης ανάγκης';

  @override
  String get settingsEmergencyNumberFieldLabel => 'Αριθμός για κλήση';

  @override
  String get settingsEmergencyNumberPresetsLabel => 'Συνηθισμένοι αριθμοί';

  @override
  String get phoneWarnInvalidChars => 'Επιτρέπονται μόνο ψηφία, +, * και #.';

  @override
  String get phoneWarnTooShort =>
      'Οι αριθμοί έκτακτης ανάγκης έχουν συνήθως τουλάχιστον 3 ψηφία.';

  @override
  String get phoneWarnLooksLikeRegular =>
      'Αυτό μοιάζει με κανονικό τηλεφωνικό αριθμό, όχι με αριθμό έκτακτης ανάγκης.';

  @override
  String get phoneWarnEmergencyEmpty =>
      'Εισαγάγετε έναν αριθμό — δεν μπορεί να είναι κενό.';

  @override
  String get settingsRedoOnboarding => 'Επανεκκίνηση εισαγωγής';

  @override
  String get settingsRedoOnboardingConfirm => 'Επανεκκίνηση εισαγωγής;';

  @override
  String get securitySessionEndPinBiometric =>
      'Χρήση βιομετρικών για το PIN τερματισμού συνεδρίας';

  @override
  String get securityAppPinBiometric =>
      'Χρήση βιομετρικών για το κλείδωμα της εφαρμογής';

  @override
  String get securityDistressCancelBiometric =>
      'Χρήση βιομετρικών για ακύρωση κινδύνου';

  @override
  String get launchPinTitle => 'Εισαγάγετε το PIN της εφαρμογής';

  @override
  String get launchPinBiometricReason => 'Ξεκλείδωμα Guardian Angela';

  @override
  String get sessionEndBiometricReason =>
      'Επιβεβαιώστε για τη λήξη της συνεδρίας';

  @override
  String get distressCancelBiometricReason =>
      'Επιβεβαιώστε ότι είστε εσείς για ακύρωση';

  @override
  String get launchPinIncorrect => 'Λανθασμένο PIN';

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
  String get stealthLockTaskLabel => 'Καρφίτσωμα εφαρμογής κατά τη συνεδρία';

  @override
  String get stealthLockTaskSubtitle =>
      'Αποτρέπει την έξοδο από την εφαρμογή ενώ τρέχει μια συνεδρία. Στο Android ενεργοποιεί το καρφίτσωμα οθόνης· στις άλλες πλατφόρμες δεν έχει καμία επίδραση.';

  @override
  String get stealthLockTaskInfo =>
      'Καρφιτσώνει το Guardian Angela στην οθόνη για όλη τη διάρκεια της συνεδρίας, ώστε να μην μπορεί να κλείσει με σάρωση ούτε να γίνει εναλλαγή εφαρμογής. Συμβιβασμός: το Android εμφανίζει ένα μήνυμα συστήματος «Η εφαρμογή είναι καρφιτσωμένη» και μπλοκάρει την εναλλαγή εφαρμογών μέχρι να λήξει η συνεδρία — ορατό σε οποιονδήποτε κοιτάζει την οθόνη. Άφησέ το απενεργοποιημένο αν προτιμάς να μετακινείσαι ελεύθερα μεταξύ εφαρμογών κατά τη συνεδρία. Καμία επίδραση σε πλατφόρμες χωρίς καρφίτσωμα οθόνης.';

  @override
  String get homeTagline => 'Ο άγγελός σου σε προσέχει.';

  @override
  String get onboardingWelcomeGreeting => 'Γεια, είμαι η Άντζελα';

  @override
  String get onboardingWelcomeBodyFull =>
      'Είμαι ο προσωπικός σου φύλακας. Σε συνοδεύω, προσέχω τη βραδινή σου έξοδο και αναλαμβάνω δράση αν κάτι δεν πάει καλά.';

  @override
  String get onboardingGetStarted => 'Ξεκινήστε';

  @override
  String get onboardingProfileNameLabel => 'Όνομα';

  @override
  String get onboardingProfilePhoneLabel => 'Αριθμός τηλεφώνου';

  @override
  String get onboardingProfilePhoneHelper =>
      'Συμπεριλαμβάνεται στα μηνύματα έκτακτης ανάγκης.';

  @override
  String get onboardingEmergencyContactHeader => 'Επαφή έκτακτης ανάγκης';

  @override
  String get onboardingEmergencyContactPrompt =>
      'Ποιον να ειδοποιήσουμε αν κάτι πάει στραβά;';

  @override
  String get onboardingEmergencyContactAdd =>
      'Προσθήκη επαφής έκτακτης ανάγκης';

  @override
  String get onboardingPermissionsIntro =>
      'Αυτές οι άδειες σε κρατούν ασφαλή κατά τη διάρκεια των συνεδριών.';

  @override
  String get onboardingPermissionsGrantAll => 'Παραχώρηση όλων';

  @override
  String get onboardingPermissionsRequired => 'ΑΠΑΙΤΕΙΤΑΙ';

  @override
  String get onboardingPermissionsOptional => 'ΠΡΟΑΙΡΕΤΙΚΟ';

  @override
  String get onboardingPermissionsMicrophone => 'Μικρόφωνο';

  @override
  String get onboardingPermissionsCamera => 'Κάμερα';

  @override
  String get onboardingPermissionsNotificationDesc =>
      'Απαιτείται για ειδοποιήσεις και υπενθυμίσεις συνεδρίας.';

  @override
  String get onboardingPermissionsSmsDesc =>
      'Απαιτείται για την αποστολή μηνυμάτων έκτακτης ανάγκης.';

  @override
  String get onboardingPermissionsPhoneDesc =>
      'Απαιτείται για κλήσεις έκτακτης ανάγκης και ψεύτικες κλήσεις.';

  @override
  String get onboardingPermissionsLocationDesc =>
      'Συμπεριλαμβάνεται στα μηνύματα έκτακτης ανάγκης όταν είναι ενεργή η καταγραφή GPS.';

  @override
  String get onboardingPermissionsMicrophoneDesc =>
      'Χρησιμοποιείται για ηχογράφηση κατά τη διάρκεια κινδύνου.';

  @override
  String get onboardingPermissionsCameraDesc =>
      'Χρησιμοποιείται για σήμα SOS με φλας.';

  @override
  String get sessionInterruptedTitle => 'Η συνεδρία διακόπηκε';

  @override
  String get sessionInterruptedBody =>
      'Μια συνεδρία ήταν σε εξέλιξη όταν η εφαρμογή σταμάτησε. Η κατάσταση της συνεδρίας χάθηκε — τίποτα δεν αποκαταστάθηκε. Το εμφανίζουμε για να το γνωρίζετε.';

  @override
  String get sessionInterruptedAcknowledge => 'Κατανοητό';

  @override
  String sessionInterruptedMode(Object name) {
    return 'Λειτουργία: $name';
  }

  @override
  String sessionInterruptedStarted(Object time) {
    return 'Έναρξη: $time';
  }

  @override
  String get sessionInterruptedStartSameMode => 'Έναρξη ίδιας λειτουργίας';

  @override
  String get sessionInterruptedJustNow => 'μόλις τώρα';

  @override
  String sessionInterruptedMinutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'πριν από $count λεπτά',
      one: 'πριν από 1 λεπτό',
    );
    return '$_temp0';
  }

  @override
  String sessionInterruptedHoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'πριν από $count ώρες',
      one: 'πριν από 1 ώρα',
    );
    return '$_temp0';
  }

  @override
  String sessionInterruptedDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'πριν από $count ημέρες',
      one: 'πριν από 1 ημέρα',
    );
    return '$_temp0';
  }

  @override
  String get sessionGpsDestinationTitle => 'Προορισμός';

  @override
  String get sessionGpsDestinationBody =>
      'Εισαγάγετε τις συντεταγμένες προορισμού για τη σκανδάλη αποδέσμευσης κατά την άφιξη μέσω GPS.';

  @override
  String get sessionGpsDestinationLat => 'Γεωγραφικό πλάτος';

  @override
  String get sessionGpsDestinationLng => 'Γεωγραφικό μήκος';

  @override
  String get sessionGpsDestinationSkip => 'Παράλειψη για αυτή τη συνεδρία';

  @override
  String get sessionGpsDestinationConfirm => 'Χρήση προορισμού';

  @override
  String get sessionEndOverlayTitle => 'Τερματισμός συνεδρίας;';

  @override
  String get sessionEndOverlayBody =>
      'Σύρετε για να επιβεβαιώσετε ότι θέλετε να τερματίσετε τη συνεδρία';

  @override
  String get sessionEndOverlaySwipeLabel => 'Σύρετε για τερματισμό';

  @override
  String get sessionEndOverlaySimBadge => '[SIM] Λειτουργία εξάσκησης';

  @override
  String get sessionEndPinPromptTitle =>
      'Εισαγάγετε το PIN τερματισμού συνεδρίας';

  @override
  String get sessionEndPinAppPinMismatch =>
      'Χρησιμοποιήστε το PIN τερματισμού συνεδρίας, όχι το PIN κλειδώματος της εφαρμογής.';

  @override
  String get sessionEndPinIncorrect => 'Λανθασμένο PIN';

  @override
  String get sessionEndPinSimSkip => 'Παράλειψη (μόνο προσομοίωση)';

  @override
  String get sessionEndSimDistressWouldFire =>
      'Η αλυσίδα κινδύνου θα ενεργοποιούνταν (5 λανθασμένα PIN)';

  @override
  String get distressConfirmTitle => 'Ο κίνδυνος ενεργοποιήθηκε';

  @override
  String distressConfirmCountdown(int seconds) {
    return 'Πατήστε για ακύρωση — έχετε $seconds δευτερόλεπτα';
  }

  @override
  String get distressConfirmCancel => 'Πατήστε για ακύρωση';

  @override
  String get distressConfirmFooter =>
      'Αν δεν ακυρωθεί, η αλυσίδα κινδύνου θα ξεκινήσει αμέσως.';

  @override
  String get distressCancelPinPromptTitle =>
      'Εισαγάγετε το PIN τερματισμού συνεδρίας';

  @override
  String distressCancelPinTimeoutLabel(int seconds) {
    return 'Απομένουν $seconds δευτ.';
  }

  @override
  String get distressCancelPinIncorrect => 'Λανθασμένο PIN';

  @override
  String get distressCancelPinAppPinMismatch =>
      'Χρησιμοποιήστε το PIN τερματισμού συνεδρίας, όχι το PIN κλειδώματος της εφαρμογής.';

  @override
  String get distressCancelPinSimSkip => 'Παράλειψη (μόνο προσομοίωση)';

  @override
  String get distressCancelSimDistressWouldFire =>
      'Η αλυσίδα κινδύνου θα ενεργοποιούνταν (5 λανθασμένα PIN)';

  @override
  String get distressCancelPinBack => 'Άκυρο';

  @override
  String get simulationPinPromptTitle => 'Εισαγάγετε το PIN';

  @override
  String get simulationPinPromptBody =>
      'Εξασκηθείτε στην εισαγωγή του PIN τερματισμού συνεδρίας';

  @override
  String get simulationPinPromptSkip => 'Παράλειψη';

  @override
  String get simulationPinIncorrect => 'Λανθασμένο PIN';

  @override
  String simulationSummaryDuration(String duration) {
    return 'Διάρκεια: $duration';
  }

  @override
  String get simulationSummaryTimelineHeader => 'Χρονολόγιο συμβάντων';

  @override
  String get simulationSummaryShare => 'Κοινοποίηση';

  @override
  String simulationSummaryMissedEventsBadge(int count) {
    return 'Χαμένα: $count';
  }

  @override
  String simulationSummaryDistressBadge(int count) {
    return 'Κίνδυνος: $count';
  }

  @override
  String simulationSummaryStepsFiredBadge(int count) {
    return 'Βήματα που ενεργοποιήθηκαν: $count';
  }

  @override
  String get simulationSummaryShareSubject =>
      'Σύνοψη προσομοίωσης Guardian Angela';

  @override
  String get notificationsChannelAlarm => 'Κλιμάκωση συναγερμού';

  @override
  String get notificationsChannelAlarmDescription =>
      'Κρίσιμες ειδοποιήσεις που παρακάμπτουν το «Μην ενοχλείτε»';

  @override
  String get notificationsChannelReminder => 'Μεταμφιεσμένη υπενθύμιση';

  @override
  String get notificationsChannelReminderDescription =>
      'Υπενθυμίσεις δήλωσης ασφάλειας κατά τη διάρκεια ενεργής συνεδρίας';

  @override
  String get notificationsChannelFakeCall => 'Ψεύτικη κλήση';

  @override
  String get notificationsChannelFakeCallDescription =>
      'Ειδοποιήσεις εισερχόμενης κλήσης πλήρους οθόνης';

  @override
  String get notificationsChannelEnabled => 'Ενεργό';

  @override
  String get notificationsChannelDisabled => 'Ανενεργό';

  @override
  String get notificationsChannelsHeader => 'Κανάλια ειδοποιήσεων';

  @override
  String get contactsImportFromDevice => 'Εισαγωγή από επαφές';

  @override
  String get contactsImportNotSupported => 'Μη διαθέσιμο σε αυτή την πλατφόρμα';

  @override
  String get contactsImportPermissionDenied =>
      'Η πρόσβαση στις επαφές απορρίφθηκε. Ενεργοποιήστε την στις ρυθμίσεις συστήματος.';

  @override
  String get contactsDeleteAllMenu => 'Διαγραφή όλων';

  @override
  String get contactsDeleteAllConfirmTitle => 'Διαγραφή όλων των επαφών;';

  @override
  String get contactsDeleteAllConfirmBody =>
      'Αυτό αφαιρεί κάθε επαφή έκτακτης ανάγκης. Δεν υπάρχει αναίρεση.';

  @override
  String get contactsDeleteAllTypeConfirmTitle =>
      'Επιβεβαίωση με πληκτρολόγηση';

  @override
  String get contactsDeleteAllTypeConfirmHint =>
      'Πληκτρολογήστε DELETE ALL για να συνεχίσετε';

  @override
  String get contactsDeleteAllTypeConfirmSentinel => 'DELETE ALL';

  @override
  String get contactsDeleteAllConfirmButton => 'Διαγραφή όλων';

  @override
  String get modesBuiltinBadge => 'Ενσωματωμένη';

  @override
  String get modesBuiltinNoDelete =>
      'Οι ενσωματωμένες λειτουργίες δεν μπορούν να διαγραφούν';

  @override
  String get sessionCompletedSimulationBanner => 'Η προσομοίωση ολοκληρώθηκε';

  @override
  String get sessionCompletedViewEventLog =>
      'Προβολή αρχείου καταγραφής συμβάντων';

  @override
  String get settingsGeneralHeader => 'Γενικά';

  @override
  String get settingsAppHeader => 'Εφαρμογή';

  @override
  String get settingsConfigurationHeader => 'Διαμόρφωση';

  @override
  String get settingsThemeLabel => 'Θέμα';

  @override
  String get settingsLanguageLabel => 'Γλώσσα';

  @override
  String get settingsSecurityRow => 'Ασφάλεια';

  @override
  String get settingsSecuritySubtitle =>
      'PIN εφαρμογής, PIN τερματισμού συνεδρίας, PIN εξαναγκασμού';

  @override
  String get settingsStealthRow => 'Κρυφή λειτουργία';

  @override
  String get settingsStealthSummaryOff => 'Κρυφή λειτουργία: ΑΝΕΝΕΡΓΗ';

  @override
  String get settingsStealthSummaryOn => 'Κρυφή λειτουργία: ΕΝΕΡΓΗ';

  @override
  String get settingsProfileRow => 'Προφίλ';

  @override
  String get settingsModesRow => 'Λειτουργίες';

  @override
  String get settingsDistressModesRow => 'Λειτουργίες κινδύνου';

  @override
  String get settingsEventDefaultsRow => 'Προεπιλογές συμβάντων';

  @override
  String get settingsGpsLoggingRow => 'Καταγραφή GPS';

  @override
  String get settingsRemindersRow => 'Πρότυπα υπενθύμισης';

  @override
  String get settingsNotificationsRow => 'Ειδοποιήσεις';

  @override
  String get settingsHistoryRetentionRow => 'Ιστορικό και διατήρηση';

  @override
  String get settingsAboutRow => 'Σχετικά';

  @override
  String get settingsFeedbackRow => 'Αποστολή σχολίων';

  @override
  String get settingsBackupRow => 'Αντίγραφο ασφαλείας και επαναφορά';

  @override
  String get settingsOssLicenses => 'Άδειες ανοιχτού κώδικα';

  @override
  String get settingsImportConfirmBody =>
      'Αυτό θα αντικαταστήσει όλα τα τρέχοντα δεδομένα. Συνέχεια;';

  @override
  String get securityAppPinTitle => 'PIN εφαρμογής';

  @override
  String get securityAppPinBody =>
      'Κλειδώνει την εφαρμογή κάθε φορά που την ανοίγετε.';

  @override
  String get securitySessionEndPinTitle => 'PIN τερματισμού συνεδρίας';

  @override
  String get securitySessionEndPinBody =>
      'Απαιτείται για την αποδέσμευση ή τον τερματισμό μιας ενεργής συνεδρίας.';

  @override
  String get securityDuressPinTitle => 'PIN εξαναγκασμού';

  @override
  String get securityDuressPinBody =>
      'Εισάγεται σε οποιαδήποτε προτροπή για σιωπηλή ενεργοποίηση της αλυσίδας κινδύνου.';

  @override
  String get securityRemovePin => 'Αφαίρεση';

  @override
  String get securityRemovePinPrompt =>
      'Εισαγάγετε το τρέχον PIN σας για να το αφαιρέσετε.';

  @override
  String get securityRemovePinIncorrect => 'Λανθασμένο PIN';

  @override
  String get securityWhatIsThis => 'Τι είναι αυτό;';

  @override
  String get securityAppPinInfo =>
      'Κλειδώνει την εφαρμογή όταν την ανοίγετε. Το πληκτρολόγιο εμφανίζεται πριν από οποιαδήποτε οθόνη. Χρήσιμο αν κάποιος κρατήσει για λίγο το ξεκλείδωτο τηλέφωνό σας.';

  @override
  String get securitySessionEndPinInfo =>
      'Απαιτείται για την αποδέσμευση ή τον τερματισμό μιας ενεργής συνεδρίας ασφαλείας. Χωρίς αυτό, ένας επιτιθέμενος που παίρνει το τηλέφωνό σας δεν μπορεί να σταματήσει την αλυσίδα. Ορίστε διαφορετικό κωδικό από το PIN της εφαρμογής σας.';

  @override
  String get securityDuressPinInfo =>
      'Αν εισαγάγετε ποτέ αυτό το PIN σε οποιαδήποτε προτροπή, η αλυσίδα κινδύνου εκτελείται σιωπηλά — οι επαφές σας ειδοποιούνται και ο συναγερμός προετοιμάζεται χωρίς να το αντιληφθεί ο επιτιθέμενος. Επιλέξτε κωδικό διαφορετικό από κάθε άλλο PIN.';

  @override
  String get securityPinTimeoutLabel => 'Χρονικό όριο PIN (δευτερόλεπτα)';

  @override
  String get securityWrongPinThresholdLabel =>
      'Λανθασμένες προσπάθειες PIN πριν την κλιμάκωση';

  @override
  String get securityDeceptiveDialogToggle =>
      'Εμφάνιση παραπλανητικού διαλόγου σε λανθασμένο PIN';

  @override
  String get pinSetupEnterNew => 'Εισαγάγετε νέο PIN';

  @override
  String get pinSetupConfirmNew => 'Επιβεβαιώστε το νέο PIN';

  @override
  String get pinSetupTooShort => 'Το PIN πρέπει να έχει τουλάχιστον 4 ψηφία.';

  @override
  String get pinSetupCollision =>
      'Αυτό το PIN συγκρούεται με άλλο διαμορφωμένο PIN.';

  @override
  String get pinSetupSaved => 'Το PIN αποθηκεύτηκε';

  @override
  String get stealthEnabledLabel => 'Ενεργοποίηση κρυφής λειτουργίας';

  @override
  String get stealthFakeNameLabel => 'Ψεύτικο όνομα εφαρμογής';

  @override
  String get stealthFakeIconLabel => 'Ψεύτικο εικονίδιο';

  @override
  String get stealthNotificationDisguiseLabel => 'Μεταμφίεση ειδοποιήσεων';

  @override
  String get stealthTimerDisplayLabel => 'Εμφάνιση χρονομέτρου';

  @override
  String get stealthSessionScreenLabel => 'Κρυφή οθόνη συνεδρίας';

  @override
  String get gpsLoggingEnabled => 'Καταγραφή GPS κατά τις συνεδρίες';

  @override
  String get gpsLoggingIntervalLabel => 'Διάστημα';

  @override
  String get gpsLoggingAccuracyLabel => 'Ακρίβεια';

  @override
  String get gpsLoggingAccuracyHigh => 'Υψηλή';

  @override
  String get gpsLoggingAccuracyBalanced => 'Ισορροπημένη';

  @override
  String get gpsLoggingAccuracyLow => 'Χαμηλή';

  @override
  String get gpsLoggingFormatLabel => 'Μορφή συντεταγμένων';

  @override
  String get gpsLoggingFormatDecimal => 'Δεκαδική';

  @override
  String get gpsLoggingFormatDms => 'DMS';

  @override
  String get gpsLoggingFormatAddress => 'Plus Code';

  @override
  String get gpsLoggingIncludeInSms => 'Προσθήκη τοποθεσίας στο SMS';

  @override
  String get historyRetentionLogsLabel =>
      'Διατήρηση αρχείων συνεδρίας (ημέρες)';

  @override
  String get historyRetentionLogsHelper =>
      'Τα αρχεία παλαιότερα από αυτό μετακινούνται στον κάδο.';

  @override
  String get historyRetentionTrashLabel => 'Διατήρηση κάδου (ημέρες)';

  @override
  String get historyRetentionTrashHelper =>
      'Τα αρχεία στον κάδο διαγράφονται οριστικά μετά από αυτό το διάστημα.';

  @override
  String get historyRetentionUpdated => 'Η διατήρηση ενημερώθηκε';

  @override
  String get historyRetentionPurgeNow => 'Εκκαθάριση τώρα';

  @override
  String historyRetentionPurged(Object count) {
    return 'Εκκαθαρίστηκαν $count αρχεία';
  }

  @override
  String get eventDefaultsCheckInHeader => 'Μέθοδοι δήλωσης ασφάλειας';

  @override
  String get eventDefaultsEscalationHeader => 'Βήματα κλιμάκωσης';

  @override
  String get eventDefaultsPanicHeader => 'Σκανδάλη πανικού';

  @override
  String get templatesCreate => 'Δημιουργία προτύπου';

  @override
  String get templatesEditTitle => 'Επεξεργασία προτύπου';

  @override
  String get templatesCreateTitle => 'Νέο πρότυπο';

  @override
  String get templatesNameLabel => 'Όνομα';

  @override
  String get templatesTitleLabel => 'Τίτλος';

  @override
  String get templatesBodyLabel => 'Κείμενο';

  @override
  String get templatesBuiltinNoDelete =>
      'Τα ενσωματωμένα πρότυπα δεν μπορούν να διαγραφούν';

  @override
  String get templatesAddFromTemplate => 'Από πρότυπο';

  @override
  String get templatesAddFromScratch => 'Από την αρχή';

  @override
  String templatesDeleteConfirmTitle(Object name) {
    return 'Διαγραφή «$name»;';
  }

  @override
  String get templatesDeleteConfirmBody =>
      'Αυτό το πρότυπο θα αφαιρεθεί οριστικά.';

  @override
  String get templatesEmptyAddFirst => 'Προσθέστε το πρώτο σας πρότυπο';

  @override
  String get templatesPickFromBuiltinTitle =>
      'Επιλέξτε ένα ενσωματωμένο πρότυπο';

  @override
  String get templatesIconLabel => 'Εικονίδιο';

  @override
  String get templatesIconCalendar => 'Ημερολόγιο';

  @override
  String get templatesIconAppNotification => 'Ειδοποίηση εφαρμογής';

  @override
  String get templatesIconFitness => 'Φυσική κατάσταση';

  @override
  String get templatesIconHealth => 'Υγεία';

  @override
  String get templatesIconFood => 'Φαγητό';

  @override
  String get templatesIconCoffee => 'Καφές';

  @override
  String get templatesIconBattery => 'Μπαταρία';

  @override
  String get templatesIconWeather => 'Καιρός';

  @override
  String get templatesPreviewHeading => 'Ζωντανή προεπισκόπηση';

  @override
  String get templatesDiscardChangesTitle => 'Απόρριψη αλλαγών;';

  @override
  String get templatesDiscardChangesBody =>
      'Οι μη αποθηκευμένες αλλαγές θα χαθούν.';

  @override
  String get templatesDiscardKeep => 'Συνέχιση επεξεργασίας';

  @override
  String get templatesDiscardDiscard => 'Απόρριψη';

  @override
  String get notificationsTitle => 'Ειδοποιήσεις';

  @override
  String get notificationsStatusGranted => 'Παραχωρήθηκε';

  @override
  String get notificationsStatusDenied => 'Απορρίφθηκε';

  @override
  String get notificationsStatusUnknown => 'Δεν έχει ζητηθεί ακόμη';

  @override
  String get notificationsRequest => 'Αίτημα άδειας';

  @override
  String get notificationsOpenSettings => 'Άνοιγμα ρυθμίσεων συστήματος';

  @override
  String get profileFieldPhone => 'Αριθμός τηλεφώνου';

  @override
  String get profileFieldDescription => 'Σωματική περιγραφή';

  @override
  String get profileFieldMedicalConditions => 'Ιατρικές παθήσεις';

  @override
  String get profileFieldEmergencyInstructions => 'Οδηγίες έκτακτης ανάγκης';

  @override
  String get aboutAuthor => 'Δημιουργός: Jonas Eschle';

  @override
  String get aboutEmail => 'guardian.angela.app@gmail.com';

  @override
  String get aboutPrivacyPolicy => 'Πολιτική απορρήτου';

  @override
  String get aboutTermsOfService => 'Όροι χρήσης';

  @override
  String get aboutSourceCode => 'Πηγαίος κώδικας';

  @override
  String get aboutSupport => 'Υποστήριξη / δωρεά';

  @override
  String get aboutLicenses => 'Άδειες ανοιχτού κώδικα';

  @override
  String get aboutTagline =>
      'Φτιαγμένο με αγάπη για την ασφάλεια της κοινότητας LGBTQ+.';

  @override
  String get aboutTechnicalSection => 'Τεχνικές πληροφορίες';

  @override
  String aboutBundleId(Object id) {
    return 'Bundle ID: $id';
  }

  @override
  String aboutPlatforms(Object list) {
    return 'Πλατφόρμες: $list';
  }

  @override
  String get feedbackHeading => 'Θα θέλαμε να ακούσουμε τη γνώμη σας';

  @override
  String get feedbackCategoryLabel => 'Κατηγορία';

  @override
  String get feedbackCategoryBug => 'Αναφορά σφάλματος';

  @override
  String get feedbackCategoryFeature => 'Αίτημα λειτουργίας';

  @override
  String get feedbackCategoryOther => 'Άλλο';

  @override
  String get feedbackEmailLabel => 'Email (προαιρετικό)';

  @override
  String get feedbackMessageLabel => 'Μήνυμα';

  @override
  String get feedbackIncludeLog => 'Συμπερίληψη αρχείου τελευταίας συνεδρίας';

  @override
  String get feedbackSent => 'Ευχαριστούμε για τα σχόλιά σας!';

  @override
  String get feedbackMessageRequired =>
      'Το μήνυμα πρέπει να έχει τουλάχιστον 10 χαρακτήρες.';

  @override
  String get backupIncludeLogs => 'Συμπερίληψη αρχείων συνεδρίας';

  @override
  String get backupIncludeMedia => 'Συμπερίληψη πολυμέσων';

  @override
  String get backupExportButton => 'Εξαγωγή';

  @override
  String get backupImportButton => 'Εισαγωγή';

  @override
  String get backupOverwriteWarning =>
      'Η εισαγωγή αντικαθιστά όλα τα τρέχοντα δεδομένα.';

  @override
  String get backupImportSuccess =>
      'Η εισαγωγή ολοκληρώθηκε. Επανεκκινήστε για εφαρμογή.';

  @override
  String backupImportError(Object message) {
    return 'Η εισαγωγή απέτυχε: $message';
  }

  @override
  String get backupActiveSessionBanner =>
      'Το αντίγραφο ασφαλείας δεν είναι διαθέσιμο κατά τη διάρκεια ενεργής συνεδρίας.';

  @override
  String backupLastBackupAtLabel(Object when) {
    return 'Τελευταίο αντίγραφο ασφαλείας στις $when';
  }

  @override
  String get backupNeverExportedLabel =>
      'Δεν υπάρχει ακόμη αντίγραφο ασφαλείας';

  @override
  String get pastEventsTitle => 'Προηγούμενες συνεδρίες';

  @override
  String get pastEventsTabReal => 'Πραγματικές';

  @override
  String get pastEventsTabSimulated => 'Προσομοιωμένες';

  @override
  String get pastEventsEmpty => 'Δεν υπάρχουν ακόμη συνεδρίες';

  @override
  String get pastEventsDeleteConfirm => 'Διαγραφή αρχείου συνεδρίας;';

  @override
  String get pastEventsDetailShareText => 'Κοινοποίηση ως κείμενο';

  @override
  String get pastEventsDetailSharePdf => 'Κοινοποίηση ως PDF';

  @override
  String get pastEventsDetailDelete => 'Διαγραφή';

  @override
  String get pastEventsOutcomeCompleted => 'Ολοκληρώθηκε';

  @override
  String get pastEventsOutcomeDistress => 'Κίνδυνος';

  @override
  String get pastEventsOutcomeInterrupted => 'Διακόπηκε';

  @override
  String get pastEventsTrash => 'Κάδος';

  @override
  String get pastEventsUndo => 'Αναίρεση';

  @override
  String get pastEventsSoftDeleted => 'Μετακινήθηκε στον κάδο';

  @override
  String get pastEventsDetailTitle => 'Αρχείο συνεδρίας';

  @override
  String get pastEventsDetailShare => 'Κοινοποίηση';

  @override
  String get contactUnsavedDiscardTitle => 'Απόρριψη μη αποθηκευμένων αλλαγών;';

  @override
  String get contactUnsavedDiscardKeep => 'Συνέχιση επεξεργασίας';

  @override
  String get contactUnsavedDiscardDiscard => 'Απόρριψη';

  @override
  String get modesDuplicate => 'Δημιουργία αντιγράφου';

  @override
  String get modesDeleteConfirmTitle => 'Διαγραφή λειτουργίας;';

  @override
  String modesDeleteConfirmBody(Object name) {
    return 'Η λειτουργία $name θα αφαιρεθεί οριστικά.';
  }

  @override
  String get modesDistressDefaultBadge => 'Προεπιλογή';

  @override
  String get modesDistressSetDefault => 'Ορισμός ως προεπιλογή';

  @override
  String get modesDistressCantDeleteLast =>
      'Απαιτείται τουλάχιστον μία λειτουργία κινδύνου.';

  @override
  String get modesDistressInUse =>
      'Αυτή η λειτουργία κινδύνου χρησιμοποιείται από άλλη λειτουργία.';

  @override
  String get modesDistressTitle => 'Λειτουργίες κινδύνου';

  @override
  String get validationNameTooShort =>
      'Το όνομα πρέπει να έχει τουλάχιστον 2 χαρακτήρες.';

  @override
  String get validationPhoneRequired =>
      'Ο αριθμός τηλεφώνου είναι υποχρεωτικός.';

  @override
  String get validationChannelsRequired => 'Επιλέξτε τουλάχιστον ένα κανάλι.';

  @override
  String get validationChainEmpty =>
      'Προσθέστε τουλάχιστον ένα βήμα πριν την αποθήκευση.';

  @override
  String get validationGpsFixedCoords =>
      'Ορίστε γεωγραφικό πλάτος και μήκος για τον σταθερό προορισμό άφιξης.';

  @override
  String get validationHardwareTrigger =>
      'Ο ενεργοποιητής πανικού υλικού είναι ελλιπής — ελέγξτε τον αριθμό πατημάτων ή τη διάρκεια κρατήματος.';

  @override
  String get validationSmsChannelNotOnContacts =>
      'Καμία από τις επιλεγμένες επαφές δεν μπορεί να λάβει μέσω του καναλιού αυτού του βήματος. Επιλέξτε άλλο κανάλι ή προσθέστε το σε μια επαφή.';

  @override
  String get validationDistressNoActionTitle =>
      'Κανένα εξερχόμενο βήμα ειδοποίησης';

  @override
  String get validationDistressNoActionBody =>
      'Αυτή η λειτουργία κινδύνου δεν έχει βήμα SMS ή κλήσης, επομένως δεν αφήνει εξερχόμενο ίχνος. Αποθήκευση ούτως ή άλλως;';

  @override
  String get validationSaveAnyway => 'Αποθήκευση ούτως ή άλλως';

  @override
  String get sessionHoldTouchToBegin => 'Αγγίξτε για έναρξη';

  @override
  String sessionHoldReleaseCountdown(Object seconds) {
    return 'Αντίστροφη μέτρηση: $secondsδ';
  }

  @override
  String sessionHoldGraceCountdown(Object seconds) {
    return 'Περιθώριο: $secondsδ — κρατήστε ξανά για να μείνετε ασφαλείς';
  }

  @override
  String get sessionHoldAgain => 'Κρατήστε ξανά για να μείνετε ασφαλείς';

  @override
  String sessionStepNextCheckIn(Object time) {
    return 'Επόμενη δήλωση ασφάλειας σε $time';
  }

  @override
  String sessionStepFakeCallActive(Object caller) {
    return 'Εισερχόμενη κλήση από $caller';
  }

  @override
  String get sessionStepFakeCallOpen => 'Άνοιγμα οθόνης κλήσης';

  @override
  String sessionStepSimBlockedSms(Object count) {
    return '[SIM] Θα στελνόταν SMS σε $count επαφές';
  }

  @override
  String get sessionStepSimBlockedPhone =>
      '[SIM] Θα γινόταν κλήση στην επαφή έκτακτης ανάγκης';

  @override
  String get sessionStepSimBlockedEmergency =>
      '[SIM] Θα γινόταν κλήση στις υπηρεσίες έκτακτης ανάγκης';

  @override
  String get sessionStepSimBlockedAlarm =>
      '[SIM] Ο συναγερμός θα είχε ηχήσει σε πλήρη ένταση';

  @override
  String get sessionStartFailedTitle => 'Δεν είναι δυνατή η έναρξη συνεδρίας';

  @override
  String get sessionStartFailedBody =>
      'Διορθώστε τα παρακάτω ζητήματα πριν την έναρξη:';

  @override
  String get sessionQuickExitTitle => 'Γρήγορη έξοδος';

  @override
  String get sessionQuickExitBody =>
      'Τα δεδομένα της συνεδρίας θα διατηρηθούν και θα κρυπτογραφηθούν. Ανοίξτε ξανά την εφαρμογή οποιαδήποτε στιγμή για να τα ανακτήσετε.';

  @override
  String get sessionQuickExitConfirm => 'Έξοδος από την εφαρμογή';

  @override
  String get pastEventsRestore => 'Επαναφορά';

  @override
  String get stepEditorWait => 'Αναμονή (δ)';

  @override
  String get stepEditorDuration => 'Διάρκεια (δ)';

  @override
  String get stepEditorGrace => 'Περιθώριο (δ)';

  @override
  String get stepEditorRetryCount => 'Αριθμός επαναλήψεων';

  @override
  String get stepEditorRandomize => 'Τυχαίος χρονισμός (±20%)';

  @override
  String get stepEditorRemove => 'Αφαίρεση βήματος';

  @override
  String get eventDefaultsHoldStyle => 'Στυλ κρατήματος';

  @override
  String get eventDefaultsHoldSensitivity => 'Ευαισθησία απελευθέρωσης';

  @override
  String get eventDefaultsHoldVibrate => 'Δόνηση κατά την απελευθέρωση';

  @override
  String get eventDefaultsHoldSound => 'Ήχος κατά την απελευθέρωση';

  @override
  String get eventDefaultsBlackScreen => 'Επικάλυψη μαύρης οθόνης';

  @override
  String get eventDefaultsReminderRandomInterval => 'Τυχαίο διάστημα';

  @override
  String get eventDefaultsReminderRandomTemplate => 'Τυχαία σειρά προτύπων';

  @override
  String get eventDefaultsReminderResetOnEarly =>
      'Επαναφορά σε πρόωρη δήλωση ασφάλειας';

  @override
  String get eventDefaultsCountdownStyle => 'Στυλ αντίστροφης μέτρησης';

  @override
  String get eventDefaultsCountdownVibrate => 'Δόνηση';

  @override
  String get eventDefaultsCountdownSound => 'Ήχος';

  @override
  String get eventDefaultsFakeCallStyle => 'Στυλ κλήσης';

  @override
  String get eventDefaultsFakeCallCallerName => 'Όνομα καλούντος';

  @override
  String get eventDefaultsFakeCallRingDuration => 'Διάρκεια κουδουνίσματος (δ)';

  @override
  String get eventDefaultsFakeCallDeclineIsSafe =>
      'Η απόρριψη μετράει ως ασφάλεια';

  @override
  String get eventDefaultsFakeCallVoiceOutput => 'Φωνητική έξοδος';

  @override
  String get eventDefaultsSmsChannel => 'Κανάλι';

  @override
  String get eventDefaultsSmsIncludeLocation => 'Συμπερίληψη τοποθεσίας';

  @override
  String get eventDefaultsSmsIncludeMedical =>
      'Συμπερίληψη ιατρικών πληροφοριών';

  @override
  String get eventDefaultsSmsAutoRecord => 'Ηχογράφηση πριν την αποστολή';

  @override
  String get eventDefaultsSmsRecordDuration => 'Διάρκεια ηχογράφησης (δ)';

  @override
  String get eventDefaultsSmsMessageTemplate => 'Πρότυπο μηνύματος';

  @override
  String get eventDefaultsSmsMessageTemplateHint =>
      'Αφήστε το κενό για χρήση της προεπιλεγμένης ειδοποίησης. Πατήστε ένα σύμβολο κράτησης θέσης για να το εισαγάγετε.';

  @override
  String get eventDefaultsSmsIosWarning =>
      'Στο iPhone, το SMS απαιτεί να πατήσετε χειροκίνητα «Αποστολή» στην εφαρμογή Μηνύματα. Αν δεν μπορείτε να χειριστείτε το τηλέφωνό σας, το μήνυμα δεν θα σταλεί. Εξετάστε το WhatsApp ή το Telegram.';

  @override
  String get eventDefaultsLoudAlarmVolume => 'Ένταση';

  @override
  String get eventDefaultsLoudAlarmSound => 'Ήχος';

  @override
  String get eventDefaultsLoudAlarmFlashScreen => 'Αναβόσβησμα οθόνης';

  @override
  String get eventDefaultsLoudAlarmFlashLight => 'Αναβόσβησμα φωτός κάμερας';

  @override
  String get eventDefaultsLoudAlarmGradual => 'Σταδιακή αύξηση έντασης';

  @override
  String get eventDefaultsCallEmergencyNumber =>
      'Αριθμός έκτακτης ανάγκης (παράκαμψη)';

  @override
  String get eventDefaultsCallEmergencyConfirm =>
      'Εμφάνιση αντίστροφης μέτρησης επιβεβαίωσης';

  @override
  String get eventDefaultsCallEmergencyConfirmDuration =>
      'Δευτερόλεπτα επιβεβαίωσης';

  @override
  String get eventDefaultsCallEmergencySmsFirst =>
      'Αποστολή SMS τοποθεσίας πρώτα';

  @override
  String get eventDefaultsCallEmergencyIosWarning =>
      'Στο iPhone, πριν την κλήση θα εμφανιστεί παράθυρο επιβεβαίωσης. Πατήστε γρήγορα «Κλήση».';

  @override
  String get eventDefaultsPhonePrimaryContact => 'Κύρια επαφή (id)';

  @override
  String get eventDefaultsHardwareButton => 'Πλήκτρο';

  @override
  String get eventDefaultsHardwarePattern => 'Μοτίβο πατήματος';

  @override
  String get eventDefaultsHardwarePressCount => 'Αριθμός πατημάτων';

  @override
  String get eventDefaultsHardwareLongDuration =>
      'Διάρκεια παρατεταμένου πατήματος (δ)';

  @override
  String get pastEventsTrashTitle => 'Κάδος';

  @override
  String get pastEventsTrashEmpty => 'Ο κάδος είναι άδειος';

  @override
  String get pastEventsTrashEmptyAll => 'Άδειασμα κάδου';

  @override
  String get pastEventsTrashEmptyAllConfirmTitle => 'Άδειασμα κάδου;';

  @override
  String get pastEventsTrashEmptyAllConfirmBody =>
      'Πληκτρολογήστε EMPTY TRASH παρακάτω για επιβεβαίωση. Αυτό διαγράφει οριστικά κάθε αρχείο στον κάδο.';

  @override
  String pastEventsTrashEmptyAllSuccess(Object count) {
    return 'Ο κάδος άδειασε ($count αρχεία)';
  }

  @override
  String pastEventsTrashRetentionNote(int days) {
    return 'Τα αρχεία στον κάδο διαγράφονται οριστικά μετά από $days ημέρες.';
  }

  @override
  String pastEventsTrashRemainingDays(int days) {
    return '$days ημέρα(ες) έως την οριστική διαγραφή';
  }

  @override
  String get pastEventsTrashDeletePermanently => 'Οριστική διαγραφή';

  @override
  String get pastEventsTrashDeletePermanentlyBody =>
      'Αυτή η ενέργεια δεν μπορεί να αναιρεθεί.';

  @override
  String sessionEmergencyConfirmTitle(String number, int seconds) {
    return 'Κλήση $number σε $secondsδ';
  }

  @override
  String get sessionEmergencyConfirmSwipe => 'Σύρετε για ακύρωση';

  @override
  String get sessionEmergencyConfirmKeep => 'Συνέχιση κλήσης';

  @override
  String get sessionEmergencyConfirmSimBadge => '[SIM] Λειτουργία εξάσκησης';

  @override
  String get sessionEmergencyConfirmSimCancelled =>
      'Προσομοιωμένη ακύρωση — η κλήση δεν θα είχε πραγματοποιηθεί';

  @override
  String get swipeSliderSemantics => 'Σύρετε για επιβεβαίωση';

  @override
  String get homeWidgetStatusIdle => 'Σε αναμονή';

  @override
  String get homeWidgetStatusSession => 'Ενεργή συνεδρία';

  @override
  String get homeWidgetStatusSim => 'Ενεργή προσομοίωση';

  @override
  String get homeWidgetQuickExit => 'Γρήγορη έξοδος';

  @override
  String get homeWidgetFakeCall => 'Ψεύτικη κλήση';

  @override
  String get settingsAlarmHeader => 'Συναγερμός';

  @override
  String get settingsAlarmDndOverrideLabel =>
      'Ο συναγερμός παρακάμπτει τη σίγαση/δόνηση';

  @override
  String get settingsAlarmDndOverrideWarning =>
      'Προειδοποίηση: ο συναγερμός θα είναι αθόρυβος αν το τηλέφωνό σας είναι σε σίγαση.';

  @override
  String get settingsAlarmDndOverrideInfo =>
      'Όταν ενεργοποιηθεί, ο δυνατός συναγερμός ηχεί στη μέγιστη ένταση ακόμη κι αν το τηλέφωνο είναι σε σίγαση ή δόνηση. Στο Android χρησιμοποιεί το κανάλι ήχου συναγερμού για να παρακάμψει τη λειτουργία «Μην ενοχλείτε». Ο συναγερμός είναι το μόνο συμβάν που μπορεί να παρακάμψει τις ρυθμίσεις ήχου του τηλεφώνου σας.';

  @override
  String get settingsAlarmGradualLabel => 'Σταδιακή αύξηση έντασης συναγερμού';

  @override
  String get settingsAlarmGradualInfo =>
      'Ξεκινά τον συναγερμό σιγά και τον ανεβάζει σταδιακά στη μέγιστη ένταση. Αυτός είναι ο κεντρικός διακόπτης για όλη την εφαρμογή· κάθε βήμα συναγερμού έχει επίσης τη δική του επιλογή σταδιακής έντασης, και πρέπει να είναι ενεργά και τα δύο για να εφαρμοστεί η σταδιακή αύξηση.';

  @override
  String get settingsAlarmRampLabel => 'Διάρκεια ανόδου';

  @override
  String get settingsAlarmRampInfo =>
      'Πόσο χρόνο χρειάζεται ο συναγερμός για να φτάσει στη μέγιστη ένταση από το μηδέν, ανεβαίνοντας ομοιόμορφα σε αυτό το διάστημα. Δεν έχει καμία επίδραση όταν η σταδιακή ένταση είναι ανενεργή.';

  @override
  String get permissionNotifRationaleTitle =>
      'Να επιτρέπονται οι ειδοποιήσεις;';

  @override
  String get permissionNotifRationaleBody =>
      'Το Guardian Angela χρησιμοποιεί ειδοποιήσεις για να ειδοποιεί εσάς και τις επαφές σας κατά τη διάρκεια μιας συνεδρίας ασφαλείας, συμπεριλαμβανομένων μεταμφιεσμένων υπενθυμίσεων που ξυπνούν το κλειδωμένο τηλέφωνό σας. Επιτρέψτε τις ειδοποιήσεις ώστε η εφαρμογή να μπορεί να σας προσεγγίσει.';

  @override
  String get permissionNotifDeniedTitle =>
      'Οι ειδοποιήσεις είναι αποκλεισμένες';

  @override
  String get permissionNotifDeniedBody =>
      'Οι ειδοποιήσεις είναι απενεργοποιημένες για το Guardian Angela. Ανοίξτε τις ρυθμίσεις συστήματος για να τις ενεργοποιήσετε ξανά, ώστε η εφαρμογή να μπορεί να σας ειδοποιεί κατά τη διάρκεια μιας συνεδρίας.';

  @override
  String get permissionNotifAllow => 'Να επιτρέπεται';

  @override
  String get permissionNotifOpenSettings => 'Άνοιγμα ρυθμίσεων';

  @override
  String get permissionNotifNotNow => 'Όχι τώρα';

  @override
  String get homeStartTriggersSummaryTitle => 'Πριν ξεκινήσετε';

  @override
  String get homeStartTriggersDistressHeading => 'Ενεργοποιητής κινδύνου';

  @override
  String get homeStartTriggersDisarmHeading => 'Ενεργοποιητής αυτόματης λήξης';

  @override
  String get homeStartTriggersNone => 'Κανένας ρυθμισμένος';

  @override
  String homeStartTriggerButtonRepeat(String button, String count) {
    return 'Πατήστε $button $count φορές';
  }

  @override
  String homeStartTriggerButtonLong(String button, String seconds) {
    return 'Κρατήστε το $button για $seconds δευτ.';
  }

  @override
  String get homeStartTriggerButtonVolumeUp => 'Αύξηση έντασης';

  @override
  String get homeStartTriggerButtonVolumeDown => 'Μείωση έντασης';

  @override
  String homeStartTriggerGpsArrival(String radius) {
    return 'Λήγει με την άφιξη εντός $radius μ. από τον προορισμό σας';
  }

  @override
  String get homeStartTriggerGpsPrompt =>
      'Θα σας ζητηθεί ο προορισμός μετά την έναρξη';

  @override
  String homeStartTriggerTimer(String minutes) {
    return 'Λήγει αυτόματα μετά από $minutes λεπτά';
  }

  @override
  String get homeStartTriggersContinue => 'Έναρξη τώρα';

  @override
  String get homeStartTriggersCancel => 'Ακύρωση';

  @override
  String get homeStartBlockedNotifTitle => 'Απαιτούνται ειδοποιήσεις';

  @override
  String get homeStartBlockedNotifBody =>
      'Αυτή η λειτουργία χρησιμοποιεί ειδοποιήσεις (μεταμφιεσμένες υπενθυμίσεις ή ψεύτικες κλήσεις) για την ασφάλειά σας, αλλά η άδεια ειδοποιήσεων είναι απενεργοποιημένη. Ενεργοποιήστε τις ειδοποιήσεις για να ξεκινήσετε αυτή τη λειτουργία.';
}
