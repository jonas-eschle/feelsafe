// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'SafeWayHome';

  @override
  String get startSession => 'Sitzung starten';

  @override
  String get endSession => 'Sitzung beenden';

  @override
  String get imSafe => 'Mir geht\'s gut';

  @override
  String get checkInPrompt => 'Bist du noch sicher?';

  @override
  String countdownWarning(int seconds) {
    return 'Tippe um zu bestätigen (${seconds}s)';
  }

  @override
  String get holdToStaySafe => 'Halten um sicher zu bleiben';

  @override
  String get releaseDetected => 'Loslassen erkannt';

  @override
  String get fakeCallIncoming => 'Eingehender Anruf...';

  @override
  String get fakeCallAnswer => 'Annehmen';

  @override
  String get fakeCallDecline => 'Ablehnen';

  @override
  String get emergencyContacts => 'Notfallkontakte';

  @override
  String get addContact => 'Kontakt hinzufügen';

  @override
  String get editContact => 'Kontakt bearbeiten';

  @override
  String get contactName => 'Name';

  @override
  String get contactPhone => 'Telefonnummer';

  @override
  String get contactRelationship => 'Beziehung';

  @override
  String get preferredChannel => 'Bevorzugter Kanal';

  @override
  String get sms => 'SMS';

  @override
  String get whatsapp => 'WhatsApp';

  @override
  String get telegram => 'Telegram';

  @override
  String get phoneCall => 'Anruf';

  @override
  String get phoneCallDescription => 'Rufe deinen Kontakt direkt an';

  @override
  String get settings => 'Einstellungen';

  @override
  String get darkTheme => 'Dunkles Design';

  @override
  String get lightTheme => 'Helles Design';

  @override
  String get language => 'Sprache';

  @override
  String get escalationChain => 'Eskalationskette';

  @override
  String get reminderTemplates => 'Erinnerungsvorlagen';

  @override
  String get modes => 'Modi';

  @override
  String get walkMode => 'Gehmodus';

  @override
  String get dateMode => 'Date-Modus';

  @override
  String get customMode => 'Benutzerdefinierter Modus';

  @override
  String get createMode => 'Modus erstellen';

  @override
  String get editMode => 'Modus bearbeiten';

  @override
  String get checkInMechanism => 'Check-in-Methode';

  @override
  String get holdButton => 'Taste halten';

  @override
  String get disguisedReminder => 'Getarnte Erinnerung';

  @override
  String get checkInInterval => 'Check-in-Intervall';

  @override
  String get missedTolerance => 'Verpasste Toleranz';

  @override
  String get fakeCallSettings => 'Fake-Anruf-Einstellungen';

  @override
  String get callerName => 'Anrufername';

  @override
  String get callerPhoto => 'Anruferfoto';

  @override
  String get voiceRecording => 'Sprachaufnahme';

  @override
  String get ringDuration => 'Klingeldauer';

  @override
  String get stepCountdownWarning => 'Countdown-Warnung';

  @override
  String get stepDisguisedReminder => 'Getarnte Erinnerung';

  @override
  String get stepFakeCall => 'Fake-Anruf';

  @override
  String get stepSmsContacts => 'SMS an Kontakte';

  @override
  String get stepLoudAlarm => 'Lauter Alarm';

  @override
  String get stepCallEmergency => 'Notruf';

  @override
  String get emergencyNumber => 'Notrufnummer';

  @override
  String get onboardingWelcome => 'Willkommen bei SafeWayHome';

  @override
  String get onboardingDescription =>
      'Dein persönlicher Sicherheitsbegleiter. Füge einen Notfallkontakt hinzu.';

  @override
  String get onboardingSelectMode => 'Wähle deinen Standardmodus';

  @override
  String get onboardingSelectModeDescription =>
      'Gehmodus überwacht dich auf dem Heimweg. Date-Modus sendet diskrete Check-ins bei Treffen oder Dates.';

  @override
  String get onboardingAddContact => 'Notfallkontakt hinzufügen';

  @override
  String get onboardingAddContactDescription =>
      'Diese Person wird benachrichtigt, wenn du dich nicht meldest.';

  @override
  String get onboardingPermissions => 'Berechtigungen erteilen';

  @override
  String get onboardingPermissionsDescription =>
      'SafeWayHome benötigt Standort-, Telefon- und SMS-Zugriff für deine Sicherheit.';

  @override
  String get onboardingGetStarted => 'Los geht\'s';

  @override
  String get onboardingNext => 'Weiter';

  @override
  String get onboardingSkip => 'Überspringen';

  @override
  String get onboardingBack => 'Zurück';

  @override
  String get permissionLocation => 'Standort';

  @override
  String get permissionPhone => 'Telefon';

  @override
  String get permissionSms => 'SMS';

  @override
  String get permissionGranted => 'Erteilt';

  @override
  String get permissionDenied => 'Verweigert';

  @override
  String get grantPermissions => 'Berechtigungen erteilen';

  @override
  String get permissionsNeeded => 'Berechtigungen erforderlich';

  @override
  String get save => 'Speichern';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get delete => 'Löschen';

  @override
  String get enabled => 'Aktiviert';

  @override
  String get disabled => 'Deaktiviert';

  @override
  String seconds(int count) {
    return '${count}s';
  }

  @override
  String minutes(int count) {
    return '$count Min';
  }

  @override
  String get sessionActive => 'Sitzung aktiv';

  @override
  String sessionElapsed(String time) {
    return 'Vergangen: $time';
  }

  @override
  String smsMessage(String name, String locationUrl, String time) {
    return '$name braucht möglicherweise Hilfe.\nLetzter bekannter Standort: $locationUrl\nZeit: $time';
  }

  @override
  String get noContactsYet => 'Noch keine Notfallkontakte';

  @override
  String get deleteContactConfirmTitle => 'Kontakt löschen';

  @override
  String deleteContactConfirmMessage(String name) {
    return 'Möchtest du $name wirklich löschen?';
  }

  @override
  String get fieldRequired => 'Dieses Feld ist erforderlich';

  @override
  String get invalidPhoneNumber => 'Gib eine gültige Telefonnummer ein';

  @override
  String get contactSaved => 'Kontakt gespeichert';

  @override
  String get contactDeleted => 'Kontakt gelöscht';

  @override
  String get slideToAnswer => 'Zum Annehmen wischen';

  @override
  String get fakeCallActive => 'Anruf...';

  @override
  String get choosePhoto => 'Foto auswählen';

  @override
  String get removePhoto => 'Entfernen';

  @override
  String get noFileSelected => 'Keine';

  @override
  String get templateCalendar => 'Kalenderereignis';

  @override
  String get templateDuolingo => 'Sprachlektion';

  @override
  String get templateDelivery => 'Lieferupdate';

  @override
  String get templateWeather => 'Wetterwarnung';

  @override
  String get templateFitness => 'Fitness-Erinnerung';

  @override
  String get templateMessage => 'Nachrichtenvorschau';

  @override
  String get templateAppUpdate => 'App-Update';

  @override
  String get templateBattery => 'Akkuwarnung';

  @override
  String get emergencyNumberSetup => 'Notrufnummer';

  @override
  String get emergencyNumberDescription =>
      'Diese Nummer wird als letzter Ausweg angerufen, wenn du nicht reagierst';

  @override
  String get skipStep => 'Überspringen';

  @override
  String get skipStepWarning => 'Wir empfehlen, diesen Schritt abzuschließen';

  @override
  String get createCustomMode => 'Eigenen erstellen';

  @override
  String get templateSubtitle => 'Untertitel';

  @override
  String get templateImage => 'Eigenes Bild';
}
