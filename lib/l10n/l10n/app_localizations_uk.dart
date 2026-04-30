// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get appTitle => 'Guardian Angela';

  @override
  String get commonSave => 'Зберегти';

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
  String get commonCancel => 'Скасувати';

  @override
  String get commonDelete => 'Видалити';

  @override
  String get commonEdit => 'Редагувати';

  @override
  String get commonAdd => 'Додати';

  @override
  String get commonClose => 'Закрити';

  @override
  String get commonConfirm => 'Підтвердити';

  @override
  String get commonBack => 'Назад';

  @override
  String get commonDone => 'Готово';

  @override
  String get commonRetry => 'Повторити';

  @override
  String get commonYes => 'Так';

  @override
  String get commonNo => 'Ні';

  @override
  String get commonEnabled => 'Увімкнено';

  @override
  String get commonDisabled => 'Вимкнено';

  @override
  String get commonNone => 'Немає';

  @override
  String get commonSeconds => 'секунд';

  @override
  String get commonMinutes => 'хвилин';

  @override
  String get cancel => 'Скасувати';

  @override
  String get pinSubmit => 'Submit';

  @override
  String get homeTitle => 'Guardian Angela';

  @override
  String get homeStartSession => 'Почати сесію';

  @override
  String get homeStartConfirmTitle => 'Start a session?';

  @override
  String get homeStartConfirmBody =>
      'Make sure your contacts and PIN are configured. The session will run in the foreground and your selected mode will guide check-ins.';

  @override
  String get homeSimulate => 'Симуляція';

  @override
  String get homeActiveSession => 'Активна сесія';

  @override
  String get homeResumeSession => 'Продовжити';

  @override
  String get homeNoModes => 'Ще немає режимів. Натисніть «Режими», щоб додати.';

  @override
  String get homeNoContacts =>
      'Ще немає екстрених контактів. Натисніть «Контакти», щоб додати.';

  @override
  String get homeContactsBannerNone => 'No emergency contacts configured.';

  @override
  String homeContactsBannerFew(int count) {
    return '$count contact(s) configured. We recommend at least 3.';
  }

  @override
  String get homeMenuSettings => 'Налаштування';

  @override
  String get homeMenuContacts => 'Контакти';

  @override
  String get homeMenuModes => 'Режими';

  @override
  String get homeMenuHistory => 'Минулі сесії';

  @override
  String get homeSelectMode => 'Виберіть режим';

  @override
  String get onboardingWelcomeTitle => 'Ласкаво просимо до Guardian Angela';

  @override
  String get onboardingWelcomeBody =>
      'Супутник, який дбає про вашу безпеку на шляху додому. Guardian Angela стежить за вами, поки ви йдете, бігаєте або подорожуєте, і може сповістити ваших обраних контактів, якщо вам потрібна допомога.';

  @override
  String get onboardingProfileTitle => 'Профіль і перший контакт';

  @override
  String get onboardingProfileBody =>
      'Розкажіть трохи про себе, щоб Guardian Angela могла поділитися корисними даними в екстреній ситуації. Потім додайте одну довірену особу.';

  @override
  String get onboardingPermissionsTitle => 'Дозволи';

  @override
  String get onboardingPermissionsBody =>
      'Guardian Angela потребує кількох дозволів для забезпечення вашої безпеки. Надайте їх зараз або пізніше в налаштуваннях.';

  @override
  String get onboardingNext => 'Далі';

  @override
  String get onboardingSkip => 'Пропустити';

  @override
  String get onboardingFinish => 'Завершити';

  @override
  String get sessionTitle => 'Сесія';

  @override
  String get sessionDisarm => 'Я в безпеці';

  @override
  String get sessionPause => 'Пауза';

  @override
  String get sessionResume => 'Продовжити';

  @override
  String get sessionHoldPrompt => 'Тримайте, щоб залишатися в безпеці';

  @override
  String get sessionHoldSemantic =>
      'Тримайте палець. Відпускання запускає пільговий період.';

  @override
  String sessionStepLabel(Object index, Object total) {
    return 'Крок $index з $total';
  }

  @override
  String sessionMissCount(Object count) {
    return 'Пропущено: $count';
  }

  @override
  String sessionRemaining(Object seconds) {
    return 'Залишилось $seconds с';
  }

  @override
  String get sessionPausedBadge => 'Призупинено';

  @override
  String get sessionPhaseEnded => 'Сесію завершено';

  @override
  String get sessionSimulationBanner => 'Симуляція';

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
  String get sessionCompletedTitle => 'Сесію завершено';

  @override
  String get sessionCompletedBody =>
      'Ви прибули в безпечне місце. Guardian Angela вимикається.';

  @override
  String get sessionCompletedReturnHome => 'На головну';

  @override
  String get simulationSummaryTitle => 'Підсумок симуляції';

  @override
  String get simulationSummaryEmpty =>
      'Під час цієї симуляції жоден крок не спрацював.';

  @override
  String get simulationSummaryReturn => 'На головну';

  @override
  String get fakeCallTitle => 'Вхідний дзвінок';

  @override
  String get fakeCallAnswer => 'Відповісти';

  @override
  String get fakeCallDecline => 'Відхилити';

  @override
  String get fakeCallHangUp => 'Завершити';

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
  String get contactsTitle => 'Екстрені контакти';

  @override
  String get contactsEmpty =>
      'Ще немає контактів. Додайте особу, яка отримуватиме ваші повідомлення про допомогу.';

  @override
  String get contactsAdd => 'Додати контакт';

  @override
  String get contactFormTitleCreate => 'Новий контакт';

  @override
  String get contactFormTitleEdit => 'Редагувати контакт';

  @override
  String get contactFieldName => 'Ім\'я';

  @override
  String get contactFieldPhone => 'Номер телефону';

  @override
  String get contactFieldRelationship => 'Стосунки (необов\'язково)';

  @override
  String get contactFieldLanguage => 'Мова SMS (необов\'язково)';

  @override
  String get contactChannelsHeader => 'Канали зв\'язку';

  @override
  String get contactChannelSms => 'SMS';

  @override
  String get contactChannelWhatsapp => 'WhatsApp';

  @override
  String get contactChannelTelegram => 'Telegram';

  @override
  String get contactChannelPhone => 'Телефонний дзвінок';

  @override
  String get contactDeleteConfirm => 'Видалити контакт?';

  @override
  String contactDeleteBody(Object name) {
    return '$name буде видалено зі списку екстрених контактів.';
  }

  @override
  String get contactRequiredError =>
      'Ім\'я та номер телефону є обов\'язковими.';

  @override
  String get modesTitle => 'Режими';

  @override
  String get modesEmpty =>
      'Ще немає режимів. Натисніть «Додати», щоб створити режим.';

  @override
  String get modesAdd => 'Додати режим';

  @override
  String get modeEditorTitleCreate => 'Новий режим';

  @override
  String get modeEditorTitleEdit => 'Редагувати режим';

  @override
  String get modeFieldName => 'Назва';

  @override
  String get modeFieldCheckInType => 'Тип реєстрації';

  @override
  String get modeFieldDistressChain => 'Режим тривоги';

  @override
  String get modeFieldDistressChainDefault => 'Використати типовий';

  @override
  String get modeChainHeader => 'Ланцюг ескалації';

  @override
  String get modeChainAddStep => 'Додати крок';

  @override
  String get modeChainEmpty => 'Ще немає кроків. Натисніть «Додати крок».';

  @override
  String get modeFieldIcon => 'Значок';

  @override
  String get modeIconPickerTitle => 'Виберіть значок';

  @override
  String get modeIconClear => 'Без значка';

  @override
  String get modeDistressHeader => 'Тригери тривоги';

  @override
  String get modeDistressEmpty => 'Тригери не налаштовано.';

  @override
  String get modeDistressAdd => 'Додати тригер';

  @override
  String get modeDistressTypeHardware => 'Апаратна кнопка';

  @override
  String get modeDistressButtonType => 'Кнопка';

  @override
  String get modeDistressButtonVolumeUp => 'Гучність +';

  @override
  String get modeDistressButtonVolumeDown => 'Гучність −';

  @override
  String get modeDistressButtonPower => 'Живлення';

  @override
  String get modeDistressPattern => 'Шаблон';

  @override
  String get modeDistressPatternRepeat => 'Повторне натискання';

  @override
  String get modeDistressPatternLong => 'Довге натискання';

  @override
  String get modeDistressPressCount => 'Кількість натискань';

  @override
  String get modeDistressPressWindow => 'Вікно (мс)';

  @override
  String get modeDistressLongDuration => 'Тривалість (секунди)';

  @override
  String modeDistressSummaryRepeat(Object count, Object windowMs) {
    return '$count натискань / $windowMs мс';
  }

  @override
  String modeDistressSummaryLong(Object seconds) {
    return 'Утримуйте $secondsс';
  }

  @override
  String get modeOverridesHeader => 'Перевизначення режиму';

  @override
  String get modeOverridesUseDefault => 'За замовчуванням';

  @override
  String get modeOverridesGpsLabel => 'Запис GPS';

  @override
  String get modeOverridesStealthLabel => 'Маскування';

  @override
  String get modeOverridesEventDefaultsLabel => 'Стандартні значення подій';

  @override
  String get modeOverridesLocalTemplatesLabel => 'Локальні шаблони нагадувань';

  @override
  String get modeOverridesGpsEnabled => 'GPS увімкнено';

  @override
  String get modeOverridesGpsIntervalLabel => 'Інтервал (секунди)';

  @override
  String get modeOverridesGpsIncludeInSms => 'Додавати координати в SMS';

  @override
  String get modeOverridesStealthEnabled => 'Маскування увімкнено';

  @override
  String get modeOverridesStealthFakeName => 'Фальшива назва застосунку';

  @override
  String get modeOverridesEventDefaultsHint =>
      'Власні стандарти активні для цього режиму.';

  @override
  String modeOverridesLocalTemplatesCount(Object count) {
    return '$count локальних шаблонів';
  }

  @override
  String get modeUnsavedTitle => 'Скасувати зміни?';

  @override
  String get modeUnsavedBody => 'Є незбережені зміни. Скасувати та вийти?';

  @override
  String get modeUnsavedDiscard => 'Скасувати';

  @override
  String get modeUnsavedKeep => 'Продовжити';

  @override
  String get stepDuplicate => 'Дублювати крок';

  @override
  String get stepTimingHeader => 'Тайминг';

  @override
  String stepTimingSummary(Object wait, Object duration, Object grace) {
    return 'очікування $waitс / тривалість $durationс / пільговий $graceс';
  }

  @override
  String get stepCategoryAll => 'Усі';

  @override
  String get stepCategoryAction => 'Дія';

  @override
  String get stepCategoryReminder => 'Нагадування';

  @override
  String get stepCategoryDisarm => 'Реєстрація';

  @override
  String get modeTrackingHeader => 'Відстеження GPS';

  @override
  String get modeTrackingEnabled => 'Записувати GPS під час сеансу';

  @override
  String get modeTrackingIntervalLabel => 'Інтервал вибірки';

  @override
  String get modeTrackingBufferSizeLabel => 'Розмір буфера';

  @override
  String modeTrackingBufferSizeValue(Object count) {
    return '$count точок';
  }

  @override
  String get modeTrackingBatteryNote =>
      'Часте відстеження GPS збільшує витрати батареї.';

  @override
  String get stepConfigLogGpsLabel => 'Запис GPS';

  @override
  String get stepConfigLogGpsDefault => 'За замовчуванням';

  @override
  String get stepConfigLogGpsOn => 'Увімкн.';

  @override
  String get stepConfigLogGpsOff => 'Вимкн.';

  @override
  String get stepConfigLogGpsDefaultOn => 'За замовчуванням (Увімкн.)';

  @override
  String get stepConfigLogGpsDefaultOff => 'За замовчуванням (Вимкн.)';

  @override
  String get moreSettingsHeader => 'Додаткові налаштування';

  @override
  String moreSettingsHeaderCustomized(int count) {
    return 'Додаткові налаштування ($count змінено)';
  }

  @override
  String get stepTypePickerLabel => 'Step type';

  @override
  String get stepTypeHoldButton => 'Кнопка утримання';

  @override
  String get stepTypeDisguisedReminder => 'Замаскований нагадування';

  @override
  String get stepTypeCountdownWarning => 'Попередження відліку';

  @override
  String get stepTypeFakeCall => 'Фальшивий дзвінок';

  @override
  String get stepTypeSmsContact => 'SMS контакту';

  @override
  String get stepTypePhoneCallContact => 'Телефонувати контакту';

  @override
  String get stepTypeLoudAlarm => 'Гучна сирена';

  @override
  String get stepTypeCallEmergency => 'Виклик екстрених служб';

  @override
  String get stepTypeHardwareButton => 'Апаратна кнопка';

  @override
  String get stepFieldDuration => 'Тривалість (секунди)';

  @override
  String get stepFieldGrace => 'Пільговий період (секунди)';

  @override
  String get stepFieldWait => 'Очікування (секунди)';

  @override
  String get stepFieldRetryCount => 'Повторні спроби';

  @override
  String get stepFieldRandomize => 'Варіація таймінгу';

  @override
  String get stepPreview => 'Попередній перегляд у симуляції';

  @override
  String stepPreviewFired(Object description) {
    return 'Попередній перегляд виконано: $description';
  }

  @override
  String get stepConfigFakeCallCaller => 'Ім\'я абонента';

  @override
  String get stepConfigFakeCallDecline => 'Відхилення = знімання тривоги';

  @override
  String get stepConfigLoudAlarmFlash => 'Мигання екрана';

  @override
  String get stepConfigLoudAlarmVolume => 'Максимальна гучність';

  @override
  String get stepConfigCountdownVibrate => 'Вібрація';

  @override
  String get stepConfigCountdownTone => 'Відтворити сигнал';

  @override
  String get stepConfigSmsSelection => 'Одержувачі';

  @override
  String get stepConfigSmsAllContacts => 'Усі контакти';

  @override
  String get stepConfigSmsSpecific => 'Вибрані контакти';

  @override
  String get stepConfigSmsIncludeLocation => 'Додати місцезнаходження';

  @override
  String get stepConfigSmsIncludeMedical => 'Додати медичну інформацію';

  @override
  String get stepConfigHoldReleaseSensitivity => 'Чутливість відпускання (с)';

  @override
  String get stepConfigReminderInterval => 'Інтервал нагадування (секунди)';

  @override
  String get stepConfigReminderTemplate => 'Шаблон';

  @override
  String get stepConfigHardwarePattern => 'Візерунок';

  @override
  String get stepConfigHardwarePressCount => 'Кількість натискань';

  @override
  String get stepConfigHardwareButton => 'Кнопка';

  @override
  String get stepConfigHardwareButtonVolumeUp => 'Гучність +';

  @override
  String get stepConfigHardwareButtonVolumeDown => 'Гучність -';

  @override
  String get stepConfigHardwareButtonPower => 'Живлення';

  @override
  String get stepConfigHardwarePatternRepeat => 'Повторне натискання';

  @override
  String get stepConfigHardwarePatternLong => 'Тривале натискання';

  @override
  String get stepConfigEmergencyNumber =>
      'Перевизначення номера екстреної служби';

  @override
  String get stepConfigEmergencyConfirm => 'Підтвердити перед дзвінком';

  @override
  String get stepConfigPhonePreSms => 'Надіслати SMS перед дзвінком';

  @override
  String get distressModesTitle => 'Режими тривоги';

  @override
  String get distressModeInUseTitle => 'Режим тривоги використовується';

  @override
  String distressModeInUseBody(Object modes) {
    return 'Цей режим тривоги досі прив\'язаний до: $modes. Перш ніж видаляти, переприв\'яжіть ці режими до іншого режиму тривоги.';
  }

  @override
  String get distressModesEmpty => 'Ще немає режимів тривоги.';

  @override
  String get distressModesAdd => 'Додати режим тривоги';

  @override
  String get distressModeEditorTitleCreate => 'Новий режим тривоги';

  @override
  String get distressModeEditorTitleEdit => 'Редагувати режим тривоги';

  @override
  String get distressModeName => 'Назва режиму тривоги';

  @override
  String get distressCountdown => 'Запускається режим тривоги...';

  @override
  String get distressCountdownStealth => 'Зачекайте, будь ласка...';

  @override
  String get templatesTitle => 'Шаблони нагадувань';

  @override
  String get templatesEmpty => 'Ще немає шаблонів.';

  @override
  String get templatesAdd => 'Додати шаблон';

  @override
  String get templateEditorTitleCreate => 'Новий шаблон';

  @override
  String get templateEditorTitleEdit => 'Редагувати шаблон';

  @override
  String get templateFieldName => 'Назва в редакторі';

  @override
  String get templateFieldTitle => 'Заголовок нагадування';

  @override
  String get templateFieldBody => 'Текст нагадування';

  @override
  String get templateFieldConfirmationType => 'Тип підтвердження';

  @override
  String get templateFieldKeyword => 'Ключове слово';

  @override
  String get templateFieldButtonLabel => 'Напис на кнопці';

  @override
  String get templateFieldDisplayStyle => 'Стиль відображення';

  @override
  String get templateConfirmTapButton => 'Натиснути кнопку';

  @override
  String get templateConfirmTapWord => 'Натиснути слово';

  @override
  String get templateConfirmSwipe => 'Провести';

  @override
  String get templateConfirmDismiss => 'Відхилити';

  @override
  String get templateDisplayFullscreen => 'На весь екран';

  @override
  String get templateDisplaySubtle => 'Непомітний';

  @override
  String get profileTitle => 'Профіль';

  @override
  String get profileFieldName => 'Ім\'я';

  @override
  String get profileFieldAge => 'Вік';

  @override
  String get profileFieldBloodType => 'Група крові';

  @override
  String get profileFieldAllergies => 'Алергії';

  @override
  String get profileFieldMedications => 'Ліки';

  @override
  String get profileFieldConditions => 'Медичні стани';

  @override
  String get profileFieldInstructions => 'Інструкції для екстрених служб';

  @override
  String get profileAddItem => 'Додати запис';

  @override
  String get settingsTitle => 'Налаштування';

  @override
  String get settingsSectionSecurity => 'Безпека';

  @override
  String get settingsSectionStealth => 'Прихований режим';

  @override
  String get settingsSectionDefaults => 'За замовчуванням';

  @override
  String get settingsSectionHistory => 'Історія';

  @override
  String get settingsSectionBackup => 'Резервне копіювання';

  @override
  String get settingsSectionAbout => 'Про застосунок';

  @override
  String get settingsSectionFeedback => 'Зворотний зв\'язок';

  @override
  String get settingsSectionContacts => 'Контакти';

  @override
  String get settingsSectionModes => 'Режими';

  @override
  String get settingsSectionProfile => 'Профіль';

  @override
  String get settingsSectionDistressModes => 'Режими тривоги';

  @override
  String get settingsSectionReminderTemplates => 'Шаблони нагадувань';

  @override
  String get settingsSectionBatteryAlert => 'Сповіщення про батарею';

  @override
  String get settingsSectionEventDefaults => 'Типові значення кроків';

  @override
  String get settingsSectionGpsLogging => 'GPS-журнал';

  @override
  String get settingsSectionNotifications => 'Сповіщення';

  @override
  String get settingsSectionHistoryRetention => 'Зберігання історії';

  @override
  String get settingsSectionAppearance => 'Вигляд';

  @override
  String get settingsThemeMode => 'Тема';

  @override
  String get settingsThemeLight => 'Світла';

  @override
  String get settingsThemeDark => 'Темна';

  @override
  String get settingsThemeSystem => 'Системна';

  @override
  String get settingsLanguage => 'Мова';

  @override
  String get settingsEmergencyNumber => 'Номер екстреної служби';

  @override
  String get settingsAlarmDnd => 'Сирена обходить «Не турбувати»';

  @override
  String get securityTitle => 'Безпека';

  @override
  String get securityAppPin => 'PIN-код застосунку';

  @override
  String get securitySessionEndPin => 'PIN-код завершення сесії';

  @override
  String get securityDuressPin => 'PIN-код примусу';

  @override
  String get securityPinTimeout => 'Тайм-аут PIN (секунди)';

  @override
  String get securityDisablePin => 'Вимкнути';

  @override
  String get securitySetPin => 'Встановити PIN';

  @override
  String get securityChangePin => 'Змінити PIN';

  @override
  String get pinSetupTitle => 'Встановити PIN';

  @override
  String get pinSetupEnter => 'Введіть новий PIN';

  @override
  String get pinSetupConfirm => 'Підтвердьте PIN';

  @override
  String get pinSetupMismatch => 'PIN-коди не збігаються. Спробуйте ще раз.';

  @override
  String get pinEntryTitle => 'Введіть PIN';

  @override
  String get pinEntrySubtitle => 'Введіть свій PIN, щоб продовжити.';

  @override
  String get pinEntryBiometricReason => 'Authenticate to continue';

  @override
  String get stealthTitle => 'Прихований режим';

  @override
  String get stealthEnable => 'Увімкнути прихований режим';

  @override
  String get stealthFakeName => 'Фальшива назва застосунку';

  @override
  String get stealthFakeIcon => 'Фальшива іконка';

  @override
  String get stealthNotificationDisguise => 'Маскувати сповіщення';

  @override
  String get stealthTimerDisplay => 'Показувати таймер у прихованому режимі';

  @override
  String get stealthTimerDisplayNormal => 'Show full text';

  @override
  String get stealthTimerDisplaySmall => 'Show numbers only';

  @override
  String get stealthTimerDisplayNone => 'Hide timer';

  @override
  String get stealthSessionScreen => 'Прибрати брендинг з екрана сесії';

  @override
  String get stealthPickerTitle => 'Значок застосунку';

  @override
  String get stealthPickerIntro =>
      'Виберіть, який вигляд має значок у лаунчері.';

  @override
  String get stealthPresetMusic => 'Музика';

  @override
  String get stealthPresetCalendar => 'Календар';

  @override
  String get stealthPresetFitness => 'Фітнес';

  @override
  String get stealthPresetWeather => 'Погода';

  @override
  String get stealthPresetNews => 'Новини';

  @override
  String get stealthPresetPhotos => 'Фото';

  @override
  String get stealthPresetNotes => 'Нотатки';

  @override
  String get stealthPresetClock => 'Годинник';

  @override
  String get distressConfirmationTitle => 'Ви в небезпеці?';

  @override
  String get distressConfirmationCancel => 'Скасувати';

  @override
  String distressConfirmationCountdown(Object seconds) {
    return 'Режим тривоги спрацює через $seconds с';
  }

  @override
  String get imSafeSliderLabel => 'Проведіть, щоб підтвердити «Я в безпеці»';

  @override
  String get batteryAlertTitle => 'Сповіщення про батарею';

  @override
  String get batteryAlertEnable => 'Увімкнути сповіщення про батарею';

  @override
  String batteryAlertThreshold(Object percent) {
    return 'Поріг: $percent%';
  }

  @override
  String get eventDefaultsTitle => 'Типові значення кроків';

  @override
  String get eventDefaultsBody =>
      'Ці типові значення застосовуються до будь-якого кроку, який їх не перевизначає.';

  @override
  String get gpsLoggingTitle => 'GPS-журнал';

  @override
  String get gpsLoggingEnable => 'Увімкнути GPS-журнал';

  @override
  String get gpsLoggingInterval => 'Інтервал вибірки (секунди)';

  @override
  String get gpsLoggingAccuracy => 'Точність';

  @override
  String get gpsAccuracyLow => 'Низька';

  @override
  String get gpsAccuracyMedium => 'Середня';

  @override
  String get gpsAccuracyHigh => 'Висока';

  @override
  String get gpsLoggingIncludeSms => 'Додати місцезнаходження до SMS';

  @override
  String get gpsLoggingHistoryDays => 'Зберігання історії (дні)';

  @override
  String get notificationSettingsTitle => 'Сповіщення';

  @override
  String get notificationSettingsBody =>
      'Guardian Angela використовує сповіщення для маскування та нагадувань.';

  @override
  String get historyRetentionTitle => 'Зберігання історії';

  @override
  String get historyRetentionBody =>
      'Як довго Guardian Angela зберігає журнали минулих сесій.';

  @override
  String historyRetentionDays(Object days) {
    return 'Зберігання: $days днів';
  }

  @override
  String get backupTitle => 'Резервне копіювання';

  @override
  String get backupExport => 'Експортувати дані';

  @override
  String get backupImport => 'Імпортувати дані';

  @override
  String get backupNotReady =>
      'Резервне копіювання поки недоступне. Незабаром.';

  @override
  String get backupPinOptional => 'Необов\'язковий PIN (шифрує пакет)';

  @override
  String get backupImportOk => 'Резервну копію успішно імпортовано.';

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
  String get historyTitle => 'Минулі сесії';

  @override
  String get historyEmpty => 'Ще немає минулих сесій.';

  @override
  String get historySearchHint => 'Search by mode name';

  @override
  String get historyFilterModeAll => 'All modes';

  @override
  String get historyFilterModeLabel => 'Mode';

  @override
  String get historyDetailTitle => 'Деталі сесії';

  @override
  String get evidenceExportTitle => 'Експорт доказів';

  @override
  String get evidenceExportAsText => 'Скопіювати як текст';

  @override
  String get evidenceExportAsJson => 'Скопіювати як JSON';

  @override
  String get evidenceCopied => 'Скопійовано до буфера обміну.';

  @override
  String get aboutTitle => 'Про застосунок';

  @override
  String get aboutVersion => 'Версія';

  @override
  String get aboutCredits =>
      'Створено з турботою про тих, хто повертається додому.';

  @override
  String get feedbackTitle => 'Зворотний зв\'язок';

  @override
  String get feedbackBody => 'Ми будемо раді почути вашу думку.';

  @override
  String get feedbackFieldMessage => 'Повідомлення';

  @override
  String get feedbackSend => 'Відкрити пошту';

  @override
  String get pickerNoneLabel => '— немає —';

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
