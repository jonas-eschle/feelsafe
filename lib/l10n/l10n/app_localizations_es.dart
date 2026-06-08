// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Guardian Angela';

  @override
  String get commonSave => 'Guardar';

  @override
  String get angelaDialogTitle => 'PIN antiguo introducido';

  @override
  String get angelaDialogBody =>
      'Parece que ha utilizado un PIN antiguo. ¿Seguro que desea continuar?';

  @override
  String get angelaDialogCancel => 'Cancelar';

  @override
  String get angelaDialogConfirm => 'Continuar';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonOk => 'Aceptar';

  @override
  String get commonDelete => 'Eliminar';

  @override
  String get commonEdit => 'Editar';

  @override
  String get commonGotIt => 'Entendido';

  @override
  String get commonClose => 'Cerrar';

  @override
  String get commonConfirm => 'Confirmar';

  @override
  String get commonBack => 'Atrás';

  @override
  String get pinSubmit => 'Enviar';

  @override
  String get homeTitle => 'Guardian Angela';

  @override
  String get homeStartSession => 'Iniciar sesión';

  @override
  String get homePermissionsNotification => 'Notificaciones';

  @override
  String get homePermissionsLocation => 'Ubicación';

  @override
  String get homePermissionsCallPhone => 'Llamadas telefónicas';

  @override
  String get homePermissionsSendSms => 'Enviar SMS';

  @override
  String get homeSimulate => 'Simular';

  @override
  String get homeNoModes => 'Aún no hay modos. Toca Modos para agregar uno.';

  @override
  String get homeContactsBannerNone =>
      'No hay contactos de emergencia configurados.';

  @override
  String get homeMenuSettings => 'Ajustes';

  @override
  String get homeMenuContacts => 'Contactos';

  @override
  String get homeMenuHistory => 'Sesiones anteriores';

  @override
  String get onboardingProfileTitle => 'Perfil y primer contacto';

  @override
  String get onboardingPermissionsTitle => 'Permisos';

  @override
  String get onboardingNext => 'Siguiente';

  @override
  String get onboardingSkip => 'Omitir';

  @override
  String get onboardingUseSimNumber => 'Usar el número de mi SIM';

  @override
  String onboardingUseSimNumberHint(Object number) {
    return '$number';
  }

  @override
  String get onboardingUseSimNumberUnsupported => 'No disponible en iOS';

  @override
  String get onboardingUseSimNumberUnavailable => 'No se pudo leer el número';

  @override
  String get onboardingUseSimNumberPermissionDenied => 'Permiso denegado';

  @override
  String get sessionTitle => 'Sesión';

  @override
  String get sessionDisarm => 'Estoy a salvo';

  @override
  String get sessionDisarmStealth => 'No hace falta Angela';

  @override
  String get homeChainSummaryTitle => 'Resumen de la cadena';

  @override
  String get homeChainSummaryEmpty =>
      'Este modo aún no tiene pasos: toca el modo para editarlo.';

  @override
  String homeChainSummaryTimingTitle(Object name) {
    return 'Paso: $name';
  }

  @override
  String homeChainSummaryWait(Object seconds) {
    return 'Espera: $seconds s';
  }

  @override
  String homeChainSummaryDuration(Object seconds) {
    return 'Activo: $seconds s';
  }

  @override
  String homeChainSummaryGrace(Object seconds) {
    return 'Periodo de gracia: $seconds s';
  }

  @override
  String homeChainSummaryRetry(Object count) {
    return 'Reintentos: $count';
  }

  @override
  String homeChainSummaryNextStep(Object name) {
    return 'Siguiente paso: $name';
  }

  @override
  String get homeChainSummaryNextStepNone => 'Siguiente paso: fin de la cadena';

  @override
  String get homeChainSummaryClose => 'Cerrar';

  @override
  String get chainStepNameHoldButton => 'Mantén para seguir a salvo';

  @override
  String get chainStepNameDisguisedReminder => 'Recordatorio camuflado';

  @override
  String get chainStepNameCountdownWarning => 'Aviso con cuenta atrás';

  @override
  String get chainStepNameFakeCall => 'Llamada falsa';

  @override
  String get chainStepNameSmsContact => 'SMS a contacto';

  @override
  String get chainStepNamePhoneCallContact => 'Llamada a contacto';

  @override
  String get chainStepNameLoudAlarm => 'Alarma sonora';

  @override
  String get chainStepNameCallEmergency => 'Llamada de emergencia';

  @override
  String get chainStepNameHardwareButton => 'Botón físico';

  @override
  String get homeChecklistTitle => 'Configuración de seguridad';

  @override
  String get homeChecklistDismissTooltip => 'Ocultar lista';

  @override
  String get homeChecklistExpandTooltip => 'Mostrar lista';

  @override
  String get homeChecklistCollapseTooltip => 'Contraer lista';

  @override
  String homeChecklistProgress(Object done, Object total) {
    return '$done de $total listos';
  }

  @override
  String get homeChecklistAllDoneBanner => 'Todo listo: ¡estás protegida!';

  @override
  String get homeChecklistInfoTooltip => 'Por qué importa';

  @override
  String get homeChecklistGotIt => 'Entendido';

  @override
  String get homeChecklistGoThere => 'Ir ahí';

  @override
  String get homeChecklistItem1Title => 'Añade un contacto de emergencia';

  @override
  String get homeChecklistItem2Title => 'Define un PIN de fin de sesión';

  @override
  String get homeChecklistItem3Title => 'Configura el modo sigiloso';

  @override
  String get homeChecklistItem4Title => 'Prueba una simulación';

  @override
  String get homeChecklistItem5Title => 'Personaliza un modo de seguridad';

  @override
  String get homeChecklistItem6Title => 'Concede los permisos necesarios';

  @override
  String get checklistInfo1Body =>
      'Los contactos de emergencia son las personas a las que Guardian Angela envía mensajes y llama cuando no consigues confirmar. Sin al menos un contacto, la cadena no tiene a quién escalar.';

  @override
  String get checklistInfo2Body =>
      'El PIN de fin de sesión impide que un atacante cierre en silencio una sesión activa. Puede intentarlo, pero cinco intentos fallidos disparan tu cadena de emergencia sin avisar.';

  @override
  String get checklistInfo3Body =>
      'El modo sigiloso disfraza la sesión activa de algo inocuo en pantalla: un reproductor de música, un temporizador en pausa, una pantalla de bloqueo en blanco. Úsalo cuando alguien cerca no puede verte usar una app de seguridad.';

  @override
  String get checklistInfo4Body =>
      'La simulación ejecuta tu modo de seguridad de principio a fin sin enviar SMS reales, realizar llamadas reales ni hacer sonar la alarma. Úsala para aprender los tiempos antes de necesitarlos.';

  @override
  String get checklistInfo5Body =>
      'Los modos personalizados te dejan ajustar pasos, tiempos y desencadenantes a una situación concreta: volver a casa, una primera cita, un turno de noche. Los dos modos preinstalados son puntos de partida, no la meta.';

  @override
  String get checklistInfo6Body =>
      'Sin permiso de notificaciones, Guardian Angela no puede mantener su estado persistente en primer plano, enviar recordatorios camuflados ni avisarte de que la cadena va a escalar.';

  @override
  String get checklistTutorial3Body =>
      'Abre los valores predeterminados de sigilo y activa «Habilitar modo sigiloso». Desde ahí puedes elegir una marca de música falsa, ocultar el temporizador de la sesión o disfrazar el icono de inicio.';

  @override
  String get checklistTutorial4Body =>
      'Toca el botón «Simular» con contorno en la pantalla de inicio tras elegir un modo. La sesión corre con borde naranja y la insignia [SIM]: nada sale de tu teléfono.';

  @override
  String get checklistTutorial5Body =>
      'Abre la pantalla de Modos y edita un modo preinstalado (Paseo/Cita) o crea uno nuevo desde cero. Ajusta la cadena, añade una llamada falsa, define tiempos personalizados.';

  @override
  String get sessionHoldPrompt => 'Mantén pulsado para seguir a salvo';

  @override
  String sessionStepLabel(Object index, Object total) {
    return 'Paso $index de $total';
  }

  @override
  String sessionMissCount(Object count) {
    return 'Omitidos: $count';
  }

  @override
  String get sessionPausedBadge => 'En pausa';

  @override
  String get sessionPausedIncomingCall => 'En pausa: llamada entrante';

  @override
  String get sessionPhaseEnded => 'Sesión finalizada';

  @override
  String get sessionSimulationBanner => 'Simulación';

  @override
  String get sessionCheckIn => 'Estoy a salvo';

  @override
  String get sessionStepCountdownTitle => 'Aviso';

  @override
  String get sessionStepCountdownBody =>
      'La próxima escalada se activará cuando termine la cuenta regresiva. Deslice «Estoy a salvo» abajo para desactivar.';

  @override
  String get sessionStepDisguisedDefaultTitle => 'Recordatorio';

  @override
  String get sessionStepDisguisedDefaultBody =>
      'Toque «Estoy a salvo» para confirmar que está bien.';

  @override
  String get sessionReminderEarlyCheckInHint => 'Toca para registrarte ahora';

  @override
  String get sessionReminderDefaultButton => 'OK';

  @override
  String get sessionReminderTapWordHint => 'Toca para continuar';

  @override
  String get sessionReminderSwipeLabel => 'Desliza para cerrar';

  @override
  String get sessionReminderDismissLabel => 'Cerrar';

  @override
  String get sessionStepSmsStatus => 'Enviando mensaje a contactos…';

  @override
  String get sessionStepPhoneCallStatus =>
      'Llamando al contacto de emergencia…';

  @override
  String get sessionStepLoudAlarmTitle => 'Alarma sonando';

  @override
  String get sessionStepLoudAlarmBody =>
      'La alarma está sonando para llamar la atención.';

  @override
  String get sessionStepLoudAlarmFlashWarning =>
      'Aviso para personas fotosensibles: la pantalla está parpadeando.';

  @override
  String get sessionStepCallEmergencyStatus =>
      'Llamando a los servicios de emergencia…';

  @override
  String sessionStepCallEmergencyNumber(Object number) {
    return 'Número: $number';
  }

  @override
  String sessionStepHardwareButtonRepeat(
    Object button,
    Object count,
    Object windowMs,
  ) {
    return 'Pulse $button $count veces en $windowMs ms';
  }

  @override
  String sessionStepHardwareButtonLong(Object button, Object seconds) {
    return 'Mantenga pulsado $button durante $seconds segundos';
  }

  @override
  String get sessionStepHardwareButtonVolumeUp => 'subir volumen';

  @override
  String get sessionStepHardwareButtonVolumeDown => 'bajar volumen';

  @override
  String get sessionStepHardwareButtonPower => 'encendido';

  @override
  String get sessionCompletedTitle => 'Sesión completada';

  @override
  String get sessionCompletedBody =>
      'Has llegado a salvo. Guardian Angela se desactiva.';

  @override
  String get sessionCompletedReturnHome => 'Volver al inicio';

  @override
  String get sessionStealthNowPlaying => 'Reproduciendo ahora';

  @override
  String get sessionServiceTitle => 'Guardian Angela está activo';

  @override
  String get sessionServiceBody => 'Tu sesión de seguridad está en curso.';

  @override
  String get sessionServiceStealthBody => 'Reproduciendo';

  @override
  String get sessionStealthTrackTitle => 'Pista sin título';

  @override
  String get sessionStealthArtistName => 'Artista desconocido';

  @override
  String get sessionStealthAlbumArtLabel => 'Carátula del álbum';

  @override
  String get sessionStealthPlay => 'Reproducir';

  @override
  String get sessionStealthPause => 'Pausar';

  @override
  String get simulationSummaryTitle => 'Resumen de la simulación';

  @override
  String get simulationSummaryEmpty =>
      'No se activó ningún paso durante esta simulación.';

  @override
  String get simulationSummaryReturn => 'Volver al inicio';

  @override
  String get fakeCallTitle => 'Llamada entrante';

  @override
  String get fakeCallHangUp => 'Colgar';

  @override
  String get fakeCallSlideToAnswer => 'deslice para contestar';

  @override
  String get fakeCallUnknownCaller => 'Desconocido';

  @override
  String get fakeCallIncomingWhatsapp => 'Llamada de voz de WhatsApp';

  @override
  String get fakeCallIncomingTelegram => 'Llamada de voz de Telegram';

  @override
  String get fakeCallIncomingSignal => 'Llamada de voz de Signal';

  @override
  String get fakeCallBrandWhatsapp => 'WHATSAPP';

  @override
  String get fakeCallBrandTelegram => 'TELEGRAM';

  @override
  String get fakeCallBrandSignal => 'SIGNAL';

  @override
  String get fakeCallBrandAndroid => 'TELÉFONO';

  @override
  String get fakeCallBrandIos => 'TELÉFONO';

  @override
  String get fakeCallBrandMinimal => 'LLAMADA';

  @override
  String get fakeCallDeclineSafeLabel => 'Rechazar (Estoy a salvo)';

  @override
  String get fakeCallDeclineUnsafeLabel => 'Rechazar (Seguir en alerta)';

  @override
  String get fakeCallHoldForDistress => 'Mantén pulsado 5 s para auxilio';

  @override
  String fakeCallVoicePrompt(String name) {
    return 'Mensaje de voz: $name';
  }

  @override
  String fakeCallVibrationLabel(String pattern) {
    return 'Vibración: $pattern';
  }

  @override
  String get fakeCallVibrationPatternDefault => 'predeterminada';

  @override
  String get fakeCallSlideToAnswerHint => 'Desliza para contestar';

  @override
  String fakeCallActiveDuration(String mm, String ss) {
    return '$mm:$ss';
  }

  @override
  String get contactsTitle => 'Contactos de emergencia';

  @override
  String get contactsEmpty =>
      'Aún no hay contactos. Añade uno para recibir tus mensajes de auxilio.';

  @override
  String get contactsAdd => 'Añadir contacto';

  @override
  String get contactFormTitleCreate => 'Nuevo contacto';

  @override
  String get contactFormTitleEdit => 'Editar contacto';

  @override
  String get contactFieldName => 'Nombre';

  @override
  String get contactFieldPhone => 'Número de teléfono';

  @override
  String get contactFieldRelationship => 'Relación (opcional)';

  @override
  String get contactFieldLanguage => 'Idioma del SMS (opcional)';

  @override
  String get contactLanguageDefault => 'Predeterminado (usar idioma de la app)';

  @override
  String get contactChannelsHeader => 'Canales de mensajería';

  @override
  String get contactChannelSms => 'SMS';

  @override
  String get contactChannelWhatsapp => 'WhatsApp';

  @override
  String get contactChannelTelegram => 'Telegram';

  @override
  String get contactChannelPhone => 'Llamada telefónica';

  @override
  String get contactDeleteConfirm => '¿Eliminar contacto?';

  @override
  String contactDeleteBody(Object name) {
    return '$name será eliminado de tu lista de emergencia.';
  }

  @override
  String get contactFormIosSmsWarning =>
      'En iOS, el SMS abre la app Mensajes. Debes tocar Enviar manualmente.';

  @override
  String get modesTitle => 'Modos';

  @override
  String get modesEmpty => 'Aún no hay modos. Toca Añadir para crear un modo.';

  @override
  String get modesAdd => 'Añadir modo';

  @override
  String get modesNewPickerBlank => 'Modo vacío';

  @override
  String get modesNewPickerBlankSubtitle => 'Empezar con una cadena vacía';

  @override
  String modesNewPickerFromTemplate(String name) {
    return 'Desde $name';
  }

  @override
  String get modesNewPickerFromTemplateSubtitle =>
      'Copiar la cadena y los disparadores de este modo';

  @override
  String get modeEditorTitleCreate => 'Nuevo modo';

  @override
  String get modeEditorTitleEdit => 'Editar modo';

  @override
  String get modeFieldName => 'Nombre';

  @override
  String get modeChainHeader => 'Cadena';

  @override
  String get modeChainAddStep => 'Añadir paso';

  @override
  String get modeUnsavedTitle => '¿Descartar cambios?';

  @override
  String get modeUnsavedBody =>
      'Tienes cambios sin guardar. ¿Descartarlos y salir del editor?';

  @override
  String get modeUnsavedDiscard => 'Descartar';

  @override
  String get modeUnsavedKeep => 'Seguir editando';

  @override
  String stepTimingSummary(Object wait, Object duration, Object grace) {
    return 'espera ${wait}s / duración ${duration}s / gracia ${grace}s';
  }

  @override
  String get stepConfigTimingHeader => 'Temporización';

  @override
  String get stepConfigEventHeader => 'Configuración del evento';

  @override
  String get stepConfigAdvancedHeader => 'Reintentos y avanzado';

  @override
  String get stepFieldWait => 'Espera antes de activarse (segundos)';

  @override
  String get stepFieldDuration => 'Duración activa (segundos)';

  @override
  String get stepFieldGrace => 'Periodo de gracia (segundos)';

  @override
  String get stepFieldRetryCount => 'Reintentos';

  @override
  String get stepFieldRandomize => 'Aleatorizar tiempos (±20%)';

  @override
  String get stepDuplicate => 'Duplicar paso';

  @override
  String get stepResetDefaults => 'Restablecer valores predeterminados';

  @override
  String get smsContactRecipientsHeader => 'Contactos a los que avisar';

  @override
  String get smsContactSummaryAll => 'Para: todos los contactos habilitados';

  @override
  String get smsContactSummaryNone => 'No se han seleccionado destinatarios';

  @override
  String smsContactSummaryTo(Object names) {
    return 'Para: $names';
  }

  @override
  String get smsContactChannelDisabledTooltip =>
      'No habilitado para este contacto: edita el contacto para añadir este canal.';

  @override
  String get smsContactEmptyAddPrompt =>
      'Aún no hay contactos: añade uno en Contactos';

  @override
  String get safetyOptionsHeader => 'Opciones de seguridad';

  @override
  String get safetyOptionsDistressModeTitle => 'Modo de emergencia';

  @override
  String get safetyOptionsDistressModeUseDefault =>
      'Usar el modo de emergencia predeterminado';

  @override
  String safetyOptionsDistressModeUseDefaultNamed(Object name) {
    return 'Usar el predeterminado ($name)';
  }

  @override
  String get safetyOptionsDistressModeInfo =>
      'Cuando se activa un disparador de emergencia (PIN de coacción, pánico por hardware o demasiados PIN incorrectos), la cadena de este modo se sustituye por la del modo de emergencia elegido. Déjalo en el predeterminado para usar el modo de emergencia general de la app.';

  @override
  String get safetyOptionsManageDistressModes =>
      'Gestionar modos de emergencia';

  @override
  String get safetyOptionsDistressTriggersTitle => 'Disparadores de emergencia';

  @override
  String get safetyOptionsDistressTriggersInfo =>
      'Los disparadores de emergencia activan la cadena de emergencia de inmediato, en paralelo con la cadena principal. El botón de pánico por hardware vigila un botón físico según el patrón de pulsación configurado.';

  @override
  String get safetyOptionsDistressTriggersEmpty =>
      'Sin disparadores de emergencia';

  @override
  String get safetyOptionsAddHardwarePanic =>
      'Añadir botón de pánico por hardware';

  @override
  String safetyOptionsTriggerHardwareRepeat(Object button, Object count) {
    return '$button: $count× pulsación';
  }

  @override
  String safetyOptionsTriggerHardwareLong(Object button, Object seconds) {
    return '$button: mantener ${seconds}s';
  }

  @override
  String get safetyOptionsButtonVolumeUp => 'Subir volumen';

  @override
  String get safetyOptionsButtonVolumeDown => 'Bajar volumen';

  @override
  String get safetyOptionsTriggerPattern => 'Patrón de pulsación';

  @override
  String get safetyOptionsPatternRepeat => 'Pulsación repetida';

  @override
  String get safetyOptionsPatternLong => 'Pulsación larga';

  @override
  String get safetyOptionsTriggerButton => 'Botón';

  @override
  String get safetyOptionsTriggerPressCount => 'Número de pulsaciones';

  @override
  String get safetyOptionsTriggerHoldDuration =>
      'Duración de la pulsación (segundos)';

  @override
  String get safetyOptionsDisarmTriggersTitle =>
      'Disparadores de desactivación';

  @override
  String get safetyOptionsGpsArrivalTitle => 'Desactivación al llegar por GPS';

  @override
  String get safetyOptionsGpsArrivalInfo =>
      'La sesión termina automáticamente cuando llegas dentro del radio configurado de tu destino. El destino se establece al iniciar una sesión.';

  @override
  String get safetyOptionsGpsArrivalRadius => 'Radio de llegada';

  @override
  String safetyOptionsRadiusMeters(Object meters) {
    return '$meters m';
  }

  @override
  String safetyOptionsRadiusKilometers(Object km) {
    return '$km km';
  }

  @override
  String get safetyOptionsDestinationSource => 'Destino';

  @override
  String get safetyOptionsDestinationPrompt =>
      'Establecer el destino al iniciar la sesión';

  @override
  String get safetyOptionsDestinationFixed => 'Coordenadas fijas';

  @override
  String get safetyOptionsLatitude => 'Latitud';

  @override
  String get safetyOptionsLongitude => 'Longitud';

  @override
  String get safetyOptionsTimerDisarmTitle => 'Desactivación por temporizador';

  @override
  String get safetyOptionsTimerDisarmInfo =>
      'La sesión termina automáticamente después del tiempo configurado, independientemente de si ha comenzado la escalada.';

  @override
  String get safetyOptionsTimerDuration => 'Duración';

  @override
  String safetyOptionsDurationMinutes(Object minutes) {
    return '$minutes min';
  }

  @override
  String safetyOptionsDurationHoursMinutes(Object hours, Object minutes) {
    return '$hours h $minutes min';
  }

  @override
  String get safetyOptionsGpsLoggingTitle => 'Registro de GPS';

  @override
  String get safetyOptionsGpsLoggingInfo =>
      'Elige si este modo registra tu ubicación durante una sesión. «Heredar» usa tu configuración global de GPS; «Personalizado» la anula para este modo; «Desactivado» desactiva el registro por completo.';

  @override
  String get safetyOptionsStealthTitle => 'Modo sigiloso';

  @override
  String get safetyOptionsStealthInfo =>
      'Elige si este modo disfraza la app durante una sesión. «Heredar» usa tu configuración global de sigilo; «Personalizado» la anula para este modo; «Desactivado» desactiva el sigilo por completo.';

  @override
  String get safetyOptionsTriStateInherit => 'Heredar';

  @override
  String get safetyOptionsTriStateCustom => 'Personalizado';

  @override
  String get safetyOptionsTriStateOff => 'Desactivado';

  @override
  String get safetyOptionsLocalTemplatesTitle => 'Plantillas locales';

  @override
  String get safetyOptionsLocalTemplatesInfo =>
      'Las plantillas locales se añaden al conjunto global de plantillas de recordatorio solo para este modo. Úsalas para pasos de recordatorio disfrazado específicos de este modo.';

  @override
  String get safetyOptionsLocalTemplatesEmpty => 'Sin plantillas locales';

  @override
  String get safetyOptionsAddTemplate => 'Añadir plantilla';

  @override
  String get safetyOptionsManageTemplates =>
      'Gestionar plantillas de recordatorio';

  @override
  String get safetyOptionsEventDefaultsTitle =>
      'Valores predeterminados de eventos';

  @override
  String get safetyOptionsEventDefaultsInfo =>
      'Los valores predeterminados de eventos definen la configuración inicial de cada tipo de paso. «Heredar» usa tus valores globales; «Personalizado» los anula para los pasos de este modo que no tengan configuración propia.';

  @override
  String get safetyOptionsEventDefaultsTwoStateInherit => 'Heredar';

  @override
  String get safetyOptionsAllowDisarmAsDistressTitle =>
      'Permitir desactivar mientras está activo como emergencia';

  @override
  String get safetyOptionsAllowDisarmAsDistressInfo =>
      'Al activarlo, puedes detener la alerta llegando a un lugar seguro o dejando que expire un temporizador. Al desactivarlo, solo se detiene al completar la cadena o cerrar la app: más resistente a la coacción.';

  @override
  String get distressModesEmpty => 'Aún no hay modos de auxilio.';

  @override
  String get distressModeEditorTitleCreate => 'Nuevo modo de auxilio';

  @override
  String get distressModeEditorTitleEdit => 'Editar modo de auxilio';

  @override
  String get templatesTitle => 'Plantillas de recordatorio';

  @override
  String get templatesEmpty => 'Aún no hay plantillas.';

  @override
  String get profileTitle => 'Perfil';

  @override
  String get profileFieldName => 'Nombre';

  @override
  String get profileFieldAge => 'Edad';

  @override
  String get profileFieldBloodType => 'Grupo sanguíneo';

  @override
  String get profileFieldAllergies => 'Alergias';

  @override
  String get profileFieldMedications => 'Medicamentos';

  @override
  String get settingsThemeLight => 'Claro';

  @override
  String get settingsThemeDark => 'Oscuro';

  @override
  String get settingsThemeSystem => 'Sistema';

  @override
  String get settingsEmergencyNumberLabel => 'Número de emergencia';

  @override
  String get settingsRedoOnboardingActiveSessionTooltip =>
      'No se puede repetir la introducción durante una sesión activa';

  @override
  String get settingsEmergencyNumberCountryPickerTitle =>
      'Elegir número de emergencia';

  @override
  String get settingsRedoOnboarding => 'Repetir introducción';

  @override
  String get settingsRedoOnboardingConfirm => '¿Reiniciar introducción?';

  @override
  String get securitySessionEndPinBiometric =>
      'Usar biometría para el PIN de fin de sesión';

  @override
  String get securityAppPinBiometric =>
      'Usar biometría para el bloqueo de la app';

  @override
  String get launchPinTitle => 'Introduce tu PIN de la app';

  @override
  String get launchPinBiometricReason => 'Desbloquear Guardian Angela';

  @override
  String get launchPinIncorrect => 'PIN incorrecto';

  @override
  String get securitySetPin => 'Establecer PIN';

  @override
  String get securityChangePin => 'Cambiar PIN';

  @override
  String get pinSetupMismatch => 'Los PIN no coinciden. Inténtalo de nuevo.';

  @override
  String get stealthTimerDisplayNormal => 'Mostrar texto completo';

  @override
  String get stealthTimerDisplaySmall => 'Mostrar solo números';

  @override
  String get stealthTimerDisplayNone => 'Ocultar temporizador';

  @override
  String get stealthPresetMusic => 'Música';

  @override
  String get stealthPresetCalendar => 'Calendario';

  @override
  String get stealthPresetFitness => 'Fitness';

  @override
  String get stealthPresetWeather => 'Tiempo';

  @override
  String get stealthPresetNews => 'Noticias';

  @override
  String get stealthPresetPhotos => 'Fotos';

  @override
  String get stealthPresetNotes => 'Notas';

  @override
  String get stealthPresetClock => 'Reloj';

  @override
  String get eventDefaultsTitle => 'Valores predeterminados de pasos';

  @override
  String get historyRetentionTitle => 'Retención del historial';

  @override
  String get backupTitle => 'Copia de seguridad';

  @override
  String get aboutTitle => 'Acerca de';

  @override
  String aboutVersion(Object version) {
    return 'Versión';
  }

  @override
  String get feedbackTitle => 'Comentarios';

  @override
  String get feedbackSend => 'Abrir correo';

  @override
  String get stealthPresetPodcast => 'Pódcast';

  @override
  String get stealthPresetNone => 'Ninguno';

  @override
  String get stealthLockTaskLabel => 'Fijar la app durante la sesión';

  @override
  String get stealthLockTaskSubtitle =>
      'Impide salir de la app mientras hay una sesión activa. En Android activa el anclaje de pantalla; en otras plataformas no tiene efecto.';

  @override
  String get stealthLockTaskInfo =>
      'Fija Guardian Angela en la pantalla durante toda la sesión para que no se pueda deslizar para cerrarla ni cambiar de app. Contrapartida: Android muestra un aviso del sistema \"La app está fijada\" y bloquea el cambio de app hasta que termina la sesión, visible para cualquiera que mire la pantalla. Déjalo desactivado si prefieres moverte libremente entre apps durante una sesión. Sin efecto en plataformas sin anclaje de pantalla.';

  @override
  String get homeTagline => 'Tu ángel te cuida las espaldas.';

  @override
  String get onboardingWelcomeGreeting => 'Hola, soy Angela';

  @override
  String get onboardingWelcomeBodyFull =>
      'Soy tu guardiana personal. Te acompaño, vigilo tu salida nocturna y actúo si algo va mal.';

  @override
  String get onboardingGetStarted => 'Empezar';

  @override
  String get onboardingProfileNameLabel => 'Nombre';

  @override
  String get onboardingProfilePhoneLabel => 'Número de teléfono';

  @override
  String get onboardingProfilePhoneHelper =>
      'Se incluye en los mensajes de emergencia.';

  @override
  String get onboardingEmergencyContactHeader => 'Contacto de emergencia';

  @override
  String get onboardingEmergencyContactPrompt =>
      '¿A quién debemos avisar si algo va mal?';

  @override
  String get onboardingEmergencyContactAdd => 'Añadir contacto de emergencia';

  @override
  String get onboardingPermissionsIntro =>
      'Estos permisos te mantienen a salvo durante las sesiones.';

  @override
  String get onboardingPermissionsGrantAll => 'Conceder todo';

  @override
  String get onboardingPermissionsRequired => 'OBLIGATORIO';

  @override
  String get onboardingPermissionsOptional => 'OPCIONAL';

  @override
  String get onboardingPermissionsMicrophone => 'Micrófono';

  @override
  String get onboardingPermissionsCamera => 'Cámara';

  @override
  String get onboardingPermissionsNotificationDesc =>
      'Necesario para las alertas y los recordatorios de la sesión.';

  @override
  String get onboardingPermissionsSmsDesc =>
      'Necesario para enviar alertas de emergencia por SMS.';

  @override
  String get onboardingPermissionsPhoneDesc =>
      'Necesario para hacer llamadas de emergencia y llamadas falsas.';

  @override
  String get onboardingPermissionsLocationDesc =>
      'Se incluye en los mensajes de emergencia cuando el registro de GPS está activado.';

  @override
  String get onboardingPermissionsMicrophoneDesc =>
      'Se usa para grabar audio durante una situación de auxilio.';

  @override
  String get onboardingPermissionsCameraDesc =>
      'Se usa para las señales SOS con el flash.';

  @override
  String get sessionInterruptedTitle => 'Sesión interrumpida';

  @override
  String get sessionInterruptedBody =>
      'Había una sesión en curso cuando la app se detuvo. El estado de la sesión se ha perdido: no se ha restaurado nada. Te lo mostramos para que lo sepas.';

  @override
  String get sessionInterruptedAcknowledge => 'Entendido';

  @override
  String sessionInterruptedMode(Object name) {
    return 'Modo: $name';
  }

  @override
  String sessionInterruptedStarted(Object time) {
    return 'Iniciada: $time';
  }

  @override
  String get sessionGpsDestinationTitle => 'Destino';

  @override
  String get sessionGpsDestinationBody =>
      'Introduce las coordenadas de destino para el desencadenante de desactivación por llegada GPS.';

  @override
  String get sessionGpsDestinationLat => 'Latitud';

  @override
  String get sessionGpsDestinationLng => 'Longitud';

  @override
  String get sessionGpsDestinationSkip => 'Omitir en esta sesión';

  @override
  String get sessionGpsDestinationConfirm => 'Usar destino';

  @override
  String get sessionEndOverlayTitle => '¿Finalizar la sesión?';

  @override
  String get sessionEndOverlayBody =>
      'Desliza para confirmar que quieres finalizar la sesión';

  @override
  String get sessionEndOverlaySwipeLabel => 'Desliza para finalizar';

  @override
  String get sessionEndOverlaySimBadge => '[SIM] Modo de práctica';

  @override
  String get sessionEndPinPromptTitle => 'Introduce el PIN de fin de sesión';

  @override
  String get sessionEndPinAppPinMismatch =>
      'Usa el PIN de fin de sesión, no el PIN de bloqueo de la app.';

  @override
  String get sessionEndPinIncorrect => 'PIN incorrecto';

  @override
  String get sessionEndPinSimSkip => 'Omitir (solo sim.)';

  @override
  String get sessionEndSimDistressWouldFire =>
      'Se activaría la cadena de auxilio (5 PIN incorrectos)';

  @override
  String get distressConfirmTitle => 'Auxilio activado';

  @override
  String distressConfirmCountdown(int seconds) {
    return 'Toca para cancelar: tienes $seconds segundos';
  }

  @override
  String get distressConfirmCancel => 'Toca para cancelar';

  @override
  String get distressConfirmFooter =>
      'Si no se cancela, la cadena de auxilio comenzará de inmediato.';

  @override
  String get distressCancelPinPromptTitle =>
      'Introduce el PIN de fin de sesión';

  @override
  String distressCancelPinTimeoutLabel(int seconds) {
    return 'Quedan $seconds s';
  }

  @override
  String get distressCancelPinIncorrect => 'PIN incorrecto';

  @override
  String get distressCancelPinAppPinMismatch =>
      'Usa el PIN de fin de sesión, no el PIN de bloqueo de la app.';

  @override
  String get distressCancelPinSimSkip => 'Omitir (solo sim.)';

  @override
  String get distressCancelSimDistressWouldFire =>
      'Se activaría la cadena de auxilio (5 PIN incorrectos)';

  @override
  String get distressCancelPinBack => 'Cancelar';

  @override
  String get simulationPinPromptTitle => 'Introduce el PIN';

  @override
  String get simulationPinPromptBody =>
      'Practica la introducción de tu PIN de fin de sesión';

  @override
  String get simulationPinPromptSkip => 'Omitir';

  @override
  String get simulationPinIncorrect => 'PIN incorrecto';

  @override
  String simulationSummaryDuration(String duration) {
    return 'Duración: $duration';
  }

  @override
  String get simulationSummaryTimelineHeader => 'Cronología de eventos';

  @override
  String get simulationSummaryShare => 'Compartir';

  @override
  String simulationSummaryMissedEventsBadge(int count) {
    return 'Omitidos: $count';
  }

  @override
  String simulationSummaryDistressBadge(int count) {
    return 'Auxilio: $count';
  }

  @override
  String simulationSummaryStepsFiredBadge(int count) {
    return 'Pasos activados: $count';
  }

  @override
  String get simulationSummaryShareSubject =>
      'Resumen de la simulación de Guardian Angela';

  @override
  String get notificationsChannelAlarm => 'Escalada de alarma';

  @override
  String get notificationsChannelAlarmDescription =>
      'Alertas críticas que omiten el modo No molestar';

  @override
  String get notificationsChannelReminder => 'Recordatorio camuflado';

  @override
  String get notificationsChannelReminderDescription =>
      'Recordatorios de confirmación durante una sesión activa';

  @override
  String get notificationsChannelFakeCall => 'Llamada falsa';

  @override
  String get notificationsChannelFakeCallDescription =>
      'Notificaciones de llamada entrante a pantalla completa';

  @override
  String get notificationsChannelEnabled => 'Activado';

  @override
  String get notificationsChannelDisabled => 'Desactivado';

  @override
  String get notificationsChannelsHeader => 'Canales de notificación';

  @override
  String get contactsImportFromDevice => 'Importar de contactos';

  @override
  String get contactsImportNotSupported => 'No disponible en esta plataforma';

  @override
  String get contactsImportPermissionDenied =>
      'Acceso a los contactos denegado. Actívalo en los ajustes del sistema.';

  @override
  String get contactsDeleteAllMenu => 'Eliminar todo';

  @override
  String get contactsDeleteAllConfirmTitle => '¿Eliminar todos los contactos?';

  @override
  String get contactsDeleteAllConfirmBody =>
      'Esto elimina todos los contactos de emergencia. No se puede deshacer.';

  @override
  String get contactsDeleteAllTypeConfirmTitle => 'Confirmar escribiendo';

  @override
  String get contactsDeleteAllTypeConfirmHint =>
      'Escribe ELIMINAR TODO para continuar';

  @override
  String get contactsDeleteAllTypeConfirmSentinel => 'ELIMINAR TODO';

  @override
  String get contactsDeleteAllConfirmButton => 'Eliminar todo';

  @override
  String get modesBuiltinBadge => 'Preinstalado';

  @override
  String get modesBuiltinNoDelete =>
      'Los modos preinstalados no se pueden eliminar';

  @override
  String get sessionCompletedSimulationBanner => 'Simulación completada';

  @override
  String get sessionCompletedViewEventLog => 'Ver registro de eventos';

  @override
  String get settingsGeneralHeader => 'General';

  @override
  String get settingsAppHeader => 'App';

  @override
  String get settingsConfigurationHeader => 'Configuración';

  @override
  String get settingsThemeLabel => 'Tema';

  @override
  String get settingsLanguageLabel => 'Idioma';

  @override
  String get settingsSecurityRow => 'Seguridad';

  @override
  String get settingsSecuritySubtitle =>
      'PIN de la app, PIN de fin de sesión, PIN de coacción';

  @override
  String get settingsStealthRow => 'Sigilo';

  @override
  String get settingsStealthSummaryOff => 'Sigilo: DESACTIVADO';

  @override
  String get settingsStealthSummaryOn => 'Sigilo: ACTIVADO';

  @override
  String get settingsProfileRow => 'Perfil';

  @override
  String get settingsModesRow => 'Modos';

  @override
  String get settingsDistressModesRow => 'Modos de auxilio';

  @override
  String get settingsEventDefaultsRow => 'Valores predeterminados de pasos';

  @override
  String get settingsGpsLoggingRow => 'Registro de GPS';

  @override
  String get settingsRemindersRow => 'Plantillas de recordatorio';

  @override
  String get settingsNotificationsRow => 'Notificaciones';

  @override
  String get settingsHistoryRetentionRow => 'Historial y retención';

  @override
  String get settingsAboutRow => 'Acerca de';

  @override
  String get settingsFeedbackRow => 'Enviar comentarios';

  @override
  String get settingsBackupRow => 'Copia de seguridad y restauración';

  @override
  String get settingsOssLicenses => 'Licencias de código abierto';

  @override
  String get settingsImportConfirmBody =>
      'Esto sobrescribirá todos los datos actuales. ¿Continuar?';

  @override
  String get securityAppPinTitle => 'PIN de la app';

  @override
  String get securityAppPinBody => 'Bloquea la app cada vez que la abres.';

  @override
  String get securitySessionEndPinTitle => 'PIN de fin de sesión';

  @override
  String get securitySessionEndPinBody =>
      'Necesario para desactivar o finalizar una sesión en curso.';

  @override
  String get securityDuressPinTitle => 'PIN de coacción';

  @override
  String get securityDuressPinBody =>
      'Se introduce en cualquier mensaje para activar la cadena de auxilio en silencio.';

  @override
  String get securityRemovePin => 'Eliminar';

  @override
  String get securityRemovePinPrompt =>
      'Introduce tu PIN actual para eliminarlo.';

  @override
  String get securityRemovePinIncorrect => 'PIN incorrecto';

  @override
  String get securityWhatIsThis => '¿Qué es esto?';

  @override
  String get securityAppPinInfo =>
      'Bloquea la app al abrirla. El teclado aparece antes de cualquier pantalla. Útil si alguien maneja brevemente tu teléfono desbloqueado.';

  @override
  String get securitySessionEndPinInfo =>
      'Necesario para desactivar o finalizar una sesión de seguridad en curso. Sin él, un atacante que se apodere de tu teléfono no puede detener la cadena. Usa un código distinto del PIN de la app.';

  @override
  String get securityDuressPinInfo =>
      'Si alguna vez introduces este PIN en cualquier mensaje, la cadena de auxilio se ejecuta en silencio: se avisa a tus contactos y la alarma se prepara sin que el atacante lo note. Elige un código distinto de cualquier otro PIN.';

  @override
  String get securityPinTimeoutLabel => 'Tiempo de espera del PIN (segundos)';

  @override
  String get securityWrongPinThresholdLabel =>
      'Intentos de PIN incorrecto antes de la escalada';

  @override
  String get securityDeceptiveDialogToggle =>
      'Mostrar diálogo engañoso con un PIN incorrecto';

  @override
  String get pinSetupEnterNew => 'Introduce el nuevo PIN';

  @override
  String get pinSetupConfirmNew => 'Confirma el nuevo PIN';

  @override
  String get pinSetupTooShort => 'El PIN debe tener al menos 4 dígitos.';

  @override
  String get pinSetupCollision => 'Este PIN coincide con otro PIN configurado.';

  @override
  String get pinSetupSaved => 'PIN guardado';

  @override
  String get stealthEnabledLabel => 'Habilitar sigilo';

  @override
  String get stealthFakeNameLabel => 'Nombre falso de la app';

  @override
  String get stealthFakeIconLabel => 'Icono falso';

  @override
  String get stealthNotificationDisguiseLabel => 'Disfraz de notificaciones';

  @override
  String get stealthTimerDisplayLabel => 'Pantalla del temporizador';

  @override
  String get stealthSessionScreenLabel => 'Sigilo en la pantalla de sesión';

  @override
  String get gpsLoggingEnabled => 'Registrar GPS durante las sesiones';

  @override
  String get gpsLoggingIntervalLabel => 'Intervalo';

  @override
  String get gpsLoggingAccuracyLabel => 'Precisión';

  @override
  String get gpsLoggingAccuracyHigh => 'Alta';

  @override
  String get gpsLoggingAccuracyBalanced => 'Equilibrada';

  @override
  String get gpsLoggingAccuracyLow => 'Baja';

  @override
  String get gpsLoggingFormatLabel => 'Formato de coordenadas';

  @override
  String get gpsLoggingFormatDecimal => 'Decimal';

  @override
  String get gpsLoggingFormatDms => 'GMS';

  @override
  String get gpsLoggingFormatAddress => 'Plus Code';

  @override
  String get gpsLoggingIncludeInSms => 'Añadir la ubicación al SMS';

  @override
  String get historyRetentionLogsLabel =>
      'Retención del registro de sesión (días)';

  @override
  String get historyRetentionLogsHelper =>
      'Los registros más antiguos que esto pasan a la papelera.';

  @override
  String get historyRetentionTrashLabel => 'Retención de la papelera (días)';

  @override
  String get historyRetentionTrashHelper =>
      'Los registros en la papelera se eliminan de forma permanente tras este periodo.';

  @override
  String get historyRetentionUpdated => 'Retención actualizada';

  @override
  String get historyRetentionPurgeNow => 'Purgar ahora';

  @override
  String historyRetentionPurged(Object count) {
    return '$count registros purgados';
  }

  @override
  String get eventDefaultsCheckInHeader => 'Métodos de confirmación';

  @override
  String get eventDefaultsEscalationHeader => 'Pasos de escalada';

  @override
  String get eventDefaultsPanicHeader => 'Desencadenante de pánico';

  @override
  String get templatesCreate => 'Crear plantilla';

  @override
  String get templatesEditTitle => 'Editar plantilla';

  @override
  String get templatesCreateTitle => 'Nueva plantilla';

  @override
  String get templatesNameLabel => 'Nombre';

  @override
  String get templatesTitleLabel => 'Título';

  @override
  String get templatesBodyLabel => 'Cuerpo';

  @override
  String get templatesBuiltinNoDelete =>
      'Las plantillas preinstaladas no se pueden eliminar';

  @override
  String get templatesAddFromTemplate => 'Desde plantilla';

  @override
  String get templatesAddFromScratch => 'Desde cero';

  @override
  String templatesDeleteConfirmTitle(Object name) {
    return '¿Eliminar «$name»?';
  }

  @override
  String get templatesDeleteConfirmBody =>
      'Esta plantilla se eliminará de forma permanente.';

  @override
  String get templatesEmptyAddFirst => 'Añade tu primera plantilla';

  @override
  String get templatesPickFromBuiltinTitle =>
      'Elige una plantilla preinstalada';

  @override
  String get templatesIconLabel => 'Icono';

  @override
  String get templatesIconCalendar => 'Calendario';

  @override
  String get templatesIconAppNotification => 'Notificación de app';

  @override
  String get templatesIconFitness => 'Fitness';

  @override
  String get templatesIconHealth => 'Salud';

  @override
  String get templatesIconFood => 'Comida';

  @override
  String get templatesIconCoffee => 'Café';

  @override
  String get templatesIconBattery => 'Batería';

  @override
  String get templatesIconWeather => 'Tiempo';

  @override
  String get templatesPreviewHeading => 'Vista previa en vivo';

  @override
  String get templatesDiscardChangesTitle => '¿Descartar cambios?';

  @override
  String get templatesDiscardChangesBody =>
      'Se perderán las ediciones sin guardar.';

  @override
  String get templatesDiscardKeep => 'Seguir editando';

  @override
  String get templatesDiscardDiscard => 'Descartar';

  @override
  String get notificationsTitle => 'Notificaciones';

  @override
  String get notificationsStatusGranted => 'Concedido';

  @override
  String get notificationsStatusDenied => 'Denegado';

  @override
  String get notificationsStatusUnknown => 'Aún sin solicitar';

  @override
  String get notificationsRequest => 'Solicitar permiso';

  @override
  String get notificationsOpenSettings => 'Abrir los ajustes del sistema';

  @override
  String get profileFieldPhone => 'Número de teléfono';

  @override
  String get profileFieldDescription => 'Descripción física';

  @override
  String get profileFieldMedicalConditions => 'Condiciones médicas';

  @override
  String get profileFieldEmergencyInstructions => 'Instrucciones de emergencia';

  @override
  String get aboutAuthor => 'Autor: Jonas Eschle';

  @override
  String get aboutEmail => 'guardian.angela.app@gmail.com';

  @override
  String get aboutPrivacyPolicy => 'Política de privacidad';

  @override
  String get aboutTermsOfService => 'Términos del servicio';

  @override
  String get aboutSourceCode => 'Código fuente';

  @override
  String get aboutSupport => 'Apoyar / donar';

  @override
  String get aboutLicenses => 'Licencias de código abierto';

  @override
  String get aboutTagline => 'Hecho con amor por la seguridad LGBTQ+.';

  @override
  String get aboutTechnicalSection => 'Información técnica';

  @override
  String aboutBundleId(Object id) {
    return 'ID del paquete: $id';
  }

  @override
  String aboutPlatforms(Object list) {
    return 'Plataformas: $list';
  }

  @override
  String get feedbackHeading => 'Nos encantaría saber de ti';

  @override
  String get feedbackCategoryLabel => 'Categoría';

  @override
  String get feedbackCategoryBug => 'Informe de error';

  @override
  String get feedbackCategoryFeature => 'Solicitud de función';

  @override
  String get feedbackCategoryOther => 'Otro';

  @override
  String get feedbackEmailLabel => 'Correo electrónico (opcional)';

  @override
  String get feedbackMessageLabel => 'Mensaje';

  @override
  String get feedbackIncludeLog => 'Incluir el último registro de sesión';

  @override
  String get feedbackSent => '¡Gracias por tus comentarios!';

  @override
  String get feedbackMessageRequired =>
      'El mensaje debe tener al menos 10 caracteres.';

  @override
  String get backupIncludeLogs => 'Incluir los registros de sesión';

  @override
  String get backupIncludeMedia => 'Incluir archivos multimedia';

  @override
  String get backupExportButton => 'Exportar';

  @override
  String get backupImportButton => 'Importar';

  @override
  String get backupOverwriteWarning =>
      'Importar sobrescribe todos los datos actuales.';

  @override
  String get backupImportSuccess =>
      'Importación completa. Reinicia para aplicar.';

  @override
  String backupImportError(Object message) {
    return 'Error al importar: $message';
  }

  @override
  String get backupActiveSessionBanner =>
      'La copia de seguridad no está disponible durante una sesión activa.';

  @override
  String backupLastBackupAtLabel(Object when) {
    return 'Última copia de seguridad el $when';
  }

  @override
  String get backupNeverExportedLabel => 'Aún no hay copia de seguridad';

  @override
  String get pastEventsTitle => 'Sesiones anteriores';

  @override
  String get pastEventsTabReal => 'Reales';

  @override
  String get pastEventsTabSimulated => 'Simuladas';

  @override
  String get pastEventsEmpty => 'Aún no hay sesiones';

  @override
  String get pastEventsDeleteConfirm => '¿Eliminar el registro de sesión?';

  @override
  String get pastEventsDetailShareText => 'Compartir como texto';

  @override
  String get pastEventsDetailSharePdf => 'Compartir como PDF';

  @override
  String get pastEventsDetailDelete => 'Eliminar';

  @override
  String get pastEventsOutcomeCompleted => 'Completada';

  @override
  String get pastEventsOutcomeDistress => 'Auxilio';

  @override
  String get pastEventsOutcomeInterrupted => 'Interrumpida';

  @override
  String get pastEventsTrash => 'Papelera';

  @override
  String get pastEventsUndo => 'Deshacer';

  @override
  String get pastEventsSoftDeleted => 'Movido a la papelera';

  @override
  String get pastEventsDetailTitle => 'Registro de sesión';

  @override
  String get pastEventsDetailShare => 'Compartir';

  @override
  String get contactUnsavedDiscardTitle =>
      '¿Descartar los cambios sin guardar?';

  @override
  String get contactUnsavedDiscardKeep => 'Seguir editando';

  @override
  String get contactUnsavedDiscardDiscard => 'Descartar';

  @override
  String get modesDuplicate => 'Duplicar';

  @override
  String get modesDeleteConfirmTitle => '¿Eliminar el modo?';

  @override
  String modesDeleteConfirmBody(Object name) {
    return '$name se eliminará de forma permanente.';
  }

  @override
  String get modesDistressDefaultBadge => 'Predeterminado';

  @override
  String get modesDistressSetDefault => 'Establecer como predeterminado';

  @override
  String get modesDistressCantDeleteLast =>
      'Se requiere al menos un modo de auxilio.';

  @override
  String get modesDistressInUse =>
      'Otro modo está usando este modo de auxilio.';

  @override
  String get modesDistressTitle => 'Modos de auxilio';

  @override
  String get validationNameTooShort =>
      'El nombre debe tener al menos 2 caracteres.';

  @override
  String get validationPhoneRequired => 'El número de teléfono es obligatorio.';

  @override
  String get validationChannelsRequired => 'Selecciona al menos un canal.';

  @override
  String get validationChainEmpty => 'Añade al menos un paso antes de guardar.';

  @override
  String get validationGpsFixedCoords =>
      'Indica la latitud y la longitud del destino de llegada fijo.';

  @override
  String get validationHardwareTrigger =>
      'El activador de pánico de hardware está incompleto: revisa el número de pulsaciones o la duración de la pulsación.';

  @override
  String get validationSmsChannelNotOnContacts =>
      'Ninguno de los contactos elegidos puede recibir por el canal de este paso. Elige otro canal o añádelo a un contacto.';

  @override
  String get validationDistressNoActionTitle => 'Sin paso de alerta saliente';

  @override
  String get validationDistressNoActionBody =>
      'Este modo de emergencia no tiene ningún paso de SMS o llamada, por lo que no deja rastro saliente. ¿Guardar de todos modos?';

  @override
  String get validationSaveAnyway => 'Guardar de todos modos';

  @override
  String get sessionHoldTouchToBegin => 'Toca para empezar';

  @override
  String sessionHoldReleaseCountdown(Object seconds) {
    return 'Cuenta atrás: $seconds s';
  }

  @override
  String sessionHoldGraceCountdown(Object seconds) {
    return 'Gracia: $seconds s: vuelve a mantener pulsado para seguir a salvo';
  }

  @override
  String get sessionHoldAgain => 'Mantén pulsado de nuevo para seguir a salvo';

  @override
  String sessionStepNextCheckIn(Object time) {
    return 'Próxima confirmación en $time';
  }

  @override
  String sessionStepFakeCallActive(Object caller) {
    return 'Llamada entrante de $caller';
  }

  @override
  String get sessionStepFakeCallOpen => 'Abrir pantalla de llamada';

  @override
  String sessionStepSimBlockedSms(Object count) {
    return '[SIM] Enviaría un SMS a $count contactos';
  }

  @override
  String get sessionStepSimBlockedPhone =>
      '[SIM] Llamaría al contacto de emergencia';

  @override
  String get sessionStepSimBlockedEmergency =>
      '[SIM] Llamaría a los servicios de emergencia';

  @override
  String get sessionStepSimBlockedAlarm =>
      '[SIM] La alarma habría sonado a todo volumen';

  @override
  String get sessionStartFailedTitle => 'No se puede iniciar la sesión';

  @override
  String get sessionStartFailedBody =>
      'Corrige los siguientes problemas antes de empezar:';

  @override
  String get sessionQuickExitTitle => 'Salida rápida';

  @override
  String get sessionQuickExitBody =>
      'Los datos de la sesión se conservarán cifrados. Vuelve a abrir la app en cualquier momento para recuperarlos.';

  @override
  String get sessionQuickExitConfirm => 'Salir de la app';

  @override
  String get pastEventsRestore => 'Restaurar';

  @override
  String get stepEditorWait => 'Espera (s)';

  @override
  String get stepEditorDuration => 'Duración (s)';

  @override
  String get stepEditorGrace => 'Gracia (s)';

  @override
  String get stepEditorRetryCount => 'Número de reintentos';

  @override
  String get stepEditorRandomize => 'Aleatorizar los tiempos (±20 %)';

  @override
  String get stepEditorRemove => 'Eliminar paso';

  @override
  String get eventDefaultsHoldStyle => 'Estilo de pulsación';

  @override
  String get eventDefaultsHoldSensitivity => 'Sensibilidad de liberación';

  @override
  String get eventDefaultsHoldVibrate => 'Vibrar al soltar';

  @override
  String get eventDefaultsHoldSound => 'Sonido al soltar';

  @override
  String get eventDefaultsBlackScreen => 'Superposición de pantalla negra';

  @override
  String get eventDefaultsReminderRandomInterval => 'Aleatorizar el intervalo';

  @override
  String get eventDefaultsReminderRandomTemplate =>
      'Aleatorizar el orden de las plantillas';

  @override
  String get eventDefaultsReminderResetOnEarly =>
      'Restablecer al confirmar antes de tiempo';

  @override
  String get eventDefaultsCountdownStyle => 'Estilo de la cuenta atrás';

  @override
  String get eventDefaultsCountdownVibrate => 'Vibrar';

  @override
  String get eventDefaultsCountdownSound => 'Sonido';

  @override
  String get eventDefaultsFakeCallStyle => 'Estilo de llamada';

  @override
  String get eventDefaultsFakeCallCallerName => 'Nombre de quien llama';

  @override
  String get eventDefaultsFakeCallRingDuration => 'Duración del tono (s)';

  @override
  String get eventDefaultsFakeCallDeclineIsSafe =>
      'Rechazar cuenta como a salvo';

  @override
  String get eventDefaultsFakeCallVoiceOutput => 'Salida de voz';

  @override
  String get eventDefaultsSmsChannel => 'Canal';

  @override
  String get eventDefaultsSmsIncludeLocation => 'Incluir la ubicación';

  @override
  String get eventDefaultsSmsIncludeMedical => 'Incluir información médica';

  @override
  String get eventDefaultsSmsAutoRecord => 'Grabar audio antes de enviar';

  @override
  String get eventDefaultsSmsRecordDuration => 'Duración de la grabación (s)';

  @override
  String get eventDefaultsSmsMessageTemplate => 'Plantilla de mensaje';

  @override
  String get eventDefaultsSmsMessageTemplateHint =>
      'Déjalo en blanco para usar la alerta predeterminada. Toca un marcador para insertarlo.';

  @override
  String get eventDefaultsSmsIosWarning =>
      'En el iPhone, el SMS requiere que pulses Enviar manualmente en la app Mensajes. Si no puedes usar el teléfono, el mensaje no se enviará. Considera usar WhatsApp o Telegram.';

  @override
  String get eventDefaultsLoudAlarmVolume => 'Volumen';

  @override
  String get eventDefaultsLoudAlarmSound => 'Sonido';

  @override
  String get eventDefaultsLoudAlarmFlashScreen => 'Parpadear la pantalla';

  @override
  String get eventDefaultsLoudAlarmFlashLight =>
      'Parpadear el flash de la cámara';

  @override
  String get eventDefaultsLoudAlarmGradual => 'Aumento gradual del volumen';

  @override
  String get eventDefaultsCallEmergencyNumber =>
      'Número de emergencia (anular)';

  @override
  String get eventDefaultsCallEmergencyConfirm =>
      'Mostrar cuenta atrás de confirmación';

  @override
  String get eventDefaultsCallEmergencyConfirmDuration =>
      'Segundos de confirmación';

  @override
  String get eventDefaultsCallEmergencySmsFirst =>
      'Enviar primero un SMS con la ubicación';

  @override
  String get eventDefaultsCallEmergencyIosWarning =>
      'En el iPhone aparecerá un cuadro de confirmación antes de llamar. Toca «Llamar» rápidamente.';

  @override
  String get eventDefaultsPhonePrimaryContact => 'Contacto principal (id)';

  @override
  String get eventDefaultsHardwareButton => 'Botón';

  @override
  String get eventDefaultsHardwarePattern => 'Patrón de pulsación';

  @override
  String get eventDefaultsHardwarePressCount => 'Número de pulsaciones';

  @override
  String get eventDefaultsHardwareLongDuration =>
      'Duración de la pulsación larga (s)';

  @override
  String get pastEventsTrashTitle => 'Papelera';

  @override
  String get pastEventsTrashEmpty => 'La papelera está vacía';

  @override
  String get pastEventsTrashEmptyAll => 'Vaciar papelera';

  @override
  String get pastEventsTrashEmptyAllConfirmTitle => '¿Vaciar la papelera?';

  @override
  String get pastEventsTrashEmptyAllConfirmBody =>
      'Escribe EMPTY TRASH abajo para confirmar. Esto elimina de forma permanente todos los registros de la papelera.';

  @override
  String pastEventsTrashEmptyAllSuccess(Object count) {
    return 'Papelera vaciada ($count registros)';
  }

  @override
  String pastEventsTrashRetentionNote(int days) {
    return 'Los registros de la papelera se eliminan de forma permanente tras $days días.';
  }

  @override
  String pastEventsTrashRemainingDays(int days) {
    return '$days día(s) hasta la eliminación permanente';
  }

  @override
  String get pastEventsTrashDeletePermanently => 'Eliminar de forma permanente';

  @override
  String get pastEventsTrashDeletePermanentlyBody =>
      'Esta acción no se puede deshacer.';

  @override
  String sessionEmergencyConfirmTitle(String number, int seconds) {
    return 'Llamando a $number en $seconds s';
  }

  @override
  String get sessionEmergencyConfirmSwipe => 'Desliza para cancelar';

  @override
  String get sessionEmergencyConfirmKeep => 'Seguir llamando';

  @override
  String get sessionEmergencyConfirmSimBadge => '[SIM] Modo de práctica';

  @override
  String get sessionEmergencyConfirmSimCancelled =>
      'Cancelación simulada: la llamada no se habría realizado';

  @override
  String get swipeSliderSemantics => 'Desliza para confirmar';

  @override
  String get homeWidgetStatusIdle => 'En espera';

  @override
  String get homeWidgetStatusSession => 'Sesión activa';

  @override
  String get homeWidgetStatusSim => 'Simulación activa';

  @override
  String get homeWidgetQuickExit => 'Salida rápida';

  @override
  String get homeWidgetFakeCall => 'Llamada falsa';

  @override
  String get settingsAlarmHeader => 'Alarma';

  @override
  String get settingsAlarmDndOverrideLabel =>
      'La alarma anula el modo silencio/vibración';

  @override
  String get settingsAlarmDndOverrideWarning =>
      'Advertencia: la alarma será silenciosa si tu teléfono está en modo silencio.';

  @override
  String get settingsAlarmDndOverrideInfo =>
      'Cuando se activa, la alarma fuerte suena al máximo volumen aunque el teléfono esté en silencio o vibración. En Android usa el canal de audio de alarma para saltarse el modo No molestar. La alarma es el único evento que puede anular los ajustes de sonido de tu teléfono.';

  @override
  String get settingsAlarmGradualLabel =>
      'Aumentar el volumen de la alarma gradualmente';

  @override
  String get settingsAlarmGradualInfo =>
      'Inicia la alarma en voz baja y la sube hasta el volumen máximo. Este es el interruptor principal de toda la app; cada paso de alarma también tiene su propia opción de volumen gradual, y ambos deben estar activados para que se aplique el aumento.';

  @override
  String get settingsAlarmRampLabel => 'Duración del aumento';

  @override
  String get settingsAlarmRampInfo =>
      'Cuánto tarda la alarma en alcanzar el volumen máximo desde cero, subiendo de forma uniforme durante este tiempo. No tiene efecto cuando el volumen gradual está desactivado.';
}
