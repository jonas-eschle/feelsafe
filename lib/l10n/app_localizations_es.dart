// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'SafeWayHome';

  @override
  String get startSession => 'Iniciar sesión';

  @override
  String get endSession => 'Finalizar sesión';

  @override
  String get imSafe => 'Estoy bien';

  @override
  String get checkInPrompt => '¿Sigues bien?';

  @override
  String countdownWarning(int seconds) {
    return 'Toca para confirmar (${seconds}s)';
  }

  @override
  String get holdToStaySafe => 'Mantén pulsado para estar a salvo';

  @override
  String get releaseDetected => 'Se detectó que soltaste';

  @override
  String get fakeCallIncoming => 'Llamada entrante...';

  @override
  String get fakeCallAnswer => 'Contestar';

  @override
  String get fakeCallDecline => 'Rechazar';

  @override
  String get emergencyContacts => 'Contactos de emergencia';

  @override
  String get addContact => 'Añadir contacto';

  @override
  String get editContact => 'Editar contacto';

  @override
  String get contactName => 'Nombre';

  @override
  String get contactPhone => 'Número de teléfono';

  @override
  String get contactRelationship => 'Relación';

  @override
  String get preferredChannel => 'Canal preferido';

  @override
  String get sms => 'SMS';

  @override
  String get whatsapp => 'WhatsApp';

  @override
  String get telegram => 'Telegram';

  @override
  String get phoneCall => 'Llamada telefónica';

  @override
  String get phoneCallDescription => 'Llamar directamente a tu contacto';

  @override
  String get settings => 'Ajustes';

  @override
  String get darkTheme => 'Tema oscuro';

  @override
  String get lightTheme => 'Tema claro';

  @override
  String get language => 'Idioma';

  @override
  String get escalationChain => 'Cadena de escalamiento';

  @override
  String get reminderTemplates => 'Plantillas de recordatorio';

  @override
  String get modes => 'Modos';

  @override
  String get walkMode => 'Modo caminar';

  @override
  String get dateMode => 'Modo cita';

  @override
  String get customMode => 'Modo personalizado';

  @override
  String get createMode => 'Crear modo';

  @override
  String get editMode => 'Editar modo';

  @override
  String get checkInMechanism => 'Método de check-in';

  @override
  String get holdButton => 'Mantener botón';

  @override
  String get disguisedReminder => 'Recordatorio disfrazado';

  @override
  String get checkInInterval => 'Intervalo de check-in';

  @override
  String get missedTolerance => 'Tolerancia de check-ins perdidos';

  @override
  String get fakeCallSettings => 'Ajustes de llamada falsa';

  @override
  String get callerName => 'Nombre del contacto';

  @override
  String get callerPhoto => 'Foto del contacto';

  @override
  String get voiceRecording => 'Grabación de voz';

  @override
  String get ringDuration => 'Duración del timbre';

  @override
  String get stepCountdownWarning => 'Cuenta regresiva';

  @override
  String get stepDisguisedReminder => 'Recordatorio disfrazado';

  @override
  String get stepFakeCall => 'Llamada falsa';

  @override
  String get stepSmsContacts => 'SMS a contactos';

  @override
  String get stepLoudAlarm => 'Alarma fuerte';

  @override
  String get stepCallEmergency => 'Llamar a emergencias';

  @override
  String get emergencyNumber => 'Número de emergencia';

  @override
  String get onboardingWelcome => 'Bienvenida a SafeWayHome';

  @override
  String get onboardingDescription =>
      'Tu compañero de seguridad personal. Añade un contacto de emergencia para empezar.';

  @override
  String get onboardingSelectMode => 'Elige tu modo por defecto';

  @override
  String get onboardingSelectModeDescription =>
      'El modo caminar te vigila de camino a casa. El modo cita envía check-ins discretos durante tus salidas.';

  @override
  String get onboardingAddContact => 'Añade un contacto de emergencia';

  @override
  String get onboardingAddContactDescription =>
      'Esta persona será avisada si no respondes.';

  @override
  String get onboardingPermissions => 'Concede los permisos';

  @override
  String get onboardingPermissionsDescription =>
      'SafeWayHome necesita acceder a tu ubicación, teléfono y SMS para mantenerte a salvo.';

  @override
  String get onboardingGetStarted => 'Empezar';

  @override
  String get onboardingNext => 'Siguiente';

  @override
  String get onboardingSkip => 'Omitir';

  @override
  String get onboardingBack => 'Atrás';

  @override
  String get permissionLocation => 'Ubicación';

  @override
  String get permissionPhone => 'Teléfono';

  @override
  String get permissionSms => 'SMS';

  @override
  String get permissionGranted => 'Concedido';

  @override
  String get permissionDenied => 'Denegado';

  @override
  String get grantPermissions => 'Conceder permisos';

  @override
  String get permissionsNeeded => 'Se necesitan permisos';

  @override
  String get save => 'Guardar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Eliminar';

  @override
  String get enabled => 'Activado';

  @override
  String get disabled => 'Desactivado';

  @override
  String seconds(int count) {
    return '${count}s';
  }

  @override
  String minutes(int count) {
    return '$count min';
  }

  @override
  String get sessionActive => 'Sesión activa';

  @override
  String sessionElapsed(String time) {
    return 'Transcurrido: $time';
  }

  @override
  String smsMessage(String name, String locationUrl, String time) {
    return '$name podría necesitar ayuda.\nÚltima ubicación conocida: $locationUrl\nHora: $time';
  }

  @override
  String get noContactsYet => 'Aún no hay contactos de emergencia';

  @override
  String get deleteContactConfirmTitle => 'Eliminar contacto';

  @override
  String deleteContactConfirmMessage(String name) {
    return '¿Segura que quieres eliminar a $name?';
  }

  @override
  String get fieldRequired => 'Este campo es obligatorio';

  @override
  String get invalidPhoneNumber => 'Introduce un número de teléfono válido';

  @override
  String get contactSaved => 'Contacto guardado';

  @override
  String get contactDeleted => 'Contacto eliminado';

  @override
  String get slideToAnswer => 'Desliza para contestar';

  @override
  String get fakeCallActive => 'Llamando...';

  @override
  String get choosePhoto => 'Elegir foto';

  @override
  String get removePhoto => 'Eliminar';

  @override
  String get noFileSelected => 'Ninguno';

  @override
  String get templateCalendar => 'Evento del calendario';

  @override
  String get templateDuolingo => 'Lección de idiomas';

  @override
  String get templateDelivery => 'Actualización de envío';

  @override
  String get templateWeather => 'Alerta meteorológica';

  @override
  String get templateFitness => 'Recordatorio de ejercicio';

  @override
  String get templateMessage => 'Vista previa del mensaje';

  @override
  String get templateAppUpdate => 'Actualización de la app';

  @override
  String get templateBattery => 'Alerta de batería';

  @override
  String get emergencyNumberSetup => 'Número de emergencia';

  @override
  String get emergencyNumberDescription =>
      'Este número se llamará como último recurso si no respondes';

  @override
  String get skipStep => 'Omitir';

  @override
  String get skipStepWarning => 'Te recomendamos completar este paso';

  @override
  String get createCustomMode => 'Crear modo personalizado';

  @override
  String get templateSubtitle => 'Subtítulo';

  @override
  String get templateImage => 'Imagen personalizada';
}
