// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'SafeWayHome';

  @override
  String get startSession => 'Начать сеанс';

  @override
  String get endSession => 'Завершить сеанс';

  @override
  String get imSafe => 'Я в порядке';

  @override
  String get checkInPrompt => 'Вы всё ещё в безопасности?';

  @override
  String countdownWarning(int seconds) {
    return 'Нажмите для подтверждения ($secondsс)';
  }

  @override
  String get holdToStaySafe => 'Удерживайте для безопасности';

  @override
  String get releaseDetected => 'Отпускание обнаружено';

  @override
  String get fakeCallIncoming => 'Входящий звонок...';

  @override
  String get fakeCallAnswer => 'Ответить';

  @override
  String get fakeCallDecline => 'Отклонить';

  @override
  String get emergencyContacts => 'Экстренные контакты';

  @override
  String get addContact => 'Добавить контакт';

  @override
  String get editContact => 'Редактировать контакт';

  @override
  String get contactName => 'Имя';

  @override
  String get contactPhone => 'Номер телефона';

  @override
  String get contactRelationship => 'Отношение';

  @override
  String get preferredChannel => 'Предпочитаемый канал';

  @override
  String get sms => 'SMS';

  @override
  String get whatsapp => 'WhatsApp';

  @override
  String get telegram => 'Telegram';

  @override
  String get phoneCall => 'Звонок';

  @override
  String get phoneCallDescription => 'Позвонить контакту напрямую';

  @override
  String get settings => 'Настройки';

  @override
  String get darkTheme => 'Тёмная тема';

  @override
  String get lightTheme => 'Светлая тема';

  @override
  String get language => 'Язык';

  @override
  String get escalationChain => 'Цепочка эскалации';

  @override
  String get reminderTemplates => 'Шаблоны напоминаний';

  @override
  String get modes => 'Режимы';

  @override
  String get walkMode => 'Режим прогулки';

  @override
  String get dateMode => 'Режим свидания';

  @override
  String get customMode => 'Пользовательский режим';

  @override
  String get createMode => 'Создать режим';

  @override
  String get editMode => 'Редактировать режим';

  @override
  String get checkInMechanism => 'Способ отметки';

  @override
  String get holdButton => 'Удержание кнопки';

  @override
  String get disguisedReminder => 'Замаскированное напоминание';

  @override
  String get checkInInterval => 'Интервал отметки';

  @override
  String get missedTolerance => 'Допустимые пропуски';

  @override
  String get fakeCallSettings => 'Настройки фейкового звонка';

  @override
  String get callerName => 'Имя звонящего';

  @override
  String get callerPhoto => 'Фото звонящего';

  @override
  String get voiceRecording => 'Голосовая запись';

  @override
  String get ringDuration => 'Длительность звонка';

  @override
  String get stepCountdownWarning => 'Предупреждение обратного отсчёта';

  @override
  String get stepDisguisedReminder => 'Замаскированное напоминание';

  @override
  String get stepFakeCall => 'Фейковый звонок';

  @override
  String get stepSmsContacts => 'SMS контактам';

  @override
  String get stepLoudAlarm => 'Громкая сирена';

  @override
  String get stepCallEmergency => 'Вызов экстренных служб';

  @override
  String get emergencyNumber => 'Номер экстренных служб';

  @override
  String get onboardingWelcome => 'Добро пожаловать в SafeWayHome';

  @override
  String get onboardingDescription =>
      'Ваш личный помощник безопасности. Добавьте экстренный контакт для начала.';

  @override
  String get onboardingSelectMode => 'Выберите режим по умолчанию';

  @override
  String get onboardingSelectModeDescription =>
      'Режим прогулки следит за вами по дороге домой. Режим свидания отправляет скрытые проверки на встречах.';

  @override
  String get onboardingAddContact => 'Добавьте экстренный контакт';

  @override
  String get onboardingAddContactDescription =>
      'Этот человек будет уведомлён, если вы не отметитесь.';

  @override
  String get onboardingPermissions => 'Предоставьте разрешения';

  @override
  String get onboardingPermissionsDescription =>
      'SafeWayHome нужен доступ к местоположению, телефону и SMS для вашей безопасности.';

  @override
  String get onboardingGetStarted => 'Начать';

  @override
  String get onboardingNext => 'Далее';

  @override
  String get onboardingSkip => 'Пропустить';

  @override
  String get onboardingBack => 'Назад';

  @override
  String get permissionLocation => 'Местоположение';

  @override
  String get permissionPhone => 'Телефон';

  @override
  String get permissionSms => 'SMS';

  @override
  String get permissionGranted => 'Разрешено';

  @override
  String get permissionDenied => 'Отказано';

  @override
  String get grantPermissions => 'Предоставить разрешения';

  @override
  String get permissionsNeeded => 'Необходимы разрешения';

  @override
  String get save => 'Сохранить';

  @override
  String get cancel => 'Отмена';

  @override
  String get delete => 'Удалить';

  @override
  String get enabled => 'Включено';

  @override
  String get disabled => 'Отключено';

  @override
  String seconds(int count) {
    return '$countс';
  }

  @override
  String minutes(int count) {
    return '$count мин';
  }

  @override
  String get sessionActive => 'Сеанс активен';

  @override
  String sessionElapsed(String time) {
    return 'Прошло: $time';
  }

  @override
  String smsMessage(String name, String locationUrl, String time) {
    return '$name возможно нуждается в помощи.\nПоследнее известное местоположение: $locationUrl\nВремя: $time';
  }

  @override
  String get noContactsYet => 'Экстренных контактов пока нет';

  @override
  String get deleteContactConfirmTitle => 'Удалить контакт';

  @override
  String deleteContactConfirmMessage(String name) {
    return 'Вы уверены, что хотите удалить $name?';
  }

  @override
  String get fieldRequired => 'Это поле обязательно';

  @override
  String get invalidPhoneNumber => 'Введите корректный номер телефона';

  @override
  String get contactSaved => 'Контакт сохранён';

  @override
  String get contactDeleted => 'Контакт удалён';

  @override
  String get slideToAnswer => 'Проведите для ответа';

  @override
  String get fakeCallActive => 'Вызов...';

  @override
  String get choosePhoto => 'Выбрать фото';

  @override
  String get removePhoto => 'Удалить';

  @override
  String get noFileSelected => 'Нет';

  @override
  String get templateCalendar => 'Событие календаря';

  @override
  String get templateDuolingo => 'Урок языка';

  @override
  String get templateDelivery => 'Обновление доставки';

  @override
  String get templateWeather => 'Прогноз погоды';

  @override
  String get templateFitness => 'Напоминание о фитнесе';

  @override
  String get templateMessage => 'Предпросмотр сообщения';

  @override
  String get templateAppUpdate => 'Обновление приложения';

  @override
  String get templateBattery => 'Предупреждение о батарее';

  @override
  String get emergencyNumberSetup => 'Номер экстренных служб';

  @override
  String get emergencyNumberDescription =>
      'Этот номер будет набран в крайнем случае, если вы не ответите';

  @override
  String get skipStep => 'Пропустить';

  @override
  String get skipStepWarning => 'Рекомендуем завершить этот шаг';

  @override
  String get createCustomMode => 'Создать свой';

  @override
  String get templateSubtitle => 'Подзаголовок';

  @override
  String get templateImage => 'Свое изображение';
}
