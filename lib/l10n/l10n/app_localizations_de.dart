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
  String get commonDelete => 'Löschen';

  @override
  String get commonEdit => 'Bearbeiten';

  @override
  String get commonGotIt => 'Verstanden';

  @override
  String get commonClose => 'Schließen';

  @override
  String get commonConfirm => 'Bestätigen';

  @override
  String get commonBack => 'Zurück';

  @override
  String get pinSubmit => 'Bestätigen';

  @override
  String get homeTitle => 'Guardian Angela';

  @override
  String get homeStartSession => 'Sitzung starten';

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
  String get homeNoModes =>
      'Noch keine Modi. Tippe auf „Modi“, um einen anzulegen.';

  @override
  String get homeContactsBannerNone => 'Keine Notfallkontakte konfiguriert.';

  @override
  String get homeMenuSettings => 'Einstellungen';

  @override
  String get homeMenuContacts => 'Kontakte';

  @override
  String get homeMenuHistory => 'Vergangene Sitzungen';

  @override
  String get onboardingProfileTitle => 'Profil & erster Kontakt';

  @override
  String get onboardingPermissionsTitle => 'Berechtigungen';

  @override
  String get onboardingNext => 'Weiter';

  @override
  String get onboardingSkip => 'Überspringen';

  @override
  String get onboardingUseSimNumber => 'Meine SIM-Nummer verwenden';

  @override
  String onboardingUseSimNumberHint(Object number) {
    return 'SIM-Nummer $number wird verwendet';
  }

  @override
  String get onboardingUseSimNumberUnsupported => 'Unter iOS nicht verfügbar';

  @override
  String get onboardingUseSimNumberUnavailable =>
      'Nummer konnte nicht gelesen werden';

  @override
  String get onboardingUseSimNumberPermissionDenied =>
      'Berechtigung verweigert';

  @override
  String get sessionTitle => 'Sitzung';

  @override
  String get sessionDisarm => 'Ich bin sicher';

  @override
  String get sessionDisarmStealth => 'Keine Angela nötig';

  @override
  String get homeChainSummaryTitle => 'Kettenübersicht';

  @override
  String get homeChainSummaryEmpty =>
      'Dieser Modus hat noch keine Schritte – tippe auf den Modus zum Bearbeiten.';

  @override
  String homeChainSummaryTimingTitle(Object name) {
    return 'Schritt: $name';
  }

  @override
  String homeChainSummaryWait(Object seconds) {
    return 'Warten: $seconds s';
  }

  @override
  String homeChainSummaryDuration(Object seconds) {
    return 'Aktiv: $seconds s';
  }

  @override
  String homeChainSummaryGrace(Object seconds) {
    return 'Karenzzeit: $seconds s';
  }

  @override
  String homeChainSummaryRetry(Object count) {
    return 'Wiederholungen: $count';
  }

  @override
  String homeChainSummaryNextStep(Object name) {
    return 'Nächster Schritt: $name';
  }

  @override
  String get homeChainSummaryNextStepNone => 'Nächster Schritt: Ende der Kette';

  @override
  String get homeChainSummaryClose => 'Schließen';

  @override
  String get chainStepNameHoldButton => 'Halten, um sicher zu bleiben';

  @override
  String get chainStepNameDisguisedReminder => 'Getarnte Erinnerung';

  @override
  String get chainStepNameCountdownWarning => 'Countdown-Warnung';

  @override
  String get chainStepNameFakeCall => 'Fake-Anruf';

  @override
  String get chainStepNameSmsContact => 'SMS-Kontakt';

  @override
  String get chainStepNamePhoneCallContact => 'Anruf an Kontakt';

  @override
  String get chainStepNameLoudAlarm => 'Lauter Alarm';

  @override
  String get chainStepNameCallEmergency => 'Notruf';

  @override
  String get chainStepNameHardwareButton => 'Hardware-Taste';

  @override
  String get homeChecklistTitle => 'Sicherheits-Einrichtung';

  @override
  String get homeChecklistDismissTooltip => 'Checkliste ausblenden';

  @override
  String get homeChecklistExpandTooltip => 'Checkliste anzeigen';

  @override
  String get homeChecklistCollapseTooltip => 'Checkliste verbergen';

  @override
  String homeChecklistProgress(Object done, Object total) {
    return '$done von $total erledigt';
  }

  @override
  String get homeChecklistAllDoneBanner =>
      'Alles erledigt – du bist geschützt!';

  @override
  String get homeChecklistInfoTooltip => 'Warum das wichtig ist';

  @override
  String get homeChecklistGotIt => 'Verstanden';

  @override
  String get homeChecklistGoThere => 'Dorthin';

  @override
  String get homeChecklistItem1Title => 'Notfallkontakt hinzufügen';

  @override
  String get homeChecklistItem2Title => 'Sitzungsende-PIN festlegen';

  @override
  String get homeChecklistItem3Title => 'Stealth-Modus einrichten';

  @override
  String get homeChecklistItem4Title => 'Simulation ausprobieren';

  @override
  String get homeChecklistItem5Title => 'Sicherheitsmodus anpassen';

  @override
  String get homeChecklistItem6Title => 'Erforderliche Berechtigungen erteilen';

  @override
  String get checklistInfo1Body =>
      'Notfallkontakte sind die Personen, denen Guardian Angela schreibt und anruft, wenn du dich nicht meldest. Ohne mindestens einen Kontakt hat die Kette niemanden, an den sie eskalieren kann.';

  @override
  String get checklistInfo2Body =>
      'Eine Sitzungsende-PIN verhindert, dass ein Angreifer eine laufende Sitzung still beendet. Versuche werden weiter zugelassen, aber fünf falsche Eingaben lösen lautlos deine Notfallkette aus.';

  @override
  String get checklistInfo3Body =>
      'Der Stealth-Modus tarnt die laufende Sitzung als etwas Unverdächtiges – einen Musikplayer, einen pausierten Timer, einen leeren Sperrbildschirm. Verwende ihn, wenn jemand in der Nähe nicht sehen soll, dass du eine Sicherheits-App benutzt.';

  @override
  String get checklistInfo4Body =>
      'Die Simulation spielt deinen Sicherheitsmodus vollständig durch, ohne echte SMS zu senden, echte Anrufe zu starten oder den lauten Alarm auszulösen. So lernst du die Abläufe, bevor du sie wirklich brauchst.';

  @override
  String get checklistInfo5Body =>
      'Mit eigenen Modi stimmst du Schritte, Zeiten und Auslöser auf eine konkrete Situation ab – Heimweg, erstes Date, Spätschicht. Die beiden vorinstallierten Modi sind Startpunkte, nicht das Ziel.';

  @override
  String get checklistInfo6Body =>
      'Ohne Benachrichtigungs-Berechtigung kann Guardian Angela keinen dauerhaften Vordergrund-Status halten, keine getarnten Erinnerungen liefern und dich nicht warnen, wenn die Kette gleich eskaliert.';

  @override
  String get checklistTutorial3Body =>
      'Öffne die Stealth-Standardeinstellungen und aktiviere „Stealth-Modus aktivieren“. Dort wählst du eine Fake-Musikmarke, blendest den Sitzungstimer aus oder tarnst das Startbildschirm-Symbol.';

  @override
  String get checklistTutorial4Body =>
      'Tippe auf der Startseite nach Auswahl eines Modus auf den umrandeten Button „Simulieren“. Die Sitzung läuft mit orangem Rahmen und [SIM]-Badge – nichts verlässt dein Handy.';

  @override
  String get checklistTutorial5Body =>
      'Öffne den Modi-Bildschirm und bearbeite entweder einen vorinstallierten Modus (Spaziergang/Date) oder erstelle einen neuen von Grund auf. Passe die Kette an, füge einen Fake-Anruf hinzu, lege eigene Zeiten fest.';

  @override
  String get sessionHoldPrompt => 'Halten, um sicher zu bleiben';

  @override
  String sessionStepLabel(Object index, Object total) {
    return 'Schritt $index von $total';
  }

  @override
  String sessionMissCount(Object count) {
    return 'Verpasst: $count';
  }

  @override
  String get sessionPausedBadge => 'Pausiert';

  @override
  String get sessionPausedIncomingCall => 'Pausiert — eingehender Anruf';

  @override
  String get sessionPhaseEnded => 'Sitzung beendet';

  @override
  String get sessionSimulationBanner => 'Simulation';

  @override
  String get sessionCheckIn => 'Ich bin eingecheckt';

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
  String get sessionReminderEarlyCheckInHint => 'Zum Einchecken tippen';

  @override
  String get sessionReminderDefaultButton => 'OK';

  @override
  String get sessionReminderTapWordHint => 'Zum Fortfahren tippen';

  @override
  String get sessionReminderDecoyWords =>
      'SPÄTER,ÜBERSPRINGEN,FERTIG,ÖFFNEN,ANZEIGEN,OKAY,WEITER,MEHR,ERINNERN,SCHLIESSEN';

  @override
  String get sessionReminderSwipeLabel => 'Zum Schließen wischen';

  @override
  String get sessionReminderDismissLabel => 'Schließen';

  @override
  String get sessionStepSmsStatus => 'Nachricht wird an Kontakte gesendet …';

  @override
  String get sessionStepPhoneCallStatus => 'Notfallkontakt wird angerufen …';

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
  String get sessionStealthNowPlaying => 'Wird gerade abgespielt';

  @override
  String get sessionServiceTitle => 'Guardian Angela ist aktiv';

  @override
  String get sessionServiceBody => 'Deine Sicherheitssitzung läuft.';

  @override
  String get sessionServiceStealthBody => 'Wird abgespielt';

  @override
  String get sessionStealthTrackTitle => 'Unbenannter Titel';

  @override
  String get sessionStealthArtistName => 'Unbekannter Künstler';

  @override
  String get sessionStealthAlbumArtLabel => 'Albumcover';

  @override
  String get sessionStealthPlay => 'Wiedergabe';

  @override
  String get sessionStealthPause => 'Pause';

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
  String get fakeCallBrandAndroid => 'TELEFON';

  @override
  String get fakeCallBrandIos => 'TELEFON';

  @override
  String get fakeCallBrandMinimal => 'ANRUF';

  @override
  String get fakeCallDeclineSafeLabel => 'Ablehnen (Ich bin sicher)';

  @override
  String get fakeCallDeclineUnsafeLabel => 'Ablehnen (Wachsam bleiben)';

  @override
  String get fakeCallHoldForDistress => '5 Sek. halten für Notfall';

  @override
  String fakeCallVoicePrompt(String name) {
    return 'Sprachansage: $name';
  }

  @override
  String fakeCallVibrationLabel(String pattern) {
    return 'Vibration: $pattern';
  }

  @override
  String get fakeCallVibrationPatternDefault => 'Standard';

  @override
  String get fakeCallSlideToAnswerHint => 'Zum Annehmen wischen';

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
  String get contactFormIosSmsWarning =>
      'Unter iOS öffnet SMS die Nachrichten-App. Du musst manuell auf „Senden“ tippen.';

  @override
  String get modesTitle => 'Modi';

  @override
  String get modesEmpty =>
      'Noch keine Modi. Tippe auf „Hinzufügen“, um einen Modus zu erstellen.';

  @override
  String get modesAdd => 'Modus hinzufügen';

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
  String get modeEditorTitleCreate => 'Neuer Modus';

  @override
  String get modeEditorTitleEdit => 'Modus bearbeiten';

  @override
  String get modeFieldName => 'Name';

  @override
  String get modeChainHeader => 'Kette';

  @override
  String get modeChainAddStep => 'Schritt hinzufügen';

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
  String stepTimingSummary(Object wait, Object duration, Object grace) {
    return 'Warten ${wait}s / Dauer ${duration}s / Karenz ${grace}s';
  }

  @override
  String get stepConfigTimingHeader => 'Timing';

  @override
  String get stepConfigEventHeader => 'Ereigniskonfiguration';

  @override
  String get stepConfigAdvancedHeader => 'Wiederholung & Erweitert';

  @override
  String get stepFieldWait => 'Warten vor Auslösung (Sekunden)';

  @override
  String get stepFieldDuration => 'Aktive Dauer (Sekunden)';

  @override
  String get stepFieldGrace => 'Karenzzeit (Sekunden)';

  @override
  String get stepFieldRetryCount => 'Wiederholungen';

  @override
  String get stepFieldRandomize => 'Timing zufällig variieren (±20%)';

  @override
  String get stepDuplicate => 'Schritt duplizieren';

  @override
  String get stepResetDefaults => 'Auf Standardwerte zurücksetzen';

  @override
  String get smsContactRecipientsHeader => 'Zu benachrichtigende Kontakte';

  @override
  String get smsContactSummaryAll => 'An: alle aktivierten Kontakte';

  @override
  String get smsContactSummaryNone => 'Keine Empfänger ausgewählt';

  @override
  String smsContactSummaryTo(Object names) {
    return 'An: $names';
  }

  @override
  String get smsContactChannelDisabledTooltip =>
      'Für diesen Kontakt nicht aktiviert — bearbeite den Kontakt, um diesen Kanal hinzuzufügen.';

  @override
  String get smsContactEmptyAddPrompt =>
      'Noch keine Kontakte — füge einen unter Kontakte hinzu';

  @override
  String get safetyOptionsHeader => 'Sicherheitsoptionen';

  @override
  String get safetyOptionsDistressModeTitle => 'Notfallmodus';

  @override
  String get safetyOptionsDistressModeUseDefault =>
      'Standard-Notfallmodus verwenden';

  @override
  String safetyOptionsDistressModeUseDefaultNamed(Object name) {
    return 'Standard verwenden ($name)';
  }

  @override
  String get safetyOptionsDistressModeInfo =>
      'Wenn ein Notfall-Auslöser ausgelöst wird (Zwangs-PIN, Hardware-Panik oder zu viele falsche PIN-Eingaben), wird die Kette dieses Modus durch die Kette des gewählten Notfallmodus ersetzt. Bei „Standard“ wird der app-weite Notfallmodus verwendet.';

  @override
  String get safetyOptionsManageDistressModes => 'Notfallmodi verwalten';

  @override
  String get safetyOptionsDistressTriggersTitle => 'Notfall-Auslöser';

  @override
  String get safetyOptionsDistressTriggersInfo =>
      'Notfall-Auslöser starten die Notfallkette sofort, parallel zur Hauptkette. Die Hardware-Paniktaste überwacht eine physische Taste auf das eingestellte Tastenmuster.';

  @override
  String get safetyOptionsDistressTriggersEmpty => 'Keine Notfall-Auslöser';

  @override
  String get safetyOptionsAddHardwarePanic => 'Hardware-Paniktaste hinzufügen';

  @override
  String safetyOptionsTriggerHardwareRepeat(Object button, Object count) {
    return '$button: $count× drücken';
  }

  @override
  String safetyOptionsTriggerHardwareLong(Object button, Object seconds) {
    return '$button: ${seconds}s halten';
  }

  @override
  String get safetyOptionsButtonVolumeUp => 'Lauter-Taste';

  @override
  String get safetyOptionsButtonVolumeDown => 'Leiser-Taste';

  @override
  String get safetyOptionsTriggerPattern => 'Tastenmuster';

  @override
  String get safetyOptionsPatternRepeat => 'Wiederholtes Drücken';

  @override
  String get safetyOptionsPatternLong => 'Langes Drücken';

  @override
  String get safetyOptionsTriggerButton => 'Taste';

  @override
  String get safetyOptionsTriggerPressCount => 'Anzahl der Drücke';

  @override
  String get safetyOptionsTriggerHoldDuration => 'Haltedauer (Sekunden)';

  @override
  String get safetyOptionsDisarmTriggersTitle => 'Deaktivierungs-Auslöser';

  @override
  String get safetyOptionsGpsArrivalTitle => 'Deaktivierung bei GPS-Ankunft';

  @override
  String get safetyOptionsGpsArrivalInfo =>
      'Die Sitzung endet automatisch, sobald du dich innerhalb des eingestellten Radius deines Ziels befindest. Das Ziel legst du beim Start einer Sitzung fest.';

  @override
  String get safetyOptionsGpsArrivalRadius => 'Ankunftsradius';

  @override
  String safetyOptionsRadiusMeters(Object meters) {
    return '$meters m';
  }

  @override
  String safetyOptionsRadiusKilometers(Object km) {
    return '$km km';
  }

  @override
  String get safetyOptionsDestinationSource => 'Ziel';

  @override
  String get safetyOptionsDestinationPrompt =>
      'Ziel beim Sitzungsstart festlegen';

  @override
  String get safetyOptionsDestinationFixed => 'Feste Koordinaten';

  @override
  String get safetyOptionsLatitude => 'Breitengrad';

  @override
  String get safetyOptionsLongitude => 'Längengrad';

  @override
  String get safetyOptionsTimerDisarmTitle => 'Timer-Deaktivierung';

  @override
  String get safetyOptionsTimerDisarmInfo =>
      'Die Sitzung endet automatisch nach der eingestellten Zeit, unabhängig davon, ob die Eskalation begonnen hat.';

  @override
  String get safetyOptionsTimerDuration => 'Dauer';

  @override
  String safetyOptionsDurationMinutes(Object minutes) {
    return '$minutes Min.';
  }

  @override
  String safetyOptionsDurationHoursMinutes(Object hours, Object minutes) {
    return '$hours Std. $minutes Min.';
  }

  @override
  String get safetyOptionsGpsLoggingTitle => 'GPS-Protokollierung';

  @override
  String get safetyOptionsGpsLoggingInfo =>
      'Lege fest, ob dieser Modus während einer Sitzung deinen Standort aufzeichnet. „Erben“ verwendet deine globalen GPS-Einstellungen; „Benutzerdefiniert“ überschreibt sie für diesen Modus; „Aus“ deaktiviert die Protokollierung vollständig.';

  @override
  String get safetyOptionsStealthTitle => 'Tarnung';

  @override
  String get safetyOptionsStealthInfo =>
      'Lege fest, ob dieser Modus die App während einer Sitzung tarnt. „Erben“ verwendet deine globalen Tarn-Einstellungen; „Benutzerdefiniert“ überschreibt sie für diesen Modus; „Aus“ deaktiviert die Tarnung vollständig.';

  @override
  String get safetyOptionsTriStateInherit => 'Erben';

  @override
  String get safetyOptionsTriStateCustom => 'Benutzerdefiniert';

  @override
  String get safetyOptionsTriStateOff => 'Aus';

  @override
  String get safetyOptionsLocalTemplatesTitle => 'Lokale Vorlagen';

  @override
  String get safetyOptionsLocalTemplatesInfo =>
      'Lokale Vorlagen werden nur für diesen Modus zum globalen Vorlagenpool für Erinnerungen hinzugefügt. Verwende sie für getarnte Erinnerungsschritte, die nur für diesen Modus gelten.';

  @override
  String get safetyOptionsLocalTemplatesEmpty => 'Keine lokalen Vorlagen';

  @override
  String get safetyOptionsAddTemplate => 'Vorlage hinzufügen';

  @override
  String get safetyOptionsManageTemplates => 'Erinnerungsvorlagen verwalten';

  @override
  String get safetyOptionsEventDefaultsTitle => 'Ereignis-Standardwerte';

  @override
  String get safetyOptionsEventDefaultsInfo =>
      'Ereignis-Standardwerte legen die Ausgangskonfiguration für jeden Schritttyp fest. „Erben“ verwendet deine globalen Standardwerte; „Benutzerdefiniert“ überschreibt sie für Schritte in diesem Modus ohne eigene Konfiguration.';

  @override
  String get safetyOptionsEventDefaultsTwoStateInherit => 'Erben';

  @override
  String get safetyOptionsAllowDisarmAsDistressTitle =>
      'Deaktivierung im aktiven Notfall zulassen';

  @override
  String get safetyOptionsAllowDisarmAsDistressInfo =>
      'Aktiviert kannst du den Alarm stoppen, indem du einen sicheren Ort erreichst oder einen Timer ablaufen lässt. Deaktiviert stoppt nur das Abschließen der Kette oder das Beenden der App den Alarm – stärker gegen Nötigung.';

  @override
  String get distressModesEmpty => 'Noch keine Notfallmodi.';

  @override
  String get distressModeEditorTitleCreate => 'Neuer Notfallmodus';

  @override
  String get distressModeEditorTitleEdit => 'Notfallmodus bearbeiten';

  @override
  String get templatesTitle => 'Erinnerungs-Vorlagen';

  @override
  String get templatesEmpty => 'Noch keine Vorlagen.';

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
  String get settingsThemeLight => 'Hell';

  @override
  String get settingsThemeDark => 'Dunkel';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsEmergencyNumberLabel => 'Notrufnummer';

  @override
  String get settingsRedoOnboardingActiveSessionTooltip =>
      'Einrichtung kann während einer laufenden Sitzung nicht wiederholt werden';

  @override
  String get settingsEmergencyNumberCountryPickerTitle =>
      'Notrufnummer auswählen';

  @override
  String get settingsEmergencyNumberEditTitle => 'Notrufnummer';

  @override
  String get settingsEmergencyNumberFieldLabel => 'Zu wählende Nummer';

  @override
  String get settingsEmergencyNumberPresetsLabel => 'Gängige Nummern';

  @override
  String get phoneWarnInvalidChars => 'Nur Ziffern, +, * und # sind erlaubt.';

  @override
  String get phoneWarnTooShort =>
      'Notrufnummern haben meist mindestens 3 Ziffern.';

  @override
  String get phoneWarnLooksLikeRegular =>
      'Das sieht nach einer normalen Telefonnummer aus, nicht nach einer Notrufnummer.';

  @override
  String get phoneWarnEmergencyEmpty =>
      'Gib eine Nummer ein – dieses Feld darf nicht leer sein.';

  @override
  String get settingsRedoOnboarding => 'Einrichtung wiederholen';

  @override
  String get settingsRedoOnboardingConfirm => 'Einrichtung neu starten?';

  @override
  String get securitySessionEndPinBiometric =>
      'Biometrie für Sitzungsende-PIN verwenden';

  @override
  String get securityAppPinBiometric => 'Biometrie für App-Sperre verwenden';

  @override
  String get securityDistressCancelBiometric =>
      'Biometrie zum Abbrechen des Notrufs verwenden';

  @override
  String get launchPinTitle => 'App-PIN eingeben';

  @override
  String get launchPinBiometricReason => 'Guardian Angela entsperren';

  @override
  String get sessionEndBiometricReason =>
      'Bestätigen, um die Sitzung zu beenden';

  @override
  String get distressCancelBiometricReason =>
      'Bestätige, dass du es bist, zum Abbrechen';

  @override
  String get launchPinIncorrect => 'Falsche PIN';

  @override
  String get securitySetPin => 'PIN festlegen';

  @override
  String get securityChangePin => 'PIN ändern';

  @override
  String get pinSetupMismatch =>
      'PINs stimmen nicht überein. Versuche es erneut.';

  @override
  String get stealthTimerDisplayNormal => 'Vollständigen Text anzeigen';

  @override
  String get stealthTimerDisplaySmall => 'Nur Zahlen anzeigen';

  @override
  String get stealthTimerDisplayNone => 'Timer ausblenden';

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
  String get eventDefaultsTitle => 'Schritt-Standardwerte';

  @override
  String get historyRetentionTitle => 'Verlauf-Aufbewahrung';

  @override
  String get backupTitle => 'Sicherung';

  @override
  String get aboutTitle => 'Über';

  @override
  String aboutVersion(Object version) {
    return 'Version';
  }

  @override
  String get feedbackTitle => 'Feedback';

  @override
  String get feedbackSend => 'E-Mail öffnen';

  @override
  String get stealthPresetPodcast => 'Podcast';

  @override
  String get stealthPresetNone => 'Keine';

  @override
  String get stealthLockTaskLabel => 'App während der Sitzung anheften';

  @override
  String get stealthLockTaskSubtitle =>
      'Verhindert das Verlassen der App während einer laufenden Sitzung. Unter Android aktiviert dies die Bildschirmfixierung; auf anderen Plattformen hat es keine Wirkung.';

  @override
  String get stealthLockTaskInfo =>
      'Fixiert Guardian Angela für die gesamte Sitzung auf dem Bildschirm, sodass die App nicht weggewischt oder gewechselt werden kann. Kompromiss: Android zeigt einen System-Hinweis \"App ist angeheftet\" und blockiert den App-Wechsel bis zum Sitzungsende — sichtbar für jeden, der auf den Bildschirm schaut. Lass dies aus, wenn du während einer Sitzung frei zwischen Apps wechseln möchtest. Auf Plattformen ohne Bildschirmfixierung ohne Wirkung.';

  @override
  String get homeTagline => 'Dein Engel passt auf dich auf.';

  @override
  String get onboardingWelcomeGreeting => 'Hi, ich bin Angela';

  @override
  String get onboardingWelcomeBodyFull =>
      'Ich bin dein persönlicher Schutzengel. Ich begleite dich, wache über deinen Abend und greife ein, wenn sich etwas falsch anfühlt.';

  @override
  String get onboardingGetStarted => 'Los geht\'s';

  @override
  String get onboardingProfileNameLabel => 'Name';

  @override
  String get onboardingProfilePhoneLabel => 'Telefonnummer';

  @override
  String get onboardingProfilePhoneHelper =>
      'Wird in Notfallnachrichten enthalten sein.';

  @override
  String get onboardingEmergencyContactHeader => 'Notfallkontakt';

  @override
  String get onboardingEmergencyContactPrompt =>
      'Wen sollen wir kontaktieren, wenn etwas schiefgeht?';

  @override
  String get onboardingEmergencyContactAdd => 'Notfallkontakt hinzufügen';

  @override
  String get onboardingPermissionsIntro =>
      'Diese Berechtigungen sorgen während der Sitzungen für deine Sicherheit.';

  @override
  String get onboardingPermissionsGrantAll => 'Alle erteilen';

  @override
  String get onboardingPermissionsRequired => 'ERFORDERLICH';

  @override
  String get onboardingPermissionsOptional => 'OPTIONAL';

  @override
  String get onboardingPermissionsMicrophone => 'Mikrofon';

  @override
  String get onboardingPermissionsCamera => 'Kamera';

  @override
  String get onboardingPermissionsNotificationDesc =>
      'Erforderlich für Sitzungswarnungen und Erinnerungen.';

  @override
  String get onboardingPermissionsSmsDesc =>
      'Erforderlich, um Notfall-SMS zu senden.';

  @override
  String get onboardingPermissionsPhoneDesc =>
      'Erforderlich für Notrufe und Fake-Anrufe.';

  @override
  String get onboardingPermissionsLocationDesc =>
      'Wird in Notfallnachrichten enthalten, wenn die GPS-Aufzeichnung aktiv ist.';

  @override
  String get onboardingPermissionsMicrophoneDesc =>
      'Wird für Audioaufnahmen im Notfall verwendet.';

  @override
  String get onboardingPermissionsCameraDesc =>
      'Wird für das Blitz-SOS-Signal verwendet.';

  @override
  String get sessionInterruptedTitle => 'Sitzung unterbrochen';

  @override
  String get sessionInterruptedBody =>
      'Eine Sitzung war aktiv, als die App gestoppt wurde. Der Sitzungsstatus ist verloren – nichts wurde wiederhergestellt. Wir zeigen dir das, damit du Bescheid weißt.';

  @override
  String get sessionInterruptedAcknowledge => 'Verstanden';

  @override
  String sessionInterruptedMode(Object name) {
    return 'Modus: $name';
  }

  @override
  String sessionInterruptedStarted(Object time) {
    return 'Gestartet: $time';
  }

  @override
  String get sessionInterruptedStartSameMode => 'Gleichen Modus starten';

  @override
  String get sessionInterruptedJustNow => 'gerade eben';

  @override
  String sessionInterruptedMinutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'vor $count Minuten',
      one: 'vor 1 Minute',
    );
    return '$_temp0';
  }

  @override
  String sessionInterruptedHoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'vor $count Stunden',
      one: 'vor 1 Stunde',
    );
    return '$_temp0';
  }

  @override
  String sessionInterruptedDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'vor $count Tagen',
      one: 'vor 1 Tag',
    );
    return '$_temp0';
  }

  @override
  String get sessionGpsDestinationTitle => 'Ziel';

  @override
  String get sessionGpsDestinationBody =>
      'Gib die Zielkoordinaten für den GPS-Ankunfts-Auslöser zum Entwarnen ein.';

  @override
  String get sessionGpsDestinationLat => 'Breitengrad';

  @override
  String get sessionGpsDestinationLng => 'Längengrad';

  @override
  String get sessionGpsDestinationSkip => 'Für diese Sitzung überspringen';

  @override
  String get sessionGpsDestinationConfirm => 'Ziel verwenden';

  @override
  String get sessionEndOverlayTitle => 'Sitzung beenden?';

  @override
  String get sessionEndOverlayBody =>
      'Wische, um zu bestätigen, dass du die Sitzung beenden möchtest';

  @override
  String get sessionEndOverlaySwipeLabel => 'Zum Beenden wischen';

  @override
  String get sessionEndOverlaySimBadge => '[SIM] Übungsmodus';

  @override
  String get sessionEndPinPromptTitle => 'Sitzungsende-PIN eingeben';

  @override
  String get sessionEndPinAppPinMismatch =>
      'Verwende die Sitzungsende-PIN, nicht die App-Sperr-PIN.';

  @override
  String get sessionEndPinIncorrect => 'Falsche PIN';

  @override
  String get sessionEndPinSimSkip => 'Überspringen (nur Sim)';

  @override
  String get sessionEndSimDistressWouldFire =>
      'Notfallkette würde auslösen (5 falsche PINs)';

  @override
  String get distressConfirmTitle => 'Notfall aktiviert';

  @override
  String distressConfirmCountdown(int seconds) {
    return 'Zum Abbrechen tippen – du hast $seconds Sekunden';
  }

  @override
  String get distressConfirmCancel => 'Zum Abbrechen tippen';

  @override
  String get distressConfirmFooter =>
      'Wenn nicht abgebrochen, startet die Notfallkette sofort.';

  @override
  String get distressCancelPinPromptTitle => 'Sitzungsende-PIN eingeben';

  @override
  String distressCancelPinTimeoutLabel(int seconds) {
    return 'noch $seconds Sek.';
  }

  @override
  String get distressCancelPinIncorrect => 'Falsche PIN';

  @override
  String get distressCancelPinAppPinMismatch =>
      'Verwende die Sitzungsende-PIN, nicht die App-Sperr-PIN.';

  @override
  String get distressCancelPinSimSkip => 'Überspringen (nur Sim)';

  @override
  String get distressCancelSimDistressWouldFire =>
      'Notfallkette würde auslösen (5 falsche PINs)';

  @override
  String get distressCancelPinBack => 'Abbrechen';

  @override
  String get simulationPinPromptTitle => 'PIN eingeben';

  @override
  String get simulationPinPromptBody =>
      'Übe die Eingabe deiner Sitzungsende-PIN';

  @override
  String get simulationPinPromptSkip => 'Überspringen';

  @override
  String get simulationPinIncorrect => 'Falsche PIN';

  @override
  String simulationSummaryDuration(String duration) {
    return 'Dauer: $duration';
  }

  @override
  String get simulationSummaryTimelineHeader => 'Ereignis-Zeitleiste';

  @override
  String get simulationSummaryShare => 'Teilen';

  @override
  String simulationSummaryMissedEventsBadge(int count) {
    return 'Verpasst: $count';
  }

  @override
  String simulationSummaryDistressBadge(int count) {
    return 'Notfall: $count';
  }

  @override
  String simulationSummaryStepsFiredBadge(int count) {
    return 'Ausgelöste Schritte: $count';
  }

  @override
  String get simulationSummaryShareSubject =>
      'Guardian Angela Simulations-Zusammenfassung';

  @override
  String get notificationsChannelAlarm => 'Alarm-Eskalation';

  @override
  String get notificationsChannelAlarmDescription =>
      'Kritische Warnungen, die „Nicht stören“ umgehen';

  @override
  String get notificationsChannelReminder => 'Getarnte Erinnerung';

  @override
  String get notificationsChannelReminderDescription =>
      'Check-in-Erinnerungen während einer laufenden Sitzung';

  @override
  String get notificationsChannelFakeCall => 'Fake-Anruf';

  @override
  String get notificationsChannelFakeCallDescription =>
      'Vollbild-Benachrichtigungen für eingehende Anrufe';

  @override
  String get notificationsChannelEnabled => 'Aktiviert';

  @override
  String get notificationsChannelDisabled => 'Deaktiviert';

  @override
  String get notificationsChannelsHeader => 'Benachrichtigungskanäle';

  @override
  String get contactsImportFromDevice => 'Aus Kontakten importieren';

  @override
  String get contactsImportNotSupported =>
      'Auf dieser Plattform nicht verfügbar';

  @override
  String get contactsImportPermissionDenied =>
      'Zugriff auf Kontakte verweigert. Aktiviere ihn in den Systemeinstellungen.';

  @override
  String get contactsDeleteAllMenu => 'Alle löschen';

  @override
  String get contactsDeleteAllConfirmTitle => 'Alle Kontakte löschen?';

  @override
  String get contactsDeleteAllConfirmBody =>
      'Dadurch wird jeder Notfallkontakt entfernt. Dies kann nicht rückgängig gemacht werden.';

  @override
  String get contactsDeleteAllTypeConfirmTitle => 'Durch Tippen bestätigen';

  @override
  String get contactsDeleteAllTypeConfirmHint =>
      'Gib ALLE LÖSCHEN ein, um fortzufahren';

  @override
  String get contactsDeleteAllTypeConfirmSentinel => 'ALLE LÖSCHEN';

  @override
  String get contactsDeleteAllConfirmButton => 'Alle löschen';

  @override
  String get modesBuiltinBadge => 'Integriert';

  @override
  String get modesBuiltinNoDelete =>
      'Integrierte Modi können nicht gelöscht werden';

  @override
  String get sessionCompletedSimulationBanner => 'Simulation abgeschlossen';

  @override
  String get sessionCompletedViewEventLog => 'Ereignisprotokoll anzeigen';

  @override
  String get sessionCompletedFeedbackPrompt => 'Wie war deine Erfahrung?';

  @override
  String get sessionCompletedFeedbackSend => 'Feedback senden';

  @override
  String get sessionCompletedFeedbackSkip => 'Überspringen';

  @override
  String get settingsGeneralHeader => 'Allgemein';

  @override
  String get settingsAppHeader => 'App';

  @override
  String get settingsConfigurationHeader => 'Konfiguration';

  @override
  String get settingsThemeLabel => 'Design';

  @override
  String get settingsLanguageLabel => 'Sprache';

  @override
  String get settingsSecurityRow => 'Sicherheit';

  @override
  String get settingsSecuritySubtitle =>
      'App-PIN, Sitzungsende-PIN, Zwangs-PIN';

  @override
  String get settingsStealthRow => 'Stealth';

  @override
  String get settingsStealthSummaryOff => 'Stealth: AUS';

  @override
  String get settingsStealthSummaryOn => 'Stealth: AN';

  @override
  String get settingsProfileRow => 'Profil';

  @override
  String get settingsModesRow => 'Modi';

  @override
  String get settingsDistressModesRow => 'Notfallmodi';

  @override
  String get settingsEventDefaultsRow => 'Schritt-Standardwerte';

  @override
  String get settingsGpsLoggingRow => 'GPS-Aufzeichnung';

  @override
  String get settingsRemindersRow => 'Erinnerungs-Vorlagen';

  @override
  String get settingsNotificationsRow => 'Benachrichtigungen';

  @override
  String get settingsHistoryRetentionRow => 'Verlauf & Aufbewahrung';

  @override
  String get settingsAboutRow => 'Über';

  @override
  String get settingsFeedbackRow => 'Feedback senden';

  @override
  String get settingsBackupRow => 'Sicherung & Wiederherstellung';

  @override
  String get settingsOssLicenses => 'Open-Source-Lizenzen';

  @override
  String get settingsImportConfirmBody =>
      'Dadurch werden alle aktuellen Daten überschrieben. Fortfahren?';

  @override
  String get securityAppPinTitle => 'App-PIN';

  @override
  String get securityAppPinBody => 'Sperrt die App bei jedem Öffnen.';

  @override
  String get securitySessionEndPinTitle => 'Sitzungsende-PIN';

  @override
  String get securitySessionEndPinBody =>
      'Erforderlich, um eine laufende Sitzung zu entwarnen oder zu beenden.';

  @override
  String get securityDuressPinTitle => 'Zwangs-PIN';

  @override
  String get securityDuressPinBody =>
      'Bei jeder Abfrage eingegeben, um die Notfallkette unbemerkt auszulösen.';

  @override
  String get securityRemovePin => 'Entfernen';

  @override
  String get securityRemovePinPrompt =>
      'Gib zum Entfernen deine aktuelle PIN ein.';

  @override
  String get securityRemovePinIncorrect => 'Falsche PIN';

  @override
  String get securityWhatIsThis => 'Was ist das?';

  @override
  String get securityAppPinInfo =>
      'Sperrt die App, wenn du sie öffnest. Das Tastenfeld erscheint vor jedem Bildschirm. Nützlich, falls jemand kurz dein entsperrtes Handy in die Hand nimmt.';

  @override
  String get securitySessionEndPinInfo =>
      'Erforderlich, um eine laufende Sicherheitssitzung zu entwarnen oder zu beenden. Ohne sie kann ein Angreifer, der dein Handy nimmt, die Kette nicht stoppen. Wähle einen anderen Code als deine App-PIN.';

  @override
  String get securityDuressPinInfo =>
      'Wenn du diese PIN jemals bei einer beliebigen Abfrage eingibst, läuft die Notfallkette unbemerkt ab – deine Kontakte werden alarmiert und der Alarm wird scharfgeschaltet, ohne dass der Angreifer es bemerkt. Wähle einen Code, der sich von allen anderen PINs unterscheidet.';

  @override
  String get securityPinTimeoutLabel => 'PIN-Zeitlimit (Sekunden)';

  @override
  String get securityWrongPinThresholdLabel =>
      'Falsche PIN-Versuche vor Eskalation';

  @override
  String get securityDeceptiveDialogToggle =>
      'Täuschungsdialog bei falscher PIN anzeigen';

  @override
  String get pinSetupEnterNew => 'Neue PIN eingeben';

  @override
  String get pinSetupConfirmNew => 'Neue PIN bestätigen';

  @override
  String get pinSetupTooShort => 'Die PIN muss mindestens 4 Ziffern haben.';

  @override
  String get pinSetupCollision =>
      'Diese PIN steht im Konflikt mit einer anderen konfigurierten PIN.';

  @override
  String get pinSetupSaved => 'PIN gespeichert';

  @override
  String get stealthEnabledLabel => 'Stealth aktivieren';

  @override
  String get stealthFakeNameLabel => 'Fake-App-Name';

  @override
  String get stealthFakeIconLabel => 'Fake-Symbol';

  @override
  String get stealthNotificationDisguiseLabel => 'Benachrichtigungs-Tarnung';

  @override
  String get stealthTimerDisplayLabel => 'Timer-Anzeige';

  @override
  String get stealthSessionScreenLabel => 'Stealth für Sitzungsbildschirm';

  @override
  String get gpsLoggingEnabled => 'GPS während der Sitzungen aufzeichnen';

  @override
  String get gpsLoggingIntervalLabel => 'Intervall';

  @override
  String get gpsLoggingAccuracyLabel => 'Genauigkeit';

  @override
  String get gpsLoggingAccuracyHigh => 'Hoch';

  @override
  String get gpsLoggingAccuracyBalanced => 'Ausgewogen';

  @override
  String get gpsLoggingAccuracyLow => 'Niedrig';

  @override
  String get gpsLoggingFormatLabel => 'Koordinatenformat';

  @override
  String get gpsLoggingFormatDecimal => 'Dezimal';

  @override
  String get gpsLoggingFormatDms => 'GMS';

  @override
  String get gpsLoggingFormatAddress => 'Plus Code';

  @override
  String get gpsLoggingIncludeInSms => 'Standort an SMS anhängen';

  @override
  String get historyRetentionLogsLabel =>
      'Aufbewahrung von Sitzungsprotokollen (Tage)';

  @override
  String get historyRetentionLogsHelper =>
      'Protokolle, die älter sind, wandern in den Papierkorb.';

  @override
  String get historyRetentionTrashLabel => 'Aufbewahrung im Papierkorb (Tage)';

  @override
  String get historyRetentionTrashHelper =>
      'Protokolle im Papierkorb werden nach diesem Zeitraum endgültig gelöscht.';

  @override
  String get historyRetentionUpdated => 'Aufbewahrung aktualisiert';

  @override
  String get historyRetentionPurgeNow => 'Jetzt bereinigen';

  @override
  String historyRetentionPurged(Object count) {
    return '$count Protokolle bereinigt';
  }

  @override
  String get eventDefaultsCheckInHeader => 'Check-in-Methoden';

  @override
  String get eventDefaultsEscalationHeader => 'Eskalationsschritte';

  @override
  String get eventDefaultsPanicHeader => 'Panik-Auslöser';

  @override
  String get templatesCreate => 'Vorlage erstellen';

  @override
  String get templatesEditTitle => 'Vorlage bearbeiten';

  @override
  String get templatesCreateTitle => 'Neue Vorlage';

  @override
  String get templatesNameLabel => 'Name';

  @override
  String get templatesTitleLabel => 'Titel';

  @override
  String get templatesBodyLabel => 'Text';

  @override
  String get templatesRequiredFieldsError =>
      'Name, Titel und Text sind erforderlich.';

  @override
  String get templatesBuiltinNoDelete =>
      'Integrierte Vorlagen können nicht gelöscht werden';

  @override
  String get templatesAddFromTemplate => 'Aus Vorlage';

  @override
  String get templatesAddFromScratch => 'Von Grund auf';

  @override
  String templatesDeleteConfirmTitle(Object name) {
    return '„$name“ löschen?';
  }

  @override
  String get templatesDeleteConfirmBody =>
      'Diese Vorlage wird endgültig entfernt.';

  @override
  String get templatesEmptyAddFirst => 'Füge deine erste Vorlage hinzu';

  @override
  String get templatesPickFromBuiltinTitle => 'Integrierte Vorlage auswählen';

  @override
  String get templatesIconLabel => 'Symbol';

  @override
  String get templatesIconCalendar => 'Kalender';

  @override
  String get templatesIconAppNotification => 'App-Benachrichtigung';

  @override
  String get templatesIconFitness => 'Fitness';

  @override
  String get templatesIconHealth => 'Gesundheit';

  @override
  String get templatesIconFood => 'Essen';

  @override
  String get templatesIconCoffee => 'Kaffee';

  @override
  String get templatesIconBattery => 'Akku';

  @override
  String get templatesIconWeather => 'Wetter';

  @override
  String get templatesPreviewHeading => 'Live-Vorschau';

  @override
  String get templatesDiscardChangesTitle => 'Änderungen verwerfen?';

  @override
  String get templatesDiscardChangesBody =>
      'Nicht gespeicherte Änderungen gehen verloren.';

  @override
  String get templatesDiscardKeep => 'Weiter bearbeiten';

  @override
  String get templatesDiscardDiscard => 'Verwerfen';

  @override
  String get notificationsTitle => 'Benachrichtigungen';

  @override
  String get notificationsStatusGranted => 'Erteilt';

  @override
  String get notificationsStatusDenied => 'Verweigert';

  @override
  String get notificationsStatusUnknown => 'Noch nicht angefragt';

  @override
  String get notificationsRequest => 'Berechtigung anfragen';

  @override
  String get notificationsOpenSettings => 'Systemeinstellungen öffnen';

  @override
  String get profileFieldPhone => 'Telefonnummer';

  @override
  String get profileFieldDescription => 'Personenbeschreibung';

  @override
  String get profileFieldMedicalConditions => 'Vorerkrankungen';

  @override
  String get profileFieldEmergencyInstructions => 'Anweisungen für den Notfall';

  @override
  String get aboutAuthor => 'Autor: Jonas Eschle';

  @override
  String get aboutEmail => 'guardian.angela.app@gmail.com';

  @override
  String get aboutPrivacyPolicy => 'Datenschutzerklärung';

  @override
  String get aboutTermsOfService => 'Nutzungsbedingungen';

  @override
  String get aboutSourceCode => 'Quellcode';

  @override
  String get aboutSupport => 'Unterstützen / spenden';

  @override
  String get aboutLicenses => 'Open-Source-Lizenzen';

  @override
  String get aboutTagline => 'Mit Liebe für die Sicherheit von LGBTQ+ gemacht.';

  @override
  String get aboutTechnicalSection => 'Technische Informationen';

  @override
  String aboutBundleId(Object id) {
    return 'Bundle-ID: $id';
  }

  @override
  String aboutPlatforms(Object list) {
    return 'Plattformen: $list';
  }

  @override
  String get feedbackHeading => 'Wir freuen uns, von dir zu hören';

  @override
  String get feedbackCategoryLabel => 'Kategorie';

  @override
  String get feedbackCategoryBug => 'Fehlerbericht';

  @override
  String get feedbackCategoryFeature => 'Funktionswunsch';

  @override
  String get feedbackCategoryOther => 'Sonstiges';

  @override
  String get feedbackEmailLabel => 'E-Mail (optional)';

  @override
  String get feedbackMessageLabel => 'Nachricht';

  @override
  String get feedbackIncludeLog => 'Letztes Sitzungsprotokoll beifügen';

  @override
  String get feedbackSent => 'Danke für dein Feedback!';

  @override
  String get feedbackMessageRequired =>
      'Die Nachricht muss mindestens 10 Zeichen lang sein.';

  @override
  String get backupIncludeLogs => 'Sitzungsprotokolle einbeziehen';

  @override
  String get backupIncludeMedia => 'Medien einbeziehen';

  @override
  String get backupExportButton => 'Exportieren';

  @override
  String get backupImportButton => 'Importieren';

  @override
  String get backupOverwriteWarning =>
      'Beim Importieren werden alle aktuellen Daten überschrieben.';

  @override
  String get backupImportSuccess =>
      'Import abgeschlossen. Zum Anwenden neu starten.';

  @override
  String backupImportError(Object message) {
    return 'Import fehlgeschlagen: $message';
  }

  @override
  String get backupActiveSessionBanner =>
      'Die Sicherung ist während einer laufenden Sitzung nicht verfügbar.';

  @override
  String backupLastBackupAtLabel(Object when) {
    return 'Letzte Sicherung am $when';
  }

  @override
  String get backupNeverExportedLabel => 'Noch keine Sicherung';

  @override
  String get pastEventsTitle => 'Vergangene Sitzungen';

  @override
  String get pastEventsTabReal => 'Echt';

  @override
  String get pastEventsTabSimulated => 'Simuliert';

  @override
  String get pastEventsEmpty => 'Noch keine Sitzungen';

  @override
  String get pastEventsDeleteConfirm => 'Sitzungsprotokoll löschen?';

  @override
  String get pastEventsDetailShareText => 'Als Text teilen';

  @override
  String get pastEventsDetailSharePdf => 'Als PDF teilen';

  @override
  String get pastEventsDetailDelete => 'Löschen';

  @override
  String get pastEventsOutcomeCompleted => 'Abgeschlossen';

  @override
  String get pastEventsOutcomeDistress => 'Notfall';

  @override
  String get pastEventsOutcomeInterrupted => 'Unterbrochen';

  @override
  String get pastEventsTrash => 'Papierkorb';

  @override
  String get pastEventsUndo => 'Rückgängig';

  @override
  String get pastEventsSoftDeleted => 'In den Papierkorb verschoben';

  @override
  String get pastEventsDetailTitle => 'Sitzungsprotokoll';

  @override
  String get pastEventsDetailShare => 'Teilen';

  @override
  String get contactUnsavedDiscardTitle =>
      'Nicht gespeicherte Änderungen verwerfen?';

  @override
  String get contactUnsavedDiscardKeep => 'Weiter bearbeiten';

  @override
  String get contactUnsavedDiscardDiscard => 'Verwerfen';

  @override
  String get modesDuplicate => 'Duplizieren';

  @override
  String get modesDeleteConfirmTitle => 'Modus löschen?';

  @override
  String modesDeleteConfirmBody(Object name) {
    return '$name wird endgültig entfernt.';
  }

  @override
  String get modesDistressDefaultBadge => 'Standard';

  @override
  String get modesDistressSetDefault => 'Als Standard festlegen';

  @override
  String get modesDistressCantDeleteLast =>
      'Mindestens ein Notfallmodus ist erforderlich.';

  @override
  String get modesDistressInUse =>
      'Dieser Notfallmodus wird von einem anderen Modus verwendet.';

  @override
  String get modesDistressTitle => 'Notfallmodi';

  @override
  String get validationNameTooShort =>
      'Der Name muss mindestens 2 Zeichen lang sein.';

  @override
  String get validationPhoneRequired => 'Eine Telefonnummer ist erforderlich.';

  @override
  String get validationChannelsRequired => 'Wähle mindestens einen Kanal aus.';

  @override
  String get validationChainEmpty =>
      'Füge mindestens einen Schritt hinzu, bevor du speicherst.';

  @override
  String get validationGpsFixedCoords =>
      'Lege für das feste Ankunftsziel sowohl Breiten- als auch Längengrad fest.';

  @override
  String get validationHardwareTrigger =>
      'Hardware-Panikauslöser ist unvollständig – prüfe die Anzahl der Tastendrücke oder die Haltedauer.';

  @override
  String get validationSmsChannelNotOnContacts =>
      'Keiner der gewählten Kontakte kann über den Kanal dieses Schritts empfangen. Wähle einen anderen Kanal oder füge ihn einem Kontakt hinzu.';

  @override
  String get validationDistressNoActionTitle => 'Kein ausgehender Alarmschritt';

  @override
  String get validationDistressNoActionBody =>
      'Dieser Notfallmodus hat keinen SMS- oder Anrufschritt und hinterlässt daher keine ausgehende Spur. Trotzdem speichern?';

  @override
  String get validationSaveAnyway => 'Trotzdem speichern';

  @override
  String get sessionHoldTouchToBegin => 'Zum Starten berühren';

  @override
  String sessionHoldReleaseCountdown(Object seconds) {
    return 'Countdown: ${seconds}s';
  }

  @override
  String sessionHoldGraceCountdown(Object seconds) {
    return 'Karenzzeit: ${seconds}s – erneut halten, um sicher zu bleiben';
  }

  @override
  String get sessionHoldAgain => 'Erneut halten, um sicher zu bleiben';

  @override
  String sessionStepNextCheckIn(Object time) {
    return 'Nächster Check-in in $time';
  }

  @override
  String sessionStepFakeCallActive(Object caller) {
    return 'Eingehender Anruf von $caller';
  }

  @override
  String get sessionStepFakeCallOpen => 'Anrufbildschirm öffnen';

  @override
  String sessionStepSimBlockedSms(Object count) {
    return '[SIM] Würde SMS an $count Kontakte senden';
  }

  @override
  String get sessionStepSimBlockedPhone => '[SIM] Würde Notfallkontakt anrufen';

  @override
  String get sessionStepSimBlockedEmergency => '[SIM] Würde Notruf wählen';

  @override
  String get sessionStepSimBlockedAlarm =>
      '[SIM] Alarm wäre mit voller Lautstärke ertönt';

  @override
  String get sessionStartFailedTitle => 'Sitzung kann nicht gestartet werden';

  @override
  String get sessionStartFailedBody =>
      'Behebe die folgenden Probleme, bevor du startest:';

  @override
  String get sessionQuickExitTitle => 'Schnell beenden';

  @override
  String get sessionQuickExitBody =>
      'Die Sitzungsdaten werden bewahrt und verschlüsselt. Öffne die App jederzeit erneut, um sie wiederherzustellen.';

  @override
  String get sessionQuickExitConfirm => 'App beenden';

  @override
  String get pastEventsRestore => 'Wiederherstellen';

  @override
  String get stepEditorWait => 'Warten (s)';

  @override
  String get stepEditorDuration => 'Dauer (s)';

  @override
  String get stepEditorGrace => 'Karenzzeit (s)';

  @override
  String get stepEditorRetryCount => 'Wiederholungsanzahl';

  @override
  String get stepEditorRandomize => 'Zeiten zufällig variieren (±20 %)';

  @override
  String get stepEditorRemove => 'Schritt entfernen';

  @override
  String get eventDefaultsHoldStyle => 'Halte-Stil';

  @override
  String get eventDefaultsHoldSensitivity => 'Loslass-Empfindlichkeit';

  @override
  String get eventDefaultsHoldVibrate => 'Vibrieren beim Loslassen';

  @override
  String get eventDefaultsHoldSound => 'Ton beim Loslassen';

  @override
  String get eventDefaultsBlackScreen => 'Schwarzbild-Overlay';

  @override
  String get eventDefaultsReminderRandomInterval =>
      'Intervall zufällig variieren';

  @override
  String get eventDefaultsReminderRandomTemplate =>
      'Vorlagen-Reihenfolge zufällig variieren';

  @override
  String get eventDefaultsReminderResetOnEarly =>
      'Bei frühem Check-in zurücksetzen';

  @override
  String get eventDefaultsCountdownStyle => 'Countdown-Stil';

  @override
  String get eventDefaultsCountdownVibrate => 'Vibrieren';

  @override
  String get eventDefaultsCountdownSound => 'Ton';

  @override
  String get eventDefaultsFakeCallStyle => 'Anruf-Stil';

  @override
  String get eventDefaultsFakeCallCallerName => 'Name des Anrufers';

  @override
  String get eventDefaultsFakeCallRingDuration => 'Klingeldauer (s)';

  @override
  String get eventDefaultsFakeCallDeclineIsSafe => 'Ablehnen gilt als sicher';

  @override
  String get eventDefaultsFakeCallVoiceOutput => 'Sprachausgabe';

  @override
  String get eventDefaultsFakeCallRingtone => 'Klingelton';

  @override
  String get eventDefaultsFakeCallRingtoneDefault => 'Standardklingelton';

  @override
  String eventDefaultsFakeCallRingtoneCustom(String fileName) {
    return 'Eigener: $fileName';
  }

  @override
  String get eventDefaultsFakeCallRingtoneChoose => 'Klingelton wählen…';

  @override
  String get eventDefaultsFakeCallRingtoneUseDefault => 'Standard verwenden';

  @override
  String get eventDefaultsSmsChannel => 'Kanal';

  @override
  String get eventDefaultsSmsIncludeLocation => 'Standort einbeziehen';

  @override
  String get eventDefaultsSmsIncludeMedical => 'Medizinische Infos einbeziehen';

  @override
  String get eventDefaultsSmsAutoRecord => 'Audio vor dem Senden aufnehmen';

  @override
  String get eventDefaultsSmsRecordDuration => 'Aufnahmedauer (s)';

  @override
  String get eventDefaultsSmsMessageTemplate => 'Nachrichtenvorlage';

  @override
  String get eventDefaultsSmsMessageTemplateHint =>
      'Leer lassen, um den Standardalarm zu verwenden. Tippe auf einen Platzhalter, um ihn einzufügen.';

  @override
  String get eventDefaultsSmsIosWarning =>
      'Auf dem iPhone musst du bei SMS in der Nachrichten-App manuell auf Senden tippen. Wenn du dein Telefon nicht bedienen kannst, wird die Nachricht nicht gesendet. Erwäge stattdessen WhatsApp oder Telegram.';

  @override
  String get eventDefaultsLoudAlarmVolume => 'Lautstärke';

  @override
  String get eventDefaultsLoudAlarmSound => 'Ton';

  @override
  String get eventDefaultsLoudAlarmFlashScreen => 'Bildschirm blinken lassen';

  @override
  String get eventDefaultsLoudAlarmFlashLight => 'Kamera-Blitz blinken lassen';

  @override
  String get eventDefaultsLoudAlarmGradual => 'Lautstärke allmählich steigern';

  @override
  String get eventDefaultsCallEmergencyNumber => 'Notrufnummer (überschreiben)';

  @override
  String get eventDefaultsCallEmergencyConfirm =>
      'Bestätigungs-Countdown anzeigen';

  @override
  String get eventDefaultsCallEmergencyConfirmDuration =>
      'Bestätigungssekunden';

  @override
  String get eventDefaultsCallEmergencySmsFirst => 'Zuerst Standort-SMS senden';

  @override
  String get eventDefaultsCallEmergencyIosWarning =>
      'Auf dem iPhone erscheint vor dem Wählen ein Bestätigungsdialog. Tippe schnell auf „Anrufen“.';

  @override
  String get eventDefaultsPhonePrimaryContact => 'Hauptkontakt (ID)';

  @override
  String get eventDefaultsHardwareButton => 'Taste';

  @override
  String get eventDefaultsHardwarePattern => 'Druckmuster';

  @override
  String get eventDefaultsHardwarePressCount => 'Anzahl der Tastendrücke';

  @override
  String get eventDefaultsHardwareLongDuration =>
      'Dauer für langes Drücken (s)';

  @override
  String get pastEventsTrashTitle => 'Papierkorb';

  @override
  String get pastEventsTrashEmpty => 'Der Papierkorb ist leer';

  @override
  String get pastEventsTrashEmptyAll => 'Papierkorb leeren';

  @override
  String get pastEventsTrashEmptyAllConfirmTitle => 'Papierkorb leeren?';

  @override
  String get pastEventsTrashEmptyAllConfirmBody =>
      'Gib unten EMPTY TRASH ein, um zu bestätigen. Dies löscht jedes Protokoll im Papierkorb endgültig.';

  @override
  String pastEventsTrashEmptyAllSuccess(Object count) {
    return 'Papierkorb geleert ($count Protokolle)';
  }

  @override
  String pastEventsTrashRetentionNote(int days) {
    return 'Protokolle im Papierkorb werden nach $days Tagen endgültig gelöscht.';
  }

  @override
  String pastEventsTrashRemainingDays(int days) {
    return 'noch $days Tag(e) bis zur endgültigen Löschung';
  }

  @override
  String get pastEventsTrashDeletePermanently => 'Endgültig löschen';

  @override
  String get pastEventsTrashDeletePermanentlyBody =>
      'Diese Aktion kann nicht rückgängig gemacht werden.';

  @override
  String sessionEmergencyConfirmTitle(String number, int seconds) {
    return 'Wähle $number in ${seconds}s';
  }

  @override
  String get sessionEmergencyConfirmSwipe => 'Zum Abbrechen wischen';

  @override
  String get sessionEmergencyConfirmKeep => 'Anruf fortsetzen';

  @override
  String get sessionEmergencyConfirmSimBadge => '[SIM] Übungsmodus';

  @override
  String get sessionEmergencyConfirmSimCancelled =>
      'Simulierter Abbruch – der Anruf wäre nicht getätigt worden';

  @override
  String get swipeSliderSemantics => 'Zum Bestätigen wischen';

  @override
  String get homeWidgetStatusIdle => 'Bereit';

  @override
  String get homeWidgetStatusSession => 'Sitzung aktiv';

  @override
  String get homeWidgetStatusSim => 'Simulation aktiv';

  @override
  String get homeWidgetQuickExit => 'Schnell beenden';

  @override
  String get homeWidgetFakeCall => 'Fake-Anruf';

  @override
  String get settingsAlarmHeader => 'Alarm';

  @override
  String get settingsAlarmDndOverrideLabel =>
      'Alarm überschreibt Lautlos-/Vibrationsmodus';

  @override
  String get settingsAlarmDndOverrideWarning =>
      'Achtung: Der Alarm bleibt stumm, wenn dein Telefon auf lautlos gestellt ist.';

  @override
  String get settingsAlarmDndOverrideInfo =>
      'Wenn aktiviert, ertönt der laute Alarm in voller Lautstärke, auch wenn dein Telefon auf lautlos oder Vibration steht. Unter Android wird der Alarm-Audiokanal genutzt, um „Nicht stören“ zu umgehen. Der Alarm ist das einzige Ereignis, das die Toneinstellungen deines Telefons überschreiben kann.';

  @override
  String get settingsAlarmGradualLabel =>
      'Alarmlautstärke schrittweise erhöhen';

  @override
  String get settingsAlarmGradualInfo =>
      'Der Alarm beginnt leise und steigert sich bis zur vollen Lautstärke. Dies ist der app-weite Hauptschalter; jeder Alarmschritt hat zusätzlich seine eigene Option für ansteigende Lautstärke, und beide müssen aktiviert sein, damit der Anstieg greift.';

  @override
  String get settingsAlarmRampLabel => 'Anstiegsdauer';

  @override
  String get settingsAlarmRampInfo =>
      'Wie lange der Alarm braucht, um von null auf volle Lautstärke anzusteigen, gleichmäßig über diese Zeit. Hat keine Wirkung, wenn die schrittweise Erhöhung aus ist.';

  @override
  String get permissionNotifRationaleTitle => 'Benachrichtigungen erlauben?';

  @override
  String get permissionNotifRationaleBody =>
      'Guardian Angela nutzt Benachrichtigungen, um dich und deine Kontakte während einer Sicherheitssitzung zu warnen, einschließlich getarnter Erinnerungen, die dein gesperrtes Telefon aufwecken. Bitte erlaube Benachrichtigungen, damit die App dich erreichen kann.';

  @override
  String get permissionNotifDeniedTitle => 'Benachrichtigungen sind blockiert';

  @override
  String get permissionNotifDeniedBody =>
      'Benachrichtigungen sind für Guardian Angela deaktiviert. Öffne die Systemeinstellungen, um sie wieder einzuschalten, damit die App dich während einer Sitzung warnen kann.';

  @override
  String get permissionNotifAllow => 'Erlauben';

  @override
  String get permissionNotifOpenSettings => 'Einstellungen öffnen';

  @override
  String get permissionNotifNotNow => 'Nicht jetzt';

  @override
  String get homeStartTriggersSummaryTitle => 'Bevor du startest';

  @override
  String get homeStartTriggersDistressHeading => 'Notfall-Auslöser';

  @override
  String get homeStartTriggersDisarmHeading => 'Auto-Beenden-Auslöser';

  @override
  String get homeStartTriggersNone => 'Keiner konfiguriert';

  @override
  String homeStartTriggerButtonRepeat(String button, String count) {
    return '$button $count-mal drücken';
  }

  @override
  String homeStartTriggerButtonLong(String button, String seconds) {
    return '$button $seconds s lang halten';
  }

  @override
  String get homeStartTriggerButtonVolumeUp => 'Lauter';

  @override
  String get homeStartTriggerButtonVolumeDown => 'Leiser';

  @override
  String homeStartTriggerGpsArrival(String radius) {
    return 'Endet bei Ankunft innerhalb von $radius m deines Ziels';
  }

  @override
  String get homeStartTriggerGpsPrompt =>
      'Du wirst nach dem Start nach dem Ziel gefragt';

  @override
  String homeStartTriggerTimer(String minutes) {
    return 'Endet automatisch nach $minutes Min.';
  }

  @override
  String get homeStartTriggersContinue => 'Jetzt starten';

  @override
  String get homeStartTriggersCancel => 'Abbrechen';

  @override
  String get homeStartBlockedNotifTitle => 'Benachrichtigungen erforderlich';

  @override
  String get homeStartBlockedNotifBody =>
      'Dieser Modus nutzt Benachrichtigungen (getarnte Erinnerungen oder Fake-Anrufe), um dich zu schützen, aber die Benachrichtigungsberechtigung ist deaktiviert. Aktiviere Benachrichtigungen, um diesen Modus zu starten.';
}
