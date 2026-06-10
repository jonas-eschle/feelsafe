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
  String get commonGotIt => 'Понятно';

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
    return 'Используется номер SIM-карты $number';
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
  String get chainStepDescHoldButton =>
      'Удерживайте, чтобы быть в безопасности — отпускание запускает льготный отсчёт.';

  @override
  String get chainStepDescDisguisedReminder =>
      'Отправляет замаскированное уведомление — вы должны отреагировать, чтобы подтвердить безопасность.';

  @override
  String get chainStepDescFakeCall =>
      'Имитирует входящий звонок — ответьте или отклоните, чтобы показать, что вы в безопасности.';

  @override
  String get chainStepDescSmsContact =>
      'Отправляет SMS с вашим местоположением экстренным контактам.';

  @override
  String get chainStepDescCountdownWarning =>
      'Показывает обратный отсчёт со звуком и вспышками как последнее предупреждение.';

  @override
  String get chainStepDescLoudAlarm =>
      'Включает тревогу на максимальной громкости со вспышками, чтобы привлечь внимание.';

  @override
  String get chainStepDescCallEmergency =>
      'Автоматически звонит в экстренные службы (112/911).';

  @override
  String get chainStepDescPhoneCallContact =>
      'Звонит напрямую экстренному контакту.';

  @override
  String get chainStepDescHardwareButton =>
      'Следит за аппаратной кнопкой, ожидая панического нажатия.';

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
  String get sessionReminderDecoyWords =>
      'ПОЗЖЕ,ПРОПУСТИТЬ,ГОТОВО,ОТКРЫТЬ,ПОКАЗАТЬ,ОК,ДАЛЕЕ,ЕЩЁ,ОТЛОЖИТЬ,ЗАКРЫТЬ';

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
  String get sessionStealthNowPlaying => 'Сейчас играет';

  @override
  String get sessionServiceTitle => 'Guardian Angela активен';

  @override
  String get sessionServiceBody => 'Ваш сеанс безопасности выполняется.';

  @override
  String get sessionServiceStealthBody => 'Воспроизведение';

  @override
  String get sessionStealthTrackTitle => 'Безымянный трек';

  @override
  String get sessionStealthArtistName => 'Неизвестный исполнитель';

  @override
  String get sessionStealthAlbumArtLabel => 'Обложка альбома';

  @override
  String get sessionStealthPlay => 'Воспроизвести';

  @override
  String get sessionStealthPause => 'Пауза';

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
  String get modeFieldIcon => 'Значок';

  @override
  String get modeIconLabelShield => 'Щит';

  @override
  String get modeIconLabelFavorite => 'Сердце';

  @override
  String get modeIconLabelLock => 'Замок';

  @override
  String get modeIconLabelDirectionsWalk => 'Прогулка';

  @override
  String get modeIconLabelRestaurant => 'Ужин';

  @override
  String get modeIconLabelWarning => 'Предупреждение';

  @override
  String get modeIconLabelNightlife => 'Ночная жизнь';

  @override
  String get modeIconLabelDirectionsRun => 'Бег';

  @override
  String get modeIconLabelDirectionsBike => 'Велосипед';

  @override
  String get modeIconLabelHome => 'Дом';

  @override
  String get modeIconLabelWork => 'Работа';

  @override
  String get modeIconLabelSchool => 'Школа';

  @override
  String get modeIconLabelLocalTaxi => 'Такси';

  @override
  String get modeIconLabelFlight => 'Путешествие';

  @override
  String get modeIconLabelHiking => 'Поход';

  @override
  String get modeIconLabelCelebration => 'Вечеринка';

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
  String stepSummaryHoldButton(Object style, int grace) {
    return 'Удержание: $style, льготный период $grace с';
  }

  @override
  String stepSummaryDisguisedReminder(Object interval, Object retries) {
    return 'Интервал $interval, $retries';
  }

  @override
  String stepSummaryRetryCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count повтора',
      many: '$count повторов',
      few: '$count повтора',
      one: '$count повтор',
    );
    return '$_temp0';
  }

  @override
  String stepSummaryMinutes(int count) {
    return '$count мин';
  }

  @override
  String stepSummarySeconds(int count) {
    return '$count с';
  }

  @override
  String stepSummaryCountdown(int duration, Object style) {
    return 'Отсчёт $duration с, $style';
  }

  @override
  String stepSummaryFakeCall(int ring, int grace) {
    return 'Звонок $ring с, льготный период $grace с';
  }

  @override
  String stepSummarySmsTo(Object names) {
    return 'Кому: $names';
  }

  @override
  String stepSummarySmsMore(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+ещё $count',
      many: '+ещё $count',
      few: '+ещё $count',
      one: '+ещё $count',
    );
    return '$_temp0';
  }

  @override
  String get stepSummarySmsNone => 'Получатели не выбраны';

  @override
  String stepSummaryPhoneCall(Object name) {
    return 'Звонок: $name';
  }

  @override
  String get stepSummaryPhoneCallNone => 'Нет контакта для звонка';

  @override
  String stepSummaryLoudAlarm(int volume, Object sound) {
    return 'Громкость $volume %, $sound';
  }

  @override
  String stepSummaryLoudAlarmRamp(int volume, Object sound) {
    return 'Громкость $volume %, $sound, нарастает';
  }

  @override
  String stepSummaryCallEmergency(Object number) {
    return 'Звонок: $number';
  }

  @override
  String stepSummaryCallEmergencySmsFirst(Object number) {
    return 'Звонок: $number, сначала SMS с геопозицией';
  }

  @override
  String stepSummaryHardwareRepeat(Object button, int count) {
    return '$button × $count';
  }

  @override
  String stepSummaryHardwareLong(Object button, Object seconds) {
    return '$button, удерживать $seconds с';
  }

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
  String get safetyOptionsHeader => 'Параметры безопасности';

  @override
  String get safetyOptionsDistressModeTitle => 'Режим тревоги';

  @override
  String get safetyOptionsDistressModeUseDefault =>
      'Использовать режим тревоги по умолчанию';

  @override
  String safetyOptionsDistressModeUseDefaultNamed(Object name) {
    return 'Использовать по умолчанию ($name)';
  }

  @override
  String get safetyOptionsDistressModeInfo =>
      'При срабатывании триггера тревоги (PIN под принуждением, аппаратная паника или превышение числа неверных PIN) цепочка этого режима заменяется цепочкой выбранного режима тревоги. Оставьте значение по умолчанию, чтобы использовать общий режим тревоги приложения.';

  @override
  String get safetyOptionsManageDistressModes => 'Управление режимами тревоги';

  @override
  String get safetyOptionsDistressTriggersTitle => 'Триггеры тревоги';

  @override
  String get safetyOptionsDistressTriggersInfo =>
      'Триггеры тревоги немедленно запускают цепочку тревоги параллельно с основной цепочкой. Аппаратная кнопка паники отслеживает физическую кнопку по заданному шаблону нажатий.';

  @override
  String get safetyOptionsDistressTriggersEmpty => 'Нет триггеров тревоги';

  @override
  String get safetyOptionsAddHardwarePanic =>
      'Добавить аппаратную кнопку паники';

  @override
  String safetyOptionsTriggerHardwareRepeat(Object button, Object count) {
    return '$button: нажатий $count×';
  }

  @override
  String safetyOptionsTriggerHardwareLong(Object button, Object seconds) {
    return '$button: удержание $seconds с';
  }

  @override
  String get safetyOptionsButtonVolumeUp => 'Громкость +';

  @override
  String get safetyOptionsButtonVolumeDown => 'Громкость −';

  @override
  String get safetyOptionsTriggerPattern => 'Шаблон нажатий';

  @override
  String get safetyOptionsPatternRepeat => 'Повторные нажатия';

  @override
  String get safetyOptionsPatternLong => 'Долгое нажатие';

  @override
  String get safetyOptionsTriggerButton => 'Кнопка';

  @override
  String get safetyOptionsTriggerPressCount => 'Количество нажатий';

  @override
  String get safetyOptionsTriggerHoldDuration =>
      'Длительность удержания (секунды)';

  @override
  String get safetyOptionsDisarmTriggersTitle => 'Триггеры отключения';

  @override
  String get safetyOptionsGpsArrivalTitle => 'Отключение при GPS-прибытии';

  @override
  String get safetyOptionsGpsArrivalInfo =>
      'Сессия завершается автоматически, когда вы оказываетесь в заданном радиусе от пункта назначения. Пункт назначения задаётся при запуске сессии.';

  @override
  String get safetyOptionsGpsArrivalRadius => 'Радиус прибытия';

  @override
  String safetyOptionsRadiusMeters(Object meters) {
    return '$meters м';
  }

  @override
  String safetyOptionsRadiusKilometers(Object km) {
    return '$km км';
  }

  @override
  String get safetyOptionsDestinationSource => 'Пункт назначения';

  @override
  String get safetyOptionsDestinationPrompt =>
      'Задавать пункт назначения при запуске сессии';

  @override
  String get safetyOptionsDestinationFixed => 'Фиксированные координаты';

  @override
  String get safetyOptionsLatitude => 'Широта';

  @override
  String get safetyOptionsLongitude => 'Долгота';

  @override
  String get safetyOptionsTimerDisarmTitle => 'Отключение по таймеру';

  @override
  String get safetyOptionsTimerDisarmInfo =>
      'Сессия завершается автоматически по истечении заданного времени, независимо от того, началась ли эскалация.';

  @override
  String get safetyOptionsTimerDuration => 'Длительность';

  @override
  String safetyOptionsDurationMinutes(Object minutes) {
    return '$minutes мин';
  }

  @override
  String safetyOptionsDurationHoursMinutes(Object hours, Object minutes) {
    return '$hours ч $minutes мин';
  }

  @override
  String get safetyOptionsGpsLoggingTitle => 'Запись GPS';

  @override
  String get safetyOptionsGpsLoggingInfo =>
      'Выберите, записывает ли этот режим ваше местоположение во время сессии. «Наследовать» использует глобальные настройки GPS; «Свои» переопределяют их для этого режима; «Выкл.» полностью отключает запись.';

  @override
  String get safetyOptionsStealthTitle => 'Скрытность';

  @override
  String get safetyOptionsStealthInfo =>
      'Выберите, маскирует ли этот режим приложение во время сессии. «Наследовать» использует глобальные настройки скрытности; «Свои» переопределяют их для этого режима; «Выкл.» полностью отключает скрытность.';

  @override
  String get safetyOptionsTriStateInherit => 'Наследовать';

  @override
  String get safetyOptionsTriStateCustom => 'Свои';

  @override
  String get safetyOptionsTriStateOff => 'Выкл.';

  @override
  String get safetyOptionsLocalTemplatesTitle => 'Локальные шаблоны';

  @override
  String get safetyOptionsLocalTemplatesInfo =>
      'Локальные шаблоны добавляются к глобальному набору шаблонов напоминаний только для этого режима. Используйте их для шагов замаскированных напоминаний, относящихся только к этому режиму.';

  @override
  String get safetyOptionsLocalTemplatesEmpty => 'Нет локальных шаблонов';

  @override
  String get safetyOptionsAddTemplate => 'Добавить шаблон';

  @override
  String get safetyOptionsManageTemplates => 'Управление шаблонами напоминаний';

  @override
  String get safetyOptionsEventDefaultsTitle => 'Значения событий по умолчанию';

  @override
  String get safetyOptionsEventDefaultsInfo =>
      'Значения событий по умолчанию задают начальную конфигурацию для каждого типа шага. «Наследовать» использует глобальные значения; «Свои» переопределяют их для шагов этого режима без собственной конфигурации.';

  @override
  String get safetyOptionsEventDefaultsTwoStateInherit => 'Наследовать';

  @override
  String get safetyOptionsAllowDisarmAsDistressTitle =>
      'Разрешить отключение во время активной тревоги';

  @override
  String get safetyOptionsAllowDisarmAsDistressInfo =>
      'Если включено, вы можете остановить тревогу, добравшись до безопасного места или дождавшись истечения таймера. Если выключено, тревогу останавливает только завершение цепочки или закрытие приложения — надёжнее против принуждения.';

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
  String get settingsEmergencyNumberEditTitle => 'Номер экстренной службы';

  @override
  String get settingsEmergencyNumberFieldLabel => 'Номер для набора';

  @override
  String get settingsEmergencyNumberPresetsLabel => 'Распространённые номера';

  @override
  String get phoneWarnInvalidChars => 'Допустимы только цифры, +, * и #.';

  @override
  String get phoneWarnTooShort =>
      'Номера экстренных служб обычно состоят минимум из 3 цифр.';

  @override
  String get phoneWarnLooksLikeRegular =>
      'Похоже на обычный телефонный номер, а не на номер экстренной службы.';

  @override
  String get phoneWarnEmergencyEmpty =>
      'Введите номер — поле не может быть пустым.';

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
  String get securityDistressCancelBiometric =>
      'Использовать биометрию для отмены сигнала бедствия';

  @override
  String get launchPinTitle => 'Введите PIN приложения';

  @override
  String get launchPinBiometricReason => 'Разблокировать Guardian Angela';

  @override
  String get sessionEndBiometricReason => 'Подтвердите, чтобы завершить сеанс';

  @override
  String get distressCancelBiometricReason =>
      'Подтвердите, что это вы, для отмены';

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
  String get stealthLockTaskInfo =>
      'Закрепляет Guardian Angela на экране на всё время сессии, чтобы приложение нельзя было смахнуть или переключить. Компромисс: Android показывает системное уведомление «Приложение закреплено» и блокирует переключение приложений до конца сессии — это видно всем, кто смотрит на экран. Оставьте выключенным, если хотите свободно переключаться между приложениями во время сессии. На платформах без закрепления экрана не действует.';

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
  String get sessionInterruptedStartSameMode => 'Запустить тот же режим';

  @override
  String get sessionInterruptedJustNow => 'только что';

  @override
  String sessionInterruptedMinutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count минуты назад',
      many: '$count минут назад',
      few: '$count минуты назад',
      one: '1 минуту назад',
    );
    return '$_temp0';
  }

  @override
  String sessionInterruptedHoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count часа назад',
      many: '$count часов назад',
      few: '$count часа назад',
      one: '1 час назад',
    );
    return '$_temp0';
  }

  @override
  String sessionInterruptedDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count дня назад',
      many: '$count дней назад',
      few: '$count дня назад',
      one: '1 день назад',
    );
    return '$_temp0';
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
  String get sessionCompletedFeedbackPrompt => 'Как всё прошло?';

  @override
  String get sessionCompletedFeedbackSend => 'Отправить отзыв';

  @override
  String get sessionCompletedFeedbackSkip => 'Пропустить';

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
  String get templatesRequiredFieldsError =>
      'Необходимо указать название, заголовок и текст.';

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
  String get validationChainEmpty =>
      'Добавьте хотя бы один шаг перед сохранением.';

  @override
  String get validationGpsFixedCoords =>
      'Укажите широту и долготу для фиксированного места прибытия.';

  @override
  String get validationHardwareTrigger =>
      'Аппаратный триггер тревоги настроен не полностью — проверьте число нажатий или длительность удержания.';

  @override
  String get validationSmsChannelNotOnContacts =>
      'Ни один из выбранных контактов не может принять сообщение по каналу этого шага. Выберите другой канал или добавьте его контакту.';

  @override
  String get validationDistressNoActionTitle =>
      'Нет исходящего шага оповещения';

  @override
  String get validationDistressNoActionBody =>
      'В этом режиме тревоги нет шага с SMS или звонком, поэтому он не оставляет исходящего следа. Всё равно сохранить?';

  @override
  String get validationSaveAnyway => 'Всё равно сохранить';

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
  String get eventDefaultsFakeCallRingtone => 'Рингтон';

  @override
  String get eventDefaultsFakeCallRingtoneDefault => 'Стандартный рингтон';

  @override
  String eventDefaultsFakeCallRingtoneCustom(String fileName) {
    return 'Свой: $fileName';
  }

  @override
  String get eventDefaultsFakeCallRingtoneChoose => 'Выбрать рингтон…';

  @override
  String get eventDefaultsFakeCallRingtoneUseDefault =>
      'Использовать стандартный';

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
  String get eventDefaultsSmsMessageTemplate => 'Шаблон сообщения';

  @override
  String get eventDefaultsSmsMessageTemplateHint =>
      'Оставьте пустым, чтобы использовать оповещение по умолчанию. Коснитесь заполнителя, чтобы вставить его.';

  @override
  String get eventDefaultsSmsIosWarning =>
      'На iPhone для отправки SMS нужно вручную нажать «Отправить» в приложении «Сообщения». Если вы не можете пользоваться телефоном, сообщение не будет отправлено. Рассмотрите WhatsApp или Telegram.';

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
  String get eventDefaultsCallEmergencyIosWarning =>
      'На iPhone перед набором появится окно подтверждения. Быстро нажмите «Позвонить».';

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
  String get eventDefaultsHoldStyleInfo =>
      'Как выглядит область удержания: большая кнопка, весь экран или поддельный экран блокировки, скрывающий, что делает приложение.';

  @override
  String get eventDefaultsHoldSensitivityInfo =>
      'Насколько строго поднятый палец считается отпусканием. Низкие значения прощают краткие соскальзывания; высокие реагируют мгновенно.';

  @override
  String get eventDefaultsHoldVibrateInfo =>
      'Телефон вибрирует, как только палец покидает кнопку, чтобы вы сразу заметили случайное отпускание.';

  @override
  String get eventDefaultsHoldSoundInfo =>
      'Проигрывает короткий звук, когда палец покидает кнопку, чтобы вы заметили случайное отпускание, даже не глядя на экран.';

  @override
  String get eventDefaultsBlackScreenInfo =>
      'Держит экран чёрным во время этого шага, имитируя заблокированный телефон, чтобы приложение оставалось невидимым для наблюдателей. Шаг продолжает работать в фоне.';

  @override
  String get eventDefaultsReminderRandomIntervalInfo =>
      'Варьирует время между напоминаниями примерно на ±20 %, чтобы они выглядели как обычные уведомления приложений, а не как фиксированное расписание.';

  @override
  String get eventDefaultsReminderRandomTemplateInfo =>
      'Каждый раз выбирает другой шаблон напоминания, чтобы повторяющиеся напоминания не выглядели одинаково для того, кто следит за вашими уведомлениями.';

  @override
  String get eventDefaultsReminderResetOnEarlyInfo =>
      'Если вы отметитесь до срабатывания напоминания, таймер перезапустится с полного интервала, а не сохранит прежнее расписание.';

  @override
  String get eventDefaultsReminderTemplateIds => 'Допустимые шаблоны';

  @override
  String get eventDefaultsReminderTemplateIdsInfo =>
      'Ограничивает, какие шаблоны напоминаний может показывать этот шаг. Если ничего не выбрано, допустим любой шаблон пула — глобальные и локальные шаблоны этого режима. Выбранный шаблон, который позже удалили, просто игнорируется; если ни одного из выбранных больше нет, снова допустимы все шаблоны.';

  @override
  String get eventDefaultsReminderTemplateIdsAll => 'Допустимы все шаблоны';

  @override
  String eventDefaultsReminderTemplateIdsSelected(Object names) {
    return 'Допустимы: $names';
  }

  @override
  String get eventDefaultsReminderTemplatesTitle => 'Шаблоны напоминаний';

  @override
  String get eventDefaultsReminderTemplatesInfo =>
      'Шаблоны определяют, как выглядит замаскированное напоминание — поддельное имя приложения, заголовок и текст (например, уведомление календаря или приложения для изучения языков). Управляйте общим пулом здесь; каждый шаг замаскированного напоминания выбирает из него.';

  @override
  String get eventDefaultsCountdownStyleInfo =>
      'Как показывается обратный отсчёт: полноэкранное предупреждение или минимальная накладка, привлекающая меньше внимания.';

  @override
  String get eventDefaultsCountdownVibrateInfo =>
      'Телефон вибрирует во время обратного отсчёта, чтобы вы заметили его даже с телефоном в кармане.';

  @override
  String get eventDefaultsCountdownSoundInfo =>
      'Проигрывает звуковой сигнал во время обратного отсчёта. Отключите, если предупреждение должно оставаться беззвучным.';

  @override
  String get eventDefaultsFakeCallStyleInfo =>
      'Экран входящего звонка какого приложения имитирует поддельный звонок, чтобы он выглядел правдоподобно на вашем телефоне.';

  @override
  String get eventDefaultsFakeCallCallerNameInfo =>
      'Имя, отображаемое как звонящий на экране поддельного звонка. Выберите того, кому вам было бы естественно ответить.';

  @override
  String get eventDefaultsFakeCallRingDurationInfo =>
      'Сколько времени звонит поддельный звонок, прежде чем считаться пропущенным. Пропущенный звонок позволяет цепочке эскалировать.';

  @override
  String get eventDefaultsFakeCallVoiceOutputInfo =>
      'Где воспроизводится голос после ответа: в динамике у уха (тихо и приватно) или через громкоговоритель.';

  @override
  String get eventDefaultsFakeCallRingtoneInfo =>
      'Рингтон поддельного звонка. Импортируйте собственный аудиофайл, совпадающий с вашим настоящим рингтоном — если файл пропадёт, прозвучит встроенный рингтон.';

  @override
  String get eventDefaultsFakeCallDeclineIsSafeInfo =>
      'Если включено, отклонение звонка считается отметкой безопасности, и цепочка сбрасывается. Если выключено, отклонение считается пропуском, и звонок может прозвенеть снова.';

  @override
  String get eventDefaultsSmsChannelInfo =>
      'Мессенджер, используемый на этом шаге: SMS, WhatsApp, Telegram или Signal. Контакты, которые не могут получать выбранный канал, отображаются серыми.';

  @override
  String get smsContactRecipientsInfo =>
      'Кто получает это оповещение. Нажимайте на контакты, чтобы выбрать их — если выбрать всех, список останется динамическим, и добавленные позже контакты будут включены автоматически.';

  @override
  String eventDefaultsSmsMessageTemplateInfo(Object name, Object location) {
    return 'Текст оповещения. Плейсхолдеры вроде $name и $location заполняются реальными значениями при отправке сообщения. Оставьте пустым, чтобы использовать встроенное оповещение.';
  }

  @override
  String get eventDefaultsSmsIncludeLocationInfo =>
      'Добавляет вашу текущую GPS-позицию к сообщению, чтобы контакты знали, где вас искать.';

  @override
  String get eventDefaultsSmsIncludeMedicalInfo =>
      'Добавляет в сообщение медицинские данные из вашего профиля (например, группу крови или аллергии) для спасателей.';

  @override
  String get eventDefaultsSmsAutoRecordInfo =>
      'Автоматически начинает аудиозапись при срабатывании этого шага, сохраняя свидетельство происходящего вокруг вас.';

  @override
  String get eventDefaultsSmsRecordDurationInfo =>
      'Сколько секунд длится автоматическая аудиозапись.';

  @override
  String get eventDefaultsPhonePrimaryContactInfo =>
      'Контакт, которому звонят первым. Оставьте пустым, чтобы позвонить первому экстренному контакту. Если он не ответит, запасные варианты пробуются по порядку.';

  @override
  String get eventDefaultsLoudAlarmVolumeInfo =>
      'Насколько громко звучит тревога: от тишины (0) до максимума устройства (1). Тревога предназначена привлекать внимание людей поблизости.';

  @override
  String get eventDefaultsLoudAlarmSoundInfo =>
      'Какой звук проигрывает тревога: встроенную сирену или собственный звук.';

  @override
  String get eventDefaultsLoudAlarmFlashScreenInfo =>
      'Экран мигает яркими цветами, пока звучит тревога. По умолчанию выключено — мигание может влиять на людей со светочувствительностью.';

  @override
  String get eventDefaultsLoudAlarmFlashLightInfo =>
      'Стробирует фонарик камеры, пока звучит тревога, чтобы вас было легче найти в темноте.';

  @override
  String get eventDefaultsLoudAlarmGradualInfo =>
      'Поднимает громкость от тишины до настроенного уровня вместо старта на полной громкости.';

  @override
  String get eventDefaultsCallEmergencyNumberInfo =>
      'Переопределяет экстренный номер, набираемый этим шагом. Оставьте пустым, чтобы использовать общий номер приложения (например, 112 или 911).';

  @override
  String get eventDefaultsCallEmergencySmsFirstInfo =>
      'Отправляет SMS с местоположением вашим экстренным контактам прямо перед набором, чтобы они были в курсе, даже если звонок не пройдёт.';

  @override
  String get eventDefaultsCallEmergencyConfirmInfo =>
      'Показывает короткий обратный отсчёт перед набором, давая последний шанс отменить случайный экстренный вызов.';

  @override
  String get eventDefaultsCallEmergencyConfirmDurationInfo =>
      'Сколько секунд длится отсчёт отмены, прежде чем будет сделан экстренный вызов.';

  @override
  String get eventDefaultsHardwareButtonInfo =>
      'Какую физическую кнопку (громкость вверх или вниз) этот шаг отслеживает для панического нажатия.';

  @override
  String get eventDefaultsHardwarePatternInfo =>
      'Шаблон нажатия, запускающий шаг: несколько быстрых нажатий подряд или одно долгое нажатие.';

  @override
  String get eventDefaultsHardwarePressCountInfo =>
      'Сколько быстрых нажатий подряд требуется. Чем больше нажатий, тем менее вероятны случайные срабатывания.';

  @override
  String get eventDefaultsHardwareLongDurationInfo =>
      'Как долго нужно удерживать кнопку, чтобы запустить шаг.';

  @override
  String get eventPreviewCardLabel => 'Предпросмотр';

  @override
  String eventPreviewFakeCallCaller(Object name) {
    return 'Входящий звонок от $name';
  }

  @override
  String eventPreviewFakeCallRing(int seconds, Object style) {
    return 'Звонит $seconds с · $style';
  }

  @override
  String get eventPreviewFakeCallDeclineSafe =>
      'Отклонение считается отметкой безопасности.';

  @override
  String get eventPreviewFakeCallDeclineNotSafe =>
      'Отклонение считается пропуском — звонок может прозвенеть снова.';

  @override
  String eventPreviewSmsToAll(Object channel) {
    return 'Всем контактам · $channel';
  }

  @override
  String eventPreviewSmsToCount(num count, Object channel) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count контактам · $channel',
      many: '$count контактам · $channel',
      few: '$count контактам · $channel',
      one: '$count контакту · $channel',
    );
    return '$_temp0';
  }

  @override
  String eventPreviewSmsToFirst(Object channel) {
    return 'Вашему первому контакту · $channel';
  }

  @override
  String eventPreviewSmsMessage(Object gist) {
    return 'Сообщение: $gist';
  }

  @override
  String eventPreviewLoudAlarmTitle(int percent, Object sound) {
    return 'Громкость $percent % · $sound';
  }

  @override
  String get eventPreviewLoudAlarmRampOn => 'Громкость нарастает постепенно.';

  @override
  String get eventPreviewLoudAlarmRampOff => 'Начинает на полной громкости.';

  @override
  String get eventPreviewLoudAlarmRampMasterOff =>
      'Начинает на полной громкости — постепенное нарастание отключено в настройках сигнала тревоги.';

  @override
  String get eventPreviewLoudAlarmFlashScreen => 'Экран мигает';

  @override
  String get eventPreviewLoudAlarmFlashLight => 'Фонарик мигает';

  @override
  String get eventPreviewLoudAlarmNoFlash => 'Без мигания';

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

  @override
  String get settingsAlarmHeader => 'Сигнал тревоги';

  @override
  String get settingsAlarmDndOverrideLabel =>
      'Сигнал игнорирует беззвучный режим/вибрацию';

  @override
  String get settingsAlarmDndOverrideWarning =>
      'Внимание: сигнал будет беззвучным, если телефон в беззвучном режиме.';

  @override
  String get settingsAlarmDndOverrideInfo =>
      'Когда включено, громкий сигнал звучит на максимальной громкости, даже если телефон в беззвучном режиме или на вибрации. На Android используется аудиоканал сигнала тревоги, чтобы обойти режим «Не беспокоить». Сигнал — единственное событие, которое может переопределить настройки звука телефона.';

  @override
  String get settingsAlarmGradualLabel =>
      'Постепенно увеличивать громкость сигнала';

  @override
  String get settingsAlarmGradualInfo =>
      'Запускает сигнал тихо и наращивает до полной громкости. Это главный переключатель для всего приложения; у каждого шага сигнала есть собственная опция постепенной громкости, и оба должны быть включены, чтобы нарастание сработало.';

  @override
  String get settingsAlarmRampLabel => 'Длительность нарастания';

  @override
  String get settingsAlarmRampInfo =>
      'Сколько времени нужно сигналу, чтобы достичь полной громкости с нуля, равномерно нарастая за это время. Не действует, когда постепенная громкость отключена.';

  @override
  String get permissionNotifRationaleTitle => 'Разрешить уведомления?';

  @override
  String get permissionNotifRationaleBody =>
      'Guardian Angela использует уведомления, чтобы предупреждать вас и ваши контакты во время сеанса безопасности, включая замаскированные напоминания, которые пробуждают заблокированный телефон. Разрешите уведомления, чтобы приложение могло с вами связаться.';

  @override
  String get permissionNotifDeniedTitle => 'Уведомления заблокированы';

  @override
  String get permissionNotifDeniedBody =>
      'Уведомления отключены для Guardian Angela. Откройте системные настройки, чтобы снова их включить, и приложение сможет предупреждать вас во время сеанса.';

  @override
  String get permissionNotifAllow => 'Разрешить';

  @override
  String get permissionNotifOpenSettings => 'Открыть настройки';

  @override
  String get permissionNotifNotNow => 'Не сейчас';

  @override
  String get homeStartTriggersSummaryTitle => 'Перед запуском';

  @override
  String get homeStartTriggersDistressHeading => 'Триггер тревоги';

  @override
  String get homeStartTriggersDisarmHeading => 'Триггер автозавершения';

  @override
  String get homeStartTriggersNone => 'Не настроено';

  @override
  String homeStartTriggerButtonRepeat(String button, String count) {
    return 'Нажмите $button $count раз';
  }

  @override
  String homeStartTriggerButtonLong(String button, String seconds) {
    return 'Удерживайте $button $seconds с';
  }

  @override
  String get homeStartTriggerButtonVolumeUp => 'Громкость +';

  @override
  String get homeStartTriggerButtonVolumeDown => 'Громкость -';

  @override
  String homeStartTriggerGpsArrival(String radius) {
    return 'Завершается по прибытии в пределах $radius м от пункта назначения';
  }

  @override
  String get homeStartTriggerGpsPrompt =>
      'Пункт назначения спросят после запуска';

  @override
  String homeStartTriggerTimer(String minutes) {
    return 'Завершается автоматически через $minutes мин';
  }

  @override
  String get homeStartTriggersContinue => 'Начать сейчас';

  @override
  String get homeStartTriggersCancel => 'Отмена';

  @override
  String get homeStartBlockedNotifTitle => 'Требуются уведомления';

  @override
  String get homeStartBlockedNotifBody =>
      'Этот режим использует уведомления (замаскированные напоминания или фальшивые звонки) для вашей безопасности, но разрешение на уведомления отключено. Включите уведомления, чтобы запустить этот режим.';

  @override
  String get timingSliderEnterDuration => 'Введите длительность (секунды)';

  @override
  String commonErrorWithDetail(Object detail) {
    return 'Ошибка: $detail';
  }

  @override
  String pastEventsDetailStart(Object timestamp) {
    return 'Начало: $timestamp';
  }

  @override
  String pastEventsDetailEnd(Object timestamp) {
    return 'Окончание: $timestamp';
  }

  @override
  String get loudAlarmNotificationTitle => 'Тревога';

  @override
  String get loudAlarmNotificationBody => 'Тревога Guardian Angela активна.';
}
