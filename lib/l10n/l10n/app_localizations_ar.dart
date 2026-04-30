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
  String get angelaDialogTitle => 'Old PIN entered';

  @override
  String get angelaDialogBody =>
      'It looks like you used an old PIN. Are you sure you want to proceed?';

  @override
  String get angelaDialogCancel => 'Cancel';

  @override
  String get angelaDialogConfirm => 'Continue';

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
  String get pinSubmit => 'Submit';

  @override
  String get homeTitle => 'Guardian Angela';

  @override
  String get homeStartSession => 'بدء الجلسة';

  @override
  String get homeStartConfirmTitle => 'Start a session?';

  @override
  String get homeStartConfirmBody =>
      'Make sure your contacts and PIN are configured. The session will run in the foreground and your selected mode will guide check-ins.';

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
  String get homeContactsBannerNone => 'No emergency contacts configured.';

  @override
  String homeContactsBannerFew(int count) {
    return '$count contact(s) configured. We recommend at least 3.';
  }

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
  String get modeFieldDistressChain => 'وضع الاستغاثة';

  @override
  String get modeFieldDistressChainDefault => 'استخدام الافتراضي';

  @override
  String get modeChainHeader => 'سلسلة التصعيد';

  @override
  String get modeChainAddStep => 'إضافة خطوة';

  @override
  String get modeChainEmpty => 'لا توجد خطوات بعد. اضغط على إضافة خطوة.';

  @override
  String get modeFieldIcon => 'أيقونة';

  @override
  String get modeIconPickerTitle => 'اختر أيقونة';

  @override
  String get modeIconClear => 'بدون أيقونة';

  @override
  String get modeDistressHeader => 'محفّزات الاستغاثة';

  @override
  String get modeDistressEmpty => 'لم يتم تكوين محفّزات استغاثة.';

  @override
  String get modeDistressAdd => 'إضافة محفّز';

  @override
  String get modeDistressTypeHardware => 'زر فيزيائي';

  @override
  String get modeDistressButtonType => 'الزر';

  @override
  String get modeDistressButtonVolumeUp => 'رفع الصوت';

  @override
  String get modeDistressButtonVolumeDown => 'خفض الصوت';

  @override
  String get modeDistressButtonPower => 'زر التشغيل';

  @override
  String get modeDistressPattern => 'النمط';

  @override
  String get modeDistressPatternRepeat => 'ضغط متكرر';

  @override
  String get modeDistressPatternLong => 'ضغط مطوّل';

  @override
  String get modeDistressPressCount => 'عدد الضغطات';

  @override
  String get modeDistressPressWindow => 'النافذة (مللي ثانية)';

  @override
  String get modeDistressLongDuration => 'مدة الاستمرار (ثوانٍ)';

  @override
  String modeDistressSummaryRepeat(Object count, Object windowMs) {
    return '$count ضغطات / $windowMs مللي ثانية';
  }

  @override
  String modeDistressSummaryLong(Object seconds) {
    return 'اضغط مطولاً $secondsث';
  }

  @override
  String get modeOverridesHeader => 'تجاوزات الوضع';

  @override
  String get modeOverridesUseDefault => 'استخدام الإعداد الافتراضي';

  @override
  String get modeOverridesGpsLabel => 'تسجيل GPS';

  @override
  String get modeOverridesStealthLabel => 'التخفي';

  @override
  String get modeOverridesEventDefaultsLabel => 'افتراضيات الأحداث';

  @override
  String get modeOverridesLocalTemplatesLabel => 'قوالب التذكير المحلية';

  @override
  String get modeOverridesGpsEnabled => 'GPS مفعّل';

  @override
  String get modeOverridesGpsIntervalLabel => 'فاصل العينة (ثوانٍ)';

  @override
  String get modeOverridesGpsIncludeInSms => 'إضافة الموقع إلى الرسائل';

  @override
  String get modeOverridesStealthEnabled => 'التخفي مفعّل';

  @override
  String get modeOverridesStealthFakeName => 'اسم وهمي للتطبيق';

  @override
  String get modeOverridesEventDefaultsHint =>
      'افتراضيات مخصصة نشطة لهذا الوضع.';

  @override
  String modeOverridesLocalTemplatesCount(Object count) {
    return '$count قوالب محلية';
  }

  @override
  String get modeUnsavedTitle => 'تجاهل التغييرات؟';

  @override
  String get modeUnsavedBody =>
      'لديك تغييرات غير محفوظة. تجاهلها والخروج من المحرر؟';

  @override
  String get modeUnsavedDiscard => 'تجاهل';

  @override
  String get modeUnsavedKeep => 'متابعة التحرير';

  @override
  String get stepDuplicate => 'نسخ الخطوة';

  @override
  String get stepTimingHeader => 'التوقيت';

  @override
  String stepTimingSummary(Object wait, Object duration, Object grace) {
    return 'انتظار $waitث / مدة $durationث / مهلة $graceث';
  }

  @override
  String get stepCategoryAll => 'الكل';

  @override
  String get stepCategoryAction => 'إجراء';

  @override
  String get stepCategoryReminder => 'تذكير';

  @override
  String get stepCategoryDisarm => 'تسجيل وصول';

  @override
  String get modeTrackingHeader => 'تتبع GPS';

  @override
  String get modeTrackingEnabled => 'تسجيل GPS أثناء الجلسة';

  @override
  String get modeTrackingIntervalLabel => 'فاصل المعاينة';

  @override
  String get modeTrackingBufferSizeLabel => 'حجم المخزن المؤقت';

  @override
  String modeTrackingBufferSizeValue(Object count) {
    return '$count نقاط';
  }

  @override
  String get modeTrackingBatteryNote =>
      'تتبع GPS المتكرر يزيد من استهلاك البطارية.';

  @override
  String get stepConfigLogGpsLabel => 'تسجيل GPS';

  @override
  String get stepConfigLogGpsDefault => 'افتراضي';

  @override
  String get stepConfigLogGpsOn => 'تشغيل';

  @override
  String get stepConfigLogGpsOff => 'إيقاف';

  @override
  String get stepConfigLogGpsDefaultOn => 'افتراضي (تشغيل)';

  @override
  String get stepConfigLogGpsDefaultOff => 'افتراضي (إيقاف)';

  @override
  String get moreSettingsHeader => 'إعدادات إضافية';

  @override
  String moreSettingsHeaderCustomized(int count) {
    return 'إعدادات إضافية (تم تخصيص $count)';
  }

  @override
  String get stepTypePickerLabel => 'Step type';

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
  String get distressModesTitle => 'أوضاع الاستغاثة';

  @override
  String get distressModeInUseTitle => 'وضع الاستغاثة قيد الاستخدام';

  @override
  String distressModeInUseBody(Object modes) {
    return 'لا يزال وضع الاستغاثة هذا مرتبطًا بـ: $modes. قم بربط تلك الأوضاع بوضع استغاثة آخر قبل الحذف.';
  }

  @override
  String get distressModesEmpty => 'لا توجد أوضاع استغاثة بعد.';

  @override
  String get distressModesAdd => 'إضافة وضع استغاثة';

  @override
  String get distressModeEditorTitleCreate => 'وضع استغاثة جديد';

  @override
  String get distressModeEditorTitleEdit => 'تعديل وضع الاستغاثة';

  @override
  String get distressModeName => 'اسم وضع الاستغاثة';

  @override
  String get distressCountdown => 'جارٍ تشغيل وضع الاستغاثة...';

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
  String get settingsSectionDistressModes => 'أوضاع الاستغاثة';

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
  String get pinEntryBiometricReason => 'Authenticate to continue';

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
  String get stealthTimerDisplayNormal => 'Show full text';

  @override
  String get stealthTimerDisplaySmall => 'Show numbers only';

  @override
  String get stealthTimerDisplayNone => 'Hide timer';

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
  String get historyTitle => 'الجلسات السابقة';

  @override
  String get historyEmpty => 'لا توجد جلسات سابقة بعد.';

  @override
  String get historySearchHint => 'Search by mode name';

  @override
  String get historyFilterModeAll => 'All modes';

  @override
  String get historyFilterModeLabel => 'Mode';

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
  String get sessionSimSpeedBackgroundCap => 'Background-capped';

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
