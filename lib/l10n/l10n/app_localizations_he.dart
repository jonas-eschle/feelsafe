// ignore: unused_import

import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hebrew (`he`).
class AppLocalizationsHe extends AppLocalizations {
  AppLocalizationsHe([String locale = 'he']) : super(locale);

  @override
  String get appTitle => 'Guardian Angela';

  @override
  String get commonSave => 'שמור';

  @override
  String get angelaDialogTitle => 'הוזן PIN ישן';

  @override
  String get angelaDialogBody =>
      'נראה שהשתמשת ב-PIN ישן. את/ה בטוח/ה שברצונך להמשיך?';

  @override
  String get angelaDialogCancel => 'ביטול';

  @override
  String get angelaDialogConfirm => 'המשך';

  @override
  String get commonCancel => 'ביטול';

  @override
  String get commonOk => 'אישור';

  @override
  String get commonDelete => 'מחק';

  @override
  String get commonEdit => 'ערוך';

  @override
  String get commonClose => 'סגור';

  @override
  String get commonConfirm => 'אישור';

  @override
  String get commonBack => 'חזור';

  @override
  String get pinSubmit => 'שלח';

  @override
  String get homeTitle => 'Guardian Angela';

  @override
  String get homeStartSession => 'התחל מושב';

  @override
  String get homePermissionsNotification => 'התראות';

  @override
  String get homePermissionsLocation => 'מיקום';

  @override
  String get homePermissionsCallPhone => 'שיחות טלפון';

  @override
  String get homePermissionsSendSms => 'שליחת SMS';

  @override
  String get homeSimulate => 'סימולציה';

  @override
  String get homeNoModes => 'אין מצבים עדיין. הקש על מצבים כדי להוסיף.';

  @override
  String get homeContactsBannerNone => 'לא הוגדרו אנשי קשר לחירום.';

  @override
  String get homeMenuSettings => 'הגדרות';

  @override
  String get homeMenuContacts => 'אנשי קשר';

  @override
  String get homeMenuHistory => 'מושבים קודמים';

  @override
  String get onboardingProfileTitle => 'פרופיל ואיש קשר ראשון';

  @override
  String get onboardingPermissionsTitle => 'הרשאות';

  @override
  String get onboardingNext => 'הבא';

  @override
  String get onboardingSkip => 'דלג';

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
  String get sessionTitle => 'מושב';

  @override
  String get sessionDisarm => 'אני בטוח';

  @override
  String get sessionDisarmStealth => 'אין צורך באנג\'לה';

  @override
  String get homeChainSummaryTitle => 'סיכום השרשרת';

  @override
  String get homeChainSummaryEmpty =>
      'במצב הזה עדיין אין שלבים — הקישי על המצב כדי לערוך.';

  @override
  String homeChainSummaryTimingTitle(Object name) {
    return 'שלב: $name';
  }

  @override
  String homeChainSummaryWait(Object seconds) {
    return 'המתנה: $seconds שניות';
  }

  @override
  String homeChainSummaryDuration(Object seconds) {
    return 'פעיל: $seconds שניות';
  }

  @override
  String homeChainSummaryGrace(Object seconds) {
    return 'תקופת חסד: $seconds שניות';
  }

  @override
  String homeChainSummaryRetry(Object count) {
    return 'ניסיונות חוזרים: $count';
  }

  @override
  String homeChainSummaryNextStep(Object name) {
    return 'השלב הבא: $name';
  }

  @override
  String get homeChainSummaryNextStepNone => 'השלב הבא: סוף השרשרת';

  @override
  String get homeChainSummaryClose => 'סגירה';

  @override
  String get chainStepNameHoldButton => 'החזיקי כדי להישאר בטוחה';

  @override
  String get chainStepNameDisguisedReminder => 'תזכורת מוסווית';

  @override
  String get chainStepNameCountdownWarning => 'אזהרת ספירה לאחור';

  @override
  String get chainStepNameFakeCall => 'שיחה מזויפת';

  @override
  String get chainStepNameSmsContact => 'SMS לאיש קשר';

  @override
  String get chainStepNamePhoneCallContact => 'שיחה לאיש קשר';

  @override
  String get chainStepNameLoudAlarm => 'אזעקה רועשת';

  @override
  String get chainStepNameCallEmergency => 'שיחת חירום';

  @override
  String get chainStepNameHardwareButton => 'כפתור חומרה';

  @override
  String get homeChecklistTitle => 'הגדרת בטיחות';

  @override
  String get homeChecklistDismissTooltip => 'סגור את הרשימה';

  @override
  String get homeChecklistExpandTooltip => 'הצג רשימה';

  @override
  String get homeChecklistCollapseTooltip => 'כווץ רשימה';

  @override
  String homeChecklistProgress(Object done, Object total) {
    return '$done מתוך $total הושלמו';
  }

  @override
  String get homeChecklistAllDoneBanner => 'הכל מוכן — את מוגנת!';

  @override
  String get homeChecklistInfoTooltip => 'למה זה חשוב';

  @override
  String get homeChecklistGotIt => 'הבנתי';

  @override
  String get homeChecklistGoThere => 'לעבור לשם';

  @override
  String get homeChecklistItem1Title => 'הוסיפי איש קשר לחירום';

  @override
  String get homeChecklistItem2Title => 'קבעי PIN לסיום פעילות';

  @override
  String get homeChecklistItem3Title => 'הגדירי מצב הסתרה';

  @override
  String get homeChecklistItem4Title => 'נסי סימולציה';

  @override
  String get homeChecklistItem5Title => 'התאימי מצב בטיחות';

  @override
  String get homeChecklistItem6Title => 'תני את ההרשאות הנדרשות';

  @override
  String get checklistInfo1Body =>
      'אנשי הקשר לחירום הם האנשים ש-Guardian Angela שולחת להם הודעה ומתקשרת אליהם כשאינך מצליחה לסמן \"בטוחה\" בזמן. בלי איש קשר אחד לפחות, אין לשרשרת לאן להסלים.';

  @override
  String get checklistInfo2Body =>
      'PIN של סיום פעילות מונע מתוקף לסיים בשקט פעילות פעילה. הוא עדיין יכול לנסות, אבל חמש הקשות שגויות יפעילו בשקט את שרשרת המצוקה שלך.';

  @override
  String get checklistInfo3Body =>
      'מצב הסתרה מסווה את הפעילות הפעילה על המסך כמשהו בלתי-מזיק — נגן מוסיקה, טיימר מושהה, מסך נעילה ריק. השתמשי בו כשמישהו לידך לא צריך לראות אפליקציית בטיחות.';

  @override
  String get checklistInfo4Body =>
      'הסימולציה מריצה את מצב הבטיחות מתחילה ועד הסוף בלי לשלוח SMS אמיתי, בלי להתקשר באמת ובלי להפעיל את האזעקה הרועשת. השתמשי בה כדי להכיר את הזמנים לפני שתזדקקי להם.';

  @override
  String get checklistInfo5Body =>
      'מצבים מותאמים אישית מאפשרים לכוונן את השלבים, הזמנים והטריגרים למצב ספציפי — הליכה הביתה, פגישה ראשונה, משמרת לילה. שני המצבים המוטמעים הם נקודת התחלה, לא היעד.';

  @override
  String get checklistInfo6Body =>
      'בלי הרשאת התראות, Guardian Angela לא יכולה לשמור על מצב חזית קבוע, להעביר תזכורות מוסוות או להזהיר אותך שהשרשרת עומדת להסלים.';

  @override
  String get checklistTutorial3Body =>
      'פתחי את ברירות המחדל של מצב ההסתרה והפעילי «אפשר מצב הסתרה». משם תוכלי לבחור מותג מוסיקה מזויף, להסתיר את טיימר הפעילות או להסוות את אייקון מסך הבית.';

  @override
  String get checklistTutorial4Body =>
      'במסך הבית, אחרי שבחרת מצב, הקישי על כפתור «סימולציה» עם המתאר. הפעילות רצה עם מסגרת כתומה ותג [SIM] — שום דבר לא יוצא מהטלפון שלך.';

  @override
  String get checklistTutorial5Body =>
      'פתחי את מסך «מצבים» ועברי או על מצב מוטמע (הליכה / דייט) או צרי חדש מאפס. כווני את השרשרת, הוסיפי שיחה מזויפת, קבעי זמנים משלך.';

  @override
  String get sessionHoldPrompt => 'החזק כדי להישאר בטוח';

  @override
  String sessionStepLabel(Object index, Object total) {
    return 'שלב $index מתוך $total';
  }

  @override
  String sessionMissCount(Object count) {
    return 'החמצות: $count';
  }

  @override
  String get sessionPausedBadge => 'מושהה';

  @override
  String get sessionPhaseEnded => 'המושב הסתיים';

  @override
  String get sessionSimulationBanner => 'סימולציה';

  @override
  String get sessionCheckIn => 'ביצעתי צ\'ק-אין';

  @override
  String get sessionStepCountdownTitle => 'אזהרה';

  @override
  String get sessionStepCountdownBody =>
      'ההסלמה הבאה תופעל בסיום הספירה לאחור. החלק/י „אני בטוח/ה” למטה כדי לנטרל.';

  @override
  String get sessionStepDisguisedDefaultTitle => 'תזכורת';

  @override
  String get sessionStepDisguisedDefaultBody =>
      'הקש/י על „ביצעתי צ\'ק-אין” כדי לאשר שאת/ה בטוח/ה.';

  @override
  String get sessionStepSmsStatus => 'שולח הודעה לאנשי קשר…';

  @override
  String get sessionStepPhoneCallStatus => 'מתקשר לאיש קשר חירום…';

  @override
  String get sessionStepLoudAlarmTitle => 'האזעקה פועלת';

  @override
  String get sessionStepLoudAlarmBody => 'האזעקה צופרת כדי למשוך תשומת לב.';

  @override
  String get sessionStepLoudAlarmFlashWarning =>
      'אזהרה לרגישים לאור: המסך מהבהב.';

  @override
  String get sessionStepCallEmergencyStatus => 'מתקשר לשירותי חירום…';

  @override
  String sessionStepCallEmergencyNumber(Object number) {
    return 'מספר: $number';
  }

  @override
  String sessionStepHardwareButtonRepeat(
    Object button,
    Object count,
    Object windowMs,
  ) {
    return 'לחץ/י $button $count פעמים בתוך $windowMs מ״ש';
  }

  @override
  String sessionStepHardwareButtonLong(Object button, Object seconds) {
    return 'החזק/י את $button למשך $seconds שניות';
  }

  @override
  String get sessionStepHardwareButtonVolumeUp => 'עוצמה למעלה';

  @override
  String get sessionStepHardwareButtonVolumeDown => 'עוצמה למטה';

  @override
  String get sessionStepHardwareButtonPower => 'הפעלה';

  @override
  String get sessionCompletedTitle => 'המושב הושלם';

  @override
  String get sessionCompletedBody =>
      'הגעתם בבטחה. Guardian Angela סיימה את תפקידה.';

  @override
  String get sessionCompletedReturnHome => 'חזרה לדף הבית';

  @override
  String get simulationSummaryTitle => 'סיכום הסימולציה';

  @override
  String get simulationSummaryEmpty => 'לא הופעלו שלבים במהלך הסימולציה.';

  @override
  String get simulationSummaryReturn => 'חזרה לדף הבית';

  @override
  String get fakeCallTitle => 'שיחה נכנסת';

  @override
  String get fakeCallHangUp => 'נתק';

  @override
  String get fakeCallSlideToAnswer => 'החלק/י כדי לענות';

  @override
  String get fakeCallUnknownCaller => 'לא ידוע';

  @override
  String get fakeCallIncomingWhatsapp => 'שיחה קולית ב-WhatsApp';

  @override
  String get fakeCallIncomingTelegram => 'שיחה קולית ב-Telegram';

  @override
  String get fakeCallIncomingSignal => 'שיחה קולית ב-Signal';

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
  String get contactsTitle => 'אנשי קשר לשעת חירום';

  @override
  String get contactsEmpty =>
      'אין אנשי קשר עדיין. הוסיפו אחד כדי לקבל הודעות מצוקה.';

  @override
  String get contactsAdd => 'הוסף איש קשר';

  @override
  String get contactFormTitleCreate => 'איש קשר חדש';

  @override
  String get contactFormTitleEdit => 'ערוך איש קשר';

  @override
  String get contactFieldName => 'שם';

  @override
  String get contactFieldPhone => 'מספר טלפון';

  @override
  String get contactFieldRelationship => 'קרבה (אופציונלי)';

  @override
  String get contactFieldLanguage => 'שפת SMS (אופציונלי)';

  @override
  String get contactLanguageDefault => 'ברירת מחדל (השתמש בשפת האפליקציה)';

  @override
  String get contactChannelsHeader => 'ערוצי התכתבות';

  @override
  String get contactChannelSms => 'SMS';

  @override
  String get contactChannelWhatsapp => 'WhatsApp';

  @override
  String get contactChannelTelegram => 'Telegram';

  @override
  String get contactChannelPhone => 'שיחת טלפון';

  @override
  String get contactDeleteConfirm => 'למחוק את איש הקשר?';

  @override
  String contactDeleteBody(Object name) {
    return '$name יוסר מרשימת החירום שלך.';
  }

  @override
  String get contactFormIosSmsWarning =>
      'On iOS, SMS opens the Messages app. You must tap Send manually.';

  @override
  String get modesTitle => 'מצבים';

  @override
  String get modesEmpty => 'אין מצבים עדיין. הקישו על הוסף כדי ליצור מצב.';

  @override
  String get modesAdd => 'הוסף מצב';

  @override
  String get modesNewPickerBlank => 'מצב ריק';

  @override
  String get modesNewPickerBlankSubtitle => 'התחל עם שרשרת ריקה';

  @override
  String modesNewPickerFromTemplate(String name) {
    return 'מתוך $name';
  }

  @override
  String get modesNewPickerFromTemplateSubtitle =>
      'העתק את השרשרת והטריגרים של המצב הזה';

  @override
  String get modeEditorTitleCreate => 'מצב חדש';

  @override
  String get modeEditorTitleEdit => 'ערוך מצב';

  @override
  String get modeFieldName => 'שם';

  @override
  String get modeChainHeader => 'שרשרת';

  @override
  String get modeChainAddStep => 'הוסף שלב';

  @override
  String get modeUnsavedTitle => 'לבטל שינויים?';

  @override
  String get modeUnsavedBody => 'יש לך שינויים שלא נשמרו. לבטל ולצאת מהעורך?';

  @override
  String get modeUnsavedDiscard => 'בטל';

  @override
  String get modeUnsavedKeep => 'המשך עריכה';

  @override
  String stepTimingSummary(Object wait, Object duration, Object grace) {
    return 'המתנה $waitש\' / משך $durationש\' / חסד $graceש\'';
  }

  @override
  String get distressModesEmpty => 'אין מצבי מצוקה עדיין.';

  @override
  String get distressModeEditorTitleCreate => 'מצב מצוקה חדש';

  @override
  String get distressModeEditorTitleEdit => 'ערוך מצב מצוקה';

  @override
  String get templatesTitle => 'תבניות תזכורת';

  @override
  String get templatesEmpty => 'אין תבניות עדיין.';

  @override
  String get profileTitle => 'פרופיל';

  @override
  String get profileFieldName => 'שם';

  @override
  String get profileFieldAge => 'גיל';

  @override
  String get profileFieldBloodType => 'סוג דם';

  @override
  String get profileFieldAllergies => 'אלרגיות';

  @override
  String get profileFieldMedications => 'תרופות';

  @override
  String get settingsThemeLight => 'בהיר';

  @override
  String get settingsThemeDark => 'כהה';

  @override
  String get settingsThemeSystem => 'מערכת';

  @override
  String get settingsEmergencyNumberLabel => 'מספר חירום';

  @override
  String get settingsRedoOnboardingActiveSessionTooltip =>
      'Cannot redo onboarding during an active session';

  @override
  String get settingsEmergencyNumberCountryPickerTitle =>
      'Choose emergency number';

  @override
  String get settingsRedoOnboarding => 'חזרה על הכניסה הראשונה';

  @override
  String get settingsRedoOnboardingConfirm => 'להתחיל את הכניסה מחדש?';

  @override
  String get securitySessionEndPinBiometric =>
      'השתמש בביומטריה ל-PIN של סיום מושב';

  @override
  String get securityAppPinBiometric => 'Use biometrics for App lock';

  @override
  String get launchPinTitle => 'Enter your App PIN';

  @override
  String get launchPinBiometricReason => 'Unlock Guardian Angela';

  @override
  String get launchPinIncorrect => 'Incorrect PIN';

  @override
  String get securitySetPin => 'הגדר קוד';

  @override
  String get securityChangePin => 'שנה קוד';

  @override
  String get pinSetupMismatch => 'הקודים אינם תואמים. נסו שוב.';

  @override
  String get stealthTimerDisplayNormal => 'הצג טקסט מלא';

  @override
  String get stealthTimerDisplaySmall => 'הצג מספרים בלבד';

  @override
  String get stealthTimerDisplayNone => 'הסתר טיימר';

  @override
  String get stealthPresetMusic => 'מוזיקה';

  @override
  String get stealthPresetCalendar => 'יומן';

  @override
  String get stealthPresetFitness => 'כושר';

  @override
  String get stealthPresetWeather => 'מזג אוויר';

  @override
  String get stealthPresetNews => 'חדשות';

  @override
  String get stealthPresetPhotos => 'תמונות';

  @override
  String get stealthPresetNotes => 'פתקים';

  @override
  String get stealthPresetClock => 'שעון';

  @override
  String get batteryAlertTitle => 'התראת סוללה';

  @override
  String get eventDefaultsTitle => 'ברירות מחדל לשלבים';

  @override
  String get historyRetentionTitle => 'שמירת היסטוריה';

  @override
  String get backupTitle => 'גיבוי';

  @override
  String get aboutTitle => 'אודות';

  @override
  String aboutVersion(Object version) {
    return 'גרסה';
  }

  @override
  String get feedbackTitle => 'משוב';

  @override
  String get feedbackSend => 'פתח אימייל';

  @override
  String get stealthPresetPodcast => 'פודקאסט';

  @override
  String get stealthPresetNone => 'ללא';

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
