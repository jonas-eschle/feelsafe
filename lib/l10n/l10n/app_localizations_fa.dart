// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Persian (`fa`).
class AppLocalizationsFa extends AppLocalizations {
  AppLocalizationsFa([String locale = 'fa']) : super(locale);

  @override
  String get appTitle => 'Guardian Angela';

  @override
  String get commonSave => 'ذخیره';

  @override
  String get angelaDialogTitle => 'پین قدیمی وارد شد';

  @override
  String get angelaDialogBody =>
      'به نظر می‌رسد از پین قدیمی استفاده کرده‌اید. آیا مطمئن هستید که می‌خواهید ادامه دهید؟';

  @override
  String get angelaDialogCancel => 'انصراف';

  @override
  String get angelaDialogConfirm => 'ادامه';

  @override
  String get commonCancel => 'انصراف';

  @override
  String get commonOk => 'تأیید';

  @override
  String get commonDelete => 'حذف';

  @override
  String get commonEdit => 'ویرایش';

  @override
  String get commonClose => 'بستن';

  @override
  String get commonConfirm => 'تأیید';

  @override
  String get commonBack => 'بازگشت';

  @override
  String get pinSubmit => 'ثبت';

  @override
  String get homeTitle => 'Guardian Angela';

  @override
  String get homeStartSession => 'شروع جلسه';

  @override
  String get homePermissionsNotification => 'اعلان‌ها';

  @override
  String get homePermissionsLocation => 'موقعیت';

  @override
  String get homePermissionsCallPhone => 'تماس‌های تلفنی';

  @override
  String get homePermissionsSendSms => 'ارسال پیامک';

  @override
  String get homeSimulate => 'شبیه‌سازی';

  @override
  String get homeNoModes =>
      'هنوز هیچ حالتی وجود ندارد. برای افزودن، روی حالت‌ها بزنید.';

  @override
  String get homeContactsBannerNone => 'هیچ مخاطب اضطراری پیکربندی نشده است.';

  @override
  String get homeMenuSettings => 'تنظیمات';

  @override
  String get homeMenuContacts => 'مخاطبین';

  @override
  String get homeMenuHistory => 'جلسات گذشته';

  @override
  String get onboardingProfileTitle => 'پروفایل و اولین مخاطب';

  @override
  String get onboardingPermissionsTitle => 'دسترسی‌ها';

  @override
  String get onboardingNext => 'بعدی';

  @override
  String get onboardingSkip => 'رد کردن';

  @override
  String get onboardingUseSimNumber => 'استفاده از شماره سیم‌کارت من';

  @override
  String onboardingUseSimNumberHint(Object number) {
    return '$number';
  }

  @override
  String get onboardingUseSimNumberUnsupported => 'در iOS در دسترس نیست';

  @override
  String get onboardingUseSimNumberUnavailable => 'خواندن شماره ممکن نشد';

  @override
  String get onboardingUseSimNumberPermissionDenied => 'دسترسی رد شد';

  @override
  String get sessionTitle => 'جلسه';

  @override
  String get sessionDisarm => 'من در امانم';

  @override
  String get sessionDisarmStealth => 'نیازی به آنجلا نیست';

  @override
  String get homeChainSummaryTitle => 'خلاصهٔ زنجیره';

  @override
  String get homeChainSummaryEmpty =>
      'این حالت هنوز مرحله‌ای ندارد — برای ویرایش روی حالت بزن.';

  @override
  String homeChainSummaryTimingTitle(Object name) {
    return 'مرحله: $name';
  }

  @override
  String homeChainSummaryWait(Object seconds) {
    return 'انتظار: $seconds ثانیه';
  }

  @override
  String homeChainSummaryDuration(Object seconds) {
    return 'فعال: $seconds ثانیه';
  }

  @override
  String homeChainSummaryGrace(Object seconds) {
    return 'مهلت: $seconds ثانیه';
  }

  @override
  String homeChainSummaryRetry(Object count) {
    return 'تلاش‌های مجدد: $count';
  }

  @override
  String homeChainSummaryNextStep(Object name) {
    return 'مرحلهٔ بعد: $name';
  }

  @override
  String get homeChainSummaryNextStepNone => 'مرحلهٔ بعد: پایان زنجیره';

  @override
  String get homeChainSummaryClose => 'بستن';

  @override
  String get chainStepNameHoldButton => 'برای ایمن ماندن نگه دار';

  @override
  String get chainStepNameDisguisedReminder => 'یادآور استتاری';

  @override
  String get chainStepNameCountdownWarning => 'هشدار شمارش معکوس';

  @override
  String get chainStepNameFakeCall => 'تماس ساختگی';

  @override
  String get chainStepNameSmsContact => 'SMS به مخاطب';

  @override
  String get chainStepNamePhoneCallContact => 'تماس با مخاطب';

  @override
  String get chainStepNameLoudAlarm => 'زنگ هشدار بلند';

  @override
  String get chainStepNameCallEmergency => 'تماس اضطراری';

  @override
  String get chainStepNameHardwareButton => 'دکمهٔ سخت‌افزاری';

  @override
  String get homeChecklistTitle => 'راه‌اندازی ایمنی';

  @override
  String get homeChecklistDismissTooltip => 'بستن فهرست';

  @override
  String get homeChecklistExpandTooltip => 'نمایش فهرست';

  @override
  String get homeChecklistCollapseTooltip => 'جمع کردن فهرست';

  @override
  String homeChecklistProgress(Object done, Object total) {
    return '$done از $total انجام شد';
  }

  @override
  String get homeChecklistAllDoneBanner => 'همه چیز آماده است — تو در امانی!';

  @override
  String get homeChecklistInfoTooltip => 'چرا مهم است';

  @override
  String get homeChecklistGotIt => 'فهمیدم';

  @override
  String get homeChecklistGoThere => 'برو آن‌جا';

  @override
  String get homeChecklistItem1Title => 'یک مخاطب اضطراری اضافه کن';

  @override
  String get homeChecklistItem2Title => 'PIN پایان جلسه را تعیین کن';

  @override
  String get homeChecklistItem3Title => 'حالت مخفی را تنظیم کن';

  @override
  String get homeChecklistItem4Title => 'یک شبیه‌سازی را امتحان کن';

  @override
  String get homeChecklistItem5Title => 'یک حالت ایمنی را شخصی‌سازی کن';

  @override
  String get homeChecklistItem6Title => 'دسترسی‌های لازم را بده';

  @override
  String get checklistInfo1Body =>
      'مخاطبان اضطراری کسانی‌اند که Guardian Angela وقتی به‌موقع علامت ایمن نزدی به آن‌ها پیام می‌دهد و زنگ می‌زند. بدون حداقل یک مخاطب، زنجیره جایی برای تشدید هشدار ندارد.';

  @override
  String get checklistInfo2Body =>
      'PIN پایان جلسه مانع می‌شود مهاجم بی‌سروصدا یک جلسهٔ فعال را پایان دهد. می‌تواند تلاش کند، اما پنج بار وارد کردن PIN اشتباه، زنجیرهٔ هشدار تو را بی‌صدا فعال می‌کند.';

  @override
  String get checklistInfo3Body =>
      'حالت مخفی، جلسهٔ فعال را روی صفحه به چیزی بی‌خطر تغییر چهره می‌دهد — یک پخش‌کنندهٔ موسیقی، یک تایمر متوقف، یک صفحهٔ قفل خالی. وقتی کسی نزدیک تو نباید ببیند برنامهٔ ایمنی اجرا می‌کنی از آن استفاده کن.';

  @override
  String get checklistInfo4Body =>
      'شبیه‌سازی حالت ایمنی را از ابتدا تا انتها اجرا می‌کند بدون ارسال SMS واقعی، بدون تماس واقعی و بدون پخش زنگ بلند. از آن برای آموختن زمان‌بندی‌ها پیش از نیاز واقعی استفاده کن.';

  @override
  String get checklistInfo5Body =>
      'حالت‌های دلخواه به تو اجازه می‌دهند مراحل، زمان‌بندی‌ها و محرّک‌ها را برای موقعیتی خاص تنظیم کنی — راه برگشت به خانه، اولین قرار، شیفت شب. دو حالت پیش‌فرض نقطهٔ شروع‌اند، نه مقصد.';

  @override
  String get checklistInfo6Body =>
      'بدون اجازهٔ اعلان، Guardian Angela نمی‌تواند وضعیت دائمی پیش‌زمینه را حفظ کند، یادآورهای استتاری بفرستد یا قبل از تشدید زنجیره به تو هشدار دهد.';

  @override
  String get checklistTutorial3Body =>
      'پیش‌فرض‌های مخفی را باز کن و «فعال‌سازی حالت مخفی» را روشن کن. از همان‌جا می‌توانی یک نام تجاری موسیقی ساختگی انتخاب کنی، تایمر جلسه را پنهان کنی یا آیکن صفحهٔ اصلی را تغییر چهره دهی.';

  @override
  String get checklistTutorial4Body =>
      'پس از انتخاب یک حالت، روی دکمهٔ «شبیه‌سازی» با حاشیه در صفحهٔ اصلی بزن. جلسه با حاشیهٔ نارنجی و نشان [SIM] اجرا می‌شود — هیچ چیز از گوشی‌ات خارج نمی‌شود.';

  @override
  String get checklistTutorial5Body =>
      'صفحهٔ «حالت‌ها» را باز کن و یا یک حالت پیش‌فرض (پیاده‌روی / قرار) را ویرایش کن، یا یک حالت تازه از صفر بساز. زنجیره را تنظیم کن، تماس ساختگی اضافه کن، زمان‌بندی دلخواه بگذار.';

  @override
  String get sessionHoldPrompt => 'برای حفظ ایمنی نگه دارید';

  @override
  String sessionStepLabel(Object index, Object total) {
    return 'گام $index از $total';
  }

  @override
  String sessionMissCount(Object count) {
    return 'از دست رفته: $count';
  }

  @override
  String get sessionPausedBadge => 'متوقف شده';

  @override
  String get sessionPausedIncomingCall => 'متوقف شده — تماس ورودی';

  @override
  String get sessionPhaseEnded => 'جلسه پایان یافت';

  @override
  String get sessionSimulationBanner => 'شبیه‌سازی';

  @override
  String get sessionCheckIn => 'من حاضرم';

  @override
  String get sessionStepCountdownTitle => 'هشدار';

  @override
  String get sessionStepCountdownBody =>
      'با پایان شمارش معکوس، تشدید بعدی فعال می‌شود. برای غیرفعال‌سازی، «من در امانم» را در پایین بکشید.';

  @override
  String get sessionStepDisguisedDefaultTitle => 'یادآور';

  @override
  String get sessionStepDisguisedDefaultBody =>
      'برای تأیید ایمنی خود روی «من حاضرم» بزنید.';

  @override
  String get sessionReminderEarlyCheckInHint => 'برای حضور الان بزنید';

  @override
  String get sessionReminderDefaultButton => 'باشه';

  @override
  String get sessionReminderTapWordHint => 'برای ادامه بزنید';

  @override
  String get sessionReminderSwipeLabel => 'بکشید تا بسته شود';

  @override
  String get sessionReminderDismissLabel => 'بستن';

  @override
  String get sessionStepSmsStatus => 'ارسال پیام به مخاطبین…';

  @override
  String get sessionStepPhoneCallStatus => 'در حال تماس با مخاطب اضطراری…';

  @override
  String get sessionStepLoudAlarmTitle => 'آژیر در حال پخش';

  @override
  String get sessionStepLoudAlarmBody =>
      'آژیر برای جلب توجه به صدا درآمده است.';

  @override
  String get sessionStepLoudAlarmFlashWarning =>
      'هشدار حساسیت نوری: صفحه چشمک می‌زند.';

  @override
  String get sessionStepCallEmergencyStatus => 'در حال تماس با خدمات اضطراری…';

  @override
  String sessionStepCallEmergencyNumber(Object number) {
    return 'شماره: $number';
  }

  @override
  String sessionStepHardwareButtonRepeat(
    Object button,
    Object count,
    Object windowMs,
  ) {
    return 'دکمه $button را در عرض $windowMs میلی‌ثانیه $count بار فشار دهید';
  }

  @override
  String sessionStepHardwareButtonLong(Object button, Object seconds) {
    return 'دکمه $button را به مدت $seconds ثانیه نگه دارید';
  }

  @override
  String get sessionStepHardwareButtonVolumeUp => 'افزایش صدا';

  @override
  String get sessionStepHardwareButtonVolumeDown => 'کاهش صدا';

  @override
  String get sessionStepHardwareButtonPower => 'روشن/خاموش';

  @override
  String get sessionCompletedTitle => 'جلسه کامل شد';

  @override
  String get sessionCompletedBody =>
      'شما به‌سلامت رسیدید. Guardian Angela آماده‌باش را لغو می‌کند.';

  @override
  String get sessionCompletedReturnHome => 'بازگشت به خانه';

  @override
  String get simulationSummaryTitle => 'خلاصه شبیه‌سازی';

  @override
  String get simulationSummaryEmpty => 'در این شبیه‌سازی هیچ گامی اجرا نشد.';

  @override
  String get simulationSummaryReturn => 'بازگشت به خانه';

  @override
  String get fakeCallTitle => 'تماس ورودی';

  @override
  String get fakeCallHangUp => 'قطع تماس';

  @override
  String get fakeCallSlideToAnswer => 'برای پاسخ بکشید';

  @override
  String get fakeCallUnknownCaller => 'ناشناس';

  @override
  String get fakeCallIncomingWhatsapp => 'تماس صوتی WhatsApp';

  @override
  String get fakeCallIncomingTelegram => 'تماس صوتی Telegram';

  @override
  String get fakeCallIncomingSignal => 'تماس صوتی Signal';

  @override
  String get fakeCallBrandWhatsapp => 'WHATSAPP';

  @override
  String get fakeCallBrandTelegram => 'TELEGRAM';

  @override
  String get fakeCallBrandSignal => 'SIGNAL';

  @override
  String get fakeCallBrandAndroid => 'تلفن';

  @override
  String get fakeCallBrandIos => 'تلفن';

  @override
  String get fakeCallBrandMinimal => 'تماس';

  @override
  String get fakeCallDeclineSafeLabel => 'رد تماس (در امانم)';

  @override
  String get fakeCallDeclineUnsafeLabel => 'رد تماس (در حالت آماده‌باش بمان)';

  @override
  String get fakeCallHoldForDistress => 'برای اضطرار ۵ ثانیه نگه دار';

  @override
  String fakeCallVoicePrompt(String name) {
    return 'اعلان صوتی: $name';
  }

  @override
  String fakeCallVibrationLabel(String pattern) {
    return 'لرزش: $pattern';
  }

  @override
  String get fakeCallVibrationPatternDefault => 'پیش‌فرض';

  @override
  String get fakeCallSlideToAnswerHint => 'برای پاسخ بکشید';

  @override
  String fakeCallActiveDuration(String mm, String ss) {
    return '$mm:$ss';
  }

  @override
  String get contactsTitle => 'مخاطبین اضطراری';

  @override
  String get contactsEmpty =>
      'هنوز هیچ مخاطبی وجود ندارد. یکی اضافه کنید تا پیام‌های اضطراری شما را دریافت کند.';

  @override
  String get contactsAdd => 'افزودن مخاطب';

  @override
  String get contactFormTitleCreate => 'مخاطب جدید';

  @override
  String get contactFormTitleEdit => 'ویرایش مخاطب';

  @override
  String get contactFieldName => 'نام';

  @override
  String get contactFieldPhone => 'شماره تلفن';

  @override
  String get contactFieldRelationship => 'نسبت (اختیاری)';

  @override
  String get contactFieldLanguage => 'زبان پیامک (اختیاری)';

  @override
  String get contactLanguageDefault => 'پیش‌فرض (استفاده از زبان برنامه)';

  @override
  String get contactChannelsHeader => 'کانال‌های پیام‌رسانی';

  @override
  String get contactChannelSms => 'پیامک';

  @override
  String get contactChannelWhatsapp => 'WhatsApp';

  @override
  String get contactChannelTelegram => 'Telegram';

  @override
  String get contactChannelPhone => 'تماس تلفنی';

  @override
  String get contactDeleteConfirm => 'مخاطب حذف شود؟';

  @override
  String contactDeleteBody(Object name) {
    return '$name از فهرست اضطراری شما حذف خواهد شد.';
  }

  @override
  String get contactFormIosSmsWarning =>
      'در iOS، پیامک در برنامهٔ Messages باز می‌شود. باید دستی روی ارسال بزنید.';

  @override
  String get modesTitle => 'حالت‌ها';

  @override
  String get modesEmpty =>
      'هنوز هیچ حالتی وجود ندارد. برای ایجاد حالت، روی افزودن بزنید.';

  @override
  String get modesAdd => 'افزودن حالت';

  @override
  String get modesNewPickerBlank => 'حالت خالی';

  @override
  String get modesNewPickerBlankSubtitle => 'با یک زنجیره خالی شروع کنید';

  @override
  String modesNewPickerFromTemplate(String name) {
    return 'از $name';
  }

  @override
  String get modesNewPickerFromTemplateSubtitle =>
      'کپی زنجیره و محرک‌های این حالت';

  @override
  String get modeEditorTitleCreate => 'حالت جدید';

  @override
  String get modeEditorTitleEdit => 'ویرایش حالت';

  @override
  String get modeFieldName => 'نام';

  @override
  String get modeChainHeader => 'زنجیره';

  @override
  String get modeChainAddStep => 'افزودن گام';

  @override
  String get modeUnsavedTitle => 'تغییرات حذف شود؟';

  @override
  String get modeUnsavedBody =>
      'تغییرات ذخیره‌نشده دارید. آن‌ها را حذف و از ویرایشگر خارج می‌شوید؟';

  @override
  String get modeUnsavedDiscard => 'حذف';

  @override
  String get modeUnsavedKeep => 'ادامه ویرایش';

  @override
  String stepTimingSummary(Object wait, Object duration, Object grace) {
    return 'انتظار $waitث / مدت $durationث / مهلت $graceث';
  }

  @override
  String get stepConfigTimingHeader => 'زمان‌بندی';

  @override
  String get stepConfigEventHeader => 'پیکربندی رویداد';

  @override
  String get stepConfigAdvancedHeader => 'تلاش مجدد و پیشرفته';

  @override
  String get stepFieldWait => 'انتظار پیش از اجرا (ثانیه)';

  @override
  String get stepFieldDuration => 'مدت فعال بودن (ثانیه)';

  @override
  String get stepFieldGrace => 'مهلت اضافه (ثانیه)';

  @override
  String get stepFieldRetryCount => 'تلاش‌های مجدد';

  @override
  String get stepFieldRandomize => 'تصادفی‌سازی زمان‌بندی (±20%)';

  @override
  String get stepDuplicate => 'تکثیر گام';

  @override
  String get stepResetDefaults => 'بازنشانی به پیش‌فرض‌ها';

  @override
  String get distressModesEmpty => 'هنوز هیچ حالت اضطراری وجود ندارد.';

  @override
  String get distressModeEditorTitleCreate => 'حالت اضطرار جدید';

  @override
  String get distressModeEditorTitleEdit => 'ویرایش حالت اضطرار';

  @override
  String get templatesTitle => 'الگوهای یادآور';

  @override
  String get templatesEmpty => 'هنوز هیچ الگویی وجود ندارد.';

  @override
  String get profileTitle => 'پروفایل';

  @override
  String get profileFieldName => 'نام';

  @override
  String get profileFieldAge => 'سن';

  @override
  String get profileFieldBloodType => 'گروه خونی';

  @override
  String get profileFieldAllergies => 'حساسیت‌ها';

  @override
  String get profileFieldMedications => 'داروها';

  @override
  String get settingsThemeLight => 'روشن';

  @override
  String get settingsThemeDark => 'تیره';

  @override
  String get settingsThemeSystem => 'سیستم';

  @override
  String get settingsEmergencyNumberLabel => 'شماره اضطراری';

  @override
  String get settingsRedoOnboardingActiveSessionTooltip =>
      'در حین جلسهٔ فعال نمی‌توان راه‌اندازی را از نو انجام داد';

  @override
  String get settingsEmergencyNumberCountryPickerTitle =>
      'انتخاب شماره اضطراری';

  @override
  String get settingsRedoOnboarding => 'راه‌اندازی مجدد';

  @override
  String get settingsRedoOnboardingConfirm => 'راه‌اندازی از نو؟';

  @override
  String get securitySessionEndPinBiometric =>
      'استفاده از زیست‌سنجی برای پین پایان جلسه';

  @override
  String get securityAppPinBiometric => 'استفاده از زیست‌سنجی برای قفل برنامه';

  @override
  String get launchPinTitle => 'پین برنامه را وارد کنید';

  @override
  String get launchPinBiometricReason => 'باز کردن قفل Guardian Angela';

  @override
  String get launchPinIncorrect => 'پین نادرست';

  @override
  String get securitySetPin => 'تنظیم پین';

  @override
  String get securityChangePin => 'تغییر پین';

  @override
  String get pinSetupMismatch => 'پین‌ها مطابقت ندارند. دوباره تلاش کنید.';

  @override
  String get stealthTimerDisplayNormal => 'نمایش متن کامل';

  @override
  String get stealthTimerDisplaySmall => 'نمایش فقط اعداد';

  @override
  String get stealthTimerDisplayNone => 'پنهان کردن تایمر';

  @override
  String get stealthPresetMusic => 'موسیقی';

  @override
  String get stealthPresetCalendar => 'تقویم';

  @override
  String get stealthPresetFitness => 'تناسب‌اندام';

  @override
  String get stealthPresetWeather => 'آب‌وهوا';

  @override
  String get stealthPresetNews => 'اخبار';

  @override
  String get stealthPresetPhotos => 'عکس‌ها';

  @override
  String get stealthPresetNotes => 'یادداشت‌ها';

  @override
  String get stealthPresetClock => 'ساعت';

  @override
  String get eventDefaultsTitle => 'پیش‌فرض‌های گام';

  @override
  String get historyRetentionTitle => 'نگهداری تاریخچه';

  @override
  String get backupTitle => 'پشتیبان‌گیری';

  @override
  String get aboutTitle => 'درباره';

  @override
  String aboutVersion(Object version) {
    return 'نسخه';
  }

  @override
  String get feedbackTitle => 'بازخورد';

  @override
  String get feedbackSend => 'باز کردن ایمیل';

  @override
  String get stealthPresetPodcast => 'پادکست';

  @override
  String get stealthPresetNone => 'هیچ‌کدام';

  @override
  String get stealthLockTaskLabel => 'سنجاق کردن برنامه در حین جلسه';

  @override
  String get stealthLockTaskSubtitle =>
      'از خروج از برنامه در حین اجرای جلسه جلوگیری می‌کند. در اندروید این کار سنجاق کردن صفحه را فعال می‌کند؛ در سایر سیستم‌عامل‌ها بی‌اثر است.';

  @override
  String get homeTagline => 'فرشته‌ات هوای تو را دارد.';

  @override
  String get onboardingWelcomeGreeting => 'سلام، من آنجلا هستم';

  @override
  String get onboardingWelcomeBodyFull =>
      'من فرشتهٔ نگهبان شخصی تو هستم. با تو راه می‌آیم، مراقب شب بیرون رفتنت هستم و اگر چیزی درست نباشد دست به کار می‌شوم.';

  @override
  String get onboardingGetStarted => 'شروع کنیم';

  @override
  String get onboardingProfileNameLabel => 'نام';

  @override
  String get onboardingProfilePhoneLabel => 'شماره تلفن';

  @override
  String get onboardingProfilePhoneHelper =>
      'در پیام‌های اضطراری گنجانده می‌شود.';

  @override
  String get onboardingEmergencyContactHeader => 'مخاطب اضطراری';

  @override
  String get onboardingEmergencyContactPrompt =>
      'اگر اتفاقی بیفتد با چه کسی تماس بگیریم؟';

  @override
  String get onboardingEmergencyContactAdd => 'افزودن مخاطب اضطراری';

  @override
  String get onboardingPermissionsIntro =>
      'این دسترسی‌ها در حین جلسات ایمنی تو را حفظ می‌کنند.';

  @override
  String get onboardingPermissionsGrantAll => 'اعطای همه';

  @override
  String get onboardingPermissionsRequired => 'ضروری';

  @override
  String get onboardingPermissionsOptional => 'اختیاری';

  @override
  String get onboardingPermissionsMicrophone => 'میکروفون';

  @override
  String get onboardingPermissionsCamera => 'دوربین';

  @override
  String get onboardingPermissionsNotificationDesc =>
      'برای هشدارها و یادآورهای جلسه لازم است.';

  @override
  String get onboardingPermissionsSmsDesc =>
      'برای ارسال هشدارهای پیامکی اضطراری لازم است.';

  @override
  String get onboardingPermissionsPhoneDesc =>
      'برای برقراری تماس‌های اضطراری و ساختگی لازم است.';

  @override
  String get onboardingPermissionsLocationDesc =>
      'وقتی ثبت موقعیت GPS روشن باشد، در پیام‌های اضطراری گنجانده می‌شود.';

  @override
  String get onboardingPermissionsMicrophoneDesc =>
      'برای ضبط صدا در حین اضطرار استفاده می‌شود.';

  @override
  String get onboardingPermissionsCameraDesc =>
      'برای علامت‌دهی SOS با فلاش استفاده می‌شود.';

  @override
  String get sessionInterruptedTitle => 'جلسه قطع شد';

  @override
  String get sessionInterruptedBody =>
      'هنگام توقف برنامه یک جلسه در حال اجرا بود. وضعیت جلسه از بین رفته است — چیزی بازیابی نشد. این پیام را نشان می‌دهیم تا باخبر باشی.';

  @override
  String get sessionInterruptedAcknowledge => 'متوجه شدم';

  @override
  String sessionInterruptedMode(Object name) {
    return 'حالت: $name';
  }

  @override
  String sessionInterruptedStarted(Object time) {
    return 'شروع: $time';
  }

  @override
  String get sessionGpsDestinationTitle => 'مقصد';

  @override
  String get sessionGpsDestinationBody =>
      'مختصات مقصد را برای محرک غیرفعال‌سازی هنگام رسیدن با GPS وارد کنید.';

  @override
  String get sessionGpsDestinationLat => 'عرض جغرافیایی';

  @override
  String get sessionGpsDestinationLng => 'طول جغرافیایی';

  @override
  String get sessionGpsDestinationSkip => 'رد کردن برای این جلسه';

  @override
  String get sessionGpsDestinationConfirm => 'استفاده از مقصد';

  @override
  String get sessionEndOverlayTitle => 'جلسه پایان یابد؟';

  @override
  String get sessionEndOverlayBody => 'برای تأیید پایان جلسه بکشید';

  @override
  String get sessionEndOverlaySwipeLabel => 'برای پایان بکشید';

  @override
  String get sessionEndOverlaySimBadge => '[SIM] حالت تمرین';

  @override
  String get sessionEndPinPromptTitle => 'پین پایان جلسه را وارد کنید';

  @override
  String get sessionEndPinAppPinMismatch =>
      'از پین پایان جلسه استفاده کن، نه پین قفل برنامه.';

  @override
  String get sessionEndPinIncorrect => 'پین نادرست';

  @override
  String get sessionEndPinSimSkip => 'رد کردن (فقط شبیه‌سازی)';

  @override
  String get sessionEndSimDistressWouldFire =>
      'زنجیرهٔ اضطرار فعال می‌شد (۵ پین نادرست)';

  @override
  String get distressConfirmTitle => 'اضطرار فعال شد';

  @override
  String distressConfirmCountdown(int seconds) {
    return 'برای لغو بزنید — $seconds ثانیه فرصت دارید';
  }

  @override
  String get distressConfirmCancel => 'برای لغو بزنید';

  @override
  String get distressConfirmFooter =>
      'در صورت عدم لغو، زنجیرهٔ اضطرار بلافاصله آغاز می‌شود.';

  @override
  String get distressCancelPinPromptTitle => 'پین پایان جلسه را وارد کنید';

  @override
  String distressCancelPinTimeoutLabel(int seconds) {
    return '$seconds ثانیه باقی مانده';
  }

  @override
  String get distressCancelPinIncorrect => 'پین نادرست';

  @override
  String get distressCancelPinAppPinMismatch =>
      'از پین پایان جلسه استفاده کن، نه پین قفل برنامه.';

  @override
  String get distressCancelPinSimSkip => 'رد کردن (فقط شبیه‌سازی)';

  @override
  String get distressCancelSimDistressWouldFire =>
      'زنجیرهٔ اضطرار فعال می‌شد (۵ پین نادرست)';

  @override
  String get distressCancelPinBack => 'انصراف';

  @override
  String get simulationPinPromptTitle => 'پین را وارد کنید';

  @override
  String get simulationPinPromptBody =>
      'وارد کردن پین پایان جلسه را تمرین کنید';

  @override
  String get simulationPinPromptSkip => 'رد کردن';

  @override
  String get simulationPinIncorrect => 'پین نادرست';

  @override
  String simulationSummaryDuration(String duration) {
    return 'مدت: $duration';
  }

  @override
  String get simulationSummaryTimelineHeader => 'گاه‌شمار رویدادها';

  @override
  String get simulationSummaryShare => 'اشتراک‌گذاری';

  @override
  String simulationSummaryMissedEventsBadge(int count) {
    return 'از دست رفته: $count';
  }

  @override
  String simulationSummaryDistressBadge(int count) {
    return 'اضطرار: $count';
  }

  @override
  String simulationSummaryStepsFiredBadge(int count) {
    return 'گام‌های اجراشده: $count';
  }

  @override
  String get simulationSummaryShareSubject =>
      'خلاصهٔ شبیه‌سازی Guardian Angela';

  @override
  String get notificationsChannelAlarm => 'تشدید آژیر';

  @override
  String get notificationsChannelAlarmDescription =>
      'هشدارهای حیاتی که حالت مزاحم نشوید را دور می‌زنند';

  @override
  String get notificationsChannelReminder => 'یادآور استتاری';

  @override
  String get notificationsChannelReminderDescription =>
      'یادآورهای حضور در حین جلسهٔ فعال';

  @override
  String get notificationsChannelFakeCall => 'تماس ساختگی';

  @override
  String get notificationsChannelFakeCallDescription =>
      'اعلان‌های تمام‌صفحهٔ تماس ورودی';

  @override
  String get notificationsChannelEnabled => 'فعال';

  @override
  String get notificationsChannelDisabled => 'غیرفعال';

  @override
  String get notificationsChannelsHeader => 'کانال‌های اعلان';

  @override
  String get contactsImportFromDevice => 'وارد کردن از مخاطبین';

  @override
  String get contactsImportNotSupported => 'در این سیستم‌عامل در دسترس نیست';

  @override
  String get contactsImportPermissionDenied =>
      'دسترسی به مخاطبین رد شد. در تنظیمات سیستم فعال کنید.';

  @override
  String get contactsDeleteAllMenu => 'حذف همه';

  @override
  String get contactsDeleteAllConfirmTitle => 'همهٔ مخاطبین حذف شوند؟';

  @override
  String get contactsDeleteAllConfirmBody =>
      'این کار همهٔ مخاطبین اضطراری را حذف می‌کند. امکان بازگردانی وجود ندارد.';

  @override
  String get contactsDeleteAllTypeConfirmTitle => 'با تایپ کردن تأیید کنید';

  @override
  String get contactsDeleteAllTypeConfirmHint =>
      'برای ادامه DELETE ALL را تایپ کنید';

  @override
  String get contactsDeleteAllTypeConfirmSentinel => 'DELETE ALL';

  @override
  String get contactsDeleteAllConfirmButton => 'حذف همه';

  @override
  String get modesBuiltinBadge => 'داخلی';

  @override
  String get modesBuiltinNoDelete => 'حالت‌های داخلی قابل حذف نیستند';

  @override
  String get sessionCompletedSimulationBanner => 'شبیه‌سازی کامل شد';

  @override
  String get sessionCompletedViewEventLog => 'مشاهدهٔ گزارش رویدادها';

  @override
  String get settingsGeneralHeader => 'عمومی';

  @override
  String get settingsAppHeader => 'برنامه';

  @override
  String get settingsConfigurationHeader => 'پیکربندی';

  @override
  String get settingsThemeLabel => 'زمینه';

  @override
  String get settingsLanguageLabel => 'زبان';

  @override
  String get settingsSecurityRow => 'امنیت';

  @override
  String get settingsSecuritySubtitle =>
      'پین برنامه، پین پایان جلسه، پین اجبار';

  @override
  String get settingsStealthRow => 'حالت مخفی';

  @override
  String get settingsStealthSummaryOff => 'حالت مخفی: خاموش';

  @override
  String get settingsStealthSummaryOn => 'حالت مخفی: روشن';

  @override
  String get settingsProfileRow => 'پروفایل';

  @override
  String get settingsModesRow => 'حالت‌ها';

  @override
  String get settingsDistressModesRow => 'حالت‌های اضطرار';

  @override
  String get settingsEventDefaultsRow => 'پیش‌فرض‌های گام';

  @override
  String get settingsGpsLoggingRow => 'ثبت موقعیت GPS';

  @override
  String get settingsRemindersRow => 'الگوهای یادآور';

  @override
  String get settingsNotificationsRow => 'اعلان‌ها';

  @override
  String get settingsHistoryRetentionRow => 'تاریخچه و نگهداری';

  @override
  String get settingsAboutRow => 'درباره';

  @override
  String get settingsFeedbackRow => 'ارسال بازخورد';

  @override
  String get settingsBackupRow => 'پشتیبان‌گیری و بازیابی';

  @override
  String get settingsOssLicenses => 'مجوزهای متن‌باز';

  @override
  String get settingsImportConfirmBody =>
      'این کار همهٔ داده‌های کنونی را بازنویسی می‌کند. ادامه می‌دهید؟';

  @override
  String get securityAppPinTitle => 'پین برنامه';

  @override
  String get securityAppPinBody =>
      'هر بار که برنامه را باز می‌کنی، آن را قفل می‌کند.';

  @override
  String get securitySessionEndPinTitle => 'پین پایان جلسه';

  @override
  String get securitySessionEndPinBody =>
      'برای غیرفعال‌سازی یا پایان دادن به جلسهٔ در حال اجرا لازم است.';

  @override
  String get securityDuressPinTitle => 'پین اجبار';

  @override
  String get securityDuressPinBody =>
      'در هر اعلانی وارد شود تا زنجیرهٔ اضطرار را بی‌صدا فعال کند.';

  @override
  String get securityRemovePin => 'حذف';

  @override
  String get securityRemovePinPrompt => 'برای حذف، پین فعلی خود را وارد کنید.';

  @override
  String get securityRemovePinIncorrect => 'پین نادرست';

  @override
  String get securityWhatIsThis => 'این چیست؟';

  @override
  String get securityAppPinInfo =>
      'وقتی برنامه را باز می‌کنی آن را قفل می‌کند. صفحه‌کلید پیش از هر صفحه‌ای ظاهر می‌شود. زمانی مفید است که کسی برای لحظه‌ای گوشی باز تو را در دست بگیرد.';

  @override
  String get securitySessionEndPinInfo =>
      'برای غیرفعال‌سازی یا پایان دادن به یک جلسهٔ ایمنی در حال اجرا لازم است. بدون آن، مهاجمی که گوشی‌ات را بگیرد نمی‌تواند زنجیره را متوقف کند. کدی متفاوت از پین برنامه‌ات تعیین کن.';

  @override
  String get securityDuressPinInfo =>
      'اگر زمانی این پین را در هر اعلانی وارد کنی، زنجیرهٔ اضطرار بی‌صدا اجرا می‌شود — مخاطبانت آگاه می‌شوند و آژیر بدون آنکه مهاجم متوجه شود آماده می‌گردد. کدی متفاوت از هر پین دیگری انتخاب کن.';

  @override
  String get securityPinTimeoutLabel => 'مهلت پین (ثانیه)';

  @override
  String get securityWrongPinThresholdLabel => 'تعداد پین نادرست پیش از تشدید';

  @override
  String get securityDeceptiveDialogToggle =>
      'نمایش گفت‌وگوی فریبنده هنگام پین نادرست';

  @override
  String get pinSetupEnterNew => 'پین جدید را وارد کنید';

  @override
  String get pinSetupConfirmNew => 'پین جدید را تأیید کنید';

  @override
  String get pinSetupTooShort => 'پین باید حداقل ۴ رقم باشد.';

  @override
  String get pinSetupCollision =>
      'این پین با پین پیکربندی‌شدهٔ دیگری تداخل دارد.';

  @override
  String get pinSetupSaved => 'پین ذخیره شد';

  @override
  String get stealthEnabledLabel => 'فعال‌سازی حالت مخفی';

  @override
  String get stealthFakeNameLabel => 'نام ساختگی برنامه';

  @override
  String get stealthFakeIconLabel => 'آیکن ساختگی';

  @override
  String get stealthNotificationDisguiseLabel => 'استتار اعلان';

  @override
  String get stealthTimerDisplayLabel => 'نمایش تایمر';

  @override
  String get stealthSessionScreenLabel => 'حالت مخفی صفحهٔ جلسه';

  @override
  String get gpsLoggingEnabled => 'ثبت موقعیت GPS در حین جلسات';

  @override
  String get gpsLoggingIntervalLabel => 'بازه';

  @override
  String get gpsLoggingAccuracyLabel => 'دقت';

  @override
  String get gpsLoggingAccuracyHigh => 'بالا';

  @override
  String get gpsLoggingAccuracyBalanced => 'متعادل';

  @override
  String get gpsLoggingAccuracyLow => 'پایین';

  @override
  String get gpsLoggingFormatLabel => 'قالب مختصات';

  @override
  String get gpsLoggingFormatDecimal => 'اعشاری';

  @override
  String get gpsLoggingFormatDms => 'DMS';

  @override
  String get gpsLoggingFormatAddress => 'Plus Code';

  @override
  String get gpsLoggingIncludeInSms => 'افزودن موقعیت به پیامک';

  @override
  String get historyRetentionLogsLabel => 'مدت نگهداری گزارش جلسه (روز)';

  @override
  String get historyRetentionLogsHelper =>
      'گزارش‌های قدیمی‌تر از این به سطل زباله منتقل می‌شوند.';

  @override
  String get historyRetentionTrashLabel => 'مدت نگهداری سطل زباله (روز)';

  @override
  String get historyRetentionTrashHelper =>
      'گزارش‌های در سطل زباله پس از این بازه برای همیشه حذف می‌شوند.';

  @override
  String get historyRetentionUpdated => 'مدت نگهداری به‌روزرسانی شد';

  @override
  String get historyRetentionPurgeNow => 'اکنون پاک‌سازی کن';

  @override
  String historyRetentionPurged(Object count) {
    return '$count گزارش پاک‌سازی شد';
  }

  @override
  String get eventDefaultsCheckInHeader => 'روش‌های اعلام حضور';

  @override
  String get eventDefaultsEscalationHeader => 'گام‌های تشدید';

  @override
  String get eventDefaultsPanicHeader => 'محرک اضطرار';

  @override
  String get templatesCreate => 'ایجاد الگو';

  @override
  String get templatesEditTitle => 'ویرایش الگو';

  @override
  String get templatesCreateTitle => 'الگوی جدید';

  @override
  String get templatesNameLabel => 'نام';

  @override
  String get templatesTitleLabel => 'عنوان';

  @override
  String get templatesBodyLabel => 'متن';

  @override
  String get templatesBuiltinNoDelete => 'الگوهای داخلی قابل حذف نیستند';

  @override
  String get templatesAddFromTemplate => 'از روی الگو';

  @override
  String get templatesAddFromScratch => 'از صفر';

  @override
  String templatesDeleteConfirmTitle(Object name) {
    return '«$name» حذف شود؟';
  }

  @override
  String get templatesDeleteConfirmBody => 'این الگو برای همیشه حذف خواهد شد.';

  @override
  String get templatesEmptyAddFirst => 'اولین الگوی خود را اضافه کنید';

  @override
  String get templatesPickFromBuiltinTitle => 'یک الگوی داخلی انتخاب کنید';

  @override
  String get templatesIconLabel => 'آیکن';

  @override
  String get templatesIconCalendar => 'تقویم';

  @override
  String get templatesIconAppNotification => 'اعلان برنامه';

  @override
  String get templatesIconFitness => 'تناسب‌اندام';

  @override
  String get templatesIconHealth => 'سلامت';

  @override
  String get templatesIconFood => 'غذا';

  @override
  String get templatesIconCoffee => 'قهوه';

  @override
  String get templatesIconBattery => 'باتری';

  @override
  String get templatesIconWeather => 'آب‌وهوا';

  @override
  String get templatesPreviewHeading => 'پیش‌نمایش زنده';

  @override
  String get templatesDiscardChangesTitle => 'تغییرات حذف شود؟';

  @override
  String get templatesDiscardChangesBody =>
      'ویرایش‌های ذخیره‌نشده از بین می‌روند.';

  @override
  String get templatesDiscardKeep => 'ادامه ویرایش';

  @override
  String get templatesDiscardDiscard => 'حذف';

  @override
  String get notificationsTitle => 'اعلان‌ها';

  @override
  String get notificationsStatusGranted => 'اعطا شده';

  @override
  String get notificationsStatusDenied => 'رد شده';

  @override
  String get notificationsStatusUnknown => 'هنوز پرسیده نشده';

  @override
  String get notificationsRequest => 'درخواست دسترسی';

  @override
  String get notificationsOpenSettings => 'باز کردن تنظیمات سیستم';

  @override
  String get profileFieldPhone => 'شماره تلفن';

  @override
  String get profileFieldDescription => 'مشخصات ظاهری';

  @override
  String get profileFieldMedicalConditions => 'بیماری‌ها';

  @override
  String get profileFieldEmergencyInstructions => 'دستورالعمل‌های اضطراری';

  @override
  String get aboutAuthor => 'نویسنده: Jonas Eschle';

  @override
  String get aboutEmail => 'guardian.angela.app@gmail.com';

  @override
  String get aboutPrivacyPolicy => 'سیاست حریم خصوصی';

  @override
  String get aboutTermsOfService => 'شرایط استفاده از خدمات';

  @override
  String get aboutSourceCode => 'کد منبع';

  @override
  String get aboutSupport => 'حمایت / کمک مالی';

  @override
  String get aboutLicenses => 'مجوزهای متن‌باز';

  @override
  String get aboutTagline => 'با عشق برای ایمنی جامعهٔ LGBTQ+ ساخته شده است.';

  @override
  String get aboutTechnicalSection => 'اطلاعات فنی';

  @override
  String aboutBundleId(Object id) {
    return 'شناسهٔ بسته: $id';
  }

  @override
  String aboutPlatforms(Object list) {
    return 'سیستم‌عامل‌ها: $list';
  }

  @override
  String get feedbackHeading => 'خوشحال می‌شویم نظرت را بشنویم';

  @override
  String get feedbackCategoryLabel => 'دسته‌بندی';

  @override
  String get feedbackCategoryBug => 'گزارش اشکال';

  @override
  String get feedbackCategoryFeature => 'درخواست قابلیت';

  @override
  String get feedbackCategoryOther => 'سایر';

  @override
  String get feedbackEmailLabel => 'ایمیل (اختیاری)';

  @override
  String get feedbackMessageLabel => 'پیام';

  @override
  String get feedbackIncludeLog => 'افزودن گزارش آخرین جلسه';

  @override
  String get feedbackSent => 'از بازخوردت سپاسگزاریم!';

  @override
  String get feedbackMessageRequired => 'پیام باید حداقل ۱۰ نویسه باشد.';

  @override
  String get backupIncludeLogs => 'افزودن گزارش‌های جلسه';

  @override
  String get backupIncludeMedia => 'افزودن رسانه';

  @override
  String get backupExportButton => 'برون‌بری';

  @override
  String get backupImportButton => 'درون‌ریزی';

  @override
  String get backupOverwriteWarning =>
      'درون‌ریزی همهٔ داده‌های کنونی را بازنویسی می‌کند.';

  @override
  String get backupImportSuccess =>
      'درون‌ریزی کامل شد. برای اعمال، برنامه را دوباره راه‌اندازی کنید.';

  @override
  String backupImportError(Object message) {
    return 'درون‌ریزی ناموفق بود: $message';
  }

  @override
  String get backupActiveSessionBanner =>
      'پشتیبان‌گیری در حین جلسهٔ فعال در دسترس نیست.';

  @override
  String backupLastBackupAtLabel(Object when) {
    return 'آخرین پشتیبان‌گیری در $when';
  }

  @override
  String get backupNeverExportedLabel => 'هنوز پشتیبانی گرفته نشده است';

  @override
  String get pastEventsTitle => 'جلسات گذشته';

  @override
  String get pastEventsTabReal => 'واقعی';

  @override
  String get pastEventsTabSimulated => 'شبیه‌سازی‌شده';

  @override
  String get pastEventsEmpty => 'هنوز هیچ جلسه‌ای وجود ندارد';

  @override
  String get pastEventsDeleteConfirm => 'گزارش جلسه حذف شود؟';

  @override
  String get pastEventsDetailShareText => 'اشتراک‌گذاری به‌صورت متن';

  @override
  String get pastEventsDetailSharePdf => 'اشتراک‌گذاری به‌صورت PDF';

  @override
  String get pastEventsDetailDelete => 'حذف';

  @override
  String get pastEventsOutcomeCompleted => 'کامل شد';

  @override
  String get pastEventsOutcomeDistress => 'اضطرار';

  @override
  String get pastEventsOutcomeInterrupted => 'قطع شد';

  @override
  String get pastEventsTrash => 'سطل زباله';

  @override
  String get pastEventsUndo => 'بازگردانی';

  @override
  String get pastEventsSoftDeleted => 'به سطل زباله منتقل شد';

  @override
  String get pastEventsDetailTitle => 'گزارش جلسه';

  @override
  String get pastEventsDetailShare => 'اشتراک‌گذاری';

  @override
  String get contactUnsavedDiscardTitle => 'تغییرات ذخیره‌نشده حذف شوند؟';

  @override
  String get contactUnsavedDiscardKeep => 'ادامه ویرایش';

  @override
  String get contactUnsavedDiscardDiscard => 'حذف';

  @override
  String get modesDuplicate => 'تکثیر';

  @override
  String get modesDeleteConfirmTitle => 'حالت حذف شود؟';

  @override
  String modesDeleteConfirmBody(Object name) {
    return '$name برای همیشه حذف خواهد شد.';
  }

  @override
  String get modesDistressDefaultBadge => 'پیش‌فرض';

  @override
  String get modesDistressSetDefault => 'تنظیم به‌عنوان پیش‌فرض';

  @override
  String get modesDistressCantDeleteLast => 'حداقل یک حالت اضطرار لازم است.';

  @override
  String get modesDistressInUse =>
      'این حالت اضطرار توسط حالت دیگری در حال استفاده است.';

  @override
  String get modesDistressTitle => 'حالت‌های اضطرار';

  @override
  String get validationNameTooShort => 'نام باید حداقل ۲ نویسه باشد.';

  @override
  String get validationPhoneRequired => 'شماره تلفن الزامی است.';

  @override
  String get validationChannelsRequired => 'حداقل یک کانال انتخاب کنید.';

  @override
  String get sessionHoldTouchToBegin => 'برای شروع لمس کنید';

  @override
  String sessionHoldReleaseCountdown(Object seconds) {
    return 'شمارش معکوس: $seconds ثانیه';
  }

  @override
  String sessionHoldGraceCountdown(Object seconds) {
    return 'مهلت: $seconds ثانیه — برای حفظ ایمنی دوباره نگه دار';
  }

  @override
  String get sessionHoldAgain => 'برای حفظ ایمنی دوباره نگه دار';

  @override
  String sessionStepNextCheckIn(Object time) {
    return 'اعلام حضور بعدی تا $time';
  }

  @override
  String sessionStepFakeCallActive(Object caller) {
    return 'تماس ورودی از $caller';
  }

  @override
  String get sessionStepFakeCallOpen => 'باز کردن صفحهٔ تماس';

  @override
  String sessionStepSimBlockedSms(Object count) {
    return '[SIM] به $count مخاطب پیامک ارسال می‌شد';
  }

  @override
  String get sessionStepSimBlockedPhone =>
      '[SIM] با مخاطب اضطراری تماس گرفته می‌شد';

  @override
  String get sessionStepSimBlockedEmergency =>
      '[SIM] با خدمات اضطراری تماس گرفته می‌شد';

  @override
  String get sessionStepSimBlockedAlarm =>
      '[SIM] آژیر با حداکثر صدا به صدا درمی‌آمد';

  @override
  String get sessionStartFailedTitle => 'شروع جلسه ممکن نیست';

  @override
  String get sessionStartFailedBody => 'پیش از شروع، مشکلات زیر را برطرف کنید:';

  @override
  String get sessionQuickExitTitle => 'خروج سریع';

  @override
  String get sessionQuickExitBody =>
      'داده‌های جلسه حفظ و رمزگذاری می‌شوند. برای بازیابی هر زمان برنامه را دوباره باز کن.';

  @override
  String get sessionQuickExitConfirm => 'خروج از برنامه';

  @override
  String get pastEventsRestore => 'بازگردانی';

  @override
  String get stepEditorWait => 'انتظار (ث)';

  @override
  String get stepEditorDuration => 'مدت (ث)';

  @override
  String get stepEditorGrace => 'مهلت (ث)';

  @override
  String get stepEditorRetryCount => 'تعداد تلاش مجدد';

  @override
  String get stepEditorRandomize => 'زمان‌بندی تصادفی (±۲۰٪)';

  @override
  String get stepEditorRemove => 'حذف گام';

  @override
  String get eventDefaultsHoldStyle => 'سبک نگه‌داشتن';

  @override
  String get eventDefaultsHoldSensitivity => 'حساسیت رهاسازی';

  @override
  String get eventDefaultsHoldVibrate => 'لرزش هنگام رهاسازی';

  @override
  String get eventDefaultsHoldSound => 'صدا هنگام رهاسازی';

  @override
  String get eventDefaultsBlackScreen => 'پوشش صفحهٔ سیاه';

  @override
  String get eventDefaultsReminderRandomInterval => 'تصادفی‌سازی بازه';

  @override
  String get eventDefaultsReminderRandomTemplate => 'تصادفی‌سازی ترتیب الگوها';

  @override
  String get eventDefaultsReminderResetOnEarly =>
      'بازنشانی هنگام اعلام حضور زودهنگام';

  @override
  String get eventDefaultsCountdownStyle => 'سبک شمارش معکوس';

  @override
  String get eventDefaultsCountdownVibrate => 'لرزش';

  @override
  String get eventDefaultsCountdownSound => 'صدا';

  @override
  String get eventDefaultsFakeCallStyle => 'سبک تماس';

  @override
  String get eventDefaultsFakeCallCallerName => 'نام تماس‌گیرنده';

  @override
  String get eventDefaultsFakeCallRingDuration => 'مدت زنگ (ث)';

  @override
  String get eventDefaultsFakeCallDeclineIsSafe =>
      'رد تماس به‌منزلهٔ ایمن بودن است';

  @override
  String get eventDefaultsFakeCallVoiceOutput => 'خروجی صوتی';

  @override
  String get eventDefaultsSmsChannel => 'کانال';

  @override
  String get eventDefaultsSmsIncludeLocation => 'افزودن موقعیت';

  @override
  String get eventDefaultsSmsIncludeMedical => 'افزودن اطلاعات پزشکی';

  @override
  String get eventDefaultsSmsAutoRecord => 'ضبط صدا پیش از ارسال';

  @override
  String get eventDefaultsSmsRecordDuration => 'مدت ضبط (ث)';

  @override
  String get eventDefaultsLoudAlarmVolume => 'بلندی صدا';

  @override
  String get eventDefaultsLoudAlarmSound => 'صدا';

  @override
  String get eventDefaultsLoudAlarmFlashScreen => 'چشمک‌زدن صفحه';

  @override
  String get eventDefaultsLoudAlarmFlashLight => 'چشمک‌زدن نور دوربین';

  @override
  String get eventDefaultsLoudAlarmGradual => 'افزایش تدریجی صدا';

  @override
  String get eventDefaultsCallEmergencyNumber => 'شماره اضطراری (جایگزین)';

  @override
  String get eventDefaultsCallEmergencyConfirm => 'نمایش شمارش معکوس تأیید';

  @override
  String get eventDefaultsCallEmergencyConfirmDuration => 'ثانیه‌های تأیید';

  @override
  String get eventDefaultsCallEmergencySmsFirst =>
      'ارسال پیامک موقعیت در ابتدا';

  @override
  String get eventDefaultsPhonePrimaryContact => 'مخاطب اصلی (شناسه)';

  @override
  String get eventDefaultsHardwareButton => 'دکمه';

  @override
  String get eventDefaultsHardwarePattern => 'الگوی فشار';

  @override
  String get eventDefaultsHardwarePressCount => 'تعداد فشار';

  @override
  String get eventDefaultsHardwareLongDuration => 'مدت فشار طولانی (ث)';

  @override
  String get pastEventsTrashTitle => 'سطل زباله';

  @override
  String get pastEventsTrashEmpty => 'سطل زباله خالی است';

  @override
  String get pastEventsTrashEmptyAll => 'خالی کردن سطل زباله';

  @override
  String get pastEventsTrashEmptyAllConfirmTitle => 'سطل زباله خالی شود؟';

  @override
  String get pastEventsTrashEmptyAllConfirmBody =>
      'برای تأیید، EMPTY TRASH را در پایین تایپ کنید. این کار همهٔ گزارش‌های موجود در سطل زباله را برای همیشه حذف می‌کند.';

  @override
  String pastEventsTrashEmptyAllSuccess(Object count) {
    return 'سطل زباله خالی شد ($count گزارش)';
  }

  @override
  String pastEventsTrashRetentionNote(int days) {
    return 'گزارش‌های موجود در سطل زباله پس از $days روز برای همیشه حذف می‌شوند.';
  }

  @override
  String pastEventsTrashRemainingDays(int days) {
    return '$days روز تا حذف دائمی';
  }

  @override
  String get pastEventsTrashDeletePermanently => 'حذف دائمی';

  @override
  String get pastEventsTrashDeletePermanentlyBody =>
      'این کار قابل بازگشت نیست.';

  @override
  String sessionEmergencyConfirmTitle(String number, int seconds) {
    return 'تماس با $number تا $seconds ثانیه';
  }

  @override
  String get sessionEmergencyConfirmSwipe => 'برای لغو بکشید';

  @override
  String get sessionEmergencyConfirmKeep => 'ادامهٔ تماس';

  @override
  String get sessionEmergencyConfirmSimBadge => '[SIM] حالت تمرین';

  @override
  String get sessionEmergencyConfirmSimCancelled =>
      'لغو شبیه‌سازی‌شده — تماسی برقرار نمی‌شد';

  @override
  String get swipeSliderSemantics => 'برای تأیید بکشید';

  @override
  String get homeWidgetStatusIdle => 'آماده‌به‌کار';

  @override
  String get homeWidgetStatusSession => 'جلسه فعال';

  @override
  String get homeWidgetStatusSim => 'شبیه‌سازی فعال';

  @override
  String get homeWidgetQuickExit => 'خروج سریع';

  @override
  String get homeWidgetFakeCall => 'تماس ساختگی';
}
