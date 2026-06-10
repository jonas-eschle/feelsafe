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
  String get commonGotIt => 'समझ गया';

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
    return 'SIM नंबर $number का उपयोग किया जा रहा है';
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
  String get chainStepDescHoldButton =>
      'सुरक्षित रहने के लिए दबाए रखें — छोड़ने पर छूट अवधि की उलटी गिनती शुरू हो जाती है।';

  @override
  String get chainStepDescDisguisedReminder =>
      'एक छिपा हुआ नोटिफ़िकेशन भेजता है — सुरक्षा की पुष्टि के लिए आपको जवाब देना होगा।';

  @override
  String get chainStepDescFakeCall =>
      'इनकमिंग कॉल की नकल करता है — सुरक्षित होने का संकेत देने के लिए उत्तर दें या अस्वीकार करें।';

  @override
  String get chainStepDescSmsContact =>
      'आपातकालीन संपर्कों को आपके स्थान के साथ SMS भेजता है।';

  @override
  String get chainStepDescCountdownWarning =>
      'अंतिम चेतावनी के रूप में ध्वनि और चमक के साथ उलटी गिनती दिखाता है।';

  @override
  String get chainStepDescLoudAlarm =>
      'ध्यान आकर्षित करने के लिए चमक के साथ अधिकतम वॉल्यूम पर अलार्म बजाता है।';

  @override
  String get chainStepDescCallEmergency =>
      'आपातकालीन सेवाओं (112/911) को स्वचालित रूप से कॉल करता है।';

  @override
  String get chainStepDescPhoneCallContact =>
      'किसी आपातकालीन संपर्क को सीधे कॉल करता है।';

  @override
  String get chainStepDescHardwareButton =>
      'पैनिक प्रेस पैटर्न के लिए हार्डवेयर बटन पर नज़र रखता है।';

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
  String get sessionPausedIncomingCall => 'रुका हुआ — इनकमिंग कॉल';

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
  String get sessionReminderEarlyCheckInHint => 'अभी चेक-इन के लिए टैप करें';

  @override
  String get sessionReminderDefaultButton => 'ठीक है';

  @override
  String get sessionReminderTapWordHint => 'जारी रखने के लिए टैप करें';

  @override
  String get sessionReminderDecoyWords =>
      'बाद में,छोड़ें,पूर्ण,खोलें,देखें,ठीक है,अगला,और,स्नूज़,बंद करें';

  @override
  String get sessionReminderSwipeLabel => 'बंद करने के लिए स्वाइप करें';

  @override
  String get sessionReminderDismissLabel => 'बंद करें';

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
  String get sessionStealthNowPlaying => 'अभी चल रहा है';

  @override
  String get sessionServiceTitle => 'Guardian Angela सक्रिय है';

  @override
  String get sessionServiceBody => 'आपका सुरक्षा सत्र चल रहा है।';

  @override
  String get sessionServiceStealthBody => 'चल रहा है';

  @override
  String get sessionStealthTrackTitle => 'बिना शीर्षक वाला ट्रैक';

  @override
  String get sessionStealthArtistName => 'अज्ञात कलाकार';

  @override
  String get sessionStealthAlbumArtLabel => 'एल्बम कला';

  @override
  String get sessionStealthPlay => 'चलाएँ';

  @override
  String get sessionStealthPause => 'रोकें';

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
  String get stepConfigTimingHeader => 'समय निर्धारण';

  @override
  String get stepConfigEventHeader => 'इवेंट कॉन्फ़िगरेशन';

  @override
  String get stepConfigAdvancedHeader => 'पुनःप्रयास और उन्नत';

  @override
  String get stepFieldWait => 'सक्रिय होने से पहले प्रतीक्षा (सेकंड)';

  @override
  String get stepFieldDuration => 'सक्रिय अवधि (सेकंड)';

  @override
  String get stepFieldGrace => 'छूट अवधि (सेकंड)';

  @override
  String get stepFieldRetryCount => 'पुनःप्रयास';

  @override
  String get stepFieldRandomize => 'समय यादृच्छिक करें (±20%)';

  @override
  String get stepDuplicate => 'चरण की प्रतिलिपि बनाएँ';

  @override
  String get stepResetDefaults => 'डिफ़ॉल्ट पर रीसेट करें';

  @override
  String get smsContactRecipientsHeader => 'संदेश भेजने के लिए संपर्क';

  @override
  String get smsContactSummaryAll => 'प्रति: सभी सक्षम संपर्क';

  @override
  String get smsContactSummaryNone => 'कोई प्राप्तकर्ता चयनित नहीं';

  @override
  String smsContactSummaryTo(Object names) {
    return 'प्रति: $names';
  }

  @override
  String get smsContactChannelDisabledTooltip =>
      'इस संपर्क के लिए सक्षम नहीं — यह चैनल जोड़ने के लिए संपर्क संपादित करें।';

  @override
  String get smsContactEmptyAddPrompt =>
      'अभी तक कोई संपर्क नहीं — संपर्क में एक जोड़ें';

  @override
  String get safetyOptionsHeader => 'सुरक्षा विकल्प';

  @override
  String get safetyOptionsDistressModeTitle => 'संकट मोड';

  @override
  String get safetyOptionsDistressModeUseDefault =>
      'डिफ़ॉल्ट संकट मोड का उपयोग करें';

  @override
  String safetyOptionsDistressModeUseDefaultNamed(Object name) {
    return 'डिफ़ॉल्ट का उपयोग करें ($name)';
  }

  @override
  String get safetyOptionsDistressModeInfo =>
      'जब कोई संकट ट्रिगर सक्रिय होता है (दबाव वाला PIN, हार्डवेयर पैनिक, या बहुत अधिक गलत PIN), तो इस मोड की शृंखला चुने गए संकट मोड की शृंखला से बदल जाती है. ऐप-व्यापी संकट मोड का उपयोग करने के लिए डिफ़ॉल्ट पर छोड़ दें.';

  @override
  String get safetyOptionsManageDistressModes => 'संकट मोड प्रबंधित करें';

  @override
  String get safetyOptionsDistressTriggersTitle => 'संकट ट्रिगर';

  @override
  String get safetyOptionsDistressTriggersInfo =>
      'संकट ट्रिगर मुख्य शृंखला के समानांतर तुरंत संकट शृंखला शुरू कर देते हैं. हार्डवेयर पैनिक बटन कॉन्फ़िगर किए गए दबाने के पैटर्न के लिए एक भौतिक बटन पर नज़र रखता है.';

  @override
  String get safetyOptionsDistressTriggersEmpty => 'कोई संकट ट्रिगर नहीं';

  @override
  String get safetyOptionsAddHardwarePanic => 'हार्डवेयर पैनिक बटन जोड़ें';

  @override
  String safetyOptionsTriggerHardwareRepeat(Object button, Object count) {
    return '$button: $count× दबाएँ';
  }

  @override
  String safetyOptionsTriggerHardwareLong(Object button, Object seconds) {
    return '$button: $seconds से दबाए रखें';
  }

  @override
  String get safetyOptionsButtonVolumeUp => 'वॉल्यूम ऊपर';

  @override
  String get safetyOptionsButtonVolumeDown => 'वॉल्यूम नीचे';

  @override
  String get safetyOptionsTriggerPattern => 'दबाने का पैटर्न';

  @override
  String get safetyOptionsPatternRepeat => 'बार-बार दबाना';

  @override
  String get safetyOptionsPatternLong => 'देर तक दबाना';

  @override
  String get safetyOptionsTriggerButton => 'बटन';

  @override
  String get safetyOptionsTriggerPressCount => 'दबाने की संख्या';

  @override
  String get safetyOptionsTriggerHoldDuration => 'दबाए रखने की अवधि (सेकंड)';

  @override
  String get safetyOptionsDisarmTriggersTitle => 'निष्क्रिय करने वाले ट्रिगर';

  @override
  String get safetyOptionsGpsArrivalTitle => 'GPS आगमन पर निष्क्रियण';

  @override
  String get safetyOptionsGpsArrivalInfo =>
      'जब आप अपने गंतव्य के कॉन्फ़िगर किए गए दायरे के भीतर पहुँचते हैं तो सत्र स्वतः समाप्त हो जाता है. आप सत्र शुरू करते समय गंतव्य निर्धारित करते हैं.';

  @override
  String get safetyOptionsGpsArrivalRadius => 'आगमन दायरा';

  @override
  String safetyOptionsRadiusMeters(Object meters) {
    return '$meters मी';
  }

  @override
  String safetyOptionsRadiusKilometers(Object km) {
    return '$km किमी';
  }

  @override
  String get safetyOptionsDestinationSource => 'गंतव्य';

  @override
  String get safetyOptionsDestinationPrompt =>
      'सत्र आरंभ पर गंतव्य निर्धारित करें';

  @override
  String get safetyOptionsDestinationFixed => 'स्थिर निर्देशांक';

  @override
  String get safetyOptionsLatitude => 'अक्षांश';

  @override
  String get safetyOptionsLongitude => 'देशांतर';

  @override
  String get safetyOptionsTimerDisarmTitle => 'टाइमर निष्क्रियण';

  @override
  String get safetyOptionsTimerDisarmInfo =>
      'एस्केलेशन शुरू हुआ है या नहीं, इसकी परवाह किए बिना, सत्र कॉन्फ़िगर किए गए समय के बाद स्वतः समाप्त हो जाता है.';

  @override
  String get safetyOptionsTimerDuration => 'अवधि';

  @override
  String safetyOptionsDurationMinutes(Object minutes) {
    return '$minutes मिनट';
  }

  @override
  String safetyOptionsDurationHoursMinutes(Object hours, Object minutes) {
    return '$hours घंटे $minutes मिनट';
  }

  @override
  String get safetyOptionsGpsLoggingTitle => 'GPS लॉगिंग';

  @override
  String get safetyOptionsGpsLoggingInfo =>
      'चुनें कि यह मोड सत्र के दौरान आपका स्थान रिकॉर्ड करता है या नहीं. ‘इनहेरिट’ आपकी वैश्विक GPS सेटिंग्स का उपयोग करता है; ‘कस्टम’ इस मोड के लिए उन्हें ओवरराइड करता है; ‘बंद’ लॉगिंग को पूरी तरह अक्षम कर देता है.';

  @override
  String get safetyOptionsStealthTitle => 'गुप्त मोड';

  @override
  String get safetyOptionsStealthInfo =>
      'चुनें कि यह मोड सत्र के दौरान ऐप का भेस बदलता है या नहीं. ‘इनहेरिट’ आपकी वैश्विक गुप्त सेटिंग्स का उपयोग करता है; ‘कस्टम’ इस मोड के लिए उन्हें ओवरराइड करता है; ‘बंद’ गुप्त मोड को पूरी तरह अक्षम कर देता है.';

  @override
  String get safetyOptionsTriStateInherit => 'इनहेरिट';

  @override
  String get safetyOptionsTriStateCustom => 'कस्टम';

  @override
  String get safetyOptionsTriStateOff => 'बंद';

  @override
  String get safetyOptionsLocalTemplatesTitle => 'स्थानीय टेम्पलेट';

  @override
  String get safetyOptionsLocalTemplatesInfo =>
      'स्थानीय टेम्पलेट केवल इस मोड के लिए वैश्विक रिमाइंडर-टेम्पलेट पूल में जोड़े जाते हैं. इस मोड के लिए विशिष्ट छद्म-रिमाइंडर चरणों के लिए उनका उपयोग करें.';

  @override
  String get safetyOptionsLocalTemplatesEmpty => 'कोई स्थानीय टेम्पलेट नहीं';

  @override
  String get safetyOptionsAddTemplate => 'टेम्पलेट जोड़ें';

  @override
  String get safetyOptionsManageTemplates => 'रिमाइंडर टेम्पलेट प्रबंधित करें';

  @override
  String get safetyOptionsEventDefaultsTitle => 'इवेंट डिफ़ॉल्ट';

  @override
  String get safetyOptionsEventDefaultsInfo =>
      'इवेंट डिफ़ॉल्ट प्रत्येक चरण प्रकार के लिए प्रारंभिक कॉन्फ़िगरेशन सेट करते हैं. ‘इनहेरिट’ आपके वैश्विक डिफ़ॉल्ट का उपयोग करता है; ‘कस्टम’ इस मोड में बिना अपने कॉन्फ़िगरेशन वाले चरणों के लिए उन्हें ओवरराइड करता है.';

  @override
  String get safetyOptionsEventDefaultsTwoStateInherit => 'इनहेरिट';

  @override
  String get safetyOptionsAllowDisarmAsDistressTitle =>
      'संकट के रूप में सक्रिय रहते हुए निष्क्रियण की अनुमति दें';

  @override
  String get safetyOptionsAllowDisarmAsDistressInfo =>
      'सक्षम करने पर आप सुरक्षित स्थान पर पहुँचकर या टाइमर समाप्त होने देकर अलार्म रोक सकते हैं. अक्षम करने पर केवल शृंखला पूरी होने या ऐप बंद करने पर ही अलार्म रुकता है — दबाव के विरुद्ध अधिक मज़बूत.';

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
  String get settingsEmergencyNumberEditTitle => 'आपातकालीन नंबर';

  @override
  String get settingsEmergencyNumberFieldLabel => 'डायल किया जाने वाला नंबर';

  @override
  String get settingsEmergencyNumberPresetsLabel => 'सामान्य नंबर';

  @override
  String get phoneWarnInvalidChars => 'केवल अंक, +, * और # की अनुमति है।';

  @override
  String get phoneWarnTooShort =>
      'आपातकालीन नंबर आमतौर पर कम से कम 3 अंकों के होते हैं।';

  @override
  String get phoneWarnLooksLikeRegular =>
      'यह एक सामान्य फ़ोन नंबर जैसा लगता है, आपातकालीन सेवा नंबर नहीं।';

  @override
  String get phoneWarnEmergencyEmpty =>
      'एक नंबर दर्ज करें — यह खाली नहीं हो सकता।';

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
  String get securityDistressCancelBiometric =>
      'संकट रद्द करने के लिए बायोमेट्रिक्स का उपयोग करें';

  @override
  String get launchPinTitle => 'अपना ऐप PIN दर्ज करें';

  @override
  String get launchPinBiometricReason => 'Guardian Angela अनलॉक करें';

  @override
  String get sessionEndBiometricReason => 'सत्र समाप्त करने के लिए पुष्टि करें';

  @override
  String get distressCancelBiometricReason =>
      'रद्द करने के लिए पुष्टि करें कि यह आप हैं';

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
  String get stealthLockTaskInfo =>
      'पूरे सत्र के दौरान Guardian Angela को स्क्रीन पर पिन कर देता है ताकि इसे स्वाइप करके बंद या स्विच न किया जा सके। समझौता: Android एक सिस्टम सूचना \"ऐप पिन किया गया है\" दिखाता है और सत्र समाप्त होने तक ऐप-स्विचिंग रोक देता है — जो स्क्रीन देख रहे किसी भी व्यक्ति को दिखता है। यदि आप सत्र के दौरान ऐप्स के बीच स्वतंत्र रूप से जाना चाहते हैं तो इसे बंद रहने दें। स्क्रीन-पिनिंग के बिना वाले प्लेटफ़ॉर्म पर कोई प्रभाव नहीं।';

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
  String get sessionInterruptedStartSameMode => 'वही मोड शुरू करें';

  @override
  String get sessionInterruptedJustNow => 'अभी-अभी';

  @override
  String sessionInterruptedMinutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count मिनट पहले',
      one: '$count मिनट पहले',
    );
    return '$_temp0';
  }

  @override
  String sessionInterruptedHoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count घंटे पहले',
      one: '$count घंटे पहले',
    );
    return '$_temp0';
  }

  @override
  String sessionInterruptedDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count दिन पहले',
      one: '$count दिन पहले',
    );
    return '$_temp0';
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
  String get sessionCompletedFeedbackPrompt => 'आपका अनुभव कैसा रहा?';

  @override
  String get sessionCompletedFeedbackSend => 'प्रतिक्रिया भेजें';

  @override
  String get sessionCompletedFeedbackSkip => 'छोड़ें';

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
  String get templatesRequiredFieldsError =>
      'नाम, शीर्षक और मुख्य पाठ आवश्यक हैं।';

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
  String get validationChainEmpty => 'सहेजने से पहले कम से कम एक चरण जोड़ें.';

  @override
  String get validationGpsFixedCoords =>
      'स्थिर आगमन गंतव्य के लिए अक्षांश और देशांतर दोनों सेट करें.';

  @override
  String get validationHardwareTrigger =>
      'हार्डवेयर पैनिक ट्रिगर अधूरा है — इसकी प्रेस संख्या या होल्ड अवधि जाँचें.';

  @override
  String get validationSmsChannelNotOnContacts =>
      'चुने गए किसी भी संपर्क को इस चरण के चैनल पर संदेश नहीं मिल सकता। कोई अन्य चैनल चुनें या इसे किसी संपर्क में जोड़ें।';

  @override
  String get validationDistressNoActionTitle => 'कोई आउटगोइंग अलर्ट चरण नहीं';

  @override
  String get validationDistressNoActionBody =>
      'इस संकट मोड में कोई SMS या कॉल चरण नहीं है, इसलिए यह कोई आउटगोइंग निशान नहीं छोड़ता. फिर भी सहेजें?';

  @override
  String get validationSaveAnyway => 'फिर भी सहेजें';

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
  String get eventDefaultsFakeCallRingtone => 'रिंगटोन';

  @override
  String get eventDefaultsFakeCallRingtoneDefault => 'डिफ़ॉल्ट रिंग';

  @override
  String eventDefaultsFakeCallRingtoneCustom(String fileName) {
    return 'कस्टम: $fileName';
  }

  @override
  String get eventDefaultsFakeCallRingtoneChoose => 'रिंगटोन चुनें…';

  @override
  String get eventDefaultsFakeCallRingtoneUseDefault =>
      'डिफ़ॉल्ट का उपयोग करें';

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
  String get eventDefaultsSmsMessageTemplate => 'संदेश टेम्पलेट';

  @override
  String get eventDefaultsSmsMessageTemplateHint =>
      'डिफ़ॉल्ट अलर्ट उपयोग करने के लिए खाली छोड़ें। डालने के लिए किसी प्लेसहोल्डर पर टैप करें।';

  @override
  String get eventDefaultsSmsIosWarning =>
      'iPhone पर, SMS के लिए आपको Messages ऐप में स्वयं Send दबाना होगा। यदि आप अपना फ़ोन नहीं चला सकते, तो संदेश नहीं भेजा जाएगा। इसके बजाय WhatsApp या Telegram उपयोग करने पर विचार करें।';

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
  String get eventDefaultsCallEmergencyIosWarning =>
      'iPhone पर, डायल करने से पहले एक पुष्टि संवाद दिखेगा। जल्दी से ‘Call’ पर टैप करें।';

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
  String get eventDefaultsHoldStyleInfo =>
      'होल्ड सतह कैसी दिखती है: एक बड़ा बटन, पूरी स्क्रीन, या एक नकली लॉक स्क्रीन जो छिपाती है कि ऐप क्या कर रहा है।';

  @override
  String get eventDefaultsHoldSensitivityInfo =>
      'उठी हुई उंगली कितनी सख़्ती से छोड़ना मानी जाए। कम मान छोटी फिसलन माफ़ करते हैं; अधिक मान तुरंत प्रतिक्रिया देते हैं।';

  @override
  String get eventDefaultsHoldVibrateInfo =>
      'जैसे ही आपकी उंगली बटन से हटती है, फ़ोन कंपन करता है, ताकि आप गलती से छूटने को तुरंत भांप लें।';

  @override
  String get eventDefaultsHoldSoundInfo =>
      'जब आपकी उंगली बटन से हटती है तो एक छोटी ध्वनि बजती है, ताकि स्क्रीन देखे बिना भी आप गलती से छूटने को भांप लें।';

  @override
  String get eventDefaultsBlackScreenInfo =>
      'इस चरण के दौरान स्क्रीन को काला रखता है, लॉक फ़ोन की नकल करते हुए, ताकि देखने वाले को ऐप दिखाई न दे। चरण नीचे चलता रहता है।';

  @override
  String get eventDefaultsReminderRandomIntervalInfo =>
      'रिमाइंडर के बीच के समय में लगभग ±20% का बदलाव करता है, ताकि वे तय कार्यक्रम के बजाय सामान्य ऐप नोटिफ़िकेशन लगें।';

  @override
  String get eventDefaultsReminderRandomTemplateInfo =>
      'हर बार अलग रिमाइंडर टेम्पलेट चुनता है, ताकि आपके नोटिफ़िकेशन देखने वाले को दोहराए गए रिमाइंडर एक जैसे न लगें।';

  @override
  String get eventDefaultsReminderResetOnEarlyInfo =>
      'यदि आप रिमाइंडर बजने से पहले चेक-इन करते हैं, तो टाइमर पुराना कार्यक्रम रखने के बजाय पूरे अंतराल से फिर शुरू होता है।';

  @override
  String get eventDefaultsReminderTemplatesTitle => 'रिमाइंडर टेम्पलेट';

  @override
  String get eventDefaultsReminderTemplatesInfo =>
      'टेम्पलेट तय करते हैं कि छिपा हुआ रिमाइंडर कैसा दिखे — उसका नकली ऐप नाम, शीर्षक और टेक्स्ट (जैसे कैलेंडर या भाषा-ऐप का नोटिफ़िकेशन)। साझा पूल यहाँ प्रबंधित करें; हर छिपा-रिमाइंडर चरण इसी में से चुनता है।';

  @override
  String get eventDefaultsCountdownStyleInfo =>
      'उलटी गिनती कैसे दिखे: पूर्ण-स्क्रीन चेतावनी या कम ध्यान खींचने वाला छोटा ओवरले।';

  @override
  String get eventDefaultsCountdownVibrateInfo =>
      'उलटी गिनती चलते समय फ़ोन कंपन करता है, ताकि जेब में फ़ोन होने पर भी आप उसे भांप लें।';

  @override
  String get eventDefaultsCountdownSoundInfo =>
      'उलटी गिनती चलते समय श्रव्य अलर्ट बजाता है। यदि चेतावनी मौन रहनी चाहिए तो इसे बंद कर दें।';

  @override
  String get eventDefaultsFakeCallStyleInfo =>
      'नकली कॉल किस ऐप की इनकमिंग-कॉल स्क्रीन की नकल करे, ताकि वह आपके फ़ोन पर विश्वसनीय लगे।';

  @override
  String get eventDefaultsFakeCallCallerNameInfo =>
      'नकली कॉल स्क्रीन पर कॉलर के रूप में दिखने वाला नाम। ऐसा कोई चुनें जिसका कॉल उठाना आपके लिए स्वाभाविक लगे।';

  @override
  String get eventDefaultsFakeCallRingDurationInfo =>
      'नकली कॉल मिस्ड मानी जाने से पहले कितनी देर बजती है। मिस्ड कॉल चेन को आगे बढ़ने देती है।';

  @override
  String get eventDefaultsFakeCallVoiceOutputInfo =>
      'उत्तर देने के बाद आवाज़ कहाँ बजे: ईयरपीस (धीमा और निजी) या लाउडस्पीकर।';

  @override
  String get eventDefaultsFakeCallRingtoneInfo =>
      'नकली कॉल की रिंगटोन। अपनी असली रिंगटोन से मेल खाने के लिए अपनी ऑडियो फ़ाइल आयात करें — यदि फ़ाइल कभी न मिले, तो अंतर्निहित रिंग बजती है।';

  @override
  String get eventDefaultsFakeCallDeclineIsSafeInfo =>
      'चालू होने पर, कॉल अस्वीकार करना सुरक्षित चेक-इन माना जाता है और चेन रीसेट हो जाती है। बंद होने पर, अस्वीकार करना चूक माना जाता है और कॉल फिर बज सकती है।';

  @override
  String get eventDefaultsSmsChannelInfo =>
      'इस चरण के लिए उपयोग किया जाने वाला मैसेजिंग ऐप: SMS, WhatsApp, Telegram या Signal। जो संपर्क चुना गया चैनल प्राप्त नहीं कर सकते, वे धूसर दिखते हैं।';

  @override
  String get smsContactRecipientsInfo =>
      'यह अलर्ट किसे मिलता है। संपर्क चुनने के लिए उन पर टैप करें — सभी को चुनने पर सूची गतिशील रहती है, और बाद में जोड़े गए संपर्क स्वतः शामिल हो जाते हैं।';

  @override
  String eventDefaultsSmsMessageTemplateInfo(Object name, Object location) {
    return 'अलर्ट संदेश का टेक्स्ट। $name और $location जैसे प्लेसहोल्डर संदेश भेजते समय असली मानों से भर दिए जाते हैं। अंतर्निहित अलर्ट उपयोग करने के लिए खाली छोड़ें।';
  }

  @override
  String get eventDefaultsSmsIncludeLocationInfo =>
      'संदेश में आपकी वर्तमान GPS स्थिति जोड़ता है, ताकि आपके संपर्क जानें कि आपको कहाँ खोजना है।';

  @override
  String get eventDefaultsSmsIncludeMedicalInfo =>
      'प्राथमिक उपचारकर्ताओं के लिए आपकी प्रोफ़ाइल की चिकित्सा जानकारी (जैसे रक्त समूह या एलर्जी) संदेश में जोड़ता है।';

  @override
  String get eventDefaultsSmsAutoRecordInfo =>
      'यह चरण सक्रिय होते ही स्वचालित रूप से ऑडियो रिकॉर्डिंग शुरू करता है, जिससे आपके आस-पास जो हो रहा है उसका प्रमाण सुरक्षित रहता है।';

  @override
  String get eventDefaultsSmsRecordDurationInfo =>
      'स्वचालित ऑडियो रिकॉर्डिंग कितने सेकंड चलती है।';

  @override
  String get eventDefaultsPhonePrimaryContactInfo =>
      'जिस संपर्क को पहले कॉल किया जाता है। अपने पहले आपातकालीन संपर्क को कॉल करने के लिए खाली छोड़ें। यदि वह न उठाए, तो विकल्प क्रम से आज़माए जाते हैं।';

  @override
  String get eventDefaultsLoudAlarmVolumeInfo =>
      'अलार्म कितनी तेज़ बजे, मौन (0) से डिवाइस के अधिकतम (1) तक। अलार्म का उद्देश्य आस-पास के लोगों का ध्यान खींचना है।';

  @override
  String get eventDefaultsLoudAlarmSoundInfo =>
      'अलार्म कौन-सी ध्वनि बजाए: अंतर्निहित सायरन या आपकी अपनी ध्वनि।';

  @override
  String get eventDefaultsLoudAlarmFlashScreenInfo =>
      'अलार्म बजते समय स्क्रीन चमकीले रंगों में चमकती है। डिफ़ॉल्ट रूप से बंद — चमक प्रकाश-संवेदनशील लोगों को प्रभावित कर सकती है।';

  @override
  String get eventDefaultsLoudAlarmFlashLightInfo =>
      'अलार्म बजते समय कैमरे की फ़्लैशलाइट चमकती है, जिससे अंधेरे में आपको खोजना आसान हो जाता है।';

  @override
  String get eventDefaultsLoudAlarmGradualInfo =>
      'पूरी आवाज़ से शुरू करने के बजाय वॉल्यूम को मौन से सेट स्तर तक बढ़ाता है।';

  @override
  String get eventDefaultsCallEmergencyNumberInfo =>
      'इस चरण द्वारा डायल किए जाने वाले आपातकालीन नंबर को बदलता है। ऐप-व्यापी नंबर (जैसे 112 या 911) उपयोग करने के लिए खाली छोड़ें।';

  @override
  String get eventDefaultsCallEmergencySmsFirstInfo =>
      'डायल करने से ठीक पहले आपके आपातकालीन संपर्कों को स्थान SMS भेजता है, ताकि कॉल न जुड़ने पर भी वे सूचित रहें।';

  @override
  String get eventDefaultsCallEmergencyConfirmInfo =>
      'डायल करने से पहले एक छोटी उलटी गिनती दिखाता है, जिससे गलती से हुई आपातकालीन कॉल रद्द करने का आख़िरी मौका मिलता है।';

  @override
  String get eventDefaultsCallEmergencyConfirmDurationInfo =>
      'आपातकालीन कॉल होने से पहले रद्द-करने की उलटी गिनती कितने सेकंड चलती है।';

  @override
  String get eventDefaultsHardwareButtonInfo =>
      'यह चरण पैनिक प्रेस के लिए किस भौतिक बटन (वॉल्यूम ऊपर या नीचे) पर नज़र रखता है।';

  @override
  String get eventDefaultsHardwarePatternInfo =>
      'चरण को सक्रिय करने वाला प्रेस पैटर्न: लगातार कई तेज़ प्रेस या एक लंबा प्रेस।';

  @override
  String get eventDefaultsHardwarePressCountInfo =>
      'लगातार कितने तेज़ प्रेस चाहिए। अधिक प्रेस से गलती से सक्रिय होने की संभावना घटती है।';

  @override
  String get eventDefaultsHardwareLongDurationInfo =>
      'चरण सक्रिय करने के लिए बटन कितनी देर दबाए रखना होगा।';

  @override
  String get eventPreviewCardLabel => 'पूर्वावलोकन';

  @override
  String eventPreviewFakeCallCaller(Object name) {
    return '$name से इनकमिंग कॉल';
  }

  @override
  String eventPreviewFakeCallRing(int seconds, Object style) {
    return '$seconds सेकंड बजती है · $style';
  }

  @override
  String get eventPreviewFakeCallDeclineSafe =>
      'अस्वीकार करना सुरक्षित चेक-इन माना जाता है।';

  @override
  String get eventPreviewFakeCallDeclineNotSafe =>
      'अस्वीकार करना चूक माना जाता है — कॉल फिर बज सकती है।';

  @override
  String eventPreviewSmsToAll(Object channel) {
    return 'सभी संपर्कों को · $channel';
  }

  @override
  String eventPreviewSmsToCount(num count, Object channel) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count संपर्कों को · $channel',
      one: '1 संपर्क को · $channel',
    );
    return '$_temp0';
  }

  @override
  String eventPreviewSmsToFirst(Object channel) {
    return 'आपके पहले संपर्क को · $channel';
  }

  @override
  String eventPreviewSmsMessage(Object gist) {
    return 'संदेश: $gist';
  }

  @override
  String eventPreviewLoudAlarmTitle(int percent, Object sound) {
    return 'वॉल्यूम $percent% · $sound';
  }

  @override
  String get eventPreviewLoudAlarmRampOn => 'वॉल्यूम धीरे-धीरे बढ़ता है।';

  @override
  String get eventPreviewLoudAlarmRampOff => 'पूरी आवाज़ से शुरू होता है।';

  @override
  String get eventPreviewLoudAlarmFlashScreen => 'स्क्रीन चमकती है';

  @override
  String get eventPreviewLoudAlarmFlashLight => 'कैमरा लाइट चमकती है';

  @override
  String get eventPreviewLoudAlarmNoFlash => 'कोई चमक नहीं';

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
  String get homeWidgetQuickExit => 'त्वरित निकास';

  @override
  String get homeWidgetFakeCall => 'नकली कॉल';

  @override
  String get settingsAlarmHeader => 'अलार्म';

  @override
  String get settingsAlarmDndOverrideLabel =>
      'अलार्म साइलेंट/वाइब्रेट मोड को ओवरराइड करता है';

  @override
  String get settingsAlarmDndOverrideWarning =>
      'चेतावनी: यदि आपका फ़ोन साइलेंट मोड पर है तो अलार्म मूक रहेगा।';

  @override
  String get settingsAlarmDndOverrideInfo =>
      'सक्षम होने पर, तेज़ अलार्म पूरी आवाज़ में बजता है, भले ही आपका फ़ोन साइलेंट या वाइब्रेट पर हो। Android पर यह डू नॉट डिस्टर्ब को दरकिनार करने के लिए अलार्म ऑडियो स्ट्रीम का उपयोग करता है। अलार्म एकमात्र ऐसी घटना है जो आपके फ़ोन की ध्वनि सेटिंग्स को ओवरराइड कर सकती है।';

  @override
  String get settingsAlarmGradualLabel => 'अलार्म की आवाज़ धीरे-धीरे बढ़ाएँ';

  @override
  String get settingsAlarmGradualInfo =>
      'अलार्म को धीमे से शुरू करता है और पूरी आवाज़ तक बढ़ाता है। यह पूरे ऐप का मुख्य स्विच है; प्रत्येक अलार्म चरण का अपना क्रमिक-आवाज़ विकल्प भी होता है, और बढ़ोतरी लागू होने के लिए दोनों चालू होने चाहिए।';

  @override
  String get settingsAlarmRampLabel => 'बढ़ने की अवधि';

  @override
  String get settingsAlarmRampInfo =>
      'अलार्म को शून्य से पूरी आवाज़ तक पहुँचने में कितना समय लगता है, इस अवधि में समान रूप से बढ़ते हुए। क्रमिक आवाज़ बंद होने पर इसका कोई प्रभाव नहीं पड़ता।';

  @override
  String get permissionNotifRationaleTitle => 'सूचनाएँ अनुमति दें?';

  @override
  String get permissionNotifRationaleBody =>
      'Guardian Angela सुरक्षा सत्र के दौरान आपको और आपके संपर्कों को सचेत करने के लिए सूचनाओं का उपयोग करता है, जिसमें छद्म रिमाइंडर शामिल हैं जो आपके लॉक फ़ोन को जगाते हैं। कृपया सूचनाओं की अनुमति दें ताकि ऐप आप तक पहुँच सके।';

  @override
  String get permissionNotifDeniedTitle => 'सूचनाएँ अवरुद्ध हैं';

  @override
  String get permissionNotifDeniedBody =>
      'Guardian Angela के लिए सूचनाएँ बंद हैं। सिस्टम सेटिंग्स खोलें और उन्हें वापस चालू करें ताकि ऐप सत्र के दौरान आपको सचेत कर सके।';

  @override
  String get permissionNotifAllow => 'अनुमति दें';

  @override
  String get permissionNotifOpenSettings => 'सेटिंग्स खोलें';

  @override
  String get permissionNotifNotNow => 'अभी नहीं';

  @override
  String get homeStartTriggersSummaryTitle => 'शुरू करने से पहले';

  @override
  String get homeStartTriggersDistressHeading => 'संकट ट्रिगर';

  @override
  String get homeStartTriggersDisarmHeading => 'स्वतः-समाप्ति ट्रिगर';

  @override
  String get homeStartTriggersNone => 'कोई कॉन्फ़िगर नहीं';

  @override
  String homeStartTriggerButtonRepeat(String button, String count) {
    return '$button को $count बार दबाएँ';
  }

  @override
  String homeStartTriggerButtonLong(String button, String seconds) {
    return '$button को $seconds सेकंड तक दबाए रखें';
  }

  @override
  String get homeStartTriggerButtonVolumeUp => 'वॉल्यूम बढ़ाएँ';

  @override
  String get homeStartTriggerButtonVolumeDown => 'वॉल्यूम घटाएँ';

  @override
  String homeStartTriggerGpsArrival(String radius) {
    return 'आपके गंतव्य के $radius मीटर के भीतर पहुँचने पर समाप्त होता है';
  }

  @override
  String get homeStartTriggerGpsPrompt =>
      'शुरू करने के बाद आपसे गंतव्य पूछा जाएगा';

  @override
  String homeStartTriggerTimer(String minutes) {
    return '$minutes मिनट बाद स्वतः समाप्त होता है';
  }

  @override
  String get homeStartTriggersContinue => 'अभी शुरू करें';

  @override
  String get homeStartTriggersCancel => 'रद्द करें';

  @override
  String get homeStartBlockedNotifTitle => 'सूचनाएँ आवश्यक हैं';

  @override
  String get homeStartBlockedNotifBody =>
      'यह मोड आपकी सुरक्षा के लिए सूचनाओं (छद्म रिमाइंडर या नकली कॉल) का उपयोग करता है, लेकिन सूचना अनुमति बंद है। इस मोड को शुरू करने के लिए सूचनाएँ सक्षम करें।';
}
