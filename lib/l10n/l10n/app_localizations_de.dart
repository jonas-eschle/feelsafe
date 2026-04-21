// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Guardian Angela';

  @override
  String get commonSave => 'Speichern';

  @override
  String get commonCancel => 'Abbrechen';

  @override
  String get commonDelete => 'Löschen';

  @override
  String get commonEdit => 'Bearbeiten';

  @override
  String get commonAdd => 'Hinzufügen';

  @override
  String get commonClose => 'Schließen';

  @override
  String get commonConfirm => 'Bestätigen';

  @override
  String get commonBack => 'Zurück';

  @override
  String get commonDone => 'Fertig';

  @override
  String get commonRetry => 'Wiederholen';

  @override
  String get commonYes => 'Ja';

  @override
  String get commonNo => 'Nein';

  @override
  String get commonEnabled => 'Aktiviert';

  @override
  String get commonDisabled => 'Deaktiviert';

  @override
  String get commonNone => 'Keine';

  @override
  String get commonSeconds => 'Sekunden';

  @override
  String get commonMinutes => 'Minuten';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get homeTitle => 'Guardian Angela';

  @override
  String get homeStartSession => 'Sitzung starten';

  @override
  String get homeSimulate => 'Simulieren';

  @override
  String get homeActiveSession => 'Aktive Sitzung';

  @override
  String get homeResumeSession => 'Fortsetzen';

  @override
  String get homeNoModes =>
      'Noch keine Modi. Tippe auf „Modi“, um einen anzulegen.';

  @override
  String get homeNoContacts =>
      'Noch keine Notfallkontakte. Tippe auf „Kontakte“, um einen anzulegen.';

  @override
  String get homeMenuSettings => 'Einstellungen';

  @override
  String get homeMenuContacts => 'Kontakte';

  @override
  String get homeMenuModes => 'Modi';

  @override
  String get homeMenuHistory => 'Vergangene Sitzungen';

  @override
  String get homeSelectMode => 'Modus wählen';

  @override
  String get onboardingWelcomeTitle => 'Willkommen bei Guardian Angela';

  @override
  String get onboardingWelcomeBody =>
      'Eine Begleiterin, die dich auf dem Heimweg sicher hält. Guardian Angela wacht über dich beim Gehen, Laufen oder Reisen und kann deine Vertrauenspersonen alarmieren, wenn du Hilfe brauchst.';

  @override
  String get onboardingProfileTitle => 'Profil & erster Kontakt';

  @override
  String get onboardingProfileBody =>
      'Erzähl uns etwas über dich, damit Guardian Angela im Notfall hilfreiche Informationen weitergeben kann. Füge dann eine Vertrauensperson hinzu.';

  @override
  String get onboardingPermissionsTitle => 'Berechtigungen';

  @override
  String get onboardingPermissionsBody =>
      'Guardian Angela benötigt einige Berechtigungen, um dich schützen zu können. Erteile sie jetzt oder später in den Einstellungen.';

  @override
  String get onboardingNext => 'Weiter';

  @override
  String get onboardingSkip => 'Überspringen';

  @override
  String get onboardingFinish => 'Fertig';

  @override
  String get sessionTitle => 'Sitzung';

  @override
  String get sessionDisarm => 'Ich bin sicher';

  @override
  String get sessionPause => 'Pause';

  @override
  String get sessionResume => 'Fortsetzen';

  @override
  String get sessionHoldPrompt => 'Halten, um sicher zu bleiben';

  @override
  String get sessionHoldSemantic =>
      'Halte gedrückt. Loslassen startet eine Kulanzzeit.';

  @override
  String sessionStepLabel(Object index, Object total) {
    return 'Schritt $index von $total';
  }

  @override
  String sessionMissCount(Object count) {
    return 'Verpasst: $count';
  }

  @override
  String sessionRemaining(Object seconds) {
    return 'Noch $seconds s';
  }

  @override
  String get sessionPausedBadge => 'Pausiert';

  @override
  String get sessionPhaseEnded => 'Sitzung beendet';

  @override
  String get sessionSimulationBanner => 'Simulation';

  @override
  String get sessionCompletedTitle => 'Sitzung abgeschlossen';

  @override
  String get sessionCompletedBody =>
      'Du bist sicher angekommen. Guardian Angela beendet die Überwachung.';

  @override
  String get sessionCompletedReturnHome => 'Zurück zur Startseite';

  @override
  String get simulationSummaryTitle => 'Simulations-Zusammenfassung';

  @override
  String get simulationSummaryEmpty =>
      'In dieser Simulation wurden keine Schritte ausgelöst.';

  @override
  String get simulationSummaryReturn => 'Zurück zur Startseite';

  @override
  String get fakeCallTitle => 'Eingehender Anruf';

  @override
  String get fakeCallAnswer => 'Annehmen';

  @override
  String get fakeCallDecline => 'Ablehnen';

  @override
  String get fakeCallHangUp => 'Auflegen';

  @override
  String get contactsTitle => 'Notfallkontakte';

  @override
  String get contactsEmpty =>
      'Noch keine Kontakte. Füge einen hinzu, um Notfallnachrichten zu empfangen.';

  @override
  String get contactsAdd => 'Kontakt hinzufügen';

  @override
  String get contactFormTitleCreate => 'Neuer Kontakt';

  @override
  String get contactFormTitleEdit => 'Kontakt bearbeiten';

  @override
  String get contactFieldName => 'Name';

  @override
  String get contactFieldPhone => 'Telefonnummer';

  @override
  String get contactFieldRelationship => 'Beziehung (optional)';

  @override
  String get contactFieldLanguage => 'SMS-Sprache (optional)';

  @override
  String get contactChannelsHeader => 'Nachrichtenkanäle';

  @override
  String get contactChannelSms => 'SMS';

  @override
  String get contactChannelWhatsapp => 'WhatsApp';

  @override
  String get contactChannelTelegram => 'Telegram';

  @override
  String get contactChannelPhone => 'Anruf';

  @override
  String get contactDeleteConfirm => 'Kontakt löschen?';

  @override
  String contactDeleteBody(Object name) {
    return '$name wird aus deiner Notfallliste entfernt.';
  }

  @override
  String get contactRequiredError =>
      'Name und Telefonnummer sind erforderlich.';

  @override
  String get modesTitle => 'Modi';

  @override
  String get modesEmpty =>
      'Noch keine Modi. Tippe auf „Hinzufügen“, um einen Modus zu erstellen.';

  @override
  String get modesAdd => 'Modus hinzufügen';

  @override
  String get modeEditorTitleCreate => 'Neuer Modus';

  @override
  String get modeEditorTitleEdit => 'Modus bearbeiten';

  @override
  String get modeFieldName => 'Name';

  @override
  String get modeFieldCheckInType => 'Check-in-Art';

  @override
  String get modeFieldDistressChain => 'Notfallkette';

  @override
  String get modeFieldDistressChainDefault => 'Standard verwenden';

  @override
  String get modeChainHeader => 'Eskalationskette';

  @override
  String get modeChainAddStep => 'Schritt hinzufügen';

  @override
  String get modeChainEmpty =>
      'Noch keine Schritte. Tippe auf „Schritt hinzufügen“.';

  @override
  String get stepTypeHoldButton => 'Halte-Taste';

  @override
  String get stepTypeDisguisedReminder => 'Getarnte Erinnerung';

  @override
  String get stepTypeCountdownWarning => 'Countdown-Warnung';

  @override
  String get stepTypeFakeCall => 'Fake-Anruf';

  @override
  String get stepTypeSmsContact => 'SMS an Kontakt';

  @override
  String get stepTypePhoneCallContact => 'Kontakt anrufen';

  @override
  String get stepTypeLoudAlarm => 'Lauter Alarm';

  @override
  String get stepTypeCallEmergency => 'Notruf wählen';

  @override
  String get stepTypeHardwareButton => 'Hardware-Taste';

  @override
  String get stepFieldDuration => 'Dauer (Sekunden)';

  @override
  String get stepFieldGrace => 'Kulanzzeit (Sekunden)';

  @override
  String get stepFieldWait => 'Wartezeit (Sekunden)';

  @override
  String get stepFieldRetryCount => 'Wiederholungen';

  @override
  String get stepFieldRandomize => 'Zeit-Streuung';

  @override
  String get stepPreview => 'In Simulation testen';

  @override
  String stepPreviewFired(Object description) {
    return 'Vorschau ausgeführt: $description';
  }

  @override
  String get stepConfigFakeCallCaller => 'Name des Anrufers';

  @override
  String get stepConfigFakeCallDecline => 'Ablehnen zählt als Entwarnung';

  @override
  String get stepConfigLoudAlarmFlash => 'Bildschirm blinken lassen';

  @override
  String get stepConfigLoudAlarmVolume => 'Maximale Lautstärke';

  @override
  String get stepConfigCountdownVibrate => 'Vibrieren';

  @override
  String get stepConfigCountdownTone => 'Ton abspielen';

  @override
  String get stepConfigSmsSelection => 'Empfänger';

  @override
  String get stepConfigSmsAllContacts => 'Alle Kontakte';

  @override
  String get stepConfigSmsSpecific => 'Bestimmte Kontakte';

  @override
  String get stepConfigSmsIncludeLocation => 'Standort mitsenden';

  @override
  String get stepConfigSmsIncludeMedical => 'Medizinische Infos mitsenden';

  @override
  String get stepConfigHoldReleaseSensitivity => 'Loslass-Empfindlichkeit (s)';

  @override
  String get stepConfigReminderInterval => 'Erinnerungsintervall (Sekunden)';

  @override
  String get stepConfigReminderTemplate => 'Vorlage';

  @override
  String get stepConfigHardwarePattern => 'Muster';

  @override
  String get stepConfigHardwarePressCount => 'Anzahl Tastendrücke';

  @override
  String get stepConfigHardwareButton => 'Taste';

  @override
  String get stepConfigHardwareButtonVolumeUp => 'Lauter';

  @override
  String get stepConfigHardwareButtonVolumeDown => 'Leiser';

  @override
  String get stepConfigHardwareButtonPower => 'Power';

  @override
  String get stepConfigHardwarePatternRepeat => 'Mehrfaches Drücken';

  @override
  String get stepConfigHardwarePatternLong => 'Langes Drücken';

  @override
  String get stepConfigEmergencyNumber => 'Notrufnummer überschreiben';

  @override
  String get stepConfigEmergencyConfirm => 'Vor Anruf bestätigen';

  @override
  String get stepConfigPhonePreSms => 'SMS vor Anruf senden';

  @override
  String get distressChainsTitle => 'Notfallketten';

  @override
  String get distressChainsEmpty => 'Noch keine Notfallketten.';

  @override
  String get distressChainsAdd => 'Kette hinzufügen';

  @override
  String get distressChainEditorTitleCreate => 'Neue Notfallkette';

  @override
  String get distressChainEditorTitleEdit => 'Notfallkette bearbeiten';

  @override
  String get distressChainName => 'Name der Kette';

  @override
  String get distressCountdown => 'Notfallkette wird ausgelöst ...';

  @override
  String get distressCountdownStealth => 'Bitte warten ...';

  @override
  String get templatesTitle => 'Erinnerungs-Vorlagen';

  @override
  String get templatesEmpty => 'Noch keine Vorlagen.';

  @override
  String get templatesAdd => 'Vorlage hinzufügen';

  @override
  String get templateEditorTitleCreate => 'Neue Vorlage';

  @override
  String get templateEditorTitleEdit => 'Vorlage bearbeiten';

  @override
  String get templateFieldName => 'Editor-Name';

  @override
  String get templateFieldTitle => 'Titel der Erinnerung';

  @override
  String get templateFieldBody => 'Text der Erinnerung';

  @override
  String get templateFieldConfirmationType => 'Bestätigungsart';

  @override
  String get templateFieldKeyword => 'Stichwort';

  @override
  String get templateFieldButtonLabel => 'Button-Beschriftung';

  @override
  String get templateFieldDisplayStyle => 'Anzeige-Stil';

  @override
  String get templateConfirmTapButton => 'Button tippen';

  @override
  String get templateConfirmTapWord => 'Wort tippen';

  @override
  String get templateConfirmSwipe => 'Wischen';

  @override
  String get templateConfirmDismiss => 'Schließen';

  @override
  String get templateDisplayFullscreen => 'Vollbild';

  @override
  String get templateDisplaySubtle => 'Unauffällig';

  @override
  String get profileTitle => 'Profil';

  @override
  String get profileFieldName => 'Name';

  @override
  String get profileFieldAge => 'Alter';

  @override
  String get profileFieldBloodType => 'Blutgruppe';

  @override
  String get profileFieldAllergies => 'Allergien';

  @override
  String get profileFieldMedications => 'Medikamente';

  @override
  String get profileFieldConditions => 'Vorerkrankungen';

  @override
  String get profileFieldInstructions => 'Notfall-Hinweise';

  @override
  String get profileAddItem => 'Eintrag hinzufügen';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get settingsSectionSecurity => 'Sicherheit';

  @override
  String get settingsSectionStealth => 'Tarnmodus';

  @override
  String get settingsSectionDefaults => 'Standardwerte';

  @override
  String get settingsSectionHistory => 'Verlauf';

  @override
  String get settingsSectionBackup => 'Sicherung';

  @override
  String get settingsSectionAbout => 'Über';

  @override
  String get settingsSectionFeedback => 'Feedback';

  @override
  String get settingsSectionContacts => 'Kontakte';

  @override
  String get settingsSectionModes => 'Modi';

  @override
  String get settingsSectionProfile => 'Profil';

  @override
  String get settingsSectionDistressChains => 'Notfallketten';

  @override
  String get settingsSectionReminderTemplates => 'Erinnerungs-Vorlagen';

  @override
  String get settingsSectionBatteryAlert => 'Akku-Warnung';

  @override
  String get settingsSectionEventDefaults => 'Schritt-Standardwerte';

  @override
  String get settingsSectionGpsLogging => 'GPS-Aufzeichnung';

  @override
  String get settingsSectionNotifications => 'Benachrichtigungen';

  @override
  String get settingsSectionHistoryRetention => 'Verlauf-Aufbewahrung';

  @override
  String get settingsSectionAppearance => 'Darstellung';

  @override
  String get settingsThemeMode => 'Design';

  @override
  String get settingsThemeLight => 'Hell';

  @override
  String get settingsThemeDark => 'Dunkel';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsLanguage => 'Sprache';

  @override
  String get settingsEmergencyNumber => 'Notrufnummer';

  @override
  String get settingsAlarmDnd => 'Alarm überschreibt „Nicht stören“';

  @override
  String get securityTitle => 'Sicherheit';

  @override
  String get securityAppPin => 'App-PIN';

  @override
  String get securitySessionEndPin => 'Sitzungsende-PIN';

  @override
  String get securityDuressPin => 'Notfall-PIN';

  @override
  String get securityPinTimeout => 'PIN-Timeout (Sekunden)';

  @override
  String get securityDisablePin => 'Deaktivieren';

  @override
  String get securitySetPin => 'PIN festlegen';

  @override
  String get securityChangePin => 'PIN ändern';

  @override
  String get pinSetupTitle => 'PIN festlegen';

  @override
  String get pinSetupEnter => 'Neue PIN eingeben';

  @override
  String get pinSetupConfirm => 'PIN bestätigen';

  @override
  String get pinSetupMismatch =>
      'PINs stimmen nicht überein. Versuche es erneut.';

  @override
  String get pinEntryTitle => 'PIN eingeben';

  @override
  String get pinEntrySubtitle => 'Gib deine PIN ein, um fortzufahren.';

  @override
  String get stealthTitle => 'Tarnmodus';

  @override
  String get stealthEnable => 'Tarnmodus aktivieren';

  @override
  String get stealthFakeName => 'Getarnter App-Name';

  @override
  String get stealthFakeIcon => 'Getarntes Symbol';

  @override
  String get stealthNotificationDisguise => 'Benachrichtigungen tarnen';

  @override
  String get stealthTimerDisplay => 'Timer im Tarnmodus anzeigen';

  @override
  String get stealthSessionScreen => 'Branding im Sitzungsbildschirm entfernen';

  @override
  String get stealthPickerTitle => 'App-Symbol';

  @override
  String get stealthPickerIntro =>
      'Wähle, wie das Symbol im Launcher aussieht.';

  @override
  String get stealthPresetMusic => 'Musik';

  @override
  String get stealthPresetCalendar => 'Kalender';

  @override
  String get stealthPresetFitness => 'Fitness';

  @override
  String get stealthPresetWeather => 'Wetter';

  @override
  String get stealthPresetNews => 'Nachrichten';

  @override
  String get stealthPresetPhotos => 'Fotos';

  @override
  String get stealthPresetNotes => 'Notizen';

  @override
  String get stealthPresetClock => 'Uhr';

  @override
  String get distressConfirmationTitle => 'Bist du in Gefahr?';

  @override
  String get distressConfirmationCancel => 'Abbrechen';

  @override
  String distressConfirmationCountdown(Object seconds) {
    return 'Notfallkette startet in $seconds s';
  }

  @override
  String get imSafeSliderLabel => 'Wischen, um „Ich bin sicher“ zu bestätigen';

  @override
  String get batteryAlertTitle => 'Akku-Warnung';

  @override
  String get batteryAlertEnable => 'Akku-Warnung aktivieren';

  @override
  String batteryAlertThreshold(Object percent) {
    return 'Schwelle: $percent%';
  }

  @override
  String get eventDefaultsTitle => 'Schritt-Standardwerte';

  @override
  String get eventDefaultsBody =>
      'Diese Standardwerte gelten für jeden Schritt, der sie nicht überschreibt.';

  @override
  String get gpsLoggingTitle => 'GPS-Aufzeichnung';

  @override
  String get gpsLoggingEnable => 'GPS-Aufzeichnung aktivieren';

  @override
  String get gpsLoggingInterval => 'Abtastintervall (Sekunden)';

  @override
  String get gpsLoggingAccuracy => 'Genauigkeit';

  @override
  String get gpsAccuracyLow => 'Niedrig';

  @override
  String get gpsAccuracyMedium => 'Mittel';

  @override
  String get gpsAccuracyHigh => 'Hoch';

  @override
  String get gpsLoggingIncludeSms => 'Standort an SMS anhängen';

  @override
  String get gpsLoggingHistoryDays => 'Verlauf-Aufbewahrung (Tage)';

  @override
  String get notificationSettingsTitle => 'Benachrichtigungen';

  @override
  String get notificationSettingsBody =>
      'Guardian Angela nutzt Benachrichtigungen zur Tarnung und zur Steuerung von Erinnerungen.';

  @override
  String get historyRetentionTitle => 'Verlauf-Aufbewahrung';

  @override
  String get historyRetentionBody =>
      'Wie lange Guardian Angela Protokolle vergangener Sitzungen aufbewahrt.';

  @override
  String historyRetentionDays(Object days) {
    return 'Aufbewahrung: $days Tage';
  }

  @override
  String get backupTitle => 'Sicherung';

  @override
  String get backupExport => 'Daten exportieren';

  @override
  String get backupImport => 'Daten importieren';

  @override
  String get backupNotReady => 'Sicherung ist noch nicht verfügbar. Demnächst.';

  @override
  String get backupPinOptional => 'Optionale PIN (verschlüsselt das Paket)';

  @override
  String get backupImportOk => 'Sicherung erfolgreich importiert.';

  @override
  String get historyTitle => 'Vergangene Sitzungen';

  @override
  String get historyEmpty => 'Noch keine vergangenen Sitzungen.';

  @override
  String get historyDetailTitle => 'Sitzungs-Details';

  @override
  String get evidenceExportTitle => 'Beweise exportieren';

  @override
  String get evidenceExportAsText => 'Als Text kopieren';

  @override
  String get evidenceExportAsJson => 'Als JSON kopieren';

  @override
  String get evidenceCopied => 'In die Zwischenablage kopiert.';

  @override
  String get aboutTitle => 'Über';

  @override
  String get aboutVersion => 'Version';

  @override
  String get aboutCredits =>
      'Mit Sorgfalt entwickelt für Menschen auf dem Heimweg.';

  @override
  String get feedbackTitle => 'Feedback';

  @override
  String get feedbackBody => 'Wir freuen uns, von dir zu hören.';

  @override
  String get feedbackFieldMessage => 'Nachricht';

  @override
  String get feedbackSend => 'E-Mail öffnen';

  @override
  String get pickerNoneLabel => '— keine —';
}
