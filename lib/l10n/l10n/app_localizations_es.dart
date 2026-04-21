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
  String get commonCancel => 'Cancelar';

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
  String get homeTitle => 'Guardian Angela';

  @override
  String get homeStartSession => 'Iniciar sesión';

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
  String get modesTitle => 'Modos';

  @override
  String get modesEmpty => 'Aún no hay modos. Toca Añadir para crear un modo.';

  @override
  String get modesAdd => 'Añadir modo';

  @override
  String get modeEditorTitleCreate => 'Nuevo modo';

  @override
  String get modeEditorTitleEdit => 'Editar modo';

  @override
  String get modeFieldName => 'Nombre';

  @override
  String get modeFieldCheckInType => 'Tipo de confirmación';

  @override
  String get modeFieldDistressChain => 'Cadena de auxilio';

  @override
  String get modeFieldDistressChainDefault => 'Usar predeterminada';

  @override
  String get modeChainHeader => 'Cadena de escalada';

  @override
  String get modeChainAddStep => 'Añadir paso';

  @override
  String get modeChainEmpty => 'Aún no hay pasos. Toca Añadir paso.';

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
  String get stepFieldRetryCount => 'Reintentos';

  @override
  String get stepFieldRandomize => 'Variación del temporizador';

  @override
  String get stepPreview => 'Previsualizar en simulación';

  @override
  String stepPreviewFired(Object description) {
    return 'Previsualización ejecutada: $description';
  }

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
  String get distressChainsTitle => 'Cadenas de auxilio';

  @override
  String get distressChainsEmpty => 'Aún no hay cadenas de auxilio.';

  @override
  String get distressChainsAdd => 'Añadir cadena';

  @override
  String get distressChainEditorTitleCreate => 'Nueva cadena de auxilio';

  @override
  String get distressChainEditorTitleEdit => 'Editar cadena de auxilio';

  @override
  String get distressChainName => 'Nombre de la cadena';

  @override
  String get distressCountdown => 'Activando cadena de auxilio...';

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
  String get settingsSectionDistressChains => 'Cadenas de auxilio';

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
  String get securityTitle => 'Seguridad';

  @override
  String get securityAppPin => 'PIN de la app';

  @override
  String get securitySessionEndPin => 'PIN de fin de sesión';

  @override
  String get securityDuressPin => 'PIN de coacción';

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
    return 'Cadena de emergencia en $seconds s';
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
  String get historyTitle => 'Sesiones anteriores';

  @override
  String get historyEmpty => 'Aún no hay sesiones anteriores.';

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
  String get aboutVersion => 'Versión';

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
}
