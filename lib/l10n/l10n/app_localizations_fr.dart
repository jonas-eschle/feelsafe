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
  String homeContactsBannerFew(int count) {
    return '$count contact(s) configuré(s). Nous en recommandons au moins 3.';
  }

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
  String get modesTitle => 'Modes';

  @override
  String get modesEmpty =>
      'Aucun mode pour le moment. Appuyez sur Ajouter pour créer un mode.';

  @override
  String get modesAdd => 'Ajouter un mode';

  @override
  String get modeEditorTitleCreate => 'Nouveau mode';

  @override
  String get modeEditorTitleEdit => 'Modifier le mode';

  @override
  String get modeFieldName => 'Nom';

  @override
  String get modeFieldCheckInType => 'Type de vérification';

  @override
  String get modeFieldDistressMode => 'Mode de détresse';

  @override
  String get modeFieldDistressModeDefault => 'Utiliser par défaut';

  @override
  String get modeChainHeader => 'Chaîne d\'escalade';

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
  String get stepFieldRetryCount => 'Nouvelles tentatives';

  @override
  String get stepFieldRandomize => 'Variation temporelle';

  @override
  String get stepPreview => 'Aperçu en simulation';

  @override
  String stepPreviewFired(Object description) {
    return 'Aperçu exécuté : $description';
  }

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
  String get aboutVersion => 'Version';

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
}
