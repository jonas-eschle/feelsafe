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
  String get commonCancel => 'انصراف';

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
  String get homeTitle => 'Guardian Angela';

  @override
  String get homeStartSession => 'شروع جلسه';

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
  String get modeFieldDistressChain => 'زنجیره اضطرار';

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
  String get distressChainsTitle => 'زنجیره‌های اضطرار';

  @override
  String get distressChainsEmpty => 'هنوز هیچ زنجیره اضطراری وجود ندارد.';

  @override
  String get distressChainsAdd => 'افزودن زنجیره';

  @override
  String get distressChainEditorTitleCreate => 'زنجیره اضطرار جدید';

  @override
  String get distressChainEditorTitleEdit => 'ویرایش زنجیره اضطرار';

  @override
  String get distressChainName => 'نام زنجیره';

  @override
  String get distressCountdown => 'در حال فعال‌سازی زنجیره اضطرار...';

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
  String get settingsSectionDistressChains => 'زنجیره‌های اضطرار';

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
  String get stealthSessionScreen => 'حذف نشانه‌ها در صفحه جلسه';

  @override
  String get stealthPickerTitle => 'App icon';

  @override
  String get stealthPickerIntro => 'Pick how the launcher icon looks.';

  @override
  String get stealthPresetMusic => 'Music';

  @override
  String get stealthPresetCalendar => 'Calendar';

  @override
  String get stealthPresetFitness => 'Fitness';

  @override
  String get stealthPresetWeather => 'Weather';

  @override
  String get stealthPresetNews => 'News';

  @override
  String get stealthPresetPhotos => 'Photos';

  @override
  String get stealthPresetNotes => 'Notes';

  @override
  String get stealthPresetClock => 'Clock';

  @override
  String get distressConfirmationTitle => 'Are you in danger?';

  @override
  String get distressConfirmationCancel => 'Cancel';

  @override
  String distressConfirmationCountdown(Object seconds) {
    return '${seconds}s until distress fires';
  }

  @override
  String get imSafeSliderLabel => 'Swipe to confirm I\'m safe';

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
  String get historyTitle => 'جلسات گذشته';

  @override
  String get historyEmpty => 'هنوز هیچ جلسه گذشته‌ای وجود ندارد.';

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
}
