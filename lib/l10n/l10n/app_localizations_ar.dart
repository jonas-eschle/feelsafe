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
  String get angelaDialogTitle => 'تم إدخال رمز PIN قديم';

  @override
  String get angelaDialogBody =>
      'يبدو أنك استخدمت رمز PIN قديمًا. هل أنت متأكد من رغبتك في المتابعة؟';

  @override
  String get angelaDialogCancel => 'إلغاء';

  @override
  String get angelaDialogConfirm => 'متابعة';

  @override
  String get commonCancel => 'إلغاء';

  @override
  String get commonOk => 'موافق';

  @override
  String get profileAngelaWarningTitle => 'تنبيه بشأن اسم \"Angela\"';

  @override
  String get profileAngelaWarningBody =>
      'يستخدم Guardian Angela كلمة \"Angela\" ككلمة مفتاحية للسلامة. قد يكون استخدامها كاسمك الشخصي مربكًا. هل تريد الحفظ على أي حال؟';

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
  String get pinSubmit => 'إرسال';

  @override
  String get homeTitle => 'Guardian Angela';

  @override
  String get homeStartSession => 'بدء الجلسة';

  @override
  String get homeStartConfirmTitle => 'هل تريد بدء جلسة؟';

  @override
  String get homeStartConfirmBody =>
      'تأكد من أن جهات الاتصال ورمز PIN مهيّأة. ستعمل الجلسة في المقدمة وسيوجّهك الوضع المختار خلال عمليات تسجيل الوصول.';

  @override
  String get homePermissionsMissingTitle => 'بعض الأذونات مفقودة';

  @override
  String get homePermissionsMissingBody =>
      'لم يتم منح الأذونات التالية. بدونها، ستفشل خطوات السلسلة المقابلة بصمت:';

  @override
  String get homePermissionsContinueAnyway => 'ابدأ على أي حال';

  @override
  String get homePermissionsNotification => 'الإشعارات';

  @override
  String get homePermissionsLocation => 'الموقع';

  @override
  String get homePermissionsCallPhone => 'المكالمات الهاتفية';

  @override
  String get homePermissionsSendSms => 'إرسال رسائل SMS';

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
  String get homeContactsBannerNone => 'لم يتم تكوين أي جهات اتصال للطوارئ.';

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
  String get sessionCheckIn => 'أنا بأمان';

  @override
  String get sessionDisarmTriggerTitle => 'تم تشغيل محفّز إنهاء التأهب';

  @override
  String get sessionDisarmTriggerBody =>
      'تم تشغيل محفّز إنهاء التأهب. هل تريد إنهاء الجلسة؟';

  @override
  String get sessionDisarmTriggerConfirm => 'إنهاء الجلسة';

  @override
  String get sessionDisarmTriggerCancel => 'متابعة';

  @override
  String get wrongPinAngelaTitle => 'رمز PIN قديم من Angela';

  @override
  String get wrongPinAngelaBody =>
      'هل أنت متأكد من رغبتك في المتابعة برمز PIN القديم هذا؟';

  @override
  String get wrongPinAngelaConfirm => 'موافق';

  @override
  String get wrongPinAngelaCancel => 'إلغاء';

  @override
  String get sessionStepCountdownTitle => 'تحذير';

  @override
  String get sessionStepCountdownBody =>
      'سيبدأ التصعيد التالي عند انتهاء العد التنازلي. اسحب «أنا بأمان» في الأسفل لإنهاء التأهب.';

  @override
  String get sessionStepDisguisedDefaultTitle => 'تذكير';

  @override
  String get sessionStepDisguisedDefaultBody =>
      'اضغط على «أنا بأمان» لتأكيد سلامتك.';

  @override
  String get sessionStepSmsStatus => 'جارٍ إرسال الرسالة إلى جهات الاتصال…';

  @override
  String get sessionStepSmsDelivered => 'تم التسليم';

  @override
  String get sessionStepSmsSent => 'تم الإرسال';

  @override
  String get sessionStepSmsQueued => 'في قائمة الانتظار';

  @override
  String get sessionStepSmsFailed => 'فشل';

  @override
  String get sessionStepPhoneCallStatus => 'جارٍ الاتصال بجهة اتصال الطوارئ…';

  @override
  String get sessionStepPhoneCallCancel => 'إلغاء المكالمة';

  @override
  String get sessionStepLoudAlarmTitle => 'الإنذار يعمل';

  @override
  String get sessionStepLoudAlarmBody => 'الإنذار يصدر صوتًا لجذب الانتباه.';

  @override
  String get sessionStepLoudAlarmFlashWarning =>
      'تحذير للحساسين للضوء: الشاشة تومض.';

  @override
  String get sessionStepCallEmergencyStatus => 'جارٍ الاتصال بخدمات الطوارئ…';

  @override
  String sessionStepCallEmergencyNumber(Object number) {
    return 'الرقم: $number';
  }

  @override
  String sessionStepHardwareButtonRepeat(
    Object button,
    Object count,
    Object windowMs,
  ) {
    return 'اضغط على $button $count مرات خلال $windowMs مللي ثانية';
  }

  @override
  String sessionStepHardwareButtonLong(Object button, Object seconds) {
    return 'استمر في الضغط على $button لمدة $seconds ثانية';
  }

  @override
  String get sessionStepHardwareButtonVolumeUp => 'رفع الصوت';

  @override
  String get sessionStepHardwareButtonVolumeDown => 'خفض الصوت';

  @override
  String get sessionStepHardwareButtonPower => 'زر التشغيل';

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
  String get fakeCallSlideToAnswer => 'اسحب للرد';

  @override
  String get fakeCallUnknownCaller => 'غير معروف';

  @override
  String get fakeCallIncomingWhatsapp => 'مكالمة صوتية عبر WhatsApp';

  @override
  String get fakeCallIncomingTelegram => 'مكالمة صوتية عبر Telegram';

  @override
  String get fakeCallIncomingSignal => 'مكالمة صوتية عبر Signal';

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
  String get contactLanguageDefault => 'افتراضي (استخدام لغة التطبيق)';

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
  String get contactFormIosSmsWarning =>
      'On iOS, SMS opens the Messages app. You must tap Send manually.';

  @override
  String get modesTitle => 'الأوضاع';

  @override
  String get modesEmpty => 'لا توجد أوضاع بعد. اضغط على إضافة لإنشاء وضع.';

  @override
  String get modesAdd => 'إضافة وضع';

  @override
  String get modesNewPickerTitle => 'ابدأ من';

  @override
  String get modesNewPickerBlank => 'وضع فارغ';

  @override
  String get modesNewPickerBlankSubtitle => 'ابدأ بسلسلة فارغة';

  @override
  String modesNewPickerFromTemplate(String name) {
    return 'من $name';
  }

  @override
  String get modesNewPickerFromTemplateSubtitle =>
      'نسخ سلسلة هذا الوضع ومحفّزاته';

  @override
  String modesNewPickerCopyName(String name) {
    return 'نسخة من $name';
  }

  @override
  String get modesNewPickerBuiltinBadge => 'مدمج';

  @override
  String get modeEditorTitleCreate => 'وضع جديد';

  @override
  String get modeEditorTitleEdit => 'تعديل الوضع';

  @override
  String get modeFieldName => 'الاسم';

  @override
  String get modeFieldDistressMode => 'وضع الاستغاثة';

  @override
  String get modeFieldDistressModeDefault => 'استخدام الافتراضي';

  @override
  String get modeChainHeader => 'سلسلة';

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
  String get stepPickerMore => 'خيارات أخرى...';

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
  String get stepTypePickerLabel => 'نوع الخطوة';

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
  String get stepFieldRetryCount => 'عدد محاولات الإعادة';

  @override
  String get stepFieldRandomize => 'تشويش التوقيت';

  @override
  String get stepFieldRandomizeToggle => 'توقيت عشوائي (±20%)';

  @override
  String get stepFieldWaitTooltip => 'كم تنتظر قبل بدء هذه الخطوة.';

  @override
  String get stepFieldDurationTooltip =>
      'كم تستغرق الخطوة قبل بدء نافذة المهلة.';

  @override
  String get stepFieldGraceTooltip =>
      'الوقت بعد المرحلة النشطة لتأكيد السلامة قبل الخطوة التالية.';

  @override
  String get stepFieldRetryCountTooltip =>
      'كم مرة تكرر هذه الخطوة قبل التصعيد.';

  @override
  String get stepFieldReminderIntervalTooltip =>
      'عدد مرات تشغيل التذكير المقنّع أثناء انتظار التأكيد.';

  @override
  String get stepFieldReminderGraceTooltip =>
      'كم من الوقت يملك المستخدم لتأكيد السلامة بعد ظهور التذكير.';

  @override
  String get stepPreview => 'معاينة في المحاكاة';

  @override
  String stepPreviewFired(Object description) {
    return 'تم تشغيل المعاينة: $description';
  }

  @override
  String get stepPreviewTitle => 'معاينة الخطوة';

  @override
  String get stepPreviewMissingParams => 'مرجع الخطوة أو الوضع مفقود.';

  @override
  String get stepPreviewModeNotFound => 'لم يُعثر على الوضع.';

  @override
  String get stepPreviewStepNotFound => 'لم يُعثر على الخطوة في هذا الوضع.';

  @override
  String stepPreviewError(Object error) {
    return 'فشلت المعاينة: $error';
  }

  @override
  String get stepPreviewReplay => 'إعادة التشغيل';

  @override
  String get stepPreviewHoldButtonHint =>
      'اضغط مع الاستمرار على الزر لتشعر بالاستجابة الحية.';

  @override
  String get stepPreviewHoldButtonLabel => 'استمر بالضغط';

  @override
  String get stepPreviewHoldButtonSemantic => 'اضغط مع الاستمرار للمعاينة';

  @override
  String get stepPreviewHoldButtonReleased =>
      'تم الإفلات. ستدخل الجلسة الآن نافذة المهلة.';

  @override
  String get stepPreviewFakeCallHint =>
      'ستظهر شاشة المكالمة الوهمية. اسحب للرد أو اضغط مع الاستمرار على الزر الأحمر لمحاكاة الاستغاثة.';

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
  String get stepConfigSmsAutoRecordAudio => 'تسجيل الصوت تلقائيًا';

  @override
  String get stepConfigSmsAutoRecordVideo => 'تسجيل الفيديو تلقائيًا';

  @override
  String get stepConfigSmsRecordDuration => 'مدة التسجيل';

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
  String get stepConfigHardwarePressWindow => 'نافذة الضغط (مللي ث)';

  @override
  String get stepConfigHardwareLongDuration => 'مدة الضغط الطويل (ث)';

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
  String get settingsLanguagePicker => 'اللغة';

  @override
  String get settingsEmergencyNumberLabel => 'رقم الطوارئ';

  @override
  String get settingsRedoOnboardingActiveSessionTooltip =>
      'Cannot redo onboarding during an active session';

  @override
  String get settingsEmergencyNumberCountryPickerTitle =>
      'Choose emergency number';

  @override
  String get settingsEmergencyNumberHint => 'مثلاً 112';

  @override
  String get settingsEmergencyNumberSave => 'حفظ';

  @override
  String get settingsRedoOnboarding => 'إعادة التهيئة';

  @override
  String get settingsRedoOnboardingConfirm => 'إعادة التهيئة من البداية؟';

  @override
  String get settingsRedoOnboardingBody => 'سيتم الاحتفاظ بإعداداتك الحالية.';

  @override
  String get settingsRedoOnboardingProceed => 'إعادة البدء';

  @override
  String get settingsAlarmGradualVolume => 'تصاعد تدريجي لصوت الإنذار';

  @override
  String settingsAlarmGradualVolumeDuration(int seconds) {
    return 'مدة التصاعد: $seconds ث';
  }

  @override
  String get securityTitle => 'الأمان';

  @override
  String get securityAppPin => 'رمز PIN للتطبيق';

  @override
  String get securitySessionEndPin => 'رمز PIN لإنهاء الجلسة';

  @override
  String get securityDuressPin => 'رمز PIN للإكراه';

  @override
  String get securityAppPinBiometric =>
      'استخدام القياسات الحيوية لرمز PIN التطبيق';

  @override
  String get securitySessionEndPinBiometric =>
      'استخدام القياسات الحيوية لرمز PIN إنهاء الجلسة';

  @override
  String get securityDistressCancelBiometric =>
      'استخدام القياسات الحيوية لإلغاء الاستغاثة';

  @override
  String get securityDuressTest => 'اختبار رمز PIN الإكراه';

  @override
  String get securityDuressTestSubtitle => 'تحقق من أن رمز PIN الإكراه يعمل.';

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
  String get pinEntryBiometricReason => 'تحقق من هويتك للمتابعة';

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
  String get stealthTimerDisplayNormal => 'عرض النص الكامل';

  @override
  String get stealthTimerDisplaySmall => 'عرض الأرقام فقط';

  @override
  String get stealthTimerDisplayNone => 'إخفاء المؤقت';

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
  String get backupSelectionHeader => 'تضمين في التصدير';

  @override
  String get backupToggleSettings => 'الإعدادات';

  @override
  String get backupToggleSettingsSubtitle =>
      'مضمّنة دائمًا حتى يمكن استعادة النسخة الاحتياطية.';

  @override
  String get backupToggleContacts => 'جهات اتصال الطوارئ';

  @override
  String get backupToggleModes => 'الأوضاع';

  @override
  String get backupToggleDistressModes => 'أوضاع الاستغاثة';

  @override
  String get backupToggleTemplates => 'قوالب التذكير';

  @override
  String get backupToggleSessionLogs => 'سجل الجلسات';

  @override
  String get backupToggleRecordings => 'التسجيلات الصوتية';

  @override
  String get historyTitle => 'الجلسات السابقة';

  @override
  String get historyEmpty => 'لا توجد جلسات سابقة بعد.';

  @override
  String get historyTabReal => 'حقيقي';

  @override
  String get historyTabSimulated => 'محاكاة';

  @override
  String get historySearchHint => 'البحث باسم الوضع';

  @override
  String get historyFilterModeAll => 'جميع الأوضاع';

  @override
  String get historyFilterModeLabel => 'الوضع';

  @override
  String get historyDateRangePick => 'النطاق الزمني';

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
  String aboutVersion(Object version) {
    return 'الإصدار';
  }

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
    return 'جارٍ الاتصال بـ $number';
  }

  @override
  String get emergencyConfirmSubtitle => 'استمر بالضغط على زر الإلغاء للإلغاء.';

  @override
  String emergencyConfirmCountdown(Object seconds) {
    return 'الاتصال خلال $seconds ثانية';
  }

  @override
  String get emergencyConfirmCancel => 'إلغاء';

  @override
  String get stealthCalendarUpcoming => 'القادم';

  @override
  String get stealthCalendarUpcomingEvent => 'اجتماع';

  @override
  String stealthCalendarUntilEvent(Object minutes) {
    return 'خلال $minutes دقيقة';
  }

  @override
  String get stealthCalendarToday => 'اليوم';

  @override
  String get stealthCalendarEvent1 => 'قهوة مع Alex';

  @override
  String get stealthCalendarEvent2 => 'اجتماع يومي';

  @override
  String get stealthCalendarEvent3 => 'غداء';

  @override
  String get stealthCalendarEvent4 => 'تمرين رياضي';

  @override
  String get stealthCalendarEvent5 => 'عشاء مع Sam';

  @override
  String get stealthDisarmGestureHint => 'اسحب للأعلى للإنهاء';

  @override
  String get stealthMusicTrackTitle => 'مقطع بدون عنوان';

  @override
  String get stealthMusicArtist => 'فنان مجهول';

  @override
  String get stealthMusicAlbum => 'ألبوم مجهول';

  @override
  String get stealthMusicNowPlaying => 'قيد التشغيل الآن';

  @override
  String get stealthMusicSwipeHint => 'اسحب لإنهاء التأهب';

  @override
  String get stealthMusicPrevious => 'السابق';

  @override
  String get stealthMusicPause => 'إيقاف مؤقت';

  @override
  String get stealthMusicNext => 'التالي';

  @override
  String get stealthPodcastShowName => 'بودكاست';

  @override
  String get stealthPodcastEpisodeTitle => 'حلقة';

  @override
  String get stealthPodcastEpisodesHeader => 'الحلقات';

  @override
  String get stealthPodcastSpeedLabel => '1x';

  @override
  String get stealthPodcastEpisode1 => 'الحلقة 1';

  @override
  String get stealthPodcastEpisode2 => 'الحلقة 2';

  @override
  String get stealthPodcastEpisode3 => 'الحلقة 3';

  @override
  String get stealthPodcastEpisode4 => 'الحلقة 4';

  @override
  String get stealthPresetPodcast => 'بودكاست';

  @override
  String get stealthPresetNone => 'بدون';

  @override
  String get stealthLockTaskLabel => 'Pin app during session';

  @override
  String get stealthLockTaskSubtitle =>
      'Prevents leaving the app while a session is running. On Android this engages screen-pinning; on other platforms this is a no-op.';

  @override
  String get sessionSimSpeedLabel => 'السرعة';

  @override
  String sessionSimSpeedValue(Object value) {
    return '${value}x';
  }

  @override
  String get sessionSimSpeedBackgroundCap => 'محدودة بـ 60× في الخلفية';

  @override
  String get sessionSimAdvancedLabel => 'متقدم';

  @override
  String get sessionSimTriggerPanic => 'تشغيل الذعر';

  @override
  String get sessionSimTriggerArrival => 'تشغيل الوصول';

  @override
  String get sessionSimTriggerBattery => 'تشغيل بطارية منخفضة';

  @override
  String get simulateGpsArrival => 'محاكاة الوصول';

  @override
  String get simulateLowBattery => 'محاكاة بطارية منخفضة';

  @override
  String get launchGateTitle => 'فتح Guardian Angela';

  @override
  String get launchGateSubtitle => 'أدخل رمز PIN أو استخدم القياسات الحيوية.';

  @override
  String get launchGateWrong => 'رمز PIN غير صحيح';

  @override
  String get launchGateBiometricReason => 'فتح Guardian Angela';

  @override
  String get launchGateUseBiometric => 'استخدام القياسات الحيوية';

  @override
  String get audioRunningLatePhrase =>
      'مرحبًا، أنا متأخر. سأعاود الاتصال بك قريبًا.';

  @override
  String smsDefaultTemplate(Object name, Object location, Object time) {
    return '$name قد يحتاج إلى المساعدة. الموقع: $location. الوقت: $time.';
  }

  @override
  String smsDefaultPreCallTemplate(Object name) {
    return '$name يحاول الاتصال بك. يرجى توقع مكالمة.';
  }

  @override
  String simLoudAlarm(Object tail) {
    return '[SIM] إنذار مرتفع + $tail';
  }

  @override
  String get simLoudAlarmTailFlash => 'وميض';

  @override
  String get simLoudAlarmTailVibrate => 'اهتزاز';

  @override
  String simSmsContact(Object channel, int count) {
    return '[SIM] سيُرسل $channel إلى $count جهات اتصال';
  }

  @override
  String simFakeCallRing(Object caller) {
    return '[SIM] مكالمة واردة من $caller';
  }

  @override
  String simCountdownWarning(int seconds) {
    return '[SIM] تحذير العد التنازلي $secondsث';
  }

  @override
  String simPhoneCall(Object name) {
    return '[SIM] سيتصل بـ $name';
  }

  @override
  String get simNoContactToCall => '[SIM] لا توجد جهة اتصال للاتصال بها';

  @override
  String simCallEmergency(Object number) {
    return '[SIM] سيطلب $number';
  }

  @override
  String get simHardwareButton => '[SIM] مُشغّل الأجهزة جاهز';

  @override
  String get simHoldButton => '[SIM] في انتظار الضغط المستمر';

  @override
  String simDisguisedReminder(Object title) {
    return '[SIM] سيعرض \"$title\"';
  }

  @override
  String get simDisguisedReminderEmpty => '[SIM] لا يوجد قالب تذكير متاح';

  @override
  String get simGpsArrivalTrigger => '[SIM] تم تشغيل مُشغّل وصول GPS';

  @override
  String get simLowBatteryAlert => '[SIM] تم تشغيل تنبيه انخفاض البطارية';

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
  String get gpsLoggingFormatAddress => 'Plus Code';

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
  String get pastEventsSearch => 'Search by mode name';

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
  String get modesDistressInUse =>
      'This distress mode is in use by another mode.';

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
}
