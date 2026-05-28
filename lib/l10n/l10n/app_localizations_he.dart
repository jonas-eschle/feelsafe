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
  String get homePermissionsMissingTitle => 'חסרות מספר הרשאות';

  @override
  String get homePermissionsMissingBody =>
      'ההרשאות הבאות לא הוענקו. בלעדיהן, שלבי השרשרת המתאימים ייכשלו בשקט:';

  @override
  String get homePermissionsContinueAnyway => 'התחל בכל זאת';

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
  String get contactRequiredError => 'שם ומספר טלפון הם שדות חובה.';

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
  String get modesNewPickerTitle => 'התחל מ-';

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
  String modesNewPickerCopyName(String name) {
    return 'עותק של $name';
  }

  @override
  String get modesNewPickerBuiltinBadge => 'מובנה';

  @override
  String get modeEditorTitleCreate => 'מצב חדש';

  @override
  String get modeEditorTitleEdit => 'ערוך מצב';

  @override
  String get modeFieldName => 'שם';

  @override
  String get modeFieldDistressMode => 'מצב מצוקה';

  @override
  String get modeFieldDistressModeDefault => 'השתמש בברירת המחדל';

  @override
  String get modeChainHeader => 'שרשרת';

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
  String get stepPickerMore => 'עוד אפשרויות...';

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
  String get stepFieldRetryCount => 'מספר ניסיונות חוזרים';

  @override
  String get stepFieldRandomize => 'שונות בזמנים';

  @override
  String get stepFieldRandomizeToggle => 'אקראיות זמנים (±20%)';

  @override
  String get stepFieldWaitTooltip => 'כמה זמן להמתין לפני שלב זה.';

  @override
  String get stepFieldDurationTooltip =>
      'כמה זמן השלב פעיל לפני תחילת חלון החסד.';

  @override
  String get stepFieldGraceTooltip =>
      'זמן לאחר השלב הפעיל לאישור בטיחות לפני השלב הבא.';

  @override
  String get stepFieldRetryCountTooltip =>
      'כמה פעמים לחזור על שלב זה לפני הסלמה.';

  @override
  String get stepFieldReminderIntervalTooltip =>
      'כל כמה זמן התזכורת המוסווה מופעלת בעת המתנה לאישור.';

  @override
  String get stepFieldReminderGraceTooltip =>
      'כמה זמן יש למשתמש לאשר בטיחות לאחר הופעת התזכורת.';

  @override
  String get stepPreview => 'תצוגה מקדימה בסימולציה';

  @override
  String stepPreviewFired(Object description) {
    return 'התצוגה המקדימה הופעלה: $description';
  }

  @override
  String get stepPreviewTitle => 'תצוגה מקדימה לשלב';

  @override
  String get stepPreviewMissingParams => 'חסרה הפניה לשלב או למצב.';

  @override
  String get stepPreviewModeNotFound => 'המצב לא נמצא.';

  @override
  String get stepPreviewStepNotFound => 'השלב לא נמצא במצב הזה.';

  @override
  String stepPreviewError(Object error) {
    return 'התצוגה המקדימה נכשלה: $error';
  }

  @override
  String get stepPreviewReplay => 'הפעל שוב';

  @override
  String get stepPreviewHoldButtonHint => 'החזק את הלחצן לחוש את התגובה החיה.';

  @override
  String get stepPreviewHoldButtonLabel => 'החזק';

  @override
  String get stepPreviewHoldButtonSemantic => 'החזק לתצוגה מקדימה';

  @override
  String get stepPreviewHoldButtonReleased =>
      'שוחרר. הסשן ייכנס כעת לחלון הארכה.';

  @override
  String get stepPreviewFakeCallHint =>
      'מסך השיחה המזויפת יופיע. החלק לענות או החזק את הלחצן האדום כדי לדמות מצוקה.';

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
  String get stepConfigSmsAutoRecordAudio => 'הקלט אודיו אוטומטית';

  @override
  String get stepConfigSmsAutoRecordVideo => 'הקלט וידאו אוטומטית';

  @override
  String get stepConfigSmsRecordDuration => 'משך ההקלטה';

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
  String get stepConfigHardwarePressWindow => 'חלון לחיצות (מ\"ש)';

  @override
  String get stepConfigHardwareLongDuration => 'משך לחיצה ארוכה (שניות)';

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
  String get settingsLanguagePicker => 'שפה';

  @override
  String get settingsEmergencyNumberLabel => 'מספר חירום';

  @override
  String get settingsEmergencyNumberHint => 'לדוגמה 112';

  @override
  String get settingsEmergencyNumberSave => 'שמור';

  @override
  String get settingsRedoOnboarding => 'חזרה על הכניסה הראשונה';

  @override
  String get settingsRedoOnboardingConfirm => 'להתחיל את הכניסה מחדש?';

  @override
  String get settingsRedoOnboardingBody => 'ההגדרות הנוכחיות שלך נשמרות.';

  @override
  String get settingsRedoOnboardingProceed => 'התחל מחדש';

  @override
  String get settingsAlarmGradualVolume => 'עוצמת אזעקה הדרגתית';

  @override
  String settingsAlarmGradualVolumeDuration(int seconds) {
    return 'משך הגברה: $seconds ש׳';
  }

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
  String get historyTabReal => 'אמיתי';

  @override
  String get historyTabSimulated => 'סימולציה';

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
  String aboutVersion(Object version) {
    return 'גרסה';
  }

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
  String get stealthLockTaskLabel => 'Pin app during session';

  @override
  String get stealthLockTaskSubtitle =>
      'Prevents leaving the app while a session is running. On Android this engages screen-pinning; on other platforms this is a no-op.';

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

  @override
  String get audioRunningLatePhrase => 'היי, אני מאחר. אחזור אליך בקרוב.';

  @override
  String smsDefaultTemplate(Object name, Object location, Object time) {
    return '$name עשוי להזדקק לעזרה. מיקום: $location. שעה: $time.';
  }

  @override
  String smsDefaultPreCallTemplate(Object name) {
    return '$name מנסה ליצור איתך קשר. אנא צפה לשיחה.';
  }

  @override
  String simLoudAlarm(Object tail) {
    return '[SIM] אזעקה רועשת + $tail';
  }

  @override
  String get simLoudAlarmTailFlash => 'הבזק';

  @override
  String get simLoudAlarmTailVibrate => 'רטט';

  @override
  String simSmsContact(Object channel, int count) {
    return '[SIM] ישלח $channel ל-$count אנשי קשר';
  }

  @override
  String simFakeCallRing(Object caller) {
    return '[SIM] שיחה נכנסת מ-$caller';
  }

  @override
  String simCountdownWarning(int seconds) {
    return '[SIM] אזהרת ספירה לאחור $secondsש\'';
  }

  @override
  String simPhoneCall(Object name) {
    return '[SIM] יתקשר ל-$name';
  }

  @override
  String get simNoContactToCall => '[SIM] אין איש קשר להתקשר אליו';

  @override
  String simCallEmergency(Object number) {
    return '[SIM] יחייג $number';
  }

  @override
  String get simHardwareButton => '[SIM] טריגר חומרה דרוך';

  @override
  String get simHoldButton => '[SIM] ממתין ללחיצה ארוכה';

  @override
  String simDisguisedReminder(Object title) {
    return '[SIM] יציג את \"$title\"';
  }

  @override
  String get simDisguisedReminderEmpty => '[SIM] אין תבנית תזכורת זמינה';

  @override
  String get simGpsArrivalTrigger => '[SIM] טריגר הגעת GPS הופעל';

  @override
  String get simLowBatteryAlert => '[SIM] התראת סוללה חלשה הופעלה';

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
  String get gpsLoggingFormatAddress => 'Address';

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
  String get pastEventsDetailDelete => 'Delete';

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
}
