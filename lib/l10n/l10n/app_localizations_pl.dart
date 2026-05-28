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
  String get homePermissionsMissingTitle => 'Brakuje niektórych uprawnień';

  @override
  String get homePermissionsMissingBody =>
      'Następujące uprawnienia nie zostały przyznane. Bez nich odpowiednie kroki łańcucha zakończą się niepowodzeniem po cichu:';

  @override
  String get homePermissionsContinueAnyway => 'Rozpocznij mimo to';

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
  String get contactFormIosSmsWarning =>
      'On iOS, SMS opens the Messages app. You must tap Send manually.';

  @override
  String get modesTitle => 'Tryby';

  @override
  String get modesEmpty => 'Brak trybów. Dotknij Dodaj, aby utworzyć tryb.';

  @override
  String get modesAdd => 'Dodaj tryb';

  @override
  String get modesNewPickerTitle => 'Zacznij od';

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
  String modesNewPickerCopyName(String name) {
    return 'Kopia $name';
  }

  @override
  String get modesNewPickerBuiltinBadge => 'Wbudowany';

  @override
  String get modeEditorTitleCreate => 'Nowy tryb';

  @override
  String get modeEditorTitleEdit => 'Edytuj tryb';

  @override
  String get modeFieldName => 'Nazwa';

  @override
  String get modeFieldDistressMode => 'Tryb alarmowy';

  @override
  String get modeFieldDistressModeDefault => 'Użyj domyślnego';

  @override
  String get modeChainHeader => 'Łańcuch';

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
  String get stepPickerMore => 'Więcej opcji...';

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
  String get stepFieldRetryCount => 'Liczba powtórzeń';

  @override
  String get stepFieldRandomize => 'Losowa zmienność czasu';

  @override
  String get stepFieldRandomizeToggle => 'Losowy czas (±20%)';

  @override
  String get stepFieldWaitTooltip =>
      'Jak długo czekać przed rozpoczęciem tego kroku.';

  @override
  String get stepFieldDurationTooltip =>
      'Jak długo krok jest aktywny przed rozpoczęciem okresu karencji.';

  @override
  String get stepFieldGraceTooltip =>
      'Czas po fazie aktywnej na potwierdzenie bezpieczeństwa przed kolejnym krokiem.';

  @override
  String get stepFieldRetryCountTooltip =>
      'Ile razy powtórzyć ten krok przed eskalacją.';

  @override
  String get stepFieldReminderIntervalTooltip =>
      'Jak często wyzwala się ukryte przypomnienie podczas oczekiwania na potwierdzenie.';

  @override
  String get stepFieldReminderGraceTooltip =>
      'Ile czasu ma użytkownik na potwierdzenie bezpieczeństwa po pojawieniu się przypomnienia.';

  @override
  String get stepPreview => 'Podgląd w symulacji';

  @override
  String stepPreviewFired(Object description) {
    return 'Podgląd uruchomiony: $description';
  }

  @override
  String get stepPreviewTitle => 'Podgląd kroku';

  @override
  String get stepPreviewMissingParams => 'Brak odwołania do kroku lub trybu.';

  @override
  String get stepPreviewModeNotFound => 'Nie znaleziono trybu.';

  @override
  String get stepPreviewStepNotFound => 'Nie znaleziono kroku w tym trybie.';

  @override
  String stepPreviewError(Object error) {
    return 'Podgląd nie powiódł się: $error';
  }

  @override
  String get stepPreviewReplay => 'Powtórz';

  @override
  String get stepPreviewHoldButtonHint =>
      'Przytrzymaj przycisk, aby poczuć rzeczywistą reakcję.';

  @override
  String get stepPreviewHoldButtonLabel => 'Przytrzymaj';

  @override
  String get stepPreviewHoldButtonSemantic =>
      'Przytrzymaj, aby zobaczyć podgląd';

  @override
  String get stepPreviewHoldButtonReleased =>
      'Zwolniono. Sesja przejdzie teraz do okna karencji.';

  @override
  String get stepPreviewFakeCallHint =>
      'Pojawi się ekran fałszywego połączenia. Przesuń, aby odebrać, lub przytrzymaj czerwony przycisk, aby zasymulować alarm.';

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
  String get stepConfigSmsAutoRecordAudio => 'Automatycznie nagrywaj audio';

  @override
  String get stepConfigSmsAutoRecordVideo => 'Automatycznie nagrywaj wideo';

  @override
  String get stepConfigSmsRecordDuration => 'Czas nagrywania';

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
  String get stepConfigHardwarePressWindow => 'Okno między naciśnięciami (ms)';

  @override
  String get stepConfigHardwareLongDuration => 'Czas długiego naciśnięcia (s)';

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
  String get settingsLanguagePicker => 'Język';

  @override
  String get settingsEmergencyNumberLabel => 'Numer alarmowy';

  @override
  String get settingsEmergencyNumberHint => 'np. 112';

  @override
  String get settingsEmergencyNumberSave => 'Zapisz';

  @override
  String get settingsRedoOnboarding => 'Powtórz wprowadzenie';

  @override
  String get settingsRedoOnboardingConfirm => 'Zrestartować wprowadzenie?';

  @override
  String get settingsRedoOnboardingBody =>
      'Twoja obecna konfiguracja zostanie zachowana.';

  @override
  String get settingsRedoOnboardingProceed => 'Restartuj';

  @override
  String get settingsAlarmGradualVolume => 'Stopniowe narastanie alarmu';

  @override
  String settingsAlarmGradualVolumeDuration(int seconds) {
    return 'Czas narastania: $seconds s';
  }

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
  String aboutVersion(Object version) {
    return 'Wersja';
  }

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

  @override
  String get audioRunningLatePhrase => 'Cześć, spóźnię się. Wkrótce oddzwonię.';

  @override
  String smsDefaultTemplate(Object name, Object location, Object time) {
    return '$name może potrzebować pomocy. Lokalizacja: $location. Czas: $time.';
  }

  @override
  String smsDefaultPreCallTemplate(Object name) {
    return '$name próbuje się z tobą skontaktować. Spodziewaj się telefonu.';
  }

  @override
  String simLoudAlarm(Object tail) {
    return '[SIM] Głośny alarm + $tail';
  }

  @override
  String get simLoudAlarmTailFlash => 'błysk';

  @override
  String get simLoudAlarmTailVibrate => 'wibracja';

  @override
  String simSmsContact(Object channel, int count) {
    return '[SIM] Wysłałby $channel do $count kontaktów';
  }

  @override
  String simFakeCallRing(Object caller) {
    return '[SIM] Połączenie przychodzące od $caller';
  }

  @override
  String simCountdownWarning(int seconds) {
    return '[SIM] Ostrzeżenie odliczania ${seconds}s';
  }

  @override
  String simPhoneCall(Object name) {
    return '[SIM] Zadzwoniłby do $name';
  }

  @override
  String get simNoContactToCall => '[SIM] Brak kontaktu do połączenia';

  @override
  String simCallEmergency(Object number) {
    return '[SIM] Wybrałby $number';
  }

  @override
  String get simHardwareButton => '[SIM] Wyzwalacz sprzętowy uzbrojony';

  @override
  String get simHoldButton => '[SIM] Oczekiwanie na przytrzymanie przycisku';

  @override
  String simDisguisedReminder(Object title) {
    return '[SIM] Pokazałby \"$title\"';
  }

  @override
  String get simDisguisedReminderEmpty =>
      '[SIM] Brak dostępnego szablonu przypomnienia';

  @override
  String get simGpsArrivalTrigger =>
      '[SIM] Wyzwalacz przybycia GPS uruchomiony';

  @override
  String get simLowBatteryAlert =>
      '[SIM] Alarm niskiego poziomu baterii uruchomiony';

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
  String get gpsLoggingFormatAddress => 'Address';

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
  String get pastEventsDetailDelete => 'Delete';

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
}
