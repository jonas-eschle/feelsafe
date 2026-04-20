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
  String get homeTitle => 'Guardian Angela';

  @override
  String get homeStartSession => 'Почати сесію';

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
  String get modeFieldDistressChain => 'Ланцюг тривоги';

  @override
  String get modeFieldDistressChainDefault => 'Використати типовий';

  @override
  String get modeChainHeader => 'Ланцюг ескалації';

  @override
  String get modeChainAddStep => 'Додати крок';

  @override
  String get modeChainEmpty => 'Ще немає кроків. Натисніть «Додати крок».';

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
  String get distressChainsTitle => 'Ланцюги тривоги';

  @override
  String get distressChainsEmpty => 'Ще немає ланцюгів тривоги.';

  @override
  String get distressChainsAdd => 'Додати ланцюг';

  @override
  String get distressChainEditorTitleCreate => 'Новий ланцюг тривоги';

  @override
  String get distressChainEditorTitleEdit => 'Редагувати ланцюг тривоги';

  @override
  String get distressChainName => 'Назва ланцюга';

  @override
  String get distressCountdown => 'Запускається ланцюг тривоги...';

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
  String get settingsSectionDistressChains => 'Ланцюги тривоги';

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
  String get stealthSessionScreen => 'Прибрати брендинг з екрана сесії';

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
  String get historyTitle => 'Минулі сесії';

  @override
  String get historyEmpty => 'Ще немає минулих сесій.';

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
}
