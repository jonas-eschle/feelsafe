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
  String get commonDelete => 'Видалити';

  @override
  String get commonEdit => 'Редагувати';

  @override
  String get commonClose => 'Закрити';

  @override
  String get commonConfirm => 'Підтвердити';

  @override
  String get commonBack => 'Назад';

  @override
  String get pinSubmit => 'Підтвердити';

  @override
  String get homeTitle => 'Guardian Angela';

  @override
  String get homeStartSession => 'Почати сесію';

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
  String get homeNoModes => 'Ще немає режимів. Натисніть «Режими», щоб додати.';

  @override
  String get homeContactsBannerNone =>
      'Не налаштовано жодного екстреного контакту.';

  @override
  String get homeMenuSettings => 'Налаштування';

  @override
  String get homeMenuContacts => 'Контакти';

  @override
  String get homeMenuHistory => 'Минулі сесії';

  @override
  String get onboardingProfileTitle => 'Профіль і перший контакт';

  @override
  String get onboardingPermissionsTitle => 'Дозволи';

  @override
  String get onboardingNext => 'Далі';

  @override
  String get onboardingSkip => 'Пропустити';

  @override
  String get onboardingUseSimNumber => 'Використати номер SIM-картки';

  @override
  String onboardingUseSimNumberHint(Object number) {
    return '$number';
  }

  @override
  String get onboardingUseSimNumberUnsupported => 'Недоступно на iOS';

  @override
  String get onboardingUseSimNumberUnavailable => 'Не вдалося зчитати номер';

  @override
  String get onboardingUseSimNumberPermissionDenied => 'Доступ відхилено';

  @override
  String get sessionTitle => 'Сесія';

  @override
  String get sessionDisarm => 'Я в безпеці';

  @override
  String get sessionDisarmStealth => 'Анджела не потрібна';

  @override
  String get homeChainSummaryTitle => 'Зведення ланцюга';

  @override
  String get homeChainSummaryEmpty =>
      'У цьому режимі ще немає кроків — торкніться режиму для редагування.';

  @override
  String homeChainSummaryTimingTitle(Object name) {
    return 'Крок: $name';
  }

  @override
  String homeChainSummaryWait(Object seconds) {
    return 'Очікування: $seconds с';
  }

  @override
  String homeChainSummaryDuration(Object seconds) {
    return 'Активно: $seconds с';
  }

  @override
  String homeChainSummaryGrace(Object seconds) {
    return 'Пільговий період: $seconds с';
  }

  @override
  String homeChainSummaryRetry(Object count) {
    return 'Повторів: $count';
  }

  @override
  String homeChainSummaryNextStep(Object name) {
    return 'Наступний крок: $name';
  }

  @override
  String get homeChainSummaryNextStepNone => 'Наступний крок: кінець ланцюга';

  @override
  String get homeChainSummaryClose => 'Закрити';

  @override
  String get chainStepNameHoldButton => 'Утримуйте, щоб бути в безпеці';

  @override
  String get chainStepNameDisguisedReminder => 'Замасковане нагадування';

  @override
  String get chainStepNameCountdownWarning => 'Попередження з відліком';

  @override
  String get chainStepNameFakeCall => 'Фейковий дзвінок';

  @override
  String get chainStepNameSmsContact => 'SMS контакту';

  @override
  String get chainStepNamePhoneCallContact => 'Дзвінок контакту';

  @override
  String get chainStepNameLoudAlarm => 'Гучна тривога';

  @override
  String get chainStepNameCallEmergency => 'Екстрений виклик';

  @override
  String get chainStepNameHardwareButton => 'Апаратна кнопка';

  @override
  String get homeChecklistTitle => 'Налаштування безпеки';

  @override
  String get homeChecklistDismissTooltip => 'Сховати список';

  @override
  String get homeChecklistExpandTooltip => 'Показати список';

  @override
  String get homeChecklistCollapseTooltip => 'Згорнути список';

  @override
  String homeChecklistProgress(Object done, Object total) {
    return '$done з $total виконано';
  }

  @override
  String get homeChecklistAllDoneBanner => 'Готово — ви під захистом!';

  @override
  String get homeChecklistInfoTooltip => 'Чому це важливо';

  @override
  String get homeChecklistGotIt => 'Зрозуміло';

  @override
  String get homeChecklistGoThere => 'Перейти';

  @override
  String get homeChecklistItem1Title => 'Додати екстрений контакт';

  @override
  String get homeChecklistItem2Title => 'Задати PIN завершення сеансу';

  @override
  String get homeChecklistItem3Title => 'Налаштувати прихований режим';

  @override
  String get homeChecklistItem4Title => 'Спробувати симуляцію';

  @override
  String get homeChecklistItem5Title => 'Налаштувати режим безпеки';

  @override
  String get homeChecklistItem6Title => 'Надати необхідні дозволи';

  @override
  String get checklistInfo1Body =>
      'Екстрені контакти — це люди, яким Guardian Angela пише та телефонує, коли ви не позначаєте себе як у безпеці. Без хоча б одного контакту ланцюгу нікому передавати сигнал.';

  @override
  String get checklistInfo2Body =>
      'PIN завершення сеансу не дає зловмиснику тихо завершити активний сеанс. Він може намагатися, але п\'ять помилкових спроб мовчки запустять вашу тривожну ланцюжку.';

  @override
  String get checklistInfo3Body =>
      'Прихований режим маскує активний сеанс під щось безневинне на екрані — музичний плеєр, призупинений таймер, порожній екран блокування. Використовуйте, коли поряд хтось не повинен бачити, що у вас додаток безпеки.';

  @override
  String get checklistInfo4Body =>
      'Симуляція прогоняє ваш режим безпеки від початку до кінця, не надсилаючи справжніх SMS, не здійснюючи дзвінків і не вмикаючи гучну тривогу. Використовуйте, щоб опанувати тайминги заздалегідь.';

  @override
  String get checklistInfo5Body =>
      'Власні режими дають змогу налаштувати кроки, тайминги та тригери під конкретну ситуацію — шлях додому, перше побачення, нічна зміна. Два вбудованих режими — це точка старту, а не фініш.';

  @override
  String get checklistInfo6Body =>
      'Без дозволу на сповіщення Guardian Angela не може утримувати постійний статус на передньому плані, доставляти замасковані нагадування або попередити вас, що ланцюг ось-ось загостриться.';

  @override
  String get checklistTutorial3Body =>
      'Відкрийте налаштування прихованого режиму за замовчуванням і увімкніть «Увімкнути прихований режим». Звідти можна обрати фальшивий музичний бренд, сховати таймер сеансу або замаскувати значок на головному екрані.';

  @override
  String get checklistTutorial4Body =>
      'На головному екрані після вибору режиму натисніть обведену кнопку «Симулювати». Сеанс запускається з помаранчевою рамкою і значком [SIM] — нічого не покидає ваш телефон.';

  @override
  String get checklistTutorial5Body =>
      'Відкрийте екран «Режими» і або відредагуйте вбудований режим (Прогулянка / Побачення), або створіть новий з нуля. Підлаштуйте ланцюг, додайте фейковий дзвінок, задайте власні тайминги.';

  @override
  String get sessionHoldPrompt => 'Тримайте, щоб залишатися в безпеці';

  @override
  String sessionStepLabel(Object index, Object total) {
    return 'Крок $index з $total';
  }

  @override
  String sessionMissCount(Object count) {
    return 'Пропущено: $count';
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
  String get sessionReminderEarlyCheckInHint =>
      'Торкніться, щоб зареєструватися зараз';

  @override
  String get sessionReminderDefaultButton => 'OK';

  @override
  String get sessionReminderTapWordHint => 'Торкніться для продовження';

  @override
  String get sessionReminderSwipeLabel => 'Проведіть, щоб закрити';

  @override
  String get sessionReminderDismissLabel => 'Закрити';

  @override
  String get sessionStepSmsStatus => 'Надсилання повідомлення контактам…';

  @override
  String get sessionStepPhoneCallStatus => 'Виклик екстреного контакту…';

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
  String get fakeCallBrandAndroid => 'ТЕЛЕФОН';

  @override
  String get fakeCallBrandIos => 'ТЕЛЕФОН';

  @override
  String get fakeCallBrandMinimal => 'ДЗВІНОК';

  @override
  String get fakeCallDeclineSafeLabel => 'Відхилити (я в безпеці)';

  @override
  String get fakeCallDeclineUnsafeLabel => 'Відхилити (залишатися напоготові)';

  @override
  String get fakeCallHoldForDistress => 'Утримуйте 5 с для тривоги';

  @override
  String fakeCallVoicePrompt(String name) {
    return 'Голосова підказка: $name';
  }

  @override
  String fakeCallVibrationLabel(String pattern) {
    return 'Вібрація: $pattern';
  }

  @override
  String get fakeCallVibrationPatternDefault => 'за замовчуванням';

  @override
  String get fakeCallSlideToAnswerHint => 'Проведіть, щоб відповісти';

  @override
  String fakeCallActiveDuration(String mm, String ss) {
    return '$mm:$ss';
  }

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
  String get contactFormIosSmsWarning =>
      'На iOS SMS відкривається в застосунку «Повідомлення». Потрібно надіслати вручну.';

  @override
  String get modesTitle => 'Режими';

  @override
  String get modesEmpty =>
      'Ще немає режимів. Натисніть «Додати», щоб створити режим.';

  @override
  String get modesAdd => 'Додати режим';

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
  String get modeEditorTitleCreate => 'Новий режим';

  @override
  String get modeEditorTitleEdit => 'Редагувати режим';

  @override
  String get modeFieldName => 'Назва';

  @override
  String get modeChainHeader => 'Ланцюг';

  @override
  String get modeChainAddStep => 'Додати крок';

  @override
  String get modeUnsavedTitle => 'Скасувати зміни?';

  @override
  String get modeUnsavedBody => 'Є незбережені зміни. Скасувати та вийти?';

  @override
  String get modeUnsavedDiscard => 'Скасувати';

  @override
  String get modeUnsavedKeep => 'Продовжити';

  @override
  String stepTimingSummary(Object wait, Object duration, Object grace) {
    return 'очікування $waitс / тривалість $durationс / пільговий $graceс';
  }

  @override
  String get distressModesEmpty => 'Ще немає режимів тривоги.';

  @override
  String get distressModeEditorTitleCreate => 'Новий режим тривоги';

  @override
  String get distressModeEditorTitleEdit => 'Редагувати режим тривоги';

  @override
  String get templatesTitle => 'Шаблони нагадувань';

  @override
  String get templatesEmpty => 'Ще немає шаблонів.';

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
  String get settingsThemeLight => 'Світла';

  @override
  String get settingsThemeDark => 'Темна';

  @override
  String get settingsThemeSystem => 'Системна';

  @override
  String get settingsEmergencyNumberLabel => 'Номер екстреної служби';

  @override
  String get settingsRedoOnboardingActiveSessionTooltip =>
      'Неможливо повторити знайомство під час активної сесії';

  @override
  String get settingsEmergencyNumberCountryPickerTitle =>
      'Виберіть номер екстреної служби';

  @override
  String get settingsRedoOnboarding => 'Повторити знайомство';

  @override
  String get settingsRedoOnboardingConfirm => 'Почати знайомство спочатку?';

  @override
  String get securitySessionEndPinBiometric =>
      'Використовувати біометрію для PIN-коду завершення сесії';

  @override
  String get securityAppPinBiometric =>
      'Використовувати біометрію для блокування застосунку';

  @override
  String get launchPinTitle => 'Введіть PIN-код застосунку';

  @override
  String get launchPinBiometricReason => 'Розблокувати Guardian Angela';

  @override
  String get launchPinIncorrect => 'Неправильний PIN-код';

  @override
  String get securitySetPin => 'Встановити PIN';

  @override
  String get securityChangePin => 'Змінити PIN';

  @override
  String get pinSetupMismatch => 'PIN-коди не збігаються. Спробуйте ще раз.';

  @override
  String get stealthTimerDisplayNormal => 'Показати повний текст';

  @override
  String get stealthTimerDisplaySmall => 'Показувати лише цифри';

  @override
  String get stealthTimerDisplayNone => 'Сховати таймер';

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
  String get batteryAlertTitle => 'Сповіщення про батарею';

  @override
  String get eventDefaultsTitle => 'Типові значення кроків';

  @override
  String get historyRetentionTitle => 'Зберігання історії';

  @override
  String get backupTitle => 'Резервне копіювання';

  @override
  String get aboutTitle => 'Про застосунок';

  @override
  String aboutVersion(Object version) {
    return 'Версія';
  }

  @override
  String get feedbackTitle => 'Зворотний зв\'язок';

  @override
  String get feedbackSend => 'Відкрити пошту';

  @override
  String get stealthPresetPodcast => 'Подкаст';

  @override
  String get stealthPresetNone => 'Немає';

  @override
  String get stealthLockTaskLabel => 'Закріпити застосунок під час сесії';

  @override
  String get stealthLockTaskSubtitle =>
      'Не дає вийти із застосунку під час активної сесії. На Android вмикає закріплення екрана; на інших платформах не діє.';

  @override
  String get homeTagline => 'Ваш янгол вас оберігає.';

  @override
  String get onboardingWelcomeGreeting => 'Привіт, я Анджела';

  @override
  String get onboardingWelcomeBodyFull =>
      'Я ваш особистий охоронець. Я супроводжую вас, наглядаю за вашим вечором і дію, якщо щось не так.';

  @override
  String get onboardingGetStarted => 'Почати';

  @override
  String get onboardingProfileNameLabel => 'Ім\'я';

  @override
  String get onboardingProfilePhoneLabel => 'Номер телефону';

  @override
  String get onboardingProfilePhoneHelper =>
      'Включається в екстрені повідомлення.';

  @override
  String get onboardingEmergencyContactHeader => 'Екстрений контакт';

  @override
  String get onboardingEmergencyContactPrompt =>
      'Кому повідомити, якщо щось піде не так?';

  @override
  String get onboardingEmergencyContactAdd => 'Додати екстрений контакт';

  @override
  String get onboardingPermissionsIntro =>
      'Ці дозволи захищають вас під час сесій.';

  @override
  String get onboardingPermissionsGrantAll => 'Надати всі';

  @override
  String get onboardingPermissionsRequired => 'ОБОВ\'ЯЗКОВО';

  @override
  String get onboardingPermissionsOptional => 'НЕОБОВ\'ЯЗКОВО';

  @override
  String get onboardingPermissionsMicrophone => 'Мікрофон';

  @override
  String get onboardingPermissionsCamera => 'Камера';

  @override
  String get onboardingPermissionsNotificationDesc =>
      'Потрібен для сповіщень і нагадувань під час сесії.';

  @override
  String get onboardingPermissionsSmsDesc =>
      'Потрібен для надсилання екстрених SMS-повідомлень.';

  @override
  String get onboardingPermissionsPhoneDesc =>
      'Потрібен для екстрених і фейкових дзвінків.';

  @override
  String get onboardingPermissionsLocationDesc =>
      'Включається в екстрені повідомлення, коли ввімкнено запис GPS.';

  @override
  String get onboardingPermissionsMicrophoneDesc =>
      'Використовується для аудіозапису під час тривоги.';

  @override
  String get onboardingPermissionsCameraDesc =>
      'Використовується для світлового сигналу SOS.';

  @override
  String get sessionInterruptedTitle => 'Сесію перервано';

  @override
  String get sessionInterruptedBody =>
      'Під час зупинки застосунку виконувалася сесія. Стан сесії втрачено — нічого не відновлено. Ми показуємо це, щоб ви знали.';

  @override
  String get sessionInterruptedAcknowledge => 'Зрозуміло';

  @override
  String sessionInterruptedMode(Object name) {
    return 'Режим: $name';
  }

  @override
  String sessionInterruptedStarted(Object time) {
    return 'Початок: $time';
  }

  @override
  String get sessionGpsDestinationTitle => 'Пункт призначення';

  @override
  String get sessionGpsDestinationBody =>
      'Введіть координати пункту призначення для тригера знеактивації за прибуттям GPS.';

  @override
  String get sessionGpsDestinationLat => 'Широта';

  @override
  String get sessionGpsDestinationLng => 'Довгота';

  @override
  String get sessionGpsDestinationSkip => 'Пропустити для цієї сесії';

  @override
  String get sessionGpsDestinationConfirm => 'Використати пункт призначення';

  @override
  String get sessionEndOverlayTitle => 'Завершити сесію?';

  @override
  String get sessionEndOverlayBody =>
      'Проведіть, щоб підтвердити завершення сесії';

  @override
  String get sessionEndOverlaySwipeLabel => 'Проведіть, щоб завершити';

  @override
  String get sessionEndOverlaySimBadge => '[SIM] Режим практики';

  @override
  String get sessionEndPinPromptTitle => 'Введіть PIN-код завершення сесії';

  @override
  String get sessionEndPinAppPinMismatch =>
      'Використовуйте PIN-код завершення сесії, а не PIN-код блокування застосунку.';

  @override
  String get sessionEndPinIncorrect => 'Неправильний PIN-код';

  @override
  String get sessionEndPinSimSkip => 'Пропустити (лише симуляція)';

  @override
  String get sessionEndSimDistressWouldFire =>
      'Тривожний ланцюг спрацював би (5 неправильних PIN-кодів)';

  @override
  String get distressConfirmTitle => 'Тривогу активовано';

  @override
  String distressConfirmCountdown(int seconds) {
    return 'Торкніться, щоб скасувати — у вас $seconds с';
  }

  @override
  String get distressConfirmCancel => 'Торкніться, щоб скасувати';

  @override
  String get distressConfirmFooter =>
      'Якщо не скасувати, тривожний ланцюг почнеться негайно.';

  @override
  String get distressCancelPinPromptTitle => 'Введіть PIN-код завершення сесії';

  @override
  String distressCancelPinTimeoutLabel(int seconds) {
    return 'Залишилося $seconds с';
  }

  @override
  String get distressCancelPinIncorrect => 'Неправильний PIN-код';

  @override
  String get distressCancelPinAppPinMismatch =>
      'Використовуйте PIN-код завершення сесії, а не PIN-код блокування застосунку.';

  @override
  String get distressCancelPinSimSkip => 'Пропустити (лише симуляція)';

  @override
  String get distressCancelSimDistressWouldFire =>
      'Тривожний ланцюг спрацював би (5 неправильних PIN-кодів)';

  @override
  String get distressCancelPinBack => 'Скасувати';

  @override
  String get simulationPinPromptTitle => 'Введіть PIN-код';

  @override
  String get simulationPinPromptBody =>
      'Потренуйтеся вводити PIN-код завершення сесії';

  @override
  String get simulationPinPromptSkip => 'Пропустити';

  @override
  String get simulationPinIncorrect => 'Неправильний PIN-код';

  @override
  String simulationSummaryDuration(String duration) {
    return 'Тривалість: $duration';
  }

  @override
  String get simulationSummaryTimelineHeader => 'Хронологія подій';

  @override
  String get simulationSummaryShare => 'Поділитися';

  @override
  String simulationSummaryMissedEventsBadge(int count) {
    return 'Пропущено: $count';
  }

  @override
  String simulationSummaryDistressBadge(int count) {
    return 'Тривога: $count';
  }

  @override
  String simulationSummaryStepsFiredBadge(int count) {
    return 'Спрацювало кроків: $count';
  }

  @override
  String get simulationSummaryShareSubject =>
      'Підсумок симуляції Guardian Angela';

  @override
  String get notificationsChannelAlarm => 'Ескалація тривоги';

  @override
  String get notificationsChannelAlarmDescription =>
      'Критичні сповіщення в обхід режиму «Не турбувати»';

  @override
  String get notificationsChannelReminder => 'Замасковане нагадування';

  @override
  String get notificationsChannelReminderDescription =>
      'Нагадування про реєстрацію під час активної сесії';

  @override
  String get notificationsChannelFakeCall => 'Фейковий дзвінок';

  @override
  String get notificationsChannelFakeCallDescription =>
      'Повноекранні сповіщення про вхідний дзвінок';

  @override
  String get notificationsChannelEnabled => 'Увімкнено';

  @override
  String get notificationsChannelDisabled => 'Вимкнено';

  @override
  String get notificationsChannelsHeader => 'Канали сповіщень';

  @override
  String get contactsImportFromDevice => 'Імпортувати з контактів';

  @override
  String get contactsImportNotSupported => 'Недоступно на цій платформі';

  @override
  String get contactsImportPermissionDenied =>
      'Доступ до контактів відхилено. Увімкніть у системних налаштуваннях.';

  @override
  String get contactsDeleteAllMenu => 'Видалити всі';

  @override
  String get contactsDeleteAllConfirmTitle => 'Видалити всі контакти?';

  @override
  String get contactsDeleteAllConfirmBody =>
      'Це видалить кожен екстрений контакт. Скасувати неможливо.';

  @override
  String get contactsDeleteAllTypeConfirmTitle => 'Підтвердьте, ввівши текст';

  @override
  String get contactsDeleteAllTypeConfirmHint =>
      'Введіть DELETE ALL, щоб продовжити';

  @override
  String get contactsDeleteAllTypeConfirmSentinel => 'DELETE ALL';

  @override
  String get contactsDeleteAllConfirmButton => 'Видалити всі';

  @override
  String get modesBuiltinBadge => 'Вбудований';

  @override
  String get modesBuiltinNoDelete => 'Вбудовані режими неможливо видалити';

  @override
  String get sessionCompletedSimulationBanner => 'Симуляцію завершено';

  @override
  String get sessionCompletedViewEventLog => 'Переглянути журнал подій';

  @override
  String get settingsGeneralHeader => 'Загальні';

  @override
  String get settingsAppHeader => 'Застосунок';

  @override
  String get settingsConfigurationHeader => 'Конфігурація';

  @override
  String get settingsThemeLabel => 'Тема';

  @override
  String get settingsLanguageLabel => 'Мова';

  @override
  String get settingsSecurityRow => 'Безпека';

  @override
  String get settingsSecuritySubtitle =>
      'PIN-код застосунку, PIN-код завершення сесії, PIN-код примусу';

  @override
  String get settingsStealthRow => 'Прихований режим';

  @override
  String get settingsStealthSummaryOff => 'Прихований режим: ВИМК.';

  @override
  String get settingsStealthSummaryOn => 'Прихований режим: УВІМК.';

  @override
  String get settingsProfileRow => 'Профіль';

  @override
  String get settingsModesRow => 'Режими';

  @override
  String get settingsDistressModesRow => 'Режими тривоги';

  @override
  String get settingsBatteryAlertRow => 'Сповіщення про батарею';

  @override
  String get settingsEventDefaultsRow => 'Типові значення кроків';

  @override
  String get settingsGpsLoggingRow => 'Запис GPS';

  @override
  String get settingsRemindersRow => 'Шаблони нагадувань';

  @override
  String get settingsNotificationsRow => 'Сповіщення';

  @override
  String get settingsHistoryRetentionRow => 'Історія та зберігання';

  @override
  String get settingsAboutRow => 'Про застосунок';

  @override
  String get settingsFeedbackRow => 'Надіслати відгук';

  @override
  String get settingsBackupRow => 'Резервне копіювання та відновлення';

  @override
  String get settingsOssLicenses => 'Ліцензії з відкритим кодом';

  @override
  String get settingsImportConfirmBody =>
      'Це перезапише всі поточні дані. Продовжити?';

  @override
  String get securityAppPinTitle => 'PIN-код застосунку';

  @override
  String get securityAppPinBody =>
      'Блокує застосунок щоразу під час відкриття.';

  @override
  String get securitySessionEndPinTitle => 'PIN-код завершення сесії';

  @override
  String get securitySessionEndPinBody =>
      'Потрібен, щоб знеактивувати або завершити активну сесію.';

  @override
  String get securityDuressPinTitle => 'PIN-код примусу';

  @override
  String get securityDuressPinBody =>
      'Введений у будь-якому запиті, тихо запускає тривожний ланцюг.';

  @override
  String get securityRemovePin => 'Видалити';

  @override
  String get securityRemovePinPrompt =>
      'Введіть поточний PIN-код, щоб видалити його.';

  @override
  String get securityRemovePinIncorrect => 'Неправильний PIN-код';

  @override
  String get securityWhatIsThis => 'Що це?';

  @override
  String get securityAppPinInfo =>
      'Блокує застосунок при відкритті. Клавіатура з\'являється перед будь-яким екраном. Корисно, якщо хтось ненадовго бере ваш розблокований телефон.';

  @override
  String get securitySessionEndPinInfo =>
      'Потрібен, щоб знеактивувати або завершити активну сесію безпеки. Без нього зловмисник, який заволодів вашим телефоном, не зможе зупинити ланцюг. Задайте код, відмінний від PIN-коду застосунку.';

  @override
  String get securityDuressPinInfo =>
      'Якщо ви введете цей PIN-код у будь-якому запиті, тривожний ланцюг запуститься тихо — ваші контакти отримають сповіщення, а тривога підготується так, що зловмисник не помітить. Виберіть код, відмінний від усіх інших PIN-кодів.';

  @override
  String get securityPinTimeoutLabel => 'Час очікування PIN-коду (секунди)';

  @override
  String get securityWrongPinThresholdLabel =>
      'Кількість неправильних PIN-кодів до ескалації';

  @override
  String get securityDeceptiveDialogToggle =>
      'Показувати оманливе вікно при неправильному PIN-коді';

  @override
  String get pinSetupEnterNew => 'Введіть новий PIN-код';

  @override
  String get pinSetupConfirmNew => 'Підтвердьте новий PIN-код';

  @override
  String get pinSetupTooShort => 'PIN-код має містити щонайменше 4 цифри.';

  @override
  String get pinSetupCollision =>
      'Цей PIN-код збігається з іншим налаштованим PIN-кодом.';

  @override
  String get pinSetupSaved => 'PIN-код збережено';

  @override
  String get stealthEnabledLabel => 'Увімкнути прихований режим';

  @override
  String get stealthFakeNameLabel => 'Фальшива назва застосунку';

  @override
  String get stealthFakeIconLabel => 'Фальшивий значок';

  @override
  String get stealthNotificationDisguiseLabel => 'Маскування сповіщень';

  @override
  String get stealthTimerDisplayLabel => 'Відображення таймера';

  @override
  String get stealthSessionScreenLabel => 'Прихований екран сесії';

  @override
  String get gpsLoggingEnabled => 'Записувати GPS під час сесій';

  @override
  String get gpsLoggingIntervalLabel => 'Інтервал';

  @override
  String get gpsLoggingAccuracyLabel => 'Точність';

  @override
  String get gpsLoggingAccuracyHigh => 'Висока';

  @override
  String get gpsLoggingAccuracyBalanced => 'Збалансована';

  @override
  String get gpsLoggingAccuracyLow => 'Низька';

  @override
  String get gpsLoggingFormatLabel => 'Формат координат';

  @override
  String get gpsLoggingFormatDecimal => 'Десятковий';

  @override
  String get gpsLoggingFormatDms => 'DMS';

  @override
  String get gpsLoggingFormatAddress => 'Plus Code';

  @override
  String get gpsLoggingIncludeInSms => 'Додавати місцезнаходження до SMS';

  @override
  String get historyRetentionLogsLabel => 'Зберігання журналів сесій (днів)';

  @override
  String get historyRetentionLogsHelper =>
      'Журнали, старіші за цей термін, переміщуються в кошик.';

  @override
  String get historyRetentionTrashLabel => 'Зберігання в кошику (днів)';

  @override
  String get historyRetentionTrashHelper =>
      'Журнали в кошику остаточно видаляються після цього періоду.';

  @override
  String get historyRetentionUpdated => 'Налаштування зберігання оновлено';

  @override
  String get historyRetentionPurgeNow => 'Очистити зараз';

  @override
  String historyRetentionPurged(Object count) {
    return 'Очищено журналів: $count';
  }

  @override
  String get batteryAlertEnableLabel => 'Увімкнути сповіщення про батарею';

  @override
  String get batteryAlertThresholdLabel => 'Поріг батареї (%)';

  @override
  String get batteryAlertChainHeader => 'Ланцюг сповіщень';

  @override
  String get batteryAlertResetChain => 'Скинути';

  @override
  String get eventDefaultsCheckInHeader => 'Методи реєстрації';

  @override
  String get eventDefaultsEscalationHeader => 'Кроки ескалації';

  @override
  String get eventDefaultsPanicHeader => 'Тривожний тригер';

  @override
  String get templatesCreate => 'Створити шаблон';

  @override
  String get templatesEditTitle => 'Редагувати шаблон';

  @override
  String get templatesCreateTitle => 'Новий шаблон';

  @override
  String get templatesNameLabel => 'Назва';

  @override
  String get templatesTitleLabel => 'Заголовок';

  @override
  String get templatesBodyLabel => 'Текст';

  @override
  String get templatesBuiltinNoDelete => 'Вбудовані шаблони неможливо видалити';

  @override
  String get templatesAddFromTemplate => 'З шаблону';

  @override
  String get templatesAddFromScratch => 'З нуля';

  @override
  String templatesDeleteConfirmTitle(Object name) {
    return 'Видалити «$name»?';
  }

  @override
  String get templatesDeleteConfirmBody => 'Цей шаблон буде видалено назавжди.';

  @override
  String get templatesEmptyAddFirst => 'Додайте свій перший шаблон';

  @override
  String get templatesPickFromBuiltinTitle => 'Виберіть вбудований шаблон';

  @override
  String get templatesIconLabel => 'Значок';

  @override
  String get templatesIconCalendar => 'Календар';

  @override
  String get templatesIconAppNotification => 'Сповіщення застосунку';

  @override
  String get templatesIconFitness => 'Фітнес';

  @override
  String get templatesIconHealth => 'Здоров\'я';

  @override
  String get templatesIconFood => 'Їжа';

  @override
  String get templatesIconCoffee => 'Кава';

  @override
  String get templatesIconBattery => 'Батарея';

  @override
  String get templatesIconWeather => 'Погода';

  @override
  String get templatesPreviewHeading => 'Перегляд у реальному часі';

  @override
  String get templatesDiscardChangesTitle => 'Скасувати зміни?';

  @override
  String get templatesDiscardChangesBody => 'Незбережені зміни буде втрачено.';

  @override
  String get templatesDiscardKeep => 'Продовжити редагування';

  @override
  String get templatesDiscardDiscard => 'Скасувати';

  @override
  String get notificationsTitle => 'Сповіщення';

  @override
  String get notificationsStatusGranted => 'Надано';

  @override
  String get notificationsStatusDenied => 'Відхилено';

  @override
  String get notificationsStatusUnknown => 'Ще не запитано';

  @override
  String get notificationsRequest => 'Запитати дозвіл';

  @override
  String get notificationsOpenSettings => 'Відкрити системні налаштування';

  @override
  String get profileFieldPhone => 'Номер телефону';

  @override
  String get profileFieldDescription => 'Зовнішній опис';

  @override
  String get profileFieldMedicalConditions => 'Стан здоров\'я';

  @override
  String get profileFieldEmergencyInstructions => 'Екстрені інструкції';

  @override
  String get aboutAuthor => 'Автор: Jonas Eschle';

  @override
  String get aboutEmail => 'guardian.angela.app@gmail.com';

  @override
  String get aboutPrivacyPolicy => 'Політика конфіденційності';

  @override
  String get aboutTermsOfService => 'Умови використання';

  @override
  String get aboutSourceCode => 'Вихідний код';

  @override
  String get aboutSupport => 'Підтримка / донат';

  @override
  String get aboutLicenses => 'Ліцензії з відкритим кодом';

  @override
  String get aboutTagline => 'Створено з любов\'ю заради безпеки ЛГБТК+.';

  @override
  String get aboutTechnicalSection => 'Технічна інформація';

  @override
  String aboutBundleId(Object id) {
    return 'Bundle ID: $id';
  }

  @override
  String aboutPlatforms(Object list) {
    return 'Платформи: $list';
  }

  @override
  String get feedbackHeading => 'Ми будемо раді почути вашу думку';

  @override
  String get feedbackCategoryLabel => 'Категорія';

  @override
  String get feedbackCategoryBug => 'Звіт про помилку';

  @override
  String get feedbackCategoryFeature => 'Запит на функцію';

  @override
  String get feedbackCategoryOther => 'Інше';

  @override
  String get feedbackEmailLabel => 'Email (необов\'язково)';

  @override
  String get feedbackMessageLabel => 'Повідомлення';

  @override
  String get feedbackIncludeLog => 'Додати журнал останньої сесії';

  @override
  String get feedbackSent => 'Дякуємо за відгук!';

  @override
  String get feedbackMessageRequired =>
      'Повідомлення має містити щонайменше 10 символів.';

  @override
  String get backupIncludeLogs => 'Додати журнали сесій';

  @override
  String get backupIncludeMedia => 'Додати медіа';

  @override
  String get backupExportButton => 'Експортувати';

  @override
  String get backupImportButton => 'Імпортувати';

  @override
  String get backupOverwriteWarning => 'Імпорт перезапише всі поточні дані.';

  @override
  String get backupImportSuccess =>
      'Імпорт завершено. Перезапустіть, щоб застосувати.';

  @override
  String backupImportError(Object message) {
    return 'Не вдалося імпортувати: $message';
  }

  @override
  String get backupActiveSessionBanner =>
      'Резервне копіювання недоступне під час активної сесії.';

  @override
  String backupLastBackupAtLabel(Object when) {
    return 'Остання резервна копія: $when';
  }

  @override
  String get backupNeverExportedLabel => 'Резервних копій ще немає';

  @override
  String get pastEventsTitle => 'Минулі сесії';

  @override
  String get pastEventsTabReal => 'Справжні';

  @override
  String get pastEventsTabSimulated => 'Симульовані';

  @override
  String get pastEventsEmpty => 'Ще немає сесій';

  @override
  String get pastEventsDeleteConfirm => 'Видалити журнал сесії?';

  @override
  String get pastEventsDetailShareText => 'Поділитися як текстом';

  @override
  String get pastEventsDetailSharePdf => 'Поділитися як PDF';

  @override
  String get pastEventsDetailDelete => 'Видалити';

  @override
  String get pastEventsOutcomeCompleted => 'Завершено';

  @override
  String get pastEventsOutcomeDistress => 'Тривога';

  @override
  String get pastEventsOutcomeInterrupted => 'Перервано';

  @override
  String get pastEventsTrash => 'Кошик';

  @override
  String get pastEventsUndo => 'Скасувати';

  @override
  String get pastEventsSoftDeleted => 'Переміщено в кошик';

  @override
  String get pastEventsDetailTitle => 'Журнал сесії';

  @override
  String get pastEventsDetailShare => 'Поділитися';

  @override
  String get contactUnsavedDiscardTitle => 'Скасувати незбережені зміни?';

  @override
  String get contactUnsavedDiscardKeep => 'Продовжити редагування';

  @override
  String get contactUnsavedDiscardDiscard => 'Скасувати';

  @override
  String get modesDuplicate => 'Дублювати';

  @override
  String get modesDeleteConfirmTitle => 'Видалити режим?';

  @override
  String modesDeleteConfirmBody(Object name) {
    return '$name буде видалено назавжди.';
  }

  @override
  String get modesDistressDefaultBadge => 'За замовчуванням';

  @override
  String get modesDistressSetDefault => 'Зробити стандартним';

  @override
  String get modesDistressCantDeleteLast =>
      'Потрібен щонайменше один режим тривоги.';

  @override
  String get modesDistressInUse =>
      'Цей режим тривоги використовується іншим режимом.';

  @override
  String get modesDistressTitle => 'Режими тривоги';

  @override
  String get validationNameTooShort =>
      'Ім\'я має містити щонайменше 2 символи.';

  @override
  String get validationPhoneRequired => 'Номер телефону обов\'язковий.';

  @override
  String get validationChannelsRequired => 'Виберіть щонайменше один канал.';

  @override
  String get sessionHoldTouchToBegin => 'Торкніться, щоб почати';

  @override
  String sessionHoldReleaseCountdown(Object seconds) {
    return 'Відлік: $seconds с';
  }

  @override
  String sessionHoldGraceCountdown(Object seconds) {
    return 'Пільговий період: $seconds с — утримуйте знову, щоб залишатися в безпеці';
  }

  @override
  String get sessionHoldAgain => 'Утримуйте знову, щоб залишатися в безпеці';

  @override
  String sessionStepNextCheckIn(Object time) {
    return 'Наступна реєстрація через $time';
  }

  @override
  String sessionStepFakeCallActive(Object caller) {
    return 'Вхідний дзвінок від $caller';
  }

  @override
  String get sessionStepFakeCallOpen => 'Відкрити екран дзвінка';

  @override
  String sessionStepSimBlockedSms(Object count) {
    return '[SIM] Надіслало б SMS $count контактам';
  }

  @override
  String get sessionStepSimBlockedPhone =>
      '[SIM] Зателефонувало б екстреному контакту';

  @override
  String get sessionStepSimBlockedEmergency =>
      '[SIM] Зателефонувало б екстреним службам';

  @override
  String get sessionStepSimBlockedAlarm =>
      '[SIM] Тривога пролунала б на повну гучність';

  @override
  String get sessionStartFailedTitle => 'Неможливо почати сесію';

  @override
  String get sessionStartFailedBody => 'Перед початком усуньте такі проблеми:';

  @override
  String get sessionQuickExitTitle => 'Швидкий вихід';

  @override
  String get sessionQuickExitBody =>
      'Дані сесії буде збережено та зашифровано. Знову відкрийте застосунок будь-коли, щоб їх відновити.';

  @override
  String get sessionQuickExitConfirm => 'Вийти із застосунку';

  @override
  String get pastEventsRestore => 'Відновити';

  @override
  String batteryAlertForbiddenStep(Object type) {
    return '$type не дозволено в ланцюзі сповіщень про батарею.';
  }

  @override
  String get stepEditorWait => 'Очікування (с)';

  @override
  String get stepEditorDuration => 'Тривалість (с)';

  @override
  String get stepEditorGrace => 'Пільговий період (с)';

  @override
  String get stepEditorRetryCount => 'Кількість повторів';

  @override
  String get stepEditorRandomize => 'Випадковий тайминг (±20%)';

  @override
  String get stepEditorRemove => 'Видалити крок';

  @override
  String get eventDefaultsHoldStyle => 'Стиль утримання';

  @override
  String get eventDefaultsHoldSensitivity => 'Чутливість відпускання';

  @override
  String get eventDefaultsHoldVibrate => 'Вібрація при відпусканні';

  @override
  String get eventDefaultsHoldSound => 'Звук при відпусканні';

  @override
  String get eventDefaultsBlackScreen => 'Накладання чорного екрана';

  @override
  String get eventDefaultsReminderRandomInterval => 'Випадковий інтервал';

  @override
  String get eventDefaultsReminderRandomTemplate =>
      'Випадковий порядок шаблонів';

  @override
  String get eventDefaultsReminderResetOnEarly =>
      'Скидати при ранній реєстрації';

  @override
  String get eventDefaultsCountdownStyle => 'Стиль відліку';

  @override
  String get eventDefaultsCountdownVibrate => 'Вібрація';

  @override
  String get eventDefaultsCountdownSound => 'Звук';

  @override
  String get eventDefaultsFakeCallStyle => 'Стиль дзвінка';

  @override
  String get eventDefaultsFakeCallCallerName => 'Ім\'я абонента';

  @override
  String get eventDefaultsFakeCallRingDuration => 'Тривалість дзвінка (с)';

  @override
  String get eventDefaultsFakeCallDeclineIsSafe => 'Відхилення означає безпеку';

  @override
  String get eventDefaultsFakeCallVoiceOutput => 'Голосовий вивід';

  @override
  String get eventDefaultsSmsChannel => 'Канал';

  @override
  String get eventDefaultsSmsIncludeLocation => 'Додати місцезнаходження';

  @override
  String get eventDefaultsSmsIncludeMedical => 'Додати медичну інформацію';

  @override
  String get eventDefaultsSmsAutoRecord => 'Записувати аудіо перед надсиланням';

  @override
  String get eventDefaultsSmsRecordDuration => 'Тривалість запису (с)';

  @override
  String get eventDefaultsLoudAlarmVolume => 'Гучність';

  @override
  String get eventDefaultsLoudAlarmSound => 'Звук';

  @override
  String get eventDefaultsLoudAlarmFlashScreen => 'Блимання екрана';

  @override
  String get eventDefaultsLoudAlarmFlashLight => 'Блимання спалаху камери';

  @override
  String get eventDefaultsLoudAlarmGradual => 'Поступове наростання гучності';

  @override
  String get eventDefaultsCallEmergencyNumber =>
      'Номер екстреної служби (перевизначення)';

  @override
  String get eventDefaultsCallEmergencyConfirm =>
      'Показувати відлік підтвердження';

  @override
  String get eventDefaultsCallEmergencyConfirmDuration =>
      'Секунди підтвердження';

  @override
  String get eventDefaultsCallEmergencySmsFirst =>
      'Спочатку надіслати SMS з місцезнаходженням';

  @override
  String get eventDefaultsPhonePrimaryContact => 'Основний контакт (id)';

  @override
  String get eventDefaultsHardwareButton => 'Кнопка';

  @override
  String get eventDefaultsHardwarePattern => 'Шаблон натискання';

  @override
  String get eventDefaultsHardwarePressCount => 'Кількість натискань';

  @override
  String get eventDefaultsHardwareLongDuration =>
      'Тривалість довгого натискання (с)';

  @override
  String get pastEventsTrashTitle => 'Кошик';

  @override
  String get pastEventsTrashEmpty => 'Кошик порожній';

  @override
  String get pastEventsTrashEmptyAll => 'Очистити кошик';

  @override
  String get pastEventsTrashEmptyAllConfirmTitle => 'Очистити кошик?';

  @override
  String get pastEventsTrashEmptyAllConfirmBody =>
      'Введіть EMPTY TRASH нижче, щоб підтвердити. Це назавжди видалить кожен журнал у кошику.';

  @override
  String pastEventsTrashEmptyAllSuccess(Object count) {
    return 'Кошик очищено (журналів: $count)';
  }

  @override
  String pastEventsTrashRetentionNote(int days) {
    return 'Журнали в кошику остаточно видаляються через $days днів.';
  }

  @override
  String pastEventsTrashRemainingDays(int days) {
    return '$days дн. до остаточного видалення';
  }

  @override
  String get pastEventsTrashDeletePermanently => 'Видалити назавжди';

  @override
  String get pastEventsTrashDeletePermanentlyBody =>
      'Цю дію неможливо скасувати.';

  @override
  String sessionEmergencyConfirmTitle(String number, int seconds) {
    return 'Виклик $number через $seconds с';
  }

  @override
  String get sessionEmergencyConfirmSwipe => 'Проведіть, щоб скасувати';

  @override
  String get sessionEmergencyConfirmKeep => 'Продовжити виклик';

  @override
  String get sessionEmergencyConfirmSimBadge => '[SIM] Режим практики';

  @override
  String get sessionEmergencyConfirmSimCancelled =>
      'Симульоване скасування — виклик не було б здійснено';

  @override
  String get swipeSliderSemantics => 'Проведіть, щоб підтвердити';

  @override
  String get homeWidgetStatusIdle => 'Очікування';

  @override
  String get homeWidgetStatusSession => 'Сесія активна';

  @override
  String get homeWidgetStatusSim => 'Симуляція активна';

  @override
  String get homeWidgetStatusBatteryAlert => 'Сповіщення про батарею';

  @override
  String get homeWidgetQuickExit => 'Швидкий вихід';

  @override
  String get homeWidgetFakeCall => 'Несправжній дзвінок';
}
