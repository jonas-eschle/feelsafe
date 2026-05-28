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
  String get contactFormIosSmsWarning =>
      'On iOS, SMS opens the Messages app. You must tap Send manually.';

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
  String aboutVersion(Object version) {
    return 'Версия';
  }

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
  String get stealthLockTaskLabel => 'Pin app during session';

  @override
  String get stealthLockTaskSubtitle =>
      'Prevents leaving the app while a session is running. On Android this engages screen-pinning; on other platforms this is a no-op.';

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
      'Enter the destination coordinates for the GPS arrival disarm trigger.';

  @override
  String get sessionGpsDestinationLat => 'Latitude';

  @override
  String get sessionGpsDestinationLng => 'Longitude';

  @override
  String get sessionGpsDestinationUseCurrent => 'Use current location';

  @override
  String get sessionGpsDestinationSkip => 'Skip for this session';

  @override
  String get sessionGpsDestinationConfirm => 'Use destination';

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
  String get contactsReorderHint => 'Drag to reorder';

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
  String get pastEventsSearch => 'Search by mode name';

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
  String get sessionEscalating => 'Escalating…';

  @override
  String get sessionDisarmedToast => 'Disarmed — chain reset to step 1.';

  @override
  String sessionStepNextCheckIn(Object time) {
    return 'Next check-in in $time';
  }

  @override
  String sessionStepGraceCountdown(Object time) {
    return 'Grace period: $time';
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
  String get sessionStealthMusicTrack => 'Now playing';

  @override
  String get sessionStealthMusicArtist => 'Various artists';

  @override
  String get homeStartingSession => 'Starting session…';

  @override
  String get pastEventsRestore => 'Restore';

  @override
  String get batteryAlertAddStep => 'Add step';

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
  String get eventDefaultsSavedToast => 'Saved';

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
}
