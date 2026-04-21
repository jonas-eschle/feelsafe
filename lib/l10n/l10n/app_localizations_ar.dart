// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'Guardian Angela';

  @override
  String get commonSave => 'حفظ';

  @override
  String get commonCancel => 'إلغاء';

  @override
  String get commonDelete => 'حذف';

  @override
  String get commonEdit => 'تعديل';

  @override
  String get commonAdd => 'إضافة';

  @override
  String get commonClose => 'إغلاق';

  @override
  String get commonConfirm => 'تأكيد';

  @override
  String get commonBack => 'رجوع';

  @override
  String get commonDone => 'تم';

  @override
  String get commonRetry => 'إعادة المحاولة';

  @override
  String get commonYes => 'نعم';

  @override
  String get commonNo => 'لا';

  @override
  String get commonEnabled => 'مفعّل';

  @override
  String get commonDisabled => 'معطّل';

  @override
  String get commonNone => 'لا شيء';

  @override
  String get commonSeconds => 'ثانية';

  @override
  String get commonMinutes => 'دقيقة';

  @override
  String get cancel => 'إلغاء';

  @override
  String get homeTitle => 'Guardian Angela';

  @override
  String get homeStartSession => 'بدء الجلسة';

  @override
  String get homeSimulate => 'محاكاة';

  @override
  String get homeActiveSession => 'جلسة نشطة';

  @override
  String get homeResumeSession => 'استئناف';

  @override
  String get homeNoModes => 'لا توجد أوضاع بعد. اضغط على الأوضاع لإضافة واحد.';

  @override
  String get homeNoContacts =>
      'لا توجد جهات اتصال للطوارئ بعد. اضغط على جهات الاتصال لإضافة واحدة.';

  @override
  String get homeMenuSettings => 'الإعدادات';

  @override
  String get homeMenuContacts => 'جهات الاتصال';

  @override
  String get homeMenuModes => 'الأوضاع';

  @override
  String get homeMenuHistory => 'الجلسات السابقة';

  @override
  String get homeSelectMode => 'اختر الوضع';

  @override
  String get onboardingWelcomeTitle => 'مرحبًا بك في Guardian Angela';

  @override
  String get onboardingWelcomeBody =>
      'رفيق يحافظ على سلامتك في طريقك إلى المنزل. يراقبك Guardian Angela أثناء المشي أو الجري أو التنقل، ويمكنه تنبيه جهات الاتصال التي تختارها إذا احتجت إلى المساعدة.';

  @override
  String get onboardingProfileTitle => 'الملف الشخصي وأول جهة اتصال';

  @override
  String get onboardingProfileBody =>
      'أخبرنا قليلاً عن نفسك حتى يتمكن Guardian Angela من مشاركة تفاصيل مفيدة إذا احتجت إلى مساعدة طارئة. ثم أضف جهة اتصال موثوقة واحدة.';

  @override
  String get onboardingPermissionsTitle => 'الأذونات';

  @override
  String get onboardingPermissionsBody =>
      'يحتاج Guardian Angela إلى بعض الأذونات للحفاظ على سلامتك. امنحها الآن أو لاحقًا من الإعدادات.';

  @override
  String get onboardingNext => 'التالي';

  @override
  String get onboardingSkip => 'تخطي';

  @override
  String get onboardingFinish => 'إنهاء';

  @override
  String get sessionTitle => 'الجلسة';

  @override
  String get sessionDisarm => 'أنا بأمان';

  @override
  String get sessionPause => 'إيقاف مؤقت';

  @override
  String get sessionResume => 'استئناف';

  @override
  String get sessionHoldPrompt => 'اضغط مع الاستمرار للبقاء بأمان';

  @override
  String get sessionHoldSemantic =>
      'اضغط مع الاستمرار. رفع الإصبع يبدأ فترة السماح.';

  @override
  String sessionStepLabel(Object index, Object total) {
    return 'الخطوة $index من $total';
  }

  @override
  String sessionMissCount(Object count) {
    return 'فائت: $count';
  }

  @override
  String sessionRemaining(Object seconds) {
    return '$seconds ثانية متبقية';
  }

  @override
  String get sessionPausedBadge => 'متوقف مؤقتًا';

  @override
  String get sessionPhaseEnded => 'انتهت الجلسة';

  @override
  String get sessionSimulationBanner => 'محاكاة';

  @override
  String get sessionCompletedTitle => 'اكتملت الجلسة';

  @override
  String get sessionCompletedBody =>
      'لقد وصلت بأمان. Guardian Angela في وضع الاستعداد الآن.';

  @override
  String get sessionCompletedReturnHome => 'العودة إلى الصفحة الرئيسية';

  @override
  String get simulationSummaryTitle => 'ملخص المحاكاة';

  @override
  String get simulationSummaryEmpty =>
      'لم يتم تشغيل أي خطوات خلال هذه المحاكاة.';

  @override
  String get simulationSummaryReturn => 'العودة إلى الصفحة الرئيسية';

  @override
  String get fakeCallTitle => 'مكالمة واردة';

  @override
  String get fakeCallAnswer => 'رد';

  @override
  String get fakeCallDecline => 'رفض';

  @override
  String get fakeCallHangUp => 'إنهاء المكالمة';

  @override
  String get contactsTitle => 'جهات اتصال الطوارئ';

  @override
  String get contactsEmpty =>
      'لا توجد جهات اتصال بعد. أضف واحدة لتلقي رسائل الاستغاثة.';

  @override
  String get contactsAdd => 'إضافة جهة اتصال';

  @override
  String get contactFormTitleCreate => 'جهة اتصال جديدة';

  @override
  String get contactFormTitleEdit => 'تعديل جهة الاتصال';

  @override
  String get contactFieldName => 'الاسم';

  @override
  String get contactFieldPhone => 'رقم الهاتف';

  @override
  String get contactFieldRelationship => 'صلة القرابة (اختياري)';

  @override
  String get contactFieldLanguage => 'لغة الرسائل النصية (اختياري)';

  @override
  String get contactChannelsHeader => 'قنوات المراسلة';

  @override
  String get contactChannelSms => 'رسالة نصية';

  @override
  String get contactChannelWhatsapp => 'WhatsApp';

  @override
  String get contactChannelTelegram => 'Telegram';

  @override
  String get contactChannelPhone => 'مكالمة هاتفية';

  @override
  String get contactDeleteConfirm => 'حذف جهة الاتصال؟';

  @override
  String contactDeleteBody(Object name) {
    return 'ستتم إزالة $name من قائمة الطوارئ.';
  }

  @override
  String get contactRequiredError => 'الاسم ورقم الهاتف مطلوبان.';

  @override
  String get modesTitle => 'الأوضاع';

  @override
  String get modesEmpty => 'لا توجد أوضاع بعد. اضغط على إضافة لإنشاء وضع.';

  @override
  String get modesAdd => 'إضافة وضع';

  @override
  String get modeEditorTitleCreate => 'وضع جديد';

  @override
  String get modeEditorTitleEdit => 'تعديل الوضع';

  @override
  String get modeFieldName => 'الاسم';

  @override
  String get modeFieldCheckInType => 'نوع تسجيل الوصول';

  @override
  String get modeFieldDistressChain => 'سلسلة الاستغاثة';

  @override
  String get modeFieldDistressChainDefault => 'استخدام الافتراضي';

  @override
  String get modeChainHeader => 'سلسلة التصعيد';

  @override
  String get modeChainAddStep => 'إضافة خطوة';

  @override
  String get modeChainEmpty => 'لا توجد خطوات بعد. اضغط على إضافة خطوة.';

  @override
  String get stepTypeHoldButton => 'زر الضغط المستمر';

  @override
  String get stepTypeDisguisedReminder => 'تذكير مموّه';

  @override
  String get stepTypeCountdownWarning => 'تحذير العد التنازلي';

  @override
  String get stepTypeFakeCall => 'مكالمة وهمية';

  @override
  String get stepTypeSmsContact => 'رسالة نصية لجهة اتصال';

  @override
  String get stepTypePhoneCallContact => 'مكالمة لجهة اتصال';

  @override
  String get stepTypeLoudAlarm => 'إنذار عالي الصوت';

  @override
  String get stepTypeCallEmergency => 'الاتصال بالطوارئ';

  @override
  String get stepTypeHardwareButton => 'زر الجهاز';

  @override
  String get stepFieldDuration => 'المدة (بالثواني)';

  @override
  String get stepFieldGrace => 'فترة السماح (بالثواني)';

  @override
  String get stepFieldWait => 'الانتظار (بالثواني)';

  @override
  String get stepFieldRetryCount => 'محاولات إعادة';

  @override
  String get stepFieldRandomize => 'تشويش التوقيت';

  @override
  String get stepPreview => 'معاينة في المحاكاة';

  @override
  String stepPreviewFired(Object description) {
    return 'تم تشغيل المعاينة: $description';
  }

  @override
  String get stepConfigFakeCallCaller => 'اسم المتصل';

  @override
  String get stepConfigFakeCallDecline => 'اعتبار الرفض كإلغاء تنبيه';

  @override
  String get stepConfigLoudAlarmFlash => 'وميض الشاشة';

  @override
  String get stepConfigLoudAlarmVolume => 'أقصى مستوى صوت';

  @override
  String get stepConfigCountdownVibrate => 'اهتزاز';

  @override
  String get stepConfigCountdownTone => 'تشغيل نغمة';

  @override
  String get stepConfigSmsSelection => 'المستلمون';

  @override
  String get stepConfigSmsAllContacts => 'جميع جهات الاتصال';

  @override
  String get stepConfigSmsSpecific => 'جهات اتصال محددة';

  @override
  String get stepConfigSmsIncludeLocation => 'تضمين الموقع';

  @override
  String get stepConfigSmsIncludeMedical => 'تضمين المعلومات الطبية';

  @override
  String get stepConfigHoldReleaseSensitivity => 'حساسية الإفلات (ث)';

  @override
  String get stepConfigReminderInterval => 'الفاصل الزمني للتذكير (بالثواني)';

  @override
  String get stepConfigReminderTemplate => 'القالب';

  @override
  String get stepConfigHardwarePattern => 'النمط';

  @override
  String get stepConfigHardwarePressCount => 'عدد الضغطات';

  @override
  String get stepConfigHardwareButton => 'الزر';

  @override
  String get stepConfigHardwareButtonVolumeUp => 'رفع الصوت';

  @override
  String get stepConfigHardwareButtonVolumeDown => 'خفض الصوت';

  @override
  String get stepConfigHardwareButtonPower => 'زر التشغيل';

  @override
  String get stepConfigHardwarePatternRepeat => 'الضغط المتكرر';

  @override
  String get stepConfigHardwarePatternLong => 'الضغط المطوّل';

  @override
  String get stepConfigEmergencyNumber => 'تجاوز رقم الطوارئ';

  @override
  String get stepConfigEmergencyConfirm => 'التأكيد قبل الاتصال';

  @override
  String get stepConfigPhonePreSms => 'إرسال رسالة نصية قبل الاتصال';

  @override
  String get distressChainsTitle => 'سلاسل الاستغاثة';

  @override
  String get distressChainsEmpty => 'لا توجد سلاسل استغاثة بعد.';

  @override
  String get distressChainsAdd => 'إضافة سلسلة';

  @override
  String get distressChainEditorTitleCreate => 'سلسلة استغاثة جديدة';

  @override
  String get distressChainEditorTitleEdit => 'تعديل سلسلة الاستغاثة';

  @override
  String get distressChainName => 'اسم السلسلة';

  @override
  String get distressCountdown => 'جارٍ تشغيل سلسلة الاستغاثة...';

  @override
  String get distressCountdownStealth => 'يرجى الانتظار...';

  @override
  String get templatesTitle => 'قوالب التذكير';

  @override
  String get templatesEmpty => 'لا توجد قوالب بعد.';

  @override
  String get templatesAdd => 'إضافة قالب';

  @override
  String get templateEditorTitleCreate => 'قالب جديد';

  @override
  String get templateEditorTitleEdit => 'تعديل القالب';

  @override
  String get templateFieldName => 'اسم المحرّر';

  @override
  String get templateFieldTitle => 'عنوان التذكير';

  @override
  String get templateFieldBody => 'نص التذكير';

  @override
  String get templateFieldConfirmationType => 'نوع التأكيد';

  @override
  String get templateFieldKeyword => 'الكلمة المفتاحية';

  @override
  String get templateFieldButtonLabel => 'نص الزر';

  @override
  String get templateFieldDisplayStyle => 'نمط العرض';

  @override
  String get templateConfirmTapButton => 'اضغط على الزر';

  @override
  String get templateConfirmTapWord => 'اضغط على الكلمة';

  @override
  String get templateConfirmSwipe => 'اسحب';

  @override
  String get templateConfirmDismiss => 'تجاهل';

  @override
  String get templateDisplayFullscreen => 'ملء الشاشة';

  @override
  String get templateDisplaySubtle => 'خفيف';

  @override
  String get profileTitle => 'الملف الشخصي';

  @override
  String get profileFieldName => 'الاسم';

  @override
  String get profileFieldAge => 'العمر';

  @override
  String get profileFieldBloodType => 'فصيلة الدم';

  @override
  String get profileFieldAllergies => 'الحساسية';

  @override
  String get profileFieldMedications => 'الأدوية';

  @override
  String get profileFieldConditions => 'الحالات الطبية';

  @override
  String get profileFieldInstructions => 'تعليمات الطوارئ';

  @override
  String get profileAddItem => 'إضافة عنصر';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsSectionSecurity => 'الأمان';

  @override
  String get settingsSectionStealth => 'الوضع المتخفي';

  @override
  String get settingsSectionDefaults => 'الإعدادات الافتراضية';

  @override
  String get settingsSectionHistory => 'السجل';

  @override
  String get settingsSectionBackup => 'النسخ الاحتياطي';

  @override
  String get settingsSectionAbout => 'حول التطبيق';

  @override
  String get settingsSectionFeedback => 'التعليقات';

  @override
  String get settingsSectionContacts => 'جهات الاتصال';

  @override
  String get settingsSectionModes => 'الأوضاع';

  @override
  String get settingsSectionProfile => 'الملف الشخصي';

  @override
  String get settingsSectionDistressChains => 'سلاسل الاستغاثة';

  @override
  String get settingsSectionReminderTemplates => 'قوالب التذكير';

  @override
  String get settingsSectionBatteryAlert => 'تنبيه البطارية';

  @override
  String get settingsSectionEventDefaults => 'افتراضيات الخطوات';

  @override
  String get settingsSectionGpsLogging => 'تسجيل GPS';

  @override
  String get settingsSectionNotifications => 'الإشعارات';

  @override
  String get settingsSectionHistoryRetention => 'مدة الاحتفاظ بالسجل';

  @override
  String get settingsSectionAppearance => 'المظهر';

  @override
  String get settingsThemeMode => 'السمة';

  @override
  String get settingsThemeLight => 'فاتح';

  @override
  String get settingsThemeDark => 'داكن';

  @override
  String get settingsThemeSystem => 'النظام';

  @override
  String get settingsLanguage => 'اللغة';

  @override
  String get settingsEmergencyNumber => 'رقم الطوارئ';

  @override
  String get settingsAlarmDnd => 'الإنذار يتجاوز وضع عدم الإزعاج';

  @override
  String get securityTitle => 'الأمان';

  @override
  String get securityAppPin => 'رمز PIN للتطبيق';

  @override
  String get securitySessionEndPin => 'رمز PIN لإنهاء الجلسة';

  @override
  String get securityDuressPin => 'رمز PIN للإكراه';

  @override
  String get securityPinTimeout => 'مهلة رمز PIN (بالثواني)';

  @override
  String get securityDisablePin => 'تعطيل';

  @override
  String get securitySetPin => 'تعيين رمز PIN';

  @override
  String get securityChangePin => 'تغيير رمز PIN';

  @override
  String get pinSetupTitle => 'تعيين رمز PIN';

  @override
  String get pinSetupEnter => 'أدخل رمز PIN الجديد';

  @override
  String get pinSetupConfirm => 'تأكيد رمز PIN';

  @override
  String get pinSetupMismatch => 'رمزا PIN غير متطابقين. حاول مرة أخرى.';

  @override
  String get pinEntryTitle => 'أدخل رمز PIN';

  @override
  String get pinEntrySubtitle => 'أدخل رمز PIN للمتابعة.';

  @override
  String get stealthTitle => 'الوضع المتخفي';

  @override
  String get stealthEnable => 'تفعيل الوضع المتخفي';

  @override
  String get stealthFakeName => 'اسم تطبيق وهمي';

  @override
  String get stealthFakeIcon => 'أيقونة وهمية';

  @override
  String get stealthNotificationDisguise => 'تمويه الإشعارات';

  @override
  String get stealthTimerDisplay => 'عرض المؤقت في الوضع المتخفي';

  @override
  String get stealthSessionScreen => 'إخفاء العلامة التجارية في شاشة الجلسة';

  @override
  String get stealthPickerTitle => 'أيقونة التطبيق';

  @override
  String get stealthPickerIntro => 'اختر شكل الأيقونة في الشاشة الرئيسية.';

  @override
  String get stealthPresetMusic => 'الموسيقى';

  @override
  String get stealthPresetCalendar => 'التقويم';

  @override
  String get stealthPresetFitness => 'اللياقة';

  @override
  String get stealthPresetWeather => 'الطقس';

  @override
  String get stealthPresetNews => 'الأخبار';

  @override
  String get stealthPresetPhotos => 'الصور';

  @override
  String get stealthPresetNotes => 'الملاحظات';

  @override
  String get stealthPresetClock => 'الساعة';

  @override
  String get distressConfirmationTitle => 'هل أنت في خطر؟';

  @override
  String get distressConfirmationCancel => 'إلغاء';

  @override
  String distressConfirmationCountdown(Object seconds) {
    return 'تبدأ سلسلة الاستغاثة خلال $seconds ثانية';
  }

  @override
  String get imSafeSliderLabel => 'اسحب لتأكيد «أنا بأمان»';

  @override
  String get batteryAlertTitle => 'تنبيه البطارية';

  @override
  String get batteryAlertEnable => 'تفعيل تنبيه البطارية';

  @override
  String batteryAlertThreshold(Object percent) {
    return 'الحد: $percent%';
  }

  @override
  String get eventDefaultsTitle => 'افتراضيات الخطوات';

  @override
  String get eventDefaultsBody =>
      'تنطبق هذه الإعدادات الافتراضية على أي خطوة لا تتجاوزها.';

  @override
  String get gpsLoggingTitle => 'تسجيل GPS';

  @override
  String get gpsLoggingEnable => 'تفعيل تسجيل GPS';

  @override
  String get gpsLoggingInterval => 'فاصل أخذ العينات (بالثواني)';

  @override
  String get gpsLoggingAccuracy => 'الدقة';

  @override
  String get gpsAccuracyLow => 'منخفضة';

  @override
  String get gpsAccuracyMedium => 'متوسطة';

  @override
  String get gpsAccuracyHigh => 'عالية';

  @override
  String get gpsLoggingIncludeSms => 'إرفاق الموقع بالرسالة النصية';

  @override
  String get gpsLoggingHistoryDays => 'الاحتفاظ بالسجل (بالأيام)';

  @override
  String get notificationSettingsTitle => 'الإشعارات';

  @override
  String get notificationSettingsBody =>
      'يستخدم Guardian Angela الإشعارات لتمويه التذكيرات وتشغيلها.';

  @override
  String get historyRetentionTitle => 'مدة الاحتفاظ بالسجل';

  @override
  String get historyRetentionBody =>
      'مدة احتفاظ Guardian Angela بسجلات الجلسات السابقة.';

  @override
  String historyRetentionDays(Object days) {
    return 'الاحتفاظ: $days يومًا';
  }

  @override
  String get backupTitle => 'النسخ الاحتياطي';

  @override
  String get backupExport => 'تصدير البيانات';

  @override
  String get backupImport => 'استيراد البيانات';

  @override
  String get backupNotReady => 'النسخ الاحتياطي غير متاح بعد. سيتوفر قريبًا.';

  @override
  String get backupPinOptional => 'رمز PIN اختياري (يشفّر الحزمة)';

  @override
  String get backupImportOk => 'تم استيراد النسخة الاحتياطية بنجاح.';

  @override
  String get historyTitle => 'الجلسات السابقة';

  @override
  String get historyEmpty => 'لا توجد جلسات سابقة بعد.';

  @override
  String get historyDetailTitle => 'تفاصيل الجلسة';

  @override
  String get evidenceExportTitle => 'تصدير الأدلة';

  @override
  String get evidenceExportAsText => 'نسخ كنص';

  @override
  String get evidenceExportAsJson => 'نسخ بصيغة JSON';

  @override
  String get evidenceCopied => 'تم النسخ إلى الحافظة.';

  @override
  String get aboutTitle => 'حول التطبيق';

  @override
  String get aboutVersion => 'الإصدار';

  @override
  String get aboutCredits => 'صُمم بعناية لكل من هم في طريقهم إلى المنزل.';

  @override
  String get feedbackTitle => 'التعليقات';

  @override
  String get feedbackBody => 'يسعدنا أن نسمع منك.';

  @override
  String get feedbackFieldMessage => 'الرسالة';

  @override
  String get feedbackSend => 'فتح البريد الإلكتروني';

  @override
  String get pickerNoneLabel => '— لا شيء —';
}
