// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get appTitle => 'Guardian Angela';

  @override
  String get commonSave => 'Zapisz';

  @override
  String get angelaDialogTitle => 'Old PIN entered';

  @override
  String get angelaDialogBody =>
      'It looks like you used an old PIN. Are you sure you want to proceed?';

  @override
  String get angelaDialogCancel => 'Cancel';

  @override
  String get angelaDialogConfirm => 'Continue';

  @override
  String get commonCancel => 'Anuluj';

  @override
  String get commonDelete => 'Usuń';

  @override
  String get commonEdit => 'Edytuj';

  @override
  String get commonAdd => 'Dodaj';

  @override
  String get commonClose => 'Zamknij';

  @override
  String get commonConfirm => 'Potwierdź';

  @override
  String get commonBack => 'Wstecz';

  @override
  String get commonDone => 'Gotowe';

  @override
  String get commonRetry => 'Spróbuj ponownie';

  @override
  String get commonYes => 'Tak';

  @override
  String get commonNo => 'Nie';

  @override
  String get commonEnabled => 'Włączone';

  @override
  String get commonDisabled => 'Wyłączone';

  @override
  String get commonNone => 'Brak';

  @override
  String get commonSeconds => 'sekund';

  @override
  String get commonMinutes => 'minut';

  @override
  String get cancel => 'Anuluj';

  @override
  String get pinSubmit => 'Submit';

  @override
  String get homeTitle => 'Guardian Angela';

  @override
  String get homeStartSession => 'Rozpocznij sesję';

  @override
  String get homeStartConfirmTitle => 'Start a session?';

  @override
  String get homeStartConfirmBody =>
      'Make sure your contacts and PIN are configured. The session will run in the foreground and your selected mode will guide check-ins.';

  @override
  String get homeSimulate => 'Symuluj';

  @override
  String get homeActiveSession => 'Aktywna sesja';

  @override
  String get homeResumeSession => 'Wznów';

  @override
  String get homeNoModes => 'Brak trybów. Dotknij Tryby, aby dodać.';

  @override
  String get homeNoContacts =>
      'Brak kontaktów alarmowych. Dotknij Kontakty, aby dodać.';

  @override
  String get homeContactsBannerNone => 'No emergency contacts configured.';

  @override
  String homeContactsBannerFew(int count) {
    return '$count contact(s) configured. We recommend at least 3.';
  }

  @override
  String get homeMenuSettings => 'Ustawienia';

  @override
  String get homeMenuContacts => 'Kontakty';

  @override
  String get homeMenuModes => 'Tryby';

  @override
  String get homeMenuHistory => 'Poprzednie sesje';

  @override
  String get homeSelectMode => 'Wybierz tryb';

  @override
  String get onboardingWelcomeTitle => 'Witaj w Guardian Angela';

  @override
  String get onboardingWelcomeBody =>
      'Towarzysz, który zapewni Ci bezpieczeństwo w drodze do domu. Guardian Angela czuwa nad Tobą, gdy idziesz, biegniesz lub podróżujesz, i może powiadomić wybrane kontakty, jeśli potrzebujesz pomocy.';

  @override
  String get onboardingProfileTitle => 'Profil i pierwszy kontakt';

  @override
  String get onboardingProfileBody =>
      'Opowiedz nam nieco o sobie, aby Guardian Angela mogła przekazać przydatne informacje w razie potrzeby. Następnie dodaj jeden zaufany kontakt.';

  @override
  String get onboardingPermissionsTitle => 'Uprawnienia';

  @override
  String get onboardingPermissionsBody =>
      'Guardian Angela potrzebuje kilku uprawnień, aby zapewnić Ci bezpieczeństwo. Przyznaj je teraz lub później w Ustawieniach.';

  @override
  String get onboardingNext => 'Dalej';

  @override
  String get onboardingSkip => 'Pomiń';

  @override
  String get onboardingFinish => 'Zakończ';

  @override
  String get sessionTitle => 'Sesja';

  @override
  String get sessionDisarm => 'Jestem bezpieczny';

  @override
  String get sessionPause => 'Wstrzymaj';

  @override
  String get sessionResume => 'Wznów';

  @override
  String get sessionHoldPrompt => 'Przytrzymaj, aby być bezpiecznym';

  @override
  String get sessionHoldSemantic =>
      'Przytrzymaj palec. Zwolnienie rozpoczyna okres karencji.';

  @override
  String sessionStepLabel(Object index, Object total) {
    return 'Krok $index z $total';
  }

  @override
  String sessionMissCount(Object count) {
    return 'Pominięte: $count';
  }

  @override
  String sessionRemaining(Object seconds) {
    return 'Pozostało ${seconds}s';
  }

  @override
  String get sessionPausedBadge => 'Wstrzymano';

  @override
  String get sessionPhaseEnded => 'Sesja zakończona';

  @override
  String get sessionSimulationBanner => 'Symulacja';

  @override
  String get sessionCheckIn => 'I\'m checked in';

  @override
  String get sessionDisarmTriggerTitle => 'Disarm trigger fired';

  @override
  String get sessionDisarmTriggerBody =>
      'A disarm trigger fired. End the session?';

  @override
  String get sessionDisarmTriggerConfirm => 'End session';

  @override
  String get sessionDisarmTriggerCancel => 'Continue';

  @override
  String get wrongPinAngelaTitle => 'Old PIN from Angela';

  @override
  String get wrongPinAngelaBody =>
      'Are you sure you want to proceed with this old PIN?';

  @override
  String get wrongPinAngelaConfirm => 'OK';

  @override
  String get wrongPinAngelaCancel => 'Cancel';

  @override
  String get sessionStepCountdownTitle => 'Warning';

  @override
  String get sessionStepCountdownBody =>
      'The next escalation fires when the countdown ends. Swipe \'I\'m safe\' below to disarm.';

  @override
  String get sessionStepDisguisedDefaultTitle => 'Reminder';

  @override
  String get sessionStepDisguisedDefaultBody =>
      'Tap \'I\'m checked in\' to confirm you\'re safe.';

  @override
  String get sessionStepSmsStatus => 'Sending message to contacts…';

  @override
  String get sessionStepSmsDelivered => 'Delivered';

  @override
  String get sessionStepSmsSent => 'Sent';

  @override
  String get sessionStepSmsQueued => 'Queued';

  @override
  String get sessionStepSmsFailed => 'Failed';

  @override
  String get sessionStepPhoneCallStatus => 'Calling emergency contact…';

  @override
  String get sessionStepPhoneCallCancel => 'Cancel call';

  @override
  String get sessionStepLoudAlarmTitle => 'Alarm playing';

  @override
  String get sessionStepLoudAlarmBody =>
      'The alarm is sounding to attract attention.';

  @override
  String get sessionStepLoudAlarmFlashWarning =>
      'Photosensitive warning: screen is flashing.';

  @override
  String get sessionStepCallEmergencyStatus => 'Calling emergency services…';

  @override
  String sessionStepCallEmergencyNumber(Object number) {
    return 'Number: $number';
  }

  @override
  String sessionStepHardwareButtonRepeat(
    Object button,
    Object count,
    Object windowMs,
  ) {
    return 'Press $button $count times within ${windowMs}ms';
  }

  @override
  String sessionStepHardwareButtonLong(Object button, Object seconds) {
    return 'Hold $button for $seconds seconds';
  }

  @override
  String get sessionStepHardwareButtonVolumeUp => 'volume up';

  @override
  String get sessionStepHardwareButtonVolumeDown => 'volume down';

  @override
  String get sessionStepHardwareButtonPower => 'power';

  @override
  String get sessionCompletedTitle => 'Sesja zakończona';

  @override
  String get sessionCompletedBody =>
      'Dotarłeś bezpiecznie. Guardian Angela kończy czuwanie.';

  @override
  String get sessionCompletedReturnHome => 'Wróć do ekranu głównego';

  @override
  String get simulationSummaryTitle => 'Podsumowanie symulacji';

  @override
  String get simulationSummaryEmpty =>
      'Podczas tej symulacji nie uruchomiono żadnych kroków.';

  @override
  String get simulationSummaryReturn => 'Wróć do ekranu głównego';

  @override
  String get fakeCallTitle => 'Połączenie przychodzące';

  @override
  String get fakeCallAnswer => 'Odbierz';

  @override
  String get fakeCallDecline => 'Odrzuć';

  @override
  String get fakeCallHangUp => 'Rozłącz';

  @override
  String get fakeCallSlideToAnswer => 'slide to answer';

  @override
  String get fakeCallUnknownCaller => 'Unknown';

  @override
  String get fakeCallIncomingWhatsapp => 'WhatsApp voice call';

  @override
  String get fakeCallIncomingTelegram => 'Telegram voice call';

  @override
  String get fakeCallIncomingSignal => 'Signal voice call';

  @override
  String get fakeCallBrandWhatsapp => 'WHATSAPP';

  @override
  String get fakeCallBrandTelegram => 'TELEGRAM';

  @override
  String get fakeCallBrandSignal => 'SIGNAL';

  @override
  String get contactsTitle => 'Kontakty alarmowe';

  @override
  String get contactsEmpty =>
      'Brak kontaktów. Dodaj kogoś, kto będzie otrzymywać wiadomości alarmowe.';

  @override
  String get contactsAdd => 'Dodaj kontakt';

  @override
  String get contactFormTitleCreate => 'Nowy kontakt';

  @override
  String get contactFormTitleEdit => 'Edytuj kontakt';

  @override
  String get contactFieldName => 'Imię';

  @override
  String get contactFieldPhone => 'Numer telefonu';

  @override
  String get contactFieldRelationship => 'Relacja (opcjonalnie)';

  @override
  String get contactFieldLanguage => 'Język SMS (opcjonalnie)';

  @override
  String get contactChannelsHeader => 'Kanały komunikacji';

  @override
  String get contactChannelSms => 'SMS';

  @override
  String get contactChannelWhatsapp => 'WhatsApp';

  @override
  String get contactChannelTelegram => 'Telegram';

  @override
  String get contactChannelPhone => 'Połączenie telefoniczne';

  @override
  String get contactDeleteConfirm => 'Usunąć kontakt?';

  @override
  String contactDeleteBody(Object name) {
    return '$name zostanie usunięty z listy kontaktów alarmowych.';
  }

  @override
  String get contactRequiredError => 'Imię i numer telefonu są wymagane.';

  @override
  String get modesTitle => 'Tryby';

  @override
  String get modesEmpty => 'Brak trybów. Dotknij Dodaj, aby utworzyć tryb.';

  @override
  String get modesAdd => 'Dodaj tryb';

  @override
  String get modeEditorTitleCreate => 'Nowy tryb';

  @override
  String get modeEditorTitleEdit => 'Edytuj tryb';

  @override
  String get modeFieldName => 'Nazwa';

  @override
  String get modeFieldCheckInType => 'Typ potwierdzenia';

  @override
  String get modeFieldDistressChain => 'Tryb alarmowy';

  @override
  String get modeFieldDistressChainDefault => 'Użyj domyślnego';

  @override
  String get modeChainHeader => 'Łańcuch eskalacji';

  @override
  String get modeChainAddStep => 'Dodaj krok';

  @override
  String get modeChainEmpty => 'Brak kroków. Dotknij Dodaj krok.';

  @override
  String get modeFieldIcon => 'Ikona';

  @override
  String get modeIconPickerTitle => 'Wybierz ikonę';

  @override
  String get modeIconClear => 'Brak ikony';

  @override
  String get modeDistressHeader => 'Wyzwalacze alarmu';

  @override
  String get modeDistressEmpty => 'Brak skonfigurowanych wyzwalaczy.';

  @override
  String get modeDistressAdd => 'Dodaj wyzwalacz';

  @override
  String get modeDistressTypeHardware => 'Przycisk sprzętowy';

  @override
  String get modeDistressButtonType => 'Przycisk';

  @override
  String get modeDistressButtonVolumeUp => 'Głośniej';

  @override
  String get modeDistressButtonVolumeDown => 'Ciszej';

  @override
  String get modeDistressButtonPower => 'Zasilanie';

  @override
  String get modeDistressPattern => 'Wzorzec';

  @override
  String get modeDistressPatternRepeat => 'Wielokrotne naciśnięcie';

  @override
  String get modeDistressPatternLong => 'Długie naciśnięcie';

  @override
  String get modeDistressPressCount => 'Liczba naciśnięć';

  @override
  String get modeDistressPressWindow => 'Okno (ms)';

  @override
  String get modeDistressLongDuration => 'Czas trzymania (sekundy)';

  @override
  String modeDistressSummaryRepeat(Object count, Object windowMs) {
    return '$count naciśnięć / $windowMs ms';
  }

  @override
  String modeDistressSummaryLong(Object seconds) {
    return 'Trzymaj ${seconds}s';
  }

  @override
  String get modeOverridesHeader => 'Nadpisania trybu';

  @override
  String get modeOverridesUseDefault => 'Użyj domyślnego';

  @override
  String get modeOverridesGpsLabel => 'Zapis GPS';

  @override
  String get modeOverridesStealthLabel => 'Tryb dyskretny';

  @override
  String get modeOverridesEventDefaultsLabel => 'Domyślne wartości zdarzeń';

  @override
  String get modeOverridesLocalTemplatesLabel => 'Lokalne szablony przypomnień';

  @override
  String get modeOverridesGpsEnabled => 'GPS włączony';

  @override
  String get modeOverridesGpsIntervalLabel => 'Interwał próbkowania (s)';

  @override
  String get modeOverridesGpsIncludeInSms => 'Dodawaj lokalizację do SMS';

  @override
  String get modeOverridesStealthEnabled => 'Tryb dyskretny włączony';

  @override
  String get modeOverridesStealthFakeName => 'Fałszywa nazwa aplikacji';

  @override
  String get modeOverridesEventDefaultsHint =>
      'Niestandardowe wartości aktywne dla tego trybu.';

  @override
  String modeOverridesLocalTemplatesCount(Object count) {
    return '$count lokalnych szablonów';
  }

  @override
  String get modeUnsavedTitle => 'Odrzucić zmiany?';

  @override
  String get modeUnsavedBody =>
      'Masz niezapisane zmiany. Odrzucić je i wyjść z edytora?';

  @override
  String get modeUnsavedDiscard => 'Odrzuć';

  @override
  String get modeUnsavedKeep => 'Kontynuuj edycję';

  @override
  String get stepDuplicate => 'Duplikuj krok';

  @override
  String get stepTimingHeader => 'Czas';

  @override
  String stepTimingSummary(Object wait, Object duration, Object grace) {
    return 'oczekiwanie ${wait}s / czas ${duration}s / okres łaski ${grace}s';
  }

  @override
  String get stepCategoryAll => 'Wszystkie';

  @override
  String get stepCategoryAction => 'Działanie';

  @override
  String get stepCategoryReminder => 'Przypomnienie';

  @override
  String get stepCategoryDisarm => 'Zameldowanie';

  @override
  String get modeTrackingHeader => 'Śledzenie GPS';

  @override
  String get modeTrackingEnabled => 'Rejestruj GPS podczas sesji';

  @override
  String get modeTrackingIntervalLabel => 'Interwał próbkowania';

  @override
  String get modeTrackingBufferSizeLabel => 'Rozmiar bufora';

  @override
  String modeTrackingBufferSizeValue(Object count) {
    return '$count punktów';
  }

  @override
  String get modeTrackingBatteryNote =>
      'Częste śledzenie GPS zwiększa zużycie baterii.';

  @override
  String get stepConfigLogGpsLabel => 'Rejestrowanie GPS';

  @override
  String get stepConfigLogGpsDefault => 'Domyślnie';

  @override
  String get stepConfigLogGpsOn => 'Wł.';

  @override
  String get stepConfigLogGpsOff => 'Wył.';

  @override
  String get stepConfigLogGpsDefaultOn => 'Domyślnie (Wł.)';

  @override
  String get stepConfigLogGpsDefaultOff => 'Domyślnie (Wył.)';

  @override
  String get moreSettingsHeader => 'Więcej ustawień';

  @override
  String moreSettingsHeaderCustomized(int count) {
    return 'Więcej ustawień (dostosowano $count)';
  }

  @override
  String get stepTypePickerLabel => 'Step type';

  @override
  String get stepTypeHoldButton => 'Przytrzymaj przycisk';

  @override
  String get stepTypeDisguisedReminder => 'Ukryte przypomnienie';

  @override
  String get stepTypeCountdownWarning => 'Ostrzeżenie z odliczaniem';

  @override
  String get stepTypeFakeCall => 'Fałszywe połączenie';

  @override
  String get stepTypeSmsContact => 'SMS do kontaktu';

  @override
  String get stepTypePhoneCallContact => 'Połączenie z kontaktem';

  @override
  String get stepTypeLoudAlarm => 'Głośny alarm';

  @override
  String get stepTypeCallEmergency => 'Zadzwoń na numer alarmowy';

  @override
  String get stepTypeHardwareButton => 'Przycisk sprzętowy';

  @override
  String get stepFieldDuration => 'Czas trwania (sekundy)';

  @override
  String get stepFieldGrace => 'Okres karencji (sekundy)';

  @override
  String get stepFieldWait => 'Oczekiwanie (sekundy)';

  @override
  String get stepFieldRetryCount => 'Powtórzenia';

  @override
  String get stepFieldRandomize => 'Losowa zmienność czasu';

  @override
  String get stepPreview => 'Podgląd w symulacji';

  @override
  String stepPreviewFired(Object description) {
    return 'Podgląd uruchomiony: $description';
  }

  @override
  String get stepConfigFakeCallCaller => 'Nazwa dzwoniącego';

  @override
  String get stepConfigFakeCallDecline =>
      'Odrzucenie liczy się jako rozbrojenie';

  @override
  String get stepConfigLoudAlarmFlash => 'Migający ekran';

  @override
  String get stepConfigLoudAlarmVolume => 'Maksymalna głośność';

  @override
  String get stepConfigCountdownVibrate => 'Wibracje';

  @override
  String get stepConfigCountdownTone => 'Odtwarzaj dźwięk';

  @override
  String get stepConfigSmsSelection => 'Odbiorcy';

  @override
  String get stepConfigSmsAllContacts => 'Wszystkie kontakty';

  @override
  String get stepConfigSmsSpecific => 'Wybrane kontakty';

  @override
  String get stepConfigSmsIncludeLocation => 'Dołącz lokalizację';

  @override
  String get stepConfigSmsIncludeMedical => 'Dołącz informacje medyczne';

  @override
  String get stepConfigHoldReleaseSensitivity => 'Czułość zwolnienia (s)';

  @override
  String get stepConfigReminderInterval => 'Odstęp przypomnień (sekundy)';

  @override
  String get stepConfigReminderTemplate => 'Szablon';

  @override
  String get stepConfigHardwarePattern => 'Wzorzec';

  @override
  String get stepConfigHardwarePressCount => 'Liczba naciśnięć';

  @override
  String get stepConfigHardwareButton => 'Przycisk';

  @override
  String get stepConfigHardwareButtonVolumeUp => 'Głośniej';

  @override
  String get stepConfigHardwareButtonVolumeDown => 'Ciszej';

  @override
  String get stepConfigHardwareButtonPower => 'Zasilanie';

  @override
  String get stepConfigHardwarePatternRepeat => 'Wielokrotne naciśnięcie';

  @override
  String get stepConfigHardwarePatternLong => 'Długie naciśnięcie';

  @override
  String get stepConfigEmergencyNumber => 'Własny numer alarmowy';

  @override
  String get stepConfigEmergencyConfirm => 'Potwierdź przed wybraniem numeru';

  @override
  String get stepConfigPhonePreSms => 'Wyślij SMS przed połączeniem';

  @override
  String get distressModesTitle => 'Tryby alarmowe';

  @override
  String get distressModeInUseTitle => 'Tryb alarmowy jest używany';

  @override
  String distressModeInUseBody(Object modes) {
    return 'Ten tryb alarmowy jest nadal powiązany z: $modes. Zanim go usuniesz, przypisz te tryby do innego trybu alarmowego.';
  }

  @override
  String get distressModesEmpty => 'Brak trybów alarmowych.';

  @override
  String get distressModesAdd => 'Dodaj tryb alarmowy';

  @override
  String get distressModeEditorTitleCreate => 'Nowy tryb alarmowy';

  @override
  String get distressModeEditorTitleEdit => 'Edytuj tryb alarmowy';

  @override
  String get distressModeName => 'Nazwa trybu alarmowego';

  @override
  String get distressCountdown => 'Uruchamianie trybu alarmowego...';

  @override
  String get distressCountdownStealth => 'Proszę czekać...';

  @override
  String get templatesTitle => 'Szablony przypomnień';

  @override
  String get templatesEmpty => 'Brak szablonów.';

  @override
  String get templatesAdd => 'Dodaj szablon';

  @override
  String get templateEditorTitleCreate => 'Nowy szablon';

  @override
  String get templateEditorTitleEdit => 'Edytuj szablon';

  @override
  String get templateFieldName => 'Nazwa w edytorze';

  @override
  String get templateFieldTitle => 'Tytuł przypomnienia';

  @override
  String get templateFieldBody => 'Treść przypomnienia';

  @override
  String get templateFieldConfirmationType => 'Typ potwierdzenia';

  @override
  String get templateFieldKeyword => 'Słowo kluczowe';

  @override
  String get templateFieldButtonLabel => 'Etykieta przycisku';

  @override
  String get templateFieldDisplayStyle => 'Styl wyświetlania';

  @override
  String get templateConfirmTapButton => 'Dotknij przycisku';

  @override
  String get templateConfirmTapWord => 'Dotknij słowa';

  @override
  String get templateConfirmSwipe => 'Przesuń';

  @override
  String get templateConfirmDismiss => 'Odrzuć';

  @override
  String get templateDisplayFullscreen => 'Pełny ekran';

  @override
  String get templateDisplaySubtle => 'Dyskretny';

  @override
  String get profileTitle => 'Profil';

  @override
  String get profileFieldName => 'Imię';

  @override
  String get profileFieldAge => 'Wiek';

  @override
  String get profileFieldBloodType => 'Grupa krwi';

  @override
  String get profileFieldAllergies => 'Alergie';

  @override
  String get profileFieldMedications => 'Leki';

  @override
  String get profileFieldConditions => 'Schorzenia';

  @override
  String get profileFieldInstructions => 'Instrukcje w nagłych przypadkach';

  @override
  String get profileAddItem => 'Dodaj pozycję';

  @override
  String get settingsTitle => 'Ustawienia';

  @override
  String get settingsSectionSecurity => 'Bezpieczeństwo';

  @override
  String get settingsSectionStealth => 'Tryb ukryty';

  @override
  String get settingsSectionDefaults => 'Domyślne';

  @override
  String get settingsSectionHistory => 'Historia';

  @override
  String get settingsSectionBackup => 'Kopia zapasowa';

  @override
  String get settingsSectionAbout => 'O aplikacji';

  @override
  String get settingsSectionFeedback => 'Opinie';

  @override
  String get settingsSectionContacts => 'Kontakty';

  @override
  String get settingsSectionModes => 'Tryby';

  @override
  String get settingsSectionProfile => 'Profil';

  @override
  String get settingsSectionDistressModes => 'Tryby alarmowe';

  @override
  String get settingsSectionReminderTemplates => 'Szablony przypomnień';

  @override
  String get settingsSectionBatteryAlert => 'Alarm baterii';

  @override
  String get settingsSectionEventDefaults => 'Domyślne kroki';

  @override
  String get settingsSectionGpsLogging => 'Rejestrowanie GPS';

  @override
  String get settingsSectionNotifications => 'Powiadomienia';

  @override
  String get settingsSectionHistoryRetention => 'Przechowywanie historii';

  @override
  String get settingsSectionAppearance => 'Wygląd';

  @override
  String get settingsThemeMode => 'Motyw';

  @override
  String get settingsThemeLight => 'Jasny';

  @override
  String get settingsThemeDark => 'Ciemny';

  @override
  String get settingsThemeSystem => 'Systemowy';

  @override
  String get settingsLanguage => 'Język';

  @override
  String get settingsEmergencyNumber => 'Numer alarmowy';

  @override
  String get settingsAlarmDnd => 'Alarm pomija tryb Nie przeszkadzać';

  @override
  String get securityTitle => 'Bezpieczeństwo';

  @override
  String get securityAppPin => 'PIN aplikacji';

  @override
  String get securitySessionEndPin => 'PIN zakończenia sesji';

  @override
  String get securityDuressPin => 'PIN przymusu';

  @override
  String get securityPinTimeout => 'Limit czasu PIN-u (sekundy)';

  @override
  String get securityDisablePin => 'Wyłącz';

  @override
  String get securitySetPin => 'Ustaw PIN';

  @override
  String get securityChangePin => 'Zmień PIN';

  @override
  String get pinSetupTitle => 'Ustaw PIN';

  @override
  String get pinSetupEnter => 'Wprowadź nowy PIN';

  @override
  String get pinSetupConfirm => 'Potwierdź PIN';

  @override
  String get pinSetupMismatch => 'Kody PIN nie są zgodne. Spróbuj ponownie.';

  @override
  String get pinEntryTitle => 'Wprowadź PIN';

  @override
  String get pinEntrySubtitle => 'Wprowadź PIN, aby kontynuować.';

  @override
  String get pinEntryBiometricReason => 'Authenticate to continue';

  @override
  String get stealthTitle => 'Tryb ukryty';

  @override
  String get stealthEnable => 'Włącz tryb ukryty';

  @override
  String get stealthFakeName => 'Fałszywa nazwa aplikacji';

  @override
  String get stealthFakeIcon => 'Fałszywa ikona';

  @override
  String get stealthNotificationDisguise => 'Maskuj powiadomienia';

  @override
  String get stealthTimerDisplay => 'Pokaż licznik w trybie ukrytym';

  @override
  String get stealthTimerDisplayNormal => 'Show full text';

  @override
  String get stealthTimerDisplaySmall => 'Show numbers only';

  @override
  String get stealthTimerDisplayNone => 'Hide timer';

  @override
  String get stealthSessionScreen => 'Usuń oznakowanie z ekranu sesji';

  @override
  String get stealthPickerTitle => 'Ikona aplikacji';

  @override
  String get stealthPickerIntro => 'Wybierz wygląd ikony w menu aplikacji.';

  @override
  String get stealthPresetMusic => 'Muzyka';

  @override
  String get stealthPresetCalendar => 'Kalendarz';

  @override
  String get stealthPresetFitness => 'Fitness';

  @override
  String get stealthPresetWeather => 'Pogoda';

  @override
  String get stealthPresetNews => 'Wiadomości';

  @override
  String get stealthPresetPhotos => 'Zdjęcia';

  @override
  String get stealthPresetNotes => 'Notatki';

  @override
  String get stealthPresetClock => 'Zegar';

  @override
  String get distressConfirmationTitle => 'Czy jesteś w niebezpieczeństwie?';

  @override
  String get distressConfirmationCancel => 'Anuluj';

  @override
  String distressConfirmationCountdown(Object seconds) {
    return 'Tryb alarmowy zostanie uruchomiony za $seconds s';
  }

  @override
  String get imSafeSliderLabel =>
      'Przesuń, aby potwierdzić „Jestem bezpieczny/a”';

  @override
  String get batteryAlertTitle => 'Alarm baterii';

  @override
  String get batteryAlertEnable => 'Włącz alarm baterii';

  @override
  String batteryAlertThreshold(Object percent) {
    return 'Próg: $percent%';
  }

  @override
  String get eventDefaultsTitle => 'Domyślne kroki';

  @override
  String get eventDefaultsBody =>
      'Te wartości domyślne odnoszą się do każdego kroku, który ich nie nadpisuje.';

  @override
  String get gpsLoggingTitle => 'Rejestrowanie GPS';

  @override
  String get gpsLoggingEnable => 'Włącz rejestrowanie GPS';

  @override
  String get gpsLoggingInterval => 'Odstęp próbkowania (sekundy)';

  @override
  String get gpsLoggingAccuracy => 'Dokładność';

  @override
  String get gpsAccuracyLow => 'Niska';

  @override
  String get gpsAccuracyMedium => 'Średnia';

  @override
  String get gpsAccuracyHigh => 'Wysoka';

  @override
  String get gpsLoggingIncludeSms => 'Dołącz lokalizację do SMS';

  @override
  String get gpsLoggingHistoryDays => 'Przechowywanie historii (dni)';

  @override
  String get notificationSettingsTitle => 'Powiadomienia';

  @override
  String get notificationSettingsBody =>
      'Guardian Angela używa powiadomień do maskowania i wyświetlania przypomnień.';

  @override
  String get historyRetentionTitle => 'Przechowywanie historii';

  @override
  String get historyRetentionBody =>
      'Jak długo Guardian Angela przechowuje dzienniki poprzednich sesji.';

  @override
  String historyRetentionDays(Object days) {
    return 'Przechowywanie: $days dni';
  }

  @override
  String get backupTitle => 'Kopia zapasowa';

  @override
  String get backupExport => 'Eksportuj dane';

  @override
  String get backupImport => 'Importuj dane';

  @override
  String get backupNotReady =>
      'Kopia zapasowa nie jest jeszcze dostępna. Wkrótce.';

  @override
  String get backupPinOptional => 'Opcjonalny PIN (szyfruje pakiet)';

  @override
  String get backupImportOk => 'Kopia zapasowa została zaimportowana.';

  @override
  String get backupSelectionHeader => 'Include in export';

  @override
  String get backupToggleSettings => 'Settings';

  @override
  String get backupToggleSettingsSubtitle =>
      'Always included so the backup can be restored.';

  @override
  String get backupToggleContacts => 'Emergency contacts';

  @override
  String get backupToggleModes => 'Modes';

  @override
  String get backupToggleDistressModes => 'Distress modes';

  @override
  String get backupToggleTemplates => 'Reminder templates';

  @override
  String get backupToggleSessionLogs => 'Session history';

  @override
  String get backupToggleRecordings => 'Audio recordings';

  @override
  String get historyTitle => 'Poprzednie sesje';

  @override
  String get historyEmpty => 'Brak poprzednich sesji.';

  @override
  String get historySearchHint => 'Search by mode name';

  @override
  String get historyFilterModeAll => 'All modes';

  @override
  String get historyFilterModeLabel => 'Mode';

  @override
  String get historyDetailTitle => 'Szczegóły sesji';

  @override
  String get evidenceExportTitle => 'Eksportuj dowody';

  @override
  String get evidenceExportAsText => 'Kopiuj jako tekst';

  @override
  String get evidenceExportAsJson => 'Kopiuj jako JSON';

  @override
  String get evidenceCopied => 'Skopiowano do schowka.';

  @override
  String get aboutTitle => 'O aplikacji';

  @override
  String get aboutVersion => 'Wersja';

  @override
  String get aboutCredits => 'Stworzone z troską o osoby w drodze do domu.';

  @override
  String get feedbackTitle => 'Opinie';

  @override
  String get feedbackBody => 'Chętnie poznamy Twoją opinię.';

  @override
  String get feedbackFieldMessage => 'Wiadomość';

  @override
  String get feedbackSend => 'Otwórz e-mail';

  @override
  String get pickerNoneLabel => '— brak —';

  @override
  String emergencyConfirmTitle(Object number) {
    return 'Calling $number';
  }

  @override
  String get emergencyConfirmSubtitle => 'Hold the cancel button to abort.';

  @override
  String emergencyConfirmCountdown(Object seconds) {
    return 'Calling in ${seconds}s';
  }

  @override
  String get emergencyConfirmCancel => 'Cancel';

  @override
  String get stealthCalendarUpcoming => 'Upcoming';

  @override
  String get stealthCalendarUpcomingEvent => 'Meeting';

  @override
  String stealthCalendarUntilEvent(Object minutes) {
    return 'in $minutes min';
  }

  @override
  String get stealthCalendarToday => 'Today';

  @override
  String get stealthCalendarEvent1 => 'Coffee with Alex';

  @override
  String get stealthCalendarEvent2 => 'Standup';

  @override
  String get stealthCalendarEvent3 => 'Lunch';

  @override
  String get stealthCalendarEvent4 => 'Workout';

  @override
  String get stealthCalendarEvent5 => 'Dinner with Sam';

  @override
  String get stealthDisarmGestureHint => 'Swipe up to end';

  @override
  String get stealthMusicTrackTitle => 'Untitled Track';

  @override
  String get stealthMusicArtist => 'Unknown Artist';

  @override
  String get stealthMusicAlbum => 'Unknown Album';

  @override
  String get stealthMusicNowPlaying => 'Now playing';

  @override
  String get stealthMusicSwipeHint => 'Swipe to disarm';

  @override
  String get stealthMusicPrevious => 'Previous';

  @override
  String get stealthMusicPause => 'Pause';

  @override
  String get stealthMusicNext => 'Next';

  @override
  String get stealthPodcastShowName => 'Podcast';

  @override
  String get stealthPodcastEpisodeTitle => 'Episode';

  @override
  String get stealthPodcastEpisodesHeader => 'Episodes';

  @override
  String get stealthPodcastSpeedLabel => '1x';

  @override
  String get stealthPodcastEpisode1 => 'Episode 1';

  @override
  String get stealthPodcastEpisode2 => 'Episode 2';

  @override
  String get stealthPodcastEpisode3 => 'Episode 3';

  @override
  String get stealthPodcastEpisode4 => 'Episode 4';

  @override
  String get stealthPresetPodcast => 'Podcast';

  @override
  String get stealthPresetNone => 'None';

  @override
  String get sessionSimSpeedLabel => 'Speed';

  @override
  String sessionSimSpeedValue(Object value) {
    return '${value}x';
  }

  @override
  String get sessionSimSpeedBackgroundCap => 'Background-capped';

  @override
  String get sessionSimAdvancedLabel => 'Advanced';

  @override
  String get sessionSimTriggerPanic => 'Trigger panic';

  @override
  String get sessionSimTriggerArrival => 'Trigger arrival';

  @override
  String get sessionSimTriggerBattery => 'Trigger low battery';

  @override
  String get simulateGpsArrival => 'Simulate arrival';

  @override
  String get simulateLowBattery => 'Simulate low battery';

  @override
  String get launchGateTitle => 'Unlock Guardian Angela';

  @override
  String get launchGateSubtitle => 'Enter your PIN or use biometrics.';

  @override
  String get launchGateWrong => 'Wrong PIN';

  @override
  String get launchGateBiometricReason => 'Unlock Guardian Angela';

  @override
  String get launchGateUseBiometric => 'Use biometrics';
}
