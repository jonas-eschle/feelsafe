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
  String get onboardingUseSimNumber => 'मेरा SIM नंबर उपयोग करें';

  @override
  String onboardingUseSimNumberHint(Object number) {
    return '$number';
  }

  @override
  String get onboardingUseSimNumberUnsupported => 'iOS पर उपलब्ध नहीं';

  @override
  String get onboardingUseSimNumberUnavailable => 'नंबर नहीं पढ़ा जा सका';

  @override
  String get onboardingUseSimNumberPermissionDenied => 'अनुमति अस्वीकृत';

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
  String get fakeCallBrandAndroid => 'फ़ोन';

  @override
  String get fakeCallBrandIos => 'फ़ोन';

  @override
  String get fakeCallBrandMinimal => 'कॉल';

  @override
  String get fakeCallDeclineSafeLabel => 'अस्वीकार करें (मैं सुरक्षित हूँ)';

  @override
  String get fakeCallDeclineUnsafeLabel => 'अस्वीकार करें (सतर्क रहें)';

  @override
  String get fakeCallHoldForDistress => 'डिस्ट्रेस के लिए 5 सेकंड दबाए रखें';

  @override
  String fakeCallVoicePrompt(String name) {
    return 'TTS प्रॉम्प्ट: $name';
  }

  @override
  String fakeCallVibrationLabel(String pattern) {
    return 'कंपन: $pattern';
  }

  @override
  String get fakeCallVibrationPatternDefault => 'डिफ़ॉल्ट';

  @override
  String get fakeCallSlideToAnswerHint => 'उत्तर देने के लिए स्लाइड करें';

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
      'iOS पर, SMS Messages ऐप में खुलता है। आपको स्वयं Send टैप करना होगा।';

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
      'सक्रिय सत्र के दौरान परिचय दोबारा नहीं किया जा सकता';

  @override
  String get settingsEmergencyNumberCountryPickerTitle =>
      'आपातकालीन नंबर चुनें';

  @override
  String get settingsRedoOnboarding => 'परिचय दोबारा करें';

  @override
  String get settingsRedoOnboardingConfirm => 'परिचय पुनः प्रारंभ करें?';

  @override
  String get securitySessionEndPinBiometric =>
      'सत्र-समाप्ति PIN के लिए बायोमेट्रिक्स का उपयोग करें';

  @override
  String get securityAppPinBiometric =>
      'ऐप लॉक के लिए बायोमेट्रिक्स का उपयोग करें';

  @override
  String get launchPinTitle => 'अपना ऐप PIN दर्ज करें';

  @override
  String get launchPinBiometricReason => 'Guardian Angela अनलॉक करें';

  @override
  String get launchPinIncorrect => 'गलत PIN';

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
  String get stealthLockTaskLabel => 'सत्र के दौरान ऐप पिन करें';

  @override
  String get stealthLockTaskSubtitle =>
      'सत्र चलते समय ऐप से बाहर निकलने से रोकता है। Android पर यह स्क्रीन-पिनिंग सक्रिय करता है; अन्य प्लेटफ़ॉर्म पर इसका कोई प्रभाव नहीं है।';

  @override
  String get homeTagline => 'आपकी एंजेल आपके साथ है।';

  @override
  String get onboardingWelcomeGreeting => 'नमस्ते, मैं एंजेला हूँ';

  @override
  String get onboardingWelcomeBodyFull =>
      'मैं आपकी निजी संरक्षक हूँ। मैं आपके साथ चलती हूँ, आपकी शाम की सैर पर नज़र रखती हूँ, और अगर कुछ गड़बड़ लगे तो कार्रवाई करती हूँ।';

  @override
  String get onboardingGetStarted => 'शुरू करें';

  @override
  String get onboardingProfileNameLabel => 'नाम';

  @override
  String get onboardingProfilePhoneLabel => 'फ़ोन नंबर';

  @override
  String get onboardingProfilePhoneHelper =>
      'आपातकालीन संदेशों में शामिल किया जाता है।';

  @override
  String get onboardingEmergencyContactHeader => 'आपातकालीन संपर्क';

  @override
  String get onboardingEmergencyContactPrompt =>
      'अगर कुछ गड़बड़ हो तो हमें किससे संपर्क करना चाहिए?';

  @override
  String get onboardingEmergencyContactAdd => 'आपातकालीन संपर्क जोड़ें';

  @override
  String get onboardingPermissionsIntro =>
      'ये अनुमतियाँ सत्रों के दौरान आपको सुरक्षित रखती हैं।';

  @override
  String get onboardingPermissionsGrantAll => 'सभी दें';

  @override
  String get onboardingPermissionsRequired => 'आवश्यक';

  @override
  String get onboardingPermissionsOptional => 'वैकल्पिक';

  @override
  String get onboardingPermissionsMicrophone => 'माइक्रोफ़ोन';

  @override
  String get onboardingPermissionsCamera => 'कैमरा';

  @override
  String get onboardingPermissionsNotificationDesc =>
      'सत्र अलर्ट और रिमाइंडर के लिए आवश्यक।';

  @override
  String get onboardingPermissionsSmsDesc =>
      'आपातकालीन टेक्स्ट अलर्ट भेजने के लिए आवश्यक।';

  @override
  String get onboardingPermissionsPhoneDesc =>
      'आपातकालीन और नकली कॉल करने के लिए आवश्यक।';

  @override
  String get onboardingPermissionsLocationDesc =>
      'GPS लॉगिंग चालू होने पर आपातकालीन संदेशों में शामिल किया जाता है।';

  @override
  String get onboardingPermissionsMicrophoneDesc =>
      'डिस्ट्रेस के दौरान ऑडियो रिकॉर्डिंग के लिए उपयोग किया जाता है।';

  @override
  String get onboardingPermissionsCameraDesc =>
      'फ़्लैश SOS संकेत के लिए उपयोग किया जाता है।';

  @override
  String get sessionInterruptedTitle => 'सत्र बाधित हुआ';

  @override
  String get sessionInterruptedBody =>
      'जब ऐप रुका तब एक सत्र चल रहा था। सत्र की स्थिति समाप्त हो गई — कुछ भी पुनर्स्थापित नहीं हुआ। हम यह इसलिए दिखा रहे हैं ताकि आपको पता रहे।';

  @override
  String get sessionInterruptedAcknowledge => 'स्वीकार करें';

  @override
  String sessionInterruptedMode(Object name) {
    return 'मोड: $name';
  }

  @override
  String sessionInterruptedStarted(Object time) {
    return 'आरंभ: $time';
  }

  @override
  String get sessionGpsDestinationTitle => 'गंतव्य';

  @override
  String get sessionGpsDestinationBody =>
      'GPS आगमन निरस्त्रीकरण ट्रिगर के लिए गंतव्य निर्देशांक दर्ज करें।';

  @override
  String get sessionGpsDestinationLat => 'अक्षांश';

  @override
  String get sessionGpsDestinationLng => 'देशांतर';

  @override
  String get sessionGpsDestinationSkip => 'इस सत्र के लिए छोड़ें';

  @override
  String get sessionGpsDestinationConfirm => 'गंतव्य उपयोग करें';

  @override
  String get sessionEndOverlayTitle => 'सत्र समाप्त करें?';

  @override
  String get sessionEndOverlayBody =>
      'सत्र समाप्त करने की पुष्टि के लिए स्वाइप करें';

  @override
  String get sessionEndOverlaySwipeLabel => 'समाप्त करने के लिए स्वाइप करें';

  @override
  String get sessionEndOverlaySimBadge => '[SIM] अभ्यास मोड';

  @override
  String get sessionEndPinPromptTitle => 'सत्र-समाप्ति PIN दर्ज करें';

  @override
  String get sessionEndPinAppPinMismatch =>
      'ऐप लॉक PIN नहीं, सत्र-समाप्ति PIN उपयोग करें।';

  @override
  String get sessionEndPinIncorrect => 'गलत PIN';

  @override
  String get sessionEndPinSimSkip => 'छोड़ें (केवल सिम)';

  @override
  String get sessionEndSimDistressWouldFire =>
      'डिस्ट्रेस चेन चालू होती (5 गलत PIN)';

  @override
  String get distressConfirmTitle => 'डिस्ट्रेस सक्रिय हुआ';

  @override
  String distressConfirmCountdown(int seconds) {
    return 'रद्द करने के लिए टैप करें — आपके पास $seconds सेकंड हैं';
  }

  @override
  String get distressConfirmCancel => 'रद्द करने के लिए टैप करें';

  @override
  String get distressConfirmFooter =>
      'यदि रद्द नहीं किया गया, तो डिस्ट्रेस चेन तुरंत शुरू हो जाएगी।';

  @override
  String get distressCancelPinPromptTitle => 'सत्र-समाप्ति PIN दर्ज करें';

  @override
  String distressCancelPinTimeoutLabel(int seconds) {
    return '$secondsसे शेष';
  }

  @override
  String get distressCancelPinIncorrect => 'गलत PIN';

  @override
  String get distressCancelPinAppPinMismatch =>
      'ऐप लॉक PIN नहीं, सत्र-समाप्ति PIN उपयोग करें।';

  @override
  String get distressCancelPinSimSkip => 'छोड़ें (केवल सिम)';

  @override
  String get distressCancelSimDistressWouldFire =>
      'डिस्ट्रेस चेन चालू होती (5 गलत PIN)';

  @override
  String get distressCancelPinBack => 'रद्द करें';

  @override
  String get simulationPinPromptTitle => 'PIN दर्ज करें';

  @override
  String get simulationPinPromptBody =>
      'अपना सत्र-समाप्ति PIN दर्ज करने का अभ्यास करें';

  @override
  String get simulationPinPromptSkip => 'छोड़ें';

  @override
  String get simulationPinIncorrect => 'गलत PIN';

  @override
  String simulationSummaryDuration(String duration) {
    return 'अवधि: $duration';
  }

  @override
  String get simulationSummaryTimelineHeader => 'इवेंट समयरेखा';

  @override
  String get simulationSummaryShare => 'साझा करें';

  @override
  String simulationSummaryMissedEventsBadge(int count) {
    return 'छूटे: $count';
  }

  @override
  String simulationSummaryDistressBadge(int count) {
    return 'डिस्ट्रेस: $count';
  }

  @override
  String simulationSummaryStepsFiredBadge(int count) {
    return 'चले चरण: $count';
  }

  @override
  String get simulationSummaryShareSubject => 'Guardian Angela सिमुलेशन सारांश';

  @override
  String get notificationsChannelAlarm => 'अलार्म एस्कलेशन';

  @override
  String get notificationsChannelAlarmDescription =>
      'गंभीर अलर्ट जो DND को दरकिनार करते हैं';

  @override
  String get notificationsChannelReminder => 'छिपा हुआ रिमाइंडर';

  @override
  String get notificationsChannelReminderDescription =>
      'सक्रिय सत्र के दौरान चेक-इन रिमाइंडर';

  @override
  String get notificationsChannelFakeCall => 'नकली कॉल';

  @override
  String get notificationsChannelFakeCallDescription =>
      'पूर्ण-स्क्रीन आने वाली कॉल सूचनाएँ';

  @override
  String get notificationsChannelEnabled => 'सक्षम';

  @override
  String get notificationsChannelDisabled => 'अक्षम';

  @override
  String get notificationsChannelsHeader => 'सूचना चैनल';

  @override
  String get contactsImportFromDevice => 'संपर्कों से आयात करें';

  @override
  String get contactsImportNotSupported => 'इस प्लेटफ़ॉर्म पर उपलब्ध नहीं';

  @override
  String get contactsImportPermissionDenied =>
      'संपर्क एक्सेस अस्वीकृत। सिस्टम सेटिंग्स में सक्षम करें।';

  @override
  String get contactsDeleteAllMenu => 'सभी हटाएँ';

  @override
  String get contactsDeleteAllConfirmTitle => 'सभी संपर्क हटाएँ?';

  @override
  String get contactsDeleteAllConfirmBody =>
      'यह हर आपातकालीन संपर्क को हटा देता है। इसे पूर्ववत नहीं किया जा सकता।';

  @override
  String get contactsDeleteAllTypeConfirmTitle => 'टाइप करके पुष्टि करें';

  @override
  String get contactsDeleteAllTypeConfirmHint =>
      'जारी रखने के लिए DELETE ALL टाइप करें';

  @override
  String get contactsDeleteAllTypeConfirmSentinel => 'DELETE ALL';

  @override
  String get contactsDeleteAllConfirmButton => 'सभी हटाएँ';

  @override
  String get modesBuiltinBadge => 'बिल्ट-इन';

  @override
  String get modesBuiltinNoDelete => 'बिल्ट-इन मोड हटाए नहीं जा सकते';

  @override
  String get sessionCompletedSimulationBanner => 'सिमुलेशन पूर्ण';

  @override
  String get sessionCompletedViewEventLog => 'इवेंट लॉग देखें';

  @override
  String get settingsGeneralHeader => 'सामान्य';

  @override
  String get settingsAppHeader => 'ऐप';

  @override
  String get settingsConfigurationHeader => 'कॉन्फ़िगरेशन';

  @override
  String get settingsThemeLabel => 'थीम';

  @override
  String get settingsLanguageLabel => 'भाषा';

  @override
  String get settingsSecurityRow => 'सुरक्षा';

  @override
  String get settingsSecuritySubtitle =>
      'ऐप PIN, सत्र-समाप्ति PIN, ड्यूरेस PIN';

  @override
  String get settingsStealthRow => 'स्टेल्थ';

  @override
  String get settingsStealthSummaryOff => 'स्टेल्थ: बंद';

  @override
  String get settingsStealthSummaryOn => 'स्टेल्थ: चालू';

  @override
  String get settingsProfileRow => 'प्रोफ़ाइल';

  @override
  String get settingsModesRow => 'मोड';

  @override
  String get settingsDistressModesRow => 'संकट मोड';

  @override
  String get settingsBatteryAlertRow => 'बैटरी चेतावनी';

  @override
  String get settingsEventDefaultsRow => 'चरण डिफ़ॉल्ट';

  @override
  String get settingsGpsLoggingRow => 'GPS लॉगिंग';

  @override
  String get settingsRemindersRow => 'अनुस्मारक टेम्पलेट';

  @override
  String get settingsNotificationsRow => 'सूचनाएँ';

  @override
  String get settingsHistoryRetentionRow => 'इतिहास और रखरखाव';

  @override
  String get settingsAboutRow => 'के बारे में';

  @override
  String get settingsFeedbackRow => 'प्रतिक्रिया भेजें';

  @override
  String get settingsBackupRow => 'बैकअप और पुनर्स्थापना';

  @override
  String get settingsOssLicenses => 'ओपन सोर्स लाइसेंस';

  @override
  String get settingsImportConfirmBody =>
      'यह सभी मौजूदा डेटा को अधिलेखित कर देगा। जारी रखें?';

  @override
  String get securityAppPinTitle => 'ऐप PIN';

  @override
  String get securityAppPinBody => 'हर बार ऐप खोलने पर उसे लॉक करता है।';

  @override
  String get securitySessionEndPinTitle => 'सत्र-समाप्ति PIN';

  @override
  String get securitySessionEndPinBody =>
      'चल रहे सत्र को निरस्त्र करने या समाप्त करने के लिए आवश्यक।';

  @override
  String get securityDuressPinTitle => 'ड्यूरेस PIN';

  @override
  String get securityDuressPinBody =>
      'डिस्ट्रेस चेन चुपचाप चालू करने के लिए किसी भी प्रॉम्प्ट पर दर्ज किया जाता है।';

  @override
  String get securityRemovePin => 'हटाएँ';

  @override
  String get securityRemovePinPrompt =>
      'इसे हटाने के लिए अपना मौजूदा PIN दर्ज करें।';

  @override
  String get securityRemovePinIncorrect => 'गलत PIN';

  @override
  String get securityWhatIsThis => 'यह क्या है?';

  @override
  String get securityAppPinInfo =>
      'जब आप ऐप खोलती हैं तब उसे लॉक करता है। कीपैड किसी भी स्क्रीन से पहले दिखता है। उपयोगी जब कोई आपके अनलॉक फ़ोन को थोड़ी देर के लिए संभालता है।';

  @override
  String get securitySessionEndPinInfo =>
      'चल रहे सुरक्षा सत्र को निरस्त्र करने या समाप्त करने के लिए आवश्यक। इसके बिना, आपका फ़ोन छीनने वाला हमलावर चेन को रोक नहीं सकता। अपने ऐप PIN से अलग कोड सेट करें।';

  @override
  String get securityDuressPinInfo =>
      'यदि आप किसी भी प्रॉम्प्ट पर यह PIN दर्ज करती हैं, तो डिस्ट्रेस चेन चुपचाप चलती है — आपके संपर्कों को सूचित किया जाता है और हमलावर को बिना भनक लगे अलार्म तैयार हो जाता है। हर दूसरे PIN से अलग कोड चुनें।';

  @override
  String get securityPinTimeoutLabel => 'PIN टाइमआउट (सेकंड)';

  @override
  String get securityWrongPinThresholdLabel =>
      'एस्कलेशन से पहले गलत PIN प्रयास';

  @override
  String get securityDeceptiveDialogToggle => 'गलत PIN पर भ्रामक डायलॉग दिखाएँ';

  @override
  String get pinSetupEnterNew => 'नया PIN दर्ज करें';

  @override
  String get pinSetupConfirmNew => 'नए PIN की पुष्टि करें';

  @override
  String get pinSetupTooShort => 'PIN कम से कम 4 अंकों का होना चाहिए।';

  @override
  String get pinSetupCollision =>
      'यह PIN किसी अन्य कॉन्फ़िगर किए गए PIN से टकराता है।';

  @override
  String get pinSetupSaved => 'PIN सहेजा गया';

  @override
  String get stealthEnabledLabel => 'स्टेल्थ सक्षम करें';

  @override
  String get stealthFakeNameLabel => 'नकली ऐप नाम';

  @override
  String get stealthFakeIconLabel => 'नकली आइकन';

  @override
  String get stealthNotificationDisguiseLabel => 'सूचना भेस';

  @override
  String get stealthTimerDisplayLabel => 'टाइमर प्रदर्शन';

  @override
  String get stealthSessionScreenLabel => 'सत्र स्क्रीन स्टेल्थ';

  @override
  String get gpsLoggingEnabled => 'सत्रों के दौरान GPS लॉग करें';

  @override
  String get gpsLoggingIntervalLabel => 'अंतराल';

  @override
  String get gpsLoggingAccuracyLabel => 'सटीकता';

  @override
  String get gpsLoggingAccuracyHigh => 'उच्च';

  @override
  String get gpsLoggingAccuracyBalanced => 'संतुलित';

  @override
  String get gpsLoggingAccuracyLow => 'कम';

  @override
  String get gpsLoggingFormatLabel => 'निर्देशांक प्रारूप';

  @override
  String get gpsLoggingFormatDecimal => 'दशमलव';

  @override
  String get gpsLoggingFormatDms => 'DMS';

  @override
  String get gpsLoggingFormatAddress => 'Plus Code';

  @override
  String get gpsLoggingIncludeInSms => 'SMS में स्थान जोड़ें';

  @override
  String get historyRetentionLogsLabel => 'सत्र लॉग रखरखाव (दिन)';

  @override
  String get historyRetentionLogsHelper =>
      'इससे पुराने लॉग ट्रैश में चले जाते हैं।';

  @override
  String get historyRetentionTrashLabel => 'ट्रैश रखरखाव (दिन)';

  @override
  String get historyRetentionTrashHelper =>
      'ट्रैश में डाले गए लॉग इस अवधि के बाद स्थायी रूप से हटा दिए जाते हैं।';

  @override
  String get historyRetentionUpdated => 'रखरखाव अपडेट किया गया';

  @override
  String get historyRetentionPurgeNow => 'अभी साफ़ करें';

  @override
  String historyRetentionPurged(Object count) {
    return '$count लॉग साफ़ किए गए';
  }

  @override
  String get batteryAlertEnableLabel => 'बैटरी चेतावनी सक्षम करें';

  @override
  String get batteryAlertThresholdLabel => 'बैटरी सीमा (%)';

  @override
  String get batteryAlertChainHeader => 'चेतावनी चेन';

  @override
  String get batteryAlertResetChain => 'रीसेट करें';

  @override
  String get eventDefaultsCheckInHeader => 'चेक-इन विधियाँ';

  @override
  String get eventDefaultsEscalationHeader => 'एस्कलेशन चरण';

  @override
  String get eventDefaultsPanicHeader => 'पैनिक ट्रिगर';

  @override
  String get templatesCreate => 'टेम्पलेट बनाएँ';

  @override
  String get templatesEditTitle => 'टेम्पलेट संपादित करें';

  @override
  String get templatesCreateTitle => 'नया टेम्पलेट';

  @override
  String get templatesNameLabel => 'नाम';

  @override
  String get templatesTitleLabel => 'शीर्षक';

  @override
  String get templatesBodyLabel => 'मुख्य पाठ';

  @override
  String get templatesBuiltinNoDelete => 'बिल्ट-इन टेम्पलेट हटाए नहीं जा सकते';

  @override
  String get templatesAddFromTemplate => 'टेम्पलेट से';

  @override
  String get templatesAddFromScratch => 'शुरू से';

  @override
  String templatesDeleteConfirmTitle(Object name) {
    return '\"$name\" हटाएँ?';
  }

  @override
  String get templatesDeleteConfirmBody =>
      'यह टेम्पलेट स्थायी रूप से हटा दिया जाएगा।';

  @override
  String get templatesEmptyAddFirst => 'अपना पहला टेम्पलेट जोड़ें';

  @override
  String get templatesPickFromBuiltinTitle => 'एक बिल्ट-इन टेम्पलेट चुनें';

  @override
  String get templatesIconLabel => 'आइकन';

  @override
  String get templatesIconCalendar => 'कैलेंडर';

  @override
  String get templatesIconAppNotification => 'ऐप सूचना';

  @override
  String get templatesIconFitness => 'फिटनेस';

  @override
  String get templatesIconHealth => 'स्वास्थ्य';

  @override
  String get templatesIconFood => 'भोजन';

  @override
  String get templatesIconCoffee => 'कॉफ़ी';

  @override
  String get templatesIconBattery => 'बैटरी';

  @override
  String get templatesIconWeather => 'मौसम';

  @override
  String get templatesPreviewHeading => 'लाइव पूर्वावलोकन';

  @override
  String get templatesDiscardChangesTitle => 'बदलाव छोड़ें?';

  @override
  String get templatesDiscardChangesBody => 'सहेजे न गए संपादन खो जाएँगे।';

  @override
  String get templatesDiscardKeep => 'संपादन जारी रखें';

  @override
  String get templatesDiscardDiscard => 'छोड़ें';

  @override
  String get notificationsTitle => 'सूचनाएँ';

  @override
  String get notificationsStatusGranted => 'दी गई';

  @override
  String get notificationsStatusDenied => 'अस्वीकृत';

  @override
  String get notificationsStatusUnknown => 'अभी तक नहीं पूछा गया';

  @override
  String get notificationsRequest => 'अनुमति का अनुरोध करें';

  @override
  String get notificationsOpenSettings => 'सिस्टम सेटिंग्स खोलें';

  @override
  String get profileFieldPhone => 'फ़ोन नंबर';

  @override
  String get profileFieldDescription => 'शारीरिक विवरण';

  @override
  String get profileFieldMedicalConditions => 'चिकित्सा स्थितियाँ';

  @override
  String get profileFieldEmergencyInstructions => 'आपातकालीन निर्देश';

  @override
  String get aboutAuthor => 'लेखक: Jonas Eschle';

  @override
  String get aboutEmail => 'guardian.angela.app@gmail.com';

  @override
  String get aboutPrivacyPolicy => 'गोपनीयता नीति';

  @override
  String get aboutTermsOfService => 'सेवा की शर्तें';

  @override
  String get aboutSourceCode => 'सोर्स कोड';

  @override
  String get aboutSupport => 'सहायता / दान करें';

  @override
  String get aboutLicenses => 'ओपन सोर्स लाइसेंस';

  @override
  String get aboutTagline => 'LGBTQ+ सुरक्षा के लिए प्यार से बनाया गया।';

  @override
  String get aboutTechnicalSection => 'तकनीकी जानकारी';

  @override
  String aboutBundleId(Object id) {
    return 'Bundle ID: $id';
  }

  @override
  String aboutPlatforms(Object list) {
    return 'प्लेटफ़ॉर्म: $list';
  }

  @override
  String get feedbackHeading => 'हम आपसे सुनना पसंद करेंगे';

  @override
  String get feedbackCategoryLabel => 'श्रेणी';

  @override
  String get feedbackCategoryBug => 'बग रिपोर्ट';

  @override
  String get feedbackCategoryFeature => 'फ़ीचर अनुरोध';

  @override
  String get feedbackCategoryOther => 'अन्य';

  @override
  String get feedbackEmailLabel => 'ईमेल (वैकल्पिक)';

  @override
  String get feedbackMessageLabel => 'संदेश';

  @override
  String get feedbackIncludeLog => 'पिछला सत्र लॉग शामिल करें';

  @override
  String get feedbackSent => 'आपकी प्रतिक्रिया के लिए धन्यवाद!';

  @override
  String get feedbackMessageRequired =>
      'संदेश कम से कम 10 वर्णों का होना चाहिए।';

  @override
  String get backupIncludeLogs => 'सत्र लॉग शामिल करें';

  @override
  String get backupIncludeMedia => 'मीडिया शामिल करें';

  @override
  String get backupExportButton => 'निर्यात करें';

  @override
  String get backupImportButton => 'आयात करें';

  @override
  String get backupOverwriteWarning =>
      'आयात करने से सभी मौजूदा डेटा अधिलेखित हो जाता है।';

  @override
  String get backupImportSuccess =>
      'आयात पूर्ण। लागू करने के लिए पुनः आरंभ करें।';

  @override
  String backupImportError(Object message) {
    return 'आयात विफल: $message';
  }

  @override
  String get backupActiveSessionBanner =>
      'सक्रिय सत्र के दौरान बैकअप उपलब्ध नहीं है।';

  @override
  String backupLastBackupAtLabel(Object when) {
    return 'अंतिम बैकअप $when पर';
  }

  @override
  String get backupNeverExportedLabel => 'अभी तक कोई बैकअप नहीं';

  @override
  String get pastEventsTitle => 'पिछले सत्र';

  @override
  String get pastEventsTabReal => 'असली';

  @override
  String get pastEventsTabSimulated => 'सिमुलेटेड';

  @override
  String get pastEventsEmpty => 'अभी तक कोई सत्र नहीं';

  @override
  String get pastEventsDeleteConfirm => 'सत्र लॉग हटाएँ?';

  @override
  String get pastEventsDetailShareText => 'टेक्स्ट के रूप में साझा करें';

  @override
  String get pastEventsDetailSharePdf => 'PDF के रूप में साझा करें';

  @override
  String get pastEventsDetailDelete => 'हटाएँ';

  @override
  String get pastEventsOutcomeCompleted => 'पूर्ण';

  @override
  String get pastEventsOutcomeDistress => 'डिस्ट्रेस';

  @override
  String get pastEventsOutcomeInterrupted => 'बाधित';

  @override
  String get pastEventsTrash => 'ट्रैश';

  @override
  String get pastEventsUndo => 'पूर्ववत करें';

  @override
  String get pastEventsSoftDeleted => 'ट्रैश में ले जाया गया';

  @override
  String get pastEventsDetailTitle => 'सत्र लॉग';

  @override
  String get pastEventsDetailShare => 'साझा करें';

  @override
  String get contactUnsavedDiscardTitle => 'सहेजे न गए बदलाव छोड़ें?';

  @override
  String get contactUnsavedDiscardKeep => 'संपादन जारी रखें';

  @override
  String get contactUnsavedDiscardDiscard => 'छोड़ें';

  @override
  String get modesDuplicate => 'प्रतिलिपि बनाएँ';

  @override
  String get modesDeleteConfirmTitle => 'मोड हटाएँ?';

  @override
  String modesDeleteConfirmBody(Object name) {
    return '$name स्थायी रूप से हटा दिया जाएगा।';
  }

  @override
  String get modesDistressDefaultBadge => 'डिफ़ॉल्ट';

  @override
  String get modesDistressSetDefault => 'डिफ़ॉल्ट के रूप में सेट करें';

  @override
  String get modesDistressCantDeleteLast => 'कम से कम एक संकट मोड आवश्यक है।';

  @override
  String get modesDistressInUse =>
      'यह संकट मोड किसी अन्य मोड द्वारा उपयोग में है।';

  @override
  String get modesDistressTitle => 'संकट मोड';

  @override
  String get validationNameTooShort => 'नाम कम से कम 2 वर्णों का होना चाहिए।';

  @override
  String get validationPhoneRequired => 'फ़ोन नंबर आवश्यक है।';

  @override
  String get validationChannelsRequired => 'कम से कम एक चैनल चुनें।';

  @override
  String get sessionHoldTouchToBegin => 'शुरू करने के लिए स्पर्श करें';

  @override
  String sessionHoldReleaseCountdown(Object seconds) {
    return 'उल्टी गिनती: $secondsसे';
  }

  @override
  String sessionHoldGraceCountdown(Object seconds) {
    return 'छूट: $secondsसे — सुरक्षित रहने के लिए फिर से दबाए रखें';
  }

  @override
  String get sessionHoldAgain => 'सुरक्षित रहने के लिए फिर से दबाए रखें';

  @override
  String sessionStepNextCheckIn(Object time) {
    return 'अगला चेक-इन $time में';
  }

  @override
  String sessionStepFakeCallActive(Object caller) {
    return '$caller से आने वाली कॉल';
  }

  @override
  String get sessionStepFakeCallOpen => 'कॉल स्क्रीन खोलें';

  @override
  String sessionStepSimBlockedSms(Object count) {
    return '[SIM] $count संपर्कों को SMS भेजा जाता';
  }

  @override
  String get sessionStepSimBlockedPhone =>
      '[SIM] आपातकालीन संपर्क को कॉल किया जाता';

  @override
  String get sessionStepSimBlockedEmergency =>
      '[SIM] आपातकालीन सेवाओं को कॉल किया जाता';

  @override
  String get sessionStepSimBlockedAlarm => '[SIM] अलार्म पूर्ण वॉल्यूम पर बजता';

  @override
  String get sessionStartFailedTitle => 'सत्र शुरू नहीं हो सकता';

  @override
  String get sessionStartFailedBody =>
      'शुरू करने से पहले निम्नलिखित समस्याएँ ठीक करें:';

  @override
  String get sessionQuickExitTitle => 'त्वरित निकास';

  @override
  String get sessionQuickExitBody =>
      'सत्र डेटा सुरक्षित और एन्क्रिप्ट किया जाएगा। इसे पुनः प्राप्त करने के लिए कभी भी ऐप दोबारा खोलें।';

  @override
  String get sessionQuickExitConfirm => 'ऐप से बाहर निकलें';

  @override
  String get pastEventsRestore => 'पुनर्स्थापित करें';

  @override
  String batteryAlertForbiddenStep(Object type) {
    return '$type बैटरी-चेतावनी चेन में अनुमत नहीं है।';
  }

  @override
  String get stepEditorWait => 'प्रतीक्षा (से)';

  @override
  String get stepEditorDuration => 'अवधि (से)';

  @override
  String get stepEditorGrace => 'छूट (से)';

  @override
  String get stepEditorRetryCount => 'पुनःप्रयास संख्या';

  @override
  String get stepEditorRandomize => 'समय यादृच्छिक करें (±20%)';

  @override
  String get stepEditorRemove => 'चरण हटाएँ';

  @override
  String get eventDefaultsHoldStyle => 'होल्ड शैली';

  @override
  String get eventDefaultsHoldSensitivity => 'रिलीज़ संवेदनशीलता';

  @override
  String get eventDefaultsHoldVibrate => 'रिलीज़ पर कंपन';

  @override
  String get eventDefaultsHoldSound => 'रिलीज़ पर ध्वनि';

  @override
  String get eventDefaultsBlackScreen => 'काली स्क्रीन ओवरले';

  @override
  String get eventDefaultsReminderRandomInterval => 'अंतराल यादृच्छिक करें';

  @override
  String get eventDefaultsReminderRandomTemplate =>
      'टेम्पलेट क्रम यादृच्छिक करें';

  @override
  String get eventDefaultsReminderResetOnEarly => 'जल्दी चेक-इन पर रीसेट करें';

  @override
  String get eventDefaultsCountdownStyle => 'उल्टी गिनती शैली';

  @override
  String get eventDefaultsCountdownVibrate => 'कंपन';

  @override
  String get eventDefaultsCountdownSound => 'ध्वनि';

  @override
  String get eventDefaultsFakeCallStyle => 'कॉल शैली';

  @override
  String get eventDefaultsFakeCallCallerName => 'कॉल करने वाले का नाम';

  @override
  String get eventDefaultsFakeCallRingDuration => 'रिंग अवधि (से)';

  @override
  String get eventDefaultsFakeCallDeclineIsSafe =>
      'अस्वीकार करना सुरक्षित माना जाए';

  @override
  String get eventDefaultsFakeCallVoiceOutput => 'वॉइस आउटपुट';

  @override
  String get eventDefaultsSmsChannel => 'चैनल';

  @override
  String get eventDefaultsSmsIncludeLocation => 'स्थान शामिल करें';

  @override
  String get eventDefaultsSmsIncludeMedical => 'चिकित्सा जानकारी शामिल करें';

  @override
  String get eventDefaultsSmsAutoRecord => 'भेजने से पहले ऑडियो रिकॉर्ड करें';

  @override
  String get eventDefaultsSmsRecordDuration => 'रिकॉर्डिंग अवधि (से)';

  @override
  String get eventDefaultsLoudAlarmVolume => 'वॉल्यूम';

  @override
  String get eventDefaultsLoudAlarmSound => 'ध्वनि';

  @override
  String get eventDefaultsLoudAlarmFlashScreen => 'स्क्रीन फ़्लैश करें';

  @override
  String get eventDefaultsLoudAlarmFlashLight => 'कैमरा लाइट फ़्लैश करें';

  @override
  String get eventDefaultsLoudAlarmGradual => 'क्रमिक वॉल्यूम वृद्धि';

  @override
  String get eventDefaultsCallEmergencyNumber => 'आपातकालीन नंबर (ओवरराइड)';

  @override
  String get eventDefaultsCallEmergencyConfirm => 'पुष्टि उल्टी गिनती दिखाएँ';

  @override
  String get eventDefaultsCallEmergencyConfirmDuration => 'पुष्टि सेकंड';

  @override
  String get eventDefaultsCallEmergencySmsFirst => 'पहले स्थान SMS भेजें';

  @override
  String get eventDefaultsPhonePrimaryContact => 'प्राथमिक संपर्क (id)';

  @override
  String get eventDefaultsHardwareButton => 'बटन';

  @override
  String get eventDefaultsHardwarePattern => 'दबाने का पैटर्न';

  @override
  String get eventDefaultsHardwarePressCount => 'दबाने की संख्या';

  @override
  String get eventDefaultsHardwareLongDuration => 'लंबे-दबाव की अवधि (से)';

  @override
  String get pastEventsTrashTitle => 'ट्रैश';

  @override
  String get pastEventsTrashEmpty => 'ट्रैश खाली है';

  @override
  String get pastEventsTrashEmptyAll => 'ट्रैश खाली करें';

  @override
  String get pastEventsTrashEmptyAllConfirmTitle => 'ट्रैश खाली करें?';

  @override
  String get pastEventsTrashEmptyAllConfirmBody =>
      'पुष्टि के लिए नीचे EMPTY TRASH टाइप करें। यह हर ट्रैश किए गए लॉग को स्थायी रूप से हटा देता है।';

  @override
  String pastEventsTrashEmptyAllSuccess(Object count) {
    return 'ट्रैश खाली किया गया ($count लॉग)';
  }

  @override
  String pastEventsTrashRetentionNote(int days) {
    return 'ट्रैश में लॉग $days दिनों के बाद स्थायी रूप से हटा दिए जाते हैं।';
  }

  @override
  String pastEventsTrashRemainingDays(int days) {
    return 'स्थायी विलोपन में $days दिन शेष';
  }

  @override
  String get pastEventsTrashDeletePermanently => 'स्थायी रूप से हटाएँ';

  @override
  String get pastEventsTrashDeletePermanentlyBody =>
      'इस क्रिया को पूर्ववत नहीं किया जा सकता।';

  @override
  String sessionEmergencyConfirmTitle(String number, int seconds) {
    return '$number को $secondsसे में कॉल किया जा रहा है';
  }

  @override
  String get sessionEmergencyConfirmSwipe => 'रद्द करने के लिए स्वाइप करें';

  @override
  String get sessionEmergencyConfirmKeep => 'कॉल जारी रखें';

  @override
  String get sessionEmergencyConfirmSimBadge => '[SIM] अभ्यास मोड';

  @override
  String get sessionEmergencyConfirmSimCancelled =>
      'सिमुलेटेड रद्द — कॉल नहीं की जाती';

  @override
  String get swipeSliderSemantics => 'पुष्टि के लिए स्वाइप करें';

  @override
  String get homeWidgetStatusIdle => 'निष्क्रिय';

  @override
  String get homeWidgetStatusSession => 'सत्र सक्रिय';

  @override
  String get homeWidgetStatusSim => 'सिमुलेशन सक्रिय';

  @override
  String get homeWidgetStatusBatteryAlert => 'बैटरी चेतावनी';

  @override
  String get homeWidgetQuickExit => 'त्वरित निकास';

  @override
  String get homeWidgetFakeCall => 'नकली कॉल';
}
