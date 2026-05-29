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
  String get onboardingUseSimNumber => 'Use my SIM number';

  @override
  String onboardingUseSimNumberHint(Object number) {
    return '$number';
  }

  @override
  String get onboardingUseSimNumberUnsupported => 'Not available on iOS';

  @override
  String get onboardingUseSimNumberUnavailable => 'Couldn\'t read number';

  @override
  String get onboardingUseSimNumberPermissionDenied => 'Permission denied';

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
      'On iOS, SMS opens the Messages app. You must tap Send manually.';

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
      'Cannot redo onboarding during an active session';

  @override
  String get settingsEmergencyNumberCountryPickerTitle =>
      'Choose emergency number';

  @override
  String get settingsRedoOnboarding => 'Повторити знайомство';

  @override
  String get settingsRedoOnboardingConfirm => 'Почати знайомство спочатку?';

  @override
  String get securitySessionEndPinBiometric =>
      'Використовувати біометрію для PIN-коду завершення сесії';

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
  String get stealthLockTaskLabel => 'Pin app during session';

  @override
  String get stealthLockTaskSubtitle =>
      'Prevents leaving the app while a session is running. On Android this engages screen-pinning; on other platforms this is a no-op.';

  @override
  String get homeTagline => 'Your angel\'s got your back.';

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
  String get onboardingEmergencyContactHeader => 'Emergency contact';

  @override
  String get onboardingEmergencyContactPrompt =>
      'Who should we contact if something goes wrong?';

  @override
  String get onboardingEmergencyContactAdd => 'Add emergency contact';

  @override
  String get onboardingPermissionsIntro =>
      'These permissions keep you safe during sessions.';

  @override
  String get onboardingPermissionsGrantAll => 'Grant all';

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
  String get sessionGpsDestinationSkip => 'Skip for this session';

  @override
  String get sessionGpsDestinationConfirm => 'Use destination';

  @override
  String get sessionEndOverlayTitle => 'End session?';

  @override
  String get sessionEndOverlayBody =>
      'Swipe to confirm you want to end the session';

  @override
  String get sessionEndOverlaySwipeLabel => 'Swipe to end';

  @override
  String get sessionEndOverlaySimBadge => '[SIM] Practice mode';

  @override
  String get sessionEndPinPromptTitle => 'Enter Session End PIN';

  @override
  String get sessionEndPinAppPinMismatch =>
      'Use the Session End PIN, not the app lock PIN.';

  @override
  String get sessionEndPinIncorrect => 'Incorrect PIN';

  @override
  String get sessionEndPinSimSkip => 'Skip (sim only)';

  @override
  String get sessionEndSimDistressWouldFire =>
      'Distress chain would fire (5 wrong PINs)';

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
  String get distressCancelPinPromptTitle => 'Enter Session End PIN';

  @override
  String distressCancelPinTimeoutLabel(int seconds) {
    return '${seconds}s remaining';
  }

  @override
  String get distressCancelPinIncorrect => 'Incorrect PIN';

  @override
  String get distressCancelPinAppPinMismatch =>
      'Use the Session End PIN, not the app lock PIN.';

  @override
  String get distressCancelPinSimSkip => 'Skip (sim only)';

  @override
  String get distressCancelSimDistressWouldFire =>
      'Distress chain would fire (5 wrong PINs)';

  @override
  String get distressCancelPinBack => 'Cancel';

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
  String get gpsLoggingFormatAddress => 'Plus Code';

  @override
  String get gpsLoggingIncludeInSms => 'Append location to SMS';

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
  String get aboutTechnicalSection => 'Technical information';

  @override
  String aboutBundleId(Object id) {
    return 'Bundle ID: $id';
  }

  @override
  String aboutPlatforms(Object list) {
    return 'Platforms: $list';
  }

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
  String get contactUnsavedDiscardTitle => 'Discard unsaved changes?';

  @override
  String get contactUnsavedDiscardKeep => 'Keep editing';

  @override
  String get contactUnsavedDiscardDiscard => 'Discard';

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
  String get modesDistressInUse =>
      'This distress mode is in use by another mode.';

  @override
  String get modesDistressTitle => 'Distress modes';

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
  String sessionStepNextCheckIn(Object time) {
    return 'Next check-in in $time';
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
  String get pastEventsRestore => 'Restore';

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
  String get pastEventsTrashEmptyAll => 'Empty trash';

  @override
  String get pastEventsTrashEmptyAllConfirmTitle => 'Empty trash?';

  @override
  String get pastEventsTrashEmptyAllConfirmBody =>
      'Type EMPTY TRASH below to confirm. This deletes every trashed log permanently.';

  @override
  String pastEventsTrashEmptyAllSuccess(Object count) {
    return 'Trash emptied ($count logs)';
  }

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

  @override
  String sessionEmergencyConfirmTitle(String number, int seconds) {
    return 'Calling $number in ${seconds}s';
  }

  @override
  String get sessionEmergencyConfirmSwipe => 'Swipe to cancel';

  @override
  String get sessionEmergencyConfirmKeep => 'Keep calling';

  @override
  String get sessionEmergencyConfirmSimBadge => '[SIM] Practice mode';

  @override
  String get sessionEmergencyConfirmSimCancelled =>
      'Simulated cancel — call would not have been placed';

  @override
  String get swipeSliderSemantics => 'Swipe to confirm';
}
