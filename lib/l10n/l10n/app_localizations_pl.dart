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
  String get angelaDialogTitle => 'Wprowadzono stary PIN';

  @override
  String get angelaDialogBody =>
      'Wygląda na to, że użyto starego PIN-u. Czy na pewno kontynuować?';

  @override
  String get angelaDialogCancel => 'Anuluj';

  @override
  String get angelaDialogConfirm => 'Kontynuuj';

  @override
  String get commonCancel => 'Anuluj';

  @override
  String get commonOk => 'OK';

  @override
  String get profileAngelaWarningTitle => 'Uwaga dotycząca imienia „Angela”';

  @override
  String get profileAngelaWarningBody =>
      'Guardian Angela używa imienia „Angela” jako słowa-klucza bezpieczeństwa. Użycie go jako własnego imienia może wprowadzać w błąd. Zapisać mimo to?';

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
  String get pinSubmit => 'Zatwierdź';

  @override
  String get homeTitle => 'Guardian Angela';

  @override
  String get homeStartSession => 'Rozpocznij sesję';

  @override
  String get homeStartConfirmTitle => 'Rozpocząć sesję?';

  @override
  String get homeStartConfirmBody =>
      'Upewnij się, że kontakty i PIN są skonfigurowane. Sesja będzie działać na pierwszym planie, a wybrany tryb będzie kierował zameldowaniami.';

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
  String get homeContactsBannerNone =>
      'Brak skonfigurowanych kontaktów alarmowych.';

  @override
  String homeContactsBannerFew(int count) {
    return 'Skonfigurowano $count kontakt(ów). Zalecamy co najmniej 3.';
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
  String get sessionCheckIn => 'Jestem zameldowany/a';

  @override
  String get sessionDisarmTriggerTitle => 'Uruchomiono wyzwalacz rozbrojenia';

  @override
  String get sessionDisarmTriggerBody =>
      'Wyzwalacz rozbrojenia został uruchomiony. Zakończyć sesję?';

  @override
  String get sessionDisarmTriggerConfirm => 'Zakończ sesję';

  @override
  String get sessionDisarmTriggerCancel => 'Kontynuuj';

  @override
  String get wrongPinAngelaTitle => 'Stary PIN od Angela';

  @override
  String get wrongPinAngelaBody =>
      'Czy na pewno chcesz kontynuować z tym starym PIN-em?';

  @override
  String get wrongPinAngelaConfirm => 'OK';

  @override
  String get wrongPinAngelaCancel => 'Anuluj';

  @override
  String get sessionStepCountdownTitle => 'Ostrzeżenie';

  @override
  String get sessionStepCountdownBody =>
      'Następna eskalacja uruchomi się po zakończeniu odliczania. Przesuń poniżej „Jestem bezpieczny/a”, aby rozbroić.';

  @override
  String get sessionStepDisguisedDefaultTitle => 'Przypomnienie';

  @override
  String get sessionStepDisguisedDefaultBody =>
      'Dotknij „Jestem zameldowany/a”, aby potwierdzić, że jesteś bezpieczny/a.';

  @override
  String get sessionStepSmsStatus => 'Wysyłanie wiadomości do kontaktów…';

  @override
  String get sessionStepSmsDelivered => 'Doręczono';

  @override
  String get sessionStepSmsSent => 'Wysłano';

  @override
  String get sessionStepSmsQueued => 'W kolejce';

  @override
  String get sessionStepSmsFailed => 'Niepowodzenie';

  @override
  String get sessionStepPhoneCallStatus => 'Dzwonienie do kontaktu alarmowego…';

  @override
  String get sessionStepPhoneCallCancel => 'Anuluj połączenie';

  @override
  String get sessionStepLoudAlarmTitle => 'Alarm odtwarzany';

  @override
  String get sessionStepLoudAlarmBody =>
      'Alarm dźwiękowy zwraca uwagę otoczenia.';

  @override
  String get sessionStepLoudAlarmFlashWarning =>
      'Ostrzeżenie dla osób światłoczułych: ekran miga.';

  @override
  String get sessionStepCallEmergencyStatus => 'Dzwonienie na numer alarmowy…';

  @override
  String sessionStepCallEmergencyNumber(Object number) {
    return 'Numer: $number';
  }

  @override
  String sessionStepHardwareButtonRepeat(
    Object button,
    Object count,
    Object windowMs,
  ) {
    return 'Naciśnij $button $count razy w ciągu $windowMs ms';
  }

  @override
  String sessionStepHardwareButtonLong(Object button, Object seconds) {
    return 'Przytrzymaj $button przez $seconds sekund';
  }

  @override
  String get sessionStepHardwareButtonVolumeUp => 'głośniej';

  @override
  String get sessionStepHardwareButtonVolumeDown => 'ciszej';

  @override
  String get sessionStepHardwareButtonPower => 'zasilanie';

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
  String get fakeCallSlideToAnswer => 'przesuń, aby odebrać';

  @override
  String get fakeCallUnknownCaller => 'Nieznany';

  @override
  String get fakeCallIncomingWhatsapp => 'Połączenie głosowe WhatsApp';

  @override
  String get fakeCallIncomingTelegram => 'Połączenie głosowe Telegram';

  @override
  String get fakeCallIncomingSignal => 'Połączenie głosowe Signal';

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
  String get contactLanguageDefault => 'Domyślny (język aplikacji)';

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
  String get modeFieldDistressMode => 'Tryb alarmowy';

  @override
  String get modeFieldDistressModeDefault => 'Użyj domyślnego';

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
  String get stepTypePickerLabel => 'Typ kroku';

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
  String get securityAppPinBiometric => 'Użyj biometrii dla PIN-u aplikacji';

  @override
  String get securitySessionEndPinBiometric =>
      'Użyj biometrii dla PIN-u zakończenia sesji';

  @override
  String get securityDistressCancelBiometric =>
      'Użyj biometrii do anulowania alarmu';

  @override
  String get securityDuressTest => 'Testuj PIN przymusu';

  @override
  String get securityDuressTestSubtitle => 'Sprawdź, czy PIN przymusu działa.';

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
  String get pinEntryBiometricReason => 'Uwierzytelnij, aby kontynuować';

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
  String get stealthTimerDisplayNormal => 'Pokaż pełny tekst';

  @override
  String get stealthTimerDisplaySmall => 'Pokaż tylko liczby';

  @override
  String get stealthTimerDisplayNone => 'Ukryj licznik';

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
  String get backupSelectionHeader => 'Uwzględnij w eksporcie';

  @override
  String get backupToggleSettings => 'Ustawienia';

  @override
  String get backupToggleSettingsSubtitle =>
      'Zawsze uwzględniane, aby kopię zapasową można było przywrócić.';

  @override
  String get backupToggleContacts => 'Kontakty alarmowe';

  @override
  String get backupToggleModes => 'Tryby';

  @override
  String get backupToggleDistressModes => 'Tryby alarmowe';

  @override
  String get backupToggleTemplates => 'Szablony przypomnień';

  @override
  String get backupToggleSessionLogs => 'Historia sesji';

  @override
  String get backupToggleRecordings => 'Nagrania audio';

  @override
  String get historyTitle => 'Poprzednie sesje';

  @override
  String get historyEmpty => 'Brak poprzednich sesji.';

  @override
  String get historyTabReal => 'Rzeczywiste';

  @override
  String get historyTabSimulated => 'Symulacje';

  @override
  String get historySearchHint => 'Szukaj według nazwy trybu';

  @override
  String get historyFilterModeAll => 'Wszystkie tryby';

  @override
  String get historyFilterModeLabel => 'Tryb';

  @override
  String get historyDateRangePick => 'Zakres dat';

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
    return 'Dzwonienie pod $number';
  }

  @override
  String get emergencyConfirmSubtitle =>
      'Przytrzymaj przycisk anulowania, aby przerwać.';

  @override
  String emergencyConfirmCountdown(Object seconds) {
    return 'Połączenie za $seconds s';
  }

  @override
  String get emergencyConfirmCancel => 'Anuluj';

  @override
  String get stealthCalendarUpcoming => 'Nadchodzące';

  @override
  String get stealthCalendarUpcomingEvent => 'Spotkanie';

  @override
  String stealthCalendarUntilEvent(Object minutes) {
    return 'za $minutes min';
  }

  @override
  String get stealthCalendarToday => 'Dzisiaj';

  @override
  String get stealthCalendarEvent1 => 'Kawa z Aleksem';

  @override
  String get stealthCalendarEvent2 => 'Standup';

  @override
  String get stealthCalendarEvent3 => 'Lunch';

  @override
  String get stealthCalendarEvent4 => 'Trening';

  @override
  String get stealthCalendarEvent5 => 'Kolacja z Samem';

  @override
  String get stealthDisarmGestureHint => 'Przesuń w górę, aby zakończyć';

  @override
  String get stealthMusicTrackTitle => 'Utwór bez tytułu';

  @override
  String get stealthMusicArtist => 'Nieznany wykonawca';

  @override
  String get stealthMusicAlbum => 'Nieznany album';

  @override
  String get stealthMusicNowPlaying => 'Teraz odtwarzane';

  @override
  String get stealthMusicSwipeHint => 'Przesuń, aby rozbroić';

  @override
  String get stealthMusicPrevious => 'Poprzedni';

  @override
  String get stealthMusicPause => 'Pauza';

  @override
  String get stealthMusicNext => 'Następny';

  @override
  String get stealthPodcastShowName => 'Podcast';

  @override
  String get stealthPodcastEpisodeTitle => 'Odcinek';

  @override
  String get stealthPodcastEpisodesHeader => 'Odcinki';

  @override
  String get stealthPodcastSpeedLabel => '1x';

  @override
  String get stealthPodcastEpisode1 => 'Odcinek 1';

  @override
  String get stealthPodcastEpisode2 => 'Odcinek 2';

  @override
  String get stealthPodcastEpisode3 => 'Odcinek 3';

  @override
  String get stealthPodcastEpisode4 => 'Odcinek 4';

  @override
  String get stealthPresetPodcast => 'Podcast';

  @override
  String get stealthPresetNone => 'Brak';

  @override
  String get sessionSimSpeedLabel => 'Prędkość';

  @override
  String sessionSimSpeedValue(Object value) {
    return '${value}x';
  }

  @override
  String get sessionSimSpeedBackgroundCap => 'W tle ograniczone do 60×';

  @override
  String get sessionSimAdvancedLabel => 'Zaawansowane';

  @override
  String get sessionSimTriggerPanic => 'Wyzwól panikę';

  @override
  String get sessionSimTriggerArrival => 'Wyzwól przybycie';

  @override
  String get sessionSimTriggerBattery => 'Wyzwól niski poziom baterii';

  @override
  String get simulateGpsArrival => 'Symuluj przybycie';

  @override
  String get simulateLowBattery => 'Symuluj niski poziom baterii';

  @override
  String get launchGateTitle => 'Odblokuj Guardian Angela';

  @override
  String get launchGateSubtitle => 'Wprowadź PIN lub użyj biometrii.';

  @override
  String get launchGateWrong => 'Błędny PIN';

  @override
  String get launchGateBiometricReason => 'Odblokuj Guardian Angela';

  @override
  String get launchGateUseBiometric => 'Użyj biometrii';
}
