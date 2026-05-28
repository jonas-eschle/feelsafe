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
  String get profileAngelaWarningTitle => 'Aviso sobre el nombre «Angela»';

  @override
  String get profileAngelaWarningBody =>
      'Guardian Angela utiliza «Angela» como palabra clave de seguridad. Usarla como su propio nombre puede causar confusión. ¿Guardar de todos modos?';

  @override
  String get commonDelete => 'Eliminar';

  @override
  String get commonEdit => 'Editar';

  @override
  String get commonAdd => 'Agregar';

  @override
  String get commonClose => 'Cerrar';

  @override
  String get commonConfirm => 'Confirmar';

  @override
  String get commonBack => 'Atrás';

  @override
  String get commonDone => 'Listo';

  @override
  String get commonRetry => 'Reintentar';

  @override
  String get commonYes => 'Sí';

  @override
  String get commonNo => 'No';

  @override
  String get commonEnabled => 'Activado';

  @override
  String get commonDisabled => 'Desactivado';

  @override
  String get commonNone => 'Ninguno';

  @override
  String get commonSeconds => 'segundos';

  @override
  String get commonMinutes => 'minutos';

  @override
  String get cancel => 'Cancelar';

  @override
  String get pinSubmit => 'Enviar';

  @override
  String get homeTitle => 'Guardian Angela';

  @override
  String get homeStartSession => 'Iniciar sesión';

  @override
  String get homeStartConfirmTitle => '¿Iniciar una sesión?';

  @override
  String get homeStartConfirmBody =>
      'Asegúrese de tener configurados sus contactos y su PIN. La sesión se ejecutará en primer plano y el modo seleccionado guiará las confirmaciones.';

  @override
  String get homePermissionsMissingTitle => 'Faltan algunos permisos';

  @override
  String get homePermissionsMissingBody =>
      'Los siguientes permisos no se concedieron. Sin ellos, los pasos correspondientes fallarán silenciosamente:';

  @override
  String get homePermissionsContinueAnyway => 'Iniciar de todos modos';

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
  String get homeActiveSession => 'Sesión activa';

  @override
  String get homeResumeSession => 'Reanudar';

  @override
  String get homeNoModes => 'Aún no hay modos. Toca Modos para agregar uno.';

  @override
  String get homeNoContacts =>
      'Aún no hay contactos de emergencia. Toca Contactos para agregar uno.';

  @override
  String get homeContactsBannerNone =>
      'No hay contactos de emergencia configurados.';

  @override
  String get homeMenuSettings => 'Ajustes';

  @override
  String get homeMenuContacts => 'Contactos';

  @override
  String get homeMenuModes => 'Modos';

  @override
  String get homeMenuHistory => 'Sesiones anteriores';

  @override
  String get homeSelectMode => 'Seleccionar modo';

  @override
  String get onboardingWelcomeTitle => 'Bienvenido a Guardian Angela';

  @override
  String get onboardingWelcomeBody =>
      'Una compañera que te mantiene a salvo camino a casa. Guardian Angela te cuida mientras caminas, corres o viajas, y puede avisar a tus contactos de confianza si necesitas ayuda.';

  @override
  String get onboardingProfileTitle => 'Perfil y primer contacto';

  @override
  String get onboardingProfileBody =>
      'Cuéntanos un poco sobre ti para que Guardian Angela pueda compartir detalles útiles si necesitas ayuda de emergencia. Luego añade un contacto de confianza.';

  @override
  String get onboardingPermissionsTitle => 'Permisos';

  @override
  String get onboardingPermissionsBody =>
      'Guardian Angela necesita algunos permisos para mantenerte a salvo. Concédelos ahora o más tarde desde Ajustes.';

  @override
  String get onboardingNext => 'Siguiente';

  @override
  String get onboardingSkip => 'Omitir';

  @override
  String get onboardingFinish => 'Finalizar';

  @override
  String get sessionTitle => 'Sesión';

  @override
  String get sessionDisarm => 'Estoy a salvo';

  @override
  String get sessionPause => 'Pausar';

  @override
  String get sessionResume => 'Reanudar';

  @override
  String get sessionHoldPrompt => 'Mantén pulsado para seguir a salvo';

  @override
  String get sessionHoldSemantic =>
      'Mantén pulsado. Al soltar se inicia un periodo de gracia.';

  @override
  String sessionStepLabel(Object index, Object total) {
    return 'Paso $index de $total';
  }

  @override
  String sessionMissCount(Object count) {
    return 'Omitidos: $count';
  }

  @override
  String sessionRemaining(Object seconds) {
    return '$seconds s restantes';
  }

  @override
  String get sessionPausedBadge => 'En pausa';

  @override
  String get sessionPhaseEnded => 'Sesión finalizada';

  @override
  String get sessionSimulationBanner => 'Simulación';

  @override
  String get sessionCheckIn => 'Estoy a salvo';

  @override
  String get sessionDisarmTriggerTitle =>
      'Disparador de desactivación activado';

  @override
  String get sessionDisarmTriggerBody =>
      'Se activó un disparador de desactivación. ¿Finalizar la sesión?';

  @override
  String get sessionDisarmTriggerConfirm => 'Finalizar sesión';

  @override
  String get sessionDisarmTriggerCancel => 'Continuar';

  @override
  String get wrongPinAngelaTitle => 'PIN antiguo de Angela';

  @override
  String get wrongPinAngelaBody =>
      '¿Seguro que desea continuar con este PIN antiguo?';

  @override
  String get wrongPinAngelaConfirm => 'Aceptar';

  @override
  String get wrongPinAngelaCancel => 'Cancelar';

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
  String get sessionStepSmsStatus => 'Enviando mensaje a contactos…';

  @override
  String get sessionStepSmsDelivered => 'Entregado';

  @override
  String get sessionStepSmsSent => 'Enviado';

  @override
  String get sessionStepSmsQueued => 'En cola';

  @override
  String get sessionStepSmsFailed => 'Error';

  @override
  String get sessionStepPhoneCallStatus =>
      'Llamando al contacto de emergencia…';

  @override
  String get sessionStepPhoneCallCancel => 'Cancelar llamada';

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
  String get simulationSummaryTitle => 'Resumen de la simulación';

  @override
  String get simulationSummaryEmpty =>
      'No se activó ningún paso durante esta simulación.';

  @override
  String get simulationSummaryReturn => 'Volver al inicio';

  @override
  String get fakeCallTitle => 'Llamada entrante';

  @override
  String get fakeCallAnswer => 'Contestar';

  @override
  String get fakeCallDecline => 'Rechazar';

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
  String get contactRequiredError =>
      'El nombre y el número de teléfono son obligatorios.';

  @override
  String get contactFormIosSmsWarning =>
      'On iOS, SMS opens the Messages app. You must tap Send manually.';

  @override
  String get modesTitle => 'Modos';

  @override
  String get modesEmpty => 'Aún no hay modos. Toca Añadir para crear un modo.';

  @override
  String get modesAdd => 'Añadir modo';

  @override
  String get modesNewPickerTitle => 'Empezar desde';

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
  String modesNewPickerCopyName(String name) {
    return 'Copia de $name';
  }

  @override
  String get modesNewPickerBuiltinBadge => 'Integrado';

  @override
  String get modeEditorTitleCreate => 'Nuevo modo';

  @override
  String get modeEditorTitleEdit => 'Editar modo';

  @override
  String get modeFieldName => 'Nombre';

  @override
  String get modeFieldDistressMode => 'Modo de auxilio';

  @override
  String get modeFieldDistressModeDefault => 'Usar predeterminada';

  @override
  String get modeChainHeader => 'Cadena';

  @override
  String get modeChainAddStep => 'Añadir paso';

  @override
  String get modeChainEmpty => 'Aún no hay pasos. Toca Añadir paso.';

  @override
  String get modeFieldIcon => 'Icono';

  @override
  String get modeIconPickerTitle => 'Elegir un icono';

  @override
  String get modeIconClear => 'Sin icono';

  @override
  String get modeDistressHeader => 'Disparadores de emergencia';

  @override
  String get modeDistressEmpty => 'No hay disparadores configurados.';

  @override
  String get modeDistressAdd => 'Añadir disparador';

  @override
  String get modeDistressTypeHardware => 'Botón físico';

  @override
  String get modeDistressButtonType => 'Botón';

  @override
  String get modeDistressButtonVolumeUp => 'Volumen +';

  @override
  String get modeDistressButtonVolumeDown => 'Volumen −';

  @override
  String get modeDistressButtonPower => 'Encendido';

  @override
  String get modeDistressPattern => 'Patrón';

  @override
  String get modeDistressPatternRepeat => 'Pulsación repetida';

  @override
  String get modeDistressPatternLong => 'Pulsación larga';

  @override
  String get modeDistressPressCount => 'Número de pulsaciones';

  @override
  String get modeDistressPressWindow => 'Ventana (ms)';

  @override
  String get modeDistressLongDuration => 'Duración (segundos)';

  @override
  String modeDistressSummaryRepeat(Object count, Object windowMs) {
    return '$count pulsaciones / $windowMs ms';
  }

  @override
  String modeDistressSummaryLong(Object seconds) {
    return 'Mantener ${seconds}s';
  }

  @override
  String get modeOverridesHeader => 'Anulaciones del modo';

  @override
  String get modeOverridesUseDefault => 'Usar valor predeterminado';

  @override
  String get modeOverridesGpsLabel => 'Registro GPS';

  @override
  String get modeOverridesStealthLabel => 'Modo sigiloso';

  @override
  String get modeOverridesEventDefaultsLabel =>
      'Valores predeterminados de evento';

  @override
  String get modeOverridesLocalTemplatesLabel =>
      'Plantillas locales de recordatorio';

  @override
  String get modeOverridesGpsEnabled => 'GPS activado';

  @override
  String get modeOverridesGpsIntervalLabel =>
      'Intervalo de muestreo (segundos)';

  @override
  String get modeOverridesGpsIncludeInSms => 'Incluir ubicación en SMS';

  @override
  String get modeOverridesStealthEnabled => 'Sigilo activado';

  @override
  String get modeOverridesStealthFakeName => 'Nombre falso de la app';

  @override
  String get modeOverridesEventDefaultsHint =>
      'Valores personalizados activos para este modo.';

  @override
  String modeOverridesLocalTemplatesCount(Object count) {
    return '$count plantillas locales';
  }

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
  String get stepDuplicate => 'Duplicar paso';

  @override
  String get stepTimingHeader => 'Tiempos';

  @override
  String stepTimingSummary(Object wait, Object duration, Object grace) {
    return 'espera ${wait}s / duración ${duration}s / gracia ${grace}s';
  }

  @override
  String get stepCategoryAll => 'Todos';

  @override
  String get stepPickerMore => 'Más opciones...';

  @override
  String get stepCategoryAction => 'Acción';

  @override
  String get stepCategoryReminder => 'Recordatorio';

  @override
  String get stepCategoryDisarm => 'Comprobación';

  @override
  String get modeTrackingHeader => 'Seguimiento GPS';

  @override
  String get modeTrackingEnabled => 'Registrar GPS durante la sesión';

  @override
  String get modeTrackingIntervalLabel => 'Intervalo de muestreo';

  @override
  String get modeTrackingBufferSizeLabel => 'Tamaño del búfer';

  @override
  String modeTrackingBufferSizeValue(Object count) {
    return '$count puntos';
  }

  @override
  String get modeTrackingBatteryNote =>
      'El seguimiento GPS frecuente aumenta el consumo de batería.';

  @override
  String get stepConfigLogGpsLabel => 'Registro de GPS';

  @override
  String get stepConfigLogGpsDefault => 'Predeterminado';

  @override
  String get stepConfigLogGpsOn => 'Activado';

  @override
  String get stepConfigLogGpsOff => 'Desactivado';

  @override
  String get stepConfigLogGpsDefaultOn => 'Predeterminado (Activado)';

  @override
  String get stepConfigLogGpsDefaultOff => 'Predeterminado (Desactivado)';

  @override
  String get moreSettingsHeader => 'Más ajustes';

  @override
  String moreSettingsHeaderCustomized(int count) {
    return 'Más ajustes ($count personalizados)';
  }

  @override
  String get stepTypePickerLabel => 'Tipo de paso';

  @override
  String get stepTypeHoldButton => 'Botón mantenido';

  @override
  String get stepTypeDisguisedReminder => 'Recordatorio disfrazado';

  @override
  String get stepTypeCountdownWarning => 'Aviso de cuenta regresiva';

  @override
  String get stepTypeFakeCall => 'Llamada falsa';

  @override
  String get stepTypeSmsContact => 'SMS a contacto';

  @override
  String get stepTypePhoneCallContact => 'Llamar a contacto';

  @override
  String get stepTypeLoudAlarm => 'Alarma sonora';

  @override
  String get stepTypeCallEmergency => 'Llamar a emergencias';

  @override
  String get stepTypeHardwareButton => 'Botón físico';

  @override
  String get stepFieldDuration => 'Duración (segundos)';

  @override
  String get stepFieldGrace => 'Periodo de gracia (segundos)';

  @override
  String get stepFieldWait => 'Espera (segundos)';

  @override
  String get stepFieldRetryCount => 'Número de reintentos';

  @override
  String get stepFieldRandomize => 'Variación del temporizador';

  @override
  String get stepFieldRandomizeToggle => 'Aleatorizar tiempo (±20%)';

  @override
  String get stepFieldWaitTooltip =>
      'Cuánto esperar antes de que comience este paso.';

  @override
  String get stepFieldDurationTooltip =>
      'Cuánto dura el paso activo antes de la ventana de gracia.';

  @override
  String get stepFieldGraceTooltip =>
      'Tiempo tras la fase activa para confirmar la seguridad antes del siguiente paso.';

  @override
  String get stepFieldRetryCountTooltip =>
      'Cuántas veces repetir este paso antes de escalar.';

  @override
  String get stepFieldReminderIntervalTooltip =>
      'Con qué frecuencia se dispara el recordatorio mientras se espera la confirmación.';

  @override
  String get stepFieldReminderGraceTooltip =>
      'Cuánto tiempo tiene el usuario para confirmar la seguridad tras aparecer el recordatorio.';

  @override
  String get stepPreview => 'Previsualizar en simulación';

  @override
  String stepPreviewFired(Object description) {
    return 'Previsualización ejecutada: $description';
  }

  @override
  String get stepPreviewTitle => 'Vista previa del paso';

  @override
  String get stepPreviewMissingParams =>
      'Falta la referencia al paso o al modo.';

  @override
  String get stepPreviewModeNotFound => 'Modo no encontrado.';

  @override
  String get stepPreviewStepNotFound => 'Paso no encontrado en este modo.';

  @override
  String stepPreviewError(Object error) {
    return 'La vista previa falló: $error';
  }

  @override
  String get stepPreviewReplay => 'Repetir';

  @override
  String get stepPreviewHoldButtonHint =>
      'Mantén pulsado el botón para sentir la respuesta real.';

  @override
  String get stepPreviewHoldButtonLabel => 'Mantener';

  @override
  String get stepPreviewHoldButtonSemantic =>
      'Mantén pulsado para previsualizar';

  @override
  String get stepPreviewHoldButtonReleased =>
      'Soltado. La sesión entraría ahora en el periodo de gracia.';

  @override
  String get stepPreviewFakeCallHint =>
      'Aparecerá la pantalla de llamada falsa. Desliza para responder o mantén pulsado el botón rojo para simular angustia.';

  @override
  String get stepConfigFakeCallCaller => 'Nombre de quien llama';

  @override
  String get stepConfigFakeCallDecline => 'Rechazar cuenta como desactivación';

  @override
  String get stepConfigLoudAlarmFlash => 'Pantalla estroboscópica';

  @override
  String get stepConfigLoudAlarmVolume => 'Volumen máximo';

  @override
  String get stepConfigCountdownVibrate => 'Vibrar';

  @override
  String get stepConfigCountdownTone => 'Reproducir tono';

  @override
  String get stepConfigSmsSelection => 'Destinatarios';

  @override
  String get stepConfigSmsAllContacts => 'Todos los contactos';

  @override
  String get stepConfigSmsSpecific => 'Contactos específicos';

  @override
  String get stepConfigSmsIncludeLocation => 'Incluir ubicación';

  @override
  String get stepConfigSmsIncludeMedical => 'Incluir información médica';

  @override
  String get stepConfigSmsAutoRecordAudio => 'Grabar audio automáticamente';

  @override
  String get stepConfigSmsAutoRecordVideo => 'Grabar vídeo automáticamente';

  @override
  String get stepConfigSmsRecordDuration => 'Duración de la grabación';

  @override
  String get stepConfigHoldReleaseSensitivity => 'Sensibilidad al soltar (s)';

  @override
  String get stepConfigReminderInterval =>
      'Intervalo del recordatorio (segundos)';

  @override
  String get stepConfigReminderTemplate => 'Plantilla';

  @override
  String get stepConfigHardwarePattern => 'Patrón';

  @override
  String get stepConfigHardwarePressCount => 'Número de pulsaciones';

  @override
  String get stepConfigHardwarePressWindow => 'Ventana entre pulsaciones (ms)';

  @override
  String get stepConfigHardwareLongDuration =>
      'Duración de pulsación larga (s)';

  @override
  String get stepConfigHardwareButton => 'Botón';

  @override
  String get stepConfigHardwareButtonVolumeUp => 'Subir volumen';

  @override
  String get stepConfigHardwareButtonVolumeDown => 'Bajar volumen';

  @override
  String get stepConfigHardwareButtonPower => 'Encendido';

  @override
  String get stepConfigHardwarePatternRepeat => 'Pulsación repetida';

  @override
  String get stepConfigHardwarePatternLong => 'Pulsación larga';

  @override
  String get stepConfigEmergencyNumber => 'Anular número de emergencia';

  @override
  String get stepConfigEmergencyConfirm => 'Confirmar antes de llamar';

  @override
  String get stepConfigPhonePreSms => 'Enviar SMS antes de llamar';

  @override
  String get distressModesTitle => 'Modos de auxilio';

  @override
  String get distressModeInUseTitle => 'El modo de auxilio está en uso';

  @override
  String distressModeInUseBody(Object modes) {
    return 'Este modo de auxilio aún está vinculado a: $modes. Vincula esos modos a otro modo de auxilio antes de eliminarlo.';
  }

  @override
  String get distressModesEmpty => 'Aún no hay modos de auxilio.';

  @override
  String get distressModesAdd => 'Añadir modo de auxilio';

  @override
  String get distressModeEditorTitleCreate => 'Nuevo modo de auxilio';

  @override
  String get distressModeEditorTitleEdit => 'Editar modo de auxilio';

  @override
  String get distressModeName => 'Nombre del modo de auxilio';

  @override
  String get distressCountdown => 'Activando modo de auxilio...';

  @override
  String get distressCountdownStealth => 'Espera un momento...';

  @override
  String get templatesTitle => 'Plantillas de recordatorio';

  @override
  String get templatesEmpty => 'Aún no hay plantillas.';

  @override
  String get templatesAdd => 'Añadir plantilla';

  @override
  String get templateEditorTitleCreate => 'Nueva plantilla';

  @override
  String get templateEditorTitleEdit => 'Editar plantilla';

  @override
  String get templateFieldName => 'Nombre en el editor';

  @override
  String get templateFieldTitle => 'Título del recordatorio';

  @override
  String get templateFieldBody => 'Cuerpo del recordatorio';

  @override
  String get templateFieldConfirmationType => 'Tipo de confirmación';

  @override
  String get templateFieldKeyword => 'Palabra clave';

  @override
  String get templateFieldButtonLabel => 'Texto del botón';

  @override
  String get templateFieldDisplayStyle => 'Estilo de presentación';

  @override
  String get templateConfirmTapButton => 'Tocar botón';

  @override
  String get templateConfirmTapWord => 'Tocar palabra';

  @override
  String get templateConfirmSwipe => 'Deslizar';

  @override
  String get templateConfirmDismiss => 'Descartar';

  @override
  String get templateDisplayFullscreen => 'Pantalla completa';

  @override
  String get templateDisplaySubtle => 'Sutil';

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
  String get profileFieldConditions => 'Condiciones médicas';

  @override
  String get profileFieldInstructions => 'Instrucciones de emergencia';

  @override
  String get profileAddItem => 'Añadir elemento';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsSectionSecurity => 'Seguridad';

  @override
  String get settingsSectionStealth => 'Modo sigiloso';

  @override
  String get settingsSectionDefaults => 'Valores predeterminados';

  @override
  String get settingsSectionHistory => 'Historial';

  @override
  String get settingsSectionBackup => 'Copia de seguridad';

  @override
  String get settingsSectionAbout => 'Acerca de';

  @override
  String get settingsSectionFeedback => 'Comentarios';

  @override
  String get settingsSectionContacts => 'Contactos';

  @override
  String get settingsSectionModes => 'Modos';

  @override
  String get settingsSectionProfile => 'Perfil';

  @override
  String get settingsSectionDistressModes => 'Modos de auxilio';

  @override
  String get settingsSectionReminderTemplates => 'Plantillas de recordatorio';

  @override
  String get settingsSectionBatteryAlert => 'Alerta de batería';

  @override
  String get settingsSectionEventDefaults => 'Valores predeterminados de pasos';

  @override
  String get settingsSectionGpsLogging => 'Registro GPS';

  @override
  String get settingsSectionNotifications => 'Notificaciones';

  @override
  String get settingsSectionHistoryRetention => 'Retención del historial';

  @override
  String get settingsSectionAppearance => 'Apariencia';

  @override
  String get settingsThemeMode => 'Tema';

  @override
  String get settingsThemeLight => 'Claro';

  @override
  String get settingsThemeDark => 'Oscuro';

  @override
  String get settingsThemeSystem => 'Sistema';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsEmergencyNumber => 'Número de emergencia';

  @override
  String get settingsAlarmDnd => 'La alarma anula No molestar';

  @override
  String get settingsLanguagePicker => 'Idioma';

  @override
  String get settingsEmergencyNumberLabel => 'Número de emergencia';

  @override
  String get settingsEmergencyNumberHint => 'p. ej., 112';

  @override
  String get settingsEmergencyNumberSave => 'Guardar';

  @override
  String get settingsRedoOnboarding => 'Repetir introducción';

  @override
  String get settingsRedoOnboardingConfirm => '¿Reiniciar introducción?';

  @override
  String get settingsRedoOnboardingBody =>
      'Tu configuración actual se conserva.';

  @override
  String get settingsRedoOnboardingProceed => 'Reiniciar';

  @override
  String get settingsAlarmGradualVolume => 'Volumen de alarma gradual';

  @override
  String settingsAlarmGradualVolumeDuration(int seconds) {
    return 'Duración del aumento: $seconds s';
  }

  @override
  String get securityTitle => 'Seguridad';

  @override
  String get securityAppPin => 'PIN de la app';

  @override
  String get securitySessionEndPin => 'PIN de fin de sesión';

  @override
  String get securityDuressPin => 'PIN de coacción';

  @override
  String get securityAppPinBiometric => 'Usar biometría para el PIN de la app';

  @override
  String get securitySessionEndPinBiometric =>
      'Usar biometría para el PIN de fin de sesión';

  @override
  String get securityDistressCancelBiometric =>
      'Usar biometría para cancelar emergencia';

  @override
  String get securityDuressTest => 'Probar PIN de coacción';

  @override
  String get securityDuressTestSubtitle =>
      'Compruebe que su PIN de coacción funciona.';

  @override
  String get securityPinTimeout => 'Tiempo de espera del PIN (segundos)';

  @override
  String get securityDisablePin => 'Desactivar';

  @override
  String get securitySetPin => 'Establecer PIN';

  @override
  String get securityChangePin => 'Cambiar PIN';

  @override
  String get pinSetupTitle => 'Establecer PIN';

  @override
  String get pinSetupEnter => 'Introduce el nuevo PIN';

  @override
  String get pinSetupConfirm => 'Confirma el PIN';

  @override
  String get pinSetupMismatch => 'Los PIN no coinciden. Inténtalo de nuevo.';

  @override
  String get pinEntryTitle => 'Introduce el PIN';

  @override
  String get pinEntrySubtitle => 'Introduce tu PIN para continuar.';

  @override
  String get pinEntryBiometricReason => 'Autentíquese para continuar';

  @override
  String get stealthTitle => 'Modo sigiloso';

  @override
  String get stealthEnable => 'Activar modo sigiloso';

  @override
  String get stealthFakeName => 'Nombre falso de la app';

  @override
  String get stealthFakeIcon => 'Icono falso';

  @override
  String get stealthNotificationDisguise => 'Disfrazar notificaciones';

  @override
  String get stealthTimerDisplay => 'Mostrar temporizador en modo sigiloso';

  @override
  String get stealthTimerDisplayNormal => 'Mostrar texto completo';

  @override
  String get stealthTimerDisplaySmall => 'Mostrar solo números';

  @override
  String get stealthTimerDisplayNone => 'Ocultar temporizador';

  @override
  String get stealthSessionScreen =>
      'Ocultar la marca en la pantalla de sesión';

  @override
  String get stealthPickerTitle => 'Icono de la app';

  @override
  String get stealthPickerIntro => 'Elige el aspecto del icono en el lanzador.';

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
  String get distressConfirmationTitle => '¿Estás en peligro?';

  @override
  String get distressConfirmationCancel => 'Cancelar';

  @override
  String distressConfirmationCountdown(Object seconds) {
    return 'Modo de emergencia en $seconds s';
  }

  @override
  String get imSafeSliderLabel => 'Desliza para confirmar «Estoy a salvo»';

  @override
  String get batteryAlertTitle => 'Alerta de batería';

  @override
  String get batteryAlertEnable => 'Activar alerta de batería';

  @override
  String batteryAlertThreshold(Object percent) {
    return 'Umbral: $percent %';
  }

  @override
  String get eventDefaultsTitle => 'Valores predeterminados de pasos';

  @override
  String get eventDefaultsBody =>
      'Estos valores se aplican a cualquier paso que no los anule.';

  @override
  String get gpsLoggingTitle => 'Registro GPS';

  @override
  String get gpsLoggingEnable => 'Activar registro GPS';

  @override
  String get gpsLoggingInterval => 'Intervalo de muestreo (segundos)';

  @override
  String get gpsLoggingAccuracy => 'Precisión';

  @override
  String get gpsAccuracyLow => 'Baja';

  @override
  String get gpsAccuracyMedium => 'Media';

  @override
  String get gpsAccuracyHigh => 'Alta';

  @override
  String get gpsLoggingIncludeSms => 'Adjuntar ubicación al SMS';

  @override
  String get gpsLoggingHistoryDays => 'Retención del historial (días)';

  @override
  String get notificationSettingsTitle => 'Notificaciones';

  @override
  String get notificationSettingsBody =>
      'Guardian Angela utiliza notificaciones para disfrazar y gestionar recordatorios.';

  @override
  String get historyRetentionTitle => 'Retención del historial';

  @override
  String get historyRetentionBody =>
      'Durante cuánto tiempo conserva Guardian Angela los registros de sesiones anteriores.';

  @override
  String historyRetentionDays(Object days) {
    return 'Retención: $days días';
  }

  @override
  String get backupTitle => 'Copia de seguridad';

  @override
  String get backupExport => 'Exportar datos';

  @override
  String get backupImport => 'Importar datos';

  @override
  String get backupNotReady =>
      'La copia de seguridad aún no está disponible. Próximamente.';

  @override
  String get backupPinOptional => 'PIN opcional (cifra el paquete)';

  @override
  String get backupImportOk => 'Copia de seguridad importada correctamente.';

  @override
  String get backupSelectionHeader => 'Incluir en la exportación';

  @override
  String get backupToggleSettings => 'Ajustes';

  @override
  String get backupToggleSettingsSubtitle =>
      'Siempre incluidos para que la copia se pueda restaurar.';

  @override
  String get backupToggleContacts => 'Contactos de emergencia';

  @override
  String get backupToggleModes => 'Modos';

  @override
  String get backupToggleDistressModes => 'Modos de auxilio';

  @override
  String get backupToggleTemplates => 'Plantillas de recordatorio';

  @override
  String get backupToggleSessionLogs => 'Historial de sesiones';

  @override
  String get backupToggleRecordings => 'Grabaciones de audio';

  @override
  String get historyTitle => 'Sesiones anteriores';

  @override
  String get historyEmpty => 'Aún no hay sesiones anteriores.';

  @override
  String get historyTabReal => 'Real';

  @override
  String get historyTabSimulated => 'Simulada';

  @override
  String get historySearchHint => 'Buscar por nombre de modo';

  @override
  String get historyFilterModeAll => 'Todos los modos';

  @override
  String get historyFilterModeLabel => 'Modo';

  @override
  String get historyDateRangePick => 'Rango de fechas';

  @override
  String get historyDetailTitle => 'Detalles de la sesión';

  @override
  String get evidenceExportTitle => 'Exportar evidencia';

  @override
  String get evidenceExportAsText => 'Copiar como texto';

  @override
  String get evidenceExportAsJson => 'Copiar como JSON';

  @override
  String get evidenceCopied => 'Copiado al portapapeles.';

  @override
  String get aboutTitle => 'Acerca de';

  @override
  String aboutVersion(Object version) {
    return 'Versión';
  }

  @override
  String get aboutCredits =>
      'Creada con cariño para las personas de camino a casa.';

  @override
  String get feedbackTitle => 'Comentarios';

  @override
  String get feedbackBody => 'Nos encantaría saber de ti.';

  @override
  String get feedbackFieldMessage => 'Mensaje';

  @override
  String get feedbackSend => 'Abrir correo';

  @override
  String get pickerNoneLabel => '— ninguno —';

  @override
  String emergencyConfirmTitle(Object number) {
    return 'Llamando al $number';
  }

  @override
  String get emergencyConfirmSubtitle =>
      'Mantenga pulsado el botón de cancelar para abortar.';

  @override
  String emergencyConfirmCountdown(Object seconds) {
    return 'Llamando en $seconds s';
  }

  @override
  String get emergencyConfirmCancel => 'Cancelar';

  @override
  String get stealthCalendarUpcoming => 'Próximamente';

  @override
  String get stealthCalendarUpcomingEvent => 'Reunión';

  @override
  String stealthCalendarUntilEvent(Object minutes) {
    return 'en $minutes min';
  }

  @override
  String get stealthCalendarToday => 'Hoy';

  @override
  String get stealthCalendarEvent1 => 'Café con Alex';

  @override
  String get stealthCalendarEvent2 => 'Reunión diaria';

  @override
  String get stealthCalendarEvent3 => 'Almuerzo';

  @override
  String get stealthCalendarEvent4 => 'Entrenamiento';

  @override
  String get stealthCalendarEvent5 => 'Cena con Sam';

  @override
  String get stealthDisarmGestureHint => 'Deslice hacia arriba para finalizar';

  @override
  String get stealthMusicTrackTitle => 'Pista sin título';

  @override
  String get stealthMusicArtist => 'Artista desconocido';

  @override
  String get stealthMusicAlbum => 'Álbum desconocido';

  @override
  String get stealthMusicNowPlaying => 'Reproduciendo ahora';

  @override
  String get stealthMusicSwipeHint => 'Deslice para desactivar';

  @override
  String get stealthMusicPrevious => 'Anterior';

  @override
  String get stealthMusicPause => 'Pausar';

  @override
  String get stealthMusicNext => 'Siguiente';

  @override
  String get stealthPodcastShowName => 'Pódcast';

  @override
  String get stealthPodcastEpisodeTitle => 'Episodio';

  @override
  String get stealthPodcastEpisodesHeader => 'Episodios';

  @override
  String get stealthPodcastSpeedLabel => '1x';

  @override
  String get stealthPodcastEpisode1 => 'Episodio 1';

  @override
  String get stealthPodcastEpisode2 => 'Episodio 2';

  @override
  String get stealthPodcastEpisode3 => 'Episodio 3';

  @override
  String get stealthPodcastEpisode4 => 'Episodio 4';

  @override
  String get stealthPresetPodcast => 'Pódcast';

  @override
  String get stealthPresetNone => 'Ninguno';

  @override
  String get sessionSimSpeedLabel => 'Velocidad';

  @override
  String sessionSimSpeedValue(Object value) {
    return '${value}x';
  }

  @override
  String get sessionSimSpeedBackgroundCap => 'Limitada a 60× en segundo plano';

  @override
  String get sessionSimAdvancedLabel => 'Avanzado';

  @override
  String get sessionSimTriggerPanic => 'Activar pánico';

  @override
  String get sessionSimTriggerArrival => 'Activar llegada';

  @override
  String get sessionSimTriggerBattery => 'Activar batería baja';

  @override
  String get simulateGpsArrival => 'Simular llegada';

  @override
  String get simulateLowBattery => 'Simular batería baja';

  @override
  String get launchGateTitle => 'Desbloquear Guardian Angela';

  @override
  String get launchGateSubtitle => 'Introduzca su PIN o utilice biometría.';

  @override
  String get launchGateWrong => 'PIN incorrecto';

  @override
  String get launchGateBiometricReason => 'Desbloquear Guardian Angela';

  @override
  String get launchGateUseBiometric => 'Usar biometría';

  @override
  String get audioRunningLatePhrase => 'Hola, llego tarde. Te llamo enseguida.';

  @override
  String smsDefaultTemplate(Object name, Object location, Object time) {
    return '$name podría necesitar ayuda. Ubicación: $location. Hora: $time.';
  }

  @override
  String smsDefaultPreCallTemplate(Object name) {
    return '$name está tratando de comunicarse contigo. Espera una llamada.';
  }

  @override
  String simLoudAlarm(Object tail) {
    return '[SIM] Alarma sonora + $tail';
  }

  @override
  String get simLoudAlarmTailFlash => 'destello';

  @override
  String get simLoudAlarmTailVibrate => 'vibración';

  @override
  String simSmsContact(Object channel, int count) {
    return '[SIM] Enviaría $channel a $count contactos';
  }

  @override
  String simFakeCallRing(Object caller) {
    return '[SIM] Llamada entrante de $caller';
  }

  @override
  String simCountdownWarning(int seconds) {
    return '[SIM] Advertencia de cuenta atrás de ${seconds}s';
  }

  @override
  String simPhoneCall(Object name) {
    return '[SIM] Llamaría a $name';
  }

  @override
  String get simNoContactToCall => '[SIM] Sin contacto al que llamar';

  @override
  String simCallEmergency(Object number) {
    return '[SIM] Marcaría $number';
  }

  @override
  String get simHardwareButton => '[SIM] Disparador de hardware armado';

  @override
  String get simHoldButton => '[SIM] Esperando botón mantenido';

  @override
  String simDisguisedReminder(Object title) {
    return '[SIM] Mostraría \"$title\"';
  }

  @override
  String get simDisguisedReminderEmpty =>
      '[SIM] No hay plantilla de recordatorio disponible';

  @override
  String get simGpsArrivalTrigger => '[SIM] Disparador de llegada GPS activado';

  @override
  String get simLowBatteryAlert => '[SIM] Alerta de batería baja activada';

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
