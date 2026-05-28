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
  String get homePermissionsMissingTitle => 'Einige Berechtigungen fehlen';

  @override
  String get homePermissionsMissingBody =>
      'Die folgenden Berechtigungen wurden nicht erteilt. Ohne sie schlagen die entsprechenden Kettenschritte stillschweigend fehl:';

  @override
  String get homePermissionsContinueAnyway => 'Trotzdem starten';

  @override
  String get homePermissionsNotification => 'Benachrichtigungen';

  @override
  String get homePermissionsLocation => 'Standort';

  @override
  String get homePermissionsCallPhone => 'Telefonanrufe';

  @override
  String get homePermissionsSendSms => 'SMS senden';

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
  String get contactFormIosSmsWarning =>
      'On iOS, SMS opens the Messages app. You must tap Send manually.';

  @override
  String get modesTitle => 'Modi';

  @override
  String get modesEmpty =>
      'Noch keine Modi. Tippe auf „Hinzufügen“, um einen Modus zu erstellen.';

  @override
  String get modesAdd => 'Modus hinzufügen';

  @override
  String get modesNewPickerTitle => 'Ausgangspunkt';

  @override
  String get modesNewPickerBlank => 'Leerer Modus';

  @override
  String get modesNewPickerBlankSubtitle => 'Mit einer leeren Kette beginnen';

  @override
  String modesNewPickerFromTemplate(String name) {
    return 'Aus $name';
  }

  @override
  String get modesNewPickerFromTemplateSubtitle =>
      'Kette und Auslöser dieses Modus kopieren';

  @override
  String modesNewPickerCopyName(String name) {
    return 'Kopie von $name';
  }

  @override
  String get modesNewPickerBuiltinBadge => 'Eingebaut';

  @override
  String get modeEditorTitleCreate => 'Neuer Modus';

  @override
  String get modeEditorTitleEdit => 'Modus bearbeiten';

  @override
  String get modeFieldName => 'Name';

  @override
  String get modeFieldDistressMode => 'Notfallmodus';

  @override
  String get modeFieldDistressModeDefault => 'Standard verwenden';

  @override
  String get modeChainHeader => 'Kette';

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
  String get stepPreviewTitle => 'Schritt-Vorschau';

  @override
  String get stepPreviewMissingParams => 'Schritt- oder Modus-Verweis fehlt.';

  @override
  String get stepPreviewModeNotFound => 'Modus nicht gefunden.';

  @override
  String get stepPreviewStepNotFound =>
      'Schritt in diesem Modus nicht gefunden.';

  @override
  String stepPreviewError(Object error) {
    return 'Vorschau fehlgeschlagen: $error';
  }

  @override
  String get stepPreviewReplay => 'Erneut';

  @override
  String get stepPreviewHoldButtonHint =>
      'Halte die Taste gedrückt, um die echte Reaktion zu spüren.';

  @override
  String get stepPreviewHoldButtonLabel => 'Halten';

  @override
  String get stepPreviewHoldButtonSemantic => 'Halten zur Vorschau';

  @override
  String get stepPreviewHoldButtonReleased =>
      'Losgelassen. Die Sitzung würde nun in das Toleranzfenster wechseln.';

  @override
  String get stepPreviewFakeCallHint =>
      'Der Fake-Anruf-Bildschirm erscheint. Wische zum Annehmen oder halte den roten Knopf, um Notfall zu simulieren.';

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
  String get stepConfigSmsAutoRecordAudio => 'Audio automatisch aufzeichnen';

  @override
  String get stepConfigSmsAutoRecordVideo => 'Video automatisch aufzeichnen';

  @override
  String get stepConfigSmsRecordDuration => 'Aufzeichnungsdauer';

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
  String get settingsLanguagePicker => 'Sprache';

  @override
  String get settingsEmergencyNumberLabel => 'Notrufnummer';

  @override
  String get settingsRedoOnboardingActiveSessionTooltip =>
      'Cannot redo onboarding during an active session';

  @override
  String get settingsEmergencyNumberCountryPickerTitle =>
      'Choose emergency number';

  @override
  String get settingsEmergencyNumberHint => 'z. B. 112';

  @override
  String get settingsEmergencyNumberSave => 'Speichern';

  @override
  String get settingsRedoOnboarding => 'Einrichtung wiederholen';

  @override
  String get settingsRedoOnboardingConfirm => 'Einrichtung neu starten?';

  @override
  String get settingsRedoOnboardingBody =>
      'Ihre aktuelle Konfiguration bleibt erhalten.';

  @override
  String get settingsRedoOnboardingProceed => 'Neu starten';

  @override
  String get settingsAlarmGradualVolume => 'Alarm schrittweise lauter';

  @override
  String settingsAlarmGradualVolumeDuration(int seconds) {
    return 'Anstiegsdauer: $seconds s';
  }

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
  String aboutVersion(Object version) {
    return 'Version';
  }

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
  String get stealthLockTaskLabel => 'Pin app during session';

  @override
  String get stealthLockTaskSubtitle =>
      'Prevents leaving the app while a session is running. On Android this engages screen-pinning; on other platforms this is a no-op.';

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
