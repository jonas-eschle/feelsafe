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
  String get profileAngelaWarningTitle => 'À propos du nom « Angela »';

  @override
  String get profileAngelaWarningBody =>
      'Guardian Angela utilise « Angela » comme mot-clé de sécurité. Utiliser ce nom comme le vôtre pourrait prêter à confusion. Enregistrer quand même ?';

  @override
  String get commonDelete => 'Supprimer';

  @override
  String get commonEdit => 'Modifier';

  @override
  String get commonAdd => 'Ajouter';

  @override
  String get commonClose => 'Fermer';

  @override
  String get commonConfirm => 'Confirmer';

  @override
  String get commonBack => 'Retour';

  @override
  String get commonDone => 'Terminé';

  @override
  String get commonRetry => 'Réessayer';

  @override
  String get commonYes => 'Oui';

  @override
  String get commonNo => 'Non';

  @override
  String get commonEnabled => 'Activé';

  @override
  String get commonDisabled => 'Désactivé';

  @override
  String get commonNone => 'Aucun';

  @override
  String get commonSeconds => 'secondes';

  @override
  String get commonMinutes => 'minutes';

  @override
  String get cancel => 'Annuler';

  @override
  String get pinSubmit => 'Valider';

  @override
  String get homeTitle => 'Guardian Angela';

  @override
  String get homeStartSession => 'Démarrer la session';

  @override
  String get homeStartConfirmTitle => 'Démarrer une session ?';

  @override
  String get homeStartConfirmBody =>
      'Vérifiez que vos contacts et votre PIN sont configurés. La session s\'exécutera au premier plan et le mode sélectionné guidera les validations.';

  @override
  String get homePermissionsMissingTitle => 'Certaines autorisations manquent';

  @override
  String get homePermissionsMissingBody =>
      'Les autorisations suivantes n\'ont pas été accordées. Sans elles, les étapes correspondantes échoueront silencieusement :';

  @override
  String get homePermissionsContinueAnyway => 'Démarrer quand même';

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
  String get homeActiveSession => 'Session active';

  @override
  String get homeResumeSession => 'Reprendre';

  @override
  String get homeNoModes =>
      'Aucun mode pour le moment. Appuyez sur Modes pour en ajouter un.';

  @override
  String get homeNoContacts =>
      'Aucun contact d\'urgence pour le moment. Appuyez sur Contacts pour en ajouter un.';

  @override
  String get homeContactsBannerNone => 'Aucun contact d\'urgence configuré.';

  @override
  String get homeMenuSettings => 'Paramètres';

  @override
  String get homeMenuContacts => 'Contacts';

  @override
  String get homeMenuModes => 'Modes';

  @override
  String get homeMenuHistory => 'Sessions passées';

  @override
  String get homeSelectMode => 'Choisir le mode';

  @override
  String get onboardingWelcomeTitle => 'Bienvenue sur Guardian Angela';

  @override
  String get onboardingWelcomeBody =>
      'Un compagnon qui veille sur votre sécurité sur le chemin du retour. Guardian Angela vous accompagne pendant que vous marchez, courez ou voyagez, et peut alerter vos contacts en cas de besoin.';

  @override
  String get onboardingProfileTitle => 'Profil et premier contact';

  @override
  String get onboardingProfileBody =>
      'Parlez-nous un peu de vous pour que Guardian Angela puisse partager des informations utiles en cas d\'urgence. Ajoutez ensuite un contact de confiance.';

  @override
  String get onboardingPermissionsTitle => 'Autorisations';

  @override
  String get onboardingPermissionsBody =>
      'Guardian Angela a besoin de quelques autorisations pour assurer votre sécurité. Accordez-les maintenant ou plus tard depuis les Paramètres.';

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
  String get onboardingFinish => 'Terminer';

  @override
  String get sessionTitle => 'Session';

  @override
  String get sessionDisarm => 'Je suis en sécurité';

  @override
  String get sessionPause => 'Pause';

  @override
  String get sessionResume => 'Reprendre';

  @override
  String get sessionHoldPrompt => 'Maintenez pour rester en sécurité';

  @override
  String get sessionHoldSemantic =>
      'Maintenez appuyé. Relâcher démarre un délai de grâce.';

  @override
  String sessionStepLabel(Object index, Object total) {
    return 'Étape $index sur $total';
  }

  @override
  String sessionMissCount(Object count) {
    return 'Manquées : $count';
  }

  @override
  String sessionRemaining(Object seconds) {
    return '${seconds}s restantes';
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
  String get sessionDisarmTriggerTitle => 'Déclencheur de désactivation activé';

  @override
  String get sessionDisarmTriggerBody =>
      'Un déclencheur de désactivation s\'est activé. Terminer la session ?';

  @override
  String get sessionDisarmTriggerConfirm => 'Terminer la session';

  @override
  String get sessionDisarmTriggerCancel => 'Continuer';

  @override
  String get wrongPinAngelaTitle => 'Ancien PIN d\'Angela';

  @override
  String get wrongPinAngelaBody =>
      'Voulez-vous vraiment continuer avec cet ancien PIN ?';

  @override
  String get wrongPinAngelaConfirm => 'OK';

  @override
  String get wrongPinAngelaCancel => 'Annuler';

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
  String get sessionStepSmsDelivered => 'Délivré';

  @override
  String get sessionStepSmsSent => 'Envoyé';

  @override
  String get sessionStepSmsQueued => 'En file d\'attente';

  @override
  String get sessionStepSmsFailed => 'Échec';

  @override
  String get sessionStepPhoneCallStatus => 'Appel du contact d\'urgence…';

  @override
  String get sessionStepPhoneCallCancel => 'Annuler l\'appel';

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
  String get fakeCallAnswer => 'Répondre';

  @override
  String get fakeCallDecline => 'Refuser';

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
  String get contactRequiredError =>
      'Le nom et le numéro de téléphone sont obligatoires.';

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
  String get modesNewPickerTitle => 'Partir de';

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
  String modesNewPickerCopyName(String name) {
    return 'Copie de $name';
  }

  @override
  String get modesNewPickerBuiltinBadge => 'Intégré';

  @override
  String get modeEditorTitleCreate => 'Nouveau mode';

  @override
  String get modeEditorTitleEdit => 'Modifier le mode';

  @override
  String get modeFieldName => 'Nom';

  @override
  String get modeFieldDistressMode => 'Mode de détresse';

  @override
  String get modeFieldDistressModeDefault => 'Utiliser par défaut';

  @override
  String get modeChainHeader => 'Chaîne';

  @override
  String get modeChainAddStep => 'Ajouter une étape';

  @override
  String get modeChainEmpty =>
      'Aucune étape pour le moment. Appuyez sur Ajouter une étape.';

  @override
  String get modeFieldIcon => 'Icône';

  @override
  String get modeIconPickerTitle => 'Choisir une icône';

  @override
  String get modeIconClear => 'Aucune icône';

  @override
  String get modeDistressHeader => 'Déclencheurs de détresse';

  @override
  String get modeDistressEmpty => 'Aucun déclencheur de détresse configuré.';

  @override
  String get modeDistressAdd => 'Ajouter un déclencheur';

  @override
  String get modeDistressTypeHardware => 'Bouton physique';

  @override
  String get modeDistressButtonType => 'Bouton';

  @override
  String get modeDistressButtonVolumeUp => 'Volume +';

  @override
  String get modeDistressButtonVolumeDown => 'Volume −';

  @override
  String get modeDistressButtonPower => 'Marche/arrêt';

  @override
  String get modeDistressPattern => 'Schéma';

  @override
  String get modeDistressPatternRepeat => 'Appui répété';

  @override
  String get modeDistressPatternLong => 'Appui long';

  @override
  String get modeDistressPressCount => 'Nombre d\'appuis';

  @override
  String get modeDistressPressWindow => 'Fenêtre (ms)';

  @override
  String get modeDistressLongDuration => 'Durée d\'appui (secondes)';

  @override
  String modeDistressSummaryRepeat(Object count, Object windowMs) {
    return '$count appuis / $windowMs ms';
  }

  @override
  String modeDistressSummaryLong(Object seconds) {
    return 'Maintenir ${seconds}s';
  }

  @override
  String get modeOverridesHeader => 'Substitutions du mode';

  @override
  String get modeOverridesUseDefault => 'Utiliser la valeur par défaut';

  @override
  String get modeOverridesGpsLabel => 'Journalisation GPS';

  @override
  String get modeOverridesStealthLabel => 'Camouflage';

  @override
  String get modeOverridesEventDefaultsLabel =>
      'Valeurs par défaut d\'événement';

  @override
  String get modeOverridesLocalTemplatesLabel => 'Modèles de rappel locaux';

  @override
  String get modeOverridesGpsEnabled => 'GPS activé';

  @override
  String get modeOverridesGpsIntervalLabel =>
      'Intervalle d\'échantillonnage (secondes)';

  @override
  String get modeOverridesGpsIncludeInSms => 'Ajouter le lieu aux SMS';

  @override
  String get modeOverridesStealthEnabled => 'Camouflage activé';

  @override
  String get modeOverridesStealthFakeName => 'Nom factice de l\'application';

  @override
  String get modeOverridesEventDefaultsHint =>
      'Valeurs personnalisées actives pour ce mode.';

  @override
  String modeOverridesLocalTemplatesCount(Object count) {
    return '$count modèles locaux';
  }

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
  String get stepDuplicate => 'Dupliquer l\'étape';

  @override
  String get stepTimingHeader => 'Minutage';

  @override
  String stepTimingSummary(Object wait, Object duration, Object grace) {
    return 'attente ${wait}s / durée ${duration}s / délai ${grace}s';
  }

  @override
  String get stepCategoryAll => 'Tout';

  @override
  String get stepPickerMore => 'Plus d\'options...';

  @override
  String get stepCategoryAction => 'Action';

  @override
  String get stepCategoryReminder => 'Rappel';

  @override
  String get stepCategoryDisarm => 'Vérification';

  @override
  String get modeTrackingHeader => 'Suivi GPS';

  @override
  String get modeTrackingEnabled => 'Enregistrer le GPS pendant la session';

  @override
  String get modeTrackingIntervalLabel => 'Intervalle d\'échantillonnage';

  @override
  String get modeTrackingBufferSizeLabel => 'Taille du tampon';

  @override
  String modeTrackingBufferSizeValue(Object count) {
    return '$count points';
  }

  @override
  String get modeTrackingBatteryNote =>
      'Un suivi GPS fréquent augmente la consommation de la batterie.';

  @override
  String get stepConfigLogGpsLabel => 'Suivi GPS';

  @override
  String get stepConfigLogGpsDefault => 'Par défaut';

  @override
  String get stepConfigLogGpsOn => 'Activé';

  @override
  String get stepConfigLogGpsOff => 'Désactivé';

  @override
  String get stepConfigLogGpsDefaultOn => 'Par défaut (Activé)';

  @override
  String get stepConfigLogGpsDefaultOff => 'Par défaut (Désactivé)';

  @override
  String get moreSettingsHeader => 'Autres paramètres';

  @override
  String moreSettingsHeaderCustomized(int count) {
    return 'Autres paramètres ($count personnalisés)';
  }

  @override
  String get stepTypePickerLabel => 'Type d\'étape';

  @override
  String get stepTypeHoldButton => 'Bouton à maintenir';

  @override
  String get stepTypeDisguisedReminder => 'Rappel déguisé';

  @override
  String get stepTypeCountdownWarning => 'Avertissement de compte à rebours';

  @override
  String get stepTypeFakeCall => 'Faux appel';

  @override
  String get stepTypeSmsContact => 'SMS contact';

  @override
  String get stepTypePhoneCallContact => 'Appel contact';

  @override
  String get stepTypeLoudAlarm => 'Alarme sonore';

  @override
  String get stepTypeCallEmergency => 'Appel d\'urgence';

  @override
  String get stepTypeHardwareButton => 'Bouton physique';

  @override
  String get stepFieldDuration => 'Durée (secondes)';

  @override
  String get stepFieldGrace => 'Délai de grâce (secondes)';

  @override
  String get stepFieldWait => 'Attente (secondes)';

  @override
  String get stepFieldRetryCount => 'Nombre de tentatives';

  @override
  String get stepFieldRandomize => 'Variation temporelle';

  @override
  String get stepFieldRandomizeToggle => 'Aléatoiriser le minutage (±20%)';

  @override
  String get stepFieldWaitTooltip =>
      'Combien de temps attendre avant le démarrage de cette étape.';

  @override
  String get stepFieldDurationTooltip =>
      'Combien de temps l\'étape est active avant la fenêtre de grâce.';

  @override
  String get stepFieldGraceTooltip =>
      'Délai après la phase active pour confirmer la sécurité avant la prochaine étape.';

  @override
  String get stepFieldRetryCountTooltip =>
      'Combien de fois répéter cette étape avant l\'escalade.';

  @override
  String get stepFieldReminderIntervalTooltip =>
      'À quelle fréquence le rappel déguisé se déclenche en attente d\'une confirmation.';

  @override
  String get stepFieldReminderGraceTooltip =>
      'Combien de temps l\'utilisateur a pour confirmer la sécurité après l\'apparition du rappel.';

  @override
  String get stepPreview => 'Aperçu en simulation';

  @override
  String stepPreviewFired(Object description) {
    return 'Aperçu exécuté : $description';
  }

  @override
  String get stepPreviewTitle => 'Aperçu de l\'étape';

  @override
  String get stepPreviewMissingParams =>
      'Référence d\'étape ou de mode manquante.';

  @override
  String get stepPreviewModeNotFound => 'Mode introuvable.';

  @override
  String get stepPreviewStepNotFound => 'Étape introuvable dans ce mode.';

  @override
  String stepPreviewError(Object error) {
    return 'Échec de l\'aperçu : $error';
  }

  @override
  String get stepPreviewReplay => 'Rejouer';

  @override
  String get stepPreviewHoldButtonHint =>
      'Maintenez le bouton pour ressentir la réponse en direct.';

  @override
  String get stepPreviewHoldButtonLabel => 'Maintenir';

  @override
  String get stepPreviewHoldButtonSemantic => 'Maintenez pour prévisualiser';

  @override
  String get stepPreviewHoldButtonReleased =>
      'Relâché. La session entrerait maintenant dans la période de grâce.';

  @override
  String get stepPreviewFakeCallHint =>
      'L\'écran de faux appel apparaîtra. Glissez pour répondre ou maintenez le bouton rouge pour simuler la détresse.';

  @override
  String get stepConfigFakeCallCaller => 'Nom de l\'appelant';

  @override
  String get stepConfigFakeCallDecline => 'Refuser compte comme désarmer';

  @override
  String get stepConfigLoudAlarmFlash => 'Écran stroboscopique';

  @override
  String get stepConfigLoudAlarmVolume => 'Volume maximum';

  @override
  String get stepConfigCountdownVibrate => 'Vibrer';

  @override
  String get stepConfigCountdownTone => 'Jouer un son';

  @override
  String get stepConfigSmsSelection => 'Destinataires';

  @override
  String get stepConfigSmsAllContacts => 'Tous les contacts';

  @override
  String get stepConfigSmsSpecific => 'Contacts spécifiques';

  @override
  String get stepConfigSmsIncludeLocation => 'Inclure la localisation';

  @override
  String get stepConfigSmsIncludeMedical =>
      'Inclure les informations médicales';

  @override
  String get stepConfigSmsAutoRecordAudio =>
      'Enregistrer l\'audio automatiquement';

  @override
  String get stepConfigSmsAutoRecordVideo =>
      'Enregistrer la vidéo automatiquement';

  @override
  String get stepConfigSmsRecordDuration => 'Durée d\'enregistrement';

  @override
  String get stepConfigHoldReleaseSensitivity =>
      'Sensibilité au relâchement (s)';

  @override
  String get stepConfigReminderInterval => 'Intervalle de rappel (secondes)';

  @override
  String get stepConfigReminderTemplate => 'Modèle';

  @override
  String get stepConfigHardwarePattern => 'Motif';

  @override
  String get stepConfigHardwarePressCount => 'Nombre d\'appuis';

  @override
  String get stepConfigHardwarePressWindow => 'Fenêtre entre appuis (ms)';

  @override
  String get stepConfigHardwareLongDuration => 'Durée d\'appui long (s)';

  @override
  String get stepConfigHardwareButton => 'Bouton';

  @override
  String get stepConfigHardwareButtonVolumeUp => 'Volume +';

  @override
  String get stepConfigHardwareButtonVolumeDown => 'Volume -';

  @override
  String get stepConfigHardwareButtonPower => 'Alimentation';

  @override
  String get stepConfigHardwarePatternRepeat => 'Appuis répétés';

  @override
  String get stepConfigHardwarePatternLong => 'Appui long';

  @override
  String get stepConfigEmergencyNumber => 'Remplacer le numéro d\'urgence';

  @override
  String get stepConfigEmergencyConfirm => 'Confirmer avant d\'appeler';

  @override
  String get stepConfigPhonePreSms => 'Envoyer un SMS avant l\'appel';

  @override
  String get distressModesTitle => 'Modes de détresse';

  @override
  String get distressModeInUseTitle => 'Mode de détresse utilisé';

  @override
  String distressModeInUseBody(Object modes) {
    return 'Ce mode de détresse est encore lié à : $modes. Associez ces modes à un autre mode de détresse avant de le supprimer.';
  }

  @override
  String get distressModesEmpty => 'Aucun mode de détresse pour le moment.';

  @override
  String get distressModesAdd => 'Ajouter un mode de détresse';

  @override
  String get distressModeEditorTitleCreate => 'Nouveau mode de détresse';

  @override
  String get distressModeEditorTitleEdit => 'Modifier le mode de détresse';

  @override
  String get distressModeName => 'Nom du mode de détresse';

  @override
  String get distressCountdown => 'Déclenchement du mode de détresse...';

  @override
  String get distressCountdownStealth => 'Veuillez patienter...';

  @override
  String get templatesTitle => 'Modèles de rappel';

  @override
  String get templatesEmpty => 'Aucun modèle pour le moment.';

  @override
  String get templatesAdd => 'Ajouter un modèle';

  @override
  String get templateEditorTitleCreate => 'Nouveau modèle';

  @override
  String get templateEditorTitleEdit => 'Modifier le modèle';

  @override
  String get templateFieldName => 'Nom dans l\'éditeur';

  @override
  String get templateFieldTitle => 'Titre du rappel';

  @override
  String get templateFieldBody => 'Corps du rappel';

  @override
  String get templateFieldConfirmationType => 'Type de confirmation';

  @override
  String get templateFieldKeyword => 'Mot-clé';

  @override
  String get templateFieldButtonLabel => 'Libellé du bouton';

  @override
  String get templateFieldDisplayStyle => 'Style d\'affichage';

  @override
  String get templateConfirmTapButton => 'Appuyer sur le bouton';

  @override
  String get templateConfirmTapWord => 'Appuyer sur le mot';

  @override
  String get templateConfirmSwipe => 'Glisser';

  @override
  String get templateConfirmDismiss => 'Ignorer';

  @override
  String get templateDisplayFullscreen => 'Plein écran';

  @override
  String get templateDisplaySubtle => 'Discret';

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
  String get profileFieldConditions => 'Antécédents médicaux';

  @override
  String get profileFieldInstructions => 'Instructions d\'urgence';

  @override
  String get profileAddItem => 'Ajouter un élément';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get settingsSectionSecurity => 'Sécurité';

  @override
  String get settingsSectionStealth => 'Mode furtif';

  @override
  String get settingsSectionDefaults => 'Valeurs par défaut';

  @override
  String get settingsSectionHistory => 'Historique';

  @override
  String get settingsSectionBackup => 'Sauvegarde';

  @override
  String get settingsSectionAbout => 'À propos';

  @override
  String get settingsSectionFeedback => 'Commentaires';

  @override
  String get settingsSectionContacts => 'Contacts';

  @override
  String get settingsSectionModes => 'Modes';

  @override
  String get settingsSectionProfile => 'Profil';

  @override
  String get settingsSectionDistressModes => 'Modes de détresse';

  @override
  String get settingsSectionReminderTemplates => 'Modèles de rappel';

  @override
  String get settingsSectionBatteryAlert => 'Alerte batterie';

  @override
  String get settingsSectionEventDefaults => 'Valeurs par défaut des étapes';

  @override
  String get settingsSectionGpsLogging => 'Journalisation GPS';

  @override
  String get settingsSectionNotifications => 'Notifications';

  @override
  String get settingsSectionHistoryRetention => 'Conservation de l\'historique';

  @override
  String get settingsSectionAppearance => 'Apparence';

  @override
  String get settingsThemeMode => 'Thème';

  @override
  String get settingsThemeLight => 'Clair';

  @override
  String get settingsThemeDark => 'Sombre';

  @override
  String get settingsThemeSystem => 'Système';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get settingsEmergencyNumber => 'Numéro d\'urgence';

  @override
  String get settingsAlarmDnd => 'L\'alarme contourne le mode Ne pas déranger';

  @override
  String get settingsLanguagePicker => 'Langue';

  @override
  String get settingsEmergencyNumberLabel => 'Numéro d\'urgence';

  @override
  String get settingsRedoOnboardingActiveSessionTooltip =>
      'Cannot redo onboarding during an active session';

  @override
  String get settingsEmergencyNumberCountryPickerTitle =>
      'Choose emergency number';

  @override
  String get settingsEmergencyNumberHint => 'ex. 112';

  @override
  String get settingsEmergencyNumberSave => 'Enregistrer';

  @override
  String get settingsRedoOnboarding => 'Refaire l\'introduction';

  @override
  String get settingsRedoOnboardingConfirm => 'Redémarrer l\'introduction ?';

  @override
  String get settingsRedoOnboardingBody =>
      'Votre configuration actuelle est conservée.';

  @override
  String get settingsRedoOnboardingProceed => 'Redémarrer';

  @override
  String get settingsAlarmGradualVolume => 'Volume d\'alarme progressif';

  @override
  String settingsAlarmGradualVolumeDuration(int seconds) {
    return 'Durée de montée : $seconds s';
  }

  @override
  String get securityTitle => 'Sécurité';

  @override
  String get securityAppPin => 'Code PIN de l\'application';

  @override
  String get securitySessionEndPin => 'Code PIN de fin de session';

  @override
  String get securityDuressPin => 'Code PIN de contrainte';

  @override
  String get securityAppPinBiometric =>
      'Utiliser la biométrie pour le PIN de l\'application';

  @override
  String get securitySessionEndPinBiometric =>
      'Utiliser la biométrie pour le PIN de fin de session';

  @override
  String get securityDistressCancelBiometric =>
      'Utiliser la biométrie pour annuler la détresse';

  @override
  String get securityDuressTest => 'Tester le PIN sous contrainte';

  @override
  String get securityDuressTestSubtitle =>
      'Vérifiez que votre PIN sous contrainte fonctionne.';

  @override
  String get securityPinTimeout => 'Délai d\'expiration du PIN (secondes)';

  @override
  String get securityDisablePin => 'Désactiver';

  @override
  String get securitySetPin => 'Définir le PIN';

  @override
  String get securityChangePin => 'Modifier le PIN';

  @override
  String get pinSetupTitle => 'Définir le PIN';

  @override
  String get pinSetupEnter => 'Saisir le nouveau PIN';

  @override
  String get pinSetupConfirm => 'Confirmer le PIN';

  @override
  String get pinSetupMismatch =>
      'Les codes PIN ne correspondent pas. Réessayez.';

  @override
  String get pinEntryTitle => 'Saisir le PIN';

  @override
  String get pinEntrySubtitle => 'Saisissez votre PIN pour continuer.';

  @override
  String get pinEntryBiometricReason => 'Authentifiez-vous pour continuer';

  @override
  String get stealthTitle => 'Mode furtif';

  @override
  String get stealthEnable => 'Activer le mode furtif';

  @override
  String get stealthFakeName => 'Faux nom de l\'application';

  @override
  String get stealthFakeIcon => 'Fausse icône';

  @override
  String get stealthNotificationDisguise => 'Déguiser les notifications';

  @override
  String get stealthTimerDisplay => 'Afficher le minuteur en mode furtif';

  @override
  String get stealthTimerDisplayNormal => 'Afficher le texte complet';

  @override
  String get stealthTimerDisplaySmall => 'Afficher uniquement les chiffres';

  @override
  String get stealthTimerDisplayNone => 'Masquer le minuteur';

  @override
  String get stealthSessionScreen =>
      'Retirer la marque sur l\'écran de session';

  @override
  String get stealthPickerTitle => 'Icône de l\'application';

  @override
  String get stealthPickerIntro =>
      'Choisissez l\'apparence de l\'icône sur l\'écran d\'accueil.';

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
  String get distressConfirmationTitle => 'Êtes-vous en danger ?';

  @override
  String get distressConfirmationCancel => 'Annuler';

  @override
  String distressConfirmationCountdown(Object seconds) {
    return 'Mode de détresse dans $seconds s';
  }

  @override
  String get imSafeSliderLabel =>
      'Glissez pour confirmer « Je suis en sécurité »';

  @override
  String get batteryAlertTitle => 'Alerte batterie';

  @override
  String get batteryAlertEnable => 'Activer l\'alerte batterie';

  @override
  String batteryAlertThreshold(Object percent) {
    return 'Seuil : $percent %';
  }

  @override
  String get eventDefaultsTitle => 'Valeurs par défaut des étapes';

  @override
  String get eventDefaultsBody =>
      'Ces valeurs par défaut s\'appliquent à toute étape qui ne les remplace pas.';

  @override
  String get gpsLoggingTitle => 'Journalisation GPS';

  @override
  String get gpsLoggingEnable => 'Activer la journalisation GPS';

  @override
  String get gpsLoggingInterval => 'Intervalle d\'échantillonnage (secondes)';

  @override
  String get gpsLoggingAccuracy => 'Précision';

  @override
  String get gpsAccuracyLow => 'Faible';

  @override
  String get gpsAccuracyMedium => 'Moyenne';

  @override
  String get gpsAccuracyHigh => 'Élevée';

  @override
  String get gpsLoggingIncludeSms => 'Joindre la localisation aux SMS';

  @override
  String get gpsLoggingHistoryDays => 'Conservation de l\'historique (jours)';

  @override
  String get notificationSettingsTitle => 'Notifications';

  @override
  String get notificationSettingsBody =>
      'Guardian Angela utilise les notifications pour déguiser et déclencher les rappels.';

  @override
  String get historyRetentionTitle => 'Conservation de l\'historique';

  @override
  String get historyRetentionBody =>
      'Durée de conservation des journaux de sessions passées par Guardian Angela.';

  @override
  String historyRetentionDays(Object days) {
    return 'Conservation : $days jours';
  }

  @override
  String get backupTitle => 'Sauvegarde';

  @override
  String get backupExport => 'Exporter les données';

  @override
  String get backupImport => 'Importer les données';

  @override
  String get backupNotReady =>
      'La sauvegarde n\'est pas encore disponible. Bientôt disponible.';

  @override
  String get backupPinOptional => 'PIN facultatif (chiffre le paquet)';

  @override
  String get backupImportOk => 'Sauvegarde importée avec succès.';

  @override
  String get backupSelectionHeader => 'Inclure dans l\'export';

  @override
  String get backupToggleSettings => 'Paramètres';

  @override
  String get backupToggleSettingsSubtitle =>
      'Toujours inclus pour permettre la restauration de la sauvegarde.';

  @override
  String get backupToggleContacts => 'Contacts d\'urgence';

  @override
  String get backupToggleModes => 'Modes';

  @override
  String get backupToggleDistressModes => 'Modes de détresse';

  @override
  String get backupToggleTemplates => 'Modèles de rappel';

  @override
  String get backupToggleSessionLogs => 'Historique des sessions';

  @override
  String get backupToggleRecordings => 'Enregistrements audio';

  @override
  String get historyTitle => 'Sessions passées';

  @override
  String get historyEmpty => 'Aucune session passée pour le moment.';

  @override
  String get historyTabReal => 'Réel';

  @override
  String get historyTabSimulated => 'Simulé';

  @override
  String get historySearchHint => 'Rechercher par nom de mode';

  @override
  String get historyFilterModeAll => 'Tous les modes';

  @override
  String get historyFilterModeLabel => 'Mode';

  @override
  String get historyDateRangePick => 'Plage de dates';

  @override
  String get historyDetailTitle => 'Détails de la session';

  @override
  String get evidenceExportTitle => 'Exporter les preuves';

  @override
  String get evidenceExportAsText => 'Copier en texte';

  @override
  String get evidenceExportAsJson => 'Copier en JSON';

  @override
  String get evidenceCopied => 'Copié dans le presse-papiers.';

  @override
  String get aboutTitle => 'À propos';

  @override
  String aboutVersion(Object version) {
    return 'Version';
  }

  @override
  String get aboutCredits =>
      'Conçu avec soin pour celles et ceux qui rentrent chez eux.';

  @override
  String get feedbackTitle => 'Commentaires';

  @override
  String get feedbackBody => 'Nous serions ravis d\'avoir de vos nouvelles.';

  @override
  String get feedbackFieldMessage => 'Message';

  @override
  String get feedbackSend => 'Ouvrir l\'e-mail';

  @override
  String get pickerNoneLabel => '— aucun —';

  @override
  String emergencyConfirmTitle(Object number) {
    return 'Appel de $number';
  }

  @override
  String get emergencyConfirmSubtitle =>
      'Maintenez le bouton d\'annulation pour interrompre.';

  @override
  String emergencyConfirmCountdown(Object seconds) {
    return 'Appel dans $seconds s';
  }

  @override
  String get emergencyConfirmCancel => 'Annuler';

  @override
  String get stealthCalendarUpcoming => 'À venir';

  @override
  String get stealthCalendarUpcomingEvent => 'Réunion';

  @override
  String stealthCalendarUntilEvent(Object minutes) {
    return 'dans $minutes min';
  }

  @override
  String get stealthCalendarToday => 'Aujourd\'hui';

  @override
  String get stealthCalendarEvent1 => 'Café avec Alex';

  @override
  String get stealthCalendarEvent2 => 'Réunion d\'équipe';

  @override
  String get stealthCalendarEvent3 => 'Déjeuner';

  @override
  String get stealthCalendarEvent4 => 'Sport';

  @override
  String get stealthCalendarEvent5 => 'Dîner avec Sam';

  @override
  String get stealthDisarmGestureHint => 'Glisser vers le haut pour terminer';

  @override
  String get stealthMusicTrackTitle => 'Titre inconnu';

  @override
  String get stealthMusicArtist => 'Artiste inconnu';

  @override
  String get stealthMusicAlbum => 'Album inconnu';

  @override
  String get stealthMusicNowPlaying => 'Lecture en cours';

  @override
  String get stealthMusicSwipeHint => 'Glisser pour désactiver';

  @override
  String get stealthMusicPrevious => 'Précédent';

  @override
  String get stealthMusicPause => 'Pause';

  @override
  String get stealthMusicNext => 'Suivant';

  @override
  String get stealthPodcastShowName => 'Podcast';

  @override
  String get stealthPodcastEpisodeTitle => 'Épisode';

  @override
  String get stealthPodcastEpisodesHeader => 'Épisodes';

  @override
  String get stealthPodcastSpeedLabel => '1x';

  @override
  String get stealthPodcastEpisode1 => 'Épisode 1';

  @override
  String get stealthPodcastEpisode2 => 'Épisode 2';

  @override
  String get stealthPodcastEpisode3 => 'Épisode 3';

  @override
  String get stealthPodcastEpisode4 => 'Épisode 4';

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
  String get sessionSimSpeedLabel => 'Vitesse';

  @override
  String sessionSimSpeedValue(Object value) {
    return '${value}x';
  }

  @override
  String get sessionSimSpeedBackgroundCap => 'Limité à 60× en arrière-plan';

  @override
  String get sessionSimAdvancedLabel => 'Avancé';

  @override
  String get sessionSimTriggerPanic => 'Déclencher la panique';

  @override
  String get sessionSimTriggerArrival => 'Simuler l\'arrivée';

  @override
  String get sessionSimTriggerBattery => 'Simuler une batterie faible';

  @override
  String get simulateGpsArrival => 'Simuler l\'arrivée';

  @override
  String get simulateLowBattery => 'Simuler une batterie faible';

  @override
  String get launchGateTitle => 'Déverrouiller Guardian Angela';

  @override
  String get launchGateSubtitle =>
      'Saisissez votre PIN ou utilisez la biométrie.';

  @override
  String get launchGateWrong => 'PIN incorrect';

  @override
  String get launchGateBiometricReason => 'Déverrouiller Guardian Angela';

  @override
  String get launchGateUseBiometric => 'Utiliser la biométrie';

  @override
  String get audioRunningLatePhrase =>
      'Salut, je suis en retard. Je te rappelle bientôt.';

  @override
  String smsDefaultTemplate(Object name, Object location, Object time) {
    return '$name pourrait avoir besoin d\'aide. Emplacement : $location. Heure : $time.';
  }

  @override
  String smsDefaultPreCallTemplate(Object name) {
    return '$name essaie de te joindre. Attends-toi à un appel.';
  }

  @override
  String simLoudAlarm(Object tail) {
    return '[SIM] Alarme sonore + $tail';
  }

  @override
  String get simLoudAlarmTailFlash => 'flash';

  @override
  String get simLoudAlarmTailVibrate => 'vibration';

  @override
  String simSmsContact(Object channel, int count) {
    return '[SIM] Enverrait $channel à $count contacts';
  }

  @override
  String simFakeCallRing(Object caller) {
    return '[SIM] Appel entrant de $caller';
  }

  @override
  String simCountdownWarning(int seconds) {
    return '[SIM] Avertissement de décompte de ${seconds}s';
  }

  @override
  String simPhoneCall(Object name) {
    return '[SIM] Appellerait $name';
  }

  @override
  String get simNoContactToCall => '[SIM] Aucun contact à appeler';

  @override
  String simCallEmergency(Object number) {
    return '[SIM] Composerait $number';
  }

  @override
  String get simHardwareButton => '[SIM] Déclencheur matériel armé';

  @override
  String get simHoldButton => '[SIM] En attente du bouton maintenu';

  @override
  String simDisguisedReminder(Object title) {
    return '[SIM] Afficherait \"$title\"';
  }

  @override
  String get simDisguisedReminderEmpty =>
      '[SIM] Aucun modèle de rappel disponible';

  @override
  String get simGpsArrivalTrigger => '[SIM] Déclencheur d\'arrivée GPS activé';

  @override
  String get simLowBatteryAlert => '[SIM] Alerte de batterie faible déclenchée';

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
  String get pastEventsSearch => 'Search by mode name';

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
  String get modesDistressInUse =>
      'This distress mode is in use by another mode.';

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
}
