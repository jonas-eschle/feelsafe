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
  String get profileAngelaWarningTitle => 'नाम \"Angela\" के बारे में सावधानी';

  @override
  String get profileAngelaWarningBody =>
      'Guardian Angela \"Angela\" को सुरक्षा कीवर्ड के रूप में उपयोग करता है। इसे अपने नाम के रूप में उपयोग करना भ्रमित करने वाला हो सकता है। फिर भी सहेजें?';

  @override
  String get commonDelete => 'हटाएँ';

  @override
  String get commonEdit => 'संपादित करें';

  @override
  String get commonAdd => 'जोड़ें';

  @override
  String get commonClose => 'बंद करें';

  @override
  String get commonConfirm => 'पुष्टि करें';

  @override
  String get commonBack => 'वापस';

  @override
  String get commonDone => 'पूर्ण';

  @override
  String get commonRetry => 'पुनः प्रयास करें';

  @override
  String get commonYes => 'हाँ';

  @override
  String get commonNo => 'नहीं';

  @override
  String get commonEnabled => 'सक्षम';

  @override
  String get commonDisabled => 'अक्षम';

  @override
  String get commonNone => 'कोई नहीं';

  @override
  String get commonSeconds => 'सेकंड';

  @override
  String get commonMinutes => 'मिनट';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get pinSubmit => 'जमा करें';

  @override
  String get homeTitle => 'Guardian Angela';

  @override
  String get homeStartSession => 'सत्र आरंभ करें';

  @override
  String get homeStartConfirmTitle => 'सत्र आरंभ करें?';

  @override
  String get homeStartConfirmBody =>
      'सुनिश्चित करें कि आपके संपर्क और PIN कॉन्फ़िगर हैं। सत्र अग्रभूमि में चलेगा और आपका चुना हुआ मोड चेक-इन का मार्गदर्शन करेगा।';

  @override
  String get homeSimulate => 'सिमुलेट करें';

  @override
  String get homeActiveSession => 'सक्रिय सत्र';

  @override
  String get homeResumeSession => 'जारी रखें';

  @override
  String get homeNoModes =>
      'अभी तक कोई मोड नहीं। एक जोड़ने के लिए Modes पर टैप करें।';

  @override
  String get homeNoContacts =>
      'अभी तक कोई आपातकालीन संपर्क नहीं। एक जोड़ने के लिए Contacts पर टैप करें।';

  @override
  String get homeContactsBannerNone =>
      'कोई आपातकालीन संपर्क कॉन्फ़िगर नहीं है।';

  @override
  String homeContactsBannerFew(int count) {
    return '$count संपर्क कॉन्फ़िगर हैं। हम कम से कम 3 की सिफारिश करते हैं।';
  }

  @override
  String get homeMenuSettings => 'सेटिंग्स';

  @override
  String get homeMenuContacts => 'संपर्क';

  @override
  String get homeMenuModes => 'मोड';

  @override
  String get homeMenuHistory => 'पिछले सत्र';

  @override
  String get homeSelectMode => 'मोड चुनें';

  @override
  String get onboardingWelcomeTitle => 'Guardian Angela में आपका स्वागत है';

  @override
  String get onboardingWelcomeBody =>
      'एक साथी जो आपको घर के रास्ते में सुरक्षित रखता है। Guardian Angela आपके चलने, दौड़ने या यात्रा करने के दौरान आपकी देखभाल करता है, और ज़रूरत पड़ने पर आपके चुने हुए संपर्कों को सूचित कर सकता है।';

  @override
  String get onboardingProfileTitle => 'प्रोफ़ाइल और पहला संपर्क';

  @override
  String get onboardingProfileBody =>
      'अपने बारे में थोड़ा बताएँ ताकि आपातकाल में Guardian Angela मददगार जानकारी साझा कर सके। फिर एक भरोसेमंद संपर्क जोड़ें।';

  @override
  String get onboardingPermissionsTitle => 'अनुमतियाँ';

  @override
  String get onboardingPermissionsBody =>
      'आपको सुरक्षित रखने के लिए Guardian Angela को कुछ अनुमतियों की आवश्यकता है। इन्हें अभी दें या बाद में सेटिंग्स से।';

  @override
  String get onboardingNext => 'आगे';

  @override
  String get onboardingSkip => 'छोड़ें';

  @override
  String get onboardingFinish => 'समाप्त';

  @override
  String get sessionTitle => 'सत्र';

  @override
  String get sessionDisarm => 'मैं सुरक्षित हूँ';

  @override
  String get sessionPause => 'रोकें';

  @override
  String get sessionResume => 'जारी रखें';

  @override
  String get sessionHoldPrompt => 'सुरक्षित रहने के लिए दबाए रखें';

  @override
  String get sessionHoldSemantic =>
      'दबाए रखें। उंगली उठाने से छूट अवधि शुरू हो जाती है।';

  @override
  String sessionStepLabel(Object index, Object total) {
    return 'चरण $index / $total';
  }

  @override
  String sessionMissCount(Object count) {
    return 'छूटे: $count';
  }

  @override
  String sessionRemaining(Object seconds) {
    return '$seconds सेकंड शेष';
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
  String get sessionDisarmTriggerTitle => 'निरस्त्रीकरण ट्रिगर सक्रिय';

  @override
  String get sessionDisarmTriggerBody =>
      'एक निरस्त्रीकरण ट्रिगर सक्रिय हुआ। सत्र समाप्त करें?';

  @override
  String get sessionDisarmTriggerConfirm => 'सत्र समाप्त करें';

  @override
  String get sessionDisarmTriggerCancel => 'जारी रखें';

  @override
  String get wrongPinAngelaTitle => 'Angela से पुराना PIN';

  @override
  String get wrongPinAngelaBody =>
      'क्या आप वाकई इस पुराने PIN के साथ आगे बढ़ना चाहते हैं?';

  @override
  String get wrongPinAngelaConfirm => 'ठीक है';

  @override
  String get wrongPinAngelaCancel => 'रद्द करें';

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
  String get sessionStepSmsDelivered => 'वितरित';

  @override
  String get sessionStepSmsSent => 'भेजा गया';

  @override
  String get sessionStepSmsQueued => 'कतार में';

  @override
  String get sessionStepSmsFailed => 'विफल';

  @override
  String get sessionStepPhoneCallStatus =>
      'आपातकालीन संपर्क को कॉल किया जा रहा है…';

  @override
  String get sessionStepPhoneCallCancel => 'कॉल रद्द करें';

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
  String get fakeCallAnswer => 'उत्तर दें';

  @override
  String get fakeCallDecline => 'अस्वीकार करें';

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
  String get contactRequiredError => 'नाम और फ़ोन नंबर आवश्यक हैं।';

  @override
  String get modesTitle => 'मोड';

  @override
  String get modesEmpty =>
      'अभी तक कोई मोड नहीं। मोड बनाने के लिए Add पर टैप करें।';

  @override
  String get modesAdd => 'मोड जोड़ें';

  @override
  String get modeEditorTitleCreate => 'नया मोड';

  @override
  String get modeEditorTitleEdit => 'मोड संपादित करें';

  @override
  String get modeFieldName => 'नाम';

  @override
  String get modeFieldCheckInType => 'चेक-इन प्रकार';

  @override
  String get modeFieldDistressMode => 'संकट मोड';

  @override
  String get modeFieldDistressModeDefault => 'डिफ़ॉल्ट उपयोग करें';

  @override
  String get modeChainHeader => 'वृद्धि शृंखला';

  @override
  String get modeChainAddStep => 'चरण जोड़ें';

  @override
  String get modeChainEmpty => 'अभी तक कोई चरण नहीं। Add step पर टैप करें।';

  @override
  String get modeFieldIcon => 'आइकन';

  @override
  String get modeIconPickerTitle => 'आइकन चुनें';

  @override
  String get modeIconClear => 'कोई आइकन नहीं';

  @override
  String get modeDistressHeader => 'संकट ट्रिगर';

  @override
  String get modeDistressEmpty => 'कोई संकट ट्रिगर सेट नहीं है।';

  @override
  String get modeDistressAdd => 'ट्रिगर जोड़ें';

  @override
  String get modeDistressTypeHardware => 'हार्डवेयर बटन';

  @override
  String get modeDistressButtonType => 'बटन';

  @override
  String get modeDistressButtonVolumeUp => 'वॉल्यूम+';

  @override
  String get modeDistressButtonVolumeDown => 'वॉल्यूम−';

  @override
  String get modeDistressButtonPower => 'पावर';

  @override
  String get modeDistressPattern => 'पैटर्न';

  @override
  String get modeDistressPatternRepeat => 'बार-बार दबाना';

  @override
  String get modeDistressPatternLong => 'देर तक दबाना';

  @override
  String get modeDistressPressCount => 'दबाने की संख्या';

  @override
  String get modeDistressPressWindow => 'विंडो (मि.से.)';

  @override
  String get modeDistressLongDuration => 'दबाए रखने की अवधि (सेकंड)';

  @override
  String modeDistressSummaryRepeat(Object count, Object windowMs) {
    return '$count बार / $windowMs मि.से.';
  }

  @override
  String modeDistressSummaryLong(Object seconds) {
    return '$secondsसे. दबाएं';
  }

  @override
  String get modeOverridesHeader => 'मोड ओवरराइड';

  @override
  String get modeOverridesUseDefault => 'ऐप डिफ़ॉल्ट का उपयोग करें';

  @override
  String get modeOverridesGpsLabel => 'GPS लॉगिंग';

  @override
  String get modeOverridesStealthLabel => 'स्टेल्थ';

  @override
  String get modeOverridesEventDefaultsLabel => 'इवेंट डिफ़ॉल्ट';

  @override
  String get modeOverridesLocalTemplatesLabel => 'स्थानीय रिमाइंडर टेम्पलेट';

  @override
  String get modeOverridesGpsEnabled => 'GPS लॉगिंग सक्षम';

  @override
  String get modeOverridesGpsIntervalLabel => 'नमूना अंतराल (सेकंड)';

  @override
  String get modeOverridesGpsIncludeInSms => 'SMS में स्थान जोड़ें';

  @override
  String get modeOverridesStealthEnabled => 'स्टेल्थ सक्षम';

  @override
  String get modeOverridesStealthFakeName => 'नकली ऐप नाम';

  @override
  String get modeOverridesEventDefaultsHint =>
      'इस मोड के लिए कस्टम इवेंट डिफ़ॉल्ट सक्रिय।';

  @override
  String modeOverridesLocalTemplatesCount(Object count) {
    return '$count मोड-स्थानीय टेम्पलेट';
  }

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
  String get stepDuplicate => 'चरण की डुप्लिकेट बनाएं';

  @override
  String get stepTimingHeader => 'समय';

  @override
  String stepTimingSummary(Object wait, Object duration, Object grace) {
    return 'प्रतीक्षा $waitसे / अवधि $durationसे / छूट $graceसे';
  }

  @override
  String get stepCategoryAll => 'सभी';

  @override
  String get stepPickerMore => 'और विकल्प...';

  @override
  String get stepCategoryAction => 'क्रिया';

  @override
  String get stepCategoryReminder => 'रिमाइंडर';

  @override
  String get stepCategoryDisarm => 'चेक-इन';

  @override
  String get modeTrackingHeader => 'GPS ट्रैकिंग';

  @override
  String get modeTrackingEnabled => 'सत्र के दौरान GPS रिकॉर्ड करें';

  @override
  String get modeTrackingIntervalLabel => 'नमूना अंतराल';

  @override
  String get modeTrackingBufferSizeLabel => 'बफर आकार';

  @override
  String modeTrackingBufferSizeValue(Object count) {
    return '$count बिंदु';
  }

  @override
  String get modeTrackingBatteryNote =>
      'बार-बार GPS ट्रैकिंग बैटरी की खपत बढ़ाती है।';

  @override
  String get stepConfigLogGpsLabel => 'GPS लॉगिंग';

  @override
  String get stepConfigLogGpsDefault => 'डिफ़ॉल्ट';

  @override
  String get stepConfigLogGpsOn => 'चालू';

  @override
  String get stepConfigLogGpsOff => 'बंद';

  @override
  String get stepConfigLogGpsDefaultOn => 'डिफ़ॉल्ट (चालू)';

  @override
  String get stepConfigLogGpsDefaultOff => 'डिफ़ॉल्ट (बंद)';

  @override
  String get moreSettingsHeader => 'अधिक सेटिंग्स';

  @override
  String moreSettingsHeaderCustomized(int count) {
    return 'अधिक सेटिंग्स ($count अनुकूलित)';
  }

  @override
  String get stepTypePickerLabel => 'चरण प्रकार';

  @override
  String get stepTypeHoldButton => 'बटन दबाए रखें';

  @override
  String get stepTypeDisguisedReminder => 'छुपा हुआ अनुस्मारक';

  @override
  String get stepTypeCountdownWarning => 'उलटी गिनती चेतावनी';

  @override
  String get stepTypeFakeCall => 'नकली कॉल';

  @override
  String get stepTypeSmsContact => 'SMS संपर्क';

  @override
  String get stepTypePhoneCallContact => 'फ़ोन संपर्क';

  @override
  String get stepTypeLoudAlarm => 'तेज़ अलार्म';

  @override
  String get stepTypeCallEmergency => 'आपातकाल कॉल करें';

  @override
  String get stepTypeHardwareButton => 'हार्डवेयर बटन';

  @override
  String get stepFieldDuration => 'अवधि (सेकंड)';

  @override
  String get stepFieldGrace => 'छूट अवधि (सेकंड)';

  @override
  String get stepFieldWait => 'प्रतीक्षा (सेकंड)';

  @override
  String get stepFieldRetryCount => 'पुनः प्रयासों की संख्या';

  @override
  String get stepFieldRandomize => 'समय में भिन्नता';

  @override
  String get stepFieldRandomizeToggle => 'समय यादृच्छिक करें (±20%)';

  @override
  String get stepFieldWaitTooltip =>
      'इस चरण के शुरू होने से पहले कितना समय प्रतीक्षा करें।';

  @override
  String get stepFieldDurationTooltip =>
      'छूट अवधि शुरू होने से पहले चरण कितना समय सक्रिय रहता है।';

  @override
  String get stepFieldGraceTooltip =>
      'अगला चरण शुरू होने से पहले सुरक्षा की पुष्टि के लिए सक्रिय चरण के बाद का समय।';

  @override
  String get stepFieldRetryCountTooltip =>
      'वृद्धि से पहले इस चरण को कितनी बार दोहराना है।';

  @override
  String get stepFieldReminderIntervalTooltip =>
      'चेक-इन की प्रतीक्षा करते समय छुपा अनुस्मारक कितनी बार सक्रिय होता है।';

  @override
  String get stepFieldReminderGraceTooltip =>
      'अनुस्मारक प्रकट होने के बाद उपयोगकर्ता को सुरक्षा की पुष्टि के लिए कितना समय मिलता है।';

  @override
  String get stepPreview => 'सिमुलेशन में पूर्वावलोकन';

  @override
  String stepPreviewFired(Object description) {
    return 'पूर्वावलोकन चला: $description';
  }

  @override
  String get stepPreviewTitle => 'चरण पूर्वावलोकन';

  @override
  String get stepPreviewMissingParams => 'चरण या मोड का संदर्भ अनुपस्थित है।';

  @override
  String get stepPreviewModeNotFound => 'मोड नहीं मिला।';

  @override
  String get stepPreviewStepNotFound => 'इस मोड में चरण नहीं मिला।';

  @override
  String stepPreviewError(Object error) {
    return 'पूर्वावलोकन विफल: $error';
  }

  @override
  String get stepPreviewReplay => 'फिर चलाएँ';

  @override
  String get stepPreviewHoldButtonHint =>
      'वास्तविक प्रतिक्रिया महसूस करने के लिए बटन को दबाए रखें।';

  @override
  String get stepPreviewHoldButtonLabel => 'दबाए रखें';

  @override
  String get stepPreviewHoldButtonSemantic => 'पूर्वावलोकन के लिए दबाए रखें';

  @override
  String get stepPreviewHoldButtonReleased =>
      'छोड़ दिया। सत्र अब रियायती अवधि में प्रवेश करेगा।';

  @override
  String get stepPreviewFakeCallHint =>
      'नकली कॉल स्क्रीन दिखाई देगी। उत्तर देने के लिए स्लाइड करें या संकट का अनुकरण करने के लिए लाल बटन दबाए रखें।';

  @override
  String get stepConfigFakeCallCaller => 'कॉलर का नाम';

  @override
  String get stepConfigFakeCallDecline => 'अस्वीकार करना निरस्त्रीकरण माना जाए';

  @override
  String get stepConfigLoudAlarmFlash => 'स्क्रीन चमकाएँ';

  @override
  String get stepConfigLoudAlarmVolume => 'अधिकतम ध्वनि';

  @override
  String get stepConfigCountdownVibrate => 'कंपन';

  @override
  String get stepConfigCountdownTone => 'ध्वनि बजाएँ';

  @override
  String get stepConfigSmsSelection => 'प्राप्तकर्ता';

  @override
  String get stepConfigSmsAllContacts => 'सभी संपर्क';

  @override
  String get stepConfigSmsSpecific => 'विशिष्ट संपर्क';

  @override
  String get stepConfigSmsIncludeLocation => 'स्थान शामिल करें';

  @override
  String get stepConfigSmsIncludeMedical => 'चिकित्सीय जानकारी शामिल करें';

  @override
  String get stepConfigSmsAutoRecordAudio => 'ऑडियो स्वतः रिकॉर्ड करें';

  @override
  String get stepConfigSmsAutoRecordVideo => 'वीडियो स्वतः रिकॉर्ड करें';

  @override
  String get stepConfigSmsRecordDuration => 'रिकॉर्डिंग अवधि';

  @override
  String get stepConfigHoldReleaseSensitivity => 'रिलीज़ संवेदनशीलता (से.)';

  @override
  String get stepConfigReminderInterval => 'अनुस्मारक अंतराल (सेकंड)';

  @override
  String get stepConfigReminderTemplate => 'टेम्पलेट';

  @override
  String get stepConfigHardwarePattern => 'पैटर्न';

  @override
  String get stepConfigHardwarePressCount => 'दबाने की संख्या';

  @override
  String get stepConfigHardwarePressWindow => 'दबाने का अंतराल (मि.से.)';

  @override
  String get stepConfigHardwareLongDuration => 'लंबे दबाव की अवधि (से.)';

  @override
  String get stepConfigHardwareButton => 'बटन';

  @override
  String get stepConfigHardwareButtonVolumeUp => 'वॉल्यूम बढ़ाएँ';

  @override
  String get stepConfigHardwareButtonVolumeDown => 'वॉल्यूम घटाएँ';

  @override
  String get stepConfigHardwareButtonPower => 'पावर';

  @override
  String get stepConfigHardwarePatternRepeat => 'बार-बार दबाएँ';

  @override
  String get stepConfigHardwarePatternLong => 'लंबा दबाव';

  @override
  String get stepConfigEmergencyNumber => 'आपातकालीन नंबर अधिरोहण';

  @override
  String get stepConfigEmergencyConfirm => 'कॉल से पहले पुष्टि करें';

  @override
  String get stepConfigPhonePreSms => 'कॉल से पहले SMS भेजें';

  @override
  String get distressModesTitle => 'संकट मोड';

  @override
  String get distressModeInUseTitle => 'संकट मोड उपयोग में है';

  @override
  String distressModeInUseBody(Object modes) {
    return 'यह संकट मोड अभी भी इनसे जुड़ा है: $modes। हटाने से पहले उन मोड को किसी अन्य संकट मोड से जोड़ें।';
  }

  @override
  String get distressModesEmpty => 'अभी तक कोई संकट मोड नहीं।';

  @override
  String get distressModesAdd => 'संकट मोड जोड़ें';

  @override
  String get distressModeEditorTitleCreate => 'नया संकट मोड';

  @override
  String get distressModeEditorTitleEdit => 'संकट मोड संपादित करें';

  @override
  String get distressModeName => 'संकट मोड का नाम';

  @override
  String get distressCountdown => 'संकट मोड शुरू हो रहा है...';

  @override
  String get distressCountdownStealth => 'कृपया प्रतीक्षा करें...';

  @override
  String get templatesTitle => 'अनुस्मारक टेम्पलेट';

  @override
  String get templatesEmpty => 'अभी तक कोई टेम्पलेट नहीं।';

  @override
  String get templatesAdd => 'टेम्पलेट जोड़ें';

  @override
  String get templateEditorTitleCreate => 'नया टेम्पलेट';

  @override
  String get templateEditorTitleEdit => 'टेम्पलेट संपादित करें';

  @override
  String get templateFieldName => 'संपादक नाम';

  @override
  String get templateFieldTitle => 'अनुस्मारक शीर्षक';

  @override
  String get templateFieldBody => 'अनुस्मारक विषय-वस्तु';

  @override
  String get templateFieldConfirmationType => 'पुष्टि प्रकार';

  @override
  String get templateFieldKeyword => 'कीवर्ड';

  @override
  String get templateFieldButtonLabel => 'बटन लेबल';

  @override
  String get templateFieldDisplayStyle => 'प्रदर्शन शैली';

  @override
  String get templateConfirmTapButton => 'बटन पर टैप करें';

  @override
  String get templateConfirmTapWord => 'शब्द पर टैप करें';

  @override
  String get templateConfirmSwipe => 'स्वाइप';

  @override
  String get templateConfirmDismiss => 'खारिज करें';

  @override
  String get templateDisplayFullscreen => 'पूर्ण स्क्रीन';

  @override
  String get templateDisplaySubtle => 'सूक्ष्म';

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
  String get profileFieldConditions => 'चिकित्सीय स्थितियाँ';

  @override
  String get profileFieldInstructions => 'आपातकालीन निर्देश';

  @override
  String get profileAddItem => 'आइटम जोड़ें';

  @override
  String get settingsTitle => 'सेटिंग्स';

  @override
  String get settingsSectionSecurity => 'सुरक्षा';

  @override
  String get settingsSectionStealth => 'गोपन';

  @override
  String get settingsSectionDefaults => 'डिफ़ॉल्ट';

  @override
  String get settingsSectionHistory => 'इतिहास';

  @override
  String get settingsSectionBackup => 'बैकअप';

  @override
  String get settingsSectionAbout => 'के बारे में';

  @override
  String get settingsSectionFeedback => 'प्रतिक्रिया';

  @override
  String get settingsSectionContacts => 'संपर्क';

  @override
  String get settingsSectionModes => 'मोड';

  @override
  String get settingsSectionProfile => 'प्रोफ़ाइल';

  @override
  String get settingsSectionDistressModes => 'संकट मोड';

  @override
  String get settingsSectionReminderTemplates => 'अनुस्मारक टेम्पलेट';

  @override
  String get settingsSectionBatteryAlert => 'बैटरी चेतावनी';

  @override
  String get settingsSectionEventDefaults => 'चरण डिफ़ॉल्ट';

  @override
  String get settingsSectionGpsLogging => 'GPS लॉगिंग';

  @override
  String get settingsSectionNotifications => 'सूचनाएँ';

  @override
  String get settingsSectionHistoryRetention => 'इतिहास रखरखाव';

  @override
  String get settingsSectionAppearance => 'रूपरंग';

  @override
  String get settingsThemeMode => 'थीम';

  @override
  String get settingsThemeLight => 'हल्का';

  @override
  String get settingsThemeDark => 'गहरा';

  @override
  String get settingsThemeSystem => 'सिस्टम';

  @override
  String get settingsLanguage => 'भाषा';

  @override
  String get settingsEmergencyNumber => 'आपातकालीन नंबर';

  @override
  String get settingsAlarmDnd => 'अलार्म Do Not Disturb को रद्द करे';

  @override
  String get securityTitle => 'सुरक्षा';

  @override
  String get securityAppPin => 'ऐप PIN';

  @override
  String get securitySessionEndPin => 'सत्र-समाप्ति PIN';

  @override
  String get securityDuressPin => 'दबाव PIN';

  @override
  String get securityAppPinBiometric =>
      'ऐप PIN के लिए बायोमेट्रिक्स का उपयोग करें';

  @override
  String get securitySessionEndPinBiometric =>
      'सत्र-समाप्ति PIN के लिए बायोमेट्रिक्स का उपयोग करें';

  @override
  String get securityDistressCancelBiometric =>
      'संकट रद्द करने के लिए बायोमेट्रिक्स का उपयोग करें';

  @override
  String get securityDuressTest => 'दबाव PIN का परीक्षण करें';

  @override
  String get securityDuressTestSubtitle =>
      'सत्यापित करें कि आपका दबाव PIN काम करता है।';

  @override
  String get securityPinTimeout => 'PIN टाइमआउट (सेकंड)';

  @override
  String get securityDisablePin => 'अक्षम करें';

  @override
  String get securitySetPin => 'PIN सेट करें';

  @override
  String get securityChangePin => 'PIN बदलें';

  @override
  String get pinSetupTitle => 'PIN सेट करें';

  @override
  String get pinSetupEnter => 'नया PIN दर्ज करें';

  @override
  String get pinSetupConfirm => 'PIN की पुष्टि करें';

  @override
  String get pinSetupMismatch => 'PIN मेल नहीं खाते। फिर से कोशिश करें।';

  @override
  String get pinEntryTitle => 'PIN दर्ज करें';

  @override
  String get pinEntrySubtitle => 'जारी रखने के लिए अपना PIN दर्ज करें।';

  @override
  String get pinEntryBiometricReason => 'जारी रखने के लिए प्रमाणित करें';

  @override
  String get stealthTitle => 'गोपन';

  @override
  String get stealthEnable => 'गोपन सक्षम करें';

  @override
  String get stealthFakeName => 'नकली ऐप नाम';

  @override
  String get stealthFakeIcon => 'नकली आइकन';

  @override
  String get stealthNotificationDisguise => 'सूचनाओं को छिपाएँ';

  @override
  String get stealthTimerDisplay => 'गोपन में टाइमर दिखाएँ';

  @override
  String get stealthTimerDisplayNormal => 'पूरा टेक्स्ट दिखाएँ';

  @override
  String get stealthTimerDisplaySmall => 'केवल संख्याएँ दिखाएँ';

  @override
  String get stealthTimerDisplayNone => 'टाइमर छिपाएँ';

  @override
  String get stealthSessionScreen => 'सत्र स्क्रीन से ब्रांडिंग हटाएँ';

  @override
  String get stealthPickerTitle => 'ऐप आइकन';

  @override
  String get stealthPickerIntro => 'चुनें कि लॉन्चर में आइकन कैसा दिखे।';

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
  String get distressConfirmationTitle => 'क्या आप ख़तरे में हैं?';

  @override
  String get distressConfirmationCancel => 'रद्द करें';

  @override
  String distressConfirmationCountdown(Object seconds) {
    return 'संकट मोड $seconds सेकंड में शुरू होगा';
  }

  @override
  String get imSafeSliderLabel =>
      '“मैं सुरक्षित हूँ” पुष्टि के लिए स्वाइप करें';

  @override
  String get batteryAlertTitle => 'बैटरी चेतावनी';

  @override
  String get batteryAlertEnable => 'बैटरी चेतावनी सक्षम करें';

  @override
  String batteryAlertThreshold(Object percent) {
    return 'सीमा: $percent%';
  }

  @override
  String get eventDefaultsTitle => 'चरण डिफ़ॉल्ट';

  @override
  String get eventDefaultsBody =>
      'ये डिफ़ॉल्ट उन सभी चरणों पर लागू होते हैं जो इन्हें अधिरोहण नहीं करते।';

  @override
  String get gpsLoggingTitle => 'GPS लॉगिंग';

  @override
  String get gpsLoggingEnable => 'GPS लॉगिंग सक्षम करें';

  @override
  String get gpsLoggingInterval => 'नमूना अंतराल (सेकंड)';

  @override
  String get gpsLoggingAccuracy => 'सटीकता';

  @override
  String get gpsAccuracyLow => 'कम';

  @override
  String get gpsAccuracyMedium => 'मध्यम';

  @override
  String get gpsAccuracyHigh => 'उच्च';

  @override
  String get gpsLoggingIncludeSms => 'SMS में स्थान जोड़ें';

  @override
  String get gpsLoggingHistoryDays => 'इतिहास रखरखाव (दिन)';

  @override
  String get notificationSettingsTitle => 'सूचनाएँ';

  @override
  String get notificationSettingsBody =>
      'Guardian Angela अनुस्मारकों को छुपाने और संचालित करने के लिए सूचनाओं का उपयोग करता है।';

  @override
  String get historyRetentionTitle => 'इतिहास रखरखाव';

  @override
  String get historyRetentionBody =>
      'Guardian Angela पिछले सत्र लॉग को कितने समय तक रखता है।';

  @override
  String historyRetentionDays(Object days) {
    return 'रखरखाव: $days दिन';
  }

  @override
  String get backupTitle => 'बैकअप';

  @override
  String get backupExport => 'डेटा निर्यात करें';

  @override
  String get backupImport => 'डेटा आयात करें';

  @override
  String get backupNotReady => 'बैकअप अभी उपलब्ध नहीं है। जल्द आ रहा है।';

  @override
  String get backupPinOptional => 'वैकल्पिक PIN (पैकेज को एन्क्रिप्ट करता है)';

  @override
  String get backupImportOk => 'बैकअप सफलतापूर्वक आयात किया गया।';

  @override
  String get backupSelectionHeader => 'निर्यात में शामिल करें';

  @override
  String get backupToggleSettings => 'सेटिंग्स';

  @override
  String get backupToggleSettingsSubtitle =>
      'हमेशा शामिल रहता है ताकि बैकअप पुनर्स्थापित किया जा सके।';

  @override
  String get backupToggleContacts => 'आपातकालीन संपर्क';

  @override
  String get backupToggleModes => 'मोड';

  @override
  String get backupToggleDistressModes => 'संकट मोड';

  @override
  String get backupToggleTemplates => 'रिमाइंडर टेम्पलेट';

  @override
  String get backupToggleSessionLogs => 'सत्र इतिहास';

  @override
  String get backupToggleRecordings => 'ऑडियो रिकॉर्डिंग';

  @override
  String get historyTitle => 'पिछले सत्र';

  @override
  String get historyEmpty => 'अभी तक कोई पिछला सत्र नहीं।';

  @override
  String get historyTabReal => 'वास्तविक';

  @override
  String get historyTabSimulated => 'सिम्युलेटेड';

  @override
  String get historySearchHint => 'मोड नाम से खोजें';

  @override
  String get historyFilterModeAll => 'सभी मोड';

  @override
  String get historyFilterModeLabel => 'मोड';

  @override
  String get historyDateRangePick => 'तिथि सीमा';

  @override
  String get historyDetailTitle => 'सत्र विवरण';

  @override
  String get evidenceExportTitle => 'साक्ष्य निर्यात करें';

  @override
  String get evidenceExportAsText => 'टेक्स्ट के रूप में कॉपी करें';

  @override
  String get evidenceExportAsJson => 'JSON के रूप में कॉपी करें';

  @override
  String get evidenceCopied => 'क्लिपबोर्ड पर कॉपी किया गया।';

  @override
  String get aboutTitle => 'के बारे में';

  @override
  String get aboutVersion => 'संस्करण';

  @override
  String get aboutCredits =>
      'घर के रास्ते में लोगों के लिए देखभाल के साथ निर्मित।';

  @override
  String get feedbackTitle => 'प्रतिक्रिया';

  @override
  String get feedbackBody => 'हम आपसे सुनना चाहेंगे।';

  @override
  String get feedbackFieldMessage => 'संदेश';

  @override
  String get feedbackSend => 'ईमेल खोलें';

  @override
  String get pickerNoneLabel => '— कोई नहीं —';

  @override
  String emergencyConfirmTitle(Object number) {
    return '$number पर कॉल किया जा रहा है';
  }

  @override
  String get emergencyConfirmSubtitle =>
      'रद्द करने के लिए कैंसल बटन को दबाए रखें।';

  @override
  String emergencyConfirmCountdown(Object seconds) {
    return '$seconds सेकंड में कॉल';
  }

  @override
  String get emergencyConfirmCancel => 'रद्द करें';

  @override
  String get stealthCalendarUpcoming => 'आगामी';

  @override
  String get stealthCalendarUpcomingEvent => 'मीटिंग';

  @override
  String stealthCalendarUntilEvent(Object minutes) {
    return '$minutes मिनट में';
  }

  @override
  String get stealthCalendarToday => 'आज';

  @override
  String get stealthCalendarEvent1 => 'Alex के साथ कॉफ़ी';

  @override
  String get stealthCalendarEvent2 => 'स्टैंडअप';

  @override
  String get stealthCalendarEvent3 => 'लंच';

  @override
  String get stealthCalendarEvent4 => 'वर्कआउट';

  @override
  String get stealthCalendarEvent5 => 'Sam के साथ डिनर';

  @override
  String get stealthDisarmGestureHint => 'समाप्त करने के लिए ऊपर स्वाइप करें';

  @override
  String get stealthMusicTrackTitle => 'बिना शीर्षक का ट्रैक';

  @override
  String get stealthMusicArtist => 'अज्ञात कलाकार';

  @override
  String get stealthMusicAlbum => 'अज्ञात एल्बम';

  @override
  String get stealthMusicNowPlaying => 'अभी चल रहा है';

  @override
  String get stealthMusicSwipeHint => 'निरस्त्र करने के लिए स्वाइप करें';

  @override
  String get stealthMusicPrevious => 'पिछला';

  @override
  String get stealthMusicPause => 'रोकें';

  @override
  String get stealthMusicNext => 'अगला';

  @override
  String get stealthPodcastShowName => 'पॉडकास्ट';

  @override
  String get stealthPodcastEpisodeTitle => 'एपिसोड';

  @override
  String get stealthPodcastEpisodesHeader => 'एपिसोड';

  @override
  String get stealthPodcastSpeedLabel => '1x';

  @override
  String get stealthPodcastEpisode1 => 'एपिसोड 1';

  @override
  String get stealthPodcastEpisode2 => 'एपिसोड 2';

  @override
  String get stealthPodcastEpisode3 => 'एपिसोड 3';

  @override
  String get stealthPodcastEpisode4 => 'एपिसोड 4';

  @override
  String get stealthPresetPodcast => 'पॉडकास्ट';

  @override
  String get stealthPresetNone => 'कोई नहीं';

  @override
  String get sessionSimSpeedLabel => 'गति';

  @override
  String sessionSimSpeedValue(Object value) {
    return '${value}x';
  }

  @override
  String get sessionSimSpeedBackgroundCap => 'पृष्ठभूमि में 60× पर सीमित';

  @override
  String get sessionSimAdvancedLabel => 'उन्नत';

  @override
  String get sessionSimTriggerPanic => 'पैनिक ट्रिगर करें';

  @override
  String get sessionSimTriggerArrival => 'आगमन ट्रिगर करें';

  @override
  String get sessionSimTriggerBattery => 'कम बैटरी ट्रिगर करें';

  @override
  String get simulateGpsArrival => 'आगमन सिमुलेट करें';

  @override
  String get simulateLowBattery => 'कम बैटरी सिमुलेट करें';

  @override
  String get launchGateTitle => 'Guardian Angela अनलॉक करें';

  @override
  String get launchGateSubtitle =>
      'अपना PIN दर्ज करें या बायोमेट्रिक्स का उपयोग करें।';

  @override
  String get launchGateWrong => 'गलत PIN';

  @override
  String get launchGateBiometricReason => 'Guardian Angela अनलॉक करें';

  @override
  String get launchGateUseBiometric => 'बायोमेट्रिक्स का उपयोग करें';

  @override
  String get audioRunningLatePhrase =>
      'नमस्ते, मुझे देर हो रही है। मैं जल्द ही वापस कॉल करूंगा।';

  @override
  String smsDefaultTemplate(Object name, Object location, Object time) {
    return '$name को मदद की ज़रूरत हो सकती है। स्थान: $location। समय: $time।';
  }

  @override
  String smsDefaultPreCallTemplate(Object name) {
    return '$name आपसे संपर्क करने की कोशिश कर रहे हैं। कॉल की प्रतीक्षा करें।';
  }

  @override
  String simLoudAlarm(Object tail) {
    return '[SIM] तेज़ अलार्म + $tail';
  }

  @override
  String get simLoudAlarmTailFlash => 'फ़्लैश';

  @override
  String get simLoudAlarmTailVibrate => 'वाइब्रेट';

  @override
  String simSmsContact(Object channel, int count) {
    return '[SIM] $channel से $count संपर्कों को भेजेगा';
  }

  @override
  String simFakeCallRing(Object caller) {
    return '[SIM] $caller से इनकमिंग कॉल';
  }

  @override
  String simCountdownWarning(int seconds) {
    return '[SIM] $seconds सेकंड की काउंटडाउन चेतावनी';
  }

  @override
  String simPhoneCall(Object name) {
    return '[SIM] $name को कॉल करेगा';
  }

  @override
  String get simNoContactToCall => '[SIM] कॉल करने के लिए कोई संपर्क नहीं';

  @override
  String simCallEmergency(Object number) {
    return '[SIM] $number डायल करेगा';
  }

  @override
  String get simHardwareButton => '[SIM] हार्डवेयर ट्रिगर सक्रिय';

  @override
  String get simHoldButton => '[SIM] होल्ड बटन की प्रतीक्षा';

  @override
  String simDisguisedReminder(Object title) {
    return '[SIM] \"$title\" दिखाएगा';
  }

  @override
  String get simDisguisedReminderEmpty =>
      '[SIM] कोई रिमाइंडर टेम्पलेट उपलब्ध नहीं';

  @override
  String get simGpsArrivalTrigger => '[SIM] GPS आगमन ट्रिगर सक्रिय';

  @override
  String get simLowBatteryAlert => '[SIM] कम बैटरी अलर्ट सक्रिय';
}
