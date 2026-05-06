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
  String homeContactsBannerFew(int count) {
    return 'تم تكوين $count جهة اتصال. نوصي بثلاث على الأقل.';
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
  String get modeFieldDistressMode => 'وضع الاستغاثة';

  @override
  String get modeFieldDistressModeDefault => 'استخدام الافتراضي';

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
  String get stepPreviewTitle => 'Step preview';

  @override
  String get stepPreviewMissingParams => 'Missing step or mode reference.';

  @override
  String get stepPreviewModeNotFound => 'Mode not found.';

  @override
  String get stepPreviewStepNotFound => 'Step not found in this mode.';

  @override
  String stepPreviewError(Object error) {
    return 'Preview failed: $error';
  }

  @override
  String get stepPreviewReplay => 'Replay';

  @override
  String get stepPreviewHoldButtonHint =>
      'Press and hold the button to feel the live response.';

  @override
  String get stepPreviewHoldButtonLabel => 'Hold';

  @override
  String get stepPreviewHoldButtonSemantic => 'Hold to preview';

  @override
  String get stepPreviewHoldButtonReleased =>
      'Released. The session would now enter the grace window.';

  @override
  String get stepPreviewFakeCallHint =>
      'The fake call screen will appear. Slide to answer or hold the red button to simulate distress.';

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
  String get stepConfigSmsAutoRecordAudio => 'Auto-record audio';

  @override
  String get stepConfigSmsAutoRecordVideo => 'Auto-record video';

  @override
  String get stepConfigSmsRecordDuration => 'Recording duration';

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
}
