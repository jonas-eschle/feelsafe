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
  String get angelaDialogTitle => 'Alte PIN eingegeben';

  @override
  String get angelaDialogBody =>
      'Es scheint, dass Sie eine alte PIN verwendet haben. Möchten Sie wirklich fortfahren?';

  @override
  String get angelaDialogCancel => 'Abbrechen';

  @override
  String get angelaDialogConfirm => 'Weiter';

  @override
  String get commonCancel => 'Abbrechen';

  @override
  String get commonOk => 'OK';

  @override
  String get profileAngelaWarningTitle => 'Hinweis zum Namen „Angela“';

  @override
  String get profileAngelaWarningBody =>
      'Guardian Angela verwendet „Angela“ als Sicherheits-Stichwort. Wenn Sie es als Ihren eigenen Namen verwenden, kann dies zu Verwechslungen führen. Trotzdem speichern?';

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
  String get pinSubmit => 'Bestätigen';

  @override
  String get homeTitle => 'Guardian Angela';

  @override
  String get homeStartSession => 'Sitzung starten';

  @override
  String get homeStartConfirmTitle => 'Sitzung starten?';

  @override
  String get homeStartConfirmBody =>
      'Stellen Sie sicher, dass Ihre Kontakte und Ihre PIN konfiguriert sind. Die Sitzung läuft im Vordergrund und Ihr ausgewählter Modus leitet die Check-ins.';

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
  String get homeContactsBannerNone => 'Keine Notfallkontakte konfiguriert.';

  @override
  String homeContactsBannerFew(int count) {
    return '$count Kontakt(e) konfiguriert. Wir empfehlen mindestens 3.';
  }

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
  String get sessionCheckIn => 'Ich bin eingecheckt';

  @override
  String get sessionDisarmTriggerTitle => 'Entwarnungs-Auslöser aktiviert';

  @override
  String get sessionDisarmTriggerBody =>
      'Ein Entwarnungs-Auslöser wurde aktiviert. Sitzung beenden?';

  @override
  String get sessionDisarmTriggerConfirm => 'Sitzung beenden';

  @override
  String get sessionDisarmTriggerCancel => 'Weiter';

  @override
  String get wrongPinAngelaTitle => 'Alte PIN von Angela';

  @override
  String get wrongPinAngelaBody =>
      'Möchten Sie wirklich mit dieser alten PIN fortfahren?';

  @override
  String get wrongPinAngelaConfirm => 'OK';

  @override
  String get wrongPinAngelaCancel => 'Abbrechen';

  @override
  String get sessionStepCountdownTitle => 'Warnung';

  @override
  String get sessionStepCountdownBody =>
      'Die nächste Eskalation startet, wenn der Countdown endet. Wischen Sie unten „Ich bin sicher“, um zu entwarnen.';

  @override
  String get sessionStepDisguisedDefaultTitle => 'Erinnerung';

  @override
  String get sessionStepDisguisedDefaultBody =>
      'Tippen Sie auf „Ich bin eingecheckt“, um zu bestätigen, dass Sie sicher sind.';

  @override
  String get sessionStepSmsStatus => 'Nachricht wird an Kontakte gesendet …';

  @override
  String get sessionStepSmsDelivered => 'Zugestellt';

  @override
  String get sessionStepSmsSent => 'Gesendet';

  @override
  String get sessionStepSmsQueued => 'In Warteschlange';

  @override
  String get sessionStepSmsFailed => 'Fehlgeschlagen';

  @override
  String get sessionStepPhoneCallStatus => 'Notfallkontakt wird angerufen …';

  @override
  String get sessionStepPhoneCallCancel => 'Anruf abbrechen';

  @override
  String get sessionStepLoudAlarmTitle => 'Alarm läuft';

  @override
  String get sessionStepLoudAlarmBody =>
      'Der Alarm ertönt, um Aufmerksamkeit zu erregen.';

  @override
  String get sessionStepLoudAlarmFlashWarning =>
      'Photosensitivitäts-Warnung: Der Bildschirm blinkt.';

  @override
  String get sessionStepCallEmergencyStatus => 'Notruf wird gewählt …';

  @override
  String sessionStepCallEmergencyNumber(Object number) {
    return 'Nummer: $number';
  }

  @override
  String sessionStepHardwareButtonRepeat(
    Object button,
    Object count,
    Object windowMs,
  ) {
    return 'Drücken Sie $button $count Mal innerhalb von $windowMs ms';
  }

  @override
  String sessionStepHardwareButtonLong(Object button, Object seconds) {
    return 'Halten Sie $button für $seconds Sekunden';
  }

  @override
  String get sessionStepHardwareButtonVolumeUp => 'Lauter';

  @override
  String get sessionStepHardwareButtonVolumeDown => 'Leiser';

  @override
  String get sessionStepHardwareButtonPower => 'Power';

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
  String get fakeCallSlideToAnswer => 'zum Annehmen wischen';

  @override
  String get fakeCallUnknownCaller => 'Unbekannt';

  @override
  String get fakeCallIncomingWhatsapp => 'WhatsApp-Sprachanruf';

  @override
  String get fakeCallIncomingTelegram => 'Telegram-Sprachanruf';

  @override
  String get fakeCallIncomingSignal => 'Signal-Sprachanruf';

  @override
  String get fakeCallBrandWhatsapp => 'WHATSAPP';

  @override
  String get fakeCallBrandTelegram => 'TELEGRAM';

  @override
  String get fakeCallBrandSignal => 'SIGNAL';

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
  String get contactLanguageDefault => 'Standard (App-Sprache verwenden)';

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
  String get modeFieldDistressMode => 'Notfallmodus';

  @override
  String get modeFieldDistressModeDefault => 'Standard verwenden';

  @override
  String get modeChainHeader => 'Eskalationskette';

  @override
  String get modeChainAddStep => 'Schritt hinzufügen';

  @override
  String get modeChainEmpty =>
      'Noch keine Schritte. Tippe auf „Schritt hinzufügen“.';

  @override
  String get modeFieldIcon => 'Symbol';

  @override
  String get modeIconPickerTitle => 'Symbol wählen';

  @override
  String get modeIconClear => 'Kein Symbol';

  @override
  String get modeDistressHeader => 'Notfall-Auslöser';

  @override
  String get modeDistressEmpty => 'Keine Notfall-Auslöser konfiguriert.';

  @override
  String get modeDistressAdd => 'Notfall-Auslöser hinzufügen';

  @override
  String get modeDistressTypeHardware => 'Hardware-Taste';

  @override
  String get modeDistressButtonType => 'Taste';

  @override
  String get modeDistressButtonVolumeUp => 'Lauter';

  @override
  String get modeDistressButtonVolumeDown => 'Leiser';

  @override
  String get modeDistressButtonPower => 'Power-Taste';

  @override
  String get modeDistressPattern => 'Muster';

  @override
  String get modeDistressPatternRepeat => 'Mehrfaches Drücken';

  @override
  String get modeDistressPatternLong => 'Langes Drücken';

  @override
  String get modeDistressPressCount => 'Anzahl Drücke';

  @override
  String get modeDistressPressWindow => 'Zeitfenster (ms)';

  @override
  String get modeDistressLongDuration => 'Haltedauer (Sekunden)';

  @override
  String modeDistressSummaryRepeat(Object count, Object windowMs) {
    return '$count Mal / $windowMs ms';
  }

  @override
  String modeDistressSummaryLong(Object seconds) {
    return '${seconds}s halten';
  }

  @override
  String get modeOverridesHeader => 'Modus-Überschreibungen';

  @override
  String get modeOverridesUseDefault => 'App-Standard verwenden';

  @override
  String get modeOverridesGpsLabel => 'GPS-Aufzeichnung';

  @override
  String get modeOverridesStealthLabel => 'Tarnung';

  @override
  String get modeOverridesEventDefaultsLabel => 'Ereignis-Standards';

  @override
  String get modeOverridesLocalTemplatesLabel => 'Lokale Erinnerungs-Vorlagen';

  @override
  String get modeOverridesGpsEnabled => 'GPS-Aufzeichnung aktiv';

  @override
  String get modeOverridesGpsIntervalLabel => 'Abtastintervall (Sekunden)';

  @override
  String get modeOverridesGpsIncludeInSms => 'Standort an SMS anhängen';

  @override
  String get modeOverridesStealthEnabled => 'Tarnung aktiv';

  @override
  String get modeOverridesStealthFakeName => 'Falscher App-Name';

  @override
  String get modeOverridesEventDefaultsHint =>
      'Eigene Ereignis-Standards aktiv für diesen Modus.';

  @override
  String modeOverridesLocalTemplatesCount(Object count) {
    return '$count modus-lokale Vorlagen';
  }

  @override
  String get modeUnsavedTitle => 'Änderungen verwerfen?';

  @override
  String get modeUnsavedBody =>
      'Du hast nicht gespeicherte Änderungen. Verwerfen und Editor verlassen?';

  @override
  String get modeUnsavedDiscard => 'Verwerfen';

  @override
  String get modeUnsavedKeep => 'Weiter bearbeiten';

  @override
  String get stepDuplicate => 'Schritt duplizieren';

  @override
  String get stepTimingHeader => 'Timing';

  @override
  String stepTimingSummary(Object wait, Object duration, Object grace) {
    return 'Warten ${wait}s / Dauer ${duration}s / Karenz ${grace}s';
  }

  @override
  String get stepCategoryAll => 'Alle';

  @override
  String get stepPickerMore => 'Weitere Optionen...';

  @override
  String get stepCategoryAction => 'Aktion';

  @override
  String get stepCategoryReminder => 'Erinnerung';

  @override
  String get stepCategoryDisarm => 'Check-in';

  @override
  String get modeTrackingHeader => 'GPS-Aufzeichnung';

  @override
  String get modeTrackingEnabled => 'GPS während der Sitzung aufzeichnen';

  @override
  String get modeTrackingIntervalLabel => 'Aufzeichnungsintervall';

  @override
  String get modeTrackingBufferSizeLabel => 'Puffergröße';

  @override
  String modeTrackingBufferSizeValue(Object count) {
    return '$count Punkte';
  }

  @override
  String get modeTrackingBatteryNote =>
      'Häufige GPS-Aufzeichnung erhöht den Batterieverbrauch.';

  @override
  String get stepConfigLogGpsLabel => 'GPS-Erfassung';

  @override
  String get stepConfigLogGpsDefault => 'Standard';

  @override
  String get stepConfigLogGpsOn => 'Ein';

  @override
  String get stepConfigLogGpsOff => 'Aus';

  @override
  String get stepConfigLogGpsDefaultOn => 'Standard (Ein)';

  @override
  String get stepConfigLogGpsDefaultOff => 'Standard (Aus)';

  @override
  String get moreSettingsHeader => 'Weitere Einstellungen';

  @override
  String moreSettingsHeaderCustomized(int count) {
    return 'Weitere Einstellungen ($count angepasst)';
  }

  @override
  String get stepTypePickerLabel => 'Schritttyp';

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
  String get stepFieldRetryCount => 'Anzahl Wiederholungen';

  @override
  String get stepFieldRandomize => 'Zeit-Streuung';

  @override
  String get stepFieldRandomizeToggle => 'Zufällige Zeit (±20%)';

  @override
  String get stepFieldWaitTooltip =>
      'Wie lange gewartet wird, bevor dieser Schritt startet.';

  @override
  String get stepFieldDurationTooltip =>
      'Wie lange der Schritt aktiv ist, bevor das Kulanz-Fenster beginnt.';

  @override
  String get stepFieldGraceTooltip =>
      'Zeit nach der aktiven Phase, um Sicherheit zu bestätigen, bevor der nächste Schritt ausgelöst wird.';

  @override
  String get stepFieldRetryCountTooltip =>
      'Wie oft dieser Schritt wiederholt wird, bevor eskaliert wird.';

  @override
  String get stepFieldReminderIntervalTooltip =>
      'Wie oft die getarnte Erinnerung erscheint, während auf eine Bestätigung gewartet wird.';

  @override
  String get stepFieldReminderGraceTooltip =>
      'Wie viel Zeit nach Erscheinen der Erinnerung zur Bestätigung bleibt.';

  @override
  String get stepPreview => 'In Simulation testen';

  @override
  String stepPreviewFired(Object description) {
    return 'Vorschau ausgeführt: $description';
  }

  @override
  String get stepPreviewTitle => 'Step preview';

  @override
  String get stepPreviewMissingParams => 'Missing step or mode reference.';

  @override
  String get stepPreviewModeNotFound => 'Mode not found.';

  @override
  String get stepPreviewStepNotFound => 'Step not found in this mode.';

  @override
  String stepPreviewError(Object error) {
    return 'Preview failed: $error';
  }

  @override
  String get stepPreviewReplay => 'Replay';

  @override
  String get stepPreviewHoldButtonHint =>
      'Press and hold the button to feel the live response.';

  @override
  String get stepPreviewHoldButtonLabel => 'Hold';

  @override
  String get stepPreviewHoldButtonSemantic => 'Hold to preview';

  @override
  String get stepPreviewHoldButtonReleased =>
      'Released. The session would now enter the grace window.';

  @override
  String get stepPreviewFakeCallHint =>
      'The fake call screen will appear. Slide to answer or hold the red button to simulate distress.';

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
  String get stepConfigHardwarePressWindow => 'Drückfenster (ms)';

  @override
  String get stepConfigHardwareLongDuration => 'Dauer langes Drücken (s)';

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
  String get distressModesTitle => 'Notfallmodi';

  @override
  String get distressModeInUseTitle => 'Notfallmodus wird verwendet';

  @override
  String distressModeInUseBody(Object modes) {
    return 'Dieser Notfallmodus ist noch mit folgenden Modi verknüpft: $modes. Weisen Sie diesen Modi einen anderen Notfallmodus zu, bevor Sie ihn löschen.';
  }

  @override
  String get distressModesEmpty => 'Noch keine Notfallmodi.';

  @override
  String get distressModesAdd => 'Notfallmodus hinzufügen';

  @override
  String get distressModeEditorTitleCreate => 'Neuer Notfallmodus';

  @override
  String get distressModeEditorTitleEdit => 'Notfallmodus bearbeiten';

  @override
  String get distressModeName => 'Name des Notfallmodus';

  @override
  String get distressCountdown => 'Notfallmodus wird ausgelöst ...';

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
  String get settingsSectionDistressModes => 'Notfallmodi';

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
  String get securityAppPinBiometric => 'Biometrie für App-PIN verwenden';

  @override
  String get securitySessionEndPinBiometric =>
      'Biometrie für Sitzungsende-PIN verwenden';

  @override
  String get securityDistressCancelBiometric =>
      'Biometrie zum Abbrechen des Notfalls verwenden';

  @override
  String get securityDuressTest => 'Notfall-PIN testen';

  @override
  String get securityDuressTestSubtitle =>
      'Überprüfen Sie, ob Ihre Notfall-PIN funktioniert.';

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
  String get pinEntryBiometricReason =>
      'Authentifizieren Sie sich, um fortzufahren';

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
  String get stealthTimerDisplayNormal => 'Vollständigen Text anzeigen';

  @override
  String get stealthTimerDisplaySmall => 'Nur Zahlen anzeigen';

  @override
  String get stealthTimerDisplayNone => 'Timer ausblenden';

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
    return 'Notfallmodus startet in $seconds s';
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
  String get backupSelectionHeader => 'In Export einbeziehen';

  @override
  String get backupToggleSettings => 'Einstellungen';

  @override
  String get backupToggleSettingsSubtitle =>
      'Immer enthalten, damit die Sicherung wiederhergestellt werden kann.';

  @override
  String get backupToggleContacts => 'Notfallkontakte';

  @override
  String get backupToggleModes => 'Modi';

  @override
  String get backupToggleDistressModes => 'Notfallmodi';

  @override
  String get backupToggleTemplates => 'Erinnerungs-Vorlagen';

  @override
  String get backupToggleSessionLogs => 'Sitzungsverlauf';

  @override
  String get backupToggleRecordings => 'Audioaufnahmen';

  @override
  String get historyTitle => 'Vergangene Sitzungen';

  @override
  String get historyEmpty => 'Noch keine vergangenen Sitzungen.';

  @override
  String get historyTabReal => 'Echt';

  @override
  String get historyTabSimulated => 'Simuliert';

  @override
  String get historySearchHint => 'Nach Modusname suchen';

  @override
  String get historyFilterModeAll => 'Alle Modi';

  @override
  String get historyFilterModeLabel => 'Modus';

  @override
  String get historyDateRangePick => 'Datumsbereich';

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

  @override
  String emergencyConfirmTitle(Object number) {
    return '$number wird angerufen';
  }

  @override
  String get emergencyConfirmSubtitle =>
      'Halten Sie die Abbrechen-Taste gedrückt, um abzubrechen.';

  @override
  String emergencyConfirmCountdown(Object seconds) {
    return 'Anruf in $seconds s';
  }

  @override
  String get emergencyConfirmCancel => 'Abbrechen';

  @override
  String get stealthCalendarUpcoming => 'Bevorstehend';

  @override
  String get stealthCalendarUpcomingEvent => 'Besprechung';

  @override
  String stealthCalendarUntilEvent(Object minutes) {
    return 'in $minutes Min.';
  }

  @override
  String get stealthCalendarToday => 'Heute';

  @override
  String get stealthCalendarEvent1 => 'Kaffee mit Alex';

  @override
  String get stealthCalendarEvent2 => 'Standup';

  @override
  String get stealthCalendarEvent3 => 'Mittagessen';

  @override
  String get stealthCalendarEvent4 => 'Workout';

  @override
  String get stealthCalendarEvent5 => 'Abendessen mit Sam';

  @override
  String get stealthDisarmGestureHint => 'Nach oben wischen zum Beenden';

  @override
  String get stealthMusicTrackTitle => 'Unbenannter Titel';

  @override
  String get stealthMusicArtist => 'Unbekannter Künstler';

  @override
  String get stealthMusicAlbum => 'Unbekanntes Album';

  @override
  String get stealthMusicNowPlaying => 'Wird gerade abgespielt';

  @override
  String get stealthMusicSwipeHint => 'Wischen zum Entwarnen';

  @override
  String get stealthMusicPrevious => 'Zurück';

  @override
  String get stealthMusicPause => 'Pause';

  @override
  String get stealthMusicNext => 'Weiter';

  @override
  String get stealthPodcastShowName => 'Podcast';

  @override
  String get stealthPodcastEpisodeTitle => 'Folge';

  @override
  String get stealthPodcastEpisodesHeader => 'Folgen';

  @override
  String get stealthPodcastSpeedLabel => '1x';

  @override
  String get stealthPodcastEpisode1 => 'Folge 1';

  @override
  String get stealthPodcastEpisode2 => 'Folge 2';

  @override
  String get stealthPodcastEpisode3 => 'Folge 3';

  @override
  String get stealthPodcastEpisode4 => 'Folge 4';

  @override
  String get stealthPresetPodcast => 'Podcast';

  @override
  String get stealthPresetNone => 'Keine';

  @override
  String get sessionSimSpeedLabel => 'Geschwindigkeit';

  @override
  String sessionSimSpeedValue(Object value) {
    return '${value}x';
  }

  @override
  String get sessionSimSpeedBackgroundCap => 'Im Hintergrund auf 60× begrenzt';

  @override
  String get sessionSimAdvancedLabel => 'Erweitert';

  @override
  String get sessionSimTriggerPanic => 'Notfall auslösen';

  @override
  String get sessionSimTriggerArrival => 'Ankunft auslösen';

  @override
  String get sessionSimTriggerBattery => 'Niedrigen Akkustand auslösen';

  @override
  String get simulateGpsArrival => 'Ankunft simulieren';

  @override
  String get simulateLowBattery => 'Niedrigen Akkustand simulieren';

  @override
  String get launchGateTitle => 'Guardian Angela entsperren';

  @override
  String get launchGateSubtitle =>
      'Geben Sie Ihre PIN ein oder verwenden Sie Biometrie.';

  @override
  String get launchGateWrong => 'Falsche PIN';

  @override
  String get launchGateBiometricReason => 'Guardian Angela entsperren';

  @override
  String get launchGateUseBiometric => 'Biometrie verwenden';

  @override
  String get audioRunningLatePhrase =>
      'Hallo, ich verspäte mich. Ich rufe dich gleich zurück.';

  @override
  String smsDefaultTemplate(Object name, Object location, Object time) {
    return '$name braucht möglicherweise Hilfe. Standort: $location. Zeit: $time.';
  }

  @override
  String smsDefaultPreCallTemplate(Object name) {
    return '$name versucht, dich zu erreichen. Bitte erwarte einen Anruf.';
  }

  @override
  String simLoudAlarm(Object tail) {
    return '[SIM] Lauter Alarm + $tail';
  }

  @override
  String get simLoudAlarmTailFlash => 'Blitz';

  @override
  String get simLoudAlarmTailVibrate => 'Vibration';

  @override
  String simSmsContact(Object channel, int count) {
    return '[SIM] Würde $channel an $count Kontakte senden';
  }

  @override
  String simFakeCallRing(Object caller) {
    return '[SIM] Eingehender Anruf von $caller';
  }

  @override
  String simCountdownWarning(int seconds) {
    return '[SIM] ${seconds}s Countdown-Warnung';
  }

  @override
  String simPhoneCall(Object name) {
    return '[SIM] Würde $name anrufen';
  }

  @override
  String get simNoContactToCall => '[SIM] Kein Kontakt zum Anrufen';

  @override
  String simCallEmergency(Object number) {
    return '[SIM] Würde $number wählen';
  }

  @override
  String get simHardwareButton => '[SIM] Hardware-Auslöser scharfgeschaltet';

  @override
  String get simHoldButton => '[SIM] Warten auf Halten der Taste';

  @override
  String simDisguisedReminder(Object title) {
    return '[SIM] Würde \"$title\" anzeigen';
  }

  @override
  String get simDisguisedReminderEmpty =>
      '[SIM] Keine Erinnerungsvorlage verfügbar';

  @override
  String get simGpsArrivalTrigger => '[SIM] GPS-Ankunfts-Auslöser ausgelöst';

  @override
  String get simLowBatteryAlert => '[SIM] Niedriger Akkustand-Alarm ausgelöst';
}
