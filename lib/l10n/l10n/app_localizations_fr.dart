// ignore: unused_import

import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Guardian Angela';

  @override
  String get commonSave => 'Enregistrer';

  @override
  String get angelaDialogTitle => 'Ancien PIN saisi';

  @override
  String get angelaDialogBody =>
      'Il semble que vous ayez utilisé un ancien PIN. Voulez-vous vraiment continuer ?';

  @override
  String get angelaDialogCancel => 'Annuler';

  @override
  String get angelaDialogConfirm => 'Continuer';

  @override
  String get commonCancel => 'Annuler';

  @override
  String get commonOk => 'OK';

  @override
  String get commonDelete => 'Supprimer';

  @override
  String get commonEdit => 'Modifier';

  @override
  String get commonClose => 'Fermer';

  @override
  String get commonConfirm => 'Confirmer';

  @override
  String get commonBack => 'Retour';

  @override
  String get pinSubmit => 'Valider';

  @override
  String get homeTitle => 'Guardian Angela';

  @override
  String get homeStartSession => 'Démarrer la session';

  @override
  String get homePermissionsNotification => 'Notifications';

  @override
  String get homePermissionsLocation => 'Position';

  @override
  String get homePermissionsCallPhone => 'Appels téléphoniques';

  @override
  String get homePermissionsSendSms => 'Envoyer un SMS';

  @override
  String get homeSimulate => 'Simuler';

  @override
  String get homeNoModes =>
      'Aucun mode pour le moment. Appuyez sur Modes pour en ajouter un.';

  @override
  String get homeContactsBannerNone => 'Aucun contact d\'urgence configuré.';

  @override
  String get homeMenuSettings => 'Paramètres';

  @override
  String get homeMenuContacts => 'Contacts';

  @override
  String get homeMenuHistory => 'Sessions passées';

  @override
  String get onboardingProfileTitle => 'Profil et premier contact';

  @override
  String get onboardingPermissionsTitle => 'Autorisations';

  @override
  String get onboardingNext => 'Suivant';

  @override
  String get onboardingSkip => 'Passer';

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
  String get sessionTitle => 'Session';

  @override
  String get sessionDisarm => 'Je suis en sécurité';

  @override
  String get sessionDisarmStealth => 'Pas besoin d’Angela';

  @override
  String get homeChainSummaryTitle => 'Résumé de la chaîne';

  @override
  String get homeChainSummaryEmpty =>
      'Ce mode n’a pas encore d’étapes – appuyez sur le mode pour le modifier.';

  @override
  String homeChainSummaryTimingTitle(Object name) {
    return 'Étape : $name';
  }

  @override
  String homeChainSummaryWait(Object seconds) {
    return 'Attente : $seconds s';
  }

  @override
  String homeChainSummaryDuration(Object seconds) {
    return 'Actif : $seconds s';
  }

  @override
  String homeChainSummaryGrace(Object seconds) {
    return 'Délai de grâce : $seconds s';
  }

  @override
  String homeChainSummaryRetry(Object count) {
    return 'Tentatives : $count';
  }

  @override
  String homeChainSummaryNextStep(Object name) {
    return 'Étape suivante : $name';
  }

  @override
  String get homeChainSummaryNextStepNone =>
      'Étape suivante : fin de la chaîne';

  @override
  String get homeChainSummaryClose => 'Fermer';

  @override
  String get chainStepNameHoldButton => 'Maintenir pour rester en sécurité';

  @override
  String get chainStepNameDisguisedReminder => 'Rappel camouflé';

  @override
  String get chainStepNameCountdownWarning =>
      'Avertissement avec compte à rebours';

  @override
  String get chainStepNameFakeCall => 'Faux appel';

  @override
  String get chainStepNameSmsContact => 'SMS à un contact';

  @override
  String get chainStepNamePhoneCallContact => 'Appel d’un contact';

  @override
  String get chainStepNameLoudAlarm => 'Alarme sonore';

  @override
  String get chainStepNameCallEmergency => 'Appel d’urgence';

  @override
  String get chainStepNameHardwareButton => 'Bouton matériel';

  @override
  String get homeChecklistTitle => 'Configuration de sécurité';

  @override
  String get homeChecklistDismissTooltip => 'Ignorer la liste';

  @override
  String get homeChecklistExpandTooltip => 'Afficher la liste';

  @override
  String get homeChecklistCollapseTooltip => 'Masquer la liste';

  @override
  String homeChecklistProgress(Object done, Object total) {
    return '$done sur $total terminés';
  }

  @override
  String get homeChecklistAllDoneBanner => 'C’est prêt – vous êtes protégée !';

  @override
  String get homeChecklistInfoTooltip => 'Pourquoi c’est important';

  @override
  String get homeChecklistGotIt => 'Compris';

  @override
  String get homeChecklistGoThere => 'Y aller';

  @override
  String get homeChecklistItem1Title => 'Ajouter un contact d’urgence';

  @override
  String get homeChecklistItem2Title => 'Définir un code PIN de fin de session';

  @override
  String get homeChecklistItem3Title => 'Configurer le mode furtif';

  @override
  String get homeChecklistItem4Title => 'Tester une simulation';

  @override
  String get homeChecklistItem5Title => 'Personnaliser un mode de sécurité';

  @override
  String get homeChecklistItem6Title => 'Accorder les autorisations requises';

  @override
  String get checklistInfo1Body =>
      'Les contacts d’urgence sont les personnes que Guardian Angela contacte par message et par appel si vous ne confirmez pas votre sécurité. Sans au moins un contact, la chaîne n’a personne vers qui escalader.';

  @override
  String get checklistInfo2Body =>
      'Un code PIN de fin de session empêche un agresseur de mettre fin discrètement à une session active. Il peut essayer, mais cinq saisies fausses déclenchent en silence votre chaîne de détresse.';

  @override
  String get checklistInfo3Body =>
      'Le mode furtif déguise la session active en quelque chose d’anodin à l’écran : un lecteur de musique, un minuteur en pause, un écran de verrouillage vide. À utiliser quand quelqu’un près de vous ne doit pas voir une appli de sécurité.';

  @override
  String get checklistInfo4Body =>
      'La simulation exécute votre mode de sécurité de bout en bout sans envoyer de vrais SMS, passer de vrais appels ni faire sonner l’alarme. Utilisez-la pour apprendre les délais avant d’en avoir besoin.';

  @override
  String get checklistInfo5Body =>
      'Les modes personnalisés vous permettent d’ajuster étapes, durées et déclencheurs à une situation précise : rentrer chez soi, un premier rendez-vous, un service de nuit. Les deux modes préinstallés sont des points de départ, pas la destination.';

  @override
  String get checklistInfo6Body =>
      'Sans autorisation de notifications, Guardian Angela ne peut pas conserver son état persistant en premier plan, livrer les rappels camouflés ou vous prévenir que la chaîne va escalader.';

  @override
  String get checklistTutorial3Body =>
      'Ouvrez les paramètres furtifs par défaut et activez « Activer le mode furtif ». De là vous pouvez choisir une fausse marque de musique, masquer le minuteur de session ou déguiser l’icône d’accueil.';

  @override
  String get checklistTutorial4Body =>
      'Appuyez sur le bouton « Simuler » contouré sur l’écran d’accueil après avoir choisi un mode. La session tourne avec une bordure orange et le badge [SIM] – rien ne quitte votre téléphone.';

  @override
  String get checklistTutorial5Body =>
      'Ouvrez l’écran Modes et modifiez un mode préinstallé (Marche / Rendez-vous) ou créez-en un de toutes pièces. Ajustez la chaîne, ajoutez un faux appel, définissez vos propres délais.';

  @override
  String get sessionHoldPrompt => 'Maintenez pour rester en sécurité';

  @override
  String sessionStepLabel(Object index, Object total) {
    return 'Étape $index sur $total';
  }

  @override
  String sessionMissCount(Object count) {
    return 'Manquées : $count';
  }

  @override
  String get sessionPausedBadge => 'En pause';

  @override
  String get sessionPhaseEnded => 'Session terminée';

  @override
  String get sessionSimulationBanner => 'Simulation';

  @override
  String get sessionCheckIn => 'Je suis en sécurité';

  @override
  String get sessionStepCountdownTitle => 'Avertissement';

  @override
  String get sessionStepCountdownBody =>
      'La prochaine escalade se déclenche à la fin du compte à rebours. Faites glisser « Je suis en sécurité » ci-dessous pour désactiver.';

  @override
  String get sessionStepDisguisedDefaultTitle => 'Rappel';

  @override
  String get sessionStepDisguisedDefaultBody =>
      'Appuyez sur « Je suis en sécurité » pour confirmer que tout va bien.';

  @override
  String get sessionStepSmsStatus => 'Envoi du message aux contacts…';

  @override
  String get sessionStepPhoneCallStatus => 'Appel du contact d\'urgence…';

  @override
  String get sessionStepLoudAlarmTitle => 'Alarme en cours';

  @override
  String get sessionStepLoudAlarmBody =>
      'L\'alarme retentit pour attirer l\'attention.';

  @override
  String get sessionStepLoudAlarmFlashWarning =>
      'Avertissement photosensibilité : l\'écran clignote.';

  @override
  String get sessionStepCallEmergencyStatus => 'Appel des services d\'urgence…';

  @override
  String sessionStepCallEmergencyNumber(Object number) {
    return 'Numéro : $number';
  }

  @override
  String sessionStepHardwareButtonRepeat(
    Object button,
    Object count,
    Object windowMs,
  ) {
    return 'Appuyez sur $button $count fois en $windowMs ms';
  }

  @override
  String sessionStepHardwareButtonLong(Object button, Object seconds) {
    return 'Maintenez $button pendant $seconds secondes';
  }

  @override
  String get sessionStepHardwareButtonVolumeUp => 'volume haut';

  @override
  String get sessionStepHardwareButtonVolumeDown => 'volume bas';

  @override
  String get sessionStepHardwareButtonPower => 'marche/arrêt';

  @override
  String get sessionCompletedTitle => 'Session terminée';

  @override
  String get sessionCompletedBody =>
      'Vous êtes arrivé(e) en sécurité. Guardian Angela se met en veille.';

  @override
  String get sessionCompletedReturnHome => 'Retour à l\'accueil';

  @override
  String get simulationSummaryTitle => 'Résumé de la simulation';

  @override
  String get simulationSummaryEmpty =>
      'Aucune étape déclenchée pendant cette simulation.';

  @override
  String get simulationSummaryReturn => 'Retour à l\'accueil';

  @override
  String get fakeCallTitle => 'Appel entrant';

  @override
  String get fakeCallHangUp => 'Raccrocher';

  @override
  String get fakeCallSlideToAnswer => 'glisser pour répondre';

  @override
  String get fakeCallUnknownCaller => 'Inconnu';

  @override
  String get fakeCallIncomingWhatsapp => 'Appel vocal WhatsApp';

  @override
  String get fakeCallIncomingTelegram => 'Appel vocal Telegram';

  @override
  String get fakeCallIncomingSignal => 'Appel vocal Signal';

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
  String get contactsTitle => 'Contacts d\'urgence';

  @override
  String get contactsEmpty =>
      'Aucun contact pour le moment. Ajoutez-en un pour recevoir vos messages de détresse.';

  @override
  String get contactsAdd => 'Ajouter un contact';

  @override
  String get contactFormTitleCreate => 'Nouveau contact';

  @override
  String get contactFormTitleEdit => 'Modifier le contact';

  @override
  String get contactFieldName => 'Nom';

  @override
  String get contactFieldPhone => 'Numéro de téléphone';

  @override
  String get contactFieldRelationship => 'Relation (facultatif)';

  @override
  String get contactFieldLanguage => 'Langue des SMS (facultatif)';

  @override
  String get contactLanguageDefault => 'Par défaut (langue de l\'application)';

  @override
  String get contactChannelsHeader => 'Canaux de messagerie';

  @override
  String get contactChannelSms => 'SMS';

  @override
  String get contactChannelWhatsapp => 'WhatsApp';

  @override
  String get contactChannelTelegram => 'Telegram';

  @override
  String get contactChannelPhone => 'Appel téléphonique';

  @override
  String get contactDeleteConfirm => 'Supprimer le contact ?';

  @override
  String contactDeleteBody(Object name) {
    return '$name sera retiré de votre liste d\'urgence.';
  }

  @override
  String get contactFormIosSmsWarning =>
      'On iOS, SMS opens the Messages app. You must tap Send manually.';

  @override
  String get modesTitle => 'Modes';

  @override
  String get modesEmpty =>
      'Aucun mode pour le moment. Appuyez sur Ajouter pour créer un mode.';

  @override
  String get modesAdd => 'Ajouter un mode';

  @override
  String get modesNewPickerBlank => 'Mode vierge';

  @override
  String get modesNewPickerBlankSubtitle => 'Commencer avec une chaîne vide';

  @override
  String modesNewPickerFromTemplate(String name) {
    return 'À partir de $name';
  }

  @override
  String get modesNewPickerFromTemplateSubtitle =>
      'Copier la chaîne et les déclencheurs de ce mode';

  @override
  String get modeEditorTitleCreate => 'Nouveau mode';

  @override
  String get modeEditorTitleEdit => 'Modifier le mode';

  @override
  String get modeFieldName => 'Nom';

  @override
  String get modeChainHeader => 'Chaîne';

  @override
  String get modeChainAddStep => 'Ajouter une étape';

  @override
  String get modeUnsavedTitle => 'Annuler les modifications ?';

  @override
  String get modeUnsavedBody =>
      'Vous avez des modifications non enregistrées. Les annuler et quitter l\'éditeur ?';

  @override
  String get modeUnsavedDiscard => 'Annuler';

  @override
  String get modeUnsavedKeep => 'Continuer';

  @override
  String stepTimingSummary(Object wait, Object duration, Object grace) {
    return 'attente ${wait}s / durée ${duration}s / délai ${grace}s';
  }

  @override
  String get distressModesEmpty => 'Aucun mode de détresse pour le moment.';

  @override
  String get distressModeEditorTitleCreate => 'Nouveau mode de détresse';

  @override
  String get distressModeEditorTitleEdit => 'Modifier le mode de détresse';

  @override
  String get templatesTitle => 'Modèles de rappel';

  @override
  String get templatesEmpty => 'Aucun modèle pour le moment.';

  @override
  String get profileTitle => 'Profil';

  @override
  String get profileFieldName => 'Nom';

  @override
  String get profileFieldAge => 'Âge';

  @override
  String get profileFieldBloodType => 'Groupe sanguin';

  @override
  String get profileFieldAllergies => 'Allergies';

  @override
  String get profileFieldMedications => 'Médicaments';

  @override
  String get settingsThemeLight => 'Clair';

  @override
  String get settingsThemeDark => 'Sombre';

  @override
  String get settingsThemeSystem => 'Système';

  @override
  String get settingsEmergencyNumberLabel => 'Numéro d\'urgence';

  @override
  String get settingsRedoOnboardingActiveSessionTooltip =>
      'Cannot redo onboarding during an active session';

  @override
  String get settingsEmergencyNumberCountryPickerTitle =>
      'Choose emergency number';

  @override
  String get settingsRedoOnboarding => 'Refaire l\'introduction';

  @override
  String get settingsRedoOnboardingConfirm => 'Redémarrer l\'introduction ?';

  @override
  String get securitySessionEndPinBiometric =>
      'Utiliser la biométrie pour le PIN de fin de session';

  @override
  String get securityAppPinBiometric =>
      'Utiliser la biométrie pour le verrouillage de l’application';

  @override
  String get launchPinTitle => 'Saisissez le PIN de l’application';

  @override
  String get launchPinBiometricReason => 'Déverrouiller Guardian Angela';

  @override
  String get launchPinIncorrect => 'PIN incorrect';

  @override
  String get securitySetPin => 'Définir le PIN';

  @override
  String get securityChangePin => 'Modifier le PIN';

  @override
  String get pinSetupMismatch =>
      'Les codes PIN ne correspondent pas. Réessayez.';

  @override
  String get stealthTimerDisplayNormal => 'Afficher le texte complet';

  @override
  String get stealthTimerDisplaySmall => 'Afficher uniquement les chiffres';

  @override
  String get stealthTimerDisplayNone => 'Masquer le minuteur';

  @override
  String get stealthPresetMusic => 'Musique';

  @override
  String get stealthPresetCalendar => 'Calendrier';

  @override
  String get stealthPresetFitness => 'Fitness';

  @override
  String get stealthPresetWeather => 'Météo';

  @override
  String get stealthPresetNews => 'Actualités';

  @override
  String get stealthPresetPhotos => 'Photos';

  @override
  String get stealthPresetNotes => 'Notes';

  @override
  String get stealthPresetClock => 'Horloge';

  @override
  String get batteryAlertTitle => 'Alerte batterie';

  @override
  String get eventDefaultsTitle => 'Valeurs par défaut des étapes';

  @override
  String get historyRetentionTitle => 'Conservation de l\'historique';

  @override
  String get backupTitle => 'Sauvegarde';

  @override
  String get aboutTitle => 'À propos';

  @override
  String aboutVersion(Object version) {
    return 'Version';
  }

  @override
  String get feedbackTitle => 'Commentaires';

  @override
  String get feedbackSend => 'Ouvrir l\'e-mail';

  @override
  String get stealthPresetPodcast => 'Podcast';

  @override
  String get stealthPresetNone => 'Aucun';

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
  String get securityRemovePinPrompt =>
      'Saisissez votre PIN actuel pour le supprimer.';

  @override
  String get securityRemovePinIncorrect => 'PIN incorrect';

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
