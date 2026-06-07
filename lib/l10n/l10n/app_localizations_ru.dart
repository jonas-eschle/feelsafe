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
  String get commonDelete => 'Удалить';

  @override
  String get commonEdit => 'Изменить';

  @override
  String get commonClose => 'Закрыть';

  @override
  String get commonConfirm => 'Подтвердить';

  @override
  String get commonBack => 'Назад';

  @override
  String get pinSubmit => 'Подтвердить';

  @override
  String get homeTitle => 'Guardian Angela';

  @override
  String get homeStartSession => 'Начать сессию';

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
  String get homeNoModes => 'Нет режимов. Нажмите «Режимы», чтобы добавить.';

  @override
  String get homeContactsBannerNone => 'Экстренные контакты не настроены.';

  @override
  String get homeMenuSettings => 'Настройки';

  @override
  String get homeMenuContacts => 'Контакты';

  @override
  String get homeMenuHistory => 'Прошлые сессии';

  @override
  String get onboardingProfileTitle => 'Профиль и первый контакт';

  @override
  String get onboardingPermissionsTitle => 'Разрешения';

  @override
  String get onboardingNext => 'Далее';

  @override
  String get onboardingSkip => 'Пропустить';

  @override
  String get onboardingUseSimNumber => 'Использовать номер SIM-карты';

  @override
  String onboardingUseSimNumberHint(Object number) {
    return '$number';
  }

  @override
  String get onboardingUseSimNumberUnsupported => 'Недоступно на iOS';

  @override
  String get onboardingUseSimNumberUnavailable => 'Не удалось прочитать номер';

  @override
  String get onboardingUseSimNumberPermissionDenied => 'Доступ запрещён';

  @override
  String get sessionTitle => 'Сессия';

  @override
  String get sessionDisarm => 'Я в безопасности';

  @override
  String get sessionDisarmStealth => 'Анджела не нужна';

  @override
  String get homeChainSummaryTitle => 'Сводка цепочки';

  @override
  String get homeChainSummaryEmpty =>
      'В этом режиме пока нет шагов — нажмите на режим, чтобы изменить.';

  @override
  String homeChainSummaryTimingTitle(Object name) {
    return 'Шаг: $name';
  }

  @override
  String homeChainSummaryWait(Object seconds) {
    return 'Ожидание: $seconds с';
  }

  @override
  String homeChainSummaryDuration(Object seconds) {
    return 'Активно: $seconds с';
  }

  @override
  String homeChainSummaryGrace(Object seconds) {
    return 'Льготный период: $seconds с';
  }

  @override
  String homeChainSummaryRetry(Object count) {
    return 'Повторов: $count';
  }

  @override
  String homeChainSummaryNextStep(Object name) {
    return 'Следующий шаг: $name';
  }

  @override
  String get homeChainSummaryNextStepNone => 'Следующий шаг: конец цепочки';

  @override
  String get homeChainSummaryClose => 'Закрыть';

  @override
  String get chainStepNameHoldButton =>
      'Удерживайте, чтобы быть в безопасности';

  @override
  String get chainStepNameDisguisedReminder => 'Замаскированное напоминание';

  @override
  String get chainStepNameCountdownWarning =>
      'Предупреждение с обратным отсчётом';

  @override
  String get chainStepNameFakeCall => 'Поддельный звонок';

  @override
  String get chainStepNameSmsContact => 'SMS контакту';

  @override
  String get chainStepNamePhoneCallContact => 'Звонок контакту';

  @override
  String get chainStepNameLoudAlarm => 'Громкая тревога';

  @override
  String get chainStepNameCallEmergency => 'Экстренный вызов';

  @override
  String get chainStepNameHardwareButton => 'Аппаратная кнопка';

  @override
  String get homeChecklistTitle => 'Настройка безопасности';

  @override
  String get homeChecklistDismissTooltip => 'Скрыть список';

  @override
  String get homeChecklistExpandTooltip => 'Показать список';

  @override
  String get homeChecklistCollapseTooltip => 'Свернуть список';

  @override
  String homeChecklistProgress(Object done, Object total) {
    return '$done из $total готово';
  }

  @override
  String get homeChecklistAllDoneBanner => 'Готово — вы под защитой!';

  @override
  String get homeChecklistInfoTooltip => 'Почему это важно';

  @override
  String get homeChecklistGotIt => 'Понятно';

  @override
  String get homeChecklistGoThere => 'Перейти';

  @override
  String get homeChecklistItem1Title => 'Добавить экстренный контакт';

  @override
  String get homeChecklistItem2Title => 'Задать PIN завершения сессии';

  @override
  String get homeChecklistItem3Title => 'Настроить скрытый режим';

  @override
  String get homeChecklistItem4Title => 'Запустить симуляцию';

  @override
  String get homeChecklistItem5Title => 'Настроить режим безопасности';

  @override
  String get homeChecklistItem6Title => 'Выдать необходимые разрешения';

  @override
  String get checklistInfo1Body =>
      'Экстренные контакты — это люди, которым Guardian Angela пишет и звонит, если вы не отметились вовремя. Без хотя бы одного контакта цепочке некуда передавать тревогу.';

  @override
  String get checklistInfo2Body =>
      'PIN завершения сессии не даёт злоумышленнику тихо отключить активную сессию. Он может пытаться, но пять неверных вводов молча запустят вашу тревожную цепочку.';

  @override
  String get checklistInfo3Body =>
      'Скрытый режим маскирует активную сессию под что-то безобидное на экране — музыкальный плеер, приостановленный таймер, пустой экран блокировки. Используйте, когда рядом не должны видеть, что у вас приложение безопасности.';

  @override
  String get checklistInfo4Body =>
      'Симуляция прогоняет ваш режим безопасности от начала до конца без реальных SMS, реальных звонков и громкой тревоги. Используйте её, чтобы освоить тайминги заранее.';

  @override
  String get checklistInfo5Body =>
      'Свои режимы позволяют настроить шаги, тайминги и триггеры под конкретную ситуацию — путь домой, первое свидание, ночная смена. Два встроенных режима — это отправная точка, а не конечный результат.';

  @override
  String get checklistInfo6Body =>
      'Без разрешения на уведомления Guardian Angela не сможет удерживать постоянный статус в шторке, доставлять замаскированные напоминания и предупреждать вас о приближающейся эскалации цепочки.';

  @override
  String get checklistTutorial3Body =>
      'Откройте настройки скрытого режима по умолчанию и включите «Включить скрытый режим». Там можно выбрать поддельный музыкальный бренд, скрыть таймер сессии или замаскировать значок на главном экране.';

  @override
  String get checklistTutorial4Body =>
      'На главном экране после выбора режима нажмите контурную кнопку «Симулировать». Сессия запускается с оранжевой рамкой и значком [SIM] — ничего не уходит с вашего телефона.';

  @override
  String get checklistTutorial5Body =>
      'Откройте экран Режимы и либо измените встроенный режим (Прогулка / Свидание), либо создайте новый с нуля. Подправьте цепочку, добавьте поддельный звонок, задайте свои тайминги.';

  @override
  String get sessionHoldPrompt =>
      'Удерживайте, чтобы оставаться в безопасности';

  @override
  String sessionStepLabel(Object index, Object total) {
    return 'Шаг $index из $total';
  }

  @override
  String sessionMissCount(Object count) {
    return 'Пропущено: $count';
  }

  @override
  String get sessionPausedBadge => 'Пауза';

  @override
  String get sessionPausedIncomingCall => 'Пауза — входящий вызов';

  @override
  String get sessionPhaseEnded => 'Сессия завершена';

  @override
  String get sessionSimulationBanner => 'Симуляция';

  @override
  String get sessionCheckIn => 'Я отметился';

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
  String get sessionReminderEarlyCheckInHint =>
      'Нажмите, чтобы отметиться сейчас';

  @override
  String get sessionReminderDefaultButton => 'OK';

  @override
  String get sessionReminderTapWordHint => 'Нажмите для продолжения';

  @override
  String get sessionReminderSwipeLabel => 'Проведите, чтобы закрыть';

  @override
  String get sessionReminderDismissLabel => 'Закрыть';

  @override
  String get sessionStepSmsStatus => 'Отправка сообщения контактам…';

  @override
  String get sessionStepPhoneCallStatus => 'Звонок экстренному контакту…';

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
  String get fakeCallBrandAndroid => 'ТЕЛЕФОН';

  @override
  String get fakeCallBrandIos => 'ТЕЛЕФОН';

  @override
  String get fakeCallBrandMinimal => 'ВЫЗОВ';

  @override
  String get fakeCallDeclineSafeLabel => 'Отклонить (я в безопасности)';

  @override
  String get fakeCallDeclineUnsafeLabel => 'Отклонить (оставаться начеку)';

  @override
  String get fakeCallHoldForDistress => 'Удерживайте 5 с для тревоги';

  @override
  String fakeCallVoicePrompt(String name) {
    return 'Голосовая подсказка: $name';
  }

  @override
  String fakeCallVibrationLabel(String pattern) {
    return 'Вибрация: $pattern';
  }

  @override
  String get fakeCallVibrationPatternDefault => 'по умолчанию';

  @override
  String get fakeCallSlideToAnswerHint => 'Проведите, чтобы ответить';

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
  String get contactFormIosSmsWarning =>
      'На iOS SMS открывается в приложении «Сообщения». Отправить нужно вручную.';

  @override
  String get modesTitle => 'Режимы';

  @override
  String get modesEmpty =>
      'Режимов пока нет. Нажмите «Добавить», чтобы создать режим.';

  @override
  String get modesAdd => 'Добавить режим';

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
  String get modeEditorTitleCreate => 'Новый режим';

  @override
  String get modeEditorTitleEdit => 'Изменить режим';

  @override
  String get modeFieldName => 'Название';

  @override
  String get modeChainHeader => 'Цепочка';

  @override
  String get modeChainAddStep => 'Добавить шаг';

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
  String stepTimingSummary(Object wait, Object duration, Object grace) {
    return 'ожидание $waitс / длительность $durationс / льготный $graceс';
  }

  @override
  String get stepConfigTimingHeader => 'Тайминг';

  @override
  String get stepConfigEventHeader => 'Настройка события';

  @override
  String get stepConfigAdvancedHeader => 'Повторы и дополнительно';

  @override
  String get stepFieldWait => 'Ожидание перед запуском (секунды)';

  @override
  String get stepFieldDuration => 'Длительность активности (секунды)';

  @override
  String get stepFieldGrace => 'Льготный период (секунды)';

  @override
  String get stepFieldRetryCount => 'Повторы';

  @override
  String get stepFieldRandomize => 'Случайный тайминг (±20%)';

  @override
  String get stepDuplicate => 'Дублировать шаг';

  @override
  String get stepResetDefaults => 'Сбросить к значениям по умолчанию';

  @override
  String get smsContactRecipientsHeader => 'Контакты для уведомления';

  @override
  String get smsContactSummaryAll => 'Кому: все включённые контакты';

  @override
  String get smsContactSummaryNone => 'Получатели не выбраны';

  @override
  String smsContactSummaryTo(Object names) {
    return 'Кому: $names';
  }

  @override
  String get smsContactChannelDisabledTooltip =>
      'Не включено для этого контакта — измените контакт, чтобы добавить этот канал.';

  @override
  String get smsContactEmptyAddPrompt =>
      'Контактов пока нет — добавьте один в разделе Контакты';

  @override
  String get distressModesEmpty => 'Режимов тревоги пока нет.';

  @override
  String get distressModeEditorTitleCreate => 'Новый режим тревоги';

  @override
  String get distressModeEditorTitleEdit => 'Изменить режим тревоги';

  @override
  String get templatesTitle => 'Шаблоны напоминаний';

  @override
  String get templatesEmpty => 'Шаблонов пока нет.';

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
  String get settingsThemeLight => 'Светлая';

  @override
  String get settingsThemeDark => 'Тёмная';

  @override
  String get settingsThemeSystem => 'Системная';

  @override
  String get settingsEmergencyNumberLabel => 'Номер экстренной помощи';

  @override
  String get settingsRedoOnboardingActiveSessionTooltip =>
      'Нельзя повторить знакомство во время активной сессии';

  @override
  String get settingsEmergencyNumberCountryPickerTitle =>
      'Выберите номер экстренной помощи';

  @override
  String get settingsRedoOnboarding => 'Повторить знакомство';

  @override
  String get settingsRedoOnboardingConfirm => 'Начать знакомство заново?';

  @override
  String get securitySessionEndPinBiometric =>
      'Использовать биометрию для PIN завершения сессии';

  @override
  String get securityAppPinBiometric =>
      'Использовать биометрию для блокировки приложения';

  @override
  String get launchPinTitle => 'Введите PIN приложения';

  @override
  String get launchPinBiometricReason => 'Разблокировать Guardian Angela';

  @override
  String get launchPinIncorrect => 'Неверный PIN';

  @override
  String get securitySetPin => 'Задать PIN';

  @override
  String get securityChangePin => 'Изменить PIN';

  @override
  String get pinSetupMismatch => 'PIN-коды не совпадают. Попробуйте снова.';

  @override
  String get stealthTimerDisplayNormal => 'Показывать полный текст';

  @override
  String get stealthTimerDisplaySmall => 'Только цифры';

  @override
  String get stealthTimerDisplayNone => 'Скрыть таймер';

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
  String get eventDefaultsTitle => 'Шаги по умолчанию';

  @override
  String get historyRetentionTitle => 'Хранение истории';

  @override
  String get backupTitle => 'Резервное копирование';

  @override
  String get aboutTitle => 'О приложении';

  @override
  String aboutVersion(Object version) {
    return 'Версия';
  }

  @override
  String get feedbackTitle => 'Отзывы';

  @override
  String get feedbackSend => 'Открыть email';

  @override
  String get stealthPresetPodcast => 'Подкаст';

  @override
  String get stealthPresetNone => 'Нет';

  @override
  String get stealthLockTaskLabel => 'Закрепить приложение во время сессии';

  @override
  String get stealthLockTaskSubtitle =>
      'Не даёт выйти из приложения, пока идёт сессия. На Android включается закрепление экрана; на других платформах не действует.';

  @override
  String get homeTagline => 'Твой ангел тебя прикроет.';

  @override
  String get onboardingWelcomeGreeting => 'Привет, я Анджела';

  @override
  String get onboardingWelcomeBodyFull =>
      'Я твой личный ангел-хранитель. Я иду рядом с тобой, присматриваю за твоим вечером и принимаю меры, если что-то не так.';

  @override
  String get onboardingGetStarted => 'Начать';

  @override
  String get onboardingProfileNameLabel => 'Имя';

  @override
  String get onboardingProfilePhoneLabel => 'Номер телефона';

  @override
  String get onboardingProfilePhoneHelper =>
      'Включается в экстренные сообщения.';

  @override
  String get onboardingEmergencyContactHeader => 'Экстренный контакт';

  @override
  String get onboardingEmergencyContactPrompt =>
      'Кому сообщить, если что-то пойдёт не так?';

  @override
  String get onboardingEmergencyContactAdd => 'Добавить экстренный контакт';

  @override
  String get onboardingPermissionsIntro =>
      'Эти разрешения обеспечивают вашу безопасность во время сессий.';

  @override
  String get onboardingPermissionsGrantAll => 'Выдать все';

  @override
  String get onboardingPermissionsRequired => 'ОБЯЗАТЕЛЬНО';

  @override
  String get onboardingPermissionsOptional => 'НЕОБЯЗАТЕЛЬНО';

  @override
  String get onboardingPermissionsMicrophone => 'Микрофон';

  @override
  String get onboardingPermissionsCamera => 'Камера';

  @override
  String get onboardingPermissionsNotificationDesc =>
      'Необходимо для оповещений и напоминаний во время сессии.';

  @override
  String get onboardingPermissionsSmsDesc =>
      'Необходимо для отправки экстренных SMS-оповещений.';

  @override
  String get onboardingPermissionsPhoneDesc =>
      'Необходимо для экстренных и поддельных звонков.';

  @override
  String get onboardingPermissionsLocationDesc =>
      'Включается в экстренные сообщения, когда включена запись GPS.';

  @override
  String get onboardingPermissionsMicrophoneDesc =>
      'Используется для записи звука во время тревоги.';

  @override
  String get onboardingPermissionsCameraDesc =>
      'Используется для подачи сигнала SOS вспышкой.';

  @override
  String get sessionInterruptedTitle => 'Сессия прервана';

  @override
  String get sessionInterruptedBody =>
      'Во время работы приложение было остановлено, и шла сессия. Её состояние утрачено — ничего не восстановлено. Показываем это, чтобы вы знали.';

  @override
  String get sessionInterruptedAcknowledge => 'Понятно';

  @override
  String sessionInterruptedMode(Object name) {
    return 'Режим: $name';
  }

  @override
  String sessionInterruptedStarted(Object time) {
    return 'Начато: $time';
  }

  @override
  String get sessionGpsDestinationTitle => 'Пункт назначения';

  @override
  String get sessionGpsDestinationBody =>
      'Введите координаты пункта назначения для триггера отключения по прибытии GPS.';

  @override
  String get sessionGpsDestinationLat => 'Широта';

  @override
  String get sessionGpsDestinationLng => 'Долгота';

  @override
  String get sessionGpsDestinationSkip => 'Пропустить для этой сессии';

  @override
  String get sessionGpsDestinationConfirm => 'Использовать пункт назначения';

  @override
  String get sessionEndOverlayTitle => 'Завершить сессию?';

  @override
  String get sessionEndOverlayBody =>
      'Проведите, чтобы подтвердить завершение сессии';

  @override
  String get sessionEndOverlaySwipeLabel => 'Проведите для завершения';

  @override
  String get sessionEndOverlaySimBadge => '[SIM] Режим тренировки';

  @override
  String get sessionEndPinPromptTitle => 'Введите PIN завершения сессии';

  @override
  String get sessionEndPinAppPinMismatch =>
      'Используйте PIN завершения сессии, а не PIN приложения.';

  @override
  String get sessionEndPinIncorrect => 'Неверный PIN';

  @override
  String get sessionEndPinSimSkip => 'Пропустить (только симуляция)';

  @override
  String get sessionEndSimDistressWouldFire =>
      'Сработала бы тревожная цепочка (5 неверных PIN-кодов)';

  @override
  String get distressConfirmTitle => 'Тревога активирована';

  @override
  String distressConfirmCountdown(int seconds) {
    return 'Нажмите для отмены — у вас $seconds с';
  }

  @override
  String get distressConfirmCancel => 'Нажмите для отмены';

  @override
  String get distressConfirmFooter =>
      'Если не отменить, тревожная цепочка начнётся немедленно.';

  @override
  String get distressCancelPinPromptTitle => 'Введите PIN завершения сессии';

  @override
  String distressCancelPinTimeoutLabel(int seconds) {
    return 'осталось $seconds с';
  }

  @override
  String get distressCancelPinIncorrect => 'Неверный PIN';

  @override
  String get distressCancelPinAppPinMismatch =>
      'Используйте PIN завершения сессии, а не PIN приложения.';

  @override
  String get distressCancelPinSimSkip => 'Пропустить (только симуляция)';

  @override
  String get distressCancelSimDistressWouldFire =>
      'Сработала бы тревожная цепочка (5 неверных PIN-кодов)';

  @override
  String get distressCancelPinBack => 'Отмена';

  @override
  String get simulationPinPromptTitle => 'Введите PIN';

  @override
  String get simulationPinPromptBody =>
      'Потренируйтесь вводить PIN завершения сессии';

  @override
  String get simulationPinPromptSkip => 'Пропустить';

  @override
  String get simulationPinIncorrect => 'Неверный PIN';

  @override
  String simulationSummaryDuration(String duration) {
    return 'Длительность: $duration';
  }

  @override
  String get simulationSummaryTimelineHeader => 'Хронология событий';

  @override
  String get simulationSummaryShare => 'Поделиться';

  @override
  String simulationSummaryMissedEventsBadge(int count) {
    return 'Пропущено: $count';
  }

  @override
  String simulationSummaryDistressBadge(int count) {
    return 'Тревог: $count';
  }

  @override
  String simulationSummaryStepsFiredBadge(int count) {
    return 'Сработало шагов: $count';
  }

  @override
  String get simulationSummaryShareSubject => 'Итоги симуляции Guardian Angela';

  @override
  String get notificationsChannelAlarm => 'Эскалация тревоги';

  @override
  String get notificationsChannelAlarmDescription =>
      'Критические оповещения в обход режима «Не беспокоить»';

  @override
  String get notificationsChannelReminder => 'Замаскированное напоминание';

  @override
  String get notificationsChannelReminderDescription =>
      'Напоминания об отметке во время активной сессии';

  @override
  String get notificationsChannelFakeCall => 'Поддельный звонок';

  @override
  String get notificationsChannelFakeCallDescription =>
      'Полноэкранные уведомления о входящем вызове';

  @override
  String get notificationsChannelEnabled => 'Включено';

  @override
  String get notificationsChannelDisabled => 'Отключено';

  @override
  String get notificationsChannelsHeader => 'Каналы уведомлений';

  @override
  String get contactsImportFromDevice => 'Импортировать из контактов';

  @override
  String get contactsImportNotSupported => 'Недоступно на этой платформе';

  @override
  String get contactsImportPermissionDenied =>
      'Доступ к контактам запрещён. Включите его в настройках системы.';

  @override
  String get contactsDeleteAllMenu => 'Удалить все';

  @override
  String get contactsDeleteAllConfirmTitle => 'Удалить все контакты?';

  @override
  String get contactsDeleteAllConfirmBody =>
      'Это удалит все экстренные контакты. Отменить нельзя.';

  @override
  String get contactsDeleteAllTypeConfirmTitle => 'Подтвердите вводом текста';

  @override
  String get contactsDeleteAllTypeConfirmHint =>
      'Введите «DELETE ALL», чтобы продолжить';

  @override
  String get contactsDeleteAllTypeConfirmSentinel => 'DELETE ALL';

  @override
  String get contactsDeleteAllConfirmButton => 'Удалить все';

  @override
  String get modesBuiltinBadge => 'Встроенный';

  @override
  String get modesBuiltinNoDelete => 'Встроенные режимы нельзя удалить';

  @override
  String get sessionCompletedSimulationBanner => 'Симуляция завершена';

  @override
  String get sessionCompletedViewEventLog => 'Посмотреть журнал событий';

  @override
  String get settingsGeneralHeader => 'Общие';

  @override
  String get settingsAppHeader => 'Приложение';

  @override
  String get settingsConfigurationHeader => 'Конфигурация';

  @override
  String get settingsThemeLabel => 'Тема';

  @override
  String get settingsLanguageLabel => 'Язык';

  @override
  String get settingsSecurityRow => 'Безопасность';

  @override
  String get settingsSecuritySubtitle =>
      'PIN приложения, PIN завершения сессии, PIN под принуждением';

  @override
  String get settingsStealthRow => 'Скрытый режим';

  @override
  String get settingsStealthSummaryOff => 'Скрытый режим: ВЫКЛ';

  @override
  String get settingsStealthSummaryOn => 'Скрытый режим: ВКЛ';

  @override
  String get settingsProfileRow => 'Профиль';

  @override
  String get settingsModesRow => 'Режимы';

  @override
  String get settingsDistressModesRow => 'Режимы тревоги';

  @override
  String get settingsEventDefaultsRow => 'Шаги по умолчанию';

  @override
  String get settingsGpsLoggingRow => 'Запись GPS';

  @override
  String get settingsRemindersRow => 'Шаблоны напоминаний';

  @override
  String get settingsNotificationsRow => 'Уведомления';

  @override
  String get settingsHistoryRetentionRow => 'История и хранение';

  @override
  String get settingsAboutRow => 'О приложении';

  @override
  String get settingsFeedbackRow => 'Отправить отзыв';

  @override
  String get settingsBackupRow => 'Резервное копирование';

  @override
  String get settingsOssLicenses => 'Лицензии открытого ПО';

  @override
  String get settingsImportConfirmBody =>
      'Это перезапишет все текущие данные. Продолжить?';

  @override
  String get securityAppPinTitle => 'PIN приложения';

  @override
  String get securityAppPinBody => 'Блокирует приложение при каждом открытии.';

  @override
  String get securitySessionEndPinTitle => 'PIN завершения сессии';

  @override
  String get securitySessionEndPinBody =>
      'Необходим для отключения или завершения активной сессии.';

  @override
  String get securityDuressPinTitle => 'PIN под принуждением';

  @override
  String get securityDuressPinBody =>
      'Введите на любом запросе, чтобы незаметно запустить тревожную цепочку.';

  @override
  String get securityRemovePin => 'Удалить';

  @override
  String get securityRemovePinPrompt =>
      'Введите текущий PIN, чтобы удалить его.';

  @override
  String get securityRemovePinIncorrect => 'Неверный PIN';

  @override
  String get securityWhatIsThis => 'Что это?';

  @override
  String get securityAppPinInfo =>
      'Блокирует приложение при открытии. Клавиатура для ввода появляется перед любым экраном. Полезно, если кто-то ненадолго взял ваш разблокированный телефон.';

  @override
  String get securitySessionEndPinInfo =>
      'Необходим для отключения или завершения активной сессии безопасности. Без него злоумышленник, забравший ваш телефон, не сможет остановить цепочку. Задайте код, отличный от PIN приложения.';

  @override
  String get securityDuressPinInfo =>
      'Если вы введёте этот PIN на любом запросе, тревожная цепочка запустится незаметно — ваши контакты получат оповещение, а тревога подготовится, и злоумышленник ничего не заметит. Выберите код, отличный от всех остальных PIN-кодов.';

  @override
  String get securityPinTimeoutLabel => 'Тайм-аут PIN (секунды)';

  @override
  String get securityWrongPinThresholdLabel =>
      'Неверных вводов PIN до эскалации';

  @override
  String get securityDeceptiveDialogToggle =>
      'Показывать обманное окно при неверном PIN';

  @override
  String get pinSetupEnterNew => 'Введите новый PIN';

  @override
  String get pinSetupConfirmNew => 'Подтвердите новый PIN';

  @override
  String get pinSetupTooShort => 'PIN должен содержать не менее 4 цифр.';

  @override
  String get pinSetupCollision =>
      'Этот PIN совпадает с другим настроенным PIN.';

  @override
  String get pinSetupSaved => 'PIN сохранён';

  @override
  String get stealthEnabledLabel => 'Включить скрытый режим';

  @override
  String get stealthFakeNameLabel => 'Поддельное название приложения';

  @override
  String get stealthFakeIconLabel => 'Поддельный значок';

  @override
  String get stealthNotificationDisguiseLabel => 'Маскировка уведомлений';

  @override
  String get stealthTimerDisplayLabel => 'Показ таймера';

  @override
  String get stealthSessionScreenLabel => 'Скрытность экрана сессии';

  @override
  String get gpsLoggingEnabled => 'Записывать GPS во время сессий';

  @override
  String get gpsLoggingIntervalLabel => 'Интервал';

  @override
  String get gpsLoggingAccuracyLabel => 'Точность';

  @override
  String get gpsLoggingAccuracyHigh => 'Высокая';

  @override
  String get gpsLoggingAccuracyBalanced => 'Сбалансированная';

  @override
  String get gpsLoggingAccuracyLow => 'Низкая';

  @override
  String get gpsLoggingFormatLabel => 'Формат координат';

  @override
  String get gpsLoggingFormatDecimal => 'Десятичный';

  @override
  String get gpsLoggingFormatDms => 'ГМС';

  @override
  String get gpsLoggingFormatAddress => 'Plus Code';

  @override
  String get gpsLoggingIncludeInSms => 'Добавлять местоположение в SMS';

  @override
  String get historyRetentionLogsLabel => 'Хранение журналов сессий (дни)';

  @override
  String get historyRetentionLogsHelper =>
      'Журналы старше этого срока перемещаются в корзину.';

  @override
  String get historyRetentionTrashLabel => 'Хранение в корзине (дни)';

  @override
  String get historyRetentionTrashHelper =>
      'Журналы в корзине окончательно удаляются по истечении этого срока.';

  @override
  String get historyRetentionUpdated => 'Срок хранения обновлён';

  @override
  String get historyRetentionPurgeNow => 'Очистить сейчас';

  @override
  String historyRetentionPurged(Object count) {
    return 'Удалено журналов: $count';
  }

  @override
  String get eventDefaultsCheckInHeader => 'Способы отметки';

  @override
  String get eventDefaultsEscalationHeader => 'Шаги эскалации';

  @override
  String get eventDefaultsPanicHeader => 'Триггер паники';

  @override
  String get templatesCreate => 'Создать шаблон';

  @override
  String get templatesEditTitle => 'Изменить шаблон';

  @override
  String get templatesCreateTitle => 'Новый шаблон';

  @override
  String get templatesNameLabel => 'Название';

  @override
  String get templatesTitleLabel => 'Заголовок';

  @override
  String get templatesBodyLabel => 'Текст';

  @override
  String get templatesBuiltinNoDelete => 'Встроенные шаблоны нельзя удалить';

  @override
  String get templatesAddFromTemplate => 'Из шаблона';

  @override
  String get templatesAddFromScratch => 'С нуля';

  @override
  String templatesDeleteConfirmTitle(Object name) {
    return 'Удалить «$name»?';
  }

  @override
  String get templatesDeleteConfirmBody =>
      'Этот шаблон будет удалён окончательно.';

  @override
  String get templatesEmptyAddFirst => 'Добавьте свой первый шаблон';

  @override
  String get templatesPickFromBuiltinTitle => 'Выберите встроенный шаблон';

  @override
  String get templatesIconLabel => 'Значок';

  @override
  String get templatesIconCalendar => 'Календарь';

  @override
  String get templatesIconAppNotification => 'Уведомление приложения';

  @override
  String get templatesIconFitness => 'Фитнес';

  @override
  String get templatesIconHealth => 'Здоровье';

  @override
  String get templatesIconFood => 'Еда';

  @override
  String get templatesIconCoffee => 'Кофе';

  @override
  String get templatesIconBattery => 'Батарея';

  @override
  String get templatesIconWeather => 'Погода';

  @override
  String get templatesPreviewHeading => 'Предпросмотр';

  @override
  String get templatesDiscardChangesTitle => 'Отменить изменения?';

  @override
  String get templatesDiscardChangesBody =>
      'Несохранённые изменения будут потеряны.';

  @override
  String get templatesDiscardKeep => 'Продолжить редактирование';

  @override
  String get templatesDiscardDiscard => 'Отменить';

  @override
  String get notificationsTitle => 'Уведомления';

  @override
  String get notificationsStatusGranted => 'Разрешено';

  @override
  String get notificationsStatusDenied => 'Запрещено';

  @override
  String get notificationsStatusUnknown => 'Ещё не запрашивалось';

  @override
  String get notificationsRequest => 'Запросить разрешение';

  @override
  String get notificationsOpenSettings => 'Открыть настройки системы';

  @override
  String get profileFieldPhone => 'Номер телефона';

  @override
  String get profileFieldDescription => 'Описание внешности';

  @override
  String get profileFieldMedicalConditions => 'Заболевания';

  @override
  String get profileFieldEmergencyInstructions => 'Инструкции на случай ЧС';

  @override
  String get aboutAuthor => 'Автор: Jonas Eschle';

  @override
  String get aboutEmail => 'guardian.angela.app@gmail.com';

  @override
  String get aboutPrivacyPolicy => 'Политика конфиденциальности';

  @override
  String get aboutTermsOfService => 'Условия использования';

  @override
  String get aboutSourceCode => 'Исходный код';

  @override
  String get aboutSupport => 'Поддержать / пожертвовать';

  @override
  String get aboutLicenses => 'Лицензии открытого ПО';

  @override
  String get aboutTagline => 'Сделано с любовью ради безопасности ЛГБТК+.';

  @override
  String get aboutTechnicalSection => 'Техническая информация';

  @override
  String aboutBundleId(Object id) {
    return 'Идентификатор пакета: $id';
  }

  @override
  String aboutPlatforms(Object list) {
    return 'Платформы: $list';
  }

  @override
  String get feedbackHeading => 'Будем рады услышать вас';

  @override
  String get feedbackCategoryLabel => 'Категория';

  @override
  String get feedbackCategoryBug => 'Сообщение об ошибке';

  @override
  String get feedbackCategoryFeature => 'Запрос функции';

  @override
  String get feedbackCategoryOther => 'Другое';

  @override
  String get feedbackEmailLabel => 'Email (необязательно)';

  @override
  String get feedbackMessageLabel => 'Сообщение';

  @override
  String get feedbackIncludeLog => 'Приложить журнал последней сессии';

  @override
  String get feedbackSent => 'Спасибо за ваш отзыв!';

  @override
  String get feedbackMessageRequired =>
      'Сообщение должно содержать не менее 10 символов.';

  @override
  String get backupIncludeLogs => 'Включить журналы сессий';

  @override
  String get backupIncludeMedia => 'Включить медиафайлы';

  @override
  String get backupExportButton => 'Экспорт';

  @override
  String get backupImportButton => 'Импорт';

  @override
  String get backupOverwriteWarning =>
      'Импорт перезаписывает все текущие данные.';

  @override
  String get backupImportSuccess =>
      'Импорт завершён. Перезапустите, чтобы применить.';

  @override
  String backupImportError(Object message) {
    return 'Сбой импорта: $message';
  }

  @override
  String get backupActiveSessionBanner =>
      'Резервное копирование недоступно во время активной сессии.';

  @override
  String backupLastBackupAtLabel(Object when) {
    return 'Последняя копия: $when';
  }

  @override
  String get backupNeverExportedLabel => 'Резервных копий пока нет';

  @override
  String get pastEventsTitle => 'Прошлые сессии';

  @override
  String get pastEventsTabReal => 'Реальные';

  @override
  String get pastEventsTabSimulated => 'Симуляции';

  @override
  String get pastEventsEmpty => 'Сессий пока нет';

  @override
  String get pastEventsDeleteConfirm => 'Удалить журнал сессии?';

  @override
  String get pastEventsDetailShareText => 'Поделиться как текст';

  @override
  String get pastEventsDetailSharePdf => 'Поделиться как PDF';

  @override
  String get pastEventsDetailDelete => 'Удалить';

  @override
  String get pastEventsOutcomeCompleted => 'Завершено';

  @override
  String get pastEventsOutcomeDistress => 'Тревога';

  @override
  String get pastEventsOutcomeInterrupted => 'Прервано';

  @override
  String get pastEventsTrash => 'В корзину';

  @override
  String get pastEventsUndo => 'Отменить';

  @override
  String get pastEventsSoftDeleted => 'Перемещено в корзину';

  @override
  String get pastEventsDetailTitle => 'Журнал сессии';

  @override
  String get pastEventsDetailShare => 'Поделиться';

  @override
  String get contactUnsavedDiscardTitle => 'Отменить несохранённые изменения?';

  @override
  String get contactUnsavedDiscardKeep => 'Продолжить редактирование';

  @override
  String get contactUnsavedDiscardDiscard => 'Отменить';

  @override
  String get modesDuplicate => 'Дублировать';

  @override
  String get modesDeleteConfirmTitle => 'Удалить режим?';

  @override
  String modesDeleteConfirmBody(Object name) {
    return '$name будет удалён окончательно.';
  }

  @override
  String get modesDistressDefaultBadge => 'По умолчанию';

  @override
  String get modesDistressSetDefault => 'Сделать основным';

  @override
  String get modesDistressCantDeleteLast =>
      'Требуется хотя бы один режим тревоги.';

  @override
  String get modesDistressInUse =>
      'Этот режим тревоги используется другим режимом.';

  @override
  String get modesDistressTitle => 'Режимы тревоги';

  @override
  String get validationNameTooShort =>
      'Имя должно содержать не менее 2 символов.';

  @override
  String get validationPhoneRequired => 'Необходимо указать номер телефона.';

  @override
  String get validationChannelsRequired => 'Выберите хотя бы один канал.';

  @override
  String get sessionHoldTouchToBegin => 'Коснитесь, чтобы начать';

  @override
  String sessionHoldReleaseCountdown(Object seconds) {
    return 'Обратный отсчёт: $seconds с';
  }

  @override
  String sessionHoldGraceCountdown(Object seconds) {
    return 'Льготный период: $seconds с — удержите снова, чтобы оставаться в безопасности';
  }

  @override
  String get sessionHoldAgain =>
      'Удержите снова, чтобы оставаться в безопасности';

  @override
  String sessionStepNextCheckIn(Object time) {
    return 'Следующая отметка через $time';
  }

  @override
  String sessionStepFakeCallActive(Object caller) {
    return 'Входящий вызов от $caller';
  }

  @override
  String get sessionStepFakeCallOpen => 'Открыть экран вызова';

  @override
  String sessionStepSimBlockedSms(Object count) {
    return '[SIM] Отправили бы SMS контактам: $count';
  }

  @override
  String get sessionStepSimBlockedPhone =>
      '[SIM] Позвонили бы экстренному контакту';

  @override
  String get sessionStepSimBlockedEmergency =>
      '[SIM] Позвонили бы в экстренные службы';

  @override
  String get sessionStepSimBlockedAlarm =>
      '[SIM] Тревога прозвучала бы на полной громкости';

  @override
  String get sessionStartFailedTitle => 'Не удаётся начать сессию';

  @override
  String get sessionStartFailedBody =>
      'Перед началом устраните следующие проблемы:';

  @override
  String get sessionQuickExitTitle => 'Быстрый выход';

  @override
  String get sessionQuickExitBody =>
      'Данные сессии будут сохранены и зашифрованы. Откройте приложение в любой момент, чтобы их восстановить.';

  @override
  String get sessionQuickExitConfirm => 'Выйти из приложения';

  @override
  String get pastEventsRestore => 'Восстановить';

  @override
  String get stepEditorWait => 'Ожидание (с)';

  @override
  String get stepEditorDuration => 'Длительность (с)';

  @override
  String get stepEditorGrace => 'Льготный период (с)';

  @override
  String get stepEditorRetryCount => 'Число повторов';

  @override
  String get stepEditorRandomize => 'Случайный тайминг (±20%)';

  @override
  String get stepEditorRemove => 'Удалить шаг';

  @override
  String get eventDefaultsHoldStyle => 'Стиль удержания';

  @override
  String get eventDefaultsHoldSensitivity => 'Чувствительность отпускания';

  @override
  String get eventDefaultsHoldVibrate => 'Вибрация при отпускании';

  @override
  String get eventDefaultsHoldSound => 'Звук при отпускании';

  @override
  String get eventDefaultsBlackScreen => 'Затемнение экрана';

  @override
  String get eventDefaultsReminderRandomInterval => 'Случайный интервал';

  @override
  String get eventDefaultsReminderRandomTemplate =>
      'Случайный порядок шаблонов';

  @override
  String get eventDefaultsReminderResetOnEarly =>
      'Сбрасывать при ранней отметке';

  @override
  String get eventDefaultsCountdownStyle => 'Стиль обратного отсчёта';

  @override
  String get eventDefaultsCountdownVibrate => 'Вибрация';

  @override
  String get eventDefaultsCountdownSound => 'Звук';

  @override
  String get eventDefaultsFakeCallStyle => 'Стиль вызова';

  @override
  String get eventDefaultsFakeCallCallerName => 'Имя звонящего';

  @override
  String get eventDefaultsFakeCallRingDuration => 'Длительность звонка (с)';

  @override
  String get eventDefaultsFakeCallDeclineIsSafe =>
      'Отклонение означает «в безопасности»';

  @override
  String get eventDefaultsFakeCallVoiceOutput => 'Голосовой вывод';

  @override
  String get eventDefaultsSmsChannel => 'Канал';

  @override
  String get eventDefaultsSmsIncludeLocation => 'Включить местоположение';

  @override
  String get eventDefaultsSmsIncludeMedical => 'Включить медицинские данные';

  @override
  String get eventDefaultsSmsAutoRecord => 'Записать звук перед отправкой';

  @override
  String get eventDefaultsSmsRecordDuration => 'Длительность записи (с)';

  @override
  String get eventDefaultsLoudAlarmVolume => 'Громкость';

  @override
  String get eventDefaultsLoudAlarmSound => 'Звук';

  @override
  String get eventDefaultsLoudAlarmFlashScreen => 'Мигание экрана';

  @override
  String get eventDefaultsLoudAlarmFlashLight => 'Мигание вспышки камеры';

  @override
  String get eventDefaultsLoudAlarmGradual =>
      'Постепенное нарастание громкости';

  @override
  String get eventDefaultsCallEmergencyNumber =>
      'Экстренный номер (переопределение)';

  @override
  String get eventDefaultsCallEmergencyConfirm =>
      'Показывать обратный отсчёт подтверждения';

  @override
  String get eventDefaultsCallEmergencyConfirmDuration =>
      'Секунды подтверждения';

  @override
  String get eventDefaultsCallEmergencySmsFirst =>
      'Сначала отправить SMS с местоположением';

  @override
  String get eventDefaultsPhonePrimaryContact => 'Основной контакт (id)';

  @override
  String get eventDefaultsHardwareButton => 'Кнопка';

  @override
  String get eventDefaultsHardwarePattern => 'Схема нажатий';

  @override
  String get eventDefaultsHardwarePressCount => 'Число нажатий';

  @override
  String get eventDefaultsHardwareLongDuration =>
      'Длительность долгого нажатия (с)';

  @override
  String get pastEventsTrashTitle => 'Корзина';

  @override
  String get pastEventsTrashEmpty => 'Корзина пуста';

  @override
  String get pastEventsTrashEmptyAll => 'Очистить корзину';

  @override
  String get pastEventsTrashEmptyAllConfirmTitle => 'Очистить корзину?';

  @override
  String get pastEventsTrashEmptyAllConfirmBody =>
      'Введите ниже «EMPTY TRASH» для подтверждения. Это удалит все журналы из корзины без возможности восстановления.';

  @override
  String pastEventsTrashEmptyAllSuccess(Object count) {
    return 'Корзина очищена (журналов: $count)';
  }

  @override
  String pastEventsTrashRetentionNote(int days) {
    return 'Журналы в корзине окончательно удаляются через $days дн.';
  }

  @override
  String pastEventsTrashRemainingDays(int days) {
    return 'до окончательного удаления: $days дн.';
  }

  @override
  String get pastEventsTrashDeletePermanently => 'Удалить окончательно';

  @override
  String get pastEventsTrashDeletePermanentlyBody =>
      'Это действие нельзя отменить.';

  @override
  String sessionEmergencyConfirmTitle(String number, int seconds) {
    return 'Звонок на $number через $seconds с';
  }

  @override
  String get sessionEmergencyConfirmSwipe => 'Проведите для отмены';

  @override
  String get sessionEmergencyConfirmKeep => 'Продолжить звонок';

  @override
  String get sessionEmergencyConfirmSimBadge => '[SIM] Режим тренировки';

  @override
  String get sessionEmergencyConfirmSimCancelled =>
      'Симулированная отмена — звонок не был бы совершён';

  @override
  String get swipeSliderSemantics => 'Проведите для подтверждения';

  @override
  String get homeWidgetStatusIdle => 'Ожидание';

  @override
  String get homeWidgetStatusSession => 'Сессия активна';

  @override
  String get homeWidgetStatusSim => 'Симуляция активна';

  @override
  String get homeWidgetQuickExit => 'Быстрый выход';

  @override
  String get homeWidgetFakeCall => 'Ложный вызов';
}
