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
      'Cannot redo onboarding during an active session';

  @override
  String get settingsEmergencyNumberCountryPickerTitle =>
      'Choose emergency number';

  @override
  String get settingsRedoOnboarding => 'Einrichtung wiederholen';

  @override
  String get settingsRedoOnboardingConfirm => 'Einrichtung neu starten?';

  @override
  String get securitySessionEndPinBiometric =>
      'Biometrie für Sitzungsende-PIN verwenden';

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
  String get batteryAlertTitle => 'Akku-Warnung';

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
