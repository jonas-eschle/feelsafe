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
  String get contactFormIosSmsWarning =>
      'On iOS, SMS opens the Messages app. You must tap Send manually.';

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
      'Cannot redo onboarding during an active session';

  @override
  String get settingsEmergencyNumberCountryPickerTitle =>
      'Choose emergency number';

  @override
  String get settingsRedoOnboarding => 'Repetir introducción';

  @override
  String get settingsRedoOnboardingConfirm => '¿Reiniciar introducción?';

  @override
  String get securitySessionEndPinBiometric =>
      'Usar biometría para el PIN de fin de sesión';

  @override
  String get securityAppPinBiometric => 'Use biometrics for App lock';

  @override
  String get launchPinTitle => 'Enter your App PIN';

  @override
  String get launchPinBiometricReason => 'Unlock Guardian Angela';

  @override
  String get launchPinIncorrect => 'Incorrect PIN';

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
  String get batteryAlertTitle => 'Alerta de batería';

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
  String get securityRemovePinPrompt => 'Enter your current PIN to remove it.';

  @override
  String get securityRemovePinIncorrect => 'Incorrect PIN';

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
