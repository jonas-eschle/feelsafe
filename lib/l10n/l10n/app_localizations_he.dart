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
  String get profileAngelaWarningTitle => 'שים/י לב לשם „Angela”';

  @override
  String get profileAngelaWarningBody =>
      'Guardian Angela משתמשת ב-„Angela” כמילת בטיחות. שימוש בשם זה כשמך עלול לבלבל. לשמור בכל זאת?';

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
  String get pinSubmit => 'שלח';

  @override
  String get homeTitle => 'Guardian Angela';

  @override
  String get homeStartSession => 'התחל מושב';

  @override
  String get homeStartConfirmTitle => 'להתחיל מושב?';

  @override
  String get homeStartConfirmBody =>
      'ודא/י שאנשי הקשר וה-PIN מוגדרים. המושב יפעל בחזית והמצב שבחרת ינחה את הצ\'ק-אינים.';

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
  String get homeContactsBannerNone => 'לא הוגדרו אנשי קשר לחירום.';

  @override
  String homeContactsBannerFew(int count) {
    return '$count אנשי קשר מוגדרים. אנו ממליצים על 3 לפחות.';
  }

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
  String get sessionCheckIn => 'ביצעתי צ\'ק-אין';

  @override
  String get sessionDisarmTriggerTitle => 'טריגר נטרול הופעל';

  @override
  String get sessionDisarmTriggerBody => 'טריגר נטרול הופעל. לסיים את המושב?';

  @override
  String get sessionDisarmTriggerConfirm => 'סיים מושב';

  @override
  String get sessionDisarmTriggerCancel => 'המשך';

  @override
  String get wrongPinAngelaTitle => 'PIN ישן מ-Angela';

  @override
  String get wrongPinAngelaBody =>
      'את/ה בטוח/ה שברצונך להמשיך עם ה-PIN הישן הזה?';

  @override
  String get wrongPinAngelaConfirm => 'אישור';

  @override
  String get wrongPinAngelaCancel => 'ביטול';

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
  String get sessionStepSmsDelivered => 'נמסרה';

  @override
  String get sessionStepSmsSent => 'נשלחה';

  @override
  String get sessionStepSmsQueued => 'בתור';

  @override
  String get sessionStepSmsFailed => 'נכשלה';

  @override
  String get sessionStepPhoneCallStatus => 'מתקשר לאיש קשר חירום…';

  @override
  String get sessionStepPhoneCallCancel => 'בטל שיחה';

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
  String get fakeCallAnswer => 'ענה';

  @override
  String get fakeCallDecline => 'דחה';

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
  String get modeFieldDistressMode => 'מצב מצוקה';

  @override
  String get modeFieldDistressModeDefault => 'השתמש בברירת המחדל';

  @override
  String get modeChainHeader => 'שרשרת הסלמה';

  @override
  String get modeChainAddStep => 'הוסף שלב';

  @override
  String get modeChainEmpty => 'אין שלבים עדיין. הקישו על הוסף שלב.';

  @override
  String get modeFieldIcon => 'סמל';

  @override
  String get modeIconPickerTitle => 'בחר סמל';

  @override
  String get modeIconClear => 'ללא סמל';

  @override
  String get modeDistressHeader => 'טריגרים למצוקה';

  @override
  String get modeDistressEmpty => 'אין טריגרי מצוקה מוגדרים.';

  @override
  String get modeDistressAdd => 'הוסף טריגר';

  @override
  String get modeDistressTypeHardware => 'כפתור פיזי';

  @override
  String get modeDistressButtonType => 'כפתור';

  @override
  String get modeDistressButtonVolumeUp => 'עוצמה +';

  @override
  String get modeDistressButtonVolumeDown => 'עוצמה −';

  @override
  String get modeDistressButtonPower => 'הפעלה';

  @override
  String get modeDistressPattern => 'תבנית';

  @override
  String get modeDistressPatternRepeat => 'לחיצה חוזרת';

  @override
  String get modeDistressPatternLong => 'לחיצה ארוכה';

  @override
  String get modeDistressPressCount => 'מספר לחיצות';

  @override
  String get modeDistressPressWindow => 'חלון (אלפיות שנייה)';

  @override
  String get modeDistressLongDuration => 'משך החזקה (שניות)';

  @override
  String modeDistressSummaryRepeat(Object count, Object windowMs) {
    return '$count לחיצות / $windowMs מ׳׳ש';
  }

  @override
  String modeDistressSummaryLong(Object seconds) {
    return 'החזק $seconds שניות';
  }

  @override
  String get modeOverridesHeader => 'עקיפות מצב';

  @override
  String get modeOverridesUseDefault => 'השתמש בברירת המחדל';

  @override
  String get modeOverridesGpsLabel => 'תיעוד GPS';

  @override
  String get modeOverridesStealthLabel => 'מצב חמקני';

  @override
  String get modeOverridesEventDefaultsLabel => 'ברירות מחדל לאירועים';

  @override
  String get modeOverridesLocalTemplatesLabel => 'תבניות תזכורת מקומיות';

  @override
  String get modeOverridesGpsEnabled => 'GPS פעיל';

  @override
  String get modeOverridesGpsIntervalLabel => 'מרווח דגימה (שניות)';

  @override
  String get modeOverridesGpsIncludeInSms => 'הוסף מיקום ל-SMS';

  @override
  String get modeOverridesStealthEnabled => 'מצב חמקני פעיל';

  @override
  String get modeOverridesStealthFakeName => 'שם אפליקציה מזויף';

  @override
  String get modeOverridesEventDefaultsHint =>
      'ברירות מחדל מותאמות פעילות עבור מצב זה.';

  @override
  String modeOverridesLocalTemplatesCount(Object count) {
    return '$count תבניות מקומיות';
  }

  @override
  String get modeUnsavedTitle => 'לבטל שינויים?';

  @override
  String get modeUnsavedBody => 'יש לך שינויים שלא נשמרו. לבטל ולצאת מהעורך?';

  @override
  String get modeUnsavedDiscard => 'בטל';

  @override
  String get modeUnsavedKeep => 'המשך עריכה';

  @override
  String get stepDuplicate => 'שכפל שלב';

  @override
  String get stepTimingHeader => 'תזמון';

  @override
  String stepTimingSummary(Object wait, Object duration, Object grace) {
    return 'המתנה $waitש\' / משך $durationש\' / חסד $graceש\'';
  }

  @override
  String get stepCategoryAll => 'הכל';

  @override
  String get stepCategoryAction => 'פעולה';

  @override
  String get stepCategoryReminder => 'תזכורת';

  @override
  String get stepCategoryDisarm => 'צ\'ק-אין';

  @override
  String get modeTrackingHeader => 'מעקב GPS';

  @override
  String get modeTrackingEnabled => 'הקלט GPS במהלך הסשן';

  @override
  String get modeTrackingIntervalLabel => 'מרווח דגימה';

  @override
  String get modeTrackingBufferSizeLabel => 'גודל המאגר';

  @override
  String modeTrackingBufferSizeValue(Object count) {
    return '$count נקודות';
  }

  @override
  String get modeTrackingBatteryNote => 'מעקב GPS תכוף מגדיל את צריכת הסוללה.';

  @override
  String get stepConfigLogGpsLabel => 'תיעוד GPS';

  @override
  String get stepConfigLogGpsDefault => 'ברירת מחדל';

  @override
  String get stepConfigLogGpsOn => 'פעיל';

  @override
  String get stepConfigLogGpsOff => 'כבוי';

  @override
  String get stepConfigLogGpsDefaultOn => 'ברירת מחדל (פעיל)';

  @override
  String get stepConfigLogGpsDefaultOff => 'ברירת מחדל (כבוי)';

  @override
  String get moreSettingsHeader => 'הגדרות נוספות';

  @override
  String moreSettingsHeaderCustomized(int count) {
    return 'הגדרות נוספות ($count מותאמים)';
  }

  @override
  String get stepTypePickerLabel => 'סוג שלב';

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
  String get distressModesTitle => 'מצבי מצוקה';

  @override
  String get distressModeInUseTitle => 'מצב המצוקה בשימוש';

  @override
  String distressModeInUseBody(Object modes) {
    return 'מצב המצוקה הזה עדיין מקושר ל: $modes. קשר את המצבים האלו למצב מצוקה אחר לפני מחיקה.';
  }

  @override
  String get distressModesEmpty => 'אין מצבי מצוקה עדיין.';

  @override
  String get distressModesAdd => 'הוסף מצב מצוקה';

  @override
  String get distressModeEditorTitleCreate => 'מצב מצוקה חדש';

  @override
  String get distressModeEditorTitleEdit => 'ערוך מצב מצוקה';

  @override
  String get distressModeName => 'שם מצב המצוקה';

  @override
  String get distressCountdown => 'מפעיל מצב מצוקה...';

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
  String get settingsSectionDistressModes => 'מצבי מצוקה';

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
  String get securityAppPinBiometric => 'השתמש בביומטריה ל-PIN של האפליקציה';

  @override
  String get securitySessionEndPinBiometric =>
      'השתמש בביומטריה ל-PIN של סיום מושב';

  @override
  String get securityDistressCancelBiometric => 'השתמש בביומטריה לביטול מצוקה';

  @override
  String get securityDuressTest => 'בדוק PIN של כפייה';

  @override
  String get securityDuressTestSubtitle => 'ודא/י של-PIN הכפייה שלך עובד.';

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
  String get pinEntryBiometricReason => 'אמת/י כדי להמשיך';

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
  String get stealthTimerDisplayNormal => 'הצג טקסט מלא';

  @override
  String get stealthTimerDisplaySmall => 'הצג מספרים בלבד';

  @override
  String get stealthTimerDisplayNone => 'הסתר טיימר';

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
  String get backupSelectionHeader => 'כלול בייצוא';

  @override
  String get backupToggleSettings => 'הגדרות';

  @override
  String get backupToggleSettingsSubtitle =>
      'תמיד נכלל כדי שניתן יהיה לשחזר את הגיבוי.';

  @override
  String get backupToggleContacts => 'אנשי קשר לחירום';

  @override
  String get backupToggleModes => 'מצבים';

  @override
  String get backupToggleDistressModes => 'מצבי מצוקה';

  @override
  String get backupToggleTemplates => 'תבניות תזכורת';

  @override
  String get backupToggleSessionLogs => 'היסטוריית מושבים';

  @override
  String get backupToggleRecordings => 'הקלטות שמע';

  @override
  String get historyTitle => 'מושבים קודמים';

  @override
  String get historyEmpty => 'אין מושבים קודמים עדיין.';

  @override
  String get historySearchHint => 'חיפוש לפי שם מצב';

  @override
  String get historyFilterModeAll => 'כל המצבים';

  @override
  String get historyFilterModeLabel => 'מצב';

  @override
  String get historyDateRangePick => 'טווח תאריכים';

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

  @override
  String emergencyConfirmTitle(Object number) {
    return 'מתקשר ל-$number';
  }

  @override
  String get emergencyConfirmSubtitle => 'החזק/י את כפתור הביטול כדי לבטל.';

  @override
  String emergencyConfirmCountdown(Object seconds) {
    return 'מתקשר בעוד $seconds שניות';
  }

  @override
  String get emergencyConfirmCancel => 'ביטול';

  @override
  String get stealthCalendarUpcoming => 'אירועים קרובים';

  @override
  String get stealthCalendarUpcomingEvent => 'פגישה';

  @override
  String stealthCalendarUntilEvent(Object minutes) {
    return 'בעוד $minutes דק׳';
  }

  @override
  String get stealthCalendarToday => 'היום';

  @override
  String get stealthCalendarEvent1 => 'קפה עם אלכס';

  @override
  String get stealthCalendarEvent2 => 'ישיבת בוקר';

  @override
  String get stealthCalendarEvent3 => 'ארוחת צהריים';

  @override
  String get stealthCalendarEvent4 => 'אימון';

  @override
  String get stealthCalendarEvent5 => 'ארוחת ערב עם סם';

  @override
  String get stealthDisarmGestureHint => 'החלק/י למעלה כדי לסיים';

  @override
  String get stealthMusicTrackTitle => 'רצועה ללא שם';

  @override
  String get stealthMusicArtist => 'אמן לא ידוע';

  @override
  String get stealthMusicAlbum => 'אלבום לא ידוע';

  @override
  String get stealthMusicNowPlaying => 'מתנגן עכשיו';

  @override
  String get stealthMusicSwipeHint => 'החלק/י לנטרול';

  @override
  String get stealthMusicPrevious => 'הקודם';

  @override
  String get stealthMusicPause => 'השהה';

  @override
  String get stealthMusicNext => 'הבא';

  @override
  String get stealthPodcastShowName => 'פודקאסט';

  @override
  String get stealthPodcastEpisodeTitle => 'פרק';

  @override
  String get stealthPodcastEpisodesHeader => 'פרקים';

  @override
  String get stealthPodcastSpeedLabel => '1x';

  @override
  String get stealthPodcastEpisode1 => 'פרק 1';

  @override
  String get stealthPodcastEpisode2 => 'פרק 2';

  @override
  String get stealthPodcastEpisode3 => 'פרק 3';

  @override
  String get stealthPodcastEpisode4 => 'פרק 4';

  @override
  String get stealthPresetPodcast => 'פודקאסט';

  @override
  String get stealthPresetNone => 'ללא';

  @override
  String get sessionSimSpeedLabel => 'מהירות';

  @override
  String sessionSimSpeedValue(Object value) {
    return '${value}x';
  }

  @override
  String get sessionSimSpeedBackgroundCap => 'מוגבל ל-60× ברקע';

  @override
  String get sessionSimAdvancedLabel => 'מתקדם';

  @override
  String get sessionSimTriggerPanic => 'הפעל פאניקה';

  @override
  String get sessionSimTriggerArrival => 'הפעל הגעה';

  @override
  String get sessionSimTriggerBattery => 'הפעל סוללה חלשה';

  @override
  String get simulateGpsArrival => 'סימולציית הגעה';

  @override
  String get simulateLowBattery => 'סימולציית סוללה חלשה';

  @override
  String get launchGateTitle => 'פתח/י את Guardian Angela';

  @override
  String get launchGateSubtitle => 'הזן/י את ה-PIN שלך או השתמש/י בביומטריה.';

  @override
  String get launchGateWrong => 'PIN שגוי';

  @override
  String get launchGateBiometricReason => 'פתח/י את Guardian Angela';

  @override
  String get launchGateUseBiometric => 'השתמש/י בביומטריה';
}
