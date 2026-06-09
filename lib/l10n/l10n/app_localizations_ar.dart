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
  String get commonDelete => 'حذف';

  @override
  String get commonEdit => 'تعديل';

  @override
  String get commonGotIt => 'حسنًا';

  @override
  String get commonClose => 'إغلاق';

  @override
  String get commonConfirm => 'تأكيد';

  @override
  String get commonBack => 'رجوع';

  @override
  String get pinSubmit => 'إرسال';

  @override
  String get homeTitle => 'Guardian Angela';

  @override
  String get homeStartSession => 'بدء الجلسة';

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
  String get homeNoModes => 'لا توجد أوضاع بعد. اضغط على الأوضاع لإضافة واحد.';

  @override
  String get homeContactsBannerNone => 'لم يتم تكوين أي جهات اتصال للطوارئ.';

  @override
  String get homeMenuSettings => 'الإعدادات';

  @override
  String get homeMenuContacts => 'جهات الاتصال';

  @override
  String get homeMenuHistory => 'الجلسات السابقة';

  @override
  String get onboardingProfileTitle => 'الملف الشخصي وأول جهة اتصال';

  @override
  String get onboardingPermissionsTitle => 'الأذونات';

  @override
  String get onboardingNext => 'التالي';

  @override
  String get onboardingSkip => 'تخطي';

  @override
  String get onboardingUseSimNumber => 'استخدام رقم شريحة SIM الخاص بي';

  @override
  String onboardingUseSimNumberHint(Object number) {
    return '$number';
  }

  @override
  String get onboardingUseSimNumberUnsupported => 'غير متاح على نظام iOS';

  @override
  String get onboardingUseSimNumberUnavailable => 'تعذّرت قراءة الرقم';

  @override
  String get onboardingUseSimNumberPermissionDenied => 'تم رفض الإذن';

  @override
  String get sessionTitle => 'الجلسة';

  @override
  String get sessionDisarm => 'أنا بأمان';

  @override
  String get sessionDisarmStealth => 'لا حاجة لأنجيلا';

  @override
  String get homeChainSummaryTitle => 'ملخص السلسلة';

  @override
  String get homeChainSummaryEmpty =>
      'لا توجد خطوات في هذا الوضع بعد — اضغطي على الوضع للتعديل.';

  @override
  String homeChainSummaryTimingTitle(Object name) {
    return 'الخطوة: $name';
  }

  @override
  String homeChainSummaryWait(Object seconds) {
    return 'الانتظار: $seconds ث';
  }

  @override
  String homeChainSummaryDuration(Object seconds) {
    return 'نشطة: $seconds ث';
  }

  @override
  String homeChainSummaryGrace(Object seconds) {
    return 'فترة السماح: $seconds ث';
  }

  @override
  String homeChainSummaryRetry(Object count) {
    return 'المحاولات: $count';
  }

  @override
  String homeChainSummaryNextStep(Object name) {
    return 'الخطوة التالية: $name';
  }

  @override
  String get homeChainSummaryNextStepNone => 'الخطوة التالية: نهاية السلسلة';

  @override
  String get homeChainSummaryClose => 'إغلاق';

  @override
  String get chainStepNameHoldButton => 'اضغطي مطوّلاً لتبقي بأمان';

  @override
  String get chainStepNameDisguisedReminder => 'تذكير مموَّه';

  @override
  String get chainStepNameCountdownWarning => 'تحذير بالعد التنازلي';

  @override
  String get chainStepNameFakeCall => 'مكالمة وهمية';

  @override
  String get chainStepNameSmsContact => 'SMS إلى جهة الاتصال';

  @override
  String get chainStepNamePhoneCallContact => 'اتصال بجهة الاتصال';

  @override
  String get chainStepNameLoudAlarm => 'إنذار صاخب';

  @override
  String get chainStepNameCallEmergency => 'اتصال طوارئ';

  @override
  String get chainStepNameHardwareButton => 'زر الجهاز';

  @override
  String get homeChecklistTitle => 'إعداد الأمان';

  @override
  String get homeChecklistDismissTooltip => 'إخفاء القائمة';

  @override
  String get homeChecklistExpandTooltip => 'عرض القائمة';

  @override
  String get homeChecklistCollapseTooltip => 'طيّ القائمة';

  @override
  String homeChecklistProgress(Object done, Object total) {
    return '$done من $total مكتمل';
  }

  @override
  String get homeChecklistAllDoneBanner => 'كلّ شيء جاهز — أنتِ في حماية!';

  @override
  String get homeChecklistInfoTooltip => 'لماذا هذا مهم';

  @override
  String get homeChecklistGotIt => 'فهمت';

  @override
  String get homeChecklistGoThere => 'اذهبي إلى هناك';

  @override
  String get homeChecklistItem1Title => 'أضيفي جهة اتصال للطوارئ';

  @override
  String get homeChecklistItem2Title => 'حدّدي PIN لإنهاء الجلسة';

  @override
  String get homeChecklistItem3Title => 'اضبطي وضع التخفّي';

  @override
  String get homeChecklistItem4Title => 'جرّبي محاكاة';

  @override
  String get homeChecklistItem5Title => 'خصّصي وضع أمان';

  @override
  String get homeChecklistItem6Title => 'امنحي الأذونات المطلوبة';

  @override
  String get checklistInfo1Body =>
      'جهات اتصال الطوارئ هم الأشخاص الذين يُرسل لهم Guardian Angela رسائل ويتصل بهم عندما لا تتمكّنين من تأكيد سلامتك. بدون جهة اتصال واحدة على الأقل، لا تجد السلسلة جهةً لتصعيد التنبيه إليها.';

  @override
  String get checklistInfo2Body =>
      'يمنع PIN إنهاء الجلسة المهاجم من إنهاء جلسة نشطة بهدوء. يمكنه المحاولة، لكن خمس إدخالات خاطئة تُطلق سلسلة الاستغاثة بصمت.';

  @override
  String get checklistInfo3Body =>
      'يُموّه وضع التخفّي الجلسة النشطة كشيء عادي على شاشتك — مشغّل موسيقى، مؤقّت متوقّف، شاشة قفل فارغة. استخدميه عندما لا يجب أن يرى شخص قريب أنك تشغّلين تطبيق سلامة.';

  @override
  String get checklistInfo4Body =>
      'تُشغّل المحاكاة وضع الأمان من البداية إلى النهاية دون إرسال SMS حقيقية أو إجراء مكالمات حقيقية أو تشغيل الإنذار الصاخب. استخدميها لتتعلّمي التوقيتات قبل أن تحتاجي إليها فعلاً.';

  @override
  String get checklistInfo5Body =>
      'تُتيح الأوضاع المخصّصة ضبط الخطوات والتوقيتات والمحفّزات لموقف بعينه — العودة إلى المنزل، أول موعد، نوبة ليلية. الوضعان المضمَّنان نقطة بداية، لا الوجهة النهائية.';

  @override
  String get checklistInfo6Body =>
      'بدون إذن الإشعارات لا يستطيع Guardian Angela الحفاظ على حالته الدائمة في المقدّمة، ولا تسليم التذكيرات المموّهة، ولا تحذيرك من أن السلسلة على وشك التصعيد.';

  @override
  String get checklistTutorial3Body =>
      'افتحي الإعدادات الافتراضية للتخفّي وفعّلي «تفعيل وضع التخفّي». من هناك يمكنك اختيار علامة موسيقى مزيّفة أو إخفاء مؤقّت الجلسة أو تمويه أيقونة الشاشة الرئيسية.';

  @override
  String get checklistTutorial4Body =>
      'على الشاشة الرئيسية، بعد اختيار وضع، اضغطي على زر «محاكاة» المُحاط بإطار. تعمل الجلسة بإطار برتقالي وشارة [SIM] — لا يخرج شيء من هاتفك.';

  @override
  String get checklistTutorial5Body =>
      'افتحي شاشة الأوضاع وعدّلي وضعًا مضمَّنًا (المشي / الموعد) أو أنشئي وضعًا جديدًا من الصفر. اضبطي السلسلة، أضيفي مكالمة وهمية، حدّدي توقيتاتك.';

  @override
  String get sessionHoldPrompt => 'اضغط مع الاستمرار للبقاء بأمان';

  @override
  String sessionStepLabel(Object index, Object total) {
    return 'الخطوة $index من $total';
  }

  @override
  String sessionMissCount(Object count) {
    return 'فائت: $count';
  }

  @override
  String get sessionPausedBadge => 'متوقف مؤقتًا';

  @override
  String get sessionPausedIncomingCall => 'متوقف مؤقتًا — مكالمة واردة';

  @override
  String get sessionPhaseEnded => 'انتهت الجلسة';

  @override
  String get sessionSimulationBanner => 'محاكاة';

  @override
  String get sessionCheckIn => 'أنا بأمان';

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
  String get sessionReminderEarlyCheckInHint => 'اضغط للتسجيل الآن';

  @override
  String get sessionReminderDefaultButton => 'موافق';

  @override
  String get sessionReminderTapWordHint => 'اضغط للمتابعة';

  @override
  String get sessionReminderDecoyWords =>
      'لاحقًا,تخطّي,تم,فتح,عرض,حسنًا,التالي,المزيد,تأجيل,إغلاق';

  @override
  String get sessionReminderSwipeLabel => 'اسحب للإغلاق';

  @override
  String get sessionReminderDismissLabel => 'إغلاق';

  @override
  String get sessionStepSmsStatus => 'جارٍ إرسال الرسالة إلى جهات الاتصال…';

  @override
  String get sessionStepPhoneCallStatus => 'جارٍ الاتصال بجهة اتصال الطوارئ…';

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
  String get sessionStealthNowPlaying => 'قيد التشغيل الآن';

  @override
  String get sessionServiceTitle => 'Guardian Angela نشط';

  @override
  String get sessionServiceBody => 'جلسة الأمان الخاصة بك قيد التشغيل.';

  @override
  String get sessionServiceStealthBody => 'قيد التشغيل';

  @override
  String get sessionStealthTrackTitle => 'مقطع بدون عنوان';

  @override
  String get sessionStealthArtistName => 'فنان غير معروف';

  @override
  String get sessionStealthAlbumArtLabel => 'غلاف الألبوم';

  @override
  String get sessionStealthPlay => 'تشغيل';

  @override
  String get sessionStealthPause => 'إيقاف مؤقت';

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
  String get fakeCallBrandAndroid => 'الهاتف';

  @override
  String get fakeCallBrandIos => 'الهاتف';

  @override
  String get fakeCallBrandMinimal => 'مكالمة';

  @override
  String get fakeCallDeclineSafeLabel => 'رفض (أنا بأمان)';

  @override
  String get fakeCallDeclineUnsafeLabel => 'رفض (البقاء في حالة تأهب)';

  @override
  String get fakeCallHoldForDistress => 'اضغطي مطوّلاً 5 ثوانٍ للاستغاثة';

  @override
  String fakeCallVoicePrompt(String name) {
    return 'رسالة صوتية: $name';
  }

  @override
  String fakeCallVibrationLabel(String pattern) {
    return 'الاهتزاز: $pattern';
  }

  @override
  String get fakeCallVibrationPatternDefault => 'افتراضي';

  @override
  String get fakeCallSlideToAnswerHint => 'اسحبي للرد';

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
  String get contactFormIosSmsWarning =>
      'على نظام iOS، تفتح الرسائل النصية تطبيق الرسائل. عليكِ الضغط على «إرسال» يدويًا.';

  @override
  String get modesTitle => 'الأوضاع';

  @override
  String get modesEmpty => 'لا توجد أوضاع بعد. اضغط على إضافة لإنشاء وضع.';

  @override
  String get modesAdd => 'إضافة وضع';

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
  String get modeEditorTitleCreate => 'وضع جديد';

  @override
  String get modeEditorTitleEdit => 'تعديل الوضع';

  @override
  String get modeFieldName => 'الاسم';

  @override
  String get modeChainHeader => 'سلسلة';

  @override
  String get modeChainAddStep => 'إضافة خطوة';

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
  String stepTimingSummary(Object wait, Object duration, Object grace) {
    return 'انتظار $waitث / مدة $durationث / مهلة $graceث';
  }

  @override
  String get stepConfigTimingHeader => 'التوقيت';

  @override
  String get stepConfigEventHeader => 'إعدادات الحدث';

  @override
  String get stepConfigAdvancedHeader => 'إعادة المحاولة والإعدادات المتقدمة';

  @override
  String get stepFieldWait => 'الانتظار قبل التشغيل (بالثواني)';

  @override
  String get stepFieldDuration => 'مدة النشاط (بالثواني)';

  @override
  String get stepFieldGrace => 'فترة السماح (بالثواني)';

  @override
  String get stepFieldRetryCount => 'المحاولات';

  @override
  String get stepFieldRandomize => 'عشوائية التوقيت (±20%)';

  @override
  String get stepDuplicate => 'تكرار الخطوة';

  @override
  String get stepResetDefaults => 'إعادة التعيين إلى الافتراضيات';

  @override
  String get smsContactRecipientsHeader => 'جهات الاتصال المرسل إليها';

  @override
  String get smsContactSummaryAll => 'إلى: جميع جهات الاتصال المفعّلة';

  @override
  String get smsContactSummaryNone => 'لم يتم تحديد أي مستلِم';

  @override
  String smsContactSummaryTo(Object names) {
    return 'إلى: $names';
  }

  @override
  String get smsContactChannelDisabledTooltip =>
      'غير مفعّل لجهة الاتصال هذه — عدّل جهة الاتصال لإضافة هذه القناة.';

  @override
  String get smsContactEmptyAddPrompt =>
      'لا توجد جهات اتصال بعد — أضف واحدة في جهات الاتصال';

  @override
  String get safetyOptionsHeader => 'خيارات الأمان';

  @override
  String get safetyOptionsDistressModeTitle => 'وضع الاستغاثة';

  @override
  String get safetyOptionsDistressModeUseDefault =>
      'استخدام وضع الاستغاثة الافتراضي';

  @override
  String safetyOptionsDistressModeUseDefaultNamed(Object name) {
    return 'استخدام الافتراضي ($name)';
  }

  @override
  String get safetyOptionsDistressModeInfo =>
      'عند تشغيل مُحفِّز استغاثة (رمز PIN تحت الإكراه أو الذعر عبر الزر المادي أو تجاوز عدد محاولات PIN الخاطئة)، تُستبدل سلسلة هذا الوضع بسلسلة وضع الاستغاثة المُختار. اترك الإعداد على الافتراضي لاستخدام وضع الاستغاثة العام للتطبيق.';

  @override
  String get safetyOptionsManageDistressModes => 'إدارة أوضاع الاستغاثة';

  @override
  String get safetyOptionsDistressTriggersTitle => 'مُحفِّزات الاستغاثة';

  @override
  String get safetyOptionsDistressTriggersInfo =>
      'تُشغِّل مُحفِّزات الاستغاثة سلسلة الاستغاثة فورًا بالتوازي مع السلسلة الرئيسية. يراقب زر الذعر المادي زرًا فعليًا وفق نمط الضغط المُهيَّأ.';

  @override
  String get safetyOptionsDistressTriggersEmpty => 'لا توجد مُحفِّزات استغاثة';

  @override
  String get safetyOptionsAddHardwarePanic => 'إضافة زر ذعر مادي';

  @override
  String safetyOptionsTriggerHardwareRepeat(Object button, Object count) {
    return '$button: ضغط $count×';
  }

  @override
  String safetyOptionsTriggerHardwareLong(Object button, Object seconds) {
    return '$button: استمرار الضغط $seconds ث';
  }

  @override
  String get safetyOptionsButtonVolumeUp => 'رفع الصوت';

  @override
  String get safetyOptionsButtonVolumeDown => 'خفض الصوت';

  @override
  String get safetyOptionsTriggerPattern => 'نمط الضغط';

  @override
  String get safetyOptionsPatternRepeat => 'ضغط متكرر';

  @override
  String get safetyOptionsPatternLong => 'ضغط مطوّل';

  @override
  String get safetyOptionsTriggerButton => 'الزر';

  @override
  String get safetyOptionsTriggerPressCount => 'عدد الضغطات';

  @override
  String get safetyOptionsTriggerHoldDuration => 'مدة الاستمرار بالضغط (ثوانٍ)';

  @override
  String get safetyOptionsDisarmTriggersTitle => 'مُحفِّزات الإلغاء';

  @override
  String get safetyOptionsGpsArrivalTitle => 'الإلغاء عند الوصول عبر GPS';

  @override
  String get safetyOptionsGpsArrivalInfo =>
      'تنتهي الجلسة تلقائيًا عند وصولك ضمن النطاق المُهيَّأ من وجهتك. تحدِّد الوجهة عند بدء الجلسة.';

  @override
  String get safetyOptionsGpsArrivalRadius => 'نطاق الوصول';

  @override
  String safetyOptionsRadiusMeters(Object meters) {
    return '$meters م';
  }

  @override
  String safetyOptionsRadiusKilometers(Object km) {
    return '$km كم';
  }

  @override
  String get safetyOptionsDestinationSource => 'الوجهة';

  @override
  String get safetyOptionsDestinationPrompt => 'تحديد الوجهة عند بدء الجلسة';

  @override
  String get safetyOptionsDestinationFixed => 'إحداثيات ثابتة';

  @override
  String get safetyOptionsLatitude => 'خط العرض';

  @override
  String get safetyOptionsLongitude => 'خط الطول';

  @override
  String get safetyOptionsTimerDisarmTitle => 'الإلغاء بالمؤقّت';

  @override
  String get safetyOptionsTimerDisarmInfo =>
      'تنتهي الجلسة تلقائيًا بعد الوقت المُهيَّأ، بغضّ النظر عن بدء التصعيد من عدمه.';

  @override
  String get safetyOptionsTimerDuration => 'المدة';

  @override
  String safetyOptionsDurationMinutes(Object minutes) {
    return '$minutes د';
  }

  @override
  String safetyOptionsDurationHoursMinutes(Object hours, Object minutes) {
    return '$hours س $minutes د';
  }

  @override
  String get safetyOptionsGpsLoggingTitle => 'تسجيل GPS';

  @override
  String get safetyOptionsGpsLoggingInfo =>
      'اختر ما إذا كان هذا الوضع يسجّل موقعك أثناء الجلسة. يستخدم «التوريث» إعدادات GPS العامة؛ ويتجاوزها «مخصّص» لهذا الوضع؛ ويعطّل «إيقاف» التسجيل تمامًا.';

  @override
  String get safetyOptionsStealthTitle => 'التخفّي';

  @override
  String get safetyOptionsStealthInfo =>
      'اختر ما إذا كان هذا الوضع يموّه التطبيق أثناء الجلسة. يستخدم «التوريث» إعدادات التخفّي العامة؛ ويتجاوزها «مخصّص» لهذا الوضع؛ ويعطّل «إيقاف» التخفّي تمامًا.';

  @override
  String get safetyOptionsTriStateInherit => 'توريث';

  @override
  String get safetyOptionsTriStateCustom => 'مخصّص';

  @override
  String get safetyOptionsTriStateOff => 'إيقاف';

  @override
  String get safetyOptionsLocalTemplatesTitle => 'القوالب المحلية';

  @override
  String get safetyOptionsLocalTemplatesInfo =>
      'تُضاف القوالب المحلية إلى مجموعة قوالب التذكير العامة لهذا الوضع فقط. استخدمها لخطوات التذكير المُموَّه الخاصة بهذا الوضع.';

  @override
  String get safetyOptionsLocalTemplatesEmpty => 'لا توجد قوالب محلية';

  @override
  String get safetyOptionsAddTemplate => 'إضافة قالب';

  @override
  String get safetyOptionsManageTemplates => 'إدارة قوالب التذكير';

  @override
  String get safetyOptionsEventDefaultsTitle => 'الإعدادات الافتراضية للأحداث';

  @override
  String get safetyOptionsEventDefaultsInfo =>
      'تحدِّد الإعدادات الافتراضية للأحداث التهيئة الأولية لكل نوع خطوة. يستخدم «التوريث» إعداداتك الافتراضية العامة؛ ويتجاوزها «مخصّص» لخطوات هذا الوضع التي لا تملك تهيئة خاصة بها.';

  @override
  String get safetyOptionsEventDefaultsTwoStateInherit => 'توريث';

  @override
  String get safetyOptionsAllowDisarmAsDistressTitle =>
      'السماح بالإلغاء أثناء التشغيل كاستغاثة';

  @override
  String get safetyOptionsAllowDisarmAsDistressInfo =>
      'عند التفعيل يمكنك إيقاف التنبيه بالوصول إلى مكان آمن أو بانتهاء المؤقّت. وعند التعطيل لا يوقف التنبيه سوى اكتمال السلسلة أو إغلاق التطبيق — أقوى ضد الإكراه.';

  @override
  String get distressModesEmpty => 'لا توجد أوضاع استغاثة بعد.';

  @override
  String get distressModeEditorTitleCreate => 'وضع استغاثة جديد';

  @override
  String get distressModeEditorTitleEdit => 'تعديل وضع الاستغاثة';

  @override
  String get templatesTitle => 'قوالب التذكير';

  @override
  String get templatesEmpty => 'لا توجد قوالب بعد.';

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
  String get settingsThemeLight => 'فاتح';

  @override
  String get settingsThemeDark => 'داكن';

  @override
  String get settingsThemeSystem => 'النظام';

  @override
  String get settingsEmergencyNumberLabel => 'رقم الطوارئ';

  @override
  String get settingsRedoOnboardingActiveSessionTooltip =>
      'لا يمكن إعادة التهيئة أثناء جلسة نشطة';

  @override
  String get settingsEmergencyNumberCountryPickerTitle => 'اختيار رقم الطوارئ';

  @override
  String get settingsEmergencyNumberEditTitle => 'رقم الطوارئ';

  @override
  String get settingsEmergencyNumberFieldLabel => 'الرقم المطلوب الاتصال به';

  @override
  String get settingsEmergencyNumberPresetsLabel => 'الأرقام الشائعة';

  @override
  String get phoneWarnInvalidChars => 'يُسمح فقط بالأرقام و+ و* و#.';

  @override
  String get phoneWarnTooShort =>
      'عادةً ما تتكوّن أرقام الطوارئ من 3 أرقام على الأقل.';

  @override
  String get phoneWarnLooksLikeRegular =>
      'يبدو هذا رقم هاتف عادي، وليس رقم خدمات طوارئ.';

  @override
  String get phoneWarnEmergencyEmpty =>
      'أدخل رقمًا — لا يمكن ترك هذا الحقل فارغًا.';

  @override
  String get settingsRedoOnboarding => 'إعادة التهيئة';

  @override
  String get settingsRedoOnboardingConfirm => 'إعادة التهيئة من البداية؟';

  @override
  String get securitySessionEndPinBiometric =>
      'استخدام القياسات الحيوية لرمز PIN إنهاء الجلسة';

  @override
  String get securityAppPinBiometric => 'استخدام القياسات الحيوية لقفل التطبيق';

  @override
  String get securityDistressCancelBiometric =>
      'استخدام السمات الحيوية لإلغاء الاستغاثة';

  @override
  String get launchPinTitle => 'أدخل رمز PIN الخاص بالتطبيق';

  @override
  String get launchPinBiometricReason => 'إلغاء قفل Guardian Angela';

  @override
  String get sessionEndBiometricReason => 'أكِّد لإنهاء الجلسة';

  @override
  String get distressCancelBiometricReason => 'أكِّد هويتك للإلغاء';

  @override
  String get launchPinIncorrect => 'رمز PIN غير صحيح';

  @override
  String get securitySetPin => 'تعيين رمز PIN';

  @override
  String get securityChangePin => 'تغيير رمز PIN';

  @override
  String get pinSetupMismatch => 'رمزا PIN غير متطابقين. حاول مرة أخرى.';

  @override
  String get stealthTimerDisplayNormal => 'عرض النص الكامل';

  @override
  String get stealthTimerDisplaySmall => 'عرض الأرقام فقط';

  @override
  String get stealthTimerDisplayNone => 'إخفاء المؤقت';

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
  String get eventDefaultsTitle => 'افتراضيات الخطوات';

  @override
  String get historyRetentionTitle => 'مدة الاحتفاظ بالسجل';

  @override
  String get backupTitle => 'النسخ الاحتياطي';

  @override
  String get aboutTitle => 'حول التطبيق';

  @override
  String aboutVersion(Object version) {
    return 'الإصدار';
  }

  @override
  String get feedbackTitle => 'التعليقات';

  @override
  String get feedbackSend => 'فتح البريد الإلكتروني';

  @override
  String get stealthPresetPodcast => 'بودكاست';

  @override
  String get stealthPresetNone => 'بدون';

  @override
  String get stealthLockTaskLabel => 'تثبيت التطبيق أثناء الجلسة';

  @override
  String get stealthLockTaskSubtitle =>
      'يمنع مغادرة التطبيق أثناء تشغيل الجلسة. على نظام Android يفعّل هذا تثبيت الشاشة؛ وعلى الأنظمة الأخرى لا يكون له أي تأثير.';

  @override
  String get stealthLockTaskInfo =>
      'يثبّت Guardian Angela على الشاشة طوال الجلسة بحيث لا يمكن تمريره للإغلاق أو التبديل إلى تطبيق آخر. المقايضة: يعرض نظام Android إشعارًا للنظام \"التطبيق مثبّت\" ويمنع التبديل بين التطبيقات حتى تنتهي الجلسة — وهو مرئي لأي شخص ينظر إلى الشاشة. اتركه معطّلًا إذا كنت تفضّل التنقّل بحرية بين التطبيقات أثناء الجلسة. لا تأثير له على الأنظمة التي لا تدعم تثبيت الشاشة.';

  @override
  String get homeTagline => 'ملاكك يحرسك.';

  @override
  String get onboardingWelcomeGreeting => 'مرحبًا، أنا أنجيلا';

  @override
  String get onboardingWelcomeBodyFull =>
      'أنا حارستك الشخصية. أمشي معك، وأراقب أمسيتك بالخارج، وأتصرّف إذا شعرتُ أن شيئًا ما ليس على ما يُرام.';

  @override
  String get onboardingGetStarted => 'لنبدأ';

  @override
  String get onboardingProfileNameLabel => 'الاسم';

  @override
  String get onboardingProfilePhoneLabel => 'رقم الهاتف';

  @override
  String get onboardingProfilePhoneHelper => 'يُدرَج في رسائل الطوارئ.';

  @override
  String get onboardingEmergencyContactHeader => 'جهة اتصال الطوارئ';

  @override
  String get onboardingEmergencyContactPrompt =>
      'بمن ينبغي أن نتصل إذا حدث خطب ما؟';

  @override
  String get onboardingEmergencyContactAdd => 'إضافة جهة اتصال للطوارئ';

  @override
  String get onboardingPermissionsIntro =>
      'تحافظ هذه الأذونات على سلامتك أثناء الجلسات.';

  @override
  String get onboardingPermissionsGrantAll => 'منح الكل';

  @override
  String get onboardingPermissionsRequired => 'مطلوب';

  @override
  String get onboardingPermissionsOptional => 'اختياري';

  @override
  String get onboardingPermissionsMicrophone => 'الميكروفون';

  @override
  String get onboardingPermissionsCamera => 'الكاميرا';

  @override
  String get onboardingPermissionsNotificationDesc =>
      'مطلوب لتنبيهات الجلسة والتذكيرات.';

  @override
  String get onboardingPermissionsSmsDesc =>
      'مطلوب لإرسال تنبيهات الطوارئ النصية.';

  @override
  String get onboardingPermissionsPhoneDesc =>
      'مطلوب لإجراء مكالمات الطوارئ والمكالمات الوهمية.';

  @override
  String get onboardingPermissionsLocationDesc =>
      'يُدرَج في رسائل الطوارئ عند تفعيل تسجيل GPS.';

  @override
  String get onboardingPermissionsMicrophoneDesc =>
      'يُستخدم لتسجيل الصوت أثناء الاستغاثة.';

  @override
  String get onboardingPermissionsCameraDesc =>
      'يُستخدم لإشارات الاستغاثة بالفلاش.';

  @override
  String get sessionInterruptedTitle => 'تمت مقاطعة الجلسة';

  @override
  String get sessionInterruptedBody =>
      'كانت هناك جلسة قيد التشغيل عند توقّف التطبيق. لقد زالت حالة الجلسة — لم تتم استعادة أي شيء. نعرض هذا لإعلامك فقط.';

  @override
  String get sessionInterruptedAcknowledge => 'إقرار';

  @override
  String sessionInterruptedMode(Object name) {
    return 'الوضع: $name';
  }

  @override
  String sessionInterruptedStarted(Object time) {
    return 'البداية: $time';
  }

  @override
  String get sessionGpsDestinationTitle => 'الوجهة';

  @override
  String get sessionGpsDestinationBody =>
      'أدخلي إحداثيات الوجهة لمحفّز إلغاء التأهب عند الوصول عبر GPS.';

  @override
  String get sessionGpsDestinationLat => 'خط العرض';

  @override
  String get sessionGpsDestinationLng => 'خط الطول';

  @override
  String get sessionGpsDestinationSkip => 'تخطّي لهذه الجلسة';

  @override
  String get sessionGpsDestinationConfirm => 'استخدام الوجهة';

  @override
  String get sessionEndOverlayTitle => 'إنهاء الجلسة؟';

  @override
  String get sessionEndOverlayBody => 'اسحبي للتأكيد أنك تريدين إنهاء الجلسة';

  @override
  String get sessionEndOverlaySwipeLabel => 'اسحبي للإنهاء';

  @override
  String get sessionEndOverlaySimBadge => '[SIM] وضع التدريب';

  @override
  String get sessionEndPinPromptTitle => 'أدخلي رمز PIN إنهاء الجلسة';

  @override
  String get sessionEndPinAppPinMismatch =>
      'استخدمي رمز PIN إنهاء الجلسة، وليس رمز قفل التطبيق.';

  @override
  String get sessionEndPinIncorrect => 'رمز PIN غير صحيح';

  @override
  String get sessionEndPinSimSkip => 'تخطّي (المحاكاة فقط)';

  @override
  String get sessionEndSimDistressWouldFire =>
      'كانت سلسلة الاستغاثة ستنطلق (5 رموز PIN خاطئة)';

  @override
  String get distressConfirmTitle => 'تم تفعيل الاستغاثة';

  @override
  String distressConfirmCountdown(int seconds) {
    return 'اضغطي للإلغاء — لديك $seconds ثانية';
  }

  @override
  String get distressConfirmCancel => 'اضغطي للإلغاء';

  @override
  String get distressConfirmFooter =>
      'إذا لم يتم الإلغاء، فستبدأ سلسلة الاستغاثة فورًا.';

  @override
  String get distressCancelPinPromptTitle => 'أدخلي رمز PIN إنهاء الجلسة';

  @override
  String distressCancelPinTimeoutLabel(int seconds) {
    return 'تبقّى $seconds ث';
  }

  @override
  String get distressCancelPinIncorrect => 'رمز PIN غير صحيح';

  @override
  String get distressCancelPinAppPinMismatch =>
      'استخدمي رمز PIN إنهاء الجلسة، وليس رمز قفل التطبيق.';

  @override
  String get distressCancelPinSimSkip => 'تخطّي (المحاكاة فقط)';

  @override
  String get distressCancelSimDistressWouldFire =>
      'كانت سلسلة الاستغاثة ستنطلق (5 رموز PIN خاطئة)';

  @override
  String get distressCancelPinBack => 'إلغاء';

  @override
  String get simulationPinPromptTitle => 'أدخلي رمز PIN';

  @override
  String get simulationPinPromptBody => 'تدرّبي على إدخال رمز PIN إنهاء الجلسة';

  @override
  String get simulationPinPromptSkip => 'تخطّي';

  @override
  String get simulationPinIncorrect => 'رمز PIN غير صحيح';

  @override
  String simulationSummaryDuration(String duration) {
    return 'المدة: $duration';
  }

  @override
  String get simulationSummaryTimelineHeader => 'الجدول الزمني للأحداث';

  @override
  String get simulationSummaryShare => 'مشاركة';

  @override
  String simulationSummaryMissedEventsBadge(int count) {
    return 'فائت: $count';
  }

  @override
  String simulationSummaryDistressBadge(int count) {
    return 'الاستغاثة: $count';
  }

  @override
  String simulationSummaryStepsFiredBadge(int count) {
    return 'الخطوات المنطلقة: $count';
  }

  @override
  String get simulationSummaryShareSubject => 'ملخص محاكاة Guardian Angela';

  @override
  String get notificationsChannelAlarm => 'تصعيد الإنذار';

  @override
  String get notificationsChannelAlarmDescription =>
      'تنبيهات حرجة تتجاوز وضع «عدم الإزعاج»';

  @override
  String get notificationsChannelReminder => 'تذكير مموَّه';

  @override
  String get notificationsChannelReminderDescription =>
      'تذكيرات تسجيل الوصول أثناء الجلسة النشطة';

  @override
  String get notificationsChannelFakeCall => 'مكالمة وهمية';

  @override
  String get notificationsChannelFakeCallDescription =>
      'إشعارات مكالمة واردة بملء الشاشة';

  @override
  String get notificationsChannelEnabled => 'مفعّل';

  @override
  String get notificationsChannelDisabled => 'معطّل';

  @override
  String get notificationsChannelsHeader => 'قنوات الإشعارات';

  @override
  String get contactsImportFromDevice => 'استيراد من جهات الاتصال';

  @override
  String get contactsImportNotSupported => 'غير متاح على هذه المنصة';

  @override
  String get contactsImportPermissionDenied =>
      'تم رفض الوصول إلى جهات الاتصال. فعّليه من إعدادات النظام.';

  @override
  String get contactsDeleteAllMenu => 'حذف الكل';

  @override
  String get contactsDeleteAllConfirmTitle => 'حذف جميع جهات الاتصال؟';

  @override
  String get contactsDeleteAllConfirmBody =>
      'يؤدّي هذا إلى إزالة كل جهات اتصال الطوارئ. لا يمكن التراجع عن ذلك.';

  @override
  String get contactsDeleteAllTypeConfirmTitle => 'التأكيد بالكتابة';

  @override
  String get contactsDeleteAllTypeConfirmHint => 'اكتبي DELETE ALL للمتابعة';

  @override
  String get contactsDeleteAllTypeConfirmSentinel => 'DELETE ALL';

  @override
  String get contactsDeleteAllConfirmButton => 'حذف الكل';

  @override
  String get modesBuiltinBadge => 'مضمَّن';

  @override
  String get modesBuiltinNoDelete => 'لا يمكن حذف الأوضاع المضمَّنة';

  @override
  String get sessionCompletedSimulationBanner => 'اكتملت المحاكاة';

  @override
  String get sessionCompletedViewEventLog => 'عرض سجل الأحداث';

  @override
  String get settingsGeneralHeader => 'عام';

  @override
  String get settingsAppHeader => 'التطبيق';

  @override
  String get settingsConfigurationHeader => 'الإعدادات';

  @override
  String get settingsThemeLabel => 'السمة';

  @override
  String get settingsLanguageLabel => 'اللغة';

  @override
  String get settingsSecurityRow => 'الأمان';

  @override
  String get settingsSecuritySubtitle =>
      'رمز PIN التطبيق، رمز PIN إنهاء الجلسة، رمز PIN الإكراه';

  @override
  String get settingsStealthRow => 'التخفّي';

  @override
  String get settingsStealthSummaryOff => 'التخفّي: مُعطَّل';

  @override
  String get settingsStealthSummaryOn => 'التخفّي: مُفعَّل';

  @override
  String get settingsProfileRow => 'الملف الشخصي';

  @override
  String get settingsModesRow => 'الأوضاع';

  @override
  String get settingsDistressModesRow => 'أوضاع الاستغاثة';

  @override
  String get settingsEventDefaultsRow => 'افتراضيات الخطوات';

  @override
  String get settingsGpsLoggingRow => 'تسجيل GPS';

  @override
  String get settingsRemindersRow => 'قوالب التذكير';

  @override
  String get settingsNotificationsRow => 'الإشعارات';

  @override
  String get settingsHistoryRetentionRow => 'السجل والاحتفاظ';

  @override
  String get settingsAboutRow => 'حول التطبيق';

  @override
  String get settingsFeedbackRow => 'إرسال التعليقات';

  @override
  String get settingsBackupRow => 'النسخ الاحتياطي والاستعادة';

  @override
  String get settingsOssLicenses => 'تراخيص المصادر المفتوحة';

  @override
  String get settingsImportConfirmBody =>
      'سيؤدّي هذا إلى الكتابة فوق جميع البيانات الحالية. هل تريدين المتابعة؟';

  @override
  String get securityAppPinTitle => 'رمز PIN التطبيق';

  @override
  String get securityAppPinBody => 'يقفل التطبيق في كل مرة تفتحينه فيها.';

  @override
  String get securitySessionEndPinTitle => 'رمز PIN إنهاء الجلسة';

  @override
  String get securitySessionEndPinBody =>
      'مطلوب لإلغاء تأهب جلسة قيد التشغيل أو إنهائها.';

  @override
  String get securityDuressPinTitle => 'رمز PIN الإكراه';

  @override
  String get securityDuressPinBody =>
      'يُدخَل عند أي مطالبة لإطلاق سلسلة الاستغاثة بصمت.';

  @override
  String get securityRemovePin => 'إزالة';

  @override
  String get securityRemovePinPrompt => 'أدخل رمز PIN الحالي لإزالته.';

  @override
  String get securityRemovePinIncorrect => 'رمز PIN غير صحيح';

  @override
  String get securityWhatIsThis => 'ما هذا؟';

  @override
  String get securityAppPinInfo =>
      'يقفل التطبيق عند فتحه. تظهر لوحة المفاتيح قبل أي شاشة. مفيد إذا تعامل أحدهم لفترة وجيزة مع هاتفك غير المقفل.';

  @override
  String get securitySessionEndPinInfo =>
      'مطلوب لإلغاء تأهب جلسة أمان قيد التشغيل أو إنهائها. وبدونه، لا يستطيع مهاجم يأخذ هاتفك إيقاف السلسلة. اختاري رمزًا مختلفًا عن رمز PIN التطبيق.';

  @override
  String get securityDuressPinInfo =>
      'إذا أدخلتِ هذا الرمز عند أي مطالبة، فإن سلسلة الاستغاثة تعمل بصمت — يتم تنبيه جهات اتصالك ويتهيّأ الإنذار دون أن يلاحظ المهاجم. اختاري رمزًا مختلفًا عن كل رمز PIN آخر.';

  @override
  String get securityPinTimeoutLabel => 'مهلة رمز PIN (ثوانٍ)';

  @override
  String get securityWrongPinThresholdLabel =>
      'عدد محاولات رمز PIN الخاطئة قبل التصعيد';

  @override
  String get securityDeceptiveDialogToggle =>
      'عرض مربّع حوار خادع عند رمز PIN خاطئ';

  @override
  String get pinSetupEnterNew => 'أدخلي رمز PIN جديدًا';

  @override
  String get pinSetupConfirmNew => 'أكّدي رمز PIN الجديد';

  @override
  String get pinSetupTooShort => 'يجب أن يتكوّن رمز PIN من 4 أرقام على الأقل.';

  @override
  String get pinSetupCollision => 'يتعارض رمز PIN هذا مع رمز PIN آخر مُكوَّن.';

  @override
  String get pinSetupSaved => 'تم حفظ رمز PIN';

  @override
  String get stealthEnabledLabel => 'تفعيل التخفّي';

  @override
  String get stealthFakeNameLabel => 'اسم تطبيق مزيّف';

  @override
  String get stealthFakeIconLabel => 'أيقونة مزيّفة';

  @override
  String get stealthNotificationDisguiseLabel => 'تمويه الإشعارات';

  @override
  String get stealthTimerDisplayLabel => 'عرض المؤقّت';

  @override
  String get stealthSessionScreenLabel => 'تخفّي شاشة الجلسة';

  @override
  String get gpsLoggingEnabled => 'تسجيل GPS أثناء الجلسات';

  @override
  String get gpsLoggingIntervalLabel => 'الفاصل الزمني';

  @override
  String get gpsLoggingAccuracyLabel => 'الدقّة';

  @override
  String get gpsLoggingAccuracyHigh => 'عالية';

  @override
  String get gpsLoggingAccuracyBalanced => 'متوازنة';

  @override
  String get gpsLoggingAccuracyLow => 'منخفضة';

  @override
  String get gpsLoggingFormatLabel => 'تنسيق الإحداثيات';

  @override
  String get gpsLoggingFormatDecimal => 'عشري';

  @override
  String get gpsLoggingFormatDms => 'درجات ودقائق وثوانٍ';

  @override
  String get gpsLoggingFormatAddress => 'Plus Code';

  @override
  String get gpsLoggingIncludeInSms => 'إلحاق الموقع بالرسالة النصية';

  @override
  String get historyRetentionLogsLabel => 'مدة الاحتفاظ بسجل الجلسة (أيام)';

  @override
  String get historyRetentionLogsHelper =>
      'تنتقل السجلات الأقدم من ذلك إلى سلة المهملات.';

  @override
  String get historyRetentionTrashLabel => 'مدة الاحتفاظ بسلة المهملات (أيام)';

  @override
  String get historyRetentionTrashHelper =>
      'تُحذف السجلات الموجودة في سلة المهملات نهائيًا بعد هذه المدة.';

  @override
  String get historyRetentionUpdated => 'تم تحديث مدة الاحتفاظ';

  @override
  String get historyRetentionPurgeNow => 'التطهير الآن';

  @override
  String historyRetentionPurged(Object count) {
    return 'تم تطهير $count من السجلات';
  }

  @override
  String get eventDefaultsCheckInHeader => 'طرق تسجيل الوصول';

  @override
  String get eventDefaultsEscalationHeader => 'خطوات التصعيد';

  @override
  String get eventDefaultsPanicHeader => 'محفّز الذعر';

  @override
  String get templatesCreate => 'إنشاء قالب';

  @override
  String get templatesEditTitle => 'تعديل القالب';

  @override
  String get templatesCreateTitle => 'قالب جديد';

  @override
  String get templatesNameLabel => 'الاسم';

  @override
  String get templatesTitleLabel => 'العنوان';

  @override
  String get templatesBodyLabel => 'النص';

  @override
  String get templatesBuiltinNoDelete => 'لا يمكن حذف القوالب المضمَّنة';

  @override
  String get templatesAddFromTemplate => 'من قالب';

  @override
  String get templatesAddFromScratch => 'من الصفر';

  @override
  String templatesDeleteConfirmTitle(Object name) {
    return 'حذف \"$name\"؟';
  }

  @override
  String get templatesDeleteConfirmBody => 'ستتم إزالة هذا القالب نهائيًا.';

  @override
  String get templatesEmptyAddFirst => 'أضيفي قالبك الأول';

  @override
  String get templatesPickFromBuiltinTitle => 'اختاري قالبًا مضمَّنًا';

  @override
  String get templatesIconLabel => 'الأيقونة';

  @override
  String get templatesIconCalendar => 'التقويم';

  @override
  String get templatesIconAppNotification => 'إشعار تطبيق';

  @override
  String get templatesIconFitness => 'اللياقة';

  @override
  String get templatesIconHealth => 'الصحة';

  @override
  String get templatesIconFood => 'الطعام';

  @override
  String get templatesIconCoffee => 'قهوة';

  @override
  String get templatesIconBattery => 'البطارية';

  @override
  String get templatesIconWeather => 'الطقس';

  @override
  String get templatesPreviewHeading => 'معاينة مباشرة';

  @override
  String get templatesDiscardChangesTitle => 'تجاهل التغييرات؟';

  @override
  String get templatesDiscardChangesBody => 'ستُفقد التعديلات غير المحفوظة.';

  @override
  String get templatesDiscardKeep => 'متابعة التحرير';

  @override
  String get templatesDiscardDiscard => 'تجاهل';

  @override
  String get notificationsTitle => 'الإشعارات';

  @override
  String get notificationsStatusGranted => 'ممنوح';

  @override
  String get notificationsStatusDenied => 'مرفوض';

  @override
  String get notificationsStatusUnknown => 'لم يُطلب بعد';

  @override
  String get notificationsRequest => 'طلب الإذن';

  @override
  String get notificationsOpenSettings => 'فتح إعدادات النظام';

  @override
  String get profileFieldPhone => 'رقم الهاتف';

  @override
  String get profileFieldDescription => 'الوصف الجسدي';

  @override
  String get profileFieldMedicalConditions => 'الحالات الطبية';

  @override
  String get profileFieldEmergencyInstructions => 'تعليمات الطوارئ';

  @override
  String get aboutAuthor => 'المؤلف: Jonas Eschle';

  @override
  String get aboutEmail => 'guardian.angela.app@gmail.com';

  @override
  String get aboutPrivacyPolicy => 'سياسة الخصوصية';

  @override
  String get aboutTermsOfService => 'شروط الخدمة';

  @override
  String get aboutSourceCode => 'الكود المصدري';

  @override
  String get aboutSupport => 'الدعم / التبرّع';

  @override
  String get aboutLicenses => 'تراخيص المصادر المفتوحة';

  @override
  String get aboutTagline => 'صُنع بحب من أجل سلامة مجتمع الميم.';

  @override
  String get aboutTechnicalSection => 'المعلومات التقنية';

  @override
  String aboutBundleId(Object id) {
    return 'معرّف الحزمة: $id';
  }

  @override
  String aboutPlatforms(Object list) {
    return 'المنصّات: $list';
  }

  @override
  String get feedbackHeading => 'يسعدنا أن نسمع منك';

  @override
  String get feedbackCategoryLabel => 'الفئة';

  @override
  String get feedbackCategoryBug => 'بلاغ عن خلل';

  @override
  String get feedbackCategoryFeature => 'طلب ميزة';

  @override
  String get feedbackCategoryOther => 'أخرى';

  @override
  String get feedbackEmailLabel => 'البريد الإلكتروني (اختياري)';

  @override
  String get feedbackMessageLabel => 'الرسالة';

  @override
  String get feedbackIncludeLog => 'تضمين سجل آخر جلسة';

  @override
  String get feedbackSent => 'شكرًا لك على ملاحظاتك!';

  @override
  String get feedbackMessageRequired =>
      'يجب أن تتكوّن الرسالة من 10 أحرف على الأقل.';

  @override
  String get backupIncludeLogs => 'تضمين سجلات الجلسات';

  @override
  String get backupIncludeMedia => 'تضمين الوسائط';

  @override
  String get backupExportButton => 'تصدير';

  @override
  String get backupImportButton => 'استيراد';

  @override
  String get backupOverwriteWarning =>
      'يؤدّي الاستيراد إلى الكتابة فوق جميع البيانات الحالية.';

  @override
  String get backupImportSuccess => 'اكتمل الاستيراد. أعيدي التشغيل للتطبيق.';

  @override
  String backupImportError(Object message) {
    return 'فشل الاستيراد: $message';
  }

  @override
  String get backupActiveSessionBanner =>
      'النسخ الاحتياطي غير متاح أثناء جلسة نشطة.';

  @override
  String backupLastBackupAtLabel(Object when) {
    return 'آخر نسخة احتياطية في $when';
  }

  @override
  String get backupNeverExportedLabel => 'لا توجد نسخة احتياطية بعد';

  @override
  String get pastEventsTitle => 'الجلسات السابقة';

  @override
  String get pastEventsTabReal => 'حقيقية';

  @override
  String get pastEventsTabSimulated => 'محاكاة';

  @override
  String get pastEventsEmpty => 'لا توجد جلسات بعد';

  @override
  String get pastEventsDeleteConfirm => 'حذف سجل الجلسة؟';

  @override
  String get pastEventsDetailShareText => 'مشاركة كنص';

  @override
  String get pastEventsDetailSharePdf => 'مشاركة كملف PDF';

  @override
  String get pastEventsDetailDelete => 'حذف';

  @override
  String get pastEventsOutcomeCompleted => 'مكتملة';

  @override
  String get pastEventsOutcomeDistress => 'استغاثة';

  @override
  String get pastEventsOutcomeInterrupted => 'متقطّعة';

  @override
  String get pastEventsTrash => 'سلة المهملات';

  @override
  String get pastEventsUndo => 'تراجع';

  @override
  String get pastEventsSoftDeleted => 'نُقل إلى سلة المهملات';

  @override
  String get pastEventsDetailTitle => 'سجل الجلسة';

  @override
  String get pastEventsDetailShare => 'مشاركة';

  @override
  String get contactUnsavedDiscardTitle => 'تجاهل التغييرات غير المحفوظة؟';

  @override
  String get contactUnsavedDiscardKeep => 'متابعة التحرير';

  @override
  String get contactUnsavedDiscardDiscard => 'تجاهل';

  @override
  String get modesDuplicate => 'تكرار';

  @override
  String get modesDeleteConfirmTitle => 'حذف الوضع؟';

  @override
  String modesDeleteConfirmBody(Object name) {
    return 'ستتم إزالة $name نهائيًا.';
  }

  @override
  String get modesDistressDefaultBadge => 'افتراضي';

  @override
  String get modesDistressSetDefault => 'تعيين كافتراضي';

  @override
  String get modesDistressCantDeleteLast =>
      'يلزم وجود وضع استغاثة واحد على الأقل.';

  @override
  String get modesDistressInUse => 'وضع الاستغاثة هذا مستخدَم من قِبل وضع آخر.';

  @override
  String get modesDistressTitle => 'أوضاع الاستغاثة';

  @override
  String get validationNameTooShort =>
      'يجب أن يتكوّن الاسم من حرفين على الأقل.';

  @override
  String get validationPhoneRequired => 'رقم الهاتف مطلوب.';

  @override
  String get validationChannelsRequired => 'اختاري قناة واحدة على الأقل.';

  @override
  String get validationChainEmpty => 'أضف خطوة واحدة على الأقل قبل الحفظ.';

  @override
  String get validationGpsFixedCoords =>
      'حدّد خط العرض وخط الطول لوجهة الوصول الثابتة.';

  @override
  String get validationHardwareTrigger =>
      'مُشغّل الطوارئ بالجهاز غير مكتمل — تحقّق من عدد الضغطات أو مدة الضغط المطوّل.';

  @override
  String get validationSmsChannelNotOnContacts =>
      'لا يمكن لأي من جهات الاتصال المختارة الاستقبال عبر قناة هذه الخطوة. اختر قناة أخرى أو أضِفها إلى جهة اتصال.';

  @override
  String get validationDistressNoActionTitle => 'لا توجد خطوة تنبيه صادرة';

  @override
  String get validationDistressNoActionBody =>
      'لا يحتوي وضع الطوارئ هذا على خطوة رسالة نصية أو مكالمة، لذا لا يترك أي أثر صادر. هل تريد الحفظ على أي حال؟';

  @override
  String get validationSaveAnyway => 'احفظ على أي حال';

  @override
  String get sessionHoldTouchToBegin => 'المسي للبدء';

  @override
  String sessionHoldReleaseCountdown(Object seconds) {
    return 'العد التنازلي: $seconds ث';
  }

  @override
  String sessionHoldGraceCountdown(Object seconds) {
    return 'فترة السماح: $seconds ث — أعيدي الضغط المطوّل لتبقي بأمان';
  }

  @override
  String get sessionHoldAgain => 'اضغطي مطوّلاً مرة أخرى لتبقي بأمان';

  @override
  String sessionStepNextCheckIn(Object time) {
    return 'تسجيل الوصول التالي خلال $time';
  }

  @override
  String sessionStepFakeCallActive(Object caller) {
    return 'مكالمة واردة من $caller';
  }

  @override
  String get sessionStepFakeCallOpen => 'فتح شاشة المكالمة';

  @override
  String sessionStepSimBlockedSms(Object count) {
    return '[SIM] كانت سترسَل رسالة نصية إلى $count من جهات الاتصال';
  }

  @override
  String get sessionStepSimBlockedPhone => '[SIM] كان سيتصل بجهة اتصال الطوارئ';

  @override
  String get sessionStepSimBlockedEmergency => '[SIM] كان سيتصل بخدمات الطوارئ';

  @override
  String get sessionStepSimBlockedAlarm =>
      '[SIM] كان الإنذار سيصدر صوتًا بكامل مستوى الصوت';

  @override
  String get sessionStartFailedTitle => 'لا يمكن بدء الجلسة';

  @override
  String get sessionStartFailedBody => 'صحّحي المشكلات التالية قبل البدء:';

  @override
  String get sessionQuickExitTitle => 'خروج سريع';

  @override
  String get sessionQuickExitBody =>
      'سيتم حفظ بيانات الجلسة وتشفيرها. أعيدي فتح التطبيق في أي وقت لاستعادتها.';

  @override
  String get sessionQuickExitConfirm => 'الخروج من التطبيق';

  @override
  String get pastEventsRestore => 'استعادة';

  @override
  String get stepEditorWait => 'الانتظار (ث)';

  @override
  String get stepEditorDuration => 'المدة (ث)';

  @override
  String get stepEditorGrace => 'فترة السماح (ث)';

  @override
  String get stepEditorRetryCount => 'عدد المحاولات';

  @override
  String get stepEditorRandomize => 'توقيت عشوائي (±20%)';

  @override
  String get stepEditorRemove => 'إزالة الخطوة';

  @override
  String get eventDefaultsHoldStyle => 'نمط الضغط المطوّل';

  @override
  String get eventDefaultsHoldSensitivity => 'حساسية الإفلات';

  @override
  String get eventDefaultsHoldVibrate => 'الاهتزاز عند الإفلات';

  @override
  String get eventDefaultsHoldSound => 'صوت عند الإفلات';

  @override
  String get eventDefaultsBlackScreen => 'تراكب الشاشة السوداء';

  @override
  String get eventDefaultsReminderRandomInterval => 'فاصل زمني عشوائي';

  @override
  String get eventDefaultsReminderRandomTemplate => 'ترتيب عشوائي للقوالب';

  @override
  String get eventDefaultsReminderResetOnEarly =>
      'إعادة التعيين عند تسجيل الوصول المبكر';

  @override
  String get eventDefaultsCountdownStyle => 'نمط العد التنازلي';

  @override
  String get eventDefaultsCountdownVibrate => 'الاهتزاز';

  @override
  String get eventDefaultsCountdownSound => 'الصوت';

  @override
  String get eventDefaultsFakeCallStyle => 'نمط المكالمة';

  @override
  String get eventDefaultsFakeCallCallerName => 'اسم المتصل';

  @override
  String get eventDefaultsFakeCallRingDuration => 'مدة الرنين (ث)';

  @override
  String get eventDefaultsFakeCallDeclineIsSafe => 'اعتبار الرفض دليل أمان';

  @override
  String get eventDefaultsFakeCallVoiceOutput => 'الإخراج الصوتي';

  @override
  String get eventDefaultsSmsChannel => 'القناة';

  @override
  String get eventDefaultsSmsIncludeLocation => 'تضمين الموقع';

  @override
  String get eventDefaultsSmsIncludeMedical => 'تضمين المعلومات الطبية';

  @override
  String get eventDefaultsSmsAutoRecord => 'تسجيل الصوت قبل الإرسال';

  @override
  String get eventDefaultsSmsRecordDuration => 'مدة التسجيل (ث)';

  @override
  String get eventDefaultsSmsMessageTemplate => 'قالب الرسالة';

  @override
  String get eventDefaultsSmsMessageTemplateHint =>
      'اتركه فارغًا لاستخدام التنبيه الافتراضي. انقر على عنصر نائب لإدراجه.';

  @override
  String get eventDefaultsSmsIosWarning =>
      'على iPhone، تتطلب الرسائل النصية الضغط يدويًا على «إرسال» في تطبيق الرسائل. إذا لم تتمكن من استخدام هاتفك، فلن تُرسَل الرسالة. ففكِّر في استخدام WhatsApp أو Telegram بدلاً من ذلك.';

  @override
  String get eventDefaultsLoudAlarmVolume => 'مستوى الصوت';

  @override
  String get eventDefaultsLoudAlarmSound => 'الصوت';

  @override
  String get eventDefaultsLoudAlarmFlashScreen => 'وميض الشاشة';

  @override
  String get eventDefaultsLoudAlarmFlashLight => 'وميض ضوء الكاميرا';

  @override
  String get eventDefaultsLoudAlarmGradual => 'تصاعد تدريجي لمستوى الصوت';

  @override
  String get eventDefaultsCallEmergencyNumber => 'رقم الطوارئ (تجاوز)';

  @override
  String get eventDefaultsCallEmergencyConfirm => 'عرض العد التنازلي للتأكيد';

  @override
  String get eventDefaultsCallEmergencyConfirmDuration => 'ثوانٍ التأكيد';

  @override
  String get eventDefaultsCallEmergencySmsFirst => 'إرسال رسالة الموقع أولاً';

  @override
  String get eventDefaultsCallEmergencyIosWarning =>
      'على iPhone، سيظهر مربع تأكيد قبل الاتصال. انقر على «اتصال» بسرعة.';

  @override
  String get eventDefaultsPhonePrimaryContact =>
      'جهة الاتصال الرئيسية (المعرّف)';

  @override
  String get eventDefaultsHardwareButton => 'الزر';

  @override
  String get eventDefaultsHardwarePattern => 'نمط الضغط';

  @override
  String get eventDefaultsHardwarePressCount => 'عدد الضغطات';

  @override
  String get eventDefaultsHardwareLongDuration => 'مدة الضغط المطوّل (ث)';

  @override
  String get pastEventsTrashTitle => 'سلة المهملات';

  @override
  String get pastEventsTrashEmpty => 'سلة المهملات فارغة';

  @override
  String get pastEventsTrashEmptyAll => 'إفراغ سلة المهملات';

  @override
  String get pastEventsTrashEmptyAllConfirmTitle => 'إفراغ سلة المهملات؟';

  @override
  String get pastEventsTrashEmptyAllConfirmBody =>
      'اكتبي EMPTY TRASH أدناه للتأكيد. يؤدّي هذا إلى حذف كل سجل في سلة المهملات نهائيًا.';

  @override
  String pastEventsTrashEmptyAllSuccess(Object count) {
    return 'تم إفراغ سلة المهملات ($count من السجلات)';
  }

  @override
  String pastEventsTrashRetentionNote(int days) {
    return 'تُحذف السجلات الموجودة في سلة المهملات نهائيًا بعد $days يومًا.';
  }

  @override
  String pastEventsTrashRemainingDays(int days) {
    return '$days يوم/أيام حتى الحذف النهائي';
  }

  @override
  String get pastEventsTrashDeletePermanently => 'حذف نهائي';

  @override
  String get pastEventsTrashDeletePermanentlyBody =>
      'لا يمكن التراجع عن هذا الإجراء.';

  @override
  String sessionEmergencyConfirmTitle(String number, int seconds) {
    return 'جارٍ الاتصال بـ $number خلال $seconds ث';
  }

  @override
  String get sessionEmergencyConfirmSwipe => 'اسحبي للإلغاء';

  @override
  String get sessionEmergencyConfirmKeep => 'متابعة الاتصال';

  @override
  String get sessionEmergencyConfirmSimBadge => '[SIM] وضع التدريب';

  @override
  String get sessionEmergencyConfirmSimCancelled =>
      'إلغاء محاكى — لم يكن ليتم إجراء المكالمة';

  @override
  String get swipeSliderSemantics => 'اسحبي للتأكيد';

  @override
  String get homeWidgetStatusIdle => 'خامل';

  @override
  String get homeWidgetStatusSession => 'جلسة نشطة';

  @override
  String get homeWidgetStatusSim => 'محاكاة نشطة';

  @override
  String get homeWidgetQuickExit => 'خروج سريع';

  @override
  String get homeWidgetFakeCall => 'مكالمة وهمية';

  @override
  String get settingsAlarmHeader => 'الإنذار';

  @override
  String get settingsAlarmDndOverrideLabel =>
      'يتجاوز الإنذار وضع الصامت/الاهتزاز';

  @override
  String get settingsAlarmDndOverrideWarning =>
      'تحذير: سيكون الإنذار صامتًا إذا كان هاتفك في الوضع الصامت.';

  @override
  String get settingsAlarmDndOverrideInfo =>
      'عند التفعيل، يُشغَّل الإنذار العالي بأقصى مستوى صوت حتى لو كان هاتفك في الوضع الصامت أو الاهتزاز. على أندرويد يستخدم مجرى صوت الإنذار لتجاوز وضع عدم الإزعاج. الإنذار هو الحدث الوحيد الذي يمكنه تجاوز إعدادات صوت هاتفك.';

  @override
  String get settingsAlarmGradualLabel => 'زيادة مستوى صوت الإنذار تدريجيًا';

  @override
  String get settingsAlarmGradualInfo =>
      'يبدأ الإنذار منخفضًا ثم يتصاعد إلى أقصى مستوى صوت. هذا هو المفتاح الرئيسي على مستوى التطبيق؛ ولكل خطوة إنذار خيارها الخاص للتصاعد التدريجي، ويجب تفعيل كليهما حتى يُطبَّق التصاعد.';

  @override
  String get settingsAlarmRampLabel => 'مدة التصاعد';

  @override
  String get settingsAlarmRampInfo =>
      'المدة التي يستغرقها الإنذار للوصول إلى أقصى مستوى صوت بدءًا من الصفر، متصاعدًا بانتظام خلال هذا الوقت. لا تأثير لها عند إيقاف التصاعد التدريجي.';
}
