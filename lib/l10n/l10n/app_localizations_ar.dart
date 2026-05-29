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
  String get sessionTitle => 'الجلسة';

  @override
  String get sessionDisarm => 'أنا بأمان';

  @override
  String get sessionDisarmStealth => 'No Angela needed';

  @override
  String get homeChainSummaryTitle => 'Chain Summary';

  @override
  String get homeChainSummaryEmpty =>
      'This mode has no steps yet — tap the mode to edit.';

  @override
  String homeChainSummaryTimingTitle(Object name) {
    return 'Step: $name';
  }

  @override
  String homeChainSummaryWait(Object seconds) {
    return 'Wait: ${seconds}s';
  }

  @override
  String homeChainSummaryDuration(Object seconds) {
    return 'Active: ${seconds}s';
  }

  @override
  String homeChainSummaryGrace(Object seconds) {
    return 'Grace period: ${seconds}s';
  }

  @override
  String homeChainSummaryRetry(Object count) {
    return 'Retries: $count';
  }

  @override
  String homeChainSummaryNextStep(Object name) {
    return 'Next step: $name';
  }

  @override
  String get homeChainSummaryNextStepNone => 'Next step: end of chain';

  @override
  String get homeChainSummaryClose => 'Close';

  @override
  String get chainStepNameHoldButton => 'Hold to stay safe';

  @override
  String get chainStepNameDisguisedReminder => 'Disguised reminder';

  @override
  String get chainStepNameCountdownWarning => 'Countdown warning';

  @override
  String get chainStepNameFakeCall => 'Fake call';

  @override
  String get chainStepNameSmsContact => 'SMS contact';

  @override
  String get chainStepNamePhoneCallContact => 'Phone call contact';

  @override
  String get chainStepNameLoudAlarm => 'Loud alarm';

  @override
  String get chainStepNameCallEmergency => 'Emergency call';

  @override
  String get chainStepNameHardwareButton => 'Hardware button';

  @override
  String get homeChecklistTitle => 'Safety Setup';

  @override
  String get homeChecklistDismissTooltip => 'Dismiss checklist';

  @override
  String get homeChecklistExpandTooltip => 'Show checklist';

  @override
  String get homeChecklistCollapseTooltip => 'Hide checklist';

  @override
  String homeChecklistProgress(Object done, Object total) {
    return '$done of $total done';
  }

  @override
  String get homeChecklistAllDoneBanner => 'All set — you\'re protected!';

  @override
  String get homeChecklistInfoTooltip => 'Why this matters';

  @override
  String get homeChecklistGotIt => 'Got it';

  @override
  String get homeChecklistGoThere => 'Go there';

  @override
  String get homeChecklistItem1Title => 'Add an emergency contact';

  @override
  String get homeChecklistItem2Title => 'Set a session-end PIN';

  @override
  String get homeChecklistItem3Title => 'Configure stealth mode';

  @override
  String get homeChecklistItem4Title => 'Test a simulation';

  @override
  String get homeChecklistItem5Title => 'Customize a safety mode';

  @override
  String get homeChecklistItem6Title => 'Grant required permissions';

  @override
  String get checklistInfo1Body =>
      'Emergency contacts are the people Guardian Angela messages and calls when you fail to check in. Without at least one contact, the chain has nowhere to escalate.';

  @override
  String get checklistInfo2Body =>
      'A session-end PIN prevents an attacker from quietly ending an active session. They can still attempt it, but typing the wrong PIN five times silently fires your distress chain.';

  @override
  String get checklistInfo3Body =>
      'Stealth mode disguises the active session as something innocuous on your screen — a music player, a paused timer, a blank lock screen. Use it when somebody nearby cannot see you running a safety app.';

  @override
  String get checklistInfo4Body =>
      'Simulation runs your safety mode end-to-end without sending real SMS, placing real calls, or sounding the loud alarm. Use it to learn the timings before you ever need them.';

  @override
  String get checklistInfo5Body =>
      'Custom modes let you tune the steps, timings, and triggers to a specific situation — walking home, a first date, a late shift. The two seed modes are starting points, not the destination.';

  @override
  String get checklistInfo6Body =>
      'Without notification permission, Guardian Angela cannot keep its persistent foreground status, deliver disguised reminders, or warn you that the chain is about to escalate.';

  @override
  String get checklistTutorial3Body =>
      'Open the stealth defaults and toggle \'Enable stealth mode\'. From there you can pick a fake music brand, hide the session timer, or disguise the home-screen icon.';

  @override
  String get checklistTutorial4Body =>
      'Tap the outlined \'Simulate\' button on the home screen after selecting a mode. The session runs with an orange border and the [SIM] badge — nothing leaves your phone.';

  @override
  String get checklistTutorial5Body =>
      'Open the Modes screen and either edit a seed mode (Walk / Date) or create a new one from scratch. Tweak the chain, add a fake call, set custom timings.';

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
  String get contactFormIosSmsWarning =>
      'On iOS, SMS opens the Messages app. You must tap Send manually.';

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
      'Cannot redo onboarding during an active session';

  @override
  String get settingsEmergencyNumberCountryPickerTitle =>
      'Choose emergency number';

  @override
  String get settingsRedoOnboarding => 'إعادة التهيئة';

  @override
  String get settingsRedoOnboardingConfirm => 'إعادة التهيئة من البداية؟';

  @override
  String get securitySessionEndPinBiometric =>
      'استخدام القياسات الحيوية لرمز PIN إنهاء الجلسة';

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
  String get batteryAlertTitle => 'تنبيه البطارية';

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
