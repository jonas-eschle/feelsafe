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
  String get angelaDialogTitle => 'Введено старий PIN-код';

  @override
  String get angelaDialogBody =>
      'Схоже, Ви використали старий PIN-код. Ви впевнені, що бажаєте продовжити?';

  @override
  String get angelaDialogCancel => 'Скасувати';

  @override
  String get angelaDialogConfirm => 'Продовжити';

  @override
  String get commonCancel => 'Скасувати';

  @override
  String get commonOk => 'OK';

  @override
  String get profileAngelaWarningTitle => 'Зверніть увагу на ім\'я «Angela»';

  @override
  String get profileAngelaWarningBody =>
      'Guardian Angela використовує «Angela» як ключове слово безпеки. Використання його як власного імені може спричинити плутанину. Зберегти попри це?';

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
  String get pinSubmit => 'Підтвердити';

  @override
  String get homeTitle => 'Guardian Angela';

  @override
  String get homeStartSession => 'Почати сесію';

  @override
  String get homeStartConfirmTitle => 'Розпочати сесію?';

  @override
  String get homeStartConfirmBody =>
      'Переконайтеся, що Ваші контакти та PIN-код налаштовано. Сесія працюватиме у фоновому режимі, і обраний режим керуватиме реєстраціями.';

  @override
  String get homePermissionsMissingTitle => 'Бракує деяких дозволів';

  @override
  String get homePermissionsMissingBody =>
      'Наступні дозволи не було надано. Без них відповідні кроки ланцюжка не виконаються без сповіщення:';

  @override
  String get homePermissionsContinueAnyway => 'Запустити все одно';

  @override
  String get homePermissionsNotification => 'Сповіщення';

  @override
  String get homePermissionsLocation => 'Місцезнаходження';

  @override
  String get homePermissionsCallPhone => 'Телефонні дзвінки';

  @override
  String get homePermissionsSendSms => 'Надсилання SMS';

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
  String get homeContactsBannerNone =>
      'Не налаштовано жодного екстреного контакту.';

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
  String get sessionCheckIn => 'Я зареєструвався';

  @override
  String get sessionDisarmTriggerTitle => 'Спрацював тригер знеактивування';

  @override
  String get sessionDisarmTriggerBody =>
      'Спрацював тригер знеактивування. Завершити сесію?';

  @override
  String get sessionDisarmTriggerConfirm => 'Завершити сесію';

  @override
  String get sessionDisarmTriggerCancel => 'Продовжити';

  @override
  String get wrongPinAngelaTitle => 'Старий PIN-код від Angela';

  @override
  String get wrongPinAngelaBody =>
      'Ви впевнені, що бажаєте продовжити з цим старим PIN-кодом?';

  @override
  String get wrongPinAngelaConfirm => 'OK';

  @override
  String get wrongPinAngelaCancel => 'Скасувати';

  @override
  String get sessionStepCountdownTitle => 'Попередження';

  @override
  String get sessionStepCountdownBody =>
      'Наступна ескалація спрацює, коли відлік завершиться. Проведіть «Я в безпеці» нижче, щоб знеактивувати.';

  @override
  String get sessionStepDisguisedDefaultTitle => 'Нагадування';

  @override
  String get sessionStepDisguisedDefaultBody =>
      'Натисніть «Я зареєструвався», щоб підтвердити, що Ви в безпеці.';

  @override
  String get sessionStepSmsStatus => 'Надсилання повідомлення контактам…';

  @override
  String get sessionStepSmsDelivered => 'Доставлено';

  @override
  String get sessionStepSmsSent => 'Надіслано';

  @override
  String get sessionStepSmsQueued => 'У черзі';

  @override
  String get sessionStepSmsFailed => 'Не вдалося';

  @override
  String get sessionStepPhoneCallStatus => 'Виклик екстреного контакту…';

  @override
  String get sessionStepPhoneCallCancel => 'Скасувати дзвінок';

  @override
  String get sessionStepLoudAlarmTitle => 'Сирена ввімкнено';

  @override
  String get sessionStepLoudAlarmBody =>
      'Сирена звучить, щоб привернути увагу.';

  @override
  String get sessionStepLoudAlarmFlashWarning =>
      'Попередження для людей із фоточутливістю: екран блимає.';

  @override
  String get sessionStepCallEmergencyStatus => 'Виклик екстрених служб…';

  @override
  String sessionStepCallEmergencyNumber(Object number) {
    return 'Номер: $number';
  }

  @override
  String sessionStepHardwareButtonRepeat(
    Object button,
    Object count,
    Object windowMs,
  ) {
    return 'Натисніть $button $count раз(ів) протягом $windowMs мс';
  }

  @override
  String sessionStepHardwareButtonLong(Object button, Object seconds) {
    return 'Утримуйте $button протягом $seconds с';
  }

  @override
  String get sessionStepHardwareButtonVolumeUp => 'збільшення гучності';

  @override
  String get sessionStepHardwareButtonVolumeDown => 'зменшення гучності';

  @override
  String get sessionStepHardwareButtonPower => 'живлення';

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
  String get fakeCallSlideToAnswer => 'проведіть, щоб відповісти';

  @override
  String get fakeCallUnknownCaller => 'Невідомий';

  @override
  String get fakeCallIncomingWhatsapp => 'Голосовий виклик WhatsApp';

  @override
  String get fakeCallIncomingTelegram => 'Голосовий виклик Telegram';

  @override
  String get fakeCallIncomingSignal => 'Голосовий виклик Signal';

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
  String get contactLanguageDefault => 'За замовчуванням (мова застосунку)';

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
  String get modesNewPickerTitle => 'Почати з';

  @override
  String get modesNewPickerBlank => 'Порожній режим';

  @override
  String get modesNewPickerBlankSubtitle => 'Почати з порожнього ланцюга';

  @override
  String modesNewPickerFromTemplate(String name) {
    return 'З «$name»';
  }

  @override
  String get modesNewPickerFromTemplateSubtitle =>
      'Скопіювати ланцюг і тригери цього режиму';

  @override
  String modesNewPickerCopyName(String name) {
    return 'Копія «$name»';
  }

  @override
  String get modesNewPickerBuiltinBadge => 'Вбудований';

  @override
  String get modeEditorTitleCreate => 'Новий режим';

  @override
  String get modeEditorTitleEdit => 'Редагувати режим';

  @override
  String get modeFieldName => 'Назва';

  @override
  String get modeFieldDistressMode => 'Режим тривоги';

  @override
  String get modeFieldDistressModeDefault => 'Використати типовий';

  @override
  String get modeChainHeader => 'Ланцюг';

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
  String get stepPickerMore => 'Більше варіантів...';

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
  String get stepTypePickerLabel => 'Тип кроку';

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
  String get stepFieldRetryCount => 'Кількість повторних спроб';

  @override
  String get stepFieldRandomize => 'Варіація таймінгу';

  @override
  String get stepFieldRandomizeToggle => 'Випадковий час (±20%)';

  @override
  String get stepFieldWaitTooltip =>
      'Скільки чекати перед початком цього кроку.';

  @override
  String get stepFieldDurationTooltip =>
      'Скільки крок активний до початку пільгового періоду.';

  @override
  String get stepFieldGraceTooltip =>
      'Час після активної фази для підтвердження безпеки перед наступним кроком.';

  @override
  String get stepFieldRetryCountTooltip =>
      'Скільки разів повторити цей крок до ескалації.';

  @override
  String get stepFieldReminderIntervalTooltip =>
      'Як часто спрацьовує замаскований нагадування в очікуванні підтвердження.';

  @override
  String get stepFieldReminderGraceTooltip =>
      'Скільки часу у користувача на підтвердження безпеки після появи нагадування.';

  @override
  String get stepPreview => 'Попередній перегляд у симуляції';

  @override
  String stepPreviewFired(Object description) {
    return 'Попередній перегляд виконано: $description';
  }

  @override
  String get stepPreviewTitle => 'Попередній перегляд кроку';

  @override
  String get stepPreviewMissingParams => 'Немає посилання на крок або режим.';

  @override
  String get stepPreviewModeNotFound => 'Режим не знайдено.';

  @override
  String get stepPreviewStepNotFound => 'Крок не знайдено в цьому режимі.';

  @override
  String stepPreviewError(Object error) {
    return 'Помилка попереднього перегляду: $error';
  }

  @override
  String get stepPreviewReplay => 'Повторити';

  @override
  String get stepPreviewHoldButtonHint =>
      'Утримуйте кнопку, щоб відчути живий відгук.';

  @override
  String get stepPreviewHoldButtonLabel => 'Утримати';

  @override
  String get stepPreviewHoldButtonSemantic => 'Утримуйте для перегляду';

  @override
  String get stepPreviewHoldButtonReleased =>
      'Відпущено. Сесія тепер увійде у вікно очікування.';

  @override
  String get stepPreviewFakeCallHint =>
      'З\'явиться екран фальшивого виклику. Проведіть для відповіді або утримуйте червону кнопку для імітації тривоги.';

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
  String get stepConfigSmsAutoRecordAudio => 'Авто-запис аудіо';

  @override
  String get stepConfigSmsAutoRecordVideo => 'Авто-запис відео';

  @override
  String get stepConfigSmsRecordDuration => 'Тривалість запису';

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
  String get stepConfigHardwarePressWindow => 'Інтервал між натисканнями (мс)';

  @override
  String get stepConfigHardwareLongDuration =>
      'Тривалість тривалого натискання (с)';

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
  String get profileFieldPhoneNumber => 'Номер телефону';

  @override
  String get profileFieldPhysicalDescription => 'Фізичний опис';

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
  String get settingsLanguagePicker => 'Мова';

  @override
  String get settingsEmergencyNumberLabel => 'Номер екстреної служби';

  @override
  String get settingsEmergencyNumberHint => 'напр., 112';

  @override
  String get settingsEmergencyNumberSave => 'Зберегти';

  @override
  String get settingsRedoOnboarding => 'Повторити знайомство';

  @override
  String get settingsRedoOnboardingConfirm => 'Почати знайомство спочатку?';

  @override
  String get settingsRedoOnboardingBody =>
      'Ваша поточна конфігурація зберігається.';

  @override
  String get settingsRedoOnboardingProceed => 'Почати спочатку';

  @override
  String get settingsAlarmGradualVolume => 'Поступове наростання сирени';

  @override
  String settingsAlarmGradualVolumeDuration(int seconds) {
    return 'Тривалість наростання: $seconds с';
  }

  @override
  String get securityTitle => 'Безпека';

  @override
  String get securityAppPin => 'PIN-код застосунку';

  @override
  String get securitySessionEndPin => 'PIN-код завершення сесії';

  @override
  String get securityDuressPin => 'PIN-код примусу';

  @override
  String get securityAppPinBiometric =>
      'Використовувати біометрію для PIN-коду застосунку';

  @override
  String get securitySessionEndPinBiometric =>
      'Використовувати біометрію для PIN-коду завершення сесії';

  @override
  String get securityDistressCancelBiometric =>
      'Використовувати біометрію для скасування сигналу тривоги';

  @override
  String get securityDuressTest => 'Перевірити PIN-код примусу';

  @override
  String get securityDuressTestSubtitle =>
      'Переконайтеся, що PIN-код примусу працює.';

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
  String get pinEntryBiometricReason => 'Автентифікуйтеся, щоб продовжити';

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
  String get stealthTimerDisplayNormal => 'Показати повний текст';

  @override
  String get stealthTimerDisplaySmall => 'Показувати лише цифри';

  @override
  String get stealthTimerDisplayNone => 'Сховати таймер';

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
  String get backupSelectionHeader => 'Включити в експорт';

  @override
  String get backupToggleSettings => 'Налаштування';

  @override
  String get backupToggleSettingsSubtitle =>
      'Завжди включено, щоб резервну копію можна було відновити.';

  @override
  String get backupToggleContacts => 'Екстрені контакти';

  @override
  String get backupToggleModes => 'Режими';

  @override
  String get backupToggleDistressModes => 'Режими тривоги';

  @override
  String get backupToggleTemplates => 'Шаблони нагадувань';

  @override
  String get backupToggleSessionLogs => 'Історія сесій';

  @override
  String get backupToggleRecordings => 'Аудіозаписи';

  @override
  String get historyTitle => 'Минулі сесії';

  @override
  String get historyEmpty => 'Ще немає минулих сесій.';

  @override
  String get historyTabReal => 'Реальні';

  @override
  String get historyTabSimulated => 'Симуляція';

  @override
  String get historySearchHint => 'Пошук за назвою режиму';

  @override
  String get historyFilterModeAll => 'Усі режими';

  @override
  String get historyFilterModeLabel => 'Режим';

  @override
  String get historyDateRangePick => 'Діапазон дат';

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
  String aboutVersion(Object version) {
    return 'Версія';
  }

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
    return 'Виклик $number';
  }

  @override
  String get emergencyConfirmSubtitle =>
      'Утримуйте кнопку скасування, щоб перервати.';

  @override
  String emergencyConfirmCountdown(Object seconds) {
    return 'Виклик через $seconds с';
  }

  @override
  String get emergencyConfirmCancel => 'Скасувати';

  @override
  String get stealthCalendarUpcoming => 'Найближчі';

  @override
  String get stealthCalendarUpcomingEvent => 'Зустріч';

  @override
  String stealthCalendarUntilEvent(Object minutes) {
    return 'через $minutes хв';
  }

  @override
  String get stealthCalendarToday => 'Сьогодні';

  @override
  String get stealthCalendarEvent1 => 'Кава з Олексієм';

  @override
  String get stealthCalendarEvent2 => 'Стендап';

  @override
  String get stealthCalendarEvent3 => 'Обід';

  @override
  String get stealthCalendarEvent4 => 'Тренування';

  @override
  String get stealthCalendarEvent5 => 'Вечеря з Сашком';

  @override
  String get stealthDisarmGestureHint => 'Проведіть угору, щоб завершити';

  @override
  String get stealthMusicTrackTitle => 'Без назви';

  @override
  String get stealthMusicArtist => 'Невідомий виконавець';

  @override
  String get stealthMusicAlbum => 'Невідомий альбом';

  @override
  String get stealthMusicNowPlaying => 'Зараз грає';

  @override
  String get stealthMusicSwipeHint => 'Проведіть, щоб знеактивувати';

  @override
  String get stealthMusicPrevious => 'Попередній';

  @override
  String get stealthMusicPause => 'Пауза';

  @override
  String get stealthMusicNext => 'Наступний';

  @override
  String get stealthPodcastShowName => 'Подкаст';

  @override
  String get stealthPodcastEpisodeTitle => 'Епізод';

  @override
  String get stealthPodcastEpisodesHeader => 'Епізоди';

  @override
  String get stealthPodcastSpeedLabel => '1x';

  @override
  String get stealthPodcastEpisode1 => 'Епізод 1';

  @override
  String get stealthPodcastEpisode2 => 'Епізод 2';

  @override
  String get stealthPodcastEpisode3 => 'Епізод 3';

  @override
  String get stealthPodcastEpisode4 => 'Епізод 4';

  @override
  String get stealthPresetPodcast => 'Подкаст';

  @override
  String get stealthPresetNone => 'Немає';

  @override
  String get sessionSimSpeedLabel => 'Швидкість';

  @override
  String sessionSimSpeedValue(Object value) {
    return '${value}x';
  }

  @override
  String get sessionSimSpeedBackgroundCap =>
      'Обмежено до 60× у фоновому режимі';

  @override
  String get sessionSimAdvancedLabel => 'Розширені';

  @override
  String get sessionSimTriggerPanic => 'Викликати паніку';

  @override
  String get sessionSimTriggerArrival => 'Симулювати прибуття';

  @override
  String get sessionSimTriggerBattery => 'Симулювати низький заряд';

  @override
  String get simulateGpsArrival => 'Симулювати прибуття';

  @override
  String get simulateLowBattery => 'Симулювати низький заряд';

  @override
  String get launchGateTitle => 'Розблокувати Guardian Angela';

  @override
  String get launchGateSubtitle =>
      'Введіть PIN-код або скористайтеся біометрією.';

  @override
  String get launchGateWrong => 'Неправильний PIN-код';

  @override
  String get launchGateBiometricReason => 'Розблокуйте Guardian Angela';

  @override
  String get launchGateUseBiometric => 'Використати біометрію';

  @override
  String get audioRunningLatePhrase =>
      'Привіт, я запізнююсь. Скоро передзвоню.';

  @override
  String smsDefaultTemplate(Object name, Object location, Object time) {
    return '$name може потребувати допомоги. Місцезнаходження: $location. Час: $time.';
  }

  @override
  String smsDefaultPreCallTemplate(Object name) {
    return '$name намагається з вами зв\'язатися. Очікуйте дзвінка.';
  }

  @override
  String simLoudAlarm(Object tail) {
    return '[SIM] Гучна тривога + $tail';
  }

  @override
  String get simLoudAlarmTailFlash => 'спалах';

  @override
  String get simLoudAlarmTailVibrate => 'вібрація';

  @override
  String simSmsContact(Object channel, int count) {
    return '[SIM] Надіслав би $channel $count контактам';
  }

  @override
  String simFakeCallRing(Object caller) {
    return '[SIM] Вхідний виклик від $caller';
  }

  @override
  String simCountdownWarning(int seconds) {
    return '[SIM] Попередження зворотного відліку $secondsс';
  }

  @override
  String simPhoneCall(Object name) {
    return '[SIM] Зателефонував би $name';
  }

  @override
  String get simNoContactToCall => '[SIM] Немає контакту для дзвінка';

  @override
  String simCallEmergency(Object number) {
    return '[SIM] Набрав би $number';
  }

  @override
  String get simHardwareButton => '[SIM] Апаратний тригер активовано';

  @override
  String get simHoldButton => '[SIM] Очікування утримання кнопки';

  @override
  String simDisguisedReminder(Object title) {
    return '[SIM] Показав би «$title»';
  }

  @override
  String get simDisguisedReminderEmpty =>
      '[SIM] Шаблон нагадування недоступний';

  @override
  String get simGpsArrivalTrigger => '[SIM] Тригер прибуття GPS активовано';

  @override
  String get simLowBatteryAlert =>
      '[SIM] Активовано сповіщення про низький заряд';

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
      'Set the destination for GPS-arrival disarm.';

  @override
  String get sessionGpsDestinationLat => 'Latitude';

  @override
  String get sessionGpsDestinationLng => 'Longitude';

  @override
  String get sessionGpsDestinationUseCurrent => 'Use current location';

  @override
  String get sessionGpsDestinationSkip => 'Skip';

  @override
  String get sessionGpsDestinationConfirm => 'Confirm';

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
  String get gpsLoggingFormatAddress => 'Address';

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
  String get pastEventsDetailDelete => 'Delete';

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
}
