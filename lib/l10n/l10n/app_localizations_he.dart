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
  String get commonGotIt => 'הבנתי';

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
  String get onboardingUseSimNumber => 'השתמשי במספר ה-SIM שלי';

  @override
  String onboardingUseSimNumberHint(Object number) {
    return '$number';
  }

  @override
  String get onboardingUseSimNumberUnsupported => 'לא זמין ב-iOS';

  @override
  String get onboardingUseSimNumberUnavailable => 'לא ניתן לקרוא את המספר';

  @override
  String get onboardingUseSimNumberPermissionDenied => 'ההרשאה נדחתה';

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
  String get sessionPausedIncomingCall => 'מושהה — שיחה נכנסת';

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
  String get sessionReminderEarlyCheckInHint => 'הקש/י לצ\'ק-אין עכשיו';

  @override
  String get sessionReminderDefaultButton => 'אישור';

  @override
  String get sessionReminderTapWordHint => 'הקש/י להמשך';

  @override
  String get sessionReminderDecoyWords =>
      'מאוחר יותר,דלג,בוצע,פתח,הצג,אישור,הבא,עוד,נדנוד,סגור';

  @override
  String get sessionReminderSwipeLabel => 'החלק/י לסגירה';

  @override
  String get sessionReminderDismissLabel => 'סגור';

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
  String get sessionStealthNowPlaying => 'מתנגן כעת';

  @override
  String get sessionServiceTitle => '‏Guardian Angela פעיל';

  @override
  String get sessionServiceBody => '‏הפעלת הבטיחות שלך פעילה.';

  @override
  String get sessionServiceStealthBody => 'מתנגן';

  @override
  String get sessionStealthTrackTitle => 'רצועה ללא שם';

  @override
  String get sessionStealthArtistName => 'אמן לא ידוע';

  @override
  String get sessionStealthAlbumArtLabel => 'עטיפת אלבום';

  @override
  String get sessionStealthPlay => 'נגן';

  @override
  String get sessionStealthPause => 'השהה';

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
  String get fakeCallBrandAndroid => 'טלפון';

  @override
  String get fakeCallBrandIos => 'טלפון';

  @override
  String get fakeCallBrandMinimal => 'שיחה';

  @override
  String get fakeCallDeclineSafeLabel => 'דחה (אני בטוחה)';

  @override
  String get fakeCallDeclineUnsafeLabel => 'דחה (הישארי בכוננות)';

  @override
  String get fakeCallHoldForDistress => 'החזיקי 5 שניות למצוקה';

  @override
  String fakeCallVoicePrompt(String name) {
    return 'הקראה: $name';
  }

  @override
  String fakeCallVibrationLabel(String pattern) {
    return 'רטט: $pattern';
  }

  @override
  String get fakeCallVibrationPatternDefault => 'ברירת מחדל';

  @override
  String get fakeCallSlideToAnswerHint => 'החליקי כדי לענות';

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
      'ב-iOS, שליחת SMS פותחת את אפליקציית ההודעות. יש להקיש על שלח באופן ידני.';

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
  String get stepConfigTimingHeader => 'תזמון';

  @override
  String get stepConfigEventHeader => 'הגדרות אירוע';

  @override
  String get stepConfigAdvancedHeader => 'ניסיונות חוזרים ומתקדם';

  @override
  String get stepFieldWait => 'המתנה לפני הפעלה (שניות)';

  @override
  String get stepFieldDuration => 'משך פעילות (שניות)';

  @override
  String get stepFieldGrace => 'תקופת חסד (שניות)';

  @override
  String get stepFieldRetryCount => 'ניסיונות חוזרים';

  @override
  String get stepFieldRandomize => 'אקראיות בתזמון (±20%)';

  @override
  String get stepDuplicate => 'שכפול שלב';

  @override
  String get stepResetDefaults => 'איפוס לברירות המחדל';

  @override
  String get smsContactRecipientsHeader => 'אנשי קשר לשליחת הודעה';

  @override
  String get smsContactSummaryAll => 'אל: כל אנשי הקשר המופעלים';

  @override
  String get smsContactSummaryNone => 'לא נבחרו נמענים';

  @override
  String smsContactSummaryTo(Object names) {
    return 'אל: $names';
  }

  @override
  String get smsContactChannelDisabledTooltip =>
      'לא מופעל עבור איש קשר זה — ערכו את איש הקשר כדי להוסיף ערוץ זה.';

  @override
  String get smsContactEmptyAddPrompt =>
      'אין אנשי קשר עדיין — הוסיפו אחד באנשי קשר';

  @override
  String get safetyOptionsHeader => 'אפשרויות בטיחות';

  @override
  String get safetyOptionsDistressModeTitle => 'מצב מצוקה';

  @override
  String get safetyOptionsDistressModeUseDefault =>
      'השתמש במצב המצוקה כברירת מחדל';

  @override
  String safetyOptionsDistressModeUseDefaultNamed(Object name) {
    return 'השתמש בברירת המחדל ($name)';
  }

  @override
  String get safetyOptionsDistressModeInfo =>
      'כאשר מופעל טריגר מצוקה (קוד PIN בכפייה, פאניקה בלחצן פיזי או חריגה ממספר ניסיונות PIN שגויים), שרשרת המצב הזה מוחלפת בשרשרת מצב המצוקה שנבחר. השאר על ברירת המחדל כדי להשתמש במצב המצוקה הכלל-יישומי.';

  @override
  String get safetyOptionsManageDistressModes => 'ניהול מצבי מצוקה';

  @override
  String get safetyOptionsDistressTriggersTitle => 'טריגרים של מצוקה';

  @override
  String get safetyOptionsDistressTriggersInfo =>
      'טריגרים של מצוקה מפעילים את שרשרת המצוקה מיד, במקביל לשרשרת הראשית. לחצן הפאניקה הפיזי עוקב אחר לחצן פיזי לפי תבנית הלחיצה שהוגדרה.';

  @override
  String get safetyOptionsDistressTriggersEmpty => 'אין טריגרים של מצוקה';

  @override
  String get safetyOptionsAddHardwarePanic => 'הוסף לחצן פאניקה פיזי';

  @override
  String safetyOptionsTriggerHardwareRepeat(Object button, Object count) {
    return '$button: $count× לחיצה';
  }

  @override
  String safetyOptionsTriggerHardwareLong(Object button, Object seconds) {
    return '$button: החזקה $seconds שנ׳';
  }

  @override
  String get safetyOptionsButtonVolumeUp => 'הגברת עוצמה';

  @override
  String get safetyOptionsButtonVolumeDown => 'הנמכת עוצמה';

  @override
  String get safetyOptionsTriggerPattern => 'תבנית לחיצה';

  @override
  String get safetyOptionsPatternRepeat => 'לחיצה חוזרת';

  @override
  String get safetyOptionsPatternLong => 'לחיצה ארוכה';

  @override
  String get safetyOptionsTriggerButton => 'לחצן';

  @override
  String get safetyOptionsTriggerPressCount => 'מספר לחיצות';

  @override
  String get safetyOptionsTriggerHoldDuration => 'משך החזקה (שניות)';

  @override
  String get safetyOptionsDisarmTriggersTitle => 'טריגרים לכיבוי';

  @override
  String get safetyOptionsGpsArrivalTitle => 'כיבוי בהגעה לפי GPS';

  @override
  String get safetyOptionsGpsArrivalInfo =>
      'הסשן מסתיים אוטומטית כשאתה מגיע אל תוך הרדיוס שהוגדר סביב היעד שלך. אתה מגדיר את היעד בתחילת הסשן.';

  @override
  String get safetyOptionsGpsArrivalRadius => 'רדיוס הגעה';

  @override
  String safetyOptionsRadiusMeters(Object meters) {
    return '$meters מ׳';
  }

  @override
  String safetyOptionsRadiusKilometers(Object km) {
    return '$km ק״מ';
  }

  @override
  String get safetyOptionsDestinationSource => 'יעד';

  @override
  String get safetyOptionsDestinationPrompt => 'הגדר יעד בתחילת הסשן';

  @override
  String get safetyOptionsDestinationFixed => 'קואורדינטות קבועות';

  @override
  String get safetyOptionsLatitude => 'קו רוחב';

  @override
  String get safetyOptionsLongitude => 'קו אורך';

  @override
  String get safetyOptionsTimerDisarmTitle => 'כיבוי בטיימר';

  @override
  String get safetyOptionsTimerDisarmInfo =>
      'הסשן מסתיים אוטומטית לאחר הזמן שהוגדר, ללא קשר לכך אם ההסלמה החלה.';

  @override
  String get safetyOptionsTimerDuration => 'משך';

  @override
  String safetyOptionsDurationMinutes(Object minutes) {
    return '$minutes דק׳';
  }

  @override
  String safetyOptionsDurationHoursMinutes(Object hours, Object minutes) {
    return '$hours שע׳ $minutes דק׳';
  }

  @override
  String get safetyOptionsGpsLoggingTitle => 'תיעוד GPS';

  @override
  String get safetyOptionsGpsLoggingInfo =>
      'בחר אם מצב זה מתעד את מיקומך במהלך סשן. ‏‘ירושה’ משתמשת בהגדרות ה-GPS הגלובליות שלך; ‘מותאם אישית’ דורס אותן עבור מצב זה; ‘כבוי’ משבית את התיעוד לחלוטין.';

  @override
  String get safetyOptionsStealthTitle => 'מצב חשאי';

  @override
  String get safetyOptionsStealthInfo =>
      'בחר אם מצב זה מסווה את האפליקציה במהלך סשן. ‏‘ירושה’ משתמשת בהגדרות החשאיות הגלובליות שלך; ‘מותאם אישית’ דורס אותן עבור מצב זה; ‘כבוי’ משבית את המצב החשאי לחלוטין.';

  @override
  String get safetyOptionsTriStateInherit => 'ירושה';

  @override
  String get safetyOptionsTriStateCustom => 'מותאם אישית';

  @override
  String get safetyOptionsTriStateOff => 'כבוי';

  @override
  String get safetyOptionsLocalTemplatesTitle => 'תבניות מקומיות';

  @override
  String get safetyOptionsLocalTemplatesInfo =>
      'תבניות מקומיות מתווספות למאגר תבניות התזכורת הגלובלי עבור מצב זה בלבד. השתמש בהן לשלבי תזכורת מוסווית הייחודיים למצב זה.';

  @override
  String get safetyOptionsLocalTemplatesEmpty => 'אין תבניות מקומיות';

  @override
  String get safetyOptionsAddTemplate => 'הוספת תבנית';

  @override
  String get safetyOptionsManageTemplates => 'ניהול תבניות תזכורת';

  @override
  String get safetyOptionsEventDefaultsTitle => 'ברירות מחדל לאירועים';

  @override
  String get safetyOptionsEventDefaultsInfo =>
      'ברירות המחדל לאירועים קובעות את התצורה ההתחלתית לכל סוג שלב. ‏‘ירושה’ משתמשת בברירות המחדל הגלובליות שלך; ‘מותאם אישית’ דורס אותן עבור שלבים במצב זה ללא תצורה משלהם.';

  @override
  String get safetyOptionsEventDefaultsTwoStateInherit => 'ירושה';

  @override
  String get safetyOptionsAllowDisarmAsDistressTitle =>
      'אפשר כיבוי בזמן פעולה כמצוקה';

  @override
  String get safetyOptionsAllowDisarmAsDistressInfo =>
      'כשמופעל, ניתן לעצור את ההתראה בהגעה למקום בטוח או בהמתנה לפקיעת טיימר. כשמושבת, רק השלמת השרשרת או סגירת האפליקציה עוצרות את ההתראה — חזק יותר מול כפייה.';

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
      'לא ניתן לחזור על הכניסה הראשונה במהלך מושב פעיל';

  @override
  String get settingsEmergencyNumberCountryPickerTitle => 'בחרי מספר חירום';

  @override
  String get settingsEmergencyNumberEditTitle => 'מספר חירום';

  @override
  String get settingsEmergencyNumberFieldLabel => 'המספר לחיוג';

  @override
  String get settingsEmergencyNumberPresetsLabel => 'מספרים נפוצים';

  @override
  String get phoneWarnInvalidChars => 'מותר להזין רק ספרות, +, * ו-#.';

  @override
  String get phoneWarnTooShort => 'מספרי חירום כוללים בדרך כלל לפחות 3 ספרות.';

  @override
  String get phoneWarnLooksLikeRegular =>
      'זה נראה כמו מספר טלפון רגיל, לא כמו מספר חירום.';

  @override
  String get phoneWarnEmergencyEmpty =>
      'יש להזין מספר — השדה אינו יכול להיות ריק.';

  @override
  String get settingsRedoOnboarding => 'חזרה על הכניסה הראשונה';

  @override
  String get settingsRedoOnboardingConfirm => 'להתחיל את הכניסה מחדש?';

  @override
  String get securitySessionEndPinBiometric =>
      'השתמש בביומטריה ל-PIN של סיום מושב';

  @override
  String get securityAppPinBiometric => 'השתמש בביומטריה לנעילת האפליקציה';

  @override
  String get securityDistressCancelBiometric => 'שימוש בביומטריה לביטול מצוקה';

  @override
  String get launchPinTitle => 'הזן את ה-PIN של האפליקציה';

  @override
  String get launchPinBiometricReason => 'ביטול נעילת Guardian Angela';

  @override
  String get sessionEndBiometricReason => 'אשרו כדי לסיים את הסשן';

  @override
  String get distressCancelBiometricReason => 'אשרו שזה אתם כדי לבטל';

  @override
  String get launchPinIncorrect => 'PIN שגוי';

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
  String get stealthLockTaskLabel => 'נעצי את האפליקציה במהלך מושב';

  @override
  String get stealthLockTaskSubtitle =>
      'מונע יציאה מהאפליקציה כל עוד מושב פעיל. ב-Android זה מפעיל נעיצת מסך; בפלטפורמות אחרות אין לכך השפעה.';

  @override
  String get stealthLockTaskInfo =>
      'נועץ את Guardian Angela למסך למשך כל המושב כך שאי אפשר להחליק כדי לסגור או לעבור לאפליקציה אחרת. פשרה: Android מציג הודעת מערכת \"האפליקציה נעוצה\" וחוסם מעבר בין אפליקציות עד שהמושב מסתיים — גלוי לכל מי שמביט במסך. השאר כבוי אם אתה מעדיף לעבור בחופשיות בין אפליקציות במהלך מושב. ללא השפעה בפלטפורמות ללא נעיצת מסך.';

  @override
  String get homeTagline => 'המלאך שלך שומר עלייך.';

  @override
  String get onboardingWelcomeGreeting => 'היי, אני אנג\'לה';

  @override
  String get onboardingWelcomeBodyFull =>
      'אני המלאכית השומרת האישית שלך. אני מלווה אותך, שומרת עלייך בערב הבילוי שלך, ופועלת אם משהו מרגיש לא בסדר.';

  @override
  String get onboardingGetStarted => 'בואי נתחיל';

  @override
  String get onboardingProfileNameLabel => 'שם';

  @override
  String get onboardingProfilePhoneLabel => 'מספר טלפון';

  @override
  String get onboardingProfilePhoneHelper => 'נכלל בהודעות החירום.';

  @override
  String get onboardingEmergencyContactHeader => 'איש קשר לחירום';

  @override
  String get onboardingEmergencyContactPrompt =>
      'למי עלינו לפנות אם משהו ישתבש?';

  @override
  String get onboardingEmergencyContactAdd => 'הוסיפי איש קשר לחירום';

  @override
  String get onboardingPermissionsIntro =>
      'ההרשאות האלה שומרות עלייך במהלך מושבים.';

  @override
  String get onboardingPermissionsGrantAll => 'אשרי הכל';

  @override
  String get onboardingPermissionsRequired => 'נדרש';

  @override
  String get onboardingPermissionsOptional => 'אופציונלי';

  @override
  String get onboardingPermissionsMicrophone => 'מיקרופון';

  @override
  String get onboardingPermissionsCamera => 'מצלמה';

  @override
  String get onboardingPermissionsNotificationDesc =>
      'נדרש להתראות מושב ולתזכורות.';

  @override
  String get onboardingPermissionsSmsDesc => 'נדרש לשליחת הודעות חירום בכתב.';

  @override
  String get onboardingPermissionsPhoneDesc =>
      'נדרש לביצוע שיחות חירום ושיחות מזויפות.';

  @override
  String get onboardingPermissionsLocationDesc =>
      'נכלל בהודעות החירום כאשר רישום GPS מופעל.';

  @override
  String get onboardingPermissionsMicrophoneDesc =>
      'משמש להקלטת שמע במצב מצוקה.';

  @override
  String get onboardingPermissionsCameraDesc => 'משמש לאיתות SOS בפלאש.';

  @override
  String get sessionInterruptedTitle => 'המושב הופסק';

  @override
  String get sessionInterruptedBody =>
      'מושב היה פעיל כשהאפליקציה נעצרה. מצב המושב אבד — שום דבר לא שוחזר. אנחנו מציגות זאת כדי שתדעי.';

  @override
  String get sessionInterruptedAcknowledge => 'הבנתי';

  @override
  String sessionInterruptedMode(Object name) {
    return 'מצב: $name';
  }

  @override
  String sessionInterruptedStarted(Object time) {
    return 'התחיל: $time';
  }

  @override
  String get sessionInterruptedStartSameMode => 'התחל אותו מצב';

  @override
  String get sessionInterruptedJustNow => 'ממש עכשיו';

  @override
  String sessionInterruptedMinutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'לפני $count דקות',
      many: 'לפני $count דקות',
      two: 'לפני שתי דקות',
      one: 'לפני דקה',
    );
    return '$_temp0';
  }

  @override
  String sessionInterruptedHoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'לפני $count שעות',
      many: 'לפני $count שעות',
      two: 'לפני שעתיים',
      one: 'לפני שעה',
    );
    return '$_temp0';
  }

  @override
  String sessionInterruptedDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'לפני $count ימים',
      many: 'לפני $count ימים',
      two: 'לפני יומיים',
      one: 'לפני יום',
    );
    return '$_temp0';
  }

  @override
  String get sessionGpsDestinationTitle => 'יעד';

  @override
  String get sessionGpsDestinationBody =>
      'הזיני את קואורדינטות היעד עבור טריגר הנטרול בהגעה לפי GPS.';

  @override
  String get sessionGpsDestinationLat => 'קו רוחב';

  @override
  String get sessionGpsDestinationLng => 'קו אורך';

  @override
  String get sessionGpsDestinationSkip => 'דלגי למושב הזה';

  @override
  String get sessionGpsDestinationConfirm => 'השתמשי ביעד';

  @override
  String get sessionEndOverlayTitle => 'לסיים את המושב?';

  @override
  String get sessionEndOverlayBody => 'החליקי כדי לאשר שברצונך לסיים את המושב';

  @override
  String get sessionEndOverlaySwipeLabel => 'החליקי כדי לסיים';

  @override
  String get sessionEndOverlaySimBadge => '[SIM] מצב תרגול';

  @override
  String get sessionEndPinPromptTitle => 'הזיני PIN לסיום מושב';

  @override
  String get sessionEndPinAppPinMismatch =>
      'השתמשי ב-PIN לסיום מושב, לא ב-PIN לנעילת האפליקציה.';

  @override
  String get sessionEndPinIncorrect => 'PIN שגוי';

  @override
  String get sessionEndPinSimSkip => 'דלגי (סימולציה בלבד)';

  @override
  String get sessionEndSimDistressWouldFire =>
      'שרשרת המצוקה הייתה מופעלת (5 קודי PIN שגויים)';

  @override
  String get distressConfirmTitle => 'מצוקה הופעלה';

  @override
  String distressConfirmCountdown(int seconds) {
    return 'הקישי לביטול — נותרו לך $seconds שניות';
  }

  @override
  String get distressConfirmCancel => 'הקישי לביטול';

  @override
  String get distressConfirmFooter => 'אם לא יבוטל, שרשרת המצוקה תתחיל מיד.';

  @override
  String get distressCancelPinPromptTitle => 'הזיני PIN לסיום מושב';

  @override
  String distressCancelPinTimeoutLabel(int seconds) {
    return 'נותרו $seconds שניות';
  }

  @override
  String get distressCancelPinIncorrect => 'PIN שגוי';

  @override
  String get distressCancelPinAppPinMismatch =>
      'השתמשי ב-PIN לסיום מושב, לא ב-PIN לנעילת האפליקציה.';

  @override
  String get distressCancelPinSimSkip => 'דלגי (סימולציה בלבד)';

  @override
  String get distressCancelSimDistressWouldFire =>
      'שרשרת המצוקה הייתה מופעלת (5 קודי PIN שגויים)';

  @override
  String get distressCancelPinBack => 'ביטול';

  @override
  String get simulationPinPromptTitle => 'הזיני PIN';

  @override
  String get simulationPinPromptBody => 'תרגלי הזנת ה-PIN לסיום מושב';

  @override
  String get simulationPinPromptSkip => 'דלגי';

  @override
  String get simulationPinIncorrect => 'PIN שגוי';

  @override
  String simulationSummaryDuration(String duration) {
    return 'משך: $duration';
  }

  @override
  String get simulationSummaryTimelineHeader => 'ציר זמן של אירועים';

  @override
  String get simulationSummaryShare => 'שתפי';

  @override
  String simulationSummaryMissedEventsBadge(int count) {
    return 'הוחמצו: $count';
  }

  @override
  String simulationSummaryDistressBadge(int count) {
    return 'מצוקה: $count';
  }

  @override
  String simulationSummaryStepsFiredBadge(int count) {
    return 'שלבים שהופעלו: $count';
  }

  @override
  String get simulationSummaryShareSubject =>
      'סיכום סימולציה של Guardian Angela';

  @override
  String get notificationsChannelAlarm => 'הסלמת אזעקה';

  @override
  String get notificationsChannelAlarmDescription =>
      'התראות קריטיות שעוקפות מצב נא לא להפריע';

  @override
  String get notificationsChannelReminder => 'תזכורת מוסווית';

  @override
  String get notificationsChannelReminderDescription =>
      'תזכורות צ\'ק-אין במהלך מושב פעיל';

  @override
  String get notificationsChannelFakeCall => 'שיחה מזויפת';

  @override
  String get notificationsChannelFakeCallDescription =>
      'התראות שיחה נכנסת במסך מלא';

  @override
  String get notificationsChannelEnabled => 'מופעל';

  @override
  String get notificationsChannelDisabled => 'מושבת';

  @override
  String get notificationsChannelsHeader => 'ערוצי התראות';

  @override
  String get contactsImportFromDevice => 'ייבאי מאנשי הקשר';

  @override
  String get contactsImportNotSupported => 'לא זמין בפלטפורמה הזו';

  @override
  String get contactsImportPermissionDenied =>
      'הגישה לאנשי הקשר נדחתה. אפשרי אותה בהגדרות המערכת.';

  @override
  String get contactsDeleteAllMenu => 'מחק הכל';

  @override
  String get contactsDeleteAllConfirmTitle => 'למחוק את כל אנשי הקשר?';

  @override
  String get contactsDeleteAllConfirmBody =>
      'פעולה זו מסירה כל איש קשר לחירום. אין אפשרות ביטול.';

  @override
  String get contactsDeleteAllTypeConfirmTitle => 'אשרי על ידי הקלדה';

  @override
  String get contactsDeleteAllTypeConfirmHint => 'הקלידי DELETE ALL כדי להמשיך';

  @override
  String get contactsDeleteAllTypeConfirmSentinel => 'DELETE ALL';

  @override
  String get contactsDeleteAllConfirmButton => 'מחק הכל';

  @override
  String get modesBuiltinBadge => 'מוטמע';

  @override
  String get modesBuiltinNoDelete => 'לא ניתן למחוק מצבים מוטמעים';

  @override
  String get sessionCompletedSimulationBanner => 'הסימולציה הושלמה';

  @override
  String get sessionCompletedViewEventLog => 'הצג יומן אירועים';

  @override
  String get settingsGeneralHeader => 'כללי';

  @override
  String get settingsAppHeader => 'אפליקציה';

  @override
  String get settingsConfigurationHeader => 'תצורה';

  @override
  String get settingsThemeLabel => 'ערכת נושא';

  @override
  String get settingsLanguageLabel => 'שפה';

  @override
  String get settingsSecurityRow => 'אבטחה';

  @override
  String get settingsSecuritySubtitle =>
      'PIN לאפליקציה, PIN לסיום מושב, PIN לכפייה';

  @override
  String get settingsStealthRow => 'הסתרה';

  @override
  String get settingsStealthSummaryOff => 'הסתרה: כבוי';

  @override
  String get settingsStealthSummaryOn => 'הסתרה: פעיל';

  @override
  String get settingsProfileRow => 'פרופיל';

  @override
  String get settingsModesRow => 'מצבים';

  @override
  String get settingsDistressModesRow => 'מצבי מצוקה';

  @override
  String get settingsEventDefaultsRow => 'ברירות מחדל לשלבים';

  @override
  String get settingsGpsLoggingRow => 'רישום GPS';

  @override
  String get settingsRemindersRow => 'תבניות תזכורת';

  @override
  String get settingsNotificationsRow => 'התראות';

  @override
  String get settingsHistoryRetentionRow => 'היסטוריה ושמירה';

  @override
  String get settingsAboutRow => 'אודות';

  @override
  String get settingsFeedbackRow => 'שליחת משוב';

  @override
  String get settingsBackupRow => 'גיבוי ושחזור';

  @override
  String get settingsOssLicenses => 'רישיונות קוד פתוח';

  @override
  String get settingsImportConfirmBody =>
      'פעולה זו תדרוס את כל הנתונים הנוכחיים. להמשיך?';

  @override
  String get securityAppPinTitle => 'PIN לאפליקציה';

  @override
  String get securityAppPinBody => 'נועל את האפליקציה בכל פעם שאת פותחת אותה.';

  @override
  String get securitySessionEndPinTitle => 'PIN לסיום מושב';

  @override
  String get securitySessionEndPinBody => 'נדרש כדי לנטרל או לסיים מושב פעיל.';

  @override
  String get securityDuressPinTitle => 'PIN לכפייה';

  @override
  String get securityDuressPinBody =>
      'מוזן בכל בקשת PIN כדי להפעיל בשקט את שרשרת המצוקה.';

  @override
  String get securityRemovePin => 'הסר';

  @override
  String get securityRemovePinPrompt => 'הזן את ה-PIN הנוכחי שלך כדי להסירו.';

  @override
  String get securityRemovePinIncorrect => 'PIN שגוי';

  @override
  String get securityWhatIsThis => 'מה זה?';

  @override
  String get securityAppPinInfo =>
      'נועל את האפליקציה כשאת פותחת אותה. מקלדת המספרים מופיעה לפני כל מסך. שימושי אם מישהו מחזיק לרגע את הטלפון הלא-נעול שלך.';

  @override
  String get securitySessionEndPinInfo =>
      'נדרש כדי לנטרל או לסיים מושב בטיחות פעיל. בלעדיו, תוקף שלוקח את הטלפון שלך אינו יכול לעצור את השרשרת. הגדירי קוד שונה מה-PIN לאפליקציה.';

  @override
  String get securityDuressPinInfo =>
      'אם תזיני אי פעם את ה-PIN הזה בכל בקשה, שרשרת המצוקה רצה בשקט — אנשי הקשר שלך מקבלים התראה והאזעקה דרוכה מבלי שהתוקף יבחין. בחרי קוד שונה מכל PIN אחר.';

  @override
  String get securityPinTimeoutLabel => 'פסק זמן ל-PIN (שניות)';

  @override
  String get securityWrongPinThresholdLabel => 'ניסיונות PIN שגויים לפני הסלמה';

  @override
  String get securityDeceptiveDialogToggle => 'הצג חלון מטעה בעת PIN שגוי';

  @override
  String get pinSetupEnterNew => 'הזיני PIN חדש';

  @override
  String get pinSetupConfirmNew => 'אשרי את ה-PIN החדש';

  @override
  String get pinSetupTooShort => 'ה-PIN חייב להיות באורך 4 ספרות לפחות.';

  @override
  String get pinSetupCollision => 'ה-PIN הזה מתנגש עם PIN אחר שהוגדר.';

  @override
  String get pinSetupSaved => 'ה-PIN נשמר';

  @override
  String get stealthEnabledLabel => 'אפשרי הסתרה';

  @override
  String get stealthFakeNameLabel => 'שם אפליקציה מזויף';

  @override
  String get stealthFakeIconLabel => 'אייקון מזויף';

  @override
  String get stealthNotificationDisguiseLabel => 'הסוואת התראות';

  @override
  String get stealthTimerDisplayLabel => 'תצוגת טיימר';

  @override
  String get stealthSessionScreenLabel => 'הסתרת מסך המושב';

  @override
  String get gpsLoggingEnabled => 'רשום GPS במהלך מושבים';

  @override
  String get gpsLoggingIntervalLabel => 'מרווח';

  @override
  String get gpsLoggingAccuracyLabel => 'דיוק';

  @override
  String get gpsLoggingAccuracyHigh => 'גבוה';

  @override
  String get gpsLoggingAccuracyBalanced => 'מאוזן';

  @override
  String get gpsLoggingAccuracyLow => 'נמוך';

  @override
  String get gpsLoggingFormatLabel => 'פורמט קואורדינטות';

  @override
  String get gpsLoggingFormatDecimal => 'עשרוני';

  @override
  String get gpsLoggingFormatDms => 'DMS';

  @override
  String get gpsLoggingFormatAddress => 'Plus Code';

  @override
  String get gpsLoggingIncludeInSms => 'צרפי מיקום ל-SMS';

  @override
  String get historyRetentionLogsLabel => 'שמירת יומני מושב (ימים)';

  @override
  String get historyRetentionLogsHelper => 'יומנים ישנים מכך עוברים לאשפה.';

  @override
  String get historyRetentionTrashLabel => 'שמירת אשפה (ימים)';

  @override
  String get historyRetentionTrashHelper =>
      'יומנים באשפה נמחקים לצמיתות בתום חלון זמן זה.';

  @override
  String get historyRetentionUpdated => 'השמירה עודכנה';

  @override
  String get historyRetentionPurgeNow => 'נקה כעת';

  @override
  String historyRetentionPurged(Object count) {
    return 'נוקו $count יומנים';
  }

  @override
  String get eventDefaultsCheckInHeader => 'שיטות צ\'ק-אין';

  @override
  String get eventDefaultsEscalationHeader => 'שלבי הסלמה';

  @override
  String get eventDefaultsPanicHeader => 'טריגר פאניקה';

  @override
  String get templatesCreate => 'צרי תבנית';

  @override
  String get templatesEditTitle => 'ערוך תבנית';

  @override
  String get templatesCreateTitle => 'תבנית חדשה';

  @override
  String get templatesNameLabel => 'שם';

  @override
  String get templatesTitleLabel => 'כותרת';

  @override
  String get templatesBodyLabel => 'תוכן';

  @override
  String get templatesBuiltinNoDelete => 'לא ניתן למחוק תבניות מוטמעות';

  @override
  String get templatesAddFromTemplate => 'מתוך תבנית';

  @override
  String get templatesAddFromScratch => 'מאפס';

  @override
  String templatesDeleteConfirmTitle(Object name) {
    return 'למחוק את \"$name\"?';
  }

  @override
  String get templatesDeleteConfirmBody => 'תבנית זו תוסר לצמיתות.';

  @override
  String get templatesEmptyAddFirst => 'הוסיפי את התבנית הראשונה שלך';

  @override
  String get templatesPickFromBuiltinTitle => 'בחרי תבנית מוטמעת';

  @override
  String get templatesIconLabel => 'אייקון';

  @override
  String get templatesIconCalendar => 'יומן';

  @override
  String get templatesIconAppNotification => 'התראת אפליקציה';

  @override
  String get templatesIconFitness => 'כושר';

  @override
  String get templatesIconHealth => 'בריאות';

  @override
  String get templatesIconFood => 'אוכל';

  @override
  String get templatesIconCoffee => 'קפה';

  @override
  String get templatesIconBattery => 'סוללה';

  @override
  String get templatesIconWeather => 'מזג אוויר';

  @override
  String get templatesPreviewHeading => 'תצוגה מקדימה חיה';

  @override
  String get templatesDiscardChangesTitle => 'לבטל שינויים?';

  @override
  String get templatesDiscardChangesBody => 'עריכות שלא נשמרו יאבדו.';

  @override
  String get templatesDiscardKeep => 'המשך עריכה';

  @override
  String get templatesDiscardDiscard => 'בטל';

  @override
  String get notificationsTitle => 'התראות';

  @override
  String get notificationsStatusGranted => 'אושר';

  @override
  String get notificationsStatusDenied => 'נדחה';

  @override
  String get notificationsStatusUnknown => 'טרם התבקש';

  @override
  String get notificationsRequest => 'בקשי הרשאה';

  @override
  String get notificationsOpenSettings => 'פתחי את הגדרות המערכת';

  @override
  String get profileFieldPhone => 'מספר טלפון';

  @override
  String get profileFieldDescription => 'תיאור גופני';

  @override
  String get profileFieldMedicalConditions => 'מצבים רפואיים';

  @override
  String get profileFieldEmergencyInstructions => 'הוראות לשעת חירום';

  @override
  String get aboutAuthor => 'מחבר: Jonas Eschle';

  @override
  String get aboutEmail => 'guardian.angela.app@gmail.com';

  @override
  String get aboutPrivacyPolicy => 'מדיניות פרטיות';

  @override
  String get aboutTermsOfService => 'תנאי שימוש';

  @override
  String get aboutSourceCode => 'קוד מקור';

  @override
  String get aboutSupport => 'תמיכה / תרומה';

  @override
  String get aboutLicenses => 'רישיונות קוד פתוח';

  @override
  String get aboutTagline => 'נוצר באהבה למען בטיחות הקהילה הלהט\"בית.';

  @override
  String get aboutTechnicalSection => 'מידע טכני';

  @override
  String aboutBundleId(Object id) {
    return 'מזהה חבילה: $id';
  }

  @override
  String aboutPlatforms(Object list) {
    return 'פלטפורמות: $list';
  }

  @override
  String get feedbackHeading => 'נשמח לשמוע ממך';

  @override
  String get feedbackCategoryLabel => 'קטגוריה';

  @override
  String get feedbackCategoryBug => 'דיווח על תקלה';

  @override
  String get feedbackCategoryFeature => 'בקשת תכונה';

  @override
  String get feedbackCategoryOther => 'אחר';

  @override
  String get feedbackEmailLabel => 'אימייל (אופציונלי)';

  @override
  String get feedbackMessageLabel => 'הודעה';

  @override
  String get feedbackIncludeLog => 'צרפי את יומן המושב האחרון';

  @override
  String get feedbackSent => 'תודה על המשוב שלך!';

  @override
  String get feedbackMessageRequired =>
      'ההודעה חייבת להיות באורך 10 תווים לפחות.';

  @override
  String get backupIncludeLogs => 'כללי יומני מושב';

  @override
  String get backupIncludeMedia => 'כללי מדיה';

  @override
  String get backupExportButton => 'ייצא';

  @override
  String get backupImportButton => 'ייבא';

  @override
  String get backupOverwriteWarning => 'ייבוא דורס את כל הנתונים הנוכחיים.';

  @override
  String get backupImportSuccess => 'הייבוא הושלם. הפעילי מחדש כדי להחיל.';

  @override
  String backupImportError(Object message) {
    return 'הייבוא נכשל: $message';
  }

  @override
  String get backupActiveSessionBanner => 'הגיבוי אינו זמין במהלך מושב פעיל.';

  @override
  String backupLastBackupAtLabel(Object when) {
    return 'הגיבוי האחרון ב-$when';
  }

  @override
  String get backupNeverExportedLabel => 'אין עדיין גיבוי';

  @override
  String get pastEventsTitle => 'מושבים קודמים';

  @override
  String get pastEventsTabReal => 'אמיתי';

  @override
  String get pastEventsTabSimulated => 'סימולציה';

  @override
  String get pastEventsEmpty => 'אין מושבים עדיין';

  @override
  String get pastEventsDeleteConfirm => 'למחוק את יומן המושב?';

  @override
  String get pastEventsDetailShareText => 'שתפי כטקסט';

  @override
  String get pastEventsDetailSharePdf => 'שתפי כ-PDF';

  @override
  String get pastEventsDetailDelete => 'מחק';

  @override
  String get pastEventsOutcomeCompleted => 'הושלם';

  @override
  String get pastEventsOutcomeDistress => 'מצוקה';

  @override
  String get pastEventsOutcomeInterrupted => 'הופסק';

  @override
  String get pastEventsTrash => 'אשפה';

  @override
  String get pastEventsUndo => 'בטל';

  @override
  String get pastEventsSoftDeleted => 'הועבר לאשפה';

  @override
  String get pastEventsDetailTitle => 'יומן מושב';

  @override
  String get pastEventsDetailShare => 'שתפי';

  @override
  String get contactUnsavedDiscardTitle => 'לבטל שינויים שלא נשמרו?';

  @override
  String get contactUnsavedDiscardKeep => 'המשך עריכה';

  @override
  String get contactUnsavedDiscardDiscard => 'בטל';

  @override
  String get modesDuplicate => 'שכפל';

  @override
  String get modesDeleteConfirmTitle => 'למחוק את המצב?';

  @override
  String modesDeleteConfirmBody(Object name) {
    return '$name יוסר לצמיתות.';
  }

  @override
  String get modesDistressDefaultBadge => 'ברירת מחדל';

  @override
  String get modesDistressSetDefault => 'קבעי כברירת מחדל';

  @override
  String get modesDistressCantDeleteLast => 'נדרש לפחות מצב מצוקה אחד.';

  @override
  String get modesDistressInUse => 'מצב מצוקה זה נמצא בשימוש על ידי מצב אחר.';

  @override
  String get modesDistressTitle => 'מצבי מצוקה';

  @override
  String get validationNameTooShort => 'השם חייב להיות באורך 2 תווים לפחות.';

  @override
  String get validationPhoneRequired => 'מספר טלפון הוא שדה חובה.';

  @override
  String get validationChannelsRequired => 'בחרי לפחות ערוץ אחד.';

  @override
  String get validationChainEmpty => 'הוסף לפחות שלב אחד לפני השמירה.';

  @override
  String get validationGpsFixedCoords =>
      'הגדר קו רוחב וקו אורך עבור יעד ההגעה הקבוע.';

  @override
  String get validationHardwareTrigger =>
      'טריגר המצוקה החומרתי אינו שלם — בדוק את מספר הלחיצות או את משך הלחיצה הארוכה.';

  @override
  String get validationSmsChannelNotOnContacts =>
      'אף אחד מאנשי הקשר שנבחרו אינו יכול לקבל בערוץ של שלב זה. בחר ערוץ אחר או הוסף אותו לאיש קשר.';

  @override
  String get validationDistressNoActionTitle => 'אין שלב התראה יוצא';

  @override
  String get validationDistressNoActionBody =>
      'למצב מצוקה זה אין שלב SMS או שיחה, ולכן הוא אינו מותיר עקבות יוצאים. לשמור בכל זאת?';

  @override
  String get validationSaveAnyway => 'שמור בכל זאת';

  @override
  String get sessionHoldTouchToBegin => 'געי כדי להתחיל';

  @override
  String sessionHoldReleaseCountdown(Object seconds) {
    return 'ספירה לאחור: $seconds שניות';
  }

  @override
  String sessionHoldGraceCountdown(Object seconds) {
    return 'חסד: $seconds שניות — החזיקי שוב כדי להישאר בטוחה';
  }

  @override
  String get sessionHoldAgain => 'החזיקי שוב כדי להישאר בטוחה';

  @override
  String sessionStepNextCheckIn(Object time) {
    return 'צ\'ק-אין הבא בעוד $time';
  }

  @override
  String sessionStepFakeCallActive(Object caller) {
    return 'שיחה נכנסת מ-$caller';
  }

  @override
  String get sessionStepFakeCallOpen => 'פתחי את מסך השיחה';

  @override
  String sessionStepSimBlockedSms(Object count) {
    return '[SIM] הודעת SMS הייתה נשלחת ל-$count אנשי קשר';
  }

  @override
  String get sessionStepSimBlockedPhone =>
      '[SIM] הייתה מתבצעת שיחה לאיש קשר חירום';

  @override
  String get sessionStepSimBlockedEmergency =>
      '[SIM] הייתה מתבצעת שיחה לשירותי חירום';

  @override
  String get sessionStepSimBlockedAlarm =>
      '[SIM] האזעקה הייתה צופרת בעוצמה מלאה';

  @override
  String get sessionStartFailedTitle => 'לא ניתן להתחיל מושב';

  @override
  String get sessionStartFailedBody => 'תקני את הבעיות הבאות לפני שתתחילי:';

  @override
  String get sessionQuickExitTitle => 'יציאה מהירה';

  @override
  String get sessionQuickExitBody =>
      'נתוני המושב יישמרו ויוצפנו. פתחי שוב את האפליקציה בכל עת כדי לשחזר אותם.';

  @override
  String get sessionQuickExitConfirm => 'צאי מהאפליקציה';

  @override
  String get pastEventsRestore => 'שחזרי';

  @override
  String get stepEditorWait => 'המתנה (ש\')';

  @override
  String get stepEditorDuration => 'משך (ש\')';

  @override
  String get stepEditorGrace => 'חסד (ש\')';

  @override
  String get stepEditorRetryCount => 'מספר ניסיונות חוזרים';

  @override
  String get stepEditorRandomize => 'הגרל תזמון (20%±)';

  @override
  String get stepEditorRemove => 'הסר שלב';

  @override
  String get eventDefaultsHoldStyle => 'סגנון החזקה';

  @override
  String get eventDefaultsHoldSensitivity => 'רגישות שחרור';

  @override
  String get eventDefaultsHoldVibrate => 'רטט בעת שחרור';

  @override
  String get eventDefaultsHoldSound => 'צליל בעת שחרור';

  @override
  String get eventDefaultsBlackScreen => 'שכבת מסך שחור';

  @override
  String get eventDefaultsReminderRandomInterval => 'הגרל מרווח';

  @override
  String get eventDefaultsReminderRandomTemplate => 'הגרל סדר תבניות';

  @override
  String get eventDefaultsReminderResetOnEarly => 'אפס בצ\'ק-אין מוקדם';

  @override
  String get eventDefaultsCountdownStyle => 'סגנון ספירה לאחור';

  @override
  String get eventDefaultsCountdownVibrate => 'רטט';

  @override
  String get eventDefaultsCountdownSound => 'צליל';

  @override
  String get eventDefaultsFakeCallStyle => 'סגנון שיחה';

  @override
  String get eventDefaultsFakeCallCallerName => 'שם המתקשר';

  @override
  String get eventDefaultsFakeCallRingDuration => 'משך צלצול (ש\')';

  @override
  String get eventDefaultsFakeCallDeclineIsSafe => 'דחייה נחשבת כבטוחה';

  @override
  String get eventDefaultsFakeCallVoiceOutput => 'פלט קולי';

  @override
  String get eventDefaultsFakeCallRingtone => 'צלצול';

  @override
  String get eventDefaultsFakeCallRingtoneDefault => 'צלצול ברירת מחדל';

  @override
  String eventDefaultsFakeCallRingtoneCustom(String fileName) {
    return 'מותאם אישית: $fileName';
  }

  @override
  String get eventDefaultsFakeCallRingtoneChoose => 'בחירת צלצול…';

  @override
  String get eventDefaultsFakeCallRingtoneUseDefault => 'השתמש בברירת המחדל';

  @override
  String get eventDefaultsSmsChannel => 'ערוץ';

  @override
  String get eventDefaultsSmsIncludeLocation => 'כלול מיקום';

  @override
  String get eventDefaultsSmsIncludeMedical => 'כלול מידע רפואי';

  @override
  String get eventDefaultsSmsAutoRecord => 'הקלט שמע לפני השליחה';

  @override
  String get eventDefaultsSmsRecordDuration => 'משך הקלטה (ש\')';

  @override
  String get eventDefaultsSmsMessageTemplate => 'תבנית הודעה';

  @override
  String get eventDefaultsSmsMessageTemplateHint =>
      'השאר ריק כדי להשתמש בהתראת ברירת המחדל. הקש על מציין מיקום כדי להוסיף אותו.';

  @override
  String get eventDefaultsSmsIosWarning =>
      'ב‑iPhone, שליחת SMS מחייבת ללחוץ ידנית על שליחה באפליקציית ההודעות. אם אינך יכול להשתמש בטלפון, ההודעה לא תישלח. שקול להשתמש ב‑WhatsApp או ב‑Telegram במקום זאת.';

  @override
  String get eventDefaultsLoudAlarmVolume => 'עוצמה';

  @override
  String get eventDefaultsLoudAlarmSound => 'צליל';

  @override
  String get eventDefaultsLoudAlarmFlashScreen => 'הבהוב מסך';

  @override
  String get eventDefaultsLoudAlarmFlashLight => 'הבהוב פלאש המצלמה';

  @override
  String get eventDefaultsLoudAlarmGradual => 'עליית עוצמה הדרגתית';

  @override
  String get eventDefaultsCallEmergencyNumber => 'מספר חירום (עקיפה)';

  @override
  String get eventDefaultsCallEmergencyConfirm => 'הצג ספירת אישור לאחור';

  @override
  String get eventDefaultsCallEmergencyConfirmDuration => 'שניות אישור';

  @override
  String get eventDefaultsCallEmergencySmsFirst => 'שלח תחילה SMS עם מיקום';

  @override
  String get eventDefaultsCallEmergencyIosWarning =>
      'ב‑iPhone, לפני החיוג תופיע תיבת אישור. הקש במהירות על ‚התקשר‘.';

  @override
  String get eventDefaultsPhonePrimaryContact => 'איש קשר ראשי (מזהה)';

  @override
  String get eventDefaultsHardwareButton => 'כפתור';

  @override
  String get eventDefaultsHardwarePattern => 'תבנית לחיצה';

  @override
  String get eventDefaultsHardwarePressCount => 'מספר לחיצות';

  @override
  String get eventDefaultsHardwareLongDuration => 'משך לחיצה ארוכה (ש\')';

  @override
  String get pastEventsTrashTitle => 'אשפה';

  @override
  String get pastEventsTrashEmpty => 'האשפה ריקה';

  @override
  String get pastEventsTrashEmptyAll => 'רוקני אשפה';

  @override
  String get pastEventsTrashEmptyAllConfirmTitle => 'לרוקן את האשפה?';

  @override
  String get pastEventsTrashEmptyAllConfirmBody =>
      'הקלידי EMPTY TRASH למטה כדי לאשר. פעולה זו מוחקת לצמיתות כל יומן באשפה.';

  @override
  String pastEventsTrashEmptyAllSuccess(Object count) {
    return 'האשפה רוקנה ($count יומנים)';
  }

  @override
  String pastEventsTrashRetentionNote(int days) {
    return 'יומנים באשפה נמחקים לצמיתות לאחר $days ימים.';
  }

  @override
  String pastEventsTrashRemainingDays(int days) {
    return '$days ימים עד למחיקה לצמיתות';
  }

  @override
  String get pastEventsTrashDeletePermanently => 'מחק לצמיתות';

  @override
  String get pastEventsTrashDeletePermanentlyBody => 'לא ניתן לבטל פעולה זו.';

  @override
  String sessionEmergencyConfirmTitle(String number, int seconds) {
    return 'מתקשרת אל $number בעוד $seconds שניות';
  }

  @override
  String get sessionEmergencyConfirmSwipe => 'החליקי לביטול';

  @override
  String get sessionEmergencyConfirmKeep => 'המשיכי בשיחה';

  @override
  String get sessionEmergencyConfirmSimBadge => '[SIM] מצב תרגול';

  @override
  String get sessionEmergencyConfirmSimCancelled =>
      'ביטול מדומה — השיחה לא הייתה מתבצעת';

  @override
  String get swipeSliderSemantics => 'החליקי כדי לאשר';

  @override
  String get homeWidgetStatusIdle => 'בהמתנה';

  @override
  String get homeWidgetStatusSession => 'מושב פעיל';

  @override
  String get homeWidgetStatusSim => 'סימולציה פעילה';

  @override
  String get homeWidgetQuickExit => 'יציאה מהירה';

  @override
  String get homeWidgetFakeCall => 'שיחה מזויפת';

  @override
  String get settingsAlarmHeader => 'התרעה';

  @override
  String get settingsAlarmDndOverrideLabel => 'ההתרעה עוקפת מצב שקט/רטט';

  @override
  String get settingsAlarmDndOverrideWarning =>
      'אזהרה: ההתרעה תהיה שקטה אם הטלפון שלך במצב שקט.';

  @override
  String get settingsAlarmDndOverrideInfo =>
      'כשמופעל, ההתרעה הרועשת תושמע בעוצמה מלאה גם אם הטלפון במצב שקט או רטט. ב-Android נעשה שימוש בערוץ השמע של ההתרעה כדי לעקוף את מצב «נא לא להפריע». ההתרעה היא האירוע היחיד שיכול לעקוף את הגדרות הצליל של הטלפון שלך.';

  @override
  String get settingsAlarmGradualLabel => 'הגברת עוצמת ההתרעה בהדרגה';

  @override
  String get settingsAlarmGradualInfo =>
      'מתחיל את ההתרעה בשקט ומעלה אותה עד לעוצמה מלאה. זהו המתג הראשי לכל האפליקציה; לכל שלב התרעה יש גם אפשרות עוצמה הדרגתית משלו, ושניהם חייבים להיות מופעלים כדי שההגברה תחול.';

  @override
  String get settingsAlarmRampLabel => 'משך ההגברה';

  @override
  String get settingsAlarmRampInfo =>
      'כמה זמן לוקח להתרעה להגיע לעוצמה מלאה מאפס, בעלייה אחידה לאורך זמן זה. אין לכך השפעה כשהעוצמה ההדרגתית כבויה.';

  @override
  String get permissionNotifRationaleTitle => 'לאפשר התראות?';

  @override
  String get permissionNotifRationaleBody =>
      '‏Guardian Angela משתמש בהתראות כדי להתריע לך ולאנשי הקשר שלך במהלך מפגש בטיחות, כולל תזכורות מוסוות שמעירות את הטלפון הנעול. אפשר התראות כדי שהאפליקציה תוכל ליצור איתך קשר.';

  @override
  String get permissionNotifDeniedTitle => 'ההתראות חסומות';

  @override
  String get permissionNotifDeniedBody =>
      'ההתראות כבויות עבור Guardian Angela. פתח את הגדרות המערכת כדי להפעיל אותן מחדש, כדי שהאפליקציה תוכל להתריע לך במהלך מפגש.';

  @override
  String get permissionNotifAllow => 'אפשר';

  @override
  String get permissionNotifOpenSettings => 'פתח הגדרות';

  @override
  String get permissionNotifNotNow => 'לא עכשיו';

  @override
  String get homeStartTriggersSummaryTitle => 'לפני שמתחילים';

  @override
  String get homeStartTriggersDistressHeading => 'טריגר מצוקה';

  @override
  String get homeStartTriggersDisarmHeading => 'טריגר סיום אוטומטי';

  @override
  String get homeStartTriggersNone => 'לא הוגדר';

  @override
  String homeStartTriggerButtonRepeat(String button, String count) {
    return 'לחץ על $button $count פעמים';
  }

  @override
  String homeStartTriggerButtonLong(String button, String seconds) {
    return 'החזק את $button למשך $seconds שניות';
  }

  @override
  String get homeStartTriggerButtonVolumeUp => 'הגברת עוצמה';

  @override
  String get homeStartTriggerButtonVolumeDown => 'החלשת עוצמה';

  @override
  String homeStartTriggerGpsArrival(String radius) {
    return 'מסתיים בהגעה למרחק $radius מ\' מהיעד';
  }

  @override
  String get homeStartTriggerGpsPrompt => 'תתבקש להזין את היעד לאחר ההתחלה';

  @override
  String homeStartTriggerTimer(String minutes) {
    return 'מסתיים אוטומטית לאחר $minutes דקות';
  }

  @override
  String get homeStartTriggersContinue => 'התחל עכשיו';

  @override
  String get homeStartTriggersCancel => 'ביטול';

  @override
  String get homeStartBlockedNotifTitle => 'נדרשות התראות';

  @override
  String get homeStartBlockedNotifBody =>
      'מצב זה משתמש בהתראות (תזכורות מוסוות או שיחות מזויפות) כדי לשמור על ביטחונך, אך הרשאת ההתראות כבויה. הפעל התראות כדי להתחיל מצב זה.';
}
