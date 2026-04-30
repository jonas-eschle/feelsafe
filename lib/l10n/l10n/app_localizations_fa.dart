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
  String get angelaDialogTitle => 'Old PIN entered';

  @override
  String get angelaDialogBody =>
      'It looks like you used an old PIN. Are you sure you want to proceed?';

  @override
  String get angelaDialogCancel => 'Cancel';

  @override
  String get angelaDialogConfirm => 'Continue';

  @override
  String get commonCancel => 'انصراف';

  @override
  String get commonOk => 'OK';

  @override
  String get profileAngelaWarningTitle => 'Heads up about the name \"Angela\"';

  @override
  String get profileAngelaWarningBody =>
      'Guardian Angela uses \"Angela\" as a safety keyword. Using it as your own name could be confusing. Save anyway?';

  @override
  String get commonDelete => 'حذف';

  @override
  String get commonEdit => 'ویرایش';

  @override
  String get commonAdd => 'افزودن';

  @override
  String get commonClose => 'بستن';

  @override
  String get commonConfirm => 'تأیید';

  @override
  String get commonBack => 'بازگشت';

  @override
  String get commonDone => 'انجام شد';

  @override
  String get commonRetry => 'تلاش دوباره';

  @override
  String get commonYes => 'بله';

  @override
  String get commonNo => 'خیر';

  @override
  String get commonEnabled => 'فعال';

  @override
  String get commonDisabled => 'غیرفعال';

  @override
  String get commonNone => 'هیچ‌کدام';

  @override
  String get commonSeconds => 'ثانیه';

  @override
  String get commonMinutes => 'دقیقه';

  @override
  String get cancel => 'انصراف';

  @override
  String get pinSubmit => 'Submit';

  @override
  String get homeTitle => 'Guardian Angela';

  @override
  String get homeStartSession => 'شروع جلسه';

  @override
  String get homeStartConfirmTitle => 'Start a session?';

  @override
  String get homeStartConfirmBody =>
      'Make sure your contacts and PIN are configured. The session will run in the foreground and your selected mode will guide check-ins.';

  @override
  String get homeSimulate => 'شبیه‌سازی';

  @override
  String get homeActiveSession => 'جلسه فعال';

  @override
  String get homeResumeSession => 'ادامه';

  @override
  String get homeNoModes =>
      'هنوز هیچ حالتی وجود ندارد. برای افزودن، روی حالت‌ها بزنید.';

  @override
  String get homeNoContacts =>
      'هنوز هیچ مخاطب اضطراری وجود ندارد. برای افزودن، روی مخاطبین بزنید.';

  @override
  String get homeContactsBannerNone => 'No emergency contacts configured.';

  @override
  String homeContactsBannerFew(int count) {
    return '$count contact(s) configured. We recommend at least 3.';
  }

  @override
  String get homeMenuSettings => 'تنظیمات';

  @override
  String get homeMenuContacts => 'مخاطبین';

  @override
  String get homeMenuModes => 'حالت‌ها';

  @override
  String get homeMenuHistory => 'جلسات گذشته';

  @override
  String get homeSelectMode => 'انتخاب حالت';

  @override
  String get onboardingWelcomeTitle => 'به Guardian Angela خوش آمدید';

  @override
  String get onboardingWelcomeBody =>
      'همراهی که در مسیر خانه از شما مراقبت می‌کند. Guardian Angela هنگام پیاده‌روی، دویدن یا سفر مراقب شماست و در صورت نیاز به کمک می‌تواند به مخاطبین منتخب شما هشدار دهد.';

  @override
  String get onboardingProfileTitle => 'پروفایل و اولین مخاطب';

  @override
  String get onboardingProfileBody =>
      'کمی درباره خود به ما بگویید تا Guardian Angela بتواند در صورت نیاز به کمک اضطراری، اطلاعات مفیدی را به اشتراک بگذارد. سپس یک مخاطب مورد اعتماد اضافه کنید.';

  @override
  String get onboardingPermissionsTitle => 'دسترسی‌ها';

  @override
  String get onboardingPermissionsBody =>
      'Guardian Angela برای حفظ ایمنی شما به چند دسترسی نیاز دارد. همین حالا یا بعداً از تنظیمات اعطا کنید.';

  @override
  String get onboardingNext => 'بعدی';

  @override
  String get onboardingSkip => 'رد کردن';

  @override
  String get onboardingFinish => 'پایان';

  @override
  String get sessionTitle => 'جلسه';

  @override
  String get sessionDisarm => 'من در امانم';

  @override
  String get sessionPause => 'توقف';

  @override
  String get sessionResume => 'ادامه';

  @override
  String get sessionHoldPrompt => 'برای حفظ ایمنی نگه دارید';

  @override
  String get sessionHoldSemantic =>
      'انگشت خود را نگه دارید. برداشتن انگشت، دوره مهلت را آغاز می‌کند.';

  @override
  String sessionStepLabel(Object index, Object total) {
    return 'گام $index از $total';
  }

  @override
  String sessionMissCount(Object count) {
    return 'از دست رفته: $count';
  }

  @override
  String sessionRemaining(Object seconds) {
    return '$seconds ثانیه باقی‌مانده';
  }

  @override
  String get sessionPausedBadge => 'متوقف شده';

  @override
  String get sessionPhaseEnded => 'جلسه پایان یافت';

  @override
  String get sessionSimulationBanner => 'شبیه‌سازی';

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
  String get fakeCallAnswer => 'پاسخ';

  @override
  String get fakeCallDecline => 'رد کردن';

  @override
  String get fakeCallHangUp => 'قطع تماس';

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
  String get contactLanguageDefault => 'Default (use app language)';

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
  String get contactRequiredError => 'نام و شماره تلفن الزامی است.';

  @override
  String get modesTitle => 'حالت‌ها';

  @override
  String get modesEmpty =>
      'هنوز هیچ حالتی وجود ندارد. برای ایجاد حالت، روی افزودن بزنید.';

  @override
  String get modesAdd => 'افزودن حالت';

  @override
  String get modeEditorTitleCreate => 'حالت جدید';

  @override
  String get modeEditorTitleEdit => 'ویرایش حالت';

  @override
  String get modeFieldName => 'نام';

  @override
  String get modeFieldCheckInType => 'نوع گزارش وضعیت';

  @override
  String get modeFieldDistressChain => 'حالت اضطرار';

  @override
  String get modeFieldDistressChainDefault => 'استفاده از پیش‌فرض';

  @override
  String get modeChainHeader => 'زنجیره تشدید';

  @override
  String get modeChainAddStep => 'افزودن گام';

  @override
  String get modeChainEmpty =>
      'هنوز هیچ گامی وجود ندارد. روی افزودن گام بزنید.';

  @override
  String get modeFieldIcon => 'آیکون';

  @override
  String get modeIconPickerTitle => 'انتخاب آیکون';

  @override
  String get modeIconClear => 'بدون آیکون';

  @override
  String get modeDistressHeader => 'محرک‌های اضطرار';

  @override
  String get modeDistressEmpty => 'محرک اضطراری تنظیم نشده است.';

  @override
  String get modeDistressAdd => 'افزودن محرک';

  @override
  String get modeDistressTypeHardware => 'دکمه سخت‌افزاری';

  @override
  String get modeDistressButtonType => 'دکمه';

  @override
  String get modeDistressButtonVolumeUp => 'افزایش صدا';

  @override
  String get modeDistressButtonVolumeDown => 'کاهش صدا';

  @override
  String get modeDistressButtonPower => 'روشن/خاموش';

  @override
  String get modeDistressPattern => 'الگو';

  @override
  String get modeDistressPatternRepeat => 'فشار مکرر';

  @override
  String get modeDistressPatternLong => 'فشار طولانی';

  @override
  String get modeDistressPressCount => 'تعداد فشار';

  @override
  String get modeDistressPressWindow => 'بازه (میلی‌ثانیه)';

  @override
  String get modeDistressLongDuration => 'مدت نگه‌داشتن (ثانیه)';

  @override
  String modeDistressSummaryRepeat(Object count, Object windowMs) {
    return '$count بار / $windowMs میلی‌ثانیه';
  }

  @override
  String modeDistressSummaryLong(Object seconds) {
    return 'نگه‌داشتن $seconds ثانیه';
  }

  @override
  String get modeOverridesHeader => 'بازنویسی‌های حالت';

  @override
  String get modeOverridesUseDefault => 'استفاده از پیش‌فرض برنامه';

  @override
  String get modeOverridesGpsLabel => 'ثبت GPS';

  @override
  String get modeOverridesStealthLabel => 'حالت مخفی';

  @override
  String get modeOverridesEventDefaultsLabel => 'پیش‌فرض‌های رویداد';

  @override
  String get modeOverridesLocalTemplatesLabel => 'قالب‌های یادآور محلی';

  @override
  String get modeOverridesGpsEnabled => 'GPS فعال';

  @override
  String get modeOverridesGpsIntervalLabel => 'بازه نمونه‌گیری (ثانیه)';

  @override
  String get modeOverridesGpsIncludeInSms => 'افزودن مکان به پیامک';

  @override
  String get modeOverridesStealthEnabled => 'حالت مخفی فعال';

  @override
  String get modeOverridesStealthFakeName => 'نام جعلی برنامه';

  @override
  String get modeOverridesEventDefaultsHint =>
      'پیش‌فرض‌های سفارشی برای این حالت فعال است.';

  @override
  String modeOverridesLocalTemplatesCount(Object count) {
    return '$count قالب محلی';
  }

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
  String get stepDuplicate => 'تکثیر گام';

  @override
  String get stepTimingHeader => 'زمان‌بندی';

  @override
  String stepTimingSummary(Object wait, Object duration, Object grace) {
    return 'انتظار $waitث / مدت $durationث / مهلت $graceث';
  }

  @override
  String get stepCategoryAll => 'همه';

  @override
  String get stepCategoryAction => 'کنش';

  @override
  String get stepCategoryReminder => 'یادآور';

  @override
  String get stepCategoryDisarm => 'ثبت ورود';

  @override
  String get modeTrackingHeader => 'ردیابی GPS';

  @override
  String get modeTrackingEnabled => 'ضبط GPS در طول جلسه';

  @override
  String get modeTrackingIntervalLabel => 'فاصله نمونه‌برداری';

  @override
  String get modeTrackingBufferSizeLabel => 'اندازه بافر';

  @override
  String modeTrackingBufferSizeValue(Object count) {
    return '$count نقطه';
  }

  @override
  String get modeTrackingBatteryNote =>
      'ردیابی مکرر GPS باعث افزایش مصرف باتری می‌شود.';

  @override
  String get stepConfigLogGpsLabel => 'ثبت GPS';

  @override
  String get stepConfigLogGpsDefault => 'پیش‌فرض';

  @override
  String get stepConfigLogGpsOn => 'روشن';

  @override
  String get stepConfigLogGpsOff => 'خاموش';

  @override
  String get stepConfigLogGpsDefaultOn => 'پیش‌فرض (روشن)';

  @override
  String get stepConfigLogGpsDefaultOff => 'پیش‌فرض (خاموش)';

  @override
  String get moreSettingsHeader => 'تنظیمات بیشتر';

  @override
  String moreSettingsHeaderCustomized(int count) {
    return 'تنظیمات بیشتر ($count مورد سفارشی)';
  }

  @override
  String get stepTypePickerLabel => 'Step type';

  @override
  String get stepTypeHoldButton => 'دکمه نگه‌داشتن';

  @override
  String get stepTypeDisguisedReminder => 'یادآور پنهان';

  @override
  String get stepTypeCountdownWarning => 'هشدار شمارش معکوس';

  @override
  String get stepTypeFakeCall => 'تماس ساختگی';

  @override
  String get stepTypeSmsContact => 'پیامک به مخاطب';

  @override
  String get stepTypePhoneCallContact => 'تماس با مخاطب';

  @override
  String get stepTypeLoudAlarm => 'آژیر بلند';

  @override
  String get stepTypeCallEmergency => 'تماس اضطراری';

  @override
  String get stepTypeHardwareButton => 'دکمه سخت‌افزاری';

  @override
  String get stepFieldDuration => 'مدت‌زمان (ثانیه)';

  @override
  String get stepFieldGrace => 'دوره مهلت (ثانیه)';

  @override
  String get stepFieldWait => 'انتظار (ثانیه)';

  @override
  String get stepFieldRetryCount => 'تلاش‌های مجدد';

  @override
  String get stepFieldRandomize => 'پراکندگی زمانی';

  @override
  String get stepPreview => 'پیش‌نمایش در شبیه‌سازی';

  @override
  String stepPreviewFired(Object description) {
    return 'پیش‌نمایش اجرا شد: $description';
  }

  @override
  String get stepConfigFakeCallCaller => 'نام تماس‌گیرنده';

  @override
  String get stepConfigFakeCallDecline => 'رد تماس به معنی لغو آماده‌باش است';

  @override
  String get stepConfigLoudAlarmFlash => 'چشمک زدن صفحه';

  @override
  String get stepConfigLoudAlarmVolume => 'حداکثر صدا';

  @override
  String get stepConfigCountdownVibrate => 'ویبره';

  @override
  String get stepConfigCountdownTone => 'پخش صدا';

  @override
  String get stepConfigSmsSelection => 'گیرندگان';

  @override
  String get stepConfigSmsAllContacts => 'همه مخاطبین';

  @override
  String get stepConfigSmsSpecific => 'مخاطبین خاص';

  @override
  String get stepConfigSmsIncludeLocation => 'شامل موقعیت مکانی';

  @override
  String get stepConfigSmsIncludeMedical => 'شامل اطلاعات پزشکی';

  @override
  String get stepConfigHoldReleaseSensitivity => 'حساسیت رها کردن (ث)';

  @override
  String get stepConfigReminderInterval => 'فاصله یادآور (ثانیه)';

  @override
  String get stepConfigReminderTemplate => 'الگو';

  @override
  String get stepConfigHardwarePattern => 'الگو';

  @override
  String get stepConfigHardwarePressCount => 'تعداد فشار';

  @override
  String get stepConfigHardwareButton => 'دکمه';

  @override
  String get stepConfigHardwareButtonVolumeUp => 'افزایش صدا';

  @override
  String get stepConfigHardwareButtonVolumeDown => 'کاهش صدا';

  @override
  String get stepConfigHardwareButtonPower => 'روشن/خاموش';

  @override
  String get stepConfigHardwarePatternRepeat => 'فشار پیاپی';

  @override
  String get stepConfigHardwarePatternLong => 'فشار طولانی';

  @override
  String get stepConfigEmergencyNumber => 'جایگزینی شماره اضطراری';

  @override
  String get stepConfigEmergencyConfirm => 'تأیید پیش از تماس';

  @override
  String get stepConfigPhonePreSms => 'ارسال پیامک پیش از تماس';

  @override
  String get distressModesTitle => 'حالت‌های اضطرار';

  @override
  String get distressModeInUseTitle => 'حالت اضطرار در حال استفاده است';

  @override
  String distressModeInUseBody(Object modes) {
    return 'این حالت اضطرار هنوز به این حالت‌ها متصل است: $modes. پیش از حذف، آن حالت‌ها را به حالت اضطرار دیگری متصل کنید.';
  }

  @override
  String get distressModesEmpty => 'هنوز هیچ حالت اضطراری وجود ندارد.';

  @override
  String get distressModesAdd => 'افزودن حالت اضطرار';

  @override
  String get distressModeEditorTitleCreate => 'حالت اضطرار جدید';

  @override
  String get distressModeEditorTitleEdit => 'ویرایش حالت اضطرار';

  @override
  String get distressModeName => 'نام حالت اضطرار';

  @override
  String get distressCountdown => 'در حال فعال‌سازی حالت اضطرار...';

  @override
  String get distressCountdownStealth => 'لطفاً منتظر بمانید...';

  @override
  String get templatesTitle => 'الگوهای یادآور';

  @override
  String get templatesEmpty => 'هنوز هیچ الگویی وجود ندارد.';

  @override
  String get templatesAdd => 'افزودن الگو';

  @override
  String get templateEditorTitleCreate => 'الگوی جدید';

  @override
  String get templateEditorTitleEdit => 'ویرایش الگو';

  @override
  String get templateFieldName => 'نام در ویرایشگر';

  @override
  String get templateFieldTitle => 'عنوان یادآور';

  @override
  String get templateFieldBody => 'متن یادآور';

  @override
  String get templateFieldConfirmationType => 'نوع تأیید';

  @override
  String get templateFieldKeyword => 'واژه کلیدی';

  @override
  String get templateFieldButtonLabel => 'برچسب دکمه';

  @override
  String get templateFieldDisplayStyle => 'سبک نمایش';

  @override
  String get templateConfirmTapButton => 'ضربه روی دکمه';

  @override
  String get templateConfirmTapWord => 'ضربه روی واژه';

  @override
  String get templateConfirmSwipe => 'کشیدن';

  @override
  String get templateConfirmDismiss => 'نادیده گرفتن';

  @override
  String get templateDisplayFullscreen => 'تمام‌صفحه';

  @override
  String get templateDisplaySubtle => 'ظریف';

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
  String get profileFieldConditions => 'بیماری‌ها';

  @override
  String get profileFieldInstructions => 'دستورالعمل‌های اضطراری';

  @override
  String get profileAddItem => 'افزودن مورد';

  @override
  String get settingsTitle => 'تنظیمات';

  @override
  String get settingsSectionSecurity => 'امنیت';

  @override
  String get settingsSectionStealth => 'حالت مخفی';

  @override
  String get settingsSectionDefaults => 'پیش‌فرض‌ها';

  @override
  String get settingsSectionHistory => 'تاریخچه';

  @override
  String get settingsSectionBackup => 'پشتیبان‌گیری';

  @override
  String get settingsSectionAbout => 'درباره';

  @override
  String get settingsSectionFeedback => 'بازخورد';

  @override
  String get settingsSectionContacts => 'مخاطبین';

  @override
  String get settingsSectionModes => 'حالت‌ها';

  @override
  String get settingsSectionProfile => 'پروفایل';

  @override
  String get settingsSectionDistressModes => 'حالت‌های اضطرار';

  @override
  String get settingsSectionReminderTemplates => 'الگوهای یادآور';

  @override
  String get settingsSectionBatteryAlert => 'هشدار باتری';

  @override
  String get settingsSectionEventDefaults => 'پیش‌فرض‌های گام';

  @override
  String get settingsSectionGpsLogging => 'ثبت GPS';

  @override
  String get settingsSectionNotifications => 'اعلان‌ها';

  @override
  String get settingsSectionHistoryRetention => 'نگهداری تاریخچه';

  @override
  String get settingsSectionAppearance => 'ظاهر';

  @override
  String get settingsThemeMode => 'تم';

  @override
  String get settingsThemeLight => 'روشن';

  @override
  String get settingsThemeDark => 'تیره';

  @override
  String get settingsThemeSystem => 'سیستم';

  @override
  String get settingsLanguage => 'زبان';

  @override
  String get settingsEmergencyNumber => 'شماره اضطراری';

  @override
  String get settingsAlarmDnd => 'آژیر، حالت مزاحم نشوید را نادیده می‌گیرد';

  @override
  String get securityTitle => 'امنیت';

  @override
  String get securityAppPin => 'پین برنامه';

  @override
  String get securitySessionEndPin => 'پین پایان جلسه';

  @override
  String get securityDuressPin => 'پین اجباری';

  @override
  String get securityAppPinBiometric => 'Use biometrics for App PIN';

  @override
  String get securitySessionEndPinBiometric =>
      'Use biometrics for Session-end PIN';

  @override
  String get securityDistressCancelBiometric =>
      'Use biometrics to cancel distress';

  @override
  String get securityDuressTest => 'Test duress PIN';

  @override
  String get securityDuressTestSubtitle => 'Verify your duress PIN works.';

  @override
  String get securityPinTimeout => 'مهلت پین (ثانیه)';

  @override
  String get securityDisablePin => 'غیرفعال کردن';

  @override
  String get securitySetPin => 'تنظیم پین';

  @override
  String get securityChangePin => 'تغییر پین';

  @override
  String get pinSetupTitle => 'تنظیم پین';

  @override
  String get pinSetupEnter => 'پین جدید را وارد کنید';

  @override
  String get pinSetupConfirm => 'پین را تأیید کنید';

  @override
  String get pinSetupMismatch => 'پین‌ها مطابقت ندارند. دوباره تلاش کنید.';

  @override
  String get pinEntryTitle => 'وارد کردن پین';

  @override
  String get pinEntrySubtitle => 'برای ادامه، پین خود را وارد کنید.';

  @override
  String get pinEntryBiometricReason => 'Authenticate to continue';

  @override
  String get stealthTitle => 'حالت مخفی';

  @override
  String get stealthEnable => 'فعال‌سازی حالت مخفی';

  @override
  String get stealthFakeName => 'نام ساختگی برنامه';

  @override
  String get stealthFakeIcon => 'آیکون ساختگی';

  @override
  String get stealthNotificationDisguise => 'پنهان‌سازی اعلان‌ها';

  @override
  String get stealthTimerDisplay => 'نمایش تایمر در حالت مخفی';

  @override
  String get stealthTimerDisplayNormal => 'Show full text';

  @override
  String get stealthTimerDisplaySmall => 'Show numbers only';

  @override
  String get stealthTimerDisplayNone => 'Hide timer';

  @override
  String get stealthSessionScreen => 'حذف نشانه‌ها در صفحه جلسه';

  @override
  String get stealthPickerTitle => 'آیکون برنامه';

  @override
  String get stealthPickerIntro => 'ظاهر آیکون در صفحه اصلی را انتخاب کنید.';

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
  String get distressConfirmationTitle => 'آیا در خطر هستید؟';

  @override
  String get distressConfirmationCancel => 'انصراف';

  @override
  String distressConfirmationCountdown(Object seconds) {
    return 'حالت اضطراری در $seconds ثانیه آغاز می‌شود';
  }

  @override
  String get imSafeSliderLabel => 'برای تأیید «من در امانم» بکشید';

  @override
  String get batteryAlertTitle => 'هشدار باتری';

  @override
  String get batteryAlertEnable => 'فعال‌سازی هشدار باتری';

  @override
  String batteryAlertThreshold(Object percent) {
    return 'آستانه: $percent٪';
  }

  @override
  String get eventDefaultsTitle => 'پیش‌فرض‌های گام';

  @override
  String get eventDefaultsBody =>
      'این پیش‌فرض‌ها برای هر گامی که آن‌ها را بازنویسی نکند، اعمال می‌شوند.';

  @override
  String get gpsLoggingTitle => 'ثبت GPS';

  @override
  String get gpsLoggingEnable => 'فعال‌سازی ثبت GPS';

  @override
  String get gpsLoggingInterval => 'فاصله نمونه‌برداری (ثانیه)';

  @override
  String get gpsLoggingAccuracy => 'دقت';

  @override
  String get gpsAccuracyLow => 'کم';

  @override
  String get gpsAccuracyMedium => 'متوسط';

  @override
  String get gpsAccuracyHigh => 'زیاد';

  @override
  String get gpsLoggingIncludeSms => 'پیوست موقعیت به پیامک';

  @override
  String get gpsLoggingHistoryDays => 'نگهداری تاریخچه (روز)';

  @override
  String get notificationSettingsTitle => 'اعلان‌ها';

  @override
  String get notificationSettingsBody =>
      'Guardian Angela از اعلان‌ها برای پنهان‌سازی و اجرای یادآورها استفاده می‌کند.';

  @override
  String get historyRetentionTitle => 'نگهداری تاریخچه';

  @override
  String get historyRetentionBody =>
      'مدت زمانی که Guardian Angela گزارش جلسات گذشته را نگه می‌دارد.';

  @override
  String historyRetentionDays(Object days) {
    return 'نگهداری: $days روز';
  }

  @override
  String get backupTitle => 'پشتیبان‌گیری';

  @override
  String get backupExport => 'خروجی گرفتن از داده‌ها';

  @override
  String get backupImport => 'وارد کردن داده‌ها';

  @override
  String get backupNotReady =>
      'پشتیبان‌گیری هنوز در دسترس نیست. به‌زودی اضافه می‌شود.';

  @override
  String get backupPinOptional => 'رمز اختیاری (بسته را رمزگذاری می‌کند)';

  @override
  String get backupImportOk => 'پشتیبان با موفقیت وارد شد.';

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
  String get historyTitle => 'جلسات گذشته';

  @override
  String get historyEmpty => 'هنوز هیچ جلسه گذشته‌ای وجود ندارد.';

  @override
  String get historySearchHint => 'Search by mode name';

  @override
  String get historyFilterModeAll => 'All modes';

  @override
  String get historyFilterModeLabel => 'Mode';

  @override
  String get historyDateRangePick => 'Date range';

  @override
  String get historyDetailTitle => 'جزئیات جلسه';

  @override
  String get evidenceExportTitle => 'خروجی گرفتن از شواهد';

  @override
  String get evidenceExportAsText => 'کپی به‌صورت متن';

  @override
  String get evidenceExportAsJson => 'کپی به‌صورت JSON';

  @override
  String get evidenceCopied => 'در کلیپ‌بورد کپی شد.';

  @override
  String get aboutTitle => 'درباره';

  @override
  String get aboutVersion => 'نسخه';

  @override
  String get aboutCredits =>
      'با دقت برای کسانی ساخته شده که در مسیر خانه هستند.';

  @override
  String get feedbackTitle => 'بازخورد';

  @override
  String get feedbackBody => 'ما خوشحال می‌شویم نظر شما را بشنویم.';

  @override
  String get feedbackFieldMessage => 'پیام';

  @override
  String get feedbackSend => 'باز کردن ایمیل';

  @override
  String get pickerNoneLabel => '— هیچ‌کدام —';

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
  String get sessionSimSpeedBackgroundCap => 'Capped at 60× in background';

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
