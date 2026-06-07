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
  String get commonDelete => 'Usuń';

  @override
  String get commonEdit => 'Edytuj';

  @override
  String get commonClose => 'Zamknij';

  @override
  String get commonConfirm => 'Potwierdź';

  @override
  String get commonBack => 'Wstecz';

  @override
  String get pinSubmit => 'Zatwierdź';

  @override
  String get homeTitle => 'Guardian Angela';

  @override
  String get homeStartSession => 'Rozpocznij sesję';

  @override
  String get homePermissionsNotification => 'Powiadomienia';

  @override
  String get homePermissionsLocation => 'Lokalizacja';

  @override
  String get homePermissionsCallPhone => 'Połączenia telefoniczne';

  @override
  String get homePermissionsSendSms => 'Wysyłanie SMS';

  @override
  String get homeSimulate => 'Symuluj';

  @override
  String get homeNoModes => 'Brak trybów. Dotknij Tryby, aby dodać.';

  @override
  String get homeContactsBannerNone =>
      'Brak skonfigurowanych kontaktów alarmowych.';

  @override
  String get homeMenuSettings => 'Ustawienia';

  @override
  String get homeMenuContacts => 'Kontakty';

  @override
  String get homeMenuHistory => 'Poprzednie sesje';

  @override
  String get onboardingProfileTitle => 'Profil i pierwszy kontakt';

  @override
  String get onboardingPermissionsTitle => 'Uprawnienia';

  @override
  String get onboardingNext => 'Dalej';

  @override
  String get onboardingSkip => 'Pomiń';

  @override
  String get onboardingUseSimNumber => 'Użyj numeru z karty SIM';

  @override
  String onboardingUseSimNumberHint(Object number) {
    return '$number';
  }

  @override
  String get onboardingUseSimNumberUnsupported => 'Niedostępne na iOS';

  @override
  String get onboardingUseSimNumberUnavailable =>
      'Nie udało się odczytać numeru';

  @override
  String get onboardingUseSimNumberPermissionDenied => 'Odmówiono uprawnienia';

  @override
  String get sessionTitle => 'Sesja';

  @override
  String get sessionDisarm => 'Jestem bezpieczny';

  @override
  String get sessionDisarmStealth => 'Angela niepotrzebna';

  @override
  String get homeChainSummaryTitle => 'Podsumowanie łańcucha';

  @override
  String get homeChainSummaryEmpty =>
      'Ten tryb nie ma jeszcze kroków – dotknij trybu, by edytować.';

  @override
  String homeChainSummaryTimingTitle(Object name) {
    return 'Krok: $name';
  }

  @override
  String homeChainSummaryWait(Object seconds) {
    return 'Oczekiwanie: $seconds s';
  }

  @override
  String homeChainSummaryDuration(Object seconds) {
    return 'Aktywny: $seconds s';
  }

  @override
  String homeChainSummaryGrace(Object seconds) {
    return 'Okres karencji: $seconds s';
  }

  @override
  String homeChainSummaryRetry(Object count) {
    return 'Powtórzeń: $count';
  }

  @override
  String homeChainSummaryNextStep(Object name) {
    return 'Następny krok: $name';
  }

  @override
  String get homeChainSummaryNextStepNone => 'Następny krok: koniec łańcucha';

  @override
  String get homeChainSummaryClose => 'Zamknij';

  @override
  String get chainStepNameHoldButton => 'Trzymaj, by zostać bezpieczną';

  @override
  String get chainStepNameDisguisedReminder => 'Zamaskowane przypomnienie';

  @override
  String get chainStepNameCountdownWarning => 'Ostrzeżenie z odliczaniem';

  @override
  String get chainStepNameFakeCall => 'Fałszywe połączenie';

  @override
  String get chainStepNameSmsContact => 'SMS do kontaktu';

  @override
  String get chainStepNamePhoneCallContact => 'Telefon do kontaktu';

  @override
  String get chainStepNameLoudAlarm => 'Głośny alarm';

  @override
  String get chainStepNameCallEmergency => 'Połączenie alarmowe';

  @override
  String get chainStepNameHardwareButton => 'Przycisk sprzętowy';

  @override
  String get homeChecklistTitle => 'Konfiguracja bezpieczeństwa';

  @override
  String get homeChecklistDismissTooltip => 'Ukryj listę';

  @override
  String get homeChecklistExpandTooltip => 'Pokaż listę';

  @override
  String get homeChecklistCollapseTooltip => 'Zwiń listę';

  @override
  String homeChecklistProgress(Object done, Object total) {
    return '$done z $total gotowe';
  }

  @override
  String get homeChecklistAllDoneBanner => 'Gotowe – jesteś chroniona!';

  @override
  String get homeChecklistInfoTooltip => 'Dlaczego to ważne';

  @override
  String get homeChecklistGotIt => 'Rozumiem';

  @override
  String get homeChecklistGoThere => 'Przejdź';

  @override
  String get homeChecklistItem1Title => 'Dodaj kontakt alarmowy';

  @override
  String get homeChecklistItem2Title => 'Ustaw PIN zakończenia sesji';

  @override
  String get homeChecklistItem3Title => 'Skonfiguruj tryb dyskretny';

  @override
  String get homeChecklistItem4Title => 'Wypróbuj symulację';

  @override
  String get homeChecklistItem5Title => 'Dostosuj tryb bezpieczeństwa';

  @override
  String get homeChecklistItem6Title => 'Przyznaj wymagane uprawnienia';

  @override
  String get checklistInfo1Body =>
      'Kontakty alarmowe to osoby, do których Guardian Angela pisze i dzwoni, gdy nie zgłosisz się na czas. Bez przynajmniej jednego kontaktu łańcuch nie ma do kogo eskalować.';

  @override
  String get checklistInfo2Body =>
      'PIN zakończenia sesji uniemożliwia napastnikowi ciche zakończenie aktywnej sesji. Może próbować, ale pięć błędnych wprowadzeń po cichu uruchomi twój łańcuch alarmowy.';

  @override
  String get checklistInfo3Body =>
      'Tryb dyskretny ukrywa aktywną sesję jako coś niepozornego na ekranie – odtwarzacz muzyki, wstrzymany licznik, pusty ekran blokady. Użyj go, gdy ktoś obok nie może zobaczyć, że masz aplikację bezpieczeństwa.';

  @override
  String get checklistInfo4Body =>
      'Symulacja przepuszcza twój tryb bezpieczeństwa od początku do końca, ale bez wysyłania prawdziwych SMS-ów, wykonywania prawdziwych połączeń ani uruchamiania głośnego alarmu. Użyj jej, by poznać czasy, zanim ich naprawdę potrzebujesz.';

  @override
  String get checklistInfo5Body =>
      'Tryby własne pozwalają dostroić kroki, czasy i wyzwalacze do konkretnej sytuacji – powrót do domu, pierwsza randka, nocna zmiana. Dwa wbudowane tryby to punkt wyjścia, a nie cel.';

  @override
  String get checklistInfo6Body =>
      'Bez uprawnień powiadomień Guardian Angela nie utrzyma trwałego statusu na pierwszym planie, nie dostarczy zamaskowanych przypomnień ani nie ostrzeże cię, że łańcuch zaraz eskaluje.';

  @override
  String get checklistTutorial3Body =>
      'Otwórz domyślne ustawienia trybu dyskretnego i włącz „Włącz tryb dyskretny”. Stamtąd wybierzesz fałszywą markę muzyczną, ukryjesz licznik sesji albo zamaskujesz ikonę na ekranie głównym.';

  @override
  String get checklistTutorial4Body =>
      'Po wybraniu trybu dotknij obramowanego przycisku „Symuluj” na ekranie głównym. Sesja działa z pomarańczową ramką i odznaką [SIM] – nic nie opuszcza telefonu.';

  @override
  String get checklistTutorial5Body =>
      'Otwórz ekran Trybów i albo edytuj wbudowany tryb (Spacer / Randka), albo utwórz nowy od zera. Dopasuj łańcuch, dodaj fałszywe połączenie, ustaw własne czasy.';

  @override
  String get sessionHoldPrompt => 'Przytrzymaj, aby być bezpiecznym';

  @override
  String sessionStepLabel(Object index, Object total) {
    return 'Krok $index z $total';
  }

  @override
  String sessionMissCount(Object count) {
    return 'Pominięte: $count';
  }

  @override
  String get sessionPausedBadge => 'Wstrzymano';

  @override
  String get sessionPausedIncomingCall =>
      'Wstrzymano — połączenie przychodzące';

  @override
  String get sessionPhaseEnded => 'Sesja zakończona';

  @override
  String get sessionSimulationBanner => 'Symulacja';

  @override
  String get sessionCheckIn => 'Jestem zameldowany/a';

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
  String get sessionReminderEarlyCheckInHint =>
      'Dotknij, aby zameldować się teraz';

  @override
  String get sessionReminderDefaultButton => 'OK';

  @override
  String get sessionReminderTapWordHint => 'Dotknij, aby kontynuować';

  @override
  String get sessionReminderSwipeLabel => 'Przesuń, aby zamknąć';

  @override
  String get sessionReminderDismissLabel => 'Zamknij';

  @override
  String get sessionStepSmsStatus => 'Wysyłanie wiadomości do kontaktów…';

  @override
  String get sessionStepPhoneCallStatus => 'Dzwonienie do kontaktu alarmowego…';

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
  String get fakeCallBrandAndroid => 'TELEFON';

  @override
  String get fakeCallBrandIos => 'TELEFON';

  @override
  String get fakeCallBrandMinimal => 'POŁĄCZENIE';

  @override
  String get fakeCallDeclineSafeLabel => 'Odrzuć (jestem bezpieczna)';

  @override
  String get fakeCallDeclineUnsafeLabel => 'Odrzuć (pozostań czujna)';

  @override
  String get fakeCallHoldForDistress => 'Przytrzymaj 5 s, by wezwać pomoc';

  @override
  String fakeCallVoicePrompt(String name) {
    return 'Komunikat głosowy: $name';
  }

  @override
  String fakeCallVibrationLabel(String pattern) {
    return 'Wibracje: $pattern';
  }

  @override
  String get fakeCallVibrationPatternDefault => 'domyślne';

  @override
  String get fakeCallSlideToAnswerHint => 'Przesuń, aby odebrać';

  @override
  String fakeCallActiveDuration(String mm, String ss) {
    return '$mm:$ss';
  }

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
  String get contactFormIosSmsWarning =>
      'Na iOS SMS otwiera aplikację Wiadomości. Musisz ręcznie dotknąć Wyślij.';

  @override
  String get modesTitle => 'Tryby';

  @override
  String get modesEmpty => 'Brak trybów. Dotknij Dodaj, aby utworzyć tryb.';

  @override
  String get modesAdd => 'Dodaj tryb';

  @override
  String get modesNewPickerBlank => 'Pusty tryb';

  @override
  String get modesNewPickerBlankSubtitle => 'Zacznij z pustym łańcuchem';

  @override
  String modesNewPickerFromTemplate(String name) {
    return 'Z $name';
  }

  @override
  String get modesNewPickerFromTemplateSubtitle =>
      'Skopiuj łańcuch i wyzwalacze tego trybu';

  @override
  String get modeEditorTitleCreate => 'Nowy tryb';

  @override
  String get modeEditorTitleEdit => 'Edytuj tryb';

  @override
  String get modeFieldName => 'Nazwa';

  @override
  String get modeChainHeader => 'Łańcuch';

  @override
  String get modeChainAddStep => 'Dodaj krok';

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
  String stepTimingSummary(Object wait, Object duration, Object grace) {
    return 'oczekiwanie ${wait}s / czas ${duration}s / okres łaski ${grace}s';
  }

  @override
  String get stepConfigTimingHeader => 'Czas';

  @override
  String get stepConfigEventHeader => 'Konfiguracja zdarzenia';

  @override
  String get stepConfigAdvancedHeader => 'Ponawianie i zaawansowane';

  @override
  String get stepFieldWait => 'Oczekiwanie przed uruchomieniem (sekundy)';

  @override
  String get stepFieldDuration => 'Czas aktywności (sekundy)';

  @override
  String get stepFieldGrace => 'Okres karencji (sekundy)';

  @override
  String get stepFieldRetryCount => 'Powtórzenia';

  @override
  String get stepFieldRandomize => 'Losowy czas (±20%)';

  @override
  String get stepDuplicate => 'Duplikuj krok';

  @override
  String get stepResetDefaults => 'Przywróć domyślne';

  @override
  String get smsContactRecipientsHeader => 'Kontakty do powiadomienia';

  @override
  String get smsContactSummaryAll => 'Do: wszystkie włączone kontakty';

  @override
  String get smsContactSummaryNone => 'Nie wybrano odbiorców';

  @override
  String smsContactSummaryTo(Object names) {
    return 'Do: $names';
  }

  @override
  String get smsContactChannelDisabledTooltip =>
      'Niewłączone dla tego kontaktu — edytuj kontakt, aby dodać ten kanał.';

  @override
  String get smsContactEmptyAddPrompt =>
      'Brak kontaktów — dodaj jeden w Kontaktach';

  @override
  String get distressModesEmpty => 'Brak trybów alarmowych.';

  @override
  String get distressModeEditorTitleCreate => 'Nowy tryb alarmowy';

  @override
  String get distressModeEditorTitleEdit => 'Edytuj tryb alarmowy';

  @override
  String get templatesTitle => 'Szablony przypomnień';

  @override
  String get templatesEmpty => 'Brak szablonów.';

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
  String get settingsThemeLight => 'Jasny';

  @override
  String get settingsThemeDark => 'Ciemny';

  @override
  String get settingsThemeSystem => 'Systemowy';

  @override
  String get settingsEmergencyNumberLabel => 'Numer alarmowy';

  @override
  String get settingsRedoOnboardingActiveSessionTooltip =>
      'Nie można powtórzyć wprowadzenia podczas aktywnej sesji';

  @override
  String get settingsEmergencyNumberCountryPickerTitle =>
      'Wybierz numer alarmowy';

  @override
  String get settingsRedoOnboarding => 'Powtórz wprowadzenie';

  @override
  String get settingsRedoOnboardingConfirm => 'Zrestartować wprowadzenie?';

  @override
  String get securitySessionEndPinBiometric =>
      'Użyj biometrii dla PIN-u zakończenia sesji';

  @override
  String get securityAppPinBiometric => 'Użyj biometrii do blokady aplikacji';

  @override
  String get launchPinTitle => 'Wprowadź PIN aplikacji';

  @override
  String get launchPinBiometricReason => 'Odblokuj Guardian Angela';

  @override
  String get launchPinIncorrect => 'Nieprawidłowy PIN';

  @override
  String get securitySetPin => 'Ustaw PIN';

  @override
  String get securityChangePin => 'Zmień PIN';

  @override
  String get pinSetupMismatch => 'Kody PIN nie są zgodne. Spróbuj ponownie.';

  @override
  String get stealthTimerDisplayNormal => 'Pokaż pełny tekst';

  @override
  String get stealthTimerDisplaySmall => 'Pokaż tylko liczby';

  @override
  String get stealthTimerDisplayNone => 'Ukryj licznik';

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
  String get eventDefaultsTitle => 'Domyślne kroki';

  @override
  String get historyRetentionTitle => 'Przechowywanie historii';

  @override
  String get backupTitle => 'Kopia zapasowa';

  @override
  String get aboutTitle => 'O aplikacji';

  @override
  String aboutVersion(Object version) {
    return 'Wersja';
  }

  @override
  String get feedbackTitle => 'Opinie';

  @override
  String get feedbackSend => 'Otwórz e-mail';

  @override
  String get stealthPresetPodcast => 'Podcast';

  @override
  String get stealthPresetNone => 'Brak';

  @override
  String get stealthLockTaskLabel => 'Przypnij aplikację podczas sesji';

  @override
  String get stealthLockTaskSubtitle =>
      'Uniemożliwia opuszczenie aplikacji podczas trwającej sesji. Na Androidzie włącza przypinanie ekranu; na innych platformach nie ma efektu.';

  @override
  String get homeTagline => 'Twój anioł czuwa nad tobą.';

  @override
  String get onboardingWelcomeGreeting => 'Cześć, jestem Angela';

  @override
  String get onboardingWelcomeBodyFull =>
      'Jestem twoim osobistym aniołem stróżem. Towarzyszę ci w drodze, czuwam nad twoim wieczorem i działam, gdy coś jest nie tak.';

  @override
  String get onboardingGetStarted => 'Zaczynajmy';

  @override
  String get onboardingProfileNameLabel => 'Imię';

  @override
  String get onboardingProfilePhoneLabel => 'Numer telefonu';

  @override
  String get onboardingProfilePhoneHelper =>
      'Dołączany do wiadomości alarmowych.';

  @override
  String get onboardingEmergencyContactHeader => 'Kontakt alarmowy';

  @override
  String get onboardingEmergencyContactPrompt =>
      'Z kim mamy się skontaktować, jeśli coś pójdzie nie tak?';

  @override
  String get onboardingEmergencyContactAdd => 'Dodaj kontakt alarmowy';

  @override
  String get onboardingPermissionsIntro =>
      'Te uprawnienia zapewniają ci bezpieczeństwo podczas sesji.';

  @override
  String get onboardingPermissionsGrantAll => 'Przyznaj wszystkie';

  @override
  String get onboardingPermissionsRequired => 'WYMAGANE';

  @override
  String get onboardingPermissionsOptional => 'OPCJONALNE';

  @override
  String get onboardingPermissionsMicrophone => 'Mikrofon';

  @override
  String get onboardingPermissionsCamera => 'Aparat';

  @override
  String get onboardingPermissionsNotificationDesc =>
      'Wymagane do alertów sesji i przypomnień.';

  @override
  String get onboardingPermissionsSmsDesc =>
      'Wymagane do wysyłania alarmowych wiadomości SMS.';

  @override
  String get onboardingPermissionsPhoneDesc =>
      'Wymagane do wykonywania połączeń alarmowych i fałszywych.';

  @override
  String get onboardingPermissionsLocationDesc =>
      'Dołączana do wiadomości alarmowych, gdy rejestrowanie GPS jest włączone.';

  @override
  String get onboardingPermissionsMicrophoneDesc =>
      'Używany do nagrywania dźwięku w sytuacji zagrożenia.';

  @override
  String get onboardingPermissionsCameraDesc =>
      'Używany do sygnalizowania SOS lampą błyskową.';

  @override
  String get sessionInterruptedTitle => 'Sesja przerwana';

  @override
  String get sessionInterruptedBody =>
      'Sesja była aktywna w momencie zatrzymania aplikacji. Stan sesji został utracony — nic nie zostało przywrócone. Pokazujemy to, abyś wiedziała.';

  @override
  String get sessionInterruptedAcknowledge => 'Rozumiem';

  @override
  String sessionInterruptedMode(Object name) {
    return 'Tryb: $name';
  }

  @override
  String sessionInterruptedStarted(Object time) {
    return 'Rozpoczęto: $time';
  }

  @override
  String get sessionGpsDestinationTitle => 'Cel podróży';

  @override
  String get sessionGpsDestinationBody =>
      'Wprowadź współrzędne celu dla wyzwalacza rozbrojenia po dotarciu na miejsce (GPS).';

  @override
  String get sessionGpsDestinationLat => 'Szerokość geograficzna';

  @override
  String get sessionGpsDestinationLng => 'Długość geograficzna';

  @override
  String get sessionGpsDestinationSkip => 'Pomiń w tej sesji';

  @override
  String get sessionGpsDestinationConfirm => 'Użyj celu';

  @override
  String get sessionEndOverlayTitle => 'Zakończyć sesję?';

  @override
  String get sessionEndOverlayBody =>
      'Przesuń, aby potwierdzić, że chcesz zakończyć sesję';

  @override
  String get sessionEndOverlaySwipeLabel => 'Przesuń, aby zakończyć';

  @override
  String get sessionEndOverlaySimBadge => '[SIM] Tryb ćwiczeniowy';

  @override
  String get sessionEndPinPromptTitle => 'Wprowadź PIN zakończenia sesji';

  @override
  String get sessionEndPinAppPinMismatch =>
      'Użyj PIN-u zakończenia sesji, a nie PIN-u blokady aplikacji.';

  @override
  String get sessionEndPinIncorrect => 'Nieprawidłowy PIN';

  @override
  String get sessionEndPinSimSkip => 'Pomiń (tylko symulacja)';

  @override
  String get sessionEndSimDistressWouldFire =>
      'Łańcuch alarmowy zostałby uruchomiony (5 błędnych PIN-ów)';

  @override
  String get distressConfirmTitle => 'Aktywowano alarm';

  @override
  String distressConfirmCountdown(int seconds) {
    return 'Dotknij, aby anulować — masz $seconds sek.';
  }

  @override
  String get distressConfirmCancel => 'Dotknij, aby anulować';

  @override
  String get distressConfirmFooter =>
      'Jeśli nie anulujesz, łańcuch alarmowy uruchomi się natychmiast.';

  @override
  String get distressCancelPinPromptTitle => 'Wprowadź PIN zakończenia sesji';

  @override
  String distressCancelPinTimeoutLabel(int seconds) {
    return 'pozostało $seconds s';
  }

  @override
  String get distressCancelPinIncorrect => 'Nieprawidłowy PIN';

  @override
  String get distressCancelPinAppPinMismatch =>
      'Użyj PIN-u zakończenia sesji, a nie PIN-u blokady aplikacji.';

  @override
  String get distressCancelPinSimSkip => 'Pomiń (tylko symulacja)';

  @override
  String get distressCancelSimDistressWouldFire =>
      'Łańcuch alarmowy zostałby uruchomiony (5 błędnych PIN-ów)';

  @override
  String get distressCancelPinBack => 'Anuluj';

  @override
  String get simulationPinPromptTitle => 'Wprowadź PIN';

  @override
  String get simulationPinPromptBody =>
      'Przećwicz wprowadzanie PIN-u zakończenia sesji';

  @override
  String get simulationPinPromptSkip => 'Pomiń';

  @override
  String get simulationPinIncorrect => 'Nieprawidłowy PIN';

  @override
  String simulationSummaryDuration(String duration) {
    return 'Czas trwania: $duration';
  }

  @override
  String get simulationSummaryTimelineHeader => 'Oś czasu zdarzeń';

  @override
  String get simulationSummaryShare => 'Udostępnij';

  @override
  String simulationSummaryMissedEventsBadge(int count) {
    return 'Pominięte: $count';
  }

  @override
  String simulationSummaryDistressBadge(int count) {
    return 'Alarmy: $count';
  }

  @override
  String simulationSummaryStepsFiredBadge(int count) {
    return 'Uruchomione kroki: $count';
  }

  @override
  String get simulationSummaryShareSubject =>
      'Podsumowanie symulacji Guardian Angela';

  @override
  String get notificationsChannelAlarm => 'Eskalacja alarmu';

  @override
  String get notificationsChannelAlarmDescription =>
      'Krytyczne alerty pomijające tryb Nie przeszkadzać';

  @override
  String get notificationsChannelReminder => 'Zamaskowane przypomnienie';

  @override
  String get notificationsChannelReminderDescription =>
      'Przypomnienia o zameldowaniu podczas aktywnej sesji';

  @override
  String get notificationsChannelFakeCall => 'Fałszywe połączenie';

  @override
  String get notificationsChannelFakeCallDescription =>
      'Pełnoekranowe powiadomienia o połączeniu przychodzącym';

  @override
  String get notificationsChannelEnabled => 'Włączone';

  @override
  String get notificationsChannelDisabled => 'Wyłączone';

  @override
  String get notificationsChannelsHeader => 'Kanały powiadomień';

  @override
  String get contactsImportFromDevice => 'Importuj z kontaktów';

  @override
  String get contactsImportNotSupported => 'Niedostępne na tej platformie';

  @override
  String get contactsImportPermissionDenied =>
      'Odmówiono dostępu do kontaktów. Włącz go w ustawieniach systemu.';

  @override
  String get contactsDeleteAllMenu => 'Usuń wszystkie';

  @override
  String get contactsDeleteAllConfirmTitle => 'Usunąć wszystkie kontakty?';

  @override
  String get contactsDeleteAllConfirmBody =>
      'Spowoduje to usunięcie każdego kontaktu alarmowego. Tej operacji nie można cofnąć.';

  @override
  String get contactsDeleteAllTypeConfirmTitle => 'Potwierdź, wpisując';

  @override
  String get contactsDeleteAllTypeConfirmHint =>
      'Wpisz USUŃ WSZYSTKO, aby kontynuować';

  @override
  String get contactsDeleteAllTypeConfirmSentinel => 'USUŃ WSZYSTKO';

  @override
  String get contactsDeleteAllConfirmButton => 'Usuń wszystkie';

  @override
  String get modesBuiltinBadge => 'Wbudowany';

  @override
  String get modesBuiltinNoDelete => 'Wbudowanych trybów nie można usunąć';

  @override
  String get sessionCompletedSimulationBanner => 'Symulacja zakończona';

  @override
  String get sessionCompletedViewEventLog => 'Pokaż dziennik zdarzeń';

  @override
  String get settingsGeneralHeader => 'Ogólne';

  @override
  String get settingsAppHeader => 'Aplikacja';

  @override
  String get settingsConfigurationHeader => 'Konfiguracja';

  @override
  String get settingsThemeLabel => 'Motyw';

  @override
  String get settingsLanguageLabel => 'Język';

  @override
  String get settingsSecurityRow => 'Bezpieczeństwo';

  @override
  String get settingsSecuritySubtitle =>
      'PIN aplikacji, PIN zakończenia sesji, PIN pod przymusem';

  @override
  String get settingsStealthRow => 'Tryb dyskretny';

  @override
  String get settingsStealthSummaryOff => 'Tryb dyskretny: WYŁ.';

  @override
  String get settingsStealthSummaryOn => 'Tryb dyskretny: WŁ.';

  @override
  String get settingsProfileRow => 'Profil';

  @override
  String get settingsModesRow => 'Tryby';

  @override
  String get settingsDistressModesRow => 'Tryby alarmowe';

  @override
  String get settingsEventDefaultsRow => 'Domyślne kroki';

  @override
  String get settingsGpsLoggingRow => 'Rejestrowanie GPS';

  @override
  String get settingsRemindersRow => 'Szablony przypomnień';

  @override
  String get settingsNotificationsRow => 'Powiadomienia';

  @override
  String get settingsHistoryRetentionRow => 'Historia i przechowywanie';

  @override
  String get settingsAboutRow => 'O aplikacji';

  @override
  String get settingsFeedbackRow => 'Wyślij opinię';

  @override
  String get settingsBackupRow => 'Kopia zapasowa i przywracanie';

  @override
  String get settingsOssLicenses => 'Licencje open source';

  @override
  String get settingsImportConfirmBody =>
      'Spowoduje to nadpisanie wszystkich bieżących danych. Kontynuować?';

  @override
  String get securityAppPinTitle => 'PIN aplikacji';

  @override
  String get securityAppPinBody =>
      'Blokuje aplikację przy każdym jej otwarciu.';

  @override
  String get securitySessionEndPinTitle => 'PIN zakończenia sesji';

  @override
  String get securitySessionEndPinBody =>
      'Wymagany do rozbrojenia lub zakończenia trwającej sesji.';

  @override
  String get securityDuressPinTitle => 'PIN pod przymusem';

  @override
  String get securityDuressPinBody =>
      'Wprowadzony przy dowolnym monicie po cichu uruchamia łańcuch alarmowy.';

  @override
  String get securityRemovePin => 'Usuń';

  @override
  String get securityRemovePinPrompt => 'Wprowadź bieżący PIN, aby go usunąć.';

  @override
  String get securityRemovePinIncorrect => 'Nieprawidłowy PIN';

  @override
  String get securityWhatIsThis => 'Co to jest?';

  @override
  String get securityAppPinInfo =>
      'Blokuje aplikację przy jej otwarciu. Klawiatura PIN pojawia się przed każdym ekranem. Przydatne, gdy ktoś na chwilę weźmie twój odblokowany telefon.';

  @override
  String get securitySessionEndPinInfo =>
      'Wymagany do rozbrojenia lub zakończenia trwającej sesji bezpieczeństwa. Bez niego napastnik, który zabierze ci telefon, nie zatrzyma łańcucha. Ustaw inny kod niż PIN aplikacji.';

  @override
  String get securityDuressPinInfo =>
      'Jeśli kiedykolwiek wprowadzisz ten PIN przy dowolnym monicie, łańcuch alarmowy uruchomi się po cichu — twoje kontakty zostaną powiadomione, a alarm zostanie uzbrojony, czego napastnik nie zauważy. Wybierz kod inny niż każdy pozostały PIN.';

  @override
  String get securityPinTimeoutLabel => 'Limit czasu PIN-u (sekundy)';

  @override
  String get securityWrongPinThresholdLabel =>
      'Liczba błędnych PIN-ów przed eskalacją';

  @override
  String get securityDeceptiveDialogToggle =>
      'Pokaż zwodniczy komunikat przy błędnym PIN-ie';

  @override
  String get pinSetupEnterNew => 'Wprowadź nowy PIN';

  @override
  String get pinSetupConfirmNew => 'Potwierdź nowy PIN';

  @override
  String get pinSetupTooShort => 'PIN musi mieć co najmniej 4 cyfry.';

  @override
  String get pinSetupCollision =>
      'Ten PIN koliduje z innym skonfigurowanym PIN-em.';

  @override
  String get pinSetupSaved => 'Zapisano PIN';

  @override
  String get stealthEnabledLabel => 'Włącz tryb dyskretny';

  @override
  String get stealthFakeNameLabel => 'Fałszywa nazwa aplikacji';

  @override
  String get stealthFakeIconLabel => 'Fałszywa ikona';

  @override
  String get stealthNotificationDisguiseLabel => 'Maskowanie powiadomień';

  @override
  String get stealthTimerDisplayLabel => 'Wyświetlanie licznika';

  @override
  String get stealthSessionScreenLabel => 'Dyskretny ekran sesji';

  @override
  String get gpsLoggingEnabled => 'Rejestruj GPS podczas sesji';

  @override
  String get gpsLoggingIntervalLabel => 'Interwał';

  @override
  String get gpsLoggingAccuracyLabel => 'Dokładność';

  @override
  String get gpsLoggingAccuracyHigh => 'Wysoka';

  @override
  String get gpsLoggingAccuracyBalanced => 'Zrównoważona';

  @override
  String get gpsLoggingAccuracyLow => 'Niska';

  @override
  String get gpsLoggingFormatLabel => 'Format współrzędnych';

  @override
  String get gpsLoggingFormatDecimal => 'Dziesiętny';

  @override
  String get gpsLoggingFormatDms => 'DMS';

  @override
  String get gpsLoggingFormatAddress => 'Plus Code';

  @override
  String get gpsLoggingIncludeInSms => 'Dołącz lokalizację do SMS-a';

  @override
  String get historyRetentionLogsLabel =>
      'Przechowywanie dziennika sesji (dni)';

  @override
  String get historyRetentionLogsHelper =>
      'Dzienniki starsze niż to trafiają do kosza.';

  @override
  String get historyRetentionTrashLabel => 'Przechowywanie kosza (dni)';

  @override
  String get historyRetentionTrashHelper =>
      'Dzienniki w koszu są trwale usuwane po upływie tego okresu.';

  @override
  String get historyRetentionUpdated => 'Zaktualizowano okres przechowywania';

  @override
  String get historyRetentionPurgeNow => 'Wyczyść teraz';

  @override
  String historyRetentionPurged(Object count) {
    return 'Wyczyszczono $count dzienników';
  }

  @override
  String get eventDefaultsCheckInHeader => 'Metody zameldowania';

  @override
  String get eventDefaultsEscalationHeader => 'Kroki eskalacji';

  @override
  String get eventDefaultsPanicHeader => 'Wyzwalacz paniki';

  @override
  String get templatesCreate => 'Utwórz szablon';

  @override
  String get templatesEditTitle => 'Edytuj szablon';

  @override
  String get templatesCreateTitle => 'Nowy szablon';

  @override
  String get templatesNameLabel => 'Nazwa';

  @override
  String get templatesTitleLabel => 'Tytuł';

  @override
  String get templatesBodyLabel => 'Treść';

  @override
  String get templatesBuiltinNoDelete =>
      'Wbudowanych szablonów nie można usunąć';

  @override
  String get templatesAddFromTemplate => 'Z szablonu';

  @override
  String get templatesAddFromScratch => 'Od zera';

  @override
  String templatesDeleteConfirmTitle(Object name) {
    return 'Usunąć „$name”?';
  }

  @override
  String get templatesDeleteConfirmBody =>
      'Ten szablon zostanie trwale usunięty.';

  @override
  String get templatesEmptyAddFirst => 'Dodaj swój pierwszy szablon';

  @override
  String get templatesPickFromBuiltinTitle => 'Wybierz wbudowany szablon';

  @override
  String get templatesIconLabel => 'Ikona';

  @override
  String get templatesIconCalendar => 'Kalendarz';

  @override
  String get templatesIconAppNotification => 'Powiadomienie aplikacji';

  @override
  String get templatesIconFitness => 'Fitness';

  @override
  String get templatesIconHealth => 'Zdrowie';

  @override
  String get templatesIconFood => 'Jedzenie';

  @override
  String get templatesIconCoffee => 'Kawa';

  @override
  String get templatesIconBattery => 'Bateria';

  @override
  String get templatesIconWeather => 'Pogoda';

  @override
  String get templatesPreviewHeading => 'Podgląd na żywo';

  @override
  String get templatesDiscardChangesTitle => 'Odrzucić zmiany?';

  @override
  String get templatesDiscardChangesBody =>
      'Niezapisane zmiany zostaną utracone.';

  @override
  String get templatesDiscardKeep => 'Kontynuuj edycję';

  @override
  String get templatesDiscardDiscard => 'Odrzuć';

  @override
  String get notificationsTitle => 'Powiadomienia';

  @override
  String get notificationsStatusGranted => 'Przyznano';

  @override
  String get notificationsStatusDenied => 'Odmówiono';

  @override
  String get notificationsStatusUnknown => 'Jeszcze nie pytano';

  @override
  String get notificationsRequest => 'Poproś o uprawnienie';

  @override
  String get notificationsOpenSettings => 'Otwórz ustawienia systemu';

  @override
  String get profileFieldPhone => 'Numer telefonu';

  @override
  String get profileFieldDescription => 'Rysopis';

  @override
  String get profileFieldMedicalConditions => 'Schorzenia';

  @override
  String get profileFieldEmergencyInstructions => 'Instrukcje na wypadek nagły';

  @override
  String get aboutAuthor => 'Autor: Jonas Eschle';

  @override
  String get aboutEmail => 'guardian.angela.app@gmail.com';

  @override
  String get aboutPrivacyPolicy => 'Polityka prywatności';

  @override
  String get aboutTermsOfService => 'Warunki korzystania z usługi';

  @override
  String get aboutSourceCode => 'Kod źródłowy';

  @override
  String get aboutSupport => 'Wsparcie / wpłać darowiznę';

  @override
  String get aboutLicenses => 'Licencje open source';

  @override
  String get aboutTagline =>
      'Stworzone z miłością dla bezpieczeństwa osób LGBTQ+.';

  @override
  String get aboutTechnicalSection => 'Informacje techniczne';

  @override
  String aboutBundleId(Object id) {
    return 'Identyfikator pakietu: $id';
  }

  @override
  String aboutPlatforms(Object list) {
    return 'Platformy: $list';
  }

  @override
  String get feedbackHeading => 'Chętnie poznamy twoją opinię';

  @override
  String get feedbackCategoryLabel => 'Kategoria';

  @override
  String get feedbackCategoryBug => 'Zgłoszenie błędu';

  @override
  String get feedbackCategoryFeature => 'Propozycja funkcji';

  @override
  String get feedbackCategoryOther => 'Inne';

  @override
  String get feedbackEmailLabel => 'E-mail (opcjonalnie)';

  @override
  String get feedbackMessageLabel => 'Wiadomość';

  @override
  String get feedbackIncludeLog => 'Dołącz dziennik ostatniej sesji';

  @override
  String get feedbackSent => 'Dziękujemy za opinię!';

  @override
  String get feedbackMessageRequired =>
      'Wiadomość musi mieć co najmniej 10 znaków.';

  @override
  String get backupIncludeLogs => 'Dołącz dzienniki sesji';

  @override
  String get backupIncludeMedia => 'Dołącz multimedia';

  @override
  String get backupExportButton => 'Eksportuj';

  @override
  String get backupImportButton => 'Importuj';

  @override
  String get backupOverwriteWarning =>
      'Import nadpisuje wszystkie bieżące dane.';

  @override
  String get backupImportSuccess =>
      'Import zakończony. Uruchom ponownie, aby zastosować.';

  @override
  String backupImportError(Object message) {
    return 'Import nie powiódł się: $message';
  }

  @override
  String get backupActiveSessionBanner =>
      'Kopia zapasowa jest niedostępna podczas aktywnej sesji.';

  @override
  String backupLastBackupAtLabel(Object when) {
    return 'Ostatnia kopia zapasowa: $when';
  }

  @override
  String get backupNeverExportedLabel => 'Brak kopii zapasowej';

  @override
  String get pastEventsTitle => 'Poprzednie sesje';

  @override
  String get pastEventsTabReal => 'Rzeczywiste';

  @override
  String get pastEventsTabSimulated => 'Symulowane';

  @override
  String get pastEventsEmpty => 'Brak sesji';

  @override
  String get pastEventsDeleteConfirm => 'Usunąć dziennik sesji?';

  @override
  String get pastEventsDetailShareText => 'Udostępnij jako tekst';

  @override
  String get pastEventsDetailSharePdf => 'Udostępnij jako PDF';

  @override
  String get pastEventsDetailDelete => 'Usuń';

  @override
  String get pastEventsOutcomeCompleted => 'Zakończona';

  @override
  String get pastEventsOutcomeDistress => 'Alarm';

  @override
  String get pastEventsOutcomeInterrupted => 'Przerwana';

  @override
  String get pastEventsTrash => 'Kosz';

  @override
  String get pastEventsUndo => 'Cofnij';

  @override
  String get pastEventsSoftDeleted => 'Przeniesiono do kosza';

  @override
  String get pastEventsDetailTitle => 'Dziennik sesji';

  @override
  String get pastEventsDetailShare => 'Udostępnij';

  @override
  String get contactUnsavedDiscardTitle => 'Odrzucić niezapisane zmiany?';

  @override
  String get contactUnsavedDiscardKeep => 'Kontynuuj edycję';

  @override
  String get contactUnsavedDiscardDiscard => 'Odrzuć';

  @override
  String get modesDuplicate => 'Duplikuj';

  @override
  String get modesDeleteConfirmTitle => 'Usunąć tryb?';

  @override
  String modesDeleteConfirmBody(Object name) {
    return '$name zostanie trwale usunięty.';
  }

  @override
  String get modesDistressDefaultBadge => 'Domyślny';

  @override
  String get modesDistressSetDefault => 'Ustaw jako domyślny';

  @override
  String get modesDistressCantDeleteLast =>
      'Wymagany jest co najmniej jeden tryb alarmowy.';

  @override
  String get modesDistressInUse =>
      'Ten tryb alarmowy jest używany przez inny tryb.';

  @override
  String get modesDistressTitle => 'Tryby alarmowe';

  @override
  String get validationNameTooShort => 'Imię musi mieć co najmniej 2 znaki.';

  @override
  String get validationPhoneRequired => 'Numer telefonu jest wymagany.';

  @override
  String get validationChannelsRequired => 'Wybierz co najmniej jeden kanał.';

  @override
  String get sessionHoldTouchToBegin => 'Dotknij, aby rozpocząć';

  @override
  String sessionHoldReleaseCountdown(Object seconds) {
    return 'Odliczanie: $seconds s';
  }

  @override
  String sessionHoldGraceCountdown(Object seconds) {
    return 'Okres karencji: $seconds s — przytrzymaj ponownie, by zostać bezpieczną';
  }

  @override
  String get sessionHoldAgain => 'Przytrzymaj ponownie, by zostać bezpieczną';

  @override
  String sessionStepNextCheckIn(Object time) {
    return 'Następne zameldowanie za $time';
  }

  @override
  String sessionStepFakeCallActive(Object caller) {
    return 'Połączenie przychodzące od $caller';
  }

  @override
  String get sessionStepFakeCallOpen => 'Otwórz ekran połączenia';

  @override
  String sessionStepSimBlockedSms(Object count) {
    return '[SIM] SMS zostałby wysłany do $count kontaktów';
  }

  @override
  String get sessionStepSimBlockedPhone =>
      '[SIM] Nastąpiłoby połączenie z kontaktem alarmowym';

  @override
  String get sessionStepSimBlockedEmergency =>
      '[SIM] Nastąpiłoby połączenie ze służbami ratunkowymi';

  @override
  String get sessionStepSimBlockedAlarm =>
      '[SIM] Alarm zabrzmiałby na pełną głośność';

  @override
  String get sessionStartFailedTitle => 'Nie można rozpocząć sesji';

  @override
  String get sessionStartFailedBody =>
      'Rozwiąż poniższe problemy przed rozpoczęciem:';

  @override
  String get sessionQuickExitTitle => 'Szybkie wyjście';

  @override
  String get sessionQuickExitBody =>
      'Dane sesji zostaną zachowane i zaszyfrowane. Otwórz aplikację ponownie w dowolnej chwili, aby je odzyskać.';

  @override
  String get sessionQuickExitConfirm => 'Zamknij aplikację';

  @override
  String get pastEventsRestore => 'Przywróć';

  @override
  String get stepEditorWait => 'Oczekiwanie (s)';

  @override
  String get stepEditorDuration => 'Czas trwania (s)';

  @override
  String get stepEditorGrace => 'Okres karencji (s)';

  @override
  String get stepEditorRetryCount => 'Liczba powtórzeń';

  @override
  String get stepEditorRandomize => 'Losuj czasy (±20%)';

  @override
  String get stepEditorRemove => 'Usuń krok';

  @override
  String get eventDefaultsHoldStyle => 'Styl przytrzymania';

  @override
  String get eventDefaultsHoldSensitivity => 'Czułość zwolnienia';

  @override
  String get eventDefaultsHoldVibrate => 'Wibracja przy zwolnieniu';

  @override
  String get eventDefaultsHoldSound => 'Dźwięk przy zwolnieniu';

  @override
  String get eventDefaultsBlackScreen => 'Nakładka czarnego ekranu';

  @override
  String get eventDefaultsReminderRandomInterval => 'Losuj interwał';

  @override
  String get eventDefaultsReminderRandomTemplate => 'Losuj kolejność szablonów';

  @override
  String get eventDefaultsReminderResetOnEarly =>
      'Resetuj przy wczesnym zameldowaniu';

  @override
  String get eventDefaultsCountdownStyle => 'Styl odliczania';

  @override
  String get eventDefaultsCountdownVibrate => 'Wibracja';

  @override
  String get eventDefaultsCountdownSound => 'Dźwięk';

  @override
  String get eventDefaultsFakeCallStyle => 'Styl połączenia';

  @override
  String get eventDefaultsFakeCallCallerName => 'Nazwa dzwoniącego';

  @override
  String get eventDefaultsFakeCallRingDuration => 'Czas dzwonienia (s)';

  @override
  String get eventDefaultsFakeCallDeclineIsSafe =>
      'Odrzucenie liczy się jako bezpieczeństwo';

  @override
  String get eventDefaultsFakeCallVoiceOutput => 'Odtwarzanie głosu';

  @override
  String get eventDefaultsSmsChannel => 'Kanał';

  @override
  String get eventDefaultsSmsIncludeLocation => 'Dołącz lokalizację';

  @override
  String get eventDefaultsSmsIncludeMedical => 'Dołącz informacje medyczne';

  @override
  String get eventDefaultsSmsAutoRecord => 'Nagraj dźwięk przed wysłaniem';

  @override
  String get eventDefaultsSmsRecordDuration => 'Czas nagrywania (s)';

  @override
  String get eventDefaultsLoudAlarmVolume => 'Głośność';

  @override
  String get eventDefaultsLoudAlarmSound => 'Dźwięk';

  @override
  String get eventDefaultsLoudAlarmFlashScreen => 'Miganie ekranu';

  @override
  String get eventDefaultsLoudAlarmFlashLight => 'Miganie lampą aparatu';

  @override
  String get eventDefaultsLoudAlarmGradual => 'Stopniowe zwiększanie głośności';

  @override
  String get eventDefaultsCallEmergencyNumber => 'Numer alarmowy (zastąpienie)';

  @override
  String get eventDefaultsCallEmergencyConfirm =>
      'Pokaż odliczanie potwierdzające';

  @override
  String get eventDefaultsCallEmergencyConfirmDuration =>
      'Sekundy potwierdzenia';

  @override
  String get eventDefaultsCallEmergencySmsFirst =>
      'Najpierw wyślij SMS z lokalizacją';

  @override
  String get eventDefaultsPhonePrimaryContact => 'Kontakt główny (id)';

  @override
  String get eventDefaultsHardwareButton => 'Przycisk';

  @override
  String get eventDefaultsHardwarePattern => 'Wzorzec naciśnięć';

  @override
  String get eventDefaultsHardwarePressCount => 'Liczba naciśnięć';

  @override
  String get eventDefaultsHardwareLongDuration => 'Czas przytrzymania (s)';

  @override
  String get pastEventsTrashTitle => 'Kosz';

  @override
  String get pastEventsTrashEmpty => 'Kosz jest pusty';

  @override
  String get pastEventsTrashEmptyAll => 'Opróżnij kosz';

  @override
  String get pastEventsTrashEmptyAllConfirmTitle => 'Opróżnić kosz?';

  @override
  String get pastEventsTrashEmptyAllConfirmBody =>
      'Wpisz poniżej EMPTY TRASH, aby potwierdzić. Spowoduje to trwałe usunięcie każdego dziennika z kosza.';

  @override
  String pastEventsTrashEmptyAllSuccess(Object count) {
    return 'Opróżniono kosz ($count dzienników)';
  }

  @override
  String pastEventsTrashRetentionNote(int days) {
    return 'Dzienniki w koszu są trwale usuwane po $days dniach.';
  }

  @override
  String pastEventsTrashRemainingDays(int days) {
    return '$days dni do trwałego usunięcia';
  }

  @override
  String get pastEventsTrashDeletePermanently => 'Usuń trwale';

  @override
  String get pastEventsTrashDeletePermanentlyBody =>
      'Tej operacji nie można cofnąć.';

  @override
  String sessionEmergencyConfirmTitle(String number, int seconds) {
    return 'Dzwonienie pod $number za $seconds s';
  }

  @override
  String get sessionEmergencyConfirmSwipe => 'Przesuń, aby anulować';

  @override
  String get sessionEmergencyConfirmKeep => 'Kontynuuj dzwonienie';

  @override
  String get sessionEmergencyConfirmSimBadge => '[SIM] Tryb ćwiczeniowy';

  @override
  String get sessionEmergencyConfirmSimCancelled =>
      'Symulowane anulowanie — połączenie nie zostałoby wykonane';

  @override
  String get swipeSliderSemantics => 'Przesuń, aby potwierdzić';

  @override
  String get homeWidgetStatusIdle => 'Gotowy';

  @override
  String get homeWidgetStatusSession => 'Sesja aktywna';

  @override
  String get homeWidgetStatusSim => 'Symulacja aktywna';

  @override
  String get homeWidgetQuickExit => 'Szybkie wyjście';

  @override
  String get homeWidgetFakeCall => 'Fałszywe połączenie';
}
