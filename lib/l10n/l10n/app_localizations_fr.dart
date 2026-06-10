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
  String get commonGotIt => 'Compris';

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
  String get onboardingUseSimNumber => 'Utiliser mon numéro de SIM';

  @override
  String onboardingUseSimNumberHint(Object number) {
    return 'Utilisation du numéro de SIM $number';
  }

  @override
  String get onboardingUseSimNumberUnsupported => 'Non disponible sur iOS';

  @override
  String get onboardingUseSimNumberUnavailable =>
      'Impossible de lire le numéro';

  @override
  String get onboardingUseSimNumberPermissionDenied => 'Autorisation refusée';

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
  String get sessionPausedIncomingCall => 'En pause — appel entrant';

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
  String get sessionReminderEarlyCheckInHint =>
      'Appuyer pour s\'enregistrer maintenant';

  @override
  String get sessionReminderDefaultButton => 'OK';

  @override
  String get sessionReminderTapWordHint => 'Appuyer pour continuer';

  @override
  String get sessionReminderDecoyWords =>
      'PLUS TARD,IGNORER,TERMINÉ,OUVRIR,VOIR,OK,SUIVANT,PLUS,RAPPELER,FERMER';

  @override
  String get sessionReminderSwipeLabel => 'Glisser pour fermer';

  @override
  String get sessionReminderDismissLabel => 'Fermer';

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
  String get sessionStealthNowPlaying => 'Lecture en cours';

  @override
  String get sessionServiceTitle => 'Guardian Angela est actif';

  @override
  String get sessionServiceBody => 'Votre session de sécurité est en cours.';

  @override
  String get sessionServiceStealthBody => 'Lecture en cours';

  @override
  String get sessionStealthTrackTitle => 'Titre sans nom';

  @override
  String get sessionStealthArtistName => 'Artiste inconnu';

  @override
  String get sessionStealthAlbumArtLabel => 'Pochette d’album';

  @override
  String get sessionStealthPlay => 'Lecture';

  @override
  String get sessionStealthPause => 'Pause';

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
  String get fakeCallBrandAndroid => 'TÉLÉPHONE';

  @override
  String get fakeCallBrandIos => 'TÉLÉPHONE';

  @override
  String get fakeCallBrandMinimal => 'APPEL';

  @override
  String get fakeCallDeclineSafeLabel => 'Refuser (je suis en sécurité)';

  @override
  String get fakeCallDeclineUnsafeLabel => 'Refuser (rester en alerte)';

  @override
  String get fakeCallHoldForDistress => 'Maintenez 5 s pour la détresse';

  @override
  String fakeCallVoicePrompt(String name) {
    return 'Invite vocale : $name';
  }

  @override
  String fakeCallVibrationLabel(String pattern) {
    return 'Vibration : $pattern';
  }

  @override
  String get fakeCallVibrationPatternDefault => 'par défaut';

  @override
  String get fakeCallSlideToAnswerHint => 'Glisser pour répondre';

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
      'Sur iOS, les SMS ouvrent l\'application Messages. Vous devez appuyer sur Envoyer manuellement.';

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
  String get stepConfigTimingHeader => 'Minutage';

  @override
  String get stepConfigEventHeader => 'Configuration de l\'événement';

  @override
  String get stepConfigAdvancedHeader => 'Nouvelles tentatives et avancé';

  @override
  String get stepFieldWait => 'Attente avant déclenchement (secondes)';

  @override
  String get stepFieldDuration => 'Durée active (secondes)';

  @override
  String get stepFieldGrace => 'Délai de grâce (secondes)';

  @override
  String get stepFieldRetryCount => 'Tentatives';

  @override
  String get stepFieldRandomize => 'Rendre le minutage aléatoire (±20%)';

  @override
  String get stepDuplicate => 'Dupliquer l\'étape';

  @override
  String get stepResetDefaults => 'Réinitialiser aux valeurs par défaut';

  @override
  String get smsContactRecipientsHeader => 'Contacts à prévenir';

  @override
  String get smsContactSummaryAll => 'À : tous les contacts activés';

  @override
  String get smsContactSummaryNone => 'Aucun destinataire sélectionné';

  @override
  String smsContactSummaryTo(Object names) {
    return 'À : $names';
  }

  @override
  String get smsContactChannelDisabledTooltip =>
      'Non activé pour ce contact — modifiez le contact pour ajouter ce canal.';

  @override
  String get smsContactEmptyAddPrompt =>
      'Aucun contact pour le moment — ajoutez-en un dans Contacts';

  @override
  String get safetyOptionsHeader => 'Options de sécurité';

  @override
  String get safetyOptionsDistressModeTitle => 'Mode de détresse';

  @override
  String get safetyOptionsDistressModeUseDefault =>
      'Utiliser le mode de détresse par défaut';

  @override
  String safetyOptionsDistressModeUseDefaultNamed(Object name) {
    return 'Utiliser le mode par défaut ($name)';
  }

  @override
  String get safetyOptionsDistressModeInfo =>
      'Lorsqu’un déclencheur de détresse s’active (PIN de contrainte, panique matérielle ou trop d’erreurs de PIN), la chaîne de ce mode est remplacée par celle du mode de détresse choisi. Laissez « par défaut » pour utiliser le mode de détresse global de l’application.';

  @override
  String get safetyOptionsManageDistressModes => 'Gérer les modes de détresse';

  @override
  String get safetyOptionsDistressTriggersTitle => 'Déclencheurs de détresse';

  @override
  String get safetyOptionsDistressTriggersInfo =>
      'Les déclencheurs de détresse lancent la chaîne de détresse immédiatement, en parallèle de la chaîne principale. Le bouton de panique matériel surveille un bouton physique selon le motif d’appui configuré.';

  @override
  String get safetyOptionsDistressTriggersEmpty =>
      'Aucun déclencheur de détresse';

  @override
  String get safetyOptionsAddHardwarePanic =>
      'Ajouter un bouton de panique matériel';

  @override
  String safetyOptionsTriggerHardwareRepeat(Object button, Object count) {
    return '$button : $count× appui';
  }

  @override
  String safetyOptionsTriggerHardwareLong(Object button, Object seconds) {
    return '$button : maintenir ${seconds}s';
  }

  @override
  String get safetyOptionsButtonVolumeUp => 'Volume +';

  @override
  String get safetyOptionsButtonVolumeDown => 'Volume −';

  @override
  String get safetyOptionsTriggerPattern => 'Motif d’appui';

  @override
  String get safetyOptionsPatternRepeat => 'Appuis répétés';

  @override
  String get safetyOptionsPatternLong => 'Appui long';

  @override
  String get safetyOptionsTriggerButton => 'Bouton';

  @override
  String get safetyOptionsTriggerPressCount => 'Nombre d’appuis';

  @override
  String get safetyOptionsTriggerHoldDuration => 'Durée de maintien (secondes)';

  @override
  String get safetyOptionsDisarmTriggersTitle => 'Déclencheurs de désarmement';

  @override
  String get safetyOptionsGpsArrivalTitle => 'Désarmement à l’arrivée GPS';

  @override
  String get safetyOptionsGpsArrivalInfo =>
      'La session se termine automatiquement lorsque vous arrivez dans le rayon configuré de votre destination. Vous définissez la destination au démarrage d’une session.';

  @override
  String get safetyOptionsGpsArrivalRadius => 'Rayon d’arrivée';

  @override
  String safetyOptionsRadiusMeters(Object meters) {
    return '$meters m';
  }

  @override
  String safetyOptionsRadiusKilometers(Object km) {
    return '$km km';
  }

  @override
  String get safetyOptionsDestinationSource => 'Destination';

  @override
  String get safetyOptionsDestinationPrompt =>
      'Définir la destination au démarrage de la session';

  @override
  String get safetyOptionsDestinationFixed => 'Coordonnées fixes';

  @override
  String get safetyOptionsLatitude => 'Latitude';

  @override
  String get safetyOptionsLongitude => 'Longitude';

  @override
  String get safetyOptionsTimerDisarmTitle => 'Désarmement par minuteur';

  @override
  String get safetyOptionsTimerDisarmInfo =>
      'La session se termine automatiquement après la durée configurée, que l’escalade ait commencé ou non.';

  @override
  String get safetyOptionsTimerDuration => 'Durée';

  @override
  String safetyOptionsDurationMinutes(Object minutes) {
    return '$minutes min';
  }

  @override
  String safetyOptionsDurationHoursMinutes(Object hours, Object minutes) {
    return '$hours h $minutes min';
  }

  @override
  String get safetyOptionsGpsLoggingTitle => 'Journalisation GPS';

  @override
  String get safetyOptionsGpsLoggingInfo =>
      'Choisissez si ce mode enregistre votre position pendant une session. « Hériter » utilise vos réglages GPS globaux ; « Personnalisé » les remplace pour ce mode ; « Désactivé » désactive entièrement la journalisation.';

  @override
  String get safetyOptionsStealthTitle => 'Mode furtif';

  @override
  String get safetyOptionsStealthInfo =>
      'Choisissez si ce mode déguise l’application pendant une session. « Hériter » utilise vos réglages furtifs globaux ; « Personnalisé » les remplace pour ce mode ; « Désactivé » désactive entièrement le mode furtif.';

  @override
  String get safetyOptionsTriStateInherit => 'Hériter';

  @override
  String get safetyOptionsTriStateCustom => 'Personnalisé';

  @override
  String get safetyOptionsTriStateOff => 'Désactivé';

  @override
  String get safetyOptionsLocalTemplatesTitle => 'Modèles locaux';

  @override
  String get safetyOptionsLocalTemplatesInfo =>
      'Les modèles locaux sont ajoutés au pool global de modèles de rappel pour ce mode uniquement. Utilisez-les pour des étapes de rappel déguisé propres à ce mode.';

  @override
  String get safetyOptionsLocalTemplatesEmpty => 'Aucun modèle local';

  @override
  String get safetyOptionsAddTemplate => 'Ajouter un modèle';

  @override
  String get safetyOptionsManageTemplates => 'Gérer les modèles de rappel';

  @override
  String get safetyOptionsEventDefaultsTitle =>
      'Valeurs par défaut des événements';

  @override
  String get safetyOptionsEventDefaultsInfo =>
      'Les valeurs par défaut des événements définissent la configuration initiale de chaque type d’étape. « Hériter » utilise vos valeurs globales ; « Personnalisé » les remplace pour les étapes de ce mode sans configuration propre.';

  @override
  String get safetyOptionsEventDefaultsTwoStateInherit => 'Hériter';

  @override
  String get safetyOptionsAllowDisarmAsDistressTitle =>
      'Autoriser le désarmement pendant la détresse active';

  @override
  String get safetyOptionsAllowDisarmAsDistressInfo =>
      'Activé, vous pouvez arrêter l’alerte en atteignant un lieu sûr ou en laissant un minuteur expirer. Désactivé, seule la fin de la chaîne ou la fermeture de l’application arrête l’alerte — plus résistant à la contrainte.';

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
      'Impossible de refaire l\'introduction pendant une session active';

  @override
  String get settingsEmergencyNumberCountryPickerTitle =>
      'Choisir le numéro d\'urgence';

  @override
  String get settingsEmergencyNumberEditTitle => 'Numéro d\'urgence';

  @override
  String get settingsEmergencyNumberFieldLabel => 'Numéro à composer';

  @override
  String get settingsEmergencyNumberPresetsLabel => 'Numéros courants';

  @override
  String get phoneWarnInvalidChars =>
      'Seuls les chiffres, +, * et # sont autorisés.';

  @override
  String get phoneWarnTooShort =>
      'Les numéros d\'urgence comportent généralement au moins 3 chiffres.';

  @override
  String get phoneWarnLooksLikeRegular =>
      'Cela ressemble à un numéro de téléphone ordinaire, pas à un numéro d\'urgence.';

  @override
  String get phoneWarnEmergencyEmpty =>
      'Saisissez un numéro : ce champ ne peut pas être vide.';

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
  String get securityDistressCancelBiometric =>
      'Utiliser la biométrie pour annuler la détresse';

  @override
  String get launchPinTitle => 'Saisissez le PIN de l’application';

  @override
  String get launchPinBiometricReason => 'Déverrouiller Guardian Angela';

  @override
  String get sessionEndBiometricReason => 'Confirmez pour terminer la session';

  @override
  String get distressCancelBiometricReason =>
      'Confirmez votre identité pour annuler';

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
  String get stealthLockTaskLabel =>
      'Épingler l\'application pendant la session';

  @override
  String get stealthLockTaskSubtitle =>
      'Empêche de quitter l\'application pendant qu\'une session est en cours. Sur Android, cela active l\'épinglage de l\'écran ; sur les autres plateformes, cela n\'a aucun effet.';

  @override
  String get stealthLockTaskInfo =>
      'Épingle Guardian Angela à l\'écran pendant toute la session afin qu\'on ne puisse pas la balayer pour la fermer ni changer d\'application. Compromis : Android affiche un bandeau système \"Application épinglée\" et bloque le changement d\'application jusqu\'à la fin de la session — visible par quiconque regarde l\'écran. Laissez ceci désactivé si vous préférez passer librement d\'une application à l\'autre pendant une session. Sans effet sur les plateformes sans épinglage d\'écran.';

  @override
  String get homeTagline => 'Votre ange veille sur vous.';

  @override
  String get onboardingWelcomeGreeting => 'Bonjour, je suis Angela';

  @override
  String get onboardingWelcomeBodyFull =>
      'Je suis votre gardienne personnelle. Je marche avec vous, veille sur votre soirée et passe à l\'action si quelque chose ne va pas.';

  @override
  String get onboardingGetStarted => 'Commencer';

  @override
  String get onboardingProfileNameLabel => 'Nom';

  @override
  String get onboardingProfilePhoneLabel => 'Numéro de téléphone';

  @override
  String get onboardingProfilePhoneHelper =>
      'Inclus dans les messages d\'urgence.';

  @override
  String get onboardingEmergencyContactHeader => 'Contact d\'urgence';

  @override
  String get onboardingEmergencyContactPrompt =>
      'Qui devons-nous contacter si quelque chose ne va pas ?';

  @override
  String get onboardingEmergencyContactAdd => 'Ajouter un contact d\'urgence';

  @override
  String get onboardingPermissionsIntro =>
      'Ces autorisations assurent votre sécurité pendant les sessions.';

  @override
  String get onboardingPermissionsGrantAll => 'Tout accorder';

  @override
  String get onboardingPermissionsRequired => 'REQUIS';

  @override
  String get onboardingPermissionsOptional => 'FACULTATIF';

  @override
  String get onboardingPermissionsMicrophone => 'Microphone';

  @override
  String get onboardingPermissionsCamera => 'Appareil photo';

  @override
  String get onboardingPermissionsNotificationDesc =>
      'Requis pour les alertes de session et les rappels.';

  @override
  String get onboardingPermissionsSmsDesc =>
      'Requis pour envoyer des alertes d\'urgence par SMS.';

  @override
  String get onboardingPermissionsPhoneDesc =>
      'Requis pour passer des appels d\'urgence et de faux appels.';

  @override
  String get onboardingPermissionsLocationDesc =>
      'Inclus dans les messages d\'urgence lorsque la journalisation GPS est activée.';

  @override
  String get onboardingPermissionsMicrophoneDesc =>
      'Utilisé pour l\'enregistrement audio en cas de détresse.';

  @override
  String get onboardingPermissionsCameraDesc =>
      'Utilisé pour les signaux SOS au flash.';

  @override
  String get sessionInterruptedTitle => 'Session interrompue';

  @override
  String get sessionInterruptedBody =>
      'Une session était en cours lorsque l\'application s\'est arrêtée. L\'état de la session est perdu — rien n\'a été restauré. Nous vous l\'indiquons pour que vous le sachiez.';

  @override
  String get sessionInterruptedAcknowledge => 'J\'ai compris';

  @override
  String sessionInterruptedMode(Object name) {
    return 'Mode : $name';
  }

  @override
  String sessionInterruptedStarted(Object time) {
    return 'Démarrée : $time';
  }

  @override
  String get sessionInterruptedStartSameMode => 'Démarrer le même mode';

  @override
  String get sessionInterruptedJustNow => 'à l’instant';

  @override
  String sessionInterruptedMinutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'il y a $count minutes',
      one: 'il y a 1 minute',
    );
    return '$_temp0';
  }

  @override
  String sessionInterruptedHoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'il y a $count heures',
      one: 'il y a 1 heure',
    );
    return '$_temp0';
  }

  @override
  String sessionInterruptedDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'il y a $count jours',
      one: 'il y a 1 jour',
    );
    return '$_temp0';
  }

  @override
  String get sessionGpsDestinationTitle => 'Destination';

  @override
  String get sessionGpsDestinationBody =>
      'Saisissez les coordonnées de destination pour le déclencheur de désactivation à l\'arrivée GPS.';

  @override
  String get sessionGpsDestinationLat => 'Latitude';

  @override
  String get sessionGpsDestinationLng => 'Longitude';

  @override
  String get sessionGpsDestinationSkip => 'Passer pour cette session';

  @override
  String get sessionGpsDestinationConfirm => 'Utiliser la destination';

  @override
  String get sessionEndOverlayTitle => 'Mettre fin à la session ?';

  @override
  String get sessionEndOverlayBody =>
      'Faites glisser pour confirmer que vous voulez mettre fin à la session';

  @override
  String get sessionEndOverlaySwipeLabel => 'Glisser pour terminer';

  @override
  String get sessionEndOverlaySimBadge => '[SIM] Mode entraînement';

  @override
  String get sessionEndPinPromptTitle => 'Saisissez le PIN de fin de session';

  @override
  String get sessionEndPinAppPinMismatch =>
      'Utilisez le PIN de fin de session, pas le PIN de verrouillage de l\'application.';

  @override
  String get sessionEndPinIncorrect => 'PIN incorrect';

  @override
  String get sessionEndPinSimSkip => 'Passer (sim. uniquement)';

  @override
  String get sessionEndSimDistressWouldFire =>
      'La chaîne de détresse se déclencherait (5 PIN erronés)';

  @override
  String get distressConfirmTitle => 'Détresse activée';

  @override
  String distressConfirmCountdown(int seconds) {
    return 'Appuyez pour annuler — il vous reste $seconds secondes';
  }

  @override
  String get distressConfirmCancel => 'Appuyez pour annuler';

  @override
  String get distressConfirmFooter =>
      'Si elle n\'est pas annulée, la chaîne de détresse démarrera immédiatement.';

  @override
  String get distressCancelPinPromptTitle =>
      'Saisissez le PIN de fin de session';

  @override
  String distressCancelPinTimeoutLabel(int seconds) {
    return '$seconds s restantes';
  }

  @override
  String get distressCancelPinIncorrect => 'PIN incorrect';

  @override
  String get distressCancelPinAppPinMismatch =>
      'Utilisez le PIN de fin de session, pas le PIN de verrouillage de l\'application.';

  @override
  String get distressCancelPinSimSkip => 'Passer (sim. uniquement)';

  @override
  String get distressCancelSimDistressWouldFire =>
      'La chaîne de détresse se déclencherait (5 PIN erronés)';

  @override
  String get distressCancelPinBack => 'Annuler';

  @override
  String get simulationPinPromptTitle => 'Saisissez le PIN';

  @override
  String get simulationPinPromptBody =>
      'Entraînez-vous à saisir votre PIN de fin de session';

  @override
  String get simulationPinPromptSkip => 'Passer';

  @override
  String get simulationPinIncorrect => 'PIN incorrect';

  @override
  String simulationSummaryDuration(String duration) {
    return 'Durée : $duration';
  }

  @override
  String get simulationSummaryTimelineHeader => 'Chronologie des événements';

  @override
  String get simulationSummaryShare => 'Partager';

  @override
  String simulationSummaryMissedEventsBadge(int count) {
    return 'Manqués : $count';
  }

  @override
  String simulationSummaryDistressBadge(int count) {
    return 'Détresse : $count';
  }

  @override
  String simulationSummaryStepsFiredBadge(int count) {
    return 'Étapes déclenchées : $count';
  }

  @override
  String get simulationSummaryShareSubject =>
      'Résumé de la simulation Guardian Angela';

  @override
  String get notificationsChannelAlarm => 'Escalade d\'alarme';

  @override
  String get notificationsChannelAlarmDescription =>
      'Alertes critiques qui contournent le mode Ne pas déranger';

  @override
  String get notificationsChannelReminder => 'Rappel camouflé';

  @override
  String get notificationsChannelReminderDescription =>
      'Rappels de pointage pendant une session active';

  @override
  String get notificationsChannelFakeCall => 'Faux appel';

  @override
  String get notificationsChannelFakeCallDescription =>
      'Notifications d\'appel entrant en plein écran';

  @override
  String get notificationsChannelEnabled => 'Activé';

  @override
  String get notificationsChannelDisabled => 'Désactivé';

  @override
  String get notificationsChannelsHeader => 'Canaux de notification';

  @override
  String get contactsImportFromDevice => 'Importer depuis les contacts';

  @override
  String get contactsImportNotSupported =>
      'Non disponible sur cette plateforme';

  @override
  String get contactsImportPermissionDenied =>
      'Accès aux contacts refusé. Activez-le dans les paramètres système.';

  @override
  String get contactsDeleteAllMenu => 'Tout supprimer';

  @override
  String get contactsDeleteAllConfirmTitle => 'Supprimer tous les contacts ?';

  @override
  String get contactsDeleteAllConfirmBody =>
      'Cela supprime tous les contacts d\'urgence. Aucune annulation possible.';

  @override
  String get contactsDeleteAllTypeConfirmTitle => 'Confirmer en saisissant';

  @override
  String get contactsDeleteAllTypeConfirmHint =>
      'Saisissez TOUT SUPPRIMER pour continuer';

  @override
  String get contactsDeleteAllTypeConfirmSentinel => 'TOUT SUPPRIMER';

  @override
  String get contactsDeleteAllConfirmButton => 'Tout supprimer';

  @override
  String get modesBuiltinBadge => 'Préinstallé';

  @override
  String get modesBuiltinNoDelete =>
      'Les modes préinstallés ne peuvent pas être supprimés';

  @override
  String get sessionCompletedSimulationBanner => 'Simulation terminée';

  @override
  String get sessionCompletedViewEventLog => 'Voir le journal des événements';

  @override
  String get sessionCompletedFeedbackPrompt =>
      'Comment s\'est passée votre expérience ?';

  @override
  String get sessionCompletedFeedbackSend => 'Envoyer des commentaires';

  @override
  String get sessionCompletedFeedbackSkip => 'Passer';

  @override
  String get settingsGeneralHeader => 'Général';

  @override
  String get settingsAppHeader => 'Application';

  @override
  String get settingsConfigurationHeader => 'Configuration';

  @override
  String get settingsThemeLabel => 'Thème';

  @override
  String get settingsLanguageLabel => 'Langue';

  @override
  String get settingsSecurityRow => 'Sécurité';

  @override
  String get settingsSecuritySubtitle =>
      'PIN de l\'application, PIN de fin de session, PIN de contrainte';

  @override
  String get settingsStealthRow => 'Mode furtif';

  @override
  String get settingsStealthSummaryOff => 'Mode furtif : DÉSACTIVÉ';

  @override
  String get settingsStealthSummaryOn => 'Mode furtif : ACTIVÉ';

  @override
  String get settingsProfileRow => 'Profil';

  @override
  String get settingsModesRow => 'Modes';

  @override
  String get settingsDistressModesRow => 'Modes de détresse';

  @override
  String get settingsEventDefaultsRow => 'Valeurs par défaut des étapes';

  @override
  String get settingsGpsLoggingRow => 'Journalisation GPS';

  @override
  String get settingsRemindersRow => 'Modèles de rappel';

  @override
  String get settingsNotificationsRow => 'Notifications';

  @override
  String get settingsHistoryRetentionRow => 'Historique et conservation';

  @override
  String get settingsAboutRow => 'À propos';

  @override
  String get settingsFeedbackRow => 'Envoyer des commentaires';

  @override
  String get settingsBackupRow => 'Sauvegarde et restauration';

  @override
  String get settingsOssLicenses => 'Licences open source';

  @override
  String get settingsImportConfirmBody =>
      'Cela écrasera toutes les données actuelles. Continuer ?';

  @override
  String get securityAppPinTitle => 'PIN de l\'application';

  @override
  String get securityAppPinBody =>
      'Verrouille l\'application chaque fois que vous l\'ouvrez.';

  @override
  String get securitySessionEndPinTitle => 'PIN de fin de session';

  @override
  String get securitySessionEndPinBody =>
      'Requis pour désactiver ou mettre fin à une session en cours.';

  @override
  String get securityDuressPinTitle => 'PIN de contrainte';

  @override
  String get securityDuressPinBody =>
      'Saisi à n\'importe quelle invite pour déclencher silencieusement la chaîne de détresse.';

  @override
  String get securityRemovePin => 'Supprimer';

  @override
  String get securityRemovePinPrompt =>
      'Saisissez votre PIN actuel pour le supprimer.';

  @override
  String get securityRemovePinIncorrect => 'PIN incorrect';

  @override
  String get securityWhatIsThis => 'Qu\'est-ce que c\'est ?';

  @override
  String get securityAppPinInfo =>
      'Verrouille l\'application quand vous l\'ouvrez. Le clavier apparaît avant tout écran. Utile si quelqu\'un manipule brièvement votre téléphone déverrouillé.';

  @override
  String get securitySessionEndPinInfo =>
      'Requis pour désactiver ou mettre fin à une session de sécurité en cours. Sans lui, un agresseur qui s\'empare de votre téléphone ne peut pas arrêter la chaîne. Définissez un code différent de votre PIN de l\'application.';

  @override
  String get securityDuressPinInfo =>
      'Si vous saisissez un jour ce PIN à n\'importe quelle invite, la chaîne de détresse s\'exécute en silence — vos contacts sont alertés et l\'alarme s\'arme sans que l\'agresseur s\'en aperçoive. Choisissez un code différent de tous les autres PIN.';

  @override
  String get securityPinTimeoutLabel => 'Délai d\'expiration du PIN (secondes)';

  @override
  String get securityWrongPinThresholdLabel =>
      'Saisies de PIN erronées avant escalade';

  @override
  String get securityDeceptiveDialogToggle =>
      'Afficher une boîte de dialogue trompeuse en cas de PIN erroné';

  @override
  String get pinSetupEnterNew => 'Saisissez le nouveau PIN';

  @override
  String get pinSetupConfirmNew => 'Confirmez le nouveau PIN';

  @override
  String get pinSetupTooShort => 'Le PIN doit comporter au moins 4 chiffres.';

  @override
  String get pinSetupCollision =>
      'Ce PIN est en conflit avec un autre PIN configuré.';

  @override
  String get pinSetupSaved => 'PIN enregistré';

  @override
  String get stealthEnabledLabel => 'Activer le mode furtif';

  @override
  String get stealthFakeNameLabel => 'Faux nom d\'application';

  @override
  String get stealthFakeIconLabel => 'Fausse icône';

  @override
  String get stealthNotificationDisguiseLabel => 'Camouflage des notifications';

  @override
  String get stealthTimerDisplayLabel => 'Affichage du minuteur';

  @override
  String get stealthSessionScreenLabel => 'Mode furtif sur l\'écran de session';

  @override
  String get gpsLoggingEnabled => 'Journaliser le GPS pendant les sessions';

  @override
  String get gpsLoggingIntervalLabel => 'Intervalle';

  @override
  String get gpsLoggingAccuracyLabel => 'Précision';

  @override
  String get gpsLoggingAccuracyHigh => 'Élevée';

  @override
  String get gpsLoggingAccuracyBalanced => 'Équilibrée';

  @override
  String get gpsLoggingAccuracyLow => 'Faible';

  @override
  String get gpsLoggingFormatLabel => 'Format des coordonnées';

  @override
  String get gpsLoggingFormatDecimal => 'Décimal';

  @override
  String get gpsLoggingFormatDms => 'DMS';

  @override
  String get gpsLoggingFormatAddress => 'Plus Code';

  @override
  String get gpsLoggingIncludeInSms => 'Ajouter la position aux SMS';

  @override
  String get historyRetentionLogsLabel =>
      'Conservation des journaux de session (jours)';

  @override
  String get historyRetentionLogsHelper =>
      'Les journaux plus anciens sont déplacés vers la corbeille.';

  @override
  String get historyRetentionTrashLabel =>
      'Conservation dans la corbeille (jours)';

  @override
  String get historyRetentionTrashHelper =>
      'Les journaux mis à la corbeille sont définitivement supprimés après ce délai.';

  @override
  String get historyRetentionUpdated => 'Conservation mise à jour';

  @override
  String get historyRetentionPurgeNow => 'Purger maintenant';

  @override
  String historyRetentionPurged(Object count) {
    return '$count journaux purgés';
  }

  @override
  String get eventDefaultsCheckInHeader => 'Méthodes de pointage';

  @override
  String get eventDefaultsEscalationHeader => 'Étapes d\'escalade';

  @override
  String get eventDefaultsPanicHeader => 'Déclencheur de panique';

  @override
  String get templatesCreate => 'Créer un modèle';

  @override
  String get templatesEditTitle => 'Modifier le modèle';

  @override
  String get templatesCreateTitle => 'Nouveau modèle';

  @override
  String get templatesNameLabel => 'Nom';

  @override
  String get templatesTitleLabel => 'Titre';

  @override
  String get templatesBodyLabel => 'Corps';

  @override
  String get templatesRequiredFieldsError =>
      'Le nom, le titre et le corps sont requis.';

  @override
  String get templatesBuiltinNoDelete =>
      'Les modèles préinstallés ne peuvent pas être supprimés';

  @override
  String get templatesAddFromTemplate => 'À partir d\'un modèle';

  @override
  String get templatesAddFromScratch => 'De toutes pièces';

  @override
  String templatesDeleteConfirmTitle(Object name) {
    return 'Supprimer « $name » ?';
  }

  @override
  String get templatesDeleteConfirmBody =>
      'Ce modèle sera définitivement supprimé.';

  @override
  String get templatesEmptyAddFirst => 'Ajoutez votre premier modèle';

  @override
  String get templatesPickFromBuiltinTitle => 'Choisir un modèle préinstallé';

  @override
  String get templatesIconLabel => 'Icône';

  @override
  String get templatesIconCalendar => 'Calendrier';

  @override
  String get templatesIconAppNotification => 'Notification d\'application';

  @override
  String get templatesIconFitness => 'Fitness';

  @override
  String get templatesIconHealth => 'Santé';

  @override
  String get templatesIconFood => 'Repas';

  @override
  String get templatesIconCoffee => 'Café';

  @override
  String get templatesIconBattery => 'Batterie';

  @override
  String get templatesIconWeather => 'Météo';

  @override
  String get templatesPreviewHeading => 'Aperçu en direct';

  @override
  String get templatesDiscardChangesTitle => 'Annuler les modifications ?';

  @override
  String get templatesDiscardChangesBody =>
      'Les modifications non enregistrées seront perdues.';

  @override
  String get templatesDiscardKeep => 'Continuer la modification';

  @override
  String get templatesDiscardDiscard => 'Annuler';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsStatusGranted => 'Accordée';

  @override
  String get notificationsStatusDenied => 'Refusée';

  @override
  String get notificationsStatusUnknown => 'Pas encore demandée';

  @override
  String get notificationsRequest => 'Demander l\'autorisation';

  @override
  String get notificationsOpenSettings => 'Ouvrir les paramètres système';

  @override
  String get profileFieldPhone => 'Numéro de téléphone';

  @override
  String get profileFieldDescription => 'Description physique';

  @override
  String get profileFieldMedicalConditions => 'Problèmes de santé';

  @override
  String get profileFieldEmergencyInstructions => 'Instructions d\'urgence';

  @override
  String get aboutAuthor => 'Auteur : Jonas Eschle';

  @override
  String get aboutEmail => 'guardian.angela.app@gmail.com';

  @override
  String get aboutPrivacyPolicy => 'Politique de confidentialité';

  @override
  String get aboutTermsOfService => 'Conditions d\'utilisation';

  @override
  String get aboutSourceCode => 'Code source';

  @override
  String get aboutSupport => 'Soutien / faire un don';

  @override
  String get aboutLicenses => 'Licences open source';

  @override
  String get aboutTagline => 'Conçu avec amour pour la sécurité LGBTQ+.';

  @override
  String get aboutTechnicalSection => 'Informations techniques';

  @override
  String aboutBundleId(Object id) {
    return 'Identifiant du bundle : $id';
  }

  @override
  String aboutPlatforms(Object list) {
    return 'Plateformes : $list';
  }

  @override
  String get feedbackHeading => 'Nous aimerions avoir de vos nouvelles';

  @override
  String get feedbackCategoryLabel => 'Catégorie';

  @override
  String get feedbackCategoryBug => 'Signalement de bogue';

  @override
  String get feedbackCategoryFeature => 'Demande de fonctionnalité';

  @override
  String get feedbackCategoryOther => 'Autre';

  @override
  String get feedbackEmailLabel => 'E-mail (facultatif)';

  @override
  String get feedbackMessageLabel => 'Message';

  @override
  String get feedbackIncludeLog => 'Inclure le journal de la dernière session';

  @override
  String get feedbackSent => 'Merci pour vos commentaires !';

  @override
  String get feedbackMessageRequired =>
      'Le message doit comporter au moins 10 caractères.';

  @override
  String get backupIncludeLogs => 'Inclure les journaux de session';

  @override
  String get backupIncludeMedia => 'Inclure les médias';

  @override
  String get backupExportButton => 'Exporter';

  @override
  String get backupImportButton => 'Importer';

  @override
  String get backupOverwriteWarning =>
      'L\'importation écrase toutes les données actuelles.';

  @override
  String get backupImportSuccess =>
      'Importation terminée. Redémarrez pour appliquer.';

  @override
  String backupImportError(Object message) {
    return 'Échec de l\'importation : $message';
  }

  @override
  String get backupActiveSessionBanner =>
      'La sauvegarde n\'est pas disponible pendant une session active.';

  @override
  String backupLastBackupAtLabel(Object when) {
    return 'Dernière sauvegarde le $when';
  }

  @override
  String get backupNeverExportedLabel => 'Aucune sauvegarde pour le moment';

  @override
  String get pastEventsTitle => 'Sessions passées';

  @override
  String get pastEventsTabReal => 'Réelles';

  @override
  String get pastEventsTabSimulated => 'Simulées';

  @override
  String get pastEventsEmpty => 'Aucune session pour le moment';

  @override
  String get pastEventsDeleteConfirm => 'Supprimer le journal de session ?';

  @override
  String get pastEventsDetailShareText => 'Partager en texte';

  @override
  String get pastEventsDetailSharePdf => 'Partager en PDF';

  @override
  String get pastEventsDetailDelete => 'Supprimer';

  @override
  String get pastEventsOutcomeCompleted => 'Terminée';

  @override
  String get pastEventsOutcomeDistress => 'Détresse';

  @override
  String get pastEventsOutcomeInterrupted => 'Interrompue';

  @override
  String get pastEventsTrash => 'Corbeille';

  @override
  String get pastEventsUndo => 'Annuler';

  @override
  String get pastEventsSoftDeleted => 'Déplacé vers la corbeille';

  @override
  String get pastEventsDetailTitle => 'Journal de session';

  @override
  String get pastEventsDetailShare => 'Partager';

  @override
  String get contactUnsavedDiscardTitle =>
      'Annuler les modifications non enregistrées ?';

  @override
  String get contactUnsavedDiscardKeep => 'Continuer la modification';

  @override
  String get contactUnsavedDiscardDiscard => 'Annuler';

  @override
  String get modesDuplicate => 'Dupliquer';

  @override
  String get modesDeleteConfirmTitle => 'Supprimer le mode ?';

  @override
  String modesDeleteConfirmBody(Object name) {
    return '$name sera définitivement supprimé.';
  }

  @override
  String get modesDistressDefaultBadge => 'Par défaut';

  @override
  String get modesDistressSetDefault => 'Définir par défaut';

  @override
  String get modesDistressCantDeleteLast =>
      'Au moins un mode de détresse est requis.';

  @override
  String get modesDistressInUse =>
      'Ce mode de détresse est utilisé par un autre mode.';

  @override
  String get modesDistressTitle => 'Modes de détresse';

  @override
  String get validationNameTooShort =>
      'Le nom doit comporter au moins 2 caractères.';

  @override
  String get validationPhoneRequired => 'Le numéro de téléphone est requis.';

  @override
  String get validationChannelsRequired => 'Sélectionnez au moins un canal.';

  @override
  String get validationChainEmpty =>
      'Ajoutez au moins une étape avant d’enregistrer.';

  @override
  String get validationGpsFixedCoords =>
      'Indiquez la latitude et la longitude de la destination d’arrivée fixe.';

  @override
  String get validationHardwareTrigger =>
      'Le déclencheur de panique matériel est incomplet — vérifiez le nombre d’appuis ou la durée de maintien.';

  @override
  String get validationSmsChannelNotOnContacts =>
      'Aucun des contacts choisis ne peut recevoir via le canal de cette étape. Choisissez un autre canal ou ajoutez-le à un contact.';

  @override
  String get validationDistressNoActionTitle =>
      'Aucune étape d’alerte sortante';

  @override
  String get validationDistressNoActionBody =>
      'Ce mode de détresse n’a aucune étape SMS ou appel ; il ne laisse donc aucune trace sortante. Enregistrer quand même ?';

  @override
  String get validationSaveAnyway => 'Enregistrer quand même';

  @override
  String get sessionHoldTouchToBegin => 'Touchez pour commencer';

  @override
  String sessionHoldReleaseCountdown(Object seconds) {
    return 'Compte à rebours : $seconds s';
  }

  @override
  String sessionHoldGraceCountdown(Object seconds) {
    return 'Délai de grâce : $seconds s — maintenez à nouveau pour rester en sécurité';
  }

  @override
  String get sessionHoldAgain => 'Maintenez à nouveau pour rester en sécurité';

  @override
  String sessionStepNextCheckIn(Object time) {
    return 'Prochain pointage dans $time';
  }

  @override
  String sessionStepFakeCallActive(Object caller) {
    return 'Appel entrant de $caller';
  }

  @override
  String get sessionStepFakeCallOpen => 'Ouvrir l\'écran d\'appel';

  @override
  String sessionStepSimBlockedSms(Object count) {
    return '[SIM] Enverrait un SMS à $count contacts';
  }

  @override
  String get sessionStepSimBlockedPhone =>
      '[SIM] Appellerait le contact d\'urgence';

  @override
  String get sessionStepSimBlockedEmergency =>
      '[SIM] Appellerait les services d\'urgence';

  @override
  String get sessionStepSimBlockedAlarm =>
      '[SIM] L\'alarme aurait retenti à plein volume';

  @override
  String get sessionStartFailedTitle => 'Impossible de démarrer la session';

  @override
  String get sessionStartFailedBody =>
      'Corrigez les problèmes suivants avant de démarrer :';

  @override
  String get sessionQuickExitTitle => 'Sortie rapide';

  @override
  String get sessionQuickExitBody =>
      'Les données de la session seront conservées et chiffrées. Rouvrez l\'application à tout moment pour les récupérer.';

  @override
  String get sessionQuickExitConfirm => 'Quitter l\'application';

  @override
  String get pastEventsRestore => 'Restaurer';

  @override
  String get stepEditorWait => 'Attente (s)';

  @override
  String get stepEditorDuration => 'Durée (s)';

  @override
  String get stepEditorGrace => 'Délai de grâce (s)';

  @override
  String get stepEditorRetryCount => 'Nombre de tentatives';

  @override
  String get stepEditorRandomize => 'Aléatoiriser le minutage (±20 %)';

  @override
  String get stepEditorRemove => 'Supprimer l\'étape';

  @override
  String get eventDefaultsHoldStyle => 'Style de maintien';

  @override
  String get eventDefaultsHoldSensitivity => 'Sensibilité au relâchement';

  @override
  String get eventDefaultsHoldVibrate => 'Vibrer au relâchement';

  @override
  String get eventDefaultsHoldSound => 'Son au relâchement';

  @override
  String get eventDefaultsBlackScreen => 'Superposition d\'écran noir';

  @override
  String get eventDefaultsReminderRandomInterval =>
      'Aléatoiriser l\'intervalle';

  @override
  String get eventDefaultsReminderRandomTemplate =>
      'Aléatoiriser l\'ordre des modèles';

  @override
  String get eventDefaultsReminderResetOnEarly =>
      'Réinitialiser en cas de pointage anticipé';

  @override
  String get eventDefaultsCountdownStyle => 'Style du compte à rebours';

  @override
  String get eventDefaultsCountdownVibrate => 'Vibrer';

  @override
  String get eventDefaultsCountdownSound => 'Son';

  @override
  String get eventDefaultsFakeCallStyle => 'Style d\'appel';

  @override
  String get eventDefaultsFakeCallCallerName => 'Nom de l\'appelant';

  @override
  String get eventDefaultsFakeCallRingDuration => 'Durée de sonnerie (s)';

  @override
  String get eventDefaultsFakeCallDeclineIsSafe =>
      'Refuser compte comme « en sécurité »';

  @override
  String get eventDefaultsFakeCallVoiceOutput => 'Sortie vocale';

  @override
  String get eventDefaultsFakeCallRingtone => 'Sonnerie';

  @override
  String get eventDefaultsFakeCallRingtoneDefault => 'Sonnerie par défaut';

  @override
  String eventDefaultsFakeCallRingtoneCustom(String fileName) {
    return 'Personnalisée : $fileName';
  }

  @override
  String get eventDefaultsFakeCallRingtoneChoose => 'Choisir une sonnerie…';

  @override
  String get eventDefaultsFakeCallRingtoneUseDefault => 'Utiliser par défaut';

  @override
  String get eventDefaultsSmsChannel => 'Canal';

  @override
  String get eventDefaultsSmsIncludeLocation => 'Inclure la position';

  @override
  String get eventDefaultsSmsIncludeMedical =>
      'Inclure les informations médicales';

  @override
  String get eventDefaultsSmsAutoRecord =>
      'Enregistrer l\'audio avant l\'envoi';

  @override
  String get eventDefaultsSmsRecordDuration => 'Durée d\'enregistrement (s)';

  @override
  String get eventDefaultsSmsMessageTemplate => 'Modèle de message';

  @override
  String get eventDefaultsSmsMessageTemplateHint =>
      'Laissez vide pour utiliser l’alerte par défaut. Touchez un espace réservé pour l’insérer.';

  @override
  String get eventDefaultsSmsIosWarning =>
      'Sur iPhone, l’envoi de SMS exige d’appuyer manuellement sur Envoyer dans l’app Messages. Si vous ne pouvez pas utiliser votre téléphone, le message ne sera pas envoyé. Préférez WhatsApp ou Telegram.';

  @override
  String get eventDefaultsLoudAlarmVolume => 'Volume';

  @override
  String get eventDefaultsLoudAlarmSound => 'Son';

  @override
  String get eventDefaultsLoudAlarmFlashScreen => 'Faire clignoter l\'écran';

  @override
  String get eventDefaultsLoudAlarmFlashLight =>
      'Faire clignoter le flash de l\'appareil photo';

  @override
  String get eventDefaultsLoudAlarmGradual => 'Montée progressive du volume';

  @override
  String get eventDefaultsCallEmergencyNumber =>
      'Numéro d\'urgence (remplacement)';

  @override
  String get eventDefaultsCallEmergencyConfirm =>
      'Afficher un compte à rebours de confirmation';

  @override
  String get eventDefaultsCallEmergencyConfirmDuration =>
      'Secondes de confirmation';

  @override
  String get eventDefaultsCallEmergencySmsFirst =>
      'Envoyer d\'abord un SMS de position';

  @override
  String get eventDefaultsCallEmergencyIosWarning =>
      'Sur iPhone, une boîte de confirmation apparaît avant l’appel. Touchez « Appeler » rapidement.';

  @override
  String get eventDefaultsPhonePrimaryContact => 'Contact principal (id)';

  @override
  String get eventDefaultsHardwareButton => 'Bouton';

  @override
  String get eventDefaultsHardwarePattern => 'Schéma de pression';

  @override
  String get eventDefaultsHardwarePressCount => 'Nombre de pressions';

  @override
  String get eventDefaultsHardwareLongDuration => 'Durée d\'appui long (s)';

  @override
  String get pastEventsTrashTitle => 'Corbeille';

  @override
  String get pastEventsTrashEmpty => 'La corbeille est vide';

  @override
  String get pastEventsTrashEmptyAll => 'Vider la corbeille';

  @override
  String get pastEventsTrashEmptyAllConfirmTitle => 'Vider la corbeille ?';

  @override
  String get pastEventsTrashEmptyAllConfirmBody =>
      'Saisissez EMPTY TRASH ci-dessous pour confirmer. Cela supprime définitivement tous les journaux mis à la corbeille.';

  @override
  String pastEventsTrashEmptyAllSuccess(Object count) {
    return 'Corbeille vidée ($count journaux)';
  }

  @override
  String pastEventsTrashRetentionNote(int days) {
    return 'Les journaux dans la corbeille sont définitivement supprimés après $days jours.';
  }

  @override
  String pastEventsTrashRemainingDays(int days) {
    return '$days jour(s) avant la suppression définitive';
  }

  @override
  String get pastEventsTrashDeletePermanently => 'Supprimer définitivement';

  @override
  String get pastEventsTrashDeletePermanentlyBody =>
      'Cette action est irréversible.';

  @override
  String sessionEmergencyConfirmTitle(String number, int seconds) {
    return 'Appel du $number dans $seconds s';
  }

  @override
  String get sessionEmergencyConfirmSwipe => 'Glisser pour annuler';

  @override
  String get sessionEmergencyConfirmKeep => 'Continuer l\'appel';

  @override
  String get sessionEmergencyConfirmSimBadge => '[SIM] Mode entraînement';

  @override
  String get sessionEmergencyConfirmSimCancelled =>
      'Annulation simulée — l\'appel n\'aurait pas été passé';

  @override
  String get swipeSliderSemantics => 'Glisser pour confirmer';

  @override
  String get homeWidgetStatusIdle => 'En veille';

  @override
  String get homeWidgetStatusSession => 'Session active';

  @override
  String get homeWidgetStatusSim => 'Simulation active';

  @override
  String get homeWidgetQuickExit => 'Sortie rapide';

  @override
  String get homeWidgetFakeCall => 'Faux appel';

  @override
  String get settingsAlarmHeader => 'Alarme';

  @override
  String get settingsAlarmDndOverrideLabel =>
      'L\'alarme ignore le mode silencieux/vibreur';

  @override
  String get settingsAlarmDndOverrideWarning =>
      'Attention : l\'alarme sera silencieuse si votre téléphone est en mode silencieux.';

  @override
  String get settingsAlarmDndOverrideInfo =>
      'Lorsqu\'elle est activée, l\'alarme sonore retentit au volume maximal même si votre téléphone est en mode silencieux ou vibreur. Sous Android, elle utilise le canal audio d\'alarme pour contourner le mode Ne pas déranger. L\'alarme est le seul événement qui peut ignorer les réglages sonores de votre téléphone.';

  @override
  String get settingsAlarmGradualLabel =>
      'Augmenter progressivement le volume de l\'alarme';

  @override
  String get settingsAlarmGradualInfo =>
      'Démarre l\'alarme en douceur et la monte jusqu\'au volume maximal. C\'est l\'interrupteur principal de toute l\'application ; chaque étape d\'alarme possède aussi sa propre option de volume progressif, et les deux doivent être activés pour que la montée s\'applique.';

  @override
  String get settingsAlarmRampLabel => 'Durée de la montée';

  @override
  String get settingsAlarmRampInfo =>
      'Le temps que met l\'alarme pour atteindre le volume maximal à partir de zéro, en montant régulièrement pendant cette durée. Sans effet lorsque le volume progressif est désactivé.';

  @override
  String get permissionNotifRationaleTitle => 'Autoriser les notifications ?';

  @override
  String get permissionNotifRationaleBody =>
      'Guardian Angela utilise les notifications pour vous alerter, vous et vos contacts, pendant une session de sécurité, y compris des rappels déguisés qui réveillent votre téléphone verrouillé. Veuillez autoriser les notifications pour que l\'application puisse vous joindre.';

  @override
  String get permissionNotifDeniedTitle => 'Les notifications sont bloquées';

  @override
  String get permissionNotifDeniedBody =>
      'Les notifications sont désactivées pour Guardian Angela. Ouvrez les réglages système pour les réactiver afin que l\'application puisse vous alerter pendant une session.';

  @override
  String get permissionNotifAllow => 'Autoriser';

  @override
  String get permissionNotifOpenSettings => 'Ouvrir les réglages';

  @override
  String get permissionNotifNotNow => 'Pas maintenant';

  @override
  String get homeStartTriggersSummaryTitle => 'Avant de commencer';

  @override
  String get homeStartTriggersDistressHeading => 'Déclencheur d\'alerte';

  @override
  String get homeStartTriggersDisarmHeading => 'Déclencheur de fin automatique';

  @override
  String get homeStartTriggersNone => 'Aucun configuré';

  @override
  String homeStartTriggerButtonRepeat(String button, String count) {
    return 'Appuyez sur $button $count fois';
  }

  @override
  String homeStartTriggerButtonLong(String button, String seconds) {
    return 'Maintenez $button pendant $seconds s';
  }

  @override
  String get homeStartTriggerButtonVolumeUp => 'Volume +';

  @override
  String get homeStartTriggerButtonVolumeDown => 'Volume -';

  @override
  String homeStartTriggerGpsArrival(String radius) {
    return 'Se termine à l\'arrivée à moins de $radius m de votre destination';
  }

  @override
  String get homeStartTriggerGpsPrompt =>
      'La destination vous sera demandée après le démarrage';

  @override
  String homeStartTriggerTimer(String minutes) {
    return 'Se termine automatiquement après $minutes min';
  }

  @override
  String get homeStartTriggersContinue => 'Démarrer';

  @override
  String get homeStartTriggersCancel => 'Annuler';

  @override
  String get homeStartBlockedNotifTitle => 'Notifications requises';

  @override
  String get homeStartBlockedNotifBody =>
      'Ce mode utilise des notifications (rappels déguisés ou faux appels) pour assurer votre sécurité, mais l\'autorisation de notification est désactivée. Activez les notifications pour démarrer ce mode.';
}
