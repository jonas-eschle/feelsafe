// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'SafeWayHome';

  @override
  String get startSession => 'Démarrer la session';

  @override
  String get endSession => 'Terminer la session';

  @override
  String get imSafe => 'Ça va';

  @override
  String get checkInPrompt => 'Tu es toujours en sécurité ?';

  @override
  String countdownWarning(int seconds) {
    return 'Appuie pour confirmer (${seconds}s)';
  }

  @override
  String get holdToStaySafe => 'Maintiens pour rester en sécurité';

  @override
  String get releaseDetected => 'Relâchement détecté';

  @override
  String get fakeCallIncoming => 'Appel entrant...';

  @override
  String get fakeCallAnswer => 'Répondre';

  @override
  String get fakeCallDecline => 'Refuser';

  @override
  String get emergencyContacts => 'Contacts d\'urgence';

  @override
  String get addContact => 'Ajouter un contact';

  @override
  String get editContact => 'Modifier le contact';

  @override
  String get contactName => 'Nom';

  @override
  String get contactPhone => 'Numéro de téléphone';

  @override
  String get contactRelationship => 'Lien';

  @override
  String get preferredChannel => 'Canal préféré';

  @override
  String get sms => 'SMS';

  @override
  String get whatsapp => 'WhatsApp';

  @override
  String get telegram => 'Telegram';

  @override
  String get phoneCall => 'Appel téléphonique';

  @override
  String get phoneCallDescription => 'Appeler directement ton contact';

  @override
  String get settings => 'Paramètres';

  @override
  String get darkTheme => 'Thème sombre';

  @override
  String get lightTheme => 'Thème clair';

  @override
  String get language => 'Langue';

  @override
  String get escalationChain => 'Chaîne d\'escalade';

  @override
  String get reminderTemplates => 'Modèles de rappel';

  @override
  String get modes => 'Modes';

  @override
  String get walkMode => 'Mode trajet';

  @override
  String get dateMode => 'Mode rendez-vous';

  @override
  String get customMode => 'Mode personnalisé';

  @override
  String get createMode => 'Créer un mode';

  @override
  String get editMode => 'Modifier le mode';

  @override
  String get checkInMechanism => 'Méthode de check-in';

  @override
  String get holdButton => 'Maintien du bouton';

  @override
  String get disguisedReminder => 'Rappel déguisé';

  @override
  String get checkInInterval => 'Intervalle de check-in';

  @override
  String get missedTolerance => 'Tolérance aux check-ins manqués';

  @override
  String get fakeCallSettings => 'Paramètres du faux appel';

  @override
  String get callerName => 'Nom de l\'appelant';

  @override
  String get callerPhoto => 'Photo de l\'appelant';

  @override
  String get voiceRecording => 'Enregistrement vocal';

  @override
  String get ringDuration => 'Durée de sonnerie';

  @override
  String get stepCountdownWarning => 'Compte à rebours';

  @override
  String get stepDisguisedReminder => 'Rappel déguisé';

  @override
  String get stepFakeCall => 'Faux appel';

  @override
  String get stepSmsContacts => 'SMS aux contacts';

  @override
  String get stepLoudAlarm => 'Alarme forte';

  @override
  String get stepCallEmergency => 'Appel aux urgences';

  @override
  String get emergencyNumber => 'Numéro d\'urgence';

  @override
  String get onboardingWelcome => 'Bienvenue sur SafeWayHome';

  @override
  String get onboardingDescription =>
      'Ton compagnon de sécurité personnel. Ajoute un contact d\'urgence pour commencer.';

  @override
  String get onboardingSelectMode => 'Choisis ton mode par défaut';

  @override
  String get onboardingSelectModeDescription =>
      'Le mode trajet te surveille sur le chemin du retour. Le mode rendez-vous envoie des check-ins discrets pendant tes sorties.';

  @override
  String get onboardingAddContact => 'Ajoute un contact d\'urgence';

  @override
  String get onboardingAddContactDescription =>
      'Cette personne sera prévenue si tu ne réponds pas.';

  @override
  String get onboardingPermissions => 'Accorde les permissions';

  @override
  String get onboardingPermissionsDescription =>
      'SafeWayHome a besoin d\'accéder à ta localisation, ton téléphone et tes SMS pour assurer ta sécurité.';

  @override
  String get onboardingGetStarted => 'C\'est parti';

  @override
  String get onboardingNext => 'Suivant';

  @override
  String get onboardingSkip => 'Passer';

  @override
  String get onboardingBack => 'Retour';

  @override
  String get permissionLocation => 'Localisation';

  @override
  String get permissionPhone => 'Téléphone';

  @override
  String get permissionSms => 'SMS';

  @override
  String get permissionGranted => 'Accordée';

  @override
  String get permissionDenied => 'Refusée';

  @override
  String get grantPermissions => 'Accorder les permissions';

  @override
  String get permissionsNeeded => 'Permissions requises';

  @override
  String get save => 'Enregistrer';

  @override
  String get cancel => 'Annuler';

  @override
  String get delete => 'Supprimer';

  @override
  String get enabled => 'Activé';

  @override
  String get disabled => 'Désactivé';

  @override
  String seconds(int count) {
    return '${count}s';
  }

  @override
  String minutes(int count) {
    return '$count min';
  }

  @override
  String get sessionActive => 'Session active';

  @override
  String sessionElapsed(String time) {
    return 'Écoulé : $time';
  }

  @override
  String smsMessage(String name, String locationUrl, String time) {
    return '$name a peut-être besoin d\'aide.\nDernière position connue : $locationUrl\nHeure : $time';
  }

  @override
  String get noContactsYet => 'Aucun contact d\'urgence pour l\'instant';

  @override
  String get deleteContactConfirmTitle => 'Supprimer le contact';

  @override
  String deleteContactConfirmMessage(String name) {
    return 'Tu veux vraiment supprimer $name ?';
  }

  @override
  String get fieldRequired => 'Ce champ est obligatoire';

  @override
  String get invalidPhoneNumber => 'Entre un numéro de téléphone valide';

  @override
  String get contactSaved => 'Contact enregistré';

  @override
  String get contactDeleted => 'Contact supprimé';

  @override
  String get slideToAnswer => 'Glisse pour répondre';

  @override
  String get fakeCallActive => 'Appel en cours...';

  @override
  String get choosePhoto => 'Choisir une photo';

  @override
  String get removePhoto => 'Supprimer';

  @override
  String get noFileSelected => 'Aucun';

  @override
  String get templateCalendar => 'Événement du calendrier';

  @override
  String get templateDuolingo => 'Leçon de langue';

  @override
  String get templateDelivery => 'Mise à jour de livraison';

  @override
  String get templateWeather => 'Alerte météo';

  @override
  String get templateFitness => 'Rappel fitness';

  @override
  String get templateMessage => 'Aperçu du message';

  @override
  String get templateAppUpdate => 'Mise à jour de l\'appli';

  @override
  String get templateBattery => 'Alerte batterie';

  @override
  String get emergencyNumberSetup => 'Numéro d\'urgence';

  @override
  String get emergencyNumberDescription =>
      'Ce numéro sera appelé en dernier recours si tu ne réponds pas';

  @override
  String get skipStep => 'Passer';

  @override
  String get skipStepWarning => 'On te recommande de compléter cette étape';

  @override
  String get createCustomMode => 'Créer un mode perso';

  @override
  String get templateSubtitle => 'Sous-titre';

  @override
  String get templateImage => 'Image personnalisée';
}
