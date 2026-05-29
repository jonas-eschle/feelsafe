// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Guardian Angela';

  @override
  String get commonSave => '保存';

  @override
  String get angelaDialogTitle => '已输入旧 PIN 码';

  @override
  String get angelaDialogBody => '您似乎使用了旧的 PIN 码。确定要继续吗？';

  @override
  String get angelaDialogCancel => '取消';

  @override
  String get angelaDialogConfirm => '继续';

  @override
  String get commonCancel => '取消';

  @override
  String get commonOk => '确定';

  @override
  String get commonDelete => '删除';

  @override
  String get commonEdit => '编辑';

  @override
  String get commonClose => '关闭';

  @override
  String get commonConfirm => '确认';

  @override
  String get commonBack => '返回';

  @override
  String get pinSubmit => '提交';

  @override
  String get homeTitle => 'Guardian Angela';

  @override
  String get homeStartSession => '开始会话';

  @override
  String get homePermissionsNotification => '通知';

  @override
  String get homePermissionsLocation => '位置';

  @override
  String get homePermissionsCallPhone => '电话呼叫';

  @override
  String get homePermissionsSendSms => '发送短信';

  @override
  String get homeSimulate => '模拟';

  @override
  String get homeNoModes => '尚无模式。点击“模式”添加一个。';

  @override
  String get homeContactsBannerNone => '尚未配置紧急联系人。';

  @override
  String get homeMenuSettings => '设置';

  @override
  String get homeMenuContacts => '联系人';

  @override
  String get homeMenuHistory => '历史会话';

  @override
  String get onboardingProfileTitle => '个人资料和首位联系人';

  @override
  String get onboardingPermissionsTitle => '权限';

  @override
  String get onboardingNext => '下一步';

  @override
  String get onboardingSkip => '跳过';

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
  String get sessionTitle => '会话';

  @override
  String get sessionDisarm => '我安全';

  @override
  String get sessionDisarmStealth => 'No Angela needed';

  @override
  String get homeChainSummaryTitle => 'Chain Summary';

  @override
  String get homeChainSummaryEmpty =>
      'This mode has no steps yet — tap the mode to edit.';

  @override
  String homeChainSummaryTimingTitle(Object name) {
    return 'Step: $name';
  }

  @override
  String homeChainSummaryWait(Object seconds) {
    return 'Wait: ${seconds}s';
  }

  @override
  String homeChainSummaryDuration(Object seconds) {
    return 'Active: ${seconds}s';
  }

  @override
  String homeChainSummaryGrace(Object seconds) {
    return 'Grace period: ${seconds}s';
  }

  @override
  String homeChainSummaryRetry(Object count) {
    return 'Retries: $count';
  }

  @override
  String homeChainSummaryNextStep(Object name) {
    return 'Next step: $name';
  }

  @override
  String get homeChainSummaryNextStepNone => 'Next step: end of chain';

  @override
  String get homeChainSummaryClose => 'Close';

  @override
  String get chainStepNameHoldButton => 'Hold to stay safe';

  @override
  String get chainStepNameDisguisedReminder => 'Disguised reminder';

  @override
  String get chainStepNameCountdownWarning => 'Countdown warning';

  @override
  String get chainStepNameFakeCall => 'Fake call';

  @override
  String get chainStepNameSmsContact => 'SMS contact';

  @override
  String get chainStepNamePhoneCallContact => 'Phone call contact';

  @override
  String get chainStepNameLoudAlarm => 'Loud alarm';

  @override
  String get chainStepNameCallEmergency => 'Emergency call';

  @override
  String get chainStepNameHardwareButton => 'Hardware button';

  @override
  String get homeChecklistTitle => 'Safety Setup';

  @override
  String get homeChecklistDismissTooltip => 'Dismiss checklist';

  @override
  String get homeChecklistExpandTooltip => 'Show checklist';

  @override
  String get homeChecklistCollapseTooltip => 'Hide checklist';

  @override
  String homeChecklistProgress(Object done, Object total) {
    return '$done of $total done';
  }

  @override
  String get homeChecklistAllDoneBanner => 'All set — you\'re protected!';

  @override
  String get homeChecklistInfoTooltip => 'Why this matters';

  @override
  String get homeChecklistGotIt => 'Got it';

  @override
  String get homeChecklistGoThere => 'Go there';

  @override
  String get homeChecklistItem1Title => 'Add an emergency contact';

  @override
  String get homeChecklistItem2Title => 'Set a session-end PIN';

  @override
  String get homeChecklistItem3Title => 'Configure stealth mode';

  @override
  String get homeChecklistItem4Title => 'Test a simulation';

  @override
  String get homeChecklistItem5Title => 'Customize a safety mode';

  @override
  String get homeChecklistItem6Title => 'Grant required permissions';

  @override
  String get checklistInfo1Body =>
      'Emergency contacts are the people Guardian Angela messages and calls when you fail to check in. Without at least one contact, the chain has nowhere to escalate.';

  @override
  String get checklistInfo2Body =>
      'A session-end PIN prevents an attacker from quietly ending an active session. They can still attempt it, but typing the wrong PIN five times silently fires your distress chain.';

  @override
  String get checklistInfo3Body =>
      'Stealth mode disguises the active session as something innocuous on your screen — a music player, a paused timer, a blank lock screen. Use it when somebody nearby cannot see you running a safety app.';

  @override
  String get checklistInfo4Body =>
      'Simulation runs your safety mode end-to-end without sending real SMS, placing real calls, or sounding the loud alarm. Use it to learn the timings before you ever need them.';

  @override
  String get checklistInfo5Body =>
      'Custom modes let you tune the steps, timings, and triggers to a specific situation — walking home, a first date, a late shift. The two seed modes are starting points, not the destination.';

  @override
  String get checklistInfo6Body =>
      'Without notification permission, Guardian Angela cannot keep its persistent foreground status, deliver disguised reminders, or warn you that the chain is about to escalate.';

  @override
  String get checklistTutorial3Body =>
      'Open the stealth defaults and toggle \'Enable stealth mode\'. From there you can pick a fake music brand, hide the session timer, or disguise the home-screen icon.';

  @override
  String get checklistTutorial4Body =>
      'Tap the outlined \'Simulate\' button on the home screen after selecting a mode. The session runs with an orange border and the [SIM] badge — nothing leaves your phone.';

  @override
  String get checklistTutorial5Body =>
      'Open the Modes screen and either edit a seed mode (Walk / Date) or create a new one from scratch. Tweak the chain, add a fake call, set custom timings.';

  @override
  String get sessionHoldPrompt => '按住以保持安全';

  @override
  String sessionStepLabel(Object index, Object total) {
    return '第 $index 步，共 $total 步';
  }

  @override
  String sessionMissCount(Object count) {
    return '错过次数：$count';
  }

  @override
  String get sessionPausedBadge => '已暂停';

  @override
  String get sessionPhaseEnded => '会话已结束';

  @override
  String get sessionSimulationBanner => '模拟';

  @override
  String get sessionCheckIn => '我已签到';

  @override
  String get sessionStepCountdownTitle => '警告';

  @override
  String get sessionStepCountdownBody => '倒计时结束后将触发下一次升级。在下方滑动“我安全”以解除。';

  @override
  String get sessionStepDisguisedDefaultTitle => '提醒';

  @override
  String get sessionStepDisguisedDefaultBody => '点击“我已签到”以确认安全。';

  @override
  String get sessionStepSmsStatus => '正在向联系人发送消息……';

  @override
  String get sessionStepPhoneCallStatus => '正在呼叫紧急联系人……';

  @override
  String get sessionStepLoudAlarmTitle => '警报响起中';

  @override
  String get sessionStepLoudAlarmBody => '警报正在响起以引起他人注意。';

  @override
  String get sessionStepLoudAlarmFlashWarning => '光敏警告：屏幕将闪烁。';

  @override
  String get sessionStepCallEmergencyStatus => '正在呼叫紧急服务……';

  @override
  String sessionStepCallEmergencyNumber(Object number) {
    return '号码：$number';
  }

  @override
  String sessionStepHardwareButtonRepeat(
    Object button,
    Object count,
    Object windowMs,
  ) {
    return '在 $windowMs 毫秒内按 $button $count 次';
  }

  @override
  String sessionStepHardwareButtonLong(Object button, Object seconds) {
    return '按住 $button $seconds 秒';
  }

  @override
  String get sessionStepHardwareButtonVolumeUp => '音量加键';

  @override
  String get sessionStepHardwareButtonVolumeDown => '音量减键';

  @override
  String get sessionStepHardwareButtonPower => '电源键';

  @override
  String get sessionCompletedTitle => '会话已完成';

  @override
  String get sessionCompletedBody => '您已安全到达。Guardian Angela 正在撤防。';

  @override
  String get sessionCompletedReturnHome => '返回主页';

  @override
  String get simulationSummaryTitle => '模拟摘要';

  @override
  String get simulationSummaryEmpty => '本次模拟未触发任何步骤。';

  @override
  String get simulationSummaryReturn => '返回主页';

  @override
  String get fakeCallTitle => '来电';

  @override
  String get fakeCallHangUp => '挂断';

  @override
  String get fakeCallSlideToAnswer => '滑动以接听';

  @override
  String get fakeCallUnknownCaller => '未知';

  @override
  String get fakeCallIncomingWhatsapp => 'WhatsApp 语音通话';

  @override
  String get fakeCallIncomingTelegram => 'Telegram 语音通话';

  @override
  String get fakeCallIncomingSignal => 'Signal 语音通话';

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
  String get contactsTitle => '紧急联系人';

  @override
  String get contactsEmpty => '尚无联系人。添加一位以接收您的求救信息。';

  @override
  String get contactsAdd => '添加联系人';

  @override
  String get contactFormTitleCreate => '新建联系人';

  @override
  String get contactFormTitleEdit => '编辑联系人';

  @override
  String get contactFieldName => '姓名';

  @override
  String get contactFieldPhone => '电话号码';

  @override
  String get contactFieldRelationship => '关系（可选）';

  @override
  String get contactFieldLanguage => '短信语言（可选）';

  @override
  String get contactLanguageDefault => '默认（使用应用语言）';

  @override
  String get contactChannelsHeader => '消息渠道';

  @override
  String get contactChannelSms => '短信';

  @override
  String get contactChannelWhatsapp => 'WhatsApp';

  @override
  String get contactChannelTelegram => 'Telegram';

  @override
  String get contactChannelPhone => '电话呼叫';

  @override
  String get contactDeleteConfirm => '删除联系人？';

  @override
  String contactDeleteBody(Object name) {
    return '$name 将从您的紧急联系人列表中移除。';
  }

  @override
  String get contactFormIosSmsWarning =>
      'On iOS, SMS opens the Messages app. You must tap Send manually.';

  @override
  String get modesTitle => '模式';

  @override
  String get modesEmpty => '尚无模式。点击“添加”创建一个模式。';

  @override
  String get modesAdd => '添加模式';

  @override
  String get modesNewPickerBlank => '空白模式';

  @override
  String get modesNewPickerBlankSubtitle => '从一个空的链开始';

  @override
  String modesNewPickerFromTemplate(String name) {
    return '基于“$name”';
  }

  @override
  String get modesNewPickerFromTemplateSubtitle => '复制此模式的链和触发器';

  @override
  String get modeEditorTitleCreate => '新建模式';

  @override
  String get modeEditorTitleEdit => '编辑模式';

  @override
  String get modeFieldName => '名称';

  @override
  String get modeChainHeader => '链';

  @override
  String get modeChainAddStep => '添加步骤';

  @override
  String get modeUnsavedTitle => '放弃更改?';

  @override
  String get modeUnsavedBody => '您有未保存的更改。放弃并离开编辑器?';

  @override
  String get modeUnsavedDiscard => '放弃';

  @override
  String get modeUnsavedKeep => '继续编辑';

  @override
  String stepTimingSummary(Object wait, Object duration, Object grace) {
    return '等待 $wait秒 / 时长 $duration秒 / 宽限 $grace秒';
  }

  @override
  String get distressModesEmpty => '尚无求救模式。';

  @override
  String get distressModeEditorTitleCreate => '新建求救模式';

  @override
  String get distressModeEditorTitleEdit => '编辑求救模式';

  @override
  String get templatesTitle => '提醒模板';

  @override
  String get templatesEmpty => '尚无模板。';

  @override
  String get profileTitle => '个人资料';

  @override
  String get profileFieldName => '姓名';

  @override
  String get profileFieldAge => '年龄';

  @override
  String get profileFieldBloodType => '血型';

  @override
  String get profileFieldAllergies => '过敏史';

  @override
  String get profileFieldMedications => '用药';

  @override
  String get settingsThemeLight => '浅色';

  @override
  String get settingsThemeDark => '深色';

  @override
  String get settingsThemeSystem => '跟随系统';

  @override
  String get settingsEmergencyNumberLabel => '紧急号码';

  @override
  String get settingsRedoOnboardingActiveSessionTooltip =>
      'Cannot redo onboarding during an active session';

  @override
  String get settingsEmergencyNumberCountryPickerTitle =>
      'Choose emergency number';

  @override
  String get settingsRedoOnboarding => '重新引导';

  @override
  String get settingsRedoOnboardingConfirm => '重新开始引导？';

  @override
  String get securitySessionEndPinBiometric => '为会话结束 PIN 码启用生物识别';

  @override
  String get securitySetPin => '设置 PIN 码';

  @override
  String get securityChangePin => '更改 PIN 码';

  @override
  String get pinSetupMismatch => '两次输入的 PIN 码不一致，请重试。';

  @override
  String get stealthTimerDisplayNormal => '显示完整文字';

  @override
  String get stealthTimerDisplaySmall => '仅显示数字';

  @override
  String get stealthTimerDisplayNone => '隐藏计时器';

  @override
  String get stealthPresetMusic => '音乐';

  @override
  String get stealthPresetCalendar => '日历';

  @override
  String get stealthPresetFitness => '健身';

  @override
  String get stealthPresetWeather => '天气';

  @override
  String get stealthPresetNews => '新闻';

  @override
  String get stealthPresetPhotos => '照片';

  @override
  String get stealthPresetNotes => '备忘录';

  @override
  String get stealthPresetClock => '时钟';

  @override
  String get batteryAlertTitle => '电量警报';

  @override
  String get eventDefaultsTitle => '步骤默认值';

  @override
  String get historyRetentionTitle => '历史保留';

  @override
  String get backupTitle => '备份';

  @override
  String get aboutTitle => '关于';

  @override
  String aboutVersion(Object version) {
    return '版本';
  }

  @override
  String get feedbackTitle => '反馈';

  @override
  String get feedbackSend => '打开邮箱';

  @override
  String get stealthPresetPodcast => '播客';

  @override
  String get stealthPresetNone => '无';

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

/// The translations for Chinese, as used in Taiwan (`zh_TW`).
class AppLocalizationsZhTw extends AppLocalizationsZh {
  AppLocalizationsZhTw() : super('zh_TW');

  @override
  String get appTitle => 'Guardian Angela';

  @override
  String get commonSave => '儲存';

  @override
  String get angelaDialogTitle => '已輸入舊 PIN';

  @override
  String get angelaDialogBody => '看起來你使用了舊的 PIN。確定要繼續嗎?';

  @override
  String get angelaDialogCancel => '取消';

  @override
  String get angelaDialogConfirm => '繼續';

  @override
  String get commonCancel => '取消';

  @override
  String get commonOk => '確定';

  @override
  String get commonDelete => '刪除';

  @override
  String get commonEdit => '編輯';

  @override
  String get commonClose => '關閉';

  @override
  String get commonConfirm => '確認';

  @override
  String get commonBack => '返回';

  @override
  String get pinSubmit => '送出';

  @override
  String get homeTitle => 'Guardian Angela';

  @override
  String get homeStartSession => '開始守護';

  @override
  String get homePermissionsNotification => '通知';

  @override
  String get homePermissionsLocation => '位置';

  @override
  String get homePermissionsCallPhone => '電話呼叫';

  @override
  String get homePermissionsSendSms => '傳送簡訊';

  @override
  String get homeSimulate => '模擬';

  @override
  String get homeNoModes => '尚未建立模式。點選「模式」新增一個。';

  @override
  String get homeContactsBannerNone => '尚未設定緊急聯絡人。';

  @override
  String get homeMenuSettings => '設定';

  @override
  String get homeMenuContacts => '聯絡人';

  @override
  String get homeMenuHistory => '過往紀錄';

  @override
  String get onboardingProfileTitle => '個人資料與首位聯絡人';

  @override
  String get onboardingPermissionsTitle => '權限';

  @override
  String get onboardingNext => '下一步';

  @override
  String get onboardingSkip => '略過';

  @override
  String get sessionTitle => '守護中';

  @override
  String get sessionDisarm => '我很安全';

  @override
  String get sessionHoldPrompt => '按住以保持安全';

  @override
  String sessionStepLabel(Object index, Object total) {
    return '步驟 $index / $total';
  }

  @override
  String sessionMissCount(Object count) {
    return '錯過次數:$count';
  }

  @override
  String get sessionPausedBadge => '已暫停';

  @override
  String get sessionPhaseEnded => '守護已結束';

  @override
  String get sessionSimulationBanner => '模擬';

  @override
  String get sessionCheckIn => '我已報平安';

  @override
  String get sessionStepCountdownTitle => '警告';

  @override
  String get sessionStepCountdownBody => '倒數結束時將觸發下一個升級步驟。請於下方滑動「我很安全」以解除。';

  @override
  String get sessionStepDisguisedDefaultTitle => '提醒';

  @override
  String get sessionStepDisguisedDefaultBody => '請點按「我已報平安」以確認你安全無虞。';

  @override
  String get sessionStepSmsStatus => '正在傳送訊息給聯絡人…';

  @override
  String get sessionStepPhoneCallStatus => '正在致電緊急聯絡人…';

  @override
  String get sessionStepLoudAlarmTitle => '警報播放中';

  @override
  String get sessionStepLoudAlarmBody => '警報正在發出聲響以引起注意。';

  @override
  String get sessionStepLoudAlarmFlashWarning => '光敏警告:螢幕將會閃爍。';

  @override
  String get sessionStepCallEmergencyStatus => '正在撥打緊急電話…';

  @override
  String sessionStepCallEmergencyNumber(Object number) {
    return '號碼:$number';
  }

  @override
  String sessionStepHardwareButtonRepeat(
    Object button,
    Object count,
    Object windowMs,
  ) {
    return '於 $windowMs 毫秒內按下$button $count 次';
  }

  @override
  String sessionStepHardwareButtonLong(Object button, Object seconds) {
    return '按住$button $seconds 秒';
  }

  @override
  String get sessionStepHardwareButtonVolumeUp => '音量增加鍵';

  @override
  String get sessionStepHardwareButtonVolumeDown => '音量減少鍵';

  @override
  String get sessionStepHardwareButtonPower => '電源鍵';

  @override
  String get sessionCompletedTitle => '守護完成';

  @override
  String get sessionCompletedBody => '你已平安抵達。Guardian Angela 即將停止守護。';

  @override
  String get sessionCompletedReturnHome => '返回首頁';

  @override
  String get simulationSummaryTitle => '模擬摘要';

  @override
  String get simulationSummaryEmpty => '本次模擬未觸發任何步驟。';

  @override
  String get simulationSummaryReturn => '返回首頁';

  @override
  String get fakeCallTitle => '來電中';

  @override
  String get fakeCallHangUp => '掛斷';

  @override
  String get fakeCallSlideToAnswer => '滑動以接聽';

  @override
  String get fakeCallUnknownCaller => '未知';

  @override
  String get fakeCallIncomingWhatsapp => 'WhatsApp 語音通話';

  @override
  String get fakeCallIncomingTelegram => 'Telegram 語音通話';

  @override
  String get fakeCallIncomingSignal => 'Signal 語音通話';

  @override
  String get fakeCallBrandWhatsapp => 'WHATSAPP';

  @override
  String get fakeCallBrandTelegram => 'TELEGRAM';

  @override
  String get fakeCallBrandSignal => 'SIGNAL';

  @override
  String get contactsTitle => '緊急聯絡人';

  @override
  String get contactsEmpty => '尚未新增聯絡人。請新增一位以便接收你的求救訊息。';

  @override
  String get contactsAdd => '新增聯絡人';

  @override
  String get contactFormTitleCreate => '新聯絡人';

  @override
  String get contactFormTitleEdit => '編輯聯絡人';

  @override
  String get contactFieldName => '姓名';

  @override
  String get contactFieldPhone => '電話號碼';

  @override
  String get contactFieldRelationship => '關係(選填)';

  @override
  String get contactFieldLanguage => '簡訊語言(選填)';

  @override
  String get contactLanguageDefault => '預設(使用應用程式語言)';

  @override
  String get contactChannelsHeader => '通訊管道';

  @override
  String get contactChannelSms => '簡訊';

  @override
  String get contactChannelWhatsapp => 'WhatsApp';

  @override
  String get contactChannelTelegram => 'Telegram';

  @override
  String get contactChannelPhone => '電話';

  @override
  String get contactDeleteConfirm => '刪除聯絡人?';

  @override
  String contactDeleteBody(Object name) {
    return '$name 將從你的緊急聯絡清單中移除。';
  }

  @override
  String get modesTitle => '模式';

  @override
  String get modesEmpty => '尚未建立模式。點選「新增」以建立模式。';

  @override
  String get modesAdd => '新增模式';

  @override
  String get modesNewPickerBlank => '空白模式';

  @override
  String get modesNewPickerBlankSubtitle => '從空的鏈開始';

  @override
  String modesNewPickerFromTemplate(String name) {
    return '以 $name 為範本';
  }

  @override
  String get modesNewPickerFromTemplateSubtitle => '複製此模式的鏈與觸發器';

  @override
  String get modeEditorTitleCreate => '新模式';

  @override
  String get modeEditorTitleEdit => '編輯模式';

  @override
  String get modeFieldName => '名稱';

  @override
  String get modeChainHeader => '鏈';

  @override
  String get modeChainAddStep => '新增步驟';

  @override
  String get modeUnsavedTitle => '捨棄變更?';

  @override
  String get modeUnsavedBody => '您有未儲存的變更。捨棄並離開編輯器?';

  @override
  String get modeUnsavedDiscard => '捨棄';

  @override
  String get modeUnsavedKeep => '繼續編輯';

  @override
  String stepTimingSummary(Object wait, Object duration, Object grace) {
    return '等待 $wait 秒 / 時長 $duration 秒 / 寬限 $grace 秒';
  }

  @override
  String get distressModesEmpty => '尚未建立求救模式。';

  @override
  String get distressModeEditorTitleCreate => '新求救模式';

  @override
  String get distressModeEditorTitleEdit => '編輯求救模式';

  @override
  String get templatesTitle => '提醒範本';

  @override
  String get templatesEmpty => '尚未建立範本。';

  @override
  String get profileTitle => '個人資料';

  @override
  String get profileFieldName => '姓名';

  @override
  String get profileFieldAge => '年齡';

  @override
  String get profileFieldBloodType => '血型';

  @override
  String get profileFieldAllergies => '過敏原';

  @override
  String get profileFieldMedications => '使用中藥物';

  @override
  String get settingsThemeLight => '淺色';

  @override
  String get settingsThemeDark => '深色';

  @override
  String get settingsThemeSystem => '跟隨系統';

  @override
  String get settingsEmergencyNumberLabel => '緊急號碼';

  @override
  String get settingsRedoOnboarding => '重新引導';

  @override
  String get settingsRedoOnboardingConfirm => '重新開始引導？';

  @override
  String get securitySessionEndPinBiometric => '使用生物辨識解鎖結束守護 PIN';

  @override
  String get securitySetPin => '設定 PIN';

  @override
  String get securityChangePin => '變更 PIN';

  @override
  String get pinSetupMismatch => '兩次輸入的 PIN 不一致,請重試。';

  @override
  String get stealthTimerDisplayNormal => '顯示完整文字';

  @override
  String get stealthTimerDisplaySmall => '僅顯示數字';

  @override
  String get stealthTimerDisplayNone => '隱藏計時器';

  @override
  String get stealthPresetMusic => '音樂';

  @override
  String get stealthPresetCalendar => '行事曆';

  @override
  String get stealthPresetFitness => '健身';

  @override
  String get stealthPresetWeather => '天氣';

  @override
  String get stealthPresetNews => '新聞';

  @override
  String get stealthPresetPhotos => '相片';

  @override
  String get stealthPresetNotes => '備忘錄';

  @override
  String get stealthPresetClock => '時鐘';

  @override
  String get batteryAlertTitle => '電量警示';

  @override
  String get eventDefaultsTitle => '步驟預設值';

  @override
  String get historyRetentionTitle => '紀錄保留';

  @override
  String get backupTitle => '備份';

  @override
  String get aboutTitle => '關於';

  @override
  String aboutVersion(Object version) {
    return '版本';
  }

  @override
  String get feedbackTitle => '意見回饋';

  @override
  String get feedbackSend => '開啟電子郵件';

  @override
  String get stealthPresetPodcast => 'Podcast';

  @override
  String get stealthPresetNone => '無';
}
