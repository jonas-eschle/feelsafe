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
  String get profileAngelaWarningTitle => '关于名称“Angela”的提示';

  @override
  String get profileAngelaWarningBody =>
      'Guardian Angela 将“Angela”用作安全关键词。把它作为您自己的姓名可能会造成混淆。仍要保存吗？';

  @override
  String get commonDelete => '删除';

  @override
  String get commonEdit => '编辑';

  @override
  String get commonAdd => '添加';

  @override
  String get commonClose => '关闭';

  @override
  String get commonConfirm => '确认';

  @override
  String get commonBack => '返回';

  @override
  String get commonDone => '完成';

  @override
  String get commonRetry => '重试';

  @override
  String get commonYes => '是';

  @override
  String get commonNo => '否';

  @override
  String get commonEnabled => '已启用';

  @override
  String get commonDisabled => '已禁用';

  @override
  String get commonNone => '无';

  @override
  String get commonSeconds => '秒';

  @override
  String get commonMinutes => '分钟';

  @override
  String get cancel => '取消';

  @override
  String get pinSubmit => '提交';

  @override
  String get homeTitle => 'Guardian Angela';

  @override
  String get homeStartSession => '开始会话';

  @override
  String get homeStartConfirmTitle => '开始一次会话？';

  @override
  String get homeStartConfirmBody => '请确认您的联系人和 PIN 码已配置。会话将在前台运行，所选模式将引导签到。';

  @override
  String get homeSimulate => '模拟';

  @override
  String get homeActiveSession => '活动会话';

  @override
  String get homeResumeSession => '继续';

  @override
  String get homeNoModes => '尚无模式。点击“模式”添加一个。';

  @override
  String get homeNoContacts => '尚无紧急联系人。点击“联系人”添加一个。';

  @override
  String get homeContactsBannerNone => '尚未配置紧急联系人。';

  @override
  String homeContactsBannerFew(int count) {
    return '已配置 $count 位联系人。建议至少 3 位。';
  }

  @override
  String get homeMenuSettings => '设置';

  @override
  String get homeMenuContacts => '联系人';

  @override
  String get homeMenuModes => '模式';

  @override
  String get homeMenuHistory => '历史会话';

  @override
  String get homeSelectMode => '选择模式';

  @override
  String get onboardingWelcomeTitle => '欢迎使用 Guardian Angela';

  @override
  String get onboardingWelcomeBody =>
      '一位守护您回家路上的伙伴。无论您步行、跑步还是出行，Guardian Angela 都会时刻守护着您，并可在您需要帮助时通知您选定的联系人。';

  @override
  String get onboardingProfileTitle => '个人资料和首位联系人';

  @override
  String get onboardingProfileBody =>
      '请告诉我们一些您的信息，以便在紧急情况下，Guardian Angela 能够提供有用的详情。然后，请添加一位可信赖的联系人。';

  @override
  String get onboardingPermissionsTitle => '权限';

  @override
  String get onboardingPermissionsBody =>
      'Guardian Angela 需要一些权限才能保护您的安全。您可现在授权，或稍后在“设置”中授权。';

  @override
  String get onboardingNext => '下一步';

  @override
  String get onboardingSkip => '跳过';

  @override
  String get onboardingFinish => '完成';

  @override
  String get sessionTitle => '会话';

  @override
  String get sessionDisarm => '我安全';

  @override
  String get sessionPause => '暂停';

  @override
  String get sessionResume => '继续';

  @override
  String get sessionHoldPrompt => '按住以保持安全';

  @override
  String get sessionHoldSemantic => '按住按钮。松开将开始宽限期。';

  @override
  String sessionStepLabel(Object index, Object total) {
    return '第 $index 步，共 $total 步';
  }

  @override
  String sessionMissCount(Object count) {
    return '错过次数：$count';
  }

  @override
  String sessionRemaining(Object seconds) {
    return '剩余 $seconds 秒';
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
  String get sessionDisarmTriggerTitle => '解除触发器已触发';

  @override
  String get sessionDisarmTriggerBody => '解除触发器已触发。结束会话吗？';

  @override
  String get sessionDisarmTriggerConfirm => '结束会话';

  @override
  String get sessionDisarmTriggerCancel => '继续';

  @override
  String get wrongPinAngelaTitle => 'Angela 的旧 PIN 码';

  @override
  String get wrongPinAngelaBody => '确定要使用此旧 PIN 码继续吗？';

  @override
  String get wrongPinAngelaConfirm => '确定';

  @override
  String get wrongPinAngelaCancel => '取消';

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
  String get sessionStepSmsDelivered => '已送达';

  @override
  String get sessionStepSmsSent => '已发送';

  @override
  String get sessionStepSmsQueued => '排队中';

  @override
  String get sessionStepSmsFailed => '失败';

  @override
  String get sessionStepPhoneCallStatus => '正在呼叫紧急联系人……';

  @override
  String get sessionStepPhoneCallCancel => '取消通话';

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
  String get fakeCallAnswer => '接听';

  @override
  String get fakeCallDecline => '拒接';

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
  String get contactRequiredError => '姓名和电话号码为必填项。';

  @override
  String get modesTitle => '模式';

  @override
  String get modesEmpty => '尚无模式。点击“添加”创建一个模式。';

  @override
  String get modesAdd => '添加模式';

  @override
  String get modeEditorTitleCreate => '新建模式';

  @override
  String get modeEditorTitleEdit => '编辑模式';

  @override
  String get modeFieldName => '名称';

  @override
  String get modeFieldCheckInType => '签到类型';

  @override
  String get modeFieldDistressMode => '求救模式';

  @override
  String get modeFieldDistressModeDefault => '使用默认';

  @override
  String get modeChainHeader => '升级链';

  @override
  String get modeChainAddStep => '添加步骤';

  @override
  String get modeChainEmpty => '尚无步骤。点击“添加步骤”。';

  @override
  String get modeFieldIcon => '图标';

  @override
  String get modeIconPickerTitle => '选择图标';

  @override
  String get modeIconClear => '无图标';

  @override
  String get modeDistressHeader => '求救触发器';

  @override
  String get modeDistressEmpty => '未配置求救触发器。';

  @override
  String get modeDistressAdd => '添加触发器';

  @override
  String get modeDistressTypeHardware => '硬件按键';

  @override
  String get modeDistressButtonType => '按键';

  @override
  String get modeDistressButtonVolumeUp => '音量上';

  @override
  String get modeDistressButtonVolumeDown => '音量下';

  @override
  String get modeDistressButtonPower => '电源';

  @override
  String get modeDistressPattern => '模式';

  @override
  String get modeDistressPatternRepeat => '重复按键';

  @override
  String get modeDistressPatternLong => '长按';

  @override
  String get modeDistressPressCount => '按键次数';

  @override
  String get modeDistressPressWindow => '窗口(毫秒)';

  @override
  String get modeDistressLongDuration => '按住时长(秒)';

  @override
  String modeDistressSummaryRepeat(Object count, Object windowMs) {
    return '$count次 / $windowMs毫秒';
  }

  @override
  String modeDistressSummaryLong(Object seconds) {
    return '按住$seconds秒';
  }

  @override
  String get modeOverridesHeader => '模式覆盖';

  @override
  String get modeOverridesUseDefault => '使用应用默认';

  @override
  String get modeOverridesGpsLabel => 'GPS 记录';

  @override
  String get modeOverridesStealthLabel => '隐身';

  @override
  String get modeOverridesEventDefaultsLabel => '事件默认值';

  @override
  String get modeOverridesLocalTemplatesLabel => '本地提醒模板';

  @override
  String get modeOverridesGpsEnabled => '启用 GPS 记录';

  @override
  String get modeOverridesGpsIntervalLabel => '采样间隔(秒)';

  @override
  String get modeOverridesGpsIncludeInSms => '在短信中附加位置';

  @override
  String get modeOverridesStealthEnabled => '启用隐身';

  @override
  String get modeOverridesStealthFakeName => '伪装应用名称';

  @override
  String get modeOverridesEventDefaultsHint => '此模式启用了自定义事件默认值。';

  @override
  String modeOverridesLocalTemplatesCount(Object count) {
    return '$count 个本地模板';
  }

  @override
  String get modeUnsavedTitle => '放弃更改?';

  @override
  String get modeUnsavedBody => '您有未保存的更改。放弃并离开编辑器?';

  @override
  String get modeUnsavedDiscard => '放弃';

  @override
  String get modeUnsavedKeep => '继续编辑';

  @override
  String get stepDuplicate => '复制步骤';

  @override
  String get stepTimingHeader => '时间';

  @override
  String stepTimingSummary(Object wait, Object duration, Object grace) {
    return '等待 $wait秒 / 时长 $duration秒 / 宽限 $grace秒';
  }

  @override
  String get stepCategoryAll => '全部';

  @override
  String get stepPickerMore => '更多选项...';

  @override
  String get stepCategoryAction => '动作';

  @override
  String get stepCategoryReminder => '提醒';

  @override
  String get stepCategoryDisarm => '签到';

  @override
  String get modeTrackingHeader => 'GPS 追踪';

  @override
  String get modeTrackingEnabled => '会话期间记录 GPS';

  @override
  String get modeTrackingIntervalLabel => '采样间隔';

  @override
  String get modeTrackingBufferSizeLabel => '缓冲区大小';

  @override
  String modeTrackingBufferSizeValue(Object count) {
    return '$count 个点';
  }

  @override
  String get modeTrackingBatteryNote => '频繁的 GPS 追踪会增加电池消耗。';

  @override
  String get stepConfigLogGpsLabel => 'GPS 记录';

  @override
  String get stepConfigLogGpsDefault => '默认';

  @override
  String get stepConfigLogGpsOn => '开启';

  @override
  String get stepConfigLogGpsOff => '关闭';

  @override
  String get stepConfigLogGpsDefaultOn => '默认（开启）';

  @override
  String get stepConfigLogGpsDefaultOff => '默认（关闭）';

  @override
  String get moreSettingsHeader => '更多设置';

  @override
  String moreSettingsHeaderCustomized(int count) {
    return '更多设置（已自定义 $count 项）';
  }

  @override
  String get stepTypePickerLabel => '步骤类型';

  @override
  String get stepTypeHoldButton => '按住按钮';

  @override
  String get stepTypeDisguisedReminder => '伪装提醒';

  @override
  String get stepTypeCountdownWarning => '倒计时警告';

  @override
  String get stepTypeFakeCall => '伪装来电';

  @override
  String get stepTypeSmsContact => '短信联系人';

  @override
  String get stepTypePhoneCallContact => '电话联系人';

  @override
  String get stepTypeLoudAlarm => '响亮警报';

  @override
  String get stepTypeCallEmergency => '呼叫紧急电话';

  @override
  String get stepTypeHardwareButton => '硬件按键';

  @override
  String get stepFieldDuration => '持续时间（秒）';

  @override
  String get stepFieldGrace => '宽限期（秒）';

  @override
  String get stepFieldWait => '等待（秒）';

  @override
  String get stepFieldRetryCount => '重试次数';

  @override
  String get stepFieldRandomize => '时间抖动';

  @override
  String get stepFieldRandomizeToggle => '随机化时间（±20%）';

  @override
  String get stepFieldWaitTooltip => '此步骤开始前等待多长时间。';

  @override
  String get stepFieldDurationTooltip => '此步骤在宽限期开始前活跃多长时间。';

  @override
  String get stepFieldGraceTooltip => '在下一步骤启动前确认安全的活动阶段后时间。';

  @override
  String get stepFieldRetryCountTooltip => '升级前重复此步骤多少次。';

  @override
  String get stepFieldReminderIntervalTooltip => '在等待签到时伪装提醒触发的频率。';

  @override
  String get stepFieldReminderGraceTooltip => '提醒出现后用户确认安全的时间。';

  @override
  String get stepPreview => '在模拟中预览';

  @override
  String stepPreviewFired(Object description) {
    return '已运行预览：$description';
  }

  @override
  String get stepPreviewTitle => '步骤预览';

  @override
  String get stepPreviewMissingParams => '缺少步骤或模式引用。';

  @override
  String get stepPreviewModeNotFound => '未找到该模式。';

  @override
  String get stepPreviewStepNotFound => '在该模式中未找到此步骤。';

  @override
  String stepPreviewError(Object error) {
    return '预览失败：$error';
  }

  @override
  String get stepPreviewReplay => '重新播放';

  @override
  String get stepPreviewHoldButtonHint => '按住按钮以感受真实响应。';

  @override
  String get stepPreviewHoldButtonLabel => '按住';

  @override
  String get stepPreviewHoldButtonSemantic => '按住以预览';

  @override
  String get stepPreviewHoldButtonReleased => '已松开。会话现在将进入宽限窗口。';

  @override
  String get stepPreviewFakeCallHint => '将出现伪装来电界面。滑动接听或按住红色按钮以模拟求助。';

  @override
  String get stepConfigFakeCallCaller => '来电者姓名';

  @override
  String get stepConfigFakeCallDecline => '拒接视为撤防';

  @override
  String get stepConfigLoudAlarmFlash => '屏幕闪烁';

  @override
  String get stepConfigLoudAlarmVolume => '最大音量';

  @override
  String get stepConfigCountdownVibrate => '振动';

  @override
  String get stepConfigCountdownTone => '播放提示音';

  @override
  String get stepConfigSmsSelection => '收件人';

  @override
  String get stepConfigSmsAllContacts => '所有联系人';

  @override
  String get stepConfigSmsSpecific => '指定联系人';

  @override
  String get stepConfigSmsIncludeLocation => '包含位置信息';

  @override
  String get stepConfigSmsIncludeMedical => '包含医疗信息';

  @override
  String get stepConfigSmsAutoRecordAudio => '自动录音';

  @override
  String get stepConfigSmsAutoRecordVideo => '自动录像';

  @override
  String get stepConfigSmsRecordDuration => '录制时长';

  @override
  String get stepConfigHoldReleaseSensitivity => '松开灵敏度（秒）';

  @override
  String get stepConfigReminderInterval => '提醒间隔（秒）';

  @override
  String get stepConfigReminderTemplate => '模板';

  @override
  String get stepConfigHardwarePattern => '模式';

  @override
  String get stepConfigHardwarePressCount => '按压次数';

  @override
  String get stepConfigHardwarePressWindow => '按压间隔（毫秒）';

  @override
  String get stepConfigHardwareLongDuration => '长按时长（秒）';

  @override
  String get stepConfigHardwareButton => '按键';

  @override
  String get stepConfigHardwareButtonVolumeUp => '音量加';

  @override
  String get stepConfigHardwareButtonVolumeDown => '音量减';

  @override
  String get stepConfigHardwareButtonPower => '电源键';

  @override
  String get stepConfigHardwarePatternRepeat => '重复按压';

  @override
  String get stepConfigHardwarePatternLong => '长按';

  @override
  String get stepConfigEmergencyNumber => '覆盖紧急号码';

  @override
  String get stepConfigEmergencyConfirm => '拨打前确认';

  @override
  String get stepConfigPhonePreSms => '拨打前发送短信';

  @override
  String get distressModesTitle => '求救模式';

  @override
  String get distressModeInUseTitle => '求救模式正在使用中';

  @override
  String distressModeInUseBody(Object modes) {
    return '此求救模式仍绑定到：$modes。请先将这些模式改绑到其他求救模式，再删除本模式。';
  }

  @override
  String get distressModesEmpty => '尚无求救模式。';

  @override
  String get distressModesAdd => '添加求救模式';

  @override
  String get distressModeEditorTitleCreate => '新建求救模式';

  @override
  String get distressModeEditorTitleEdit => '编辑求救模式';

  @override
  String get distressModeName => '求救模式名称';

  @override
  String get distressCountdown => '正在触发求救模式……';

  @override
  String get distressCountdownStealth => '请稍候……';

  @override
  String get templatesTitle => '提醒模板';

  @override
  String get templatesEmpty => '尚无模板。';

  @override
  String get templatesAdd => '添加模板';

  @override
  String get templateEditorTitleCreate => '新建模板';

  @override
  String get templateEditorTitleEdit => '编辑模板';

  @override
  String get templateFieldName => '编辑器名称';

  @override
  String get templateFieldTitle => '提醒标题';

  @override
  String get templateFieldBody => '提醒内容';

  @override
  String get templateFieldConfirmationType => '确认方式';

  @override
  String get templateFieldKeyword => '关键词';

  @override
  String get templateFieldButtonLabel => '按钮标签';

  @override
  String get templateFieldDisplayStyle => '显示样式';

  @override
  String get templateConfirmTapButton => '点击按钮';

  @override
  String get templateConfirmTapWord => '点击字词';

  @override
  String get templateConfirmSwipe => '滑动';

  @override
  String get templateConfirmDismiss => '忽略';

  @override
  String get templateDisplayFullscreen => '全屏';

  @override
  String get templateDisplaySubtle => '低调';

  @override
  String get profileTitle => '个人资料';

  @override
  String get profileFieldName => '姓名';

  @override
  String get profileFieldAge => '年龄';

  @override
  String get profileFieldPhoneNumber => '电话号码';

  @override
  String get profileFieldPhysicalDescription => '外貌描述';

  @override
  String get profileFieldBloodType => '血型';

  @override
  String get profileFieldAllergies => '过敏史';

  @override
  String get profileFieldMedications => '用药';

  @override
  String get profileFieldConditions => '病史';

  @override
  String get profileFieldInstructions => '紧急说明';

  @override
  String get profileAddItem => '添加项';

  @override
  String get settingsTitle => '设置';

  @override
  String get settingsSectionSecurity => '安全';

  @override
  String get settingsSectionStealth => '隐身';

  @override
  String get settingsSectionDefaults => '默认值';

  @override
  String get settingsSectionHistory => '历史记录';

  @override
  String get settingsSectionBackup => '备份';

  @override
  String get settingsSectionAbout => '关于';

  @override
  String get settingsSectionFeedback => '反馈';

  @override
  String get settingsSectionContacts => '联系人';

  @override
  String get settingsSectionModes => '模式';

  @override
  String get settingsSectionProfile => '个人资料';

  @override
  String get settingsSectionDistressModes => '求救模式';

  @override
  String get settingsSectionReminderTemplates => '提醒模板';

  @override
  String get settingsSectionBatteryAlert => '电量警报';

  @override
  String get settingsSectionEventDefaults => '步骤默认值';

  @override
  String get settingsSectionGpsLogging => 'GPS 记录';

  @override
  String get settingsSectionNotifications => '通知';

  @override
  String get settingsSectionHistoryRetention => '历史保留';

  @override
  String get settingsSectionAppearance => '外观';

  @override
  String get settingsThemeMode => '主题';

  @override
  String get settingsThemeLight => '浅色';

  @override
  String get settingsThemeDark => '深色';

  @override
  String get settingsThemeSystem => '跟随系统';

  @override
  String get settingsLanguage => '语言';

  @override
  String get settingsEmergencyNumber => '紧急电话号码';

  @override
  String get settingsAlarmDnd => '警报忽略勿扰模式';

  @override
  String get securityTitle => '安全';

  @override
  String get securityAppPin => '应用 PIN 码';

  @override
  String get securitySessionEndPin => '会话结束 PIN 码';

  @override
  String get securityDuressPin => '胁迫 PIN 码';

  @override
  String get securityAppPinBiometric => '为应用 PIN 码启用生物识别';

  @override
  String get securitySessionEndPinBiometric => '为会话结束 PIN 码启用生物识别';

  @override
  String get securityDistressCancelBiometric => '使用生物识别取消求救';

  @override
  String get securityDuressTest => '测试胁迫 PIN 码';

  @override
  String get securityDuressTestSubtitle => '验证您的胁迫 PIN 码是否正常。';

  @override
  String get securityPinTimeout => 'PIN 码超时（秒）';

  @override
  String get securityDisablePin => '禁用';

  @override
  String get securitySetPin => '设置 PIN 码';

  @override
  String get securityChangePin => '更改 PIN 码';

  @override
  String get pinSetupTitle => '设置 PIN 码';

  @override
  String get pinSetupEnter => '输入新 PIN 码';

  @override
  String get pinSetupConfirm => '确认 PIN 码';

  @override
  String get pinSetupMismatch => '两次输入的 PIN 码不一致，请重试。';

  @override
  String get pinEntryTitle => '输入 PIN 码';

  @override
  String get pinEntrySubtitle => '请输入您的 PIN 码以继续。';

  @override
  String get pinEntryBiometricReason => '请验证身份以继续';

  @override
  String get stealthTitle => '隐身';

  @override
  String get stealthEnable => '启用隐身';

  @override
  String get stealthFakeName => '伪装应用名称';

  @override
  String get stealthFakeIcon => '伪装图标';

  @override
  String get stealthNotificationDisguise => '伪装通知';

  @override
  String get stealthTimerDisplay => '在隐身模式下显示计时器';

  @override
  String get stealthTimerDisplayNormal => '显示完整文字';

  @override
  String get stealthTimerDisplaySmall => '仅显示数字';

  @override
  String get stealthTimerDisplayNone => '隐藏计时器';

  @override
  String get stealthSessionScreen => '隐藏会话界面品牌标识';

  @override
  String get stealthPickerTitle => '应用图标';

  @override
  String get stealthPickerIntro => '选择启动器中图标的外观。';

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
  String get distressConfirmationTitle => '你处于危险中吗？';

  @override
  String get distressConfirmationCancel => '取消';

  @override
  String distressConfirmationCountdown(Object seconds) {
    return '求救模式将在 $seconds 秒后启动';
  }

  @override
  String get imSafeSliderLabel => '滑动以确认“我安全”';

  @override
  String get batteryAlertTitle => '电量警报';

  @override
  String get batteryAlertEnable => '启用电量警报';

  @override
  String batteryAlertThreshold(Object percent) {
    return '阈值：$percent%';
  }

  @override
  String get eventDefaultsTitle => '步骤默认值';

  @override
  String get eventDefaultsBody => '这些默认值适用于任何未单独设置的步骤。';

  @override
  String get gpsLoggingTitle => 'GPS 记录';

  @override
  String get gpsLoggingEnable => '启用 GPS 记录';

  @override
  String get gpsLoggingInterval => '采样间隔（秒）';

  @override
  String get gpsLoggingAccuracy => '精度';

  @override
  String get gpsAccuracyLow => '低';

  @override
  String get gpsAccuracyMedium => '中';

  @override
  String get gpsAccuracyHigh => '高';

  @override
  String get gpsLoggingIncludeSms => '在短信中附加位置';

  @override
  String get gpsLoggingHistoryDays => '历史保留（天）';

  @override
  String get notificationSettingsTitle => '通知';

  @override
  String get notificationSettingsBody => 'Guardian Angela 使用通知来伪装和驱动提醒。';

  @override
  String get historyRetentionTitle => '历史保留';

  @override
  String get historyRetentionBody => 'Guardian Angela 保留历史会话日志的时长。';

  @override
  String historyRetentionDays(Object days) {
    return '保留：$days 天';
  }

  @override
  String get backupTitle => '备份';

  @override
  String get backupExport => '导出数据';

  @override
  String get backupImport => '导入数据';

  @override
  String get backupNotReady => '备份功能尚未可用，敬请期待。';

  @override
  String get backupPinOptional => '可选 PIN（加密备份包）';

  @override
  String get backupImportOk => '备份导入成功。';

  @override
  String get backupSelectionHeader => '包含在导出中';

  @override
  String get backupToggleSettings => '设置';

  @override
  String get backupToggleSettingsSubtitle => '始终包含，以便备份可恢复。';

  @override
  String get backupToggleContacts => '紧急联系人';

  @override
  String get backupToggleModes => '模式';

  @override
  String get backupToggleDistressModes => '求救模式';

  @override
  String get backupToggleTemplates => '提醒模板';

  @override
  String get backupToggleSessionLogs => '会话历史';

  @override
  String get backupToggleRecordings => '录音文件';

  @override
  String get historyTitle => '历史会话';

  @override
  String get historyEmpty => '尚无历史会话。';

  @override
  String get historyTabReal => '真实';

  @override
  String get historyTabSimulated => '模拟';

  @override
  String get historySearchHint => '按模式名称搜索';

  @override
  String get historyFilterModeAll => '全部模式';

  @override
  String get historyFilterModeLabel => '模式';

  @override
  String get historyDateRangePick => '日期范围';

  @override
  String get historyDetailTitle => '会话详情';

  @override
  String get evidenceExportTitle => '导出证据';

  @override
  String get evidenceExportAsText => '复制为文本';

  @override
  String get evidenceExportAsJson => '复制为 JSON';

  @override
  String get evidenceCopied => '已复制到剪贴板。';

  @override
  String get aboutTitle => '关于';

  @override
  String get aboutVersion => '版本';

  @override
  String get aboutCredits => '为回家路上的人们倾心打造。';

  @override
  String get feedbackTitle => '反馈';

  @override
  String get feedbackBody => '我们期待您的反馈。';

  @override
  String get feedbackFieldMessage => '留言';

  @override
  String get feedbackSend => '打开邮箱';

  @override
  String get pickerNoneLabel => '— 无 —';

  @override
  String emergencyConfirmTitle(Object number) {
    return '正在拨打 $number';
  }

  @override
  String get emergencyConfirmSubtitle => '按住取消按钮以中止。';

  @override
  String emergencyConfirmCountdown(Object seconds) {
    return '$seconds 秒后拨打';
  }

  @override
  String get emergencyConfirmCancel => '取消';

  @override
  String get stealthCalendarUpcoming => '即将到来';

  @override
  String get stealthCalendarUpcomingEvent => '会议';

  @override
  String stealthCalendarUntilEvent(Object minutes) {
    return '$minutes 分钟后';
  }

  @override
  String get stealthCalendarToday => '今天';

  @override
  String get stealthCalendarEvent1 => '与 Alex 喝咖啡';

  @override
  String get stealthCalendarEvent2 => '站会';

  @override
  String get stealthCalendarEvent3 => '午餐';

  @override
  String get stealthCalendarEvent4 => '健身';

  @override
  String get stealthCalendarEvent5 => '与 Sam 共进晚餐';

  @override
  String get stealthDisarmGestureHint => '向上滑动以结束';

  @override
  String get stealthMusicTrackTitle => '未命名曲目';

  @override
  String get stealthMusicArtist => '未知艺术家';

  @override
  String get stealthMusicAlbum => '未知专辑';

  @override
  String get stealthMusicNowPlaying => '正在播放';

  @override
  String get stealthMusicSwipeHint => '滑动以解除';

  @override
  String get stealthMusicPrevious => '上一首';

  @override
  String get stealthMusicPause => '暂停';

  @override
  String get stealthMusicNext => '下一首';

  @override
  String get stealthPodcastShowName => '播客';

  @override
  String get stealthPodcastEpisodeTitle => '单集';

  @override
  String get stealthPodcastEpisodesHeader => '单集列表';

  @override
  String get stealthPodcastSpeedLabel => '1x';

  @override
  String get stealthPodcastEpisode1 => '第 1 集';

  @override
  String get stealthPodcastEpisode2 => '第 2 集';

  @override
  String get stealthPodcastEpisode3 => '第 3 集';

  @override
  String get stealthPodcastEpisode4 => '第 4 集';

  @override
  String get stealthPresetPodcast => '播客';

  @override
  String get stealthPresetNone => '无';

  @override
  String get sessionSimSpeedLabel => '速度';

  @override
  String sessionSimSpeedValue(Object value) {
    return '${value}x';
  }

  @override
  String get sessionSimSpeedBackgroundCap => '后台时上限为 60×';

  @override
  String get sessionSimAdvancedLabel => '高级';

  @override
  String get sessionSimTriggerPanic => '触发求救';

  @override
  String get sessionSimTriggerArrival => '触发到达';

  @override
  String get sessionSimTriggerBattery => '触发低电量';

  @override
  String get simulateGpsArrival => '模拟到达';

  @override
  String get simulateLowBattery => '模拟低电量';

  @override
  String get launchGateTitle => '解锁 Guardian Angela';

  @override
  String get launchGateSubtitle => '请输入 PIN 码或使用生物识别。';

  @override
  String get launchGateWrong => 'PIN 码错误';

  @override
  String get launchGateBiometricReason => '解锁 Guardian Angela';

  @override
  String get launchGateUseBiometric => '使用生物识别';

  @override
  String get audioRunningLatePhrase => '你好，我要迟到了，我会尽快回电。';

  @override
  String smsDefaultTemplate(Object name, Object location, Object time) {
    return '$name 可能需要帮助。位置：$location。时间：$time。';
  }

  @override
  String smsDefaultPreCallTemplate(Object name) {
    return '$name 正在尝试联系你。请等待来电。';
  }

  @override
  String simLoudAlarm(Object tail) {
    return '[SIM] 响亮警报 + $tail';
  }

  @override
  String get simLoudAlarmTailFlash => '闪光';

  @override
  String get simLoudAlarmTailVibrate => '振动';

  @override
  String simSmsContact(Object channel, int count) {
    return '[SIM] 将通过 $channel 发送给 $count 位联系人';
  }

  @override
  String simFakeCallRing(Object caller) {
    return '[SIM] 来自 $caller 的来电';
  }

  @override
  String simCountdownWarning(int seconds) {
    return '[SIM] $seconds秒倒计时警告';
  }

  @override
  String simPhoneCall(Object name) {
    return '[SIM] 将拨打 $name';
  }

  @override
  String get simNoContactToCall => '[SIM] 没有可拨打的联系人';

  @override
  String simCallEmergency(Object number) {
    return '[SIM] 将拨打 $number';
  }

  @override
  String get simHardwareButton => '[SIM] 已启用硬件触发';

  @override
  String get simHoldButton => '[SIM] 等待按住按钮';

  @override
  String simDisguisedReminder(Object title) {
    return '[SIM] 将显示\"$title\"';
  }

  @override
  String get simDisguisedReminderEmpty => '[SIM] 没有可用的提醒模板';

  @override
  String get simGpsArrivalTrigger => '[SIM] GPS 到达触发已激活';

  @override
  String get simLowBatteryAlert => '[SIM] 低电量警报已激活';
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
  String get profileAngelaWarningTitle => '關於使用「Angela」一名的提醒';

  @override
  String get profileAngelaWarningBody =>
      'Guardian Angela 將「Angela」作為安全暗號使用。把它當作你自己的名字可能會造成混淆。仍要儲存嗎?';

  @override
  String get commonDelete => '刪除';

  @override
  String get commonEdit => '編輯';

  @override
  String get commonAdd => '新增';

  @override
  String get commonClose => '關閉';

  @override
  String get commonConfirm => '確認';

  @override
  String get commonBack => '返回';

  @override
  String get commonDone => '完成';

  @override
  String get commonRetry => '重試';

  @override
  String get commonYes => '是';

  @override
  String get commonNo => '否';

  @override
  String get commonEnabled => '已啟用';

  @override
  String get commonDisabled => '已停用';

  @override
  String get commonNone => '無';

  @override
  String get commonSeconds => '秒';

  @override
  String get commonMinutes => '分鐘';

  @override
  String get cancel => '取消';

  @override
  String get pinSubmit => '送出';

  @override
  String get homeTitle => 'Guardian Angela';

  @override
  String get homeStartSession => '開始守護';

  @override
  String get homeStartConfirmTitle => '開始守護?';

  @override
  String get homeStartConfirmBody =>
      '請確認你的聯絡人與 PIN 已設定完成。守護將在前景執行,並由你選擇的模式引導報平安。';

  @override
  String get homeSimulate => '模擬';

  @override
  String get homeActiveSession => '進行中的守護';

  @override
  String get homeResumeSession => '繼續';

  @override
  String get homeNoModes => '尚未建立模式。點選「模式」新增一個。';

  @override
  String get homeNoContacts => '尚未新增緊急聯絡人。點選「聯絡人」新增一位。';

  @override
  String get homeContactsBannerNone => '尚未設定緊急聯絡人。';

  @override
  String homeContactsBannerFew(int count) {
    return '已設定 $count 位聯絡人。建議至少 3 位。';
  }

  @override
  String get homeMenuSettings => '設定';

  @override
  String get homeMenuContacts => '聯絡人';

  @override
  String get homeMenuModes => '模式';

  @override
  String get homeMenuHistory => '過往紀錄';

  @override
  String get homeSelectMode => '選擇模式';

  @override
  String get onboardingWelcomeTitle => '歡迎使用 Guardian Angela';

  @override
  String get onboardingWelcomeBody =>
      '一位陪你平安回家的夥伴。無論你是走路、跑步或搭車,Guardian Angela 都會守護著你,並在你需要協助時通知你指定的聯絡人。';

  @override
  String get onboardingProfileTitle => '個人資料與首位聯絡人';

  @override
  String get onboardingProfileBody =>
      '告訴我們一些關於你的資訊,讓 Guardian Angela 能在緊急情況下提供實用細節。接著新增一位你信任的聯絡人。';

  @override
  String get onboardingPermissionsTitle => '權限';

  @override
  String get onboardingPermissionsBody =>
      'Guardian Angela 需要數項權限才能妥善守護你。你可以現在授權,或稍後再從「設定」中開啟。';

  @override
  String get onboardingNext => '下一步';

  @override
  String get onboardingSkip => '略過';

  @override
  String get onboardingFinish => '完成';

  @override
  String get sessionTitle => '守護中';

  @override
  String get sessionDisarm => '我很安全';

  @override
  String get sessionPause => '暫停';

  @override
  String get sessionResume => '繼續';

  @override
  String get sessionHoldPrompt => '按住以保持安全';

  @override
  String get sessionHoldSemantic => '請按住。放開後將進入寬限期。';

  @override
  String sessionStepLabel(Object index, Object total) {
    return '步驟 $index / $total';
  }

  @override
  String sessionMissCount(Object count) {
    return '錯過次數:$count';
  }

  @override
  String sessionRemaining(Object seconds) {
    return '剩餘 $seconds 秒';
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
  String get sessionDisarmTriggerTitle => '解除觸發器已啟動';

  @override
  String get sessionDisarmTriggerBody => '解除觸發器已啟動。要結束守護嗎?';

  @override
  String get sessionDisarmTriggerConfirm => '結束守護';

  @override
  String get sessionDisarmTriggerCancel => '繼續';

  @override
  String get wrongPinAngelaTitle => '來自 Angela 的舊 PIN';

  @override
  String get wrongPinAngelaBody => '確定要使用這組舊 PIN 繼續嗎?';

  @override
  String get wrongPinAngelaConfirm => '確定';

  @override
  String get wrongPinAngelaCancel => '取消';

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
  String get sessionStepSmsDelivered => '已送達';

  @override
  String get sessionStepSmsSent => '已送出';

  @override
  String get sessionStepSmsQueued => '排隊中';

  @override
  String get sessionStepSmsFailed => '失敗';

  @override
  String get sessionStepPhoneCallStatus => '正在致電緊急聯絡人…';

  @override
  String get sessionStepPhoneCallCancel => '取消通話';

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
  String get fakeCallAnswer => '接聽';

  @override
  String get fakeCallDecline => '拒接';

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
  String get contactRequiredError => '姓名與電話號碼為必填。';

  @override
  String get modesTitle => '模式';

  @override
  String get modesEmpty => '尚未建立模式。點選「新增」以建立模式。';

  @override
  String get modesAdd => '新增模式';

  @override
  String get modeEditorTitleCreate => '新模式';

  @override
  String get modeEditorTitleEdit => '編輯模式';

  @override
  String get modeFieldName => '名稱';

  @override
  String get modeFieldCheckInType => '報平安方式';

  @override
  String get modeFieldDistressMode => '求救模式';

  @override
  String get modeFieldDistressModeDefault => '使用預設';

  @override
  String get modeChainHeader => '警報升級流程';

  @override
  String get modeChainAddStep => '新增步驟';

  @override
  String get modeChainEmpty => '尚未有任何步驟。點選「新增步驟」。';

  @override
  String get modeFieldIcon => '圖示';

  @override
  String get modeIconPickerTitle => '選擇圖示';

  @override
  String get modeIconClear => '無圖示';

  @override
  String get modeDistressHeader => '求救觸發器';

  @override
  String get modeDistressEmpty => '尚未設定求救觸發器。';

  @override
  String get modeDistressAdd => '新增觸發器';

  @override
  String get modeDistressTypeHardware => '硬體按鍵';

  @override
  String get modeDistressButtonType => '按鍵';

  @override
  String get modeDistressButtonVolumeUp => '音量+';

  @override
  String get modeDistressButtonVolumeDown => '音量−';

  @override
  String get modeDistressButtonPower => '電源';

  @override
  String get modeDistressPattern => '模式';

  @override
  String get modeDistressPatternRepeat => '連續按下';

  @override
  String get modeDistressPatternLong => '長按';

  @override
  String get modeDistressPressCount => '按鍵次數';

  @override
  String get modeDistressPressWindow => '時間窗(毫秒)';

  @override
  String get modeDistressLongDuration => '按住時間(秒)';

  @override
  String modeDistressSummaryRepeat(Object count, Object windowMs) {
    return '$count 次 / $windowMs 毫秒';
  }

  @override
  String modeDistressSummaryLong(Object seconds) {
    return '按住 $seconds 秒';
  }

  @override
  String get modeOverridesHeader => '模式覆寫';

  @override
  String get modeOverridesUseDefault => '使用應用預設';

  @override
  String get modeOverridesGpsLabel => 'GPS 紀錄';

  @override
  String get modeOverridesStealthLabel => '隱身';

  @override
  String get modeOverridesEventDefaultsLabel => '事件預設值';

  @override
  String get modeOverridesLocalTemplatesLabel => '本地提醒範本';

  @override
  String get modeOverridesGpsEnabled => '啟用 GPS 紀錄';

  @override
  String get modeOverridesGpsIntervalLabel => '取樣間隔(秒)';

  @override
  String get modeOverridesGpsIncludeInSms => '在簡訊中加入位置';

  @override
  String get modeOverridesStealthEnabled => '啟用隱身';

  @override
  String get modeOverridesStealthFakeName => '假冒應用名稱';

  @override
  String get modeOverridesEventDefaultsHint => '此模式啟用了自訂事件預設值。';

  @override
  String modeOverridesLocalTemplatesCount(Object count) {
    return '$count 個本地範本';
  }

  @override
  String get modeUnsavedTitle => '捨棄變更?';

  @override
  String get modeUnsavedBody => '您有未儲存的變更。捨棄並離開編輯器?';

  @override
  String get modeUnsavedDiscard => '捨棄';

  @override
  String get modeUnsavedKeep => '繼續編輯';

  @override
  String get stepDuplicate => '複製步驟';

  @override
  String get stepTimingHeader => '時間';

  @override
  String stepTimingSummary(Object wait, Object duration, Object grace) {
    return '等待 $wait 秒 / 時長 $duration 秒 / 寬限 $grace 秒';
  }

  @override
  String get stepCategoryAll => '全部';

  @override
  String get stepPickerMore => '更多選項...';

  @override
  String get stepCategoryAction => '動作';

  @override
  String get stepCategoryReminder => '提醒';

  @override
  String get stepCategoryDisarm => '簽到';

  @override
  String get modeTrackingHeader => 'GPS 追蹤';

  @override
  String get modeTrackingEnabled => '工作階段期間記錄 GPS';

  @override
  String get modeTrackingIntervalLabel => '取樣間隔';

  @override
  String get modeTrackingBufferSizeLabel => '緩衝區大小';

  @override
  String modeTrackingBufferSizeValue(Object count) {
    return '$count 個點';
  }

  @override
  String get modeTrackingBatteryNote => '頻繁的 GPS 追蹤會增加電池耗用。';

  @override
  String get stepConfigLogGpsLabel => 'GPS 記錄';

  @override
  String get stepConfigLogGpsDefault => '預設';

  @override
  String get stepConfigLogGpsOn => '開啟';

  @override
  String get stepConfigLogGpsOff => '關閉';

  @override
  String get stepConfigLogGpsDefaultOn => '預設（開啟）';

  @override
  String get stepConfigLogGpsDefaultOff => '預設（關閉）';

  @override
  String get moreSettingsHeader => '更多設定';

  @override
  String moreSettingsHeaderCustomized(int count) {
    return '更多設定（已自訂 $count 項）';
  }

  @override
  String get stepTypePickerLabel => '步驟類型';

  @override
  String get stepTypeHoldButton => '按住按鈕';

  @override
  String get stepTypeDisguisedReminder => '偽裝提醒';

  @override
  String get stepTypeCountdownWarning => '倒數警告';

  @override
  String get stepTypeFakeCall => '假來電';

  @override
  String get stepTypeSmsContact => '簡訊聯絡人';

  @override
  String get stepTypePhoneCallContact => '致電聯絡人';

  @override
  String get stepTypeLoudAlarm => '大聲警報';

  @override
  String get stepTypeCallEmergency => '撥打緊急電話';

  @override
  String get stepTypeHardwareButton => '實體按鍵';

  @override
  String get stepFieldDuration => '持續時間(秒)';

  @override
  String get stepFieldGrace => '寬限時間(秒)';

  @override
  String get stepFieldWait => '等待時間(秒)';

  @override
  String get stepFieldRetryCount => '重試次數';

  @override
  String get stepFieldRandomize => '時間抖動';

  @override
  String get stepFieldRandomizeToggle => '隨機化時間 (±20%)';

  @override
  String get stepFieldWaitTooltip => '此步驟開始前等待多久。';

  @override
  String get stepFieldDurationTooltip => '此步驟在寬限期開始前活躍多久。';

  @override
  String get stepFieldGraceTooltip => '活躍階段後在下一步驟啟動前確認安全的時間。';

  @override
  String get stepFieldRetryCountTooltip => '升級前重複此步驟多少次。';

  @override
  String get stepFieldReminderIntervalTooltip => '等候簽到時偽裝提醒觸發的頻率。';

  @override
  String get stepFieldReminderGraceTooltip => '提醒出現後使用者確認安全的時間。';

  @override
  String get stepPreview => '模擬預覽';

  @override
  String stepPreviewFired(Object description) {
    return '預覽已執行:$description';
  }

  @override
  String get stepPreviewTitle => '步驟預覽';

  @override
  String get stepPreviewMissingParams => '缺少步驟或模式參照。';

  @override
  String get stepPreviewModeNotFound => '找不到此模式。';

  @override
  String get stepPreviewStepNotFound => '此模式中找不到此步驟。';

  @override
  String stepPreviewError(Object error) {
    return '預覽失敗:$error';
  }

  @override
  String get stepPreviewReplay => '重播';

  @override
  String get stepPreviewHoldButtonHint => '按住按鈕以感受真實回應。';

  @override
  String get stepPreviewHoldButtonLabel => '按住';

  @override
  String get stepPreviewHoldButtonSemantic => '按住以預覽';

  @override
  String get stepPreviewHoldButtonReleased => '已放開。工作階段現在將進入寬限視窗。';

  @override
  String get stepPreviewFakeCallHint => '將出現偽裝來電畫面。滑動接聽或按住紅色按鈕以模擬求救。';

  @override
  String get stepConfigFakeCallCaller => '來電者姓名';

  @override
  String get stepConfigFakeCallDecline => '拒接視為解除';

  @override
  String get stepConfigLoudAlarmFlash => '螢幕閃爍';

  @override
  String get stepConfigLoudAlarmVolume => '最大音量';

  @override
  String get stepConfigCountdownVibrate => '震動';

  @override
  String get stepConfigCountdownTone => '播放提示音';

  @override
  String get stepConfigSmsSelection => '收件者';

  @override
  String get stepConfigSmsAllContacts => '所有聯絡人';

  @override
  String get stepConfigSmsSpecific => '指定聯絡人';

  @override
  String get stepConfigSmsIncludeLocation => '附上位置';

  @override
  String get stepConfigSmsIncludeMedical => '附上醫療資訊';

  @override
  String get stepConfigSmsAutoRecordAudio => '自動錄音';

  @override
  String get stepConfigSmsAutoRecordVideo => '自動錄影';

  @override
  String get stepConfigSmsRecordDuration => '錄製時長';

  @override
  String get stepConfigHoldReleaseSensitivity => '放開靈敏度(秒)';

  @override
  String get stepConfigReminderInterval => '提醒間隔(秒)';

  @override
  String get stepConfigReminderTemplate => '範本';

  @override
  String get stepConfigHardwarePattern => '按鍵模式';

  @override
  String get stepConfigHardwarePressCount => '按壓次數';

  @override
  String get stepConfigHardwarePressWindow => '按壓間隔 (毫秒)';

  @override
  String get stepConfigHardwareLongDuration => '長按時長 (秒)';

  @override
  String get stepConfigHardwareButton => '按鍵';

  @override
  String get stepConfigHardwareButtonVolumeUp => '音量增加';

  @override
  String get stepConfigHardwareButtonVolumeDown => '音量減少';

  @override
  String get stepConfigHardwareButtonPower => '電源鍵';

  @override
  String get stepConfigHardwarePatternRepeat => '連按';

  @override
  String get stepConfigHardwarePatternLong => '長按';

  @override
  String get stepConfigEmergencyNumber => '緊急號碼覆寫';

  @override
  String get stepConfigEmergencyConfirm => '撥打前確認';

  @override
  String get stepConfigPhonePreSms => '通話前先傳送簡訊';

  @override
  String get distressModesTitle => '求救模式';

  @override
  String get distressModeInUseTitle => '求救模式使用中';

  @override
  String distressModeInUseBody(Object modes) {
    return '此求救模式仍繫結於:$modes。請先將這些模式改為其他求救模式,再刪除本模式。';
  }

  @override
  String get distressModesEmpty => '尚未建立求救模式。';

  @override
  String get distressModesAdd => '新增求救模式';

  @override
  String get distressModeEditorTitleCreate => '新求救模式';

  @override
  String get distressModeEditorTitleEdit => '編輯求救模式';

  @override
  String get distressModeName => '求救模式名稱';

  @override
  String get distressCountdown => '正在觸發求救模式…';

  @override
  String get distressCountdownStealth => '請稍候…';

  @override
  String get templatesTitle => '提醒範本';

  @override
  String get templatesEmpty => '尚未建立範本。';

  @override
  String get templatesAdd => '新增範本';

  @override
  String get templateEditorTitleCreate => '新範本';

  @override
  String get templateEditorTitleEdit => '編輯範本';

  @override
  String get templateFieldName => '編輯器名稱';

  @override
  String get templateFieldTitle => '提醒標題';

  @override
  String get templateFieldBody => '提醒內容';

  @override
  String get templateFieldConfirmationType => '確認類型';

  @override
  String get templateFieldKeyword => '關鍵字';

  @override
  String get templateFieldButtonLabel => '按鈕文字';

  @override
  String get templateFieldDisplayStyle => '顯示樣式';

  @override
  String get templateConfirmTapButton => '點按按鈕';

  @override
  String get templateConfirmTapWord => '點按字詞';

  @override
  String get templateConfirmSwipe => '滑動';

  @override
  String get templateConfirmDismiss => '關閉';

  @override
  String get templateDisplayFullscreen => '全螢幕';

  @override
  String get templateDisplaySubtle => '低調';

  @override
  String get profileTitle => '個人資料';

  @override
  String get profileFieldName => '姓名';

  @override
  String get profileFieldAge => '年齡';

  @override
  String get profileFieldPhoneNumber => '電話號碼';

  @override
  String get profileFieldPhysicalDescription => '外貌描述';

  @override
  String get profileFieldBloodType => '血型';

  @override
  String get profileFieldAllergies => '過敏原';

  @override
  String get profileFieldMedications => '使用中藥物';

  @override
  String get profileFieldConditions => '健康狀況';

  @override
  String get profileFieldInstructions => '緊急指示';

  @override
  String get profileAddItem => '新增項目';

  @override
  String get settingsTitle => '設定';

  @override
  String get settingsSectionSecurity => '安全性';

  @override
  String get settingsSectionStealth => '隱匿模式';

  @override
  String get settingsSectionDefaults => '預設值';

  @override
  String get settingsSectionHistory => '歷史紀錄';

  @override
  String get settingsSectionBackup => '備份';

  @override
  String get settingsSectionAbout => '關於';

  @override
  String get settingsSectionFeedback => '意見回饋';

  @override
  String get settingsSectionContacts => '聯絡人';

  @override
  String get settingsSectionModes => '模式';

  @override
  String get settingsSectionProfile => '個人資料';

  @override
  String get settingsSectionDistressModes => '求救模式';

  @override
  String get settingsSectionReminderTemplates => '提醒範本';

  @override
  String get settingsSectionBatteryAlert => '電量警示';

  @override
  String get settingsSectionEventDefaults => '步驟預設值';

  @override
  String get settingsSectionGpsLogging => 'GPS 紀錄';

  @override
  String get settingsSectionNotifications => '通知';

  @override
  String get settingsSectionHistoryRetention => '紀錄保留';

  @override
  String get settingsSectionAppearance => '外觀';

  @override
  String get settingsThemeMode => '主題';

  @override
  String get settingsThemeLight => '淺色';

  @override
  String get settingsThemeDark => '深色';

  @override
  String get settingsThemeSystem => '跟隨系統';

  @override
  String get settingsLanguage => '語言';

  @override
  String get settingsEmergencyNumber => '緊急電話號碼';

  @override
  String get settingsAlarmDnd => '警報覆寫勿擾模式';

  @override
  String get securityTitle => '安全性';

  @override
  String get securityAppPin => '應用程式 PIN';

  @override
  String get securitySessionEndPin => '結束守護 PIN';

  @override
  String get securityDuressPin => '脅迫 PIN';

  @override
  String get securityAppPinBiometric => '使用生物辨識解鎖應用程式 PIN';

  @override
  String get securitySessionEndPinBiometric => '使用生物辨識解鎖結束守護 PIN';

  @override
  String get securityDistressCancelBiometric => '使用生物辨識取消求救';

  @override
  String get securityDuressTest => '測試脅迫 PIN';

  @override
  String get securityDuressTestSubtitle => '驗證你的脅迫 PIN 是否可用。';

  @override
  String get securityPinTimeout => 'PIN 逾時(秒)';

  @override
  String get securityDisablePin => '停用';

  @override
  String get securitySetPin => '設定 PIN';

  @override
  String get securityChangePin => '變更 PIN';

  @override
  String get pinSetupTitle => '設定 PIN';

  @override
  String get pinSetupEnter => '請輸入新的 PIN';

  @override
  String get pinSetupConfirm => '請再次輸入 PIN';

  @override
  String get pinSetupMismatch => '兩次輸入的 PIN 不一致,請重試。';

  @override
  String get pinEntryTitle => '輸入 PIN';

  @override
  String get pinEntrySubtitle => '請輸入 PIN 以繼續。';

  @override
  String get pinEntryBiometricReason => '請驗證身分以繼續';

  @override
  String get stealthTitle => '隱匿模式';

  @override
  String get stealthEnable => '啟用隱匿模式';

  @override
  String get stealthFakeName => '偽裝應用程式名稱';

  @override
  String get stealthFakeIcon => '偽裝圖示';

  @override
  String get stealthNotificationDisguise => '偽裝通知';

  @override
  String get stealthTimerDisplay => '隱匿模式下顯示計時器';

  @override
  String get stealthTimerDisplayNormal => '顯示完整文字';

  @override
  String get stealthTimerDisplaySmall => '僅顯示數字';

  @override
  String get stealthTimerDisplayNone => '隱藏計時器';

  @override
  String get stealthSessionScreen => '移除守護畫面的品牌標示';

  @override
  String get stealthPickerTitle => '應用程式圖示';

  @override
  String get stealthPickerIntro => '選擇圖示在啟動器中的外觀。';

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
  String get distressConfirmationTitle => '你身處危險嗎？';

  @override
  String get distressConfirmationCancel => '取消';

  @override
  String distressConfirmationCountdown(Object seconds) {
    return '求救模式將在 $seconds 秒後啟動';
  }

  @override
  String get imSafeSliderLabel => '滑動以確認「我安全」';

  @override
  String get batteryAlertTitle => '電量警示';

  @override
  String get batteryAlertEnable => '啟用電量警示';

  @override
  String batteryAlertThreshold(Object percent) {
    return '門檻:$percent%';
  }

  @override
  String get eventDefaultsTitle => '步驟預設值';

  @override
  String get eventDefaultsBody => '這些預設值會套用到未覆寫這些設定的步驟。';

  @override
  String get gpsLoggingTitle => 'GPS 紀錄';

  @override
  String get gpsLoggingEnable => '啟用 GPS 紀錄';

  @override
  String get gpsLoggingInterval => '取樣間隔(秒)';

  @override
  String get gpsLoggingAccuracy => '精確度';

  @override
  String get gpsAccuracyLow => '低';

  @override
  String get gpsAccuracyMedium => '中';

  @override
  String get gpsAccuracyHigh => '高';

  @override
  String get gpsLoggingIncludeSms => '於簡訊附上位置';

  @override
  String get gpsLoggingHistoryDays => '紀錄保留天數';

  @override
  String get notificationSettingsTitle => '通知';

  @override
  String get notificationSettingsBody => 'Guardian Angela 利用通知進行偽裝並驅動提醒。';

  @override
  String get historyRetentionTitle => '紀錄保留';

  @override
  String get historyRetentionBody => 'Guardian Angela 會保留過往守護紀錄多久。';

  @override
  String historyRetentionDays(Object days) {
    return '保留:$days 天';
  }

  @override
  String get backupTitle => '備份';

  @override
  String get backupExport => '匯出資料';

  @override
  String get backupImport => '匯入資料';

  @override
  String get backupNotReady => '備份功能尚未提供,敬請期待。';

  @override
  String get backupPinOptional => '可選 PIN（加密備份包）';

  @override
  String get backupImportOk => '備份匯入成功。';

  @override
  String get backupSelectionHeader => '包含於匯出';

  @override
  String get backupToggleSettings => '設定';

  @override
  String get backupToggleSettingsSubtitle => '設定一律包含,以便還原備份。';

  @override
  String get backupToggleContacts => '緊急聯絡人';

  @override
  String get backupToggleModes => '模式';

  @override
  String get backupToggleDistressModes => '求救模式';

  @override
  String get backupToggleTemplates => '提醒範本';

  @override
  String get backupToggleSessionLogs => '守護紀錄';

  @override
  String get backupToggleRecordings => '音訊錄音';

  @override
  String get historyTitle => '過往紀錄';

  @override
  String get historyEmpty => '尚無過往紀錄。';

  @override
  String get historyTabReal => '真實';

  @override
  String get historyTabSimulated => '模擬';

  @override
  String get historySearchHint => '依模式名稱搜尋';

  @override
  String get historyFilterModeAll => '所有模式';

  @override
  String get historyFilterModeLabel => '模式';

  @override
  String get historyDateRangePick => '日期範圍';

  @override
  String get historyDetailTitle => '守護詳情';

  @override
  String get evidenceExportTitle => '匯出證據';

  @override
  String get evidenceExportAsText => '複製為文字';

  @override
  String get evidenceExportAsJson => '複製為 JSON';

  @override
  String get evidenceCopied => '已複製至剪貼簿。';

  @override
  String get aboutTitle => '關於';

  @override
  String get aboutVersion => '版本';

  @override
  String get aboutCredits => '為每一位平安回家的你,用心打造。';

  @override
  String get feedbackTitle => '意見回饋';

  @override
  String get feedbackBody => '我們非常期待聽見你的想法。';

  @override
  String get feedbackFieldMessage => '訊息';

  @override
  String get feedbackSend => '開啟電子郵件';

  @override
  String get pickerNoneLabel => '— 無 —';

  @override
  String emergencyConfirmTitle(Object number) {
    return '正在撥打 $number';
  }

  @override
  String get emergencyConfirmSubtitle => '按住取消按鈕以中止。';

  @override
  String emergencyConfirmCountdown(Object seconds) {
    return '$seconds 秒後撥出';
  }

  @override
  String get emergencyConfirmCancel => '取消';

  @override
  String get stealthCalendarUpcoming => '即將開始';

  @override
  String get stealthCalendarUpcomingEvent => '會議';

  @override
  String stealthCalendarUntilEvent(Object minutes) {
    return '$minutes 分鐘後';
  }

  @override
  String get stealthCalendarToday => '今天';

  @override
  String get stealthCalendarEvent1 => '與 Alex 喝咖啡';

  @override
  String get stealthCalendarEvent2 => '站立會議';

  @override
  String get stealthCalendarEvent3 => '午餐';

  @override
  String get stealthCalendarEvent4 => '健身';

  @override
  String get stealthCalendarEvent5 => '與 Sam 共進晚餐';

  @override
  String get stealthDisarmGestureHint => '向上滑動以結束';

  @override
  String get stealthMusicTrackTitle => '未命名曲目';

  @override
  String get stealthMusicArtist => '未知藝人';

  @override
  String get stealthMusicAlbum => '未知專輯';

  @override
  String get stealthMusicNowPlaying => '正在播放';

  @override
  String get stealthMusicSwipeHint => '滑動以解除';

  @override
  String get stealthMusicPrevious => '上一首';

  @override
  String get stealthMusicPause => '暫停';

  @override
  String get stealthMusicNext => '下一首';

  @override
  String get stealthPodcastShowName => 'Podcast';

  @override
  String get stealthPodcastEpisodeTitle => '單集';

  @override
  String get stealthPodcastEpisodesHeader => '單集';

  @override
  String get stealthPodcastSpeedLabel => '1x';

  @override
  String get stealthPodcastEpisode1 => '第 1 集';

  @override
  String get stealthPodcastEpisode2 => '第 2 集';

  @override
  String get stealthPodcastEpisode3 => '第 3 集';

  @override
  String get stealthPodcastEpisode4 => '第 4 集';

  @override
  String get stealthPresetPodcast => 'Podcast';

  @override
  String get stealthPresetNone => '無';

  @override
  String get sessionSimSpeedLabel => '速度';

  @override
  String sessionSimSpeedValue(Object value) {
    return '${value}x';
  }

  @override
  String get sessionSimSpeedBackgroundCap => '在背景時上限為 60×';

  @override
  String get sessionSimAdvancedLabel => '進階';

  @override
  String get sessionSimTriggerPanic => '觸發求救';

  @override
  String get sessionSimTriggerArrival => '觸發抵達';

  @override
  String get sessionSimTriggerBattery => '觸發低電量';

  @override
  String get simulateGpsArrival => '模擬抵達';

  @override
  String get simulateLowBattery => '模擬低電量';

  @override
  String get launchGateTitle => '解鎖 Guardian Angela';

  @override
  String get launchGateSubtitle => '請輸入 PIN 或使用生物辨識。';

  @override
  String get launchGateWrong => 'PIN 錯誤';

  @override
  String get launchGateBiometricReason => '解鎖 Guardian Angela';

  @override
  String get launchGateUseBiometric => '使用生物辨識';

  @override
  String get audioRunningLatePhrase => '你好，我會遲到，我會盡快回電。';

  @override
  String smsDefaultTemplate(Object name, Object location, Object time) {
    return '$name 可能需要協助。位置：$location。時間：$time。';
  }

  @override
  String smsDefaultPreCallTemplate(Object name) {
    return '$name 正在嘗試聯絡你。請等待來電。';
  }

  @override
  String simLoudAlarm(Object tail) {
    return '[SIM] 響亮警報 + $tail';
  }

  @override
  String get simLoudAlarmTailFlash => '閃光';

  @override
  String get simLoudAlarmTailVibrate => '震動';

  @override
  String simSmsContact(Object channel, int count) {
    return '[SIM] 將透過 $channel 發送給 $count 位聯絡人';
  }

  @override
  String simFakeCallRing(Object caller) {
    return '[SIM] 來自 $caller 的來電';
  }

  @override
  String simCountdownWarning(int seconds) {
    return '[SIM] $seconds秒倒數警告';
  }

  @override
  String simPhoneCall(Object name) {
    return '[SIM] 將撥打 $name';
  }

  @override
  String get simNoContactToCall => '[SIM] 沒有可撥打的聯絡人';

  @override
  String simCallEmergency(Object number) {
    return '[SIM] 將撥打 $number';
  }

  @override
  String get simHardwareButton => '[SIM] 已啟用硬體觸發';

  @override
  String get simHoldButton => '[SIM] 等待按住按鈕';

  @override
  String simDisguisedReminder(Object title) {
    return '[SIM] 將顯示「$title」';
  }

  @override
  String get simDisguisedReminderEmpty => '[SIM] 沒有可用的提醒範本';

  @override
  String get simGpsArrivalTrigger => '[SIM] GPS 到達觸發已啟動';

  @override
  String get simLowBatteryAlert => '[SIM] 低電量警報已啟動';
}
