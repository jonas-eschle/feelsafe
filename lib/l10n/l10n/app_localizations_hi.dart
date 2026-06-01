// ignore: unused_import

import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'Guardian Angela';

  @override
  String get commonSave => 'सहेजें';

  @override
  String get angelaDialogTitle => 'पुराना PIN दर्ज किया गया';

  @override
  String get angelaDialogBody =>
      'लगता है आपने पुराना PIN इस्तेमाल किया है। क्या आप वाकई आगे बढ़ना चाहते हैं?';

  @override
  String get angelaDialogCancel => 'रद्द करें';

  @override
  String get angelaDialogConfirm => 'जारी रखें';

  @override
  String get commonCancel => 'रद्द करें';

  @override
  String get commonOk => 'ठीक है';

  @override
  String get commonDelete => 'हटाएँ';

  @override
  String get commonEdit => 'संपादित करें';

  @override
  String get commonClose => 'बंद करें';

  @override
  String get commonConfirm => 'पुष्टि करें';

  @override
  String get commonBack => 'वापस';

  @override
  String get pinSubmit => 'जमा करें';

  @override
  String get homeTitle => 'Guardian Angela';

  @override
  String get homeStartSession => 'सत्र आरंभ करें';

  @override
  String get homePermissionsNotification => 'सूचनाएँ';

  @override
  String get homePermissionsLocation => 'स्थान';

  @override
  String get homePermissionsCallPhone => 'फ़ोन कॉल';

  @override
  String get homePermissionsSendSms => 'SMS भेजें';

  @override
  String get homeSimulate => 'सिमुलेट करें';

  @override
  String get homeNoModes =>
      'अभी तक कोई मोड नहीं। एक जोड़ने के लिए Modes पर टैप करें।';

  @override
  String get homeContactsBannerNone =>
      'कोई आपातकालीन संपर्क कॉन्फ़िगर नहीं है।';

  @override
  String get homeMenuSettings => 'सेटिंग्स';

  @override
  String get homeMenuContacts => 'संपर्क';

  @override
  String get homeMenuHistory => 'पिछले सत्र';

  @override
  String get onboardingProfileTitle => 'प्रोफ़ाइल और पहला संपर्क';

  @override
  String get onboardingPermissionsTitle => 'अनुमतियाँ';

  @override
  String get onboardingNext => 'आगे';

  @override
  String get onboardingSkip => 'छोड़ें';

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
  String get sessionTitle => 'सत्र';

  @override
  String get sessionDisarm => 'मैं सुरक्षित हूँ';

  @override
  String get sessionDisarmStealth => 'एंजेला की ज़रूरत नहीं';

  @override
  String get homeChainSummaryTitle => 'चेन सारांश';

  @override
  String get homeChainSummaryEmpty =>
      'इस मोड में अभी कोई चरण नहीं है — संपादित करने के लिए मोड पर टैप करें।';

  @override
  String homeChainSummaryTimingTitle(Object name) {
    return 'चरण: $name';
  }

  @override
  String homeChainSummaryWait(Object seconds) {
    return 'प्रतीक्षा: $seconds सेकंड';
  }

  @override
  String homeChainSummaryDuration(Object seconds) {
    return 'सक्रिय: $seconds सेकंड';
  }

  @override
  String homeChainSummaryGrace(Object seconds) {
    return 'छूट अवधि: $seconds सेकंड';
  }

  @override
  String homeChainSummaryRetry(Object count) {
    return 'पुनःप्रयास: $count';
  }

  @override
  String homeChainSummaryNextStep(Object name) {
    return 'अगला चरण: $name';
  }

  @override
  String get homeChainSummaryNextStepNone => 'अगला चरण: चेन समाप्त';

  @override
  String get homeChainSummaryClose => 'बंद करें';

  @override
  String get chainStepNameHoldButton => 'सुरक्षित रहने के लिए दबाए रखें';

  @override
  String get chainStepNameDisguisedReminder => 'छिपा हुआ रिमाइंडर';

  @override
  String get chainStepNameCountdownWarning => 'उलटी गिनती चेतावनी';

  @override
  String get chainStepNameFakeCall => 'नकली कॉल';

  @override
  String get chainStepNameSmsContact => 'संपर्क को SMS';

  @override
  String get chainStepNamePhoneCallContact => 'संपर्क को फोन';

  @override
  String get chainStepNameLoudAlarm => 'तेज़ अलार्म';

  @override
  String get chainStepNameCallEmergency => 'आपातकालीन कॉल';

  @override
  String get chainStepNameHardwareButton => 'हार्डवेयर बटन';

  @override
  String get homeChecklistTitle => 'सुरक्षा सेटअप';

  @override
  String get homeChecklistDismissTooltip => 'सूची हटाएँ';

  @override
  String get homeChecklistExpandTooltip => 'सूची दिखाएँ';

  @override
  String get homeChecklistCollapseTooltip => 'सूची छिपाएँ';

  @override
  String homeChecklistProgress(Object done, Object total) {
    return '$total में से $done पूरे';
  }

  @override
  String get homeChecklistAllDoneBanner => 'सब तैयार — आप सुरक्षित हैं!';

  @override
  String get homeChecklistInfoTooltip => 'क्यों ज़रूरी है';

  @override
  String get homeChecklistGotIt => 'समझ गई';

  @override
  String get homeChecklistGoThere => 'वहाँ जाएँ';

  @override
  String get homeChecklistItem1Title => 'आपातकालीन संपर्क जोड़ें';

  @override
  String get homeChecklistItem2Title => 'सत्र-समाप्ति PIN सेट करें';

  @override
  String get homeChecklistItem3Title => 'स्टेल्थ मोड कॉन्फ़िगर करें';

  @override
  String get homeChecklistItem4Title => 'एक सिमुलेशन आज़माएँ';

  @override
  String get homeChecklistItem5Title => 'एक सुरक्षा मोड अनुकूलित करें';

  @override
  String get homeChecklistItem6Title => 'ज़रूरी अनुमतियाँ दें';

  @override
  String get checklistInfo1Body =>
      'आपातकालीन संपर्क वे लोग हैं जिन्हें Guardian Angela तब संदेश भेजती और कॉल करती है जब आप समय पर चेक-इन नहीं कर पातीं। बिना कम से कम एक संपर्क के, चेन को आगे बढ़ाने की कोई जगह नहीं रहती।';

  @override
  String get checklistInfo2Body =>
      'सत्र-समाप्ति PIN किसी हमलावर को चुपचाप सक्रिय सत्र बंद करने से रोकती है। वह कोशिश कर सकता है, पर पाँच ग़लत प्रयास चुपचाप आपकी डिस्ट्रेस चेन चालू कर देंगे।';

  @override
  String get checklistInfo3Body =>
      'स्टेल्थ मोड सक्रिय सत्र को स्क्रीन पर किसी सामान्य चीज़ की तरह छिपाता है — म्यूज़िक प्लेयर, रुका हुआ टाइमर, खाली लॉक स्क्रीन। उपयोग तब करें जब पास का कोई व्यक्ति आपको सुरक्षा ऐप चलाते हुए न देख सके।';

  @override
  String get checklistInfo4Body =>
      'सिमुलेशन आपके सुरक्षा मोड को पूरा चलाता है, पर असली SMS नहीं भेजता, असली कॉल नहीं लगाता और तेज़ अलार्म नहीं बजाता। ज़रूरत पड़ने से पहले समय-क्रम सीखने के लिए इसका उपयोग करें।';

  @override
  String get checklistInfo5Body =>
      'कस्टम मोड आपको किसी ख़ास स्थिति के अनुसार चरण, समय और ट्रिगर ट्यून करने देते हैं — घर लौटना, पहली डेट, देर की शिफ़्ट। दो बिल्ट-इन मोड शुरुआती बिंदु हैं, मंज़िल नहीं।';

  @override
  String get checklistInfo6Body =>
      'नोटिफ़िकेशन अनुमति के बिना Guardian Angela अपनी स्थायी फ़ोरग्राउंड स्थिति नहीं रख सकती, छिपे रिमाइंडर नहीं भेज सकती, और चेन के बढ़ने से पहले आपको सूचित नहीं कर सकती।';

  @override
  String get checklistTutorial3Body =>
      'स्टेल्थ डिफ़ॉल्ट खोलें और ‘स्टेल्थ मोड सक्षम करें’ चालू करें। वहाँ से आप नकली म्यूज़िक ब्रांड चुन सकती हैं, सत्र टाइमर छिपा सकती हैं या होम-स्क्रीन आइकन छिपा सकती हैं।';

  @override
  String get checklistTutorial4Body =>
      'मोड चुनने के बाद होम स्क्रीन पर आउटलाइन वाले ‘सिमुलेट’ बटन पर टैप करें। सत्र नारंगी बॉर्डर और [SIM] बैज के साथ चलता है — कुछ भी आपके फ़ोन से बाहर नहीं जाता।';

  @override
  String get checklistTutorial5Body =>
      'मोड स्क्रीन खोलें और या तो किसी बिल्ट-इन मोड (वॉक/डेट) को संपादित करें या नया मोड बनाएँ। चेन में बदलाव करें, नकली कॉल जोड़ें, अपने समय निर्धारित करें।';

  @override
  String get sessionHoldPrompt => 'सुरक्षित रहने के लिए दबाए रखें';

  @override
  String sessionStepLabel(Object index, Object total) {
    return 'चरण $index / $total';
  }

  @override
  String sessionMissCount(Object count) {
    return 'छूटे: $count';
  }

  @override
  String get sessionPausedBadge => 'रुका हुआ';

  @override
  String get sessionPhaseEnded => 'सत्र समाप्त';

  @override
  String get sessionSimulationBanner => 'सिमुलेशन';

  @override
  String get sessionCheckIn => 'मैं चेक-इन हूँ';

  @override
  String get sessionStepCountdownTitle => 'चेतावनी';

  @override
  String get sessionStepCountdownBody =>
      'उल्टी गिनती समाप्त होने पर अगला एस्कलेशन सक्रिय होगा। निरस्त्र करने के लिए नीचे \'मैं सुरक्षित हूँ\' स्वाइप करें।';

  @override
  String get sessionStepDisguisedDefaultTitle => 'रिमाइंडर';

  @override
  String get sessionStepDisguisedDefaultBody =>
      'सुरक्षित होने की पुष्टि के लिए \'मैं चेक-इन हूँ\' टैप करें।';

  @override
  String get sessionStepSmsStatus => 'संपर्कों को संदेश भेजा जा रहा है…';

  @override
  String get sessionStepPhoneCallStatus =>
      'आपातकालीन संपर्क को कॉल किया जा रहा है…';

  @override
  String get sessionStepLoudAlarmTitle => 'अलार्म बज रहा है';

  @override
  String get sessionStepLoudAlarmBody =>
      'ध्यान आकर्षित करने के लिए अलार्म बज रहा है।';

  @override
  String get sessionStepLoudAlarmFlashWarning =>
      'प्रकाश-संवेदी चेतावनी: स्क्रीन चमक रही है।';

  @override
  String get sessionStepCallEmergencyStatus =>
      'आपातकालीन सेवाओं को कॉल किया जा रहा है…';

  @override
  String sessionStepCallEmergencyNumber(Object number) {
    return 'नंबर: $number';
  }

  @override
  String sessionStepHardwareButtonRepeat(
    Object button,
    Object count,
    Object windowMs,
  ) {
    return '$button को $windowMsमि.से. में $count बार दबाएं';
  }

  @override
  String sessionStepHardwareButtonLong(Object button, Object seconds) {
    return '$button को $seconds सेकंड तक दबाए रखें';
  }

  @override
  String get sessionStepHardwareButtonVolumeUp => 'वॉल्यूम बढ़ाएं';

  @override
  String get sessionStepHardwareButtonVolumeDown => 'वॉल्यूम घटाएं';

  @override
  String get sessionStepHardwareButtonPower => 'पावर';

  @override
  String get sessionCompletedTitle => 'सत्र पूर्ण';

  @override
  String get sessionCompletedBody =>
      'आप सुरक्षित पहुँच गए। Guardian Angela अब विश्राम में है।';

  @override
  String get sessionCompletedReturnHome => 'होम पर लौटें';

  @override
  String get simulationSummaryTitle => 'सिमुलेशन सारांश';

  @override
  String get simulationSummaryEmpty => 'इस सिमुलेशन में कोई चरण नहीं चला।';

  @override
  String get simulationSummaryReturn => 'होम पर वापस';

  @override
  String get fakeCallTitle => 'आने वाली कॉल';

  @override
  String get fakeCallHangUp => 'कॉल काटें';

  @override
  String get fakeCallSlideToAnswer => 'उत्तर देने के लिए स्लाइड करें';

  @override
  String get fakeCallUnknownCaller => 'अज्ञात';

  @override
  String get fakeCallIncomingWhatsapp => 'WhatsApp वॉइस कॉल';

  @override
  String get fakeCallIncomingTelegram => 'Telegram वॉइस कॉल';

  @override
  String get fakeCallIncomingSignal => 'Signal वॉइस कॉल';

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
  String get contactsTitle => 'आपातकालीन संपर्क';

  @override
  String get contactsEmpty =>
      'अभी तक कोई संपर्क नहीं। अपने संकट संदेश पाने के लिए एक जोड़ें।';

  @override
  String get contactsAdd => 'संपर्क जोड़ें';

  @override
  String get contactFormTitleCreate => 'नया संपर्क';

  @override
  String get contactFormTitleEdit => 'संपर्क संपादित करें';

  @override
  String get contactFieldName => 'नाम';

  @override
  String get contactFieldPhone => 'फ़ोन नंबर';

  @override
  String get contactFieldRelationship => 'संबंध (वैकल्पिक)';

  @override
  String get contactFieldLanguage => 'SMS भाषा (वैकल्पिक)';

  @override
  String get contactLanguageDefault => 'डिफ़ॉल्ट (ऐप भाषा का उपयोग करें)';

  @override
  String get contactChannelsHeader => 'संदेश चैनल';

  @override
  String get contactChannelSms => 'SMS';

  @override
  String get contactChannelWhatsapp => 'WhatsApp';

  @override
  String get contactChannelTelegram => 'Telegram';

  @override
  String get contactChannelPhone => 'फ़ोन कॉल';

  @override
  String get contactDeleteConfirm => 'संपर्क हटाएँ?';

  @override
  String contactDeleteBody(Object name) {
    return '$name को आपकी आपातकालीन सूची से हटा दिया जाएगा।';
  }

  @override
  String get contactFormIosSmsWarning =>
      'On iOS, SMS opens the Messages app. You must tap Send manually.';

  @override
  String get modesTitle => 'मोड';

  @override
  String get modesEmpty =>
      'अभी तक कोई मोड नहीं। मोड बनाने के लिए Add पर टैप करें।';

  @override
  String get modesAdd => 'मोड जोड़ें';

  @override
  String get modesNewPickerBlank => 'खाली मोड';

  @override
  String get modesNewPickerBlankSubtitle => 'खाली श्रृंखला से शुरू करें';

  @override
  String modesNewPickerFromTemplate(String name) {
    return '$name से';
  }

  @override
  String get modesNewPickerFromTemplateSubtitle =>
      'इस मोड की श्रृंखला और ट्रिगर की प्रतिलिपि बनाएँ';

  @override
  String get modeEditorTitleCreate => 'नया मोड';

  @override
  String get modeEditorTitleEdit => 'मोड संपादित करें';

  @override
  String get modeFieldName => 'नाम';

  @override
  String get modeChainHeader => 'श्रृंखला';

  @override
  String get modeChainAddStep => 'चरण जोड़ें';

  @override
  String get modeUnsavedTitle => 'बदलाव छोड़ें?';

  @override
  String get modeUnsavedBody =>
      'आपके पास सहेजे न गए बदलाव हैं। उन्हें छोड़ें और एडिटर से बाहर निकलें?';

  @override
  String get modeUnsavedDiscard => 'छोड़ें';

  @override
  String get modeUnsavedKeep => 'संपादन जारी रखें';

  @override
  String stepTimingSummary(Object wait, Object duration, Object grace) {
    return 'प्रतीक्षा $waitसे / अवधि $durationसे / छूट $graceसे';
  }

  @override
  String get distressModesEmpty => 'अभी तक कोई संकट मोड नहीं।';

  @override
  String get distressModeEditorTitleCreate => 'नया संकट मोड';

  @override
  String get distressModeEditorTitleEdit => 'संकट मोड संपादित करें';

  @override
  String get templatesTitle => 'अनुस्मारक टेम्पलेट';

  @override
  String get templatesEmpty => 'अभी तक कोई टेम्पलेट नहीं।';

  @override
  String get profileTitle => 'प्रोफ़ाइल';

  @override
  String get profileFieldName => 'नाम';

  @override
  String get profileFieldAge => 'आयु';

  @override
  String get profileFieldBloodType => 'रक्त समूह';

  @override
  String get profileFieldAllergies => 'एलर्जी';

  @override
  String get profileFieldMedications => 'दवाइयाँ';

  @override
  String get settingsThemeLight => 'हल्का';

  @override
  String get settingsThemeDark => 'गहरा';

  @override
  String get settingsThemeSystem => 'सिस्टम';

  @override
  String get settingsEmergencyNumberLabel => 'आपातकालीन नंबर';

  @override
  String get settingsRedoOnboardingActiveSessionTooltip =>
      'Cannot redo onboarding during an active session';

  @override
  String get settingsEmergencyNumberCountryPickerTitle =>
      'Choose emergency number';

  @override
  String get settingsRedoOnboarding => 'परिचय दोबारा करें';

  @override
  String get settingsRedoOnboardingConfirm => 'परिचय पुनः प्रारंभ करें?';

  @override
  String get securitySessionEndPinBiometric =>
      'सत्र-समाप्ति PIN के लिए बायोमेट्रिक्स का उपयोग करें';

  @override
  String get securityAppPinBiometric => 'Use biometrics for App lock';

  @override
  String get launchPinTitle => 'Enter your App PIN';

  @override
  String get launchPinBiometricReason => 'Unlock Guardian Angela';

  @override
  String get launchPinIncorrect => 'Incorrect PIN';

  @override
  String get securitySetPin => 'PIN सेट करें';

  @override
  String get securityChangePin => 'PIN बदलें';

  @override
  String get pinSetupMismatch => 'PIN मेल नहीं खाते। फिर से कोशिश करें।';

  @override
  String get stealthTimerDisplayNormal => 'पूरा टेक्स्ट दिखाएँ';

  @override
  String get stealthTimerDisplaySmall => 'केवल संख्याएँ दिखाएँ';

  @override
  String get stealthTimerDisplayNone => 'टाइमर छिपाएँ';

  @override
  String get stealthPresetMusic => 'संगीत';

  @override
  String get stealthPresetCalendar => 'कैलेंडर';

  @override
  String get stealthPresetFitness => 'फिटनेस';

  @override
  String get stealthPresetWeather => 'मौसम';

  @override
  String get stealthPresetNews => 'समाचार';

  @override
  String get stealthPresetPhotos => 'फ़ोटो';

  @override
  String get stealthPresetNotes => 'नोट्स';

  @override
  String get stealthPresetClock => 'घड़ी';

  @override
  String get batteryAlertTitle => 'बैटरी चेतावनी';

  @override
  String get eventDefaultsTitle => 'चरण डिफ़ॉल्ट';

  @override
  String get historyRetentionTitle => 'इतिहास रखरखाव';

  @override
  String get backupTitle => 'बैकअप';

  @override
  String get aboutTitle => 'के बारे में';

  @override
  String aboutVersion(Object version) {
    return 'संस्करण';
  }

  @override
  String get feedbackTitle => 'प्रतिक्रिया';

  @override
  String get feedbackSend => 'ईमेल खोलें';

  @override
  String get stealthPresetPodcast => 'पॉडकास्ट';

  @override
  String get stealthPresetNone => 'कोई नहीं';

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
  String get securityRemovePinPrompt => 'Enter your current PIN to remove it.';

  @override
  String get securityRemovePinIncorrect => 'Incorrect PIN';

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
