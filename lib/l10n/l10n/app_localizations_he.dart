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
  String get commonCancel => 'ביטול';

  @override
  String get commonDelete => 'מחק';

  @override
  String get commonEdit => 'ערוך';

  @override
  String get commonAdd => 'הוסף';

  @override
  String get commonClose => 'סגור';

  @override
  String get commonConfirm => 'אישור';

  @override
  String get commonBack => 'חזור';

  @override
  String get commonDone => 'סיום';

  @override
  String get commonRetry => 'נסה שוב';

  @override
  String get commonYes => 'כן';

  @override
  String get commonNo => 'לא';

  @override
  String get commonEnabled => 'מופעל';

  @override
  String get commonDisabled => 'כבוי';

  @override
  String get commonNone => 'ללא';

  @override
  String get commonSeconds => 'שניות';

  @override
  String get commonMinutes => 'דקות';

  @override
  String get cancel => 'ביטול';

  @override
  String get homeTitle => 'Guardian Angela';

  @override
  String get homeStartSession => 'התחל מושב';

  @override
  String get homeSimulate => 'סימולציה';

  @override
  String get homeActiveSession => 'מושב פעיל';

  @override
  String get homeResumeSession => 'המשך';

  @override
  String get homeNoModes => 'אין מצבים עדיין. הקש על מצבים כדי להוסיף.';

  @override
  String get homeNoContacts =>
      'אין אנשי קשר לשעת חירום. הקש על אנשי קשר כדי להוסיף.';

  @override
  String get homeMenuSettings => 'הגדרות';

  @override
  String get homeMenuContacts => 'אנשי קשר';

  @override
  String get homeMenuModes => 'מצבים';

  @override
  String get homeMenuHistory => 'מושבים קודמים';

  @override
  String get homeSelectMode => 'בחר מצב';

  @override
  String get onboardingWelcomeTitle => 'ברוכים הבאים ל-Guardian Angela';

  @override
  String get onboardingWelcomeBody =>
      'מלווה ששומר עליכם בדרככם הביתה. Guardian Angela שומרת עליכם בזמן הליכה, ריצה או נסיעה, ויכולה להתריע לאנשי הקשר שבחרתם אם אתם זקוקים לעזרה.';

  @override
  String get onboardingProfileTitle => 'פרופיל ואיש קשר ראשון';

  @override
  String get onboardingProfileBody =>
      'ספרו לנו מעט עליכם כדי ש-Guardian Angela תוכל לשתף פרטים מועילים במקרה חירום. לאחר מכן הוסיפו איש קשר מהימן אחד.';

  @override
  String get onboardingPermissionsTitle => 'הרשאות';

  @override
  String get onboardingPermissionsBody =>
      'Guardian Angela זקוקה לכמה הרשאות כדי לשמור עליכם. אשרו אותן כעת או מאוחר יותר בהגדרות.';

  @override
  String get onboardingNext => 'הבא';

  @override
  String get onboardingSkip => 'דלג';

  @override
  String get onboardingFinish => 'סיום';

  @override
  String get sessionTitle => 'מושב';

  @override
  String get sessionDisarm => 'אני בטוח';

  @override
  String get sessionPause => 'השהה';

  @override
  String get sessionResume => 'המשך';

  @override
  String get sessionHoldPrompt => 'החזק כדי להישאר בטוח';

  @override
  String get sessionHoldSemantic => 'החזק לחוץ. הרפייה מתחילה תקופת חסד.';

  @override
  String sessionStepLabel(Object index, Object total) {
    return 'שלב $index מתוך $total';
  }

  @override
  String sessionMissCount(Object count) {
    return 'החמצות: $count';
  }

  @override
  String sessionRemaining(Object seconds) {
    return 'נותרו $seconds שניות';
  }

  @override
  String get sessionPausedBadge => 'מושהה';

  @override
  String get sessionPhaseEnded => 'המושב הסתיים';

  @override
  String get sessionSimulationBanner => 'סימולציה';

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
  String get fakeCallAnswer => 'ענה';

  @override
  String get fakeCallDecline => 'דחה';

  @override
  String get fakeCallHangUp => 'נתק';

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
  String get contactRequiredError => 'שם ומספר טלפון הם שדות חובה.';

  @override
  String get modesTitle => 'מצבים';

  @override
  String get modesEmpty => 'אין מצבים עדיין. הקישו על הוסף כדי ליצור מצב.';

  @override
  String get modesAdd => 'הוסף מצב';

  @override
  String get modeEditorTitleCreate => 'מצב חדש';

  @override
  String get modeEditorTitleEdit => 'ערוך מצב';

  @override
  String get modeFieldName => 'שם';

  @override
  String get modeFieldCheckInType => 'סוג צ\'ק-אין';

  @override
  String get modeFieldDistressChain => 'שרשרת מצוקה';

  @override
  String get modeFieldDistressChainDefault => 'השתמש בברירת המחדל';

  @override
  String get modeChainHeader => 'שרשרת הסלמה';

  @override
  String get modeChainAddStep => 'הוסף שלב';

  @override
  String get modeChainEmpty => 'אין שלבים עדיין. הקישו על הוסף שלב.';

  @override
  String get stepTypeHoldButton => 'לחצן החזקה';

  @override
  String get stepTypeDisguisedReminder => 'תזכורת מוסווית';

  @override
  String get stepTypeCountdownWarning => 'אזהרת ספירה לאחור';

  @override
  String get stepTypeFakeCall => 'שיחה מזויפת';

  @override
  String get stepTypeSmsContact => 'שליחת SMS לאיש קשר';

  @override
  String get stepTypePhoneCallContact => 'שיחה לאיש קשר';

  @override
  String get stepTypeLoudAlarm => 'אזעקה רועשת';

  @override
  String get stepTypeCallEmergency => 'התקשר לחירום';

  @override
  String get stepTypeHardwareButton => 'לחצן פיזי';

  @override
  String get stepFieldDuration => 'משך (שניות)';

  @override
  String get stepFieldGrace => 'תקופת חסד (שניות)';

  @override
  String get stepFieldWait => 'המתנה (שניות)';

  @override
  String get stepFieldRetryCount => 'ניסיונות חוזרים';

  @override
  String get stepFieldRandomize => 'שונות בזמנים';

  @override
  String get stepPreview => 'תצוגה מקדימה בסימולציה';

  @override
  String stepPreviewFired(Object description) {
    return 'התצוגה המקדימה הופעלה: $description';
  }

  @override
  String get stepConfigFakeCallCaller => 'שם המתקשר';

  @override
  String get stepConfigFakeCallDecline => 'דחייה נחשבת כביטול אזעקה';

  @override
  String get stepConfigLoudAlarmFlash => 'הבהוב מסך';

  @override
  String get stepConfigLoudAlarmVolume => 'עוצמה מרבית';

  @override
  String get stepConfigCountdownVibrate => 'רטט';

  @override
  String get stepConfigCountdownTone => 'השמע צליל';

  @override
  String get stepConfigSmsSelection => 'נמענים';

  @override
  String get stepConfigSmsAllContacts => 'כל אנשי הקשר';

  @override
  String get stepConfigSmsSpecific => 'אנשי קשר מסוימים';

  @override
  String get stepConfigSmsIncludeLocation => 'כלול מיקום';

  @override
  String get stepConfigSmsIncludeMedical => 'כלול מידע רפואי';

  @override
  String get stepConfigHoldReleaseSensitivity => 'רגישות שחרור (שניות)';

  @override
  String get stepConfigReminderInterval => 'מרווח תזכורות (שניות)';

  @override
  String get stepConfigReminderTemplate => 'תבנית';

  @override
  String get stepConfigHardwarePattern => 'תבנית';

  @override
  String get stepConfigHardwarePressCount => 'מספר לחיצות';

  @override
  String get stepConfigHardwareButton => 'לחצן';

  @override
  String get stepConfigHardwareButtonVolumeUp => 'עוצמה למעלה';

  @override
  String get stepConfigHardwareButtonVolumeDown => 'עוצמה למטה';

  @override
  String get stepConfigHardwareButtonPower => 'הפעלה';

  @override
  String get stepConfigHardwarePatternRepeat => 'לחיצה חוזרת';

  @override
  String get stepConfigHardwarePatternLong => 'לחיצה ארוכה';

  @override
  String get stepConfigEmergencyNumber => 'עקיפת מספר החירום';

  @override
  String get stepConfigEmergencyConfirm => 'אשר לפני חיוג';

  @override
  String get stepConfigPhonePreSms => 'שלח SMS לפני השיחה';

  @override
  String get distressChainsTitle => 'שרשראות מצוקה';

  @override
  String get distressChainsEmpty => 'אין שרשראות מצוקה עדיין.';

  @override
  String get distressChainsAdd => 'הוסף שרשרת';

  @override
  String get distressChainEditorTitleCreate => 'שרשרת מצוקה חדשה';

  @override
  String get distressChainEditorTitleEdit => 'ערוך שרשרת מצוקה';

  @override
  String get distressChainName => 'שם השרשרת';

  @override
  String get distressCountdown => 'מפעיל שרשרת מצוקה...';

  @override
  String get distressCountdownStealth => 'אנא המתינו...';

  @override
  String get templatesTitle => 'תבניות תזכורת';

  @override
  String get templatesEmpty => 'אין תבניות עדיין.';

  @override
  String get templatesAdd => 'הוסף תבנית';

  @override
  String get templateEditorTitleCreate => 'תבנית חדשה';

  @override
  String get templateEditorTitleEdit => 'ערוך תבנית';

  @override
  String get templateFieldName => 'שם בעורך';

  @override
  String get templateFieldTitle => 'כותרת תזכורת';

  @override
  String get templateFieldBody => 'תוכן תזכורת';

  @override
  String get templateFieldConfirmationType => 'סוג אישור';

  @override
  String get templateFieldKeyword => 'מילת מפתח';

  @override
  String get templateFieldButtonLabel => 'תווית כפתור';

  @override
  String get templateFieldDisplayStyle => 'סגנון תצוגה';

  @override
  String get templateConfirmTapButton => 'הקש על כפתור';

  @override
  String get templateConfirmTapWord => 'הקש על מילה';

  @override
  String get templateConfirmSwipe => 'החלק';

  @override
  String get templateConfirmDismiss => 'בטל';

  @override
  String get templateDisplayFullscreen => 'מסך מלא';

  @override
  String get templateDisplaySubtle => 'עדין';

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
  String get profileFieldConditions => 'מצבים רפואיים';

  @override
  String get profileFieldInstructions => 'הוראות חירום';

  @override
  String get profileAddItem => 'הוסף פריט';

  @override
  String get settingsTitle => 'הגדרות';

  @override
  String get settingsSectionSecurity => 'אבטחה';

  @override
  String get settingsSectionStealth => 'מצב סמוי';

  @override
  String get settingsSectionDefaults => 'ברירות מחדל';

  @override
  String get settingsSectionHistory => 'היסטוריה';

  @override
  String get settingsSectionBackup => 'גיבוי';

  @override
  String get settingsSectionAbout => 'אודות';

  @override
  String get settingsSectionFeedback => 'משוב';

  @override
  String get settingsSectionContacts => 'אנשי קשר';

  @override
  String get settingsSectionModes => 'מצבים';

  @override
  String get settingsSectionProfile => 'פרופיל';

  @override
  String get settingsSectionDistressChains => 'שרשראות מצוקה';

  @override
  String get settingsSectionReminderTemplates => 'תבניות תזכורת';

  @override
  String get settingsSectionBatteryAlert => 'התראת סוללה';

  @override
  String get settingsSectionEventDefaults => 'ברירות מחדל לשלבים';

  @override
  String get settingsSectionGpsLogging => 'תיעוד GPS';

  @override
  String get settingsSectionNotifications => 'התראות';

  @override
  String get settingsSectionHistoryRetention => 'שמירת היסטוריה';

  @override
  String get settingsSectionAppearance => 'מראה';

  @override
  String get settingsThemeMode => 'ערכת נושא';

  @override
  String get settingsThemeLight => 'בהיר';

  @override
  String get settingsThemeDark => 'כהה';

  @override
  String get settingsThemeSystem => 'מערכת';

  @override
  String get settingsLanguage => 'שפה';

  @override
  String get settingsEmergencyNumber => 'מספר חירום';

  @override
  String get settingsAlarmDnd => 'אזעקה עוקפת את מצב \'נא לא להפריע\'';

  @override
  String get securityTitle => 'אבטחה';

  @override
  String get securityAppPin => 'קוד אפליקציה';

  @override
  String get securitySessionEndPin => 'קוד סיום מושב';

  @override
  String get securityDuressPin => 'קוד כפייה';

  @override
  String get securityPinTimeout => 'תפוגת קוד (שניות)';

  @override
  String get securityDisablePin => 'השבת';

  @override
  String get securitySetPin => 'הגדר קוד';

  @override
  String get securityChangePin => 'שנה קוד';

  @override
  String get pinSetupTitle => 'הגדר קוד';

  @override
  String get pinSetupEnter => 'הזן קוד חדש';

  @override
  String get pinSetupConfirm => 'אשר קוד';

  @override
  String get pinSetupMismatch => 'הקודים אינם תואמים. נסו שוב.';

  @override
  String get pinEntryTitle => 'הזן קוד';

  @override
  String get pinEntrySubtitle => 'הזינו את הקוד שלכם כדי להמשיך.';

  @override
  String get stealthTitle => 'מצב סמוי';

  @override
  String get stealthEnable => 'הפעל מצב סמוי';

  @override
  String get stealthFakeName => 'שם אפליקציה מזויף';

  @override
  String get stealthFakeIcon => 'אייקון מזויף';

  @override
  String get stealthNotificationDisguise => 'הסווה התראות';

  @override
  String get stealthTimerDisplay => 'הצג טיימר במצב סמוי';

  @override
  String get stealthSessionScreen => 'הסתר מיתוג במסך המושב';

  @override
  String get stealthPickerTitle => 'סמל האפליקציה';

  @override
  String get stealthPickerIntro => 'בחר כיצד ייראה הסמל במסך הבית.';

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
  String get distressConfirmationTitle => 'האם את/ה בסכנה?';

  @override
  String get distressConfirmationCancel => 'ביטול';

  @override
  String distressConfirmationCountdown(Object seconds) {
    return 'שרשרת החירום תופעל בעוד $seconds שניות';
  }

  @override
  String get imSafeSliderLabel => 'החלק כדי לאשר „אני בטוח/ה”';

  @override
  String get batteryAlertTitle => 'התראת סוללה';

  @override
  String get batteryAlertEnable => 'הפעל התראת סוללה';

  @override
  String batteryAlertThreshold(Object percent) {
    return 'סף: $percent%';
  }

  @override
  String get eventDefaultsTitle => 'ברירות מחדל לשלבים';

  @override
  String get eventDefaultsBody =>
      'ברירות המחדל הללו חלות על כל שלב שאינו דורס אותן.';

  @override
  String get gpsLoggingTitle => 'תיעוד GPS';

  @override
  String get gpsLoggingEnable => 'הפעל תיעוד GPS';

  @override
  String get gpsLoggingInterval => 'מרווח דגימה (שניות)';

  @override
  String get gpsLoggingAccuracy => 'דיוק';

  @override
  String get gpsAccuracyLow => 'נמוך';

  @override
  String get gpsAccuracyMedium => 'בינוני';

  @override
  String get gpsAccuracyHigh => 'גבוה';

  @override
  String get gpsLoggingIncludeSms => 'צרף מיקום ל-SMS';

  @override
  String get gpsLoggingHistoryDays => 'שמירת היסטוריה (ימים)';

  @override
  String get notificationSettingsTitle => 'התראות';

  @override
  String get notificationSettingsBody =>
      'Guardian Angela משתמשת בהתראות כדי להסוות ולהפעיל תזכורות.';

  @override
  String get historyRetentionTitle => 'שמירת היסטוריה';

  @override
  String get historyRetentionBody =>
      'לכמה זמן Guardian Angela שומרת יומני מושבים קודמים.';

  @override
  String historyRetentionDays(Object days) {
    return 'שמירה: $days ימים';
  }

  @override
  String get backupTitle => 'גיבוי';

  @override
  String get backupExport => 'ייצא נתונים';

  @override
  String get backupImport => 'ייבא נתונים';

  @override
  String get backupNotReady => 'הגיבוי עדיין אינו זמין. בקרוב.';

  @override
  String get backupPinOptional => 'PIN אופציונלי (מצפין את החבילה)';

  @override
  String get backupImportOk => 'הגיבוי יובא בהצלחה.';

  @override
  String get historyTitle => 'מושבים קודמים';

  @override
  String get historyEmpty => 'אין מושבים קודמים עדיין.';

  @override
  String get historyDetailTitle => 'פרטי מושב';

  @override
  String get evidenceExportTitle => 'ייצוא ראיות';

  @override
  String get evidenceExportAsText => 'העתק כטקסט';

  @override
  String get evidenceExportAsJson => 'העתק כ-JSON';

  @override
  String get evidenceCopied => 'הועתק ללוח.';

  @override
  String get aboutTitle => 'אודות';

  @override
  String get aboutVersion => 'גרסה';

  @override
  String get aboutCredits => 'נבנה באכפתיות לאנשים בדרך הביתה.';

  @override
  String get feedbackTitle => 'משוב';

  @override
  String get feedbackBody => 'נשמח לשמוע ממכם.';

  @override
  String get feedbackFieldMessage => 'הודעה';

  @override
  String get feedbackSend => 'פתח אימייל';

  @override
  String get pickerNoneLabel => '— ללא —';
}
