// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Guardian Angela';

  @override
  String get commonSave => 'Сохранить';

  @override
  String get angelaDialogTitle => 'Введён старый PIN';

  @override
  String get angelaDialogBody =>
      'Похоже, вы использовали старый PIN. Вы уверены, что хотите продолжить?';

  @override
  String get angelaDialogCancel => 'Отмена';

  @override
  String get angelaDialogConfirm => 'Продолжить';

  @override
  String get commonCancel => 'Отмена';

  @override
  String get commonOk => 'ОК';

  @override
  String get profileAngelaWarningTitle => 'Внимание к имени «Angela»';

  @override
  String get profileAngelaWarningBody =>
      'Guardian Angela использует «Angela» как ключевое слово безопасности. Использование этого имени в качестве вашего собственного может вызвать путаницу. Всё равно сохранить?';

  @override
  String get commonDelete => 'Удалить';

  @override
  String get commonEdit => 'Изменить';

  @override
  String get commonAdd => 'Добавить';

  @override
  String get commonClose => 'Закрыть';

  @override
  String get commonConfirm => 'Подтвердить';

  @override
  String get commonBack => 'Назад';

  @override
  String get commonDone => 'Готово';

  @override
  String get commonRetry => 'Повторить';

  @override
  String get commonYes => 'Да';

  @override
  String get commonNo => 'Нет';

  @override
  String get commonEnabled => 'Включено';

  @override
  String get commonDisabled => 'Отключено';

  @override
  String get commonNone => 'Нет';

  @override
  String get commonSeconds => 'секунд';

  @override
  String get commonMinutes => 'минут';

  @override
  String get cancel => 'Отмена';

  @override
  String get pinSubmit => 'Подтвердить';

  @override
  String get homeTitle => 'Guardian Angela';

  @override
  String get homeStartSession => 'Начать сессию';

  @override
  String get homeStartConfirmTitle => 'Начать сессию?';

  @override
  String get homeStartConfirmBody =>
      'Убедитесь, что ваши контакты и PIN настроены. Сессия будет работать на переднем плане, и выбранный режим будет управлять отметками.';

  @override
  String get homePermissionsMissingTitle => 'Отсутствуют некоторые разрешения';

  @override
  String get homePermissionsMissingBody =>
      'Следующие разрешения не были предоставлены. Без них соответствующие шаги цепочки завершатся неудачно без уведомления:';

  @override
  String get homePermissionsContinueAnyway => 'Запустить всё равно';

  @override
  String get homePermissionsNotification => 'Уведомления';

  @override
  String get homePermissionsLocation => 'Местоположение';

  @override
  String get homePermissionsCallPhone => 'Телефонные звонки';

  @override
  String get homePermissionsSendSms => 'Отправка SMS';

  @override
  String get homeSimulate => 'Симуляция';

  @override
  String get homeActiveSession => 'Активная сессия';

  @override
  String get homeResumeSession => 'Продолжить';

  @override
  String get homeNoModes => 'Нет режимов. Нажмите «Режимы», чтобы добавить.';

  @override
  String get homeNoContacts =>
      'Нет экстренных контактов. Нажмите «Контакты», чтобы добавить.';

  @override
  String get homeContactsBannerNone => 'Экстренные контакты не настроены.';

  @override
  String get homeMenuSettings => 'Настройки';

  @override
  String get homeMenuContacts => 'Контакты';

  @override
  String get homeMenuModes => 'Режимы';

  @override
  String get homeMenuHistory => 'Прошлые сессии';

  @override
  String get homeSelectMode => 'Выберите режим';

  @override
  String get onboardingWelcomeTitle => 'Добро пожаловать в Guardian Angela';

  @override
  String get onboardingWelcomeBody =>
      'Спутник, который помогает вам безопасно добраться домой. Guardian Angela присматривает за вами, пока вы идёте, бегаете или путешествуете, и может предупредить выбранных вами контактов, если вам понадобится помощь.';

  @override
  String get onboardingProfileTitle => 'Профиль и первый контакт';

  @override
  String get onboardingProfileBody =>
      'Расскажите немного о себе, чтобы Guardian Angela могла поделиться полезной информацией, если понадобится экстренная помощь. Затем добавьте одного доверенного контакта.';

  @override
  String get onboardingPermissionsTitle => 'Разрешения';

  @override
  String get onboardingPermissionsBody =>
      'Guardian Angela нужно несколько разрешений, чтобы обеспечить вашу безопасность. Предоставьте их сейчас или позже в «Настройках».';

  @override
  String get onboardingNext => 'Далее';

  @override
  String get onboardingSkip => 'Пропустить';

  @override
  String get onboardingFinish => 'Завершить';

  @override
  String get sessionTitle => 'Сессия';

  @override
  String get sessionDisarm => 'Я в безопасности';

  @override
  String get sessionPause => 'Пауза';

  @override
  String get sessionResume => 'Продолжить';

  @override
  String get sessionHoldPrompt =>
      'Удерживайте, чтобы оставаться в безопасности';

  @override
  String get sessionHoldSemantic =>
      'Удерживайте нажатым. Отпускание запускает льготный период.';

  @override
  String sessionStepLabel(Object index, Object total) {
    return 'Шаг $index из $total';
  }

  @override
  String sessionMissCount(Object count) {
    return 'Пропущено: $count';
  }

  @override
  String sessionRemaining(Object seconds) {
    return 'Осталось $seconds с';
  }

  @override
  String get sessionPausedBadge => 'Пауза';

  @override
  String get sessionPhaseEnded => 'Сессия завершена';

  @override
  String get sessionSimulationBanner => 'Симуляция';

  @override
  String get sessionCheckIn => 'Я отметился';

  @override
  String get sessionDisarmTriggerTitle => 'Сработал триггер отключения';

  @override
  String get sessionDisarmTriggerBody =>
      'Сработал триггер отключения. Завершить сессию?';

  @override
  String get sessionDisarmTriggerConfirm => 'Завершить сессию';

  @override
  String get sessionDisarmTriggerCancel => 'Продолжить';

  @override
  String get wrongPinAngelaTitle => 'Старый PIN от Angela';

  @override
  String get wrongPinAngelaBody =>
      'Вы уверены, что хотите продолжить с этим старым PIN?';

  @override
  String get wrongPinAngelaConfirm => 'ОК';

  @override
  String get wrongPinAngelaCancel => 'Отмена';

  @override
  String get sessionStepCountdownTitle => 'Предупреждение';

  @override
  String get sessionStepCountdownBody =>
      'Следующая эскалация сработает по окончании отсчёта. Проведите по «Я в безопасности» ниже, чтобы отключить.';

  @override
  String get sessionStepDisguisedDefaultTitle => 'Напоминание';

  @override
  String get sessionStepDisguisedDefaultBody =>
      'Нажмите «Я отметился», чтобы подтвердить, что вы в безопасности.';

  @override
  String get sessionStepSmsStatus => 'Отправка сообщения контактам…';

  @override
  String get sessionStepSmsDelivered => 'Доставлено';

  @override
  String get sessionStepSmsSent => 'Отправлено';

  @override
  String get sessionStepSmsQueued => 'В очереди';

  @override
  String get sessionStepSmsFailed => 'Ошибка';

  @override
  String get sessionStepPhoneCallStatus => 'Звонок экстренному контакту…';

  @override
  String get sessionStepPhoneCallCancel => 'Отменить звонок';

  @override
  String get sessionStepLoudAlarmTitle => 'Тревога активна';

  @override
  String get sessionStepLoudAlarmBody =>
      'Звучит тревожный сигнал, чтобы привлечь внимание.';

  @override
  String get sessionStepLoudAlarmFlashWarning =>
      'Предупреждение для светочувствительных: экран мигает.';

  @override
  String get sessionStepCallEmergencyStatus => 'Вызов экстренных служб…';

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
    return 'Нажмите $button $count раз(а) в течение $windowMs мс';
  }

  @override
  String sessionStepHardwareButtonLong(Object button, Object seconds) {
    return 'Удерживайте $button $seconds с';
  }

  @override
  String get sessionStepHardwareButtonVolumeUp => 'громкость вверх';

  @override
  String get sessionStepHardwareButtonVolumeDown => 'громкость вниз';

  @override
  String get sessionStepHardwareButtonPower => 'питание';

  @override
  String get sessionCompletedTitle => 'Сессия завершена';

  @override
  String get sessionCompletedBody =>
      'Вы благополучно добрались. Guardian Angela отключается.';

  @override
  String get sessionCompletedReturnHome => 'Вернуться на главную';

  @override
  String get simulationSummaryTitle => 'Итоги симуляции';

  @override
  String get simulationSummaryEmpty =>
      'Во время этой симуляции шаги не сработали.';

  @override
  String get simulationSummaryReturn => 'Вернуться на главную';

  @override
  String get fakeCallTitle => 'Входящий вызов';

  @override
  String get fakeCallAnswer => 'Ответить';

  @override
  String get fakeCallDecline => 'Отклонить';

  @override
  String get fakeCallHangUp => 'Завершить вызов';

  @override
  String get fakeCallSlideToAnswer => 'проведите, чтобы ответить';

  @override
  String get fakeCallUnknownCaller => 'Неизвестный';

  @override
  String get fakeCallIncomingWhatsapp => 'Голосовой вызов WhatsApp';

  @override
  String get fakeCallIncomingTelegram => 'Голосовой вызов Telegram';

  @override
  String get fakeCallIncomingSignal => 'Голосовой вызов Signal';

  @override
  String get fakeCallBrandWhatsapp => 'WHATSAPP';

  @override
  String get fakeCallBrandTelegram => 'TELEGRAM';

  @override
  String get fakeCallBrandSignal => 'SIGNAL';

  @override
  String get contactsTitle => 'Экстренные контакты';

  @override
  String get contactsEmpty =>
      'Контактов пока нет. Добавьте один, чтобы получать сообщения о помощи.';

  @override
  String get contactsAdd => 'Добавить контакт';

  @override
  String get contactFormTitleCreate => 'Новый контакт';

  @override
  String get contactFormTitleEdit => 'Изменить контакт';

  @override
  String get contactFieldName => 'Имя';

  @override
  String get contactFieldPhone => 'Номер телефона';

  @override
  String get contactFieldRelationship => 'Отношение (необязательно)';

  @override
  String get contactFieldLanguage => 'Язык SMS (необязательно)';

  @override
  String get contactLanguageDefault => 'По умолчанию (язык приложения)';

  @override
  String get contactChannelsHeader => 'Каналы сообщений';

  @override
  String get contactChannelSms => 'SMS';

  @override
  String get contactChannelWhatsapp => 'WhatsApp';

  @override
  String get contactChannelTelegram => 'Telegram';

  @override
  String get contactChannelPhone => 'Телефонный звонок';

  @override
  String get contactDeleteConfirm => 'Удалить контакт?';

  @override
  String contactDeleteBody(Object name) {
    return '$name будет удалён из списка экстренных контактов.';
  }

  @override
  String get contactRequiredError => 'Имя и номер телефона обязательны.';

  @override
  String get modesTitle => 'Режимы';

  @override
  String get modesEmpty =>
      'Режимов пока нет. Нажмите «Добавить», чтобы создать режим.';

  @override
  String get modesAdd => 'Добавить режим';

  @override
  String get modesNewPickerTitle => 'Создать из';

  @override
  String get modesNewPickerBlank => 'Пустой режим';

  @override
  String get modesNewPickerBlankSubtitle => 'Начать с пустой цепочки';

  @override
  String modesNewPickerFromTemplate(String name) {
    return 'Из «$name»';
  }

  @override
  String get modesNewPickerFromTemplateSubtitle =>
      'Скопировать цепочку и триггеры этого режима';

  @override
  String modesNewPickerCopyName(String name) {
    return 'Копия «$name»';
  }

  @override
  String get modesNewPickerBuiltinBadge => 'Встроенный';

  @override
  String get modeEditorTitleCreate => 'Новый режим';

  @override
  String get modeEditorTitleEdit => 'Изменить режим';

  @override
  String get modeFieldName => 'Название';

  @override
  String get modeFieldDistressMode => 'Режим тревоги';

  @override
  String get modeFieldDistressModeDefault => 'По умолчанию';

  @override
  String get modeChainHeader => 'Цепочка';

  @override
  String get modeChainAddStep => 'Добавить шаг';

  @override
  String get modeChainEmpty => 'Шагов пока нет. Нажмите «Добавить шаг».';

  @override
  String get modeFieldIcon => 'Значок';

  @override
  String get modeIconPickerTitle => 'Выбрать значок';

  @override
  String get modeIconClear => 'Без значка';

  @override
  String get modeDistressHeader => 'Триггеры тревоги';

  @override
  String get modeDistressEmpty => 'Триггеры не настроены.';

  @override
  String get modeDistressAdd => 'Добавить триггер';

  @override
  String get modeDistressTypeHardware => 'Аппаратная кнопка';

  @override
  String get modeDistressButtonType => 'Кнопка';

  @override
  String get modeDistressButtonVolumeUp => 'Громкость +';

  @override
  String get modeDistressButtonVolumeDown => 'Громкость −';

  @override
  String get modeDistressButtonPower => 'Питание';

  @override
  String get modeDistressPattern => 'Шаблон';

  @override
  String get modeDistressPatternRepeat => 'Повторное нажатие';

  @override
  String get modeDistressPatternLong => 'Долгое нажатие';

  @override
  String get modeDistressPressCount => 'Число нажатий';

  @override
  String get modeDistressPressWindow => 'Окно (мс)';

  @override
  String get modeDistressLongDuration => 'Длительность (секунды)';

  @override
  String modeDistressSummaryRepeat(Object count, Object windowMs) {
    return '$count нажатий / $windowMs мс';
  }

  @override
  String modeDistressSummaryLong(Object seconds) {
    return 'Удерживать $secondsс';
  }

  @override
  String get modeOverridesHeader => 'Переопределения режима';

  @override
  String get modeOverridesUseDefault => 'По умолчанию';

  @override
  String get modeOverridesGpsLabel => 'Запись GPS';

  @override
  String get modeOverridesStealthLabel => 'Маскировка';

  @override
  String get modeOverridesEventDefaultsLabel =>
      'Значения по умолчанию для событий';

  @override
  String get modeOverridesLocalTemplatesLabel =>
      'Локальные шаблоны напоминаний';

  @override
  String get modeOverridesGpsEnabled => 'GPS включён';

  @override
  String get modeOverridesGpsIntervalLabel => 'Интервал (секунды)';

  @override
  String get modeOverridesGpsIncludeInSms => 'Добавлять координаты в SMS';

  @override
  String get modeOverridesStealthEnabled => 'Маскировка включена';

  @override
  String get modeOverridesStealthFakeName => 'Фальшивое имя приложения';

  @override
  String get modeOverridesEventDefaultsHint =>
      'Свои значения по умолчанию активны для этого режима.';

  @override
  String modeOverridesLocalTemplatesCount(Object count) {
    return '$count локальных шаблонов';
  }

  @override
  String get modeUnsavedTitle => 'Отменить изменения?';

  @override
  String get modeUnsavedBody =>
      'Есть несохранённые изменения. Отменить и выйти?';

  @override
  String get modeUnsavedDiscard => 'Отменить';

  @override
  String get modeUnsavedKeep => 'Продолжить';

  @override
  String get stepDuplicate => 'Дублировать шаг';

  @override
  String get stepTimingHeader => 'Тайминг';

  @override
  String stepTimingSummary(Object wait, Object duration, Object grace) {
    return 'ожидание $waitс / длительность $durationс / льготный $graceс';
  }

  @override
  String get stepCategoryAll => 'Все';

  @override
  String get stepPickerMore => 'Больше вариантов...';

  @override
  String get stepCategoryAction => 'Действие';

  @override
  String get stepCategoryReminder => 'Напоминание';

  @override
  String get stepCategoryDisarm => 'Регистрация';

  @override
  String get modeTrackingHeader => 'Отслеживание GPS';

  @override
  String get modeTrackingEnabled => 'Записывать GPS во время сеанса';

  @override
  String get modeTrackingIntervalLabel => 'Интервал записи';

  @override
  String get modeTrackingBufferSizeLabel => 'Размер буфера';

  @override
  String modeTrackingBufferSizeValue(Object count) {
    return '$count точек';
  }

  @override
  String get modeTrackingBatteryNote =>
      'Частая запись GPS увеличивает расход батареи.';

  @override
  String get stepConfigLogGpsLabel => 'Запись GPS';

  @override
  String get stepConfigLogGpsDefault => 'По умолчанию';

  @override
  String get stepConfigLogGpsOn => 'Вкл.';

  @override
  String get stepConfigLogGpsOff => 'Выкл.';

  @override
  String get stepConfigLogGpsDefaultOn => 'По умолчанию (Вкл.)';

  @override
  String get stepConfigLogGpsDefaultOff => 'По умолчанию (Выкл.)';

  @override
  String get moreSettingsHeader => 'Дополнительные настройки';

  @override
  String moreSettingsHeaderCustomized(int count) {
    return 'Дополнительные настройки ($count изменено)';
  }

  @override
  String get stepTypePickerLabel => 'Тип шага';

  @override
  String get stepTypeHoldButton => 'Удержание кнопки';

  @override
  String get stepTypeDisguisedReminder => 'Замаскированное напоминание';

  @override
  String get stepTypeCountdownWarning => 'Обратный отсчёт';

  @override
  String get stepTypeFakeCall => 'Ложный вызов';

  @override
  String get stepTypeSmsContact => 'SMS контакту';

  @override
  String get stepTypePhoneCallContact => 'Звонок контакту';

  @override
  String get stepTypeLoudAlarm => 'Громкая тревога';

  @override
  String get stepTypeCallEmergency => 'Экстренный вызов';

  @override
  String get stepTypeHardwareButton => 'Аппаратная кнопка';

  @override
  String get stepFieldDuration => 'Длительность (секунды)';

  @override
  String get stepFieldGrace => 'Льготный период (секунды)';

  @override
  String get stepFieldWait => 'Ожидание (секунды)';

  @override
  String get stepFieldRetryCount => 'Количество повторов';

  @override
  String get stepFieldRandomize => 'Случайные колебания';

  @override
  String get stepFieldRandomizeToggle => 'Случайное время (±20%)';

  @override
  String get stepFieldWaitTooltip => 'Сколько ждать перед началом этого шага.';

  @override
  String get stepFieldDurationTooltip =>
      'Сколько шаг активен до начала льготного периода.';

  @override
  String get stepFieldGraceTooltip =>
      'Время после активной фазы для подтверждения безопасности перед следующим шагом.';

  @override
  String get stepFieldRetryCountTooltip =>
      'Сколько раз повторить этот шаг до эскалации.';

  @override
  String get stepFieldReminderIntervalTooltip =>
      'Как часто срабатывает замаскированное напоминание в ожидании подтверждения.';

  @override
  String get stepFieldReminderGraceTooltip =>
      'Сколько времени у пользователя на подтверждение безопасности после появления напоминания.';

  @override
  String get stepPreview => 'Предпросмотр в симуляции';

  @override
  String stepPreviewFired(Object description) {
    return 'Предпросмотр выполнен: $description';
  }

  @override
  String get stepPreviewTitle => 'Предпросмотр шага';

  @override
  String get stepPreviewMissingParams => 'Отсутствует ссылка на шаг или режим.';

  @override
  String get stepPreviewModeNotFound => 'Режим не найден.';

  @override
  String get stepPreviewStepNotFound => 'Шаг не найден в этом режиме.';

  @override
  String stepPreviewError(Object error) {
    return 'Сбой предпросмотра: $error';
  }

  @override
  String get stepPreviewReplay => 'Повторить';

  @override
  String get stepPreviewHoldButtonHint =>
      'Удерживайте кнопку, чтобы почувствовать реальный отклик.';

  @override
  String get stepPreviewHoldButtonLabel => 'Удерживать';

  @override
  String get stepPreviewHoldButtonSemantic => 'Удерживайте для предпросмотра';

  @override
  String get stepPreviewHoldButtonReleased =>
      'Отпущено. Сейчас сессия перешла бы в окно отсрочки.';

  @override
  String get stepPreviewFakeCallHint =>
      'Появится экран ложного звонка. Проведите для ответа или удерживайте красную кнопку, чтобы имитировать тревогу.';

  @override
  String get stepConfigFakeCallCaller => 'Имя вызывающего';

  @override
  String get stepConfigFakeCallDecline => 'Отклонение считается отменой';

  @override
  String get stepConfigLoudAlarmFlash => 'Мигание экрана';

  @override
  String get stepConfigLoudAlarmVolume => 'Максимальная громкость';

  @override
  String get stepConfigCountdownVibrate => 'Вибрация';

  @override
  String get stepConfigCountdownTone => 'Воспроизводить звук';

  @override
  String get stepConfigSmsSelection => 'Получатели';

  @override
  String get stepConfigSmsAllContacts => 'Все контакты';

  @override
  String get stepConfigSmsSpecific => 'Определённые контакты';

  @override
  String get stepConfigSmsIncludeLocation => 'Включить местоположение';

  @override
  String get stepConfigSmsIncludeMedical => 'Включить медицинскую информацию';

  @override
  String get stepConfigSmsAutoRecordAudio => 'Автозапись аудио';

  @override
  String get stepConfigSmsAutoRecordVideo => 'Автозапись видео';

  @override
  String get stepConfigSmsRecordDuration => 'Длительность записи';

  @override
  String get stepConfigHoldReleaseSensitivity =>
      'Чувствительность отпускания (с)';

  @override
  String get stepConfigReminderInterval => 'Интервал напоминаний (секунды)';

  @override
  String get stepConfigReminderTemplate => 'Шаблон';

  @override
  String get stepConfigHardwarePattern => 'Шаблон';

  @override
  String get stepConfigHardwarePressCount => 'Количество нажатий';

  @override
  String get stepConfigHardwarePressWindow => 'Окно между нажатиями (мс)';

  @override
  String get stepConfigHardwareLongDuration =>
      'Длительность долгого нажатия (с)';

  @override
  String get stepConfigHardwareButton => 'Кнопка';

  @override
  String get stepConfigHardwareButtonVolumeUp => 'Громкость вверх';

  @override
  String get stepConfigHardwareButtonVolumeDown => 'Громкость вниз';

  @override
  String get stepConfigHardwareButtonPower => 'Питание';

  @override
  String get stepConfigHardwarePatternRepeat => 'Повторное нажатие';

  @override
  String get stepConfigHardwarePatternLong => 'Долгое нажатие';

  @override
  String get stepConfigEmergencyNumber => 'Переопределение экстренного номера';

  @override
  String get stepConfigEmergencyConfirm => 'Подтвердить перед вызовом';

  @override
  String get stepConfigPhonePreSms => 'Отправить SMS перед звонком';

  @override
  String get distressModesTitle => 'Режимы тревоги';

  @override
  String get distressModeInUseTitle => 'Режим тревоги используется';

  @override
  String distressModeInUseBody(Object modes) {
    return 'Этот режим тревоги по-прежнему привязан к: $modes. Прежде чем удалить, привяжите эти режимы к другому режиму тревоги.';
  }

  @override
  String get distressModesEmpty => 'Режимов тревоги пока нет.';

  @override
  String get distressModesAdd => 'Добавить режим тревоги';

  @override
  String get distressModeEditorTitleCreate => 'Новый режим тревоги';

  @override
  String get distressModeEditorTitleEdit => 'Изменить режим тревоги';

  @override
  String get distressModeName => 'Название режима тревоги';

  @override
  String get distressCountdown => 'Запуск режима тревоги...';

  @override
  String get distressCountdownStealth => 'Пожалуйста, подождите...';

  @override
  String get templatesTitle => 'Шаблоны напоминаний';

  @override
  String get templatesEmpty => 'Шаблонов пока нет.';

  @override
  String get templatesAdd => 'Добавить шаблон';

  @override
  String get templateEditorTitleCreate => 'Новый шаблон';

  @override
  String get templateEditorTitleEdit => 'Изменить шаблон';

  @override
  String get templateFieldName => 'Название в редакторе';

  @override
  String get templateFieldTitle => 'Заголовок напоминания';

  @override
  String get templateFieldBody => 'Текст напоминания';

  @override
  String get templateFieldConfirmationType => 'Тип подтверждения';

  @override
  String get templateFieldKeyword => 'Ключевое слово';

  @override
  String get templateFieldButtonLabel => 'Надпись кнопки';

  @override
  String get templateFieldDisplayStyle => 'Стиль отображения';

  @override
  String get templateConfirmTapButton => 'Нажать кнопку';

  @override
  String get templateConfirmTapWord => 'Нажать слово';

  @override
  String get templateConfirmSwipe => 'Свайп';

  @override
  String get templateConfirmDismiss => 'Отклонить';

  @override
  String get templateDisplayFullscreen => 'На весь экран';

  @override
  String get templateDisplaySubtle => 'Незаметно';

  @override
  String get profileTitle => 'Профиль';

  @override
  String get profileFieldName => 'Имя';

  @override
  String get profileFieldAge => 'Возраст';

  @override
  String get profileFieldPhoneNumber => 'Номер телефона';

  @override
  String get profileFieldPhysicalDescription => 'Физическое описание';

  @override
  String get profileFieldBloodType => 'Группа крови';

  @override
  String get profileFieldAllergies => 'Аллергии';

  @override
  String get profileFieldMedications => 'Лекарства';

  @override
  String get profileFieldConditions => 'Медицинские состояния';

  @override
  String get profileFieldInstructions => 'Экстренные инструкции';

  @override
  String get profileAddItem => 'Добавить пункт';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get settingsSectionSecurity => 'Безопасность';

  @override
  String get settingsSectionStealth => 'Скрытность';

  @override
  String get settingsSectionDefaults => 'По умолчанию';

  @override
  String get settingsSectionHistory => 'История';

  @override
  String get settingsSectionBackup => 'Резервное копирование';

  @override
  String get settingsSectionAbout => 'О приложении';

  @override
  String get settingsSectionFeedback => 'Отзывы';

  @override
  String get settingsSectionContacts => 'Контакты';

  @override
  String get settingsSectionModes => 'Режимы';

  @override
  String get settingsSectionProfile => 'Профиль';

  @override
  String get settingsSectionDistressModes => 'Режимы тревоги';

  @override
  String get settingsSectionReminderTemplates => 'Шаблоны напоминаний';

  @override
  String get settingsSectionBatteryAlert => 'Оповещение о батарее';

  @override
  String get settingsSectionEventDefaults => 'Шаги по умолчанию';

  @override
  String get settingsSectionGpsLogging => 'Запись GPS';

  @override
  String get settingsSectionNotifications => 'Уведомления';

  @override
  String get settingsSectionHistoryRetention => 'Хранение истории';

  @override
  String get settingsSectionAppearance => 'Внешний вид';

  @override
  String get settingsThemeMode => 'Тема';

  @override
  String get settingsThemeLight => 'Светлая';

  @override
  String get settingsThemeDark => 'Тёмная';

  @override
  String get settingsThemeSystem => 'Системная';

  @override
  String get settingsLanguage => 'Язык';

  @override
  String get settingsEmergencyNumber => 'Экстренный номер';

  @override
  String get settingsAlarmDnd => 'Тревога игнорирует режим «Не беспокоить»';

  @override
  String get settingsLanguagePicker => 'Язык';

  @override
  String get settingsEmergencyNumberLabel => 'Номер экстренной помощи';

  @override
  String get settingsEmergencyNumberHint => 'напр., 112';

  @override
  String get settingsEmergencyNumberSave => 'Сохранить';

  @override
  String get settingsRedoOnboarding => 'Повторить знакомство';

  @override
  String get settingsRedoOnboardingConfirm => 'Начать знакомство заново?';

  @override
  String get settingsRedoOnboardingBody =>
      'Ваша текущая конфигурация сохраняется.';

  @override
  String get settingsRedoOnboardingProceed => 'Начать заново';

  @override
  String get settingsAlarmGradualVolume => 'Постепенное нарастание тревоги';

  @override
  String settingsAlarmGradualVolumeDuration(int seconds) {
    return 'Длительность нарастания: $seconds с';
  }

  @override
  String get securityTitle => 'Безопасность';

  @override
  String get securityAppPin => 'PIN приложения';

  @override
  String get securitySessionEndPin => 'PIN завершения сессии';

  @override
  String get securityDuressPin => 'PIN принуждения';

  @override
  String get securityAppPinBiometric =>
      'Использовать биометрию для PIN приложения';

  @override
  String get securitySessionEndPinBiometric =>
      'Использовать биометрию для PIN завершения сессии';

  @override
  String get securityDistressCancelBiometric =>
      'Использовать биометрию для отмены тревоги';

  @override
  String get securityDuressTest => 'Проверить PIN принуждения';

  @override
  String get securityDuressTestSubtitle =>
      'Убедитесь, что ваш PIN принуждения работает.';

  @override
  String get securityPinTimeout => 'Таймаут PIN (секунды)';

  @override
  String get securityDisablePin => 'Отключить';

  @override
  String get securitySetPin => 'Задать PIN';

  @override
  String get securityChangePin => 'Изменить PIN';

  @override
  String get pinSetupTitle => 'Задать PIN';

  @override
  String get pinSetupEnter => 'Введите новый PIN';

  @override
  String get pinSetupConfirm => 'Подтвердите PIN';

  @override
  String get pinSetupMismatch => 'PIN-коды не совпадают. Попробуйте снова.';

  @override
  String get pinEntryTitle => 'Введите PIN';

  @override
  String get pinEntrySubtitle => 'Введите PIN, чтобы продолжить.';

  @override
  String get pinEntryBiometricReason =>
      'Подтвердите личность, чтобы продолжить';

  @override
  String get stealthTitle => 'Скрытность';

  @override
  String get stealthEnable => 'Включить скрытный режим';

  @override
  String get stealthFakeName => 'Ложное имя приложения';

  @override
  String get stealthFakeIcon => 'Ложный значок';

  @override
  String get stealthNotificationDisguise => 'Маскировать уведомления';

  @override
  String get stealthTimerDisplay => 'Показывать таймер в скрытном режиме';

  @override
  String get stealthTimerDisplayNormal => 'Показывать полный текст';

  @override
  String get stealthTimerDisplaySmall => 'Только цифры';

  @override
  String get stealthTimerDisplayNone => 'Скрыть таймер';

  @override
  String get stealthSessionScreen => 'Убрать брендинг на экране сессии';

  @override
  String get stealthPickerTitle => 'Значок приложения';

  @override
  String get stealthPickerIntro =>
      'Выберите, как будет выглядеть значок на главном экране.';

  @override
  String get stealthPresetMusic => 'Музыка';

  @override
  String get stealthPresetCalendar => 'Календарь';

  @override
  String get stealthPresetFitness => 'Фитнес';

  @override
  String get stealthPresetWeather => 'Погода';

  @override
  String get stealthPresetNews => 'Новости';

  @override
  String get stealthPresetPhotos => 'Фото';

  @override
  String get stealthPresetNotes => 'Заметки';

  @override
  String get stealthPresetClock => 'Часы';

  @override
  String get distressConfirmationTitle => 'Вы в опасности?';

  @override
  String get distressConfirmationCancel => 'Отмена';

  @override
  String distressConfirmationCountdown(Object seconds) {
    return 'Режим тревоги сработает через $seconds с';
  }

  @override
  String get imSafeSliderLabel =>
      'Проведите, чтобы подтвердить «Я в безопасности»';

  @override
  String get batteryAlertTitle => 'Оповещение о батарее';

  @override
  String get batteryAlertEnable => 'Включить оповещение о батарее';

  @override
  String batteryAlertThreshold(Object percent) {
    return 'Порог: $percent%';
  }

  @override
  String get eventDefaultsTitle => 'Шаги по умолчанию';

  @override
  String get eventDefaultsBody =>
      'Эти значения применяются к любому шагу, который их не переопределяет.';

  @override
  String get gpsLoggingTitle => 'Запись GPS';

  @override
  String get gpsLoggingEnable => 'Включить запись GPS';

  @override
  String get gpsLoggingInterval => 'Интервал замеров (секунды)';

  @override
  String get gpsLoggingAccuracy => 'Точность';

  @override
  String get gpsAccuracyLow => 'Низкая';

  @override
  String get gpsAccuracyMedium => 'Средняя';

  @override
  String get gpsAccuracyHigh => 'Высокая';

  @override
  String get gpsLoggingIncludeSms => 'Прикреплять местоположение к SMS';

  @override
  String get gpsLoggingHistoryDays => 'Хранение истории (дней)';

  @override
  String get notificationSettingsTitle => 'Уведомления';

  @override
  String get notificationSettingsBody =>
      'Guardian Angela использует уведомления для маскировки и напоминаний.';

  @override
  String get historyRetentionTitle => 'Хранение истории';

  @override
  String get historyRetentionBody =>
      'Как долго Guardian Angela хранит журналы прошлых сессий.';

  @override
  String historyRetentionDays(Object days) {
    return 'Хранение: $days дн.';
  }

  @override
  String get backupTitle => 'Резервное копирование';

  @override
  String get backupExport => 'Экспорт данных';

  @override
  String get backupImport => 'Импорт данных';

  @override
  String get backupNotReady =>
      'Резервное копирование пока недоступно. Скоро появится.';

  @override
  String get backupPinOptional => 'Необязательный PIN (шифрует пакет)';

  @override
  String get backupImportOk => 'Резервная копия успешно импортирована.';

  @override
  String get backupSelectionHeader => 'Включить в экспорт';

  @override
  String get backupToggleSettings => 'Настройки';

  @override
  String get backupToggleSettingsSubtitle =>
      'Включаются всегда, чтобы резервную копию можно было восстановить.';

  @override
  String get backupToggleContacts => 'Экстренные контакты';

  @override
  String get backupToggleModes => 'Режимы';

  @override
  String get backupToggleDistressModes => 'Режимы тревоги';

  @override
  String get backupToggleTemplates => 'Шаблоны напоминаний';

  @override
  String get backupToggleSessionLogs => 'История сессий';

  @override
  String get backupToggleRecordings => 'Аудиозаписи';

  @override
  String get historyTitle => 'Прошлые сессии';

  @override
  String get historyEmpty => 'Прошлых сессий пока нет.';

  @override
  String get historyTabReal => 'Реальные';

  @override
  String get historyTabSimulated => 'Симуляция';

  @override
  String get historySearchHint => 'Поиск по названию режима';

  @override
  String get historyFilterModeAll => 'Все режимы';

  @override
  String get historyFilterModeLabel => 'Режим';

  @override
  String get historyDateRangePick => 'Диапазон дат';

  @override
  String get historyDetailTitle => 'Сведения о сессии';

  @override
  String get evidenceExportTitle => 'Экспорт доказательств';

  @override
  String get evidenceExportAsText => 'Скопировать как текст';

  @override
  String get evidenceExportAsJson => 'Скопировать как JSON';

  @override
  String get evidenceCopied => 'Скопировано в буфер обмена.';

  @override
  String get aboutTitle => 'О приложении';

  @override
  String get aboutVersion => 'Версия';

  @override
  String get aboutCredits => 'Сделано с заботой о тех, кто возвращается домой.';

  @override
  String get feedbackTitle => 'Отзывы';

  @override
  String get feedbackBody => 'Мы будем рады услышать от вас.';

  @override
  String get feedbackFieldMessage => 'Сообщение';

  @override
  String get feedbackSend => 'Открыть email';

  @override
  String get pickerNoneLabel => '— нет —';

  @override
  String emergencyConfirmTitle(Object number) {
    return 'Звонок на $number';
  }

  @override
  String get emergencyConfirmSubtitle =>
      'Удерживайте кнопку отмены, чтобы прервать.';

  @override
  String emergencyConfirmCountdown(Object seconds) {
    return 'Звонок через $seconds с';
  }

  @override
  String get emergencyConfirmCancel => 'Отмена';

  @override
  String get stealthCalendarUpcoming => 'Предстоящие';

  @override
  String get stealthCalendarUpcomingEvent => 'Встреча';

  @override
  String stealthCalendarUntilEvent(Object minutes) {
    return 'через $minutes мин';
  }

  @override
  String get stealthCalendarToday => 'Сегодня';

  @override
  String get stealthCalendarEvent1 => 'Кофе с Алексом';

  @override
  String get stealthCalendarEvent2 => 'Стендап';

  @override
  String get stealthCalendarEvent3 => 'Обед';

  @override
  String get stealthCalendarEvent4 => 'Тренировка';

  @override
  String get stealthCalendarEvent5 => 'Ужин с Сэмом';

  @override
  String get stealthDisarmGestureHint => 'Проведите вверх, чтобы завершить';

  @override
  String get stealthMusicTrackTitle => 'Без названия';

  @override
  String get stealthMusicArtist => 'Неизвестный исполнитель';

  @override
  String get stealthMusicAlbum => 'Неизвестный альбом';

  @override
  String get stealthMusicNowPlaying => 'Сейчас играет';

  @override
  String get stealthMusicSwipeHint => 'Проведите для отключения';

  @override
  String get stealthMusicPrevious => 'Предыдущий';

  @override
  String get stealthMusicPause => 'Пауза';

  @override
  String get stealthMusicNext => 'Следующий';

  @override
  String get stealthPodcastShowName => 'Подкаст';

  @override
  String get stealthPodcastEpisodeTitle => 'Эпизод';

  @override
  String get stealthPodcastEpisodesHeader => 'Эпизоды';

  @override
  String get stealthPodcastSpeedLabel => '1x';

  @override
  String get stealthPodcastEpisode1 => 'Эпизод 1';

  @override
  String get stealthPodcastEpisode2 => 'Эпизод 2';

  @override
  String get stealthPodcastEpisode3 => 'Эпизод 3';

  @override
  String get stealthPodcastEpisode4 => 'Эпизод 4';

  @override
  String get stealthPresetPodcast => 'Подкаст';

  @override
  String get stealthPresetNone => 'Нет';

  @override
  String get sessionSimSpeedLabel => 'Скорость';

  @override
  String sessionSimSpeedValue(Object value) {
    return '${value}x';
  }

  @override
  String get sessionSimSpeedBackgroundCap => 'Ограничено 60× в фоне';

  @override
  String get sessionSimAdvancedLabel => 'Дополнительно';

  @override
  String get sessionSimTriggerPanic => 'Запустить тревогу';

  @override
  String get sessionSimTriggerArrival => 'Имитировать прибытие';

  @override
  String get sessionSimTriggerBattery => 'Имитировать низкий заряд';

  @override
  String get simulateGpsArrival => 'Имитировать прибытие';

  @override
  String get simulateLowBattery => 'Имитировать низкий заряд';

  @override
  String get launchGateTitle => 'Разблокировать Guardian Angela';

  @override
  String get launchGateSubtitle => 'Введите PIN или используйте биометрию.';

  @override
  String get launchGateWrong => 'Неверный PIN';

  @override
  String get launchGateBiometricReason => 'Разблокировать Guardian Angela';

  @override
  String get launchGateUseBiometric => 'Использовать биометрию';

  @override
  String get audioRunningLatePhrase => 'Привет, я опаздываю. Скоро перезвоню.';

  @override
  String smsDefaultTemplate(Object name, Object location, Object time) {
    return '$name может нуждаться в помощи. Местоположение: $location. Время: $time.';
  }

  @override
  String smsDefaultPreCallTemplate(Object name) {
    return '$name пытается с вами связаться. Ожидайте звонка.';
  }

  @override
  String simLoudAlarm(Object tail) {
    return '[SIM] Громкая тревога + $tail';
  }

  @override
  String get simLoudAlarmTailFlash => 'вспышка';

  @override
  String get simLoudAlarmTailVibrate => 'вибрация';

  @override
  String simSmsContact(Object channel, int count) {
    return '[SIM] Отправил бы $channel $count контактам';
  }

  @override
  String simFakeCallRing(Object caller) {
    return '[SIM] Входящий вызов от $caller';
  }

  @override
  String simCountdownWarning(int seconds) {
    return '[SIM] Предупреждение об обратном отсчёте $secondsс';
  }

  @override
  String simPhoneCall(Object name) {
    return '[SIM] Позвонил бы $name';
  }

  @override
  String get simNoContactToCall => '[SIM] Нет контакта для звонка';

  @override
  String simCallEmergency(Object number) {
    return '[SIM] Набрал бы $number';
  }

  @override
  String get simHardwareButton => '[SIM] Аппаратный триггер вооружён';

  @override
  String get simHoldButton => '[SIM] Ожидание удержания кнопки';

  @override
  String simDisguisedReminder(Object title) {
    return '[SIM] Показал бы \"$title\"';
  }

  @override
  String get simDisguisedReminderEmpty => '[SIM] Шаблон напоминания недоступен';

  @override
  String get simGpsArrivalTrigger => '[SIM] Срабатывание триггера прибытия GPS';

  @override
  String get simLowBatteryAlert =>
      '[SIM] Срабатывание оповещения о низком заряде батареи';
}
