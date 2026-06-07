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
  String get commonGotIt => '知道了';

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
  String get onboardingUseSimNumber => '使用我的 SIM 卡号码';

  @override
  String onboardingUseSimNumberHint(Object number) {
    return '$number';
  }

  @override
  String get onboardingUseSimNumberUnsupported => '在 iOS 上不可用';

  @override
  String get onboardingUseSimNumberUnavailable => '无法读取号码';

  @override
  String get onboardingUseSimNumberPermissionDenied => '权限被拒绝';

  @override
  String get sessionTitle => '会话';

  @override
  String get sessionDisarm => '我安全';

  @override
  String get sessionDisarmStealth => '无需 Angela';

  @override
  String get homeChainSummaryTitle => '链路概要';

  @override
  String get homeChainSummaryEmpty => '该模式还没有步骤——点击模式即可编辑。';

  @override
  String homeChainSummaryTimingTitle(Object name) {
    return '步骤:$name';
  }

  @override
  String homeChainSummaryWait(Object seconds) {
    return '等待:$seconds 秒';
  }

  @override
  String homeChainSummaryDuration(Object seconds) {
    return '进行中:$seconds 秒';
  }

  @override
  String homeChainSummaryGrace(Object seconds) {
    return '宽限期:$seconds 秒';
  }

  @override
  String homeChainSummaryRetry(Object count) {
    return '重试次数:$count';
  }

  @override
  String homeChainSummaryNextStep(Object name) {
    return '下一步:$name';
  }

  @override
  String get homeChainSummaryNextStepNone => '下一步:链路结束';

  @override
  String get homeChainSummaryClose => '关闭';

  @override
  String get chainStepNameHoldButton => '长按以保持安全';

  @override
  String get chainStepNameDisguisedReminder => '伪装提醒';

  @override
  String get chainStepNameCountdownWarning => '倒计时警告';

  @override
  String get chainStepNameFakeCall => '虚假来电';

  @override
  String get chainStepNameSmsContact => '短信联系人';

  @override
  String get chainStepNamePhoneCallContact => '电话联系人';

  @override
  String get chainStepNameLoudAlarm => '高声警报';

  @override
  String get chainStepNameCallEmergency => '紧急呼救';

  @override
  String get chainStepNameHardwareButton => '硬件按键';

  @override
  String get homeChecklistTitle => '安全设置';

  @override
  String get homeChecklistDismissTooltip => '关闭清单';

  @override
  String get homeChecklistExpandTooltip => '展开清单';

  @override
  String get homeChecklistCollapseTooltip => '收起清单';

  @override
  String homeChecklistProgress(Object done, Object total) {
    return '已完成 $done/$total';
  }

  @override
  String get homeChecklistAllDoneBanner => '全部就绪——你已受到守护!';

  @override
  String get homeChecklistInfoTooltip => '为什么重要';

  @override
  String get homeChecklistGotIt => '我知道了';

  @override
  String get homeChecklistGoThere => '前往';

  @override
  String get homeChecklistItem1Title => '添加紧急联系人';

  @override
  String get homeChecklistItem2Title => '设置会话结束 PIN';

  @override
  String get homeChecklistItem3Title => '配置隐身模式';

  @override
  String get homeChecklistItem4Title => '试一次模拟';

  @override
  String get homeChecklistItem5Title => '定制一个安全模式';

  @override
  String get homeChecklistItem6Title => '授予所需权限';

  @override
  String get checklistInfo1Body =>
      '紧急联系人是当你未能按时签到时,Guardian Angela 会向其发送短信和打电话的人。没有至少一位联系人,链路就无处升级。';

  @override
  String get checklistInfo2Body =>
      '会话结束 PIN 可防止攻击者悄悄结束正在进行的会话。他们仍可尝试,但连续输错五次将静默触发你的求助链路。';

  @override
  String get checklistInfo3Body =>
      '隐身模式会把正在进行的会话伪装成屏幕上不起眼的东西——音乐播放器、暂停的计时器、空白锁屏。当身边的人不能让你看到安全应用时使用。';

  @override
  String get checklistInfo4Body =>
      '模拟会从头到尾运行你的安全模式,但不会真正发送短信、拨打电话或响起警报。用它在真正需要前熟悉时序。';

  @override
  String get checklistInfo5Body =>
      '自定义模式可针对具体情境调整步骤、时长和触发条件——走夜路、第一次约会、上夜班。内置的两个模式只是起点,而非终点。';

  @override
  String get checklistInfo6Body =>
      '没有通知权限,Guardian Angela 无法保持常驻前台状态、无法发出伪装提醒,也无法在链路即将升级时提醒你。';

  @override
  String get checklistTutorial3Body =>
      '打开隐身默认设置并打开「启用隐身模式」。在那里你可以选择一个伪装的音乐品牌、隐藏会话计时器,或者伪装主屏图标。';

  @override
  String get checklistTutorial4Body =>
      '选定模式后,在首页点击带边框的「模拟」按钮。会话会以橙色边框和 [SIM] 标记运行——任何信息都不会离开你的手机。';

  @override
  String get checklistTutorial5Body =>
      '打开「模式」页,既可编辑内置模式(步行 / 约会),也可从零创建。调整链路、加入虚假来电、设置自定义时长。';

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
  String get sessionPausedIncomingCall => '已暂停 — 来电';

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
  String get sessionReminderEarlyCheckInHint => '点击立即签到';

  @override
  String get sessionReminderDefaultButton => '好';

  @override
  String get sessionReminderTapWordHint => '点击继续';

  @override
  String get sessionReminderSwipeLabel => '滑动关闭';

  @override
  String get sessionReminderDismissLabel => '关闭';

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
  String get fakeCallBrandAndroid => '电话';

  @override
  String get fakeCallBrandIos => '电话';

  @override
  String get fakeCallBrandMinimal => '通话';

  @override
  String get fakeCallDeclineSafeLabel => '拒接（我安全）';

  @override
  String get fakeCallDeclineUnsafeLabel => '拒接（保持警戒）';

  @override
  String get fakeCallHoldForDistress => '按住 5 秒求救';

  @override
  String fakeCallVoicePrompt(String name) {
    return '语音提示：$name';
  }

  @override
  String fakeCallVibrationLabel(String pattern) {
    return '振动：$pattern';
  }

  @override
  String get fakeCallVibrationPatternDefault => '默认';

  @override
  String get fakeCallSlideToAnswerHint => '滑动以接听';

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
  String get contactFormIosSmsWarning => '在 iOS 上，短信会打开“信息”应用，您必须手动点击发送。';

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
  String get stepConfigTimingHeader => '计时';

  @override
  String get stepConfigEventHeader => '事件配置';

  @override
  String get stepConfigAdvancedHeader => '重试与高级';

  @override
  String get stepFieldWait => '触发前等待（秒）';

  @override
  String get stepFieldDuration => '活动时长（秒）';

  @override
  String get stepFieldGrace => '宽限期（秒）';

  @override
  String get stepFieldRetryCount => '重试次数';

  @override
  String get stepFieldRandomize => '随机化计时（±20%）';

  @override
  String get stepDuplicate => '复制步骤';

  @override
  String get stepResetDefaults => '重置为默认值';

  @override
  String get smsContactRecipientsHeader => '要通知的联系人';

  @override
  String get smsContactSummaryAll => '收件人：所有已启用的联系人';

  @override
  String get smsContactSummaryNone => '未选择收件人';

  @override
  String smsContactSummaryTo(Object names) {
    return '收件人：$names';
  }

  @override
  String get smsContactChannelDisabledTooltip => '此联系人未启用此渠道——编辑联系人以添加此渠道。';

  @override
  String get smsContactEmptyAddPrompt => '尚无联系人——在“联系人”中添加一位';

  @override
  String get safetyOptionsHeader => '安全选项';

  @override
  String get safetyOptionsDistressModeTitle => '求救模式';

  @override
  String get safetyOptionsDistressModeUseDefault => '使用默认求救模式';

  @override
  String safetyOptionsDistressModeUseDefaultNamed(Object name) {
    return '使用默认（$name）';
  }

  @override
  String get safetyOptionsDistressModeInfo =>
      '当求救触发器触发时（胁迫 PIN、硬件紧急按键或错误 PIN 次数超限），此模式的链条会被所选求救模式的链条替换。保持默认即可使用应用全局的求救模式。';

  @override
  String get safetyOptionsManageDistressModes => '管理求救模式';

  @override
  String get safetyOptionsDistressTriggersTitle => '求救触发器';

  @override
  String get safetyOptionsDistressTriggersInfo =>
      '求救触发器会立即启动求救链条，与主链条并行运行。硬件紧急按键会按照所配置的按键模式监视实体按键。';

  @override
  String get safetyOptionsDistressTriggersEmpty => '暂无求救触发器';

  @override
  String get safetyOptionsAddHardwarePanic => '添加硬件紧急按键';

  @override
  String safetyOptionsTriggerHardwareRepeat(Object button, Object count) {
    return '$button：按 $count 次';
  }

  @override
  String safetyOptionsTriggerHardwareLong(Object button, Object seconds) {
    return '$button：长按 $seconds 秒';
  }

  @override
  String get safetyOptionsButtonVolumeUp => '音量加';

  @override
  String get safetyOptionsButtonVolumeDown => '音量减';

  @override
  String get safetyOptionsTriggerPattern => '按键模式';

  @override
  String get safetyOptionsPatternRepeat => '重复按压';

  @override
  String get safetyOptionsPatternLong => '长按';

  @override
  String get safetyOptionsTriggerButton => '按键';

  @override
  String get safetyOptionsTriggerPressCount => '按压次数';

  @override
  String get safetyOptionsTriggerHoldDuration => '长按时长（秒）';

  @override
  String get safetyOptionsDisarmTriggersTitle => '解除触发器';

  @override
  String get safetyOptionsGpsArrivalTitle => 'GPS 到达解除';

  @override
  String get safetyOptionsGpsArrivalInfo =>
      '当你到达目的地所配置半径范围内时，会话会自动结束。目的地在开始会话时设置。';

  @override
  String get safetyOptionsGpsArrivalRadius => '到达半径';

  @override
  String safetyOptionsRadiusMeters(Object meters) {
    return '$meters 米';
  }

  @override
  String safetyOptionsRadiusKilometers(Object km) {
    return '$km 公里';
  }

  @override
  String get safetyOptionsDestinationSource => '目的地';

  @override
  String get safetyOptionsDestinationPrompt => '在会话开始时设置目的地';

  @override
  String get safetyOptionsDestinationFixed => '固定坐标';

  @override
  String get safetyOptionsLatitude => '纬度';

  @override
  String get safetyOptionsLongitude => '经度';

  @override
  String get safetyOptionsTimerDisarmTitle => '计时器解除';

  @override
  String get safetyOptionsTimerDisarmInfo => '无论是否已开始升级，会话都会在所配置的时间后自动结束。';

  @override
  String get safetyOptionsTimerDuration => '时长';

  @override
  String safetyOptionsDurationMinutes(Object minutes) {
    return '$minutes 分钟';
  }

  @override
  String safetyOptionsDurationHoursMinutes(Object hours, Object minutes) {
    return '$hours 小时 $minutes 分钟';
  }

  @override
  String get safetyOptionsGpsLoggingTitle => 'GPS 记录';

  @override
  String get safetyOptionsGpsLoggingInfo =>
      '选择此模式是否在会话期间记录你的位置。“继承”使用你的全局 GPS 设置；“自定义”为此模式覆盖这些设置；“关闭”完全禁用记录。';

  @override
  String get safetyOptionsStealthTitle => '隐身';

  @override
  String get safetyOptionsStealthInfo =>
      '选择此模式是否在会话期间伪装应用。“继承”使用你的全局隐身设置；“自定义”为此模式覆盖这些设置；“关闭”完全禁用隐身。';

  @override
  String get safetyOptionsTriStateInherit => '继承';

  @override
  String get safetyOptionsTriStateCustom => '自定义';

  @override
  String get safetyOptionsTriStateOff => '关闭';

  @override
  String get safetyOptionsLocalTemplatesTitle => '本地模板';

  @override
  String get safetyOptionsLocalTemplatesInfo =>
      '本地模板仅为此模式添加到全局提醒模板池中。可用于此模式专属的伪装提醒步骤。';

  @override
  String get safetyOptionsLocalTemplatesEmpty => '暂无本地模板';

  @override
  String get safetyOptionsAddTemplate => '添加模板';

  @override
  String get safetyOptionsManageTemplates => '管理提醒模板';

  @override
  String get safetyOptionsEventDefaultsTitle => '事件默认值';

  @override
  String get safetyOptionsEventDefaultsInfo =>
      '事件默认值设置每种步骤类型的初始配置。“继承”使用你的全局默认值；“自定义”为此模式中没有自身配置的步骤覆盖这些默认值。';

  @override
  String get safetyOptionsEventDefaultsTwoStateInherit => '继承';

  @override
  String get safetyOptionsAllowDisarmAsDistressTitle => '在求救激活期间允许解除';

  @override
  String get safetyOptionsAllowDisarmAsDistressInfo =>
      '启用后，你可以通过到达安全地点或让计时器到期来停止警报。禁用后，只有完成链条或关闭应用才能停止警报——对胁迫的防护更强。';

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
  String get settingsRedoOnboardingActiveSessionTooltip => '会话进行期间无法重新引导';

  @override
  String get settingsEmergencyNumberCountryPickerTitle => '选择紧急号码';

  @override
  String get settingsRedoOnboarding => '重新引导';

  @override
  String get settingsRedoOnboardingConfirm => '重新开始引导？';

  @override
  String get securitySessionEndPinBiometric => '为会话结束 PIN 码启用生物识别';

  @override
  String get securityAppPinBiometric => '为应用锁启用生物识别';

  @override
  String get launchPinTitle => '输入应用 PIN 码';

  @override
  String get launchPinBiometricReason => '解锁 Guardian Angela';

  @override
  String get launchPinIncorrect => 'PIN 码错误';

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
  String get stealthLockTaskLabel => '会话期间固定应用';

  @override
  String get stealthLockTaskSubtitle =>
      '防止在会话进行期间离开应用。在 Android 上将启用屏幕固定；在其他平台上此项无效。';

  @override
  String get homeTagline => '你的守护天使一直在你身边。';

  @override
  String get onboardingWelcomeGreeting => '你好，我是 Angela';

  @override
  String get onboardingWelcomeBodyFull =>
      '我是你的专属守护者。我会陪你同行，守护你的夜晚出行，并在情况不对时采取行动。';

  @override
  String get onboardingGetStarted => '开始使用';

  @override
  String get onboardingProfileNameLabel => '姓名';

  @override
  String get onboardingProfilePhoneLabel => '电话号码';

  @override
  String get onboardingProfilePhoneHelper => '将包含在紧急消息中。';

  @override
  String get onboardingEmergencyContactHeader => '紧急联系人';

  @override
  String get onboardingEmergencyContactPrompt => '如果出现意外，我们应该联系谁？';

  @override
  String get onboardingEmergencyContactAdd => '添加紧急联系人';

  @override
  String get onboardingPermissionsIntro => '这些权限可在会话期间保障你的安全。';

  @override
  String get onboardingPermissionsGrantAll => '全部授予';

  @override
  String get onboardingPermissionsRequired => '必需';

  @override
  String get onboardingPermissionsOptional => '可选';

  @override
  String get onboardingPermissionsMicrophone => '麦克风';

  @override
  String get onboardingPermissionsCamera => '相机';

  @override
  String get onboardingPermissionsNotificationDesc => '用于会话提醒和提醒通知所必需。';

  @override
  String get onboardingPermissionsSmsDesc => '发送紧急短信警报所必需。';

  @override
  String get onboardingPermissionsPhoneDesc => '拨打紧急电话和虚假来电所必需。';

  @override
  String get onboardingPermissionsLocationDesc => '开启 GPS 记录后将包含在紧急消息中。';

  @override
  String get onboardingPermissionsMicrophoneDesc => '用于求救时的录音。';

  @override
  String get onboardingPermissionsCameraDesc => '用于闪光灯 SOS 信号。';

  @override
  String get sessionInterruptedTitle => '会话已中断';

  @override
  String get sessionInterruptedBody =>
      '应用停止时有一个会话正在进行。会话状态已丢失——未恢复任何内容。我们显示此提示是为了让你知晓。';

  @override
  String get sessionInterruptedAcknowledge => '知道了';

  @override
  String sessionInterruptedMode(Object name) {
    return '模式：$name';
  }

  @override
  String sessionInterruptedStarted(Object time) {
    return '开始时间：$time';
  }

  @override
  String get sessionGpsDestinationTitle => '目的地';

  @override
  String get sessionGpsDestinationBody => '请输入用于 GPS 到达撤防触发器的目的地坐标。';

  @override
  String get sessionGpsDestinationLat => '纬度';

  @override
  String get sessionGpsDestinationLng => '经度';

  @override
  String get sessionGpsDestinationSkip => '本次会话跳过';

  @override
  String get sessionGpsDestinationConfirm => '使用目的地';

  @override
  String get sessionEndOverlayTitle => '结束会话？';

  @override
  String get sessionEndOverlayBody => '滑动以确认结束会话';

  @override
  String get sessionEndOverlaySwipeLabel => '滑动以结束';

  @override
  String get sessionEndOverlaySimBadge => '[SIM] 练习模式';

  @override
  String get sessionEndPinPromptTitle => '输入会话结束 PIN 码';

  @override
  String get sessionEndPinAppPinMismatch => '请使用会话结束 PIN 码，而非应用锁 PIN 码。';

  @override
  String get sessionEndPinIncorrect => 'PIN 码错误';

  @override
  String get sessionEndPinSimSkip => '跳过（仅模拟）';

  @override
  String get sessionEndSimDistressWouldFire => '求救链路将被触发（连续 5 次输错 PIN 码）';

  @override
  String get distressConfirmTitle => '已激活求救';

  @override
  String distressConfirmCountdown(int seconds) {
    return '点击以取消——你还有 $seconds 秒';
  }

  @override
  String get distressConfirmCancel => '点击以取消';

  @override
  String get distressConfirmFooter => '如不取消，求救链路将立即开始。';

  @override
  String get distressCancelPinPromptTitle => '输入会话结束 PIN 码';

  @override
  String distressCancelPinTimeoutLabel(int seconds) {
    return '剩余 $seconds 秒';
  }

  @override
  String get distressCancelPinIncorrect => 'PIN 码错误';

  @override
  String get distressCancelPinAppPinMismatch => '请使用会话结束 PIN 码，而非应用锁 PIN 码。';

  @override
  String get distressCancelPinSimSkip => '跳过（仅模拟）';

  @override
  String get distressCancelSimDistressWouldFire => '求救链路将被触发（连续 5 次输错 PIN 码）';

  @override
  String get distressCancelPinBack => '取消';

  @override
  String get simulationPinPromptTitle => '输入 PIN 码';

  @override
  String get simulationPinPromptBody => '练习输入你的会话结束 PIN 码';

  @override
  String get simulationPinPromptSkip => '跳过';

  @override
  String get simulationPinIncorrect => 'PIN 码错误';

  @override
  String simulationSummaryDuration(String duration) {
    return '时长：$duration';
  }

  @override
  String get simulationSummaryTimelineHeader => '事件时间线';

  @override
  String get simulationSummaryShare => '分享';

  @override
  String simulationSummaryMissedEventsBadge(int count) {
    return '错过：$count';
  }

  @override
  String simulationSummaryDistressBadge(int count) {
    return '求救：$count';
  }

  @override
  String simulationSummaryStepsFiredBadge(int count) {
    return '已触发步骤：$count';
  }

  @override
  String get simulationSummaryShareSubject => 'Guardian Angela 模拟摘要';

  @override
  String get notificationsChannelAlarm => '警报升级';

  @override
  String get notificationsChannelAlarmDescription => '可绕过勿扰模式的关键警报';

  @override
  String get notificationsChannelReminder => '伪装提醒';

  @override
  String get notificationsChannelReminderDescription => '会话进行期间的签到提醒';

  @override
  String get notificationsChannelFakeCall => '虚假来电';

  @override
  String get notificationsChannelFakeCallDescription => '全屏来电通知';

  @override
  String get notificationsChannelEnabled => '已启用';

  @override
  String get notificationsChannelDisabled => '已停用';

  @override
  String get notificationsChannelsHeader => '通知渠道';

  @override
  String get contactsImportFromDevice => '从通讯录导入';

  @override
  String get contactsImportNotSupported => '此平台不可用';

  @override
  String get contactsImportPermissionDenied => '通讯录访问被拒绝。请在系统设置中启用。';

  @override
  String get contactsDeleteAllMenu => '全部删除';

  @override
  String get contactsDeleteAllConfirmTitle => '删除所有联系人？';

  @override
  String get contactsDeleteAllConfirmBody => '此操作将移除每一位紧急联系人，且无法撤销。';

  @override
  String get contactsDeleteAllTypeConfirmTitle => '通过输入确认';

  @override
  String get contactsDeleteAllTypeConfirmHint => '输入 DELETE ALL 以继续';

  @override
  String get contactsDeleteAllTypeConfirmSentinel => 'DELETE ALL';

  @override
  String get contactsDeleteAllConfirmButton => '全部删除';

  @override
  String get modesBuiltinBadge => '内置';

  @override
  String get modesBuiltinNoDelete => '内置模式无法删除';

  @override
  String get sessionCompletedSimulationBanner => '模拟已完成';

  @override
  String get sessionCompletedViewEventLog => '查看事件日志';

  @override
  String get settingsGeneralHeader => '通用';

  @override
  String get settingsAppHeader => '应用';

  @override
  String get settingsConfigurationHeader => '配置';

  @override
  String get settingsThemeLabel => '主题';

  @override
  String get settingsLanguageLabel => '语言';

  @override
  String get settingsSecurityRow => '安全';

  @override
  String get settingsSecuritySubtitle => '应用 PIN 码、会话结束 PIN 码、胁迫 PIN 码';

  @override
  String get settingsStealthRow => '隐身';

  @override
  String get settingsStealthSummaryOff => '隐身：关闭';

  @override
  String get settingsStealthSummaryOn => '隐身：开启';

  @override
  String get settingsProfileRow => '个人资料';

  @override
  String get settingsModesRow => '模式';

  @override
  String get settingsDistressModesRow => '求救模式';

  @override
  String get settingsEventDefaultsRow => '步骤默认值';

  @override
  String get settingsGpsLoggingRow => 'GPS 记录';

  @override
  String get settingsRemindersRow => '提醒模板';

  @override
  String get settingsNotificationsRow => '通知';

  @override
  String get settingsHistoryRetentionRow => '历史与保留';

  @override
  String get settingsAboutRow => '关于';

  @override
  String get settingsFeedbackRow => '发送反馈';

  @override
  String get settingsBackupRow => '备份与恢复';

  @override
  String get settingsOssLicenses => '开源许可';

  @override
  String get settingsImportConfirmBody => '此操作将覆盖所有当前数据。是否继续？';

  @override
  String get securityAppPinTitle => '应用 PIN 码';

  @override
  String get securityAppPinBody => '每次打开应用时将其锁定。';

  @override
  String get securitySessionEndPinTitle => '会话结束 PIN 码';

  @override
  String get securitySessionEndPinBody => '撤防或结束进行中的会话所必需。';

  @override
  String get securityDuressPinTitle => '胁迫 PIN 码';

  @override
  String get securityDuressPinBody => '在任意提示处输入即可静默触发求救链路。';

  @override
  String get securityRemovePin => '移除';

  @override
  String get securityRemovePinPrompt => '请输入当前 PIN 码以将其移除。';

  @override
  String get securityRemovePinIncorrect => 'PIN 码错误';

  @override
  String get securityWhatIsThis => '这是什么？';

  @override
  String get securityAppPinInfo =>
      '在你打开应用时将其锁定。键盘会在任何界面之前出现。适用于他人短暂拿到你已解锁的手机的情况。';

  @override
  String get securitySessionEndPinInfo =>
      '撤防或结束进行中的安全会话所必需。没有它，夺取你手机的攻击者将无法停止链路。请设置一个与应用 PIN 码不同的密码。';

  @override
  String get securityDuressPinInfo =>
      '只要你在任意提示处输入此 PIN 码，求救链路就会静默运行——你的联系人会收到警报，警报也会就绪，而攻击者不会察觉。请选择一个与所有其他 PIN 码都不同的密码。';

  @override
  String get securityPinTimeoutLabel => 'PIN 码超时（秒）';

  @override
  String get securityWrongPinThresholdLabel => '升级前允许输错 PIN 码的次数';

  @override
  String get securityDeceptiveDialogToggle => '输错 PIN 码时显示欺骗性对话框';

  @override
  String get pinSetupEnterNew => '输入新 PIN 码';

  @override
  String get pinSetupConfirmNew => '确认新 PIN 码';

  @override
  String get pinSetupTooShort => 'PIN 码至少需要 4 位数字。';

  @override
  String get pinSetupCollision => '此 PIN 码与另一个已配置的 PIN 码冲突。';

  @override
  String get pinSetupSaved => 'PIN 码已保存';

  @override
  String get stealthEnabledLabel => '启用隐身模式';

  @override
  String get stealthFakeNameLabel => '伪装应用名称';

  @override
  String get stealthFakeIconLabel => '伪装图标';

  @override
  String get stealthNotificationDisguiseLabel => '通知伪装';

  @override
  String get stealthTimerDisplayLabel => '计时器显示';

  @override
  String get stealthSessionScreenLabel => '会话界面隐身';

  @override
  String get gpsLoggingEnabled => '会话期间记录 GPS';

  @override
  String get gpsLoggingIntervalLabel => '间隔';

  @override
  String get gpsLoggingAccuracyLabel => '精度';

  @override
  String get gpsLoggingAccuracyHigh => '高';

  @override
  String get gpsLoggingAccuracyBalanced => '均衡';

  @override
  String get gpsLoggingAccuracyLow => '低';

  @override
  String get gpsLoggingFormatLabel => '坐标格式';

  @override
  String get gpsLoggingFormatDecimal => '十进制';

  @override
  String get gpsLoggingFormatDms => '度分秒';

  @override
  String get gpsLoggingFormatAddress => 'Plus Code';

  @override
  String get gpsLoggingIncludeInSms => '在短信中附加位置';

  @override
  String get historyRetentionLogsLabel => '会话日志保留天数';

  @override
  String get historyRetentionLogsHelper => '超过此时长的日志将移入回收站。';

  @override
  String get historyRetentionTrashLabel => '回收站保留天数';

  @override
  String get historyRetentionTrashHelper => '回收站中的日志将在此时段后被永久删除。';

  @override
  String get historyRetentionUpdated => '保留设置已更新';

  @override
  String get historyRetentionPurgeNow => '立即清除';

  @override
  String historyRetentionPurged(Object count) {
    return '已清除 $count 条日志';
  }

  @override
  String get eventDefaultsCheckInHeader => '签到方式';

  @override
  String get eventDefaultsEscalationHeader => '升级步骤';

  @override
  String get eventDefaultsPanicHeader => '紧急触发器';

  @override
  String get templatesCreate => '创建模板';

  @override
  String get templatesEditTitle => '编辑模板';

  @override
  String get templatesCreateTitle => '新建模板';

  @override
  String get templatesNameLabel => '名称';

  @override
  String get templatesTitleLabel => '标题';

  @override
  String get templatesBodyLabel => '正文';

  @override
  String get templatesBuiltinNoDelete => '内置模板无法删除';

  @override
  String get templatesAddFromTemplate => '基于模板';

  @override
  String get templatesAddFromScratch => '从零开始';

  @override
  String templatesDeleteConfirmTitle(Object name) {
    return '删除“$name”？';
  }

  @override
  String get templatesDeleteConfirmBody => '此模板将被永久移除。';

  @override
  String get templatesEmptyAddFirst => '添加你的第一个模板';

  @override
  String get templatesPickFromBuiltinTitle => '选择一个内置模板';

  @override
  String get templatesIconLabel => '图标';

  @override
  String get templatesIconCalendar => '日历';

  @override
  String get templatesIconAppNotification => '应用通知';

  @override
  String get templatesIconFitness => '健身';

  @override
  String get templatesIconHealth => '健康';

  @override
  String get templatesIconFood => '餐饮';

  @override
  String get templatesIconCoffee => '咖啡';

  @override
  String get templatesIconBattery => '电池';

  @override
  String get templatesIconWeather => '天气';

  @override
  String get templatesPreviewHeading => '实时预览';

  @override
  String get templatesDiscardChangesTitle => '放弃更改？';

  @override
  String get templatesDiscardChangesBody => '未保存的编辑将丢失。';

  @override
  String get templatesDiscardKeep => '继续编辑';

  @override
  String get templatesDiscardDiscard => '放弃';

  @override
  String get notificationsTitle => '通知';

  @override
  String get notificationsStatusGranted => '已授予';

  @override
  String get notificationsStatusDenied => '已拒绝';

  @override
  String get notificationsStatusUnknown => '尚未询问';

  @override
  String get notificationsRequest => '请求权限';

  @override
  String get notificationsOpenSettings => '打开系统设置';

  @override
  String get profileFieldPhone => '电话号码';

  @override
  String get profileFieldDescription => '外貌描述';

  @override
  String get profileFieldMedicalConditions => '健康状况';

  @override
  String get profileFieldEmergencyInstructions => '紧急情况说明';

  @override
  String get aboutAuthor => '作者：Jonas Eschle';

  @override
  String get aboutEmail => 'guardian.angela.app@gmail.com';

  @override
  String get aboutPrivacyPolicy => '隐私政策';

  @override
  String get aboutTermsOfService => '服务条款';

  @override
  String get aboutSourceCode => '源代码';

  @override
  String get aboutSupport => '支持 / 捐赠';

  @override
  String get aboutLicenses => '开源许可';

  @override
  String get aboutTagline => '为 LGBTQ+ 群体的安全用心打造。';

  @override
  String get aboutTechnicalSection => '技术信息';

  @override
  String aboutBundleId(Object id) {
    return 'Bundle ID：$id';
  }

  @override
  String aboutPlatforms(Object list) {
    return '平台：$list';
  }

  @override
  String get feedbackHeading => '我们很想听听你的想法';

  @override
  String get feedbackCategoryLabel => '类别';

  @override
  String get feedbackCategoryBug => '错误报告';

  @override
  String get feedbackCategoryFeature => '功能建议';

  @override
  String get feedbackCategoryOther => '其他';

  @override
  String get feedbackEmailLabel => '电子邮箱（可选）';

  @override
  String get feedbackMessageLabel => '留言';

  @override
  String get feedbackIncludeLog => '包含上次会话日志';

  @override
  String get feedbackSent => '感谢你的反馈！';

  @override
  String get feedbackMessageRequired => '留言至少需要 10 个字符。';

  @override
  String get backupIncludeLogs => '包含会话日志';

  @override
  String get backupIncludeMedia => '包含媒体文件';

  @override
  String get backupExportButton => '导出';

  @override
  String get backupImportButton => '导入';

  @override
  String get backupOverwriteWarning => '导入将覆盖所有当前数据。';

  @override
  String get backupImportSuccess => '导入完成。请重启以应用。';

  @override
  String backupImportError(Object message) {
    return '导入失败：$message';
  }

  @override
  String get backupActiveSessionBanner => '会话进行期间无法备份。';

  @override
  String backupLastBackupAtLabel(Object when) {
    return '上次备份于 $when';
  }

  @override
  String get backupNeverExportedLabel => '尚无备份';

  @override
  String get pastEventsTitle => '历史会话';

  @override
  String get pastEventsTabReal => '真实';

  @override
  String get pastEventsTabSimulated => '模拟';

  @override
  String get pastEventsEmpty => '尚无会话';

  @override
  String get pastEventsDeleteConfirm => '删除会话日志？';

  @override
  String get pastEventsDetailShareText => '以文本分享';

  @override
  String get pastEventsDetailSharePdf => '以 PDF 分享';

  @override
  String get pastEventsDetailDelete => '删除';

  @override
  String get pastEventsOutcomeCompleted => '已完成';

  @override
  String get pastEventsOutcomeDistress => '求救';

  @override
  String get pastEventsOutcomeInterrupted => '已中断';

  @override
  String get pastEventsTrash => '回收站';

  @override
  String get pastEventsUndo => '撤销';

  @override
  String get pastEventsSoftDeleted => '已移入回收站';

  @override
  String get pastEventsDetailTitle => '会话日志';

  @override
  String get pastEventsDetailShare => '分享';

  @override
  String get contactUnsavedDiscardTitle => '放弃未保存的更改？';

  @override
  String get contactUnsavedDiscardKeep => '继续编辑';

  @override
  String get contactUnsavedDiscardDiscard => '放弃';

  @override
  String get modesDuplicate => '复制';

  @override
  String get modesDeleteConfirmTitle => '删除模式？';

  @override
  String modesDeleteConfirmBody(Object name) {
    return '$name 将被永久移除。';
  }

  @override
  String get modesDistressDefaultBadge => '默认';

  @override
  String get modesDistressSetDefault => '设为默认';

  @override
  String get modesDistressCantDeleteLast => '至少需要一个求救模式。';

  @override
  String get modesDistressInUse => '此求救模式正被另一个模式使用。';

  @override
  String get modesDistressTitle => '求救模式';

  @override
  String get validationNameTooShort => '姓名至少需要 2 个字符。';

  @override
  String get validationPhoneRequired => '电话号码为必填项。';

  @override
  String get validationChannelsRequired => '请至少选择一个渠道。';

  @override
  String get sessionHoldTouchToBegin => '触摸以开始';

  @override
  String sessionHoldReleaseCountdown(Object seconds) {
    return '倒计时：$seconds 秒';
  }

  @override
  String sessionHoldGraceCountdown(Object seconds) {
    return '宽限期：$seconds 秒——重新按住以保持安全';
  }

  @override
  String get sessionHoldAgain => '重新按住以保持安全';

  @override
  String sessionStepNextCheckIn(Object time) {
    return '下次签到将在 $time 后';
  }

  @override
  String sessionStepFakeCallActive(Object caller) {
    return '来自 $caller 的来电';
  }

  @override
  String get sessionStepFakeCallOpen => '打开通话界面';

  @override
  String sessionStepSimBlockedSms(Object count) {
    return '[SIM] 将向 $count 位联系人发送短信';
  }

  @override
  String get sessionStepSimBlockedPhone => '[SIM] 将呼叫紧急联系人';

  @override
  String get sessionStepSimBlockedEmergency => '[SIM] 将呼叫紧急服务';

  @override
  String get sessionStepSimBlockedAlarm => '[SIM] 警报本会以最大音量响起';

  @override
  String get sessionStartFailedTitle => '无法开始会话';

  @override
  String get sessionStartFailedBody => '请在开始前修复以下问题：';

  @override
  String get sessionQuickExitTitle => '快速退出';

  @override
  String get sessionQuickExitBody => '会话数据将被保留并加密。随时重新打开应用即可恢复。';

  @override
  String get sessionQuickExitConfirm => '退出应用';

  @override
  String get pastEventsRestore => '恢复';

  @override
  String get stepEditorWait => '等待（秒）';

  @override
  String get stepEditorDuration => '时长（秒）';

  @override
  String get stepEditorGrace => '宽限期（秒）';

  @override
  String get stepEditorRetryCount => '重试次数';

  @override
  String get stepEditorRandomize => '随机化时序（±20%）';

  @override
  String get stepEditorRemove => '移除步骤';

  @override
  String get eventDefaultsHoldStyle => '长按样式';

  @override
  String get eventDefaultsHoldSensitivity => '松开灵敏度';

  @override
  String get eventDefaultsHoldVibrate => '松开时振动';

  @override
  String get eventDefaultsHoldSound => '松开时发声';

  @override
  String get eventDefaultsBlackScreen => '黑屏遮罩';

  @override
  String get eventDefaultsReminderRandomInterval => '随机化间隔';

  @override
  String get eventDefaultsReminderRandomTemplate => '随机化模板顺序';

  @override
  String get eventDefaultsReminderResetOnEarly => '提前签到时重置';

  @override
  String get eventDefaultsCountdownStyle => '倒计时样式';

  @override
  String get eventDefaultsCountdownVibrate => '振动';

  @override
  String get eventDefaultsCountdownSound => '声音';

  @override
  String get eventDefaultsFakeCallStyle => '来电样式';

  @override
  String get eventDefaultsFakeCallCallerName => '来电者姓名';

  @override
  String get eventDefaultsFakeCallRingDuration => '响铃时长（秒）';

  @override
  String get eventDefaultsFakeCallDeclineIsSafe => '拒接视为安全';

  @override
  String get eventDefaultsFakeCallVoiceOutput => '语音输出';

  @override
  String get eventDefaultsSmsChannel => '渠道';

  @override
  String get eventDefaultsSmsIncludeLocation => '包含位置';

  @override
  String get eventDefaultsSmsIncludeMedical => '包含医疗信息';

  @override
  String get eventDefaultsSmsAutoRecord => '发送前录音';

  @override
  String get eventDefaultsSmsRecordDuration => '录音时长（秒）';

  @override
  String get eventDefaultsLoudAlarmVolume => '音量';

  @override
  String get eventDefaultsLoudAlarmSound => '声音';

  @override
  String get eventDefaultsLoudAlarmFlashScreen => '屏幕闪烁';

  @override
  String get eventDefaultsLoudAlarmFlashLight => '闪烁相机闪光灯';

  @override
  String get eventDefaultsLoudAlarmGradual => '音量渐强';

  @override
  String get eventDefaultsCallEmergencyNumber => '紧急号码（覆盖）';

  @override
  String get eventDefaultsCallEmergencyConfirm => '显示确认倒计时';

  @override
  String get eventDefaultsCallEmergencyConfirmDuration => '确认秒数';

  @override
  String get eventDefaultsCallEmergencySmsFirst => '先发送位置短信';

  @override
  String get eventDefaultsPhonePrimaryContact => '主要联系人（id）';

  @override
  String get eventDefaultsHardwareButton => '按键';

  @override
  String get eventDefaultsHardwarePattern => '按压模式';

  @override
  String get eventDefaultsHardwarePressCount => '按压次数';

  @override
  String get eventDefaultsHardwareLongDuration => '长按时长（秒）';

  @override
  String get pastEventsTrashTitle => '回收站';

  @override
  String get pastEventsTrashEmpty => '回收站为空';

  @override
  String get pastEventsTrashEmptyAll => '清空回收站';

  @override
  String get pastEventsTrashEmptyAllConfirmTitle => '清空回收站？';

  @override
  String get pastEventsTrashEmptyAllConfirmBody =>
      '请在下方输入 EMPTY TRASH 以确认。此操作将永久删除每一条已回收的日志。';

  @override
  String pastEventsTrashEmptyAllSuccess(Object count) {
    return '回收站已清空（$count 条日志）';
  }

  @override
  String pastEventsTrashRetentionNote(int days) {
    return '回收站中的日志将在 $days 天后被永久删除。';
  }

  @override
  String pastEventsTrashRemainingDays(int days) {
    return '距永久删除还有 $days 天';
  }

  @override
  String get pastEventsTrashDeletePermanently => '永久删除';

  @override
  String get pastEventsTrashDeletePermanentlyBody => '此操作无法撤销。';

  @override
  String sessionEmergencyConfirmTitle(String number, int seconds) {
    return '将在 $seconds 秒后呼叫 $number';
  }

  @override
  String get sessionEmergencyConfirmSwipe => '滑动以取消';

  @override
  String get sessionEmergencyConfirmKeep => '继续呼叫';

  @override
  String get sessionEmergencyConfirmSimBadge => '[SIM] 练习模式';

  @override
  String get sessionEmergencyConfirmSimCancelled => '模拟取消——本不会拨打电话';

  @override
  String get swipeSliderSemantics => '滑动以确认';

  @override
  String get homeWidgetStatusIdle => '待机';

  @override
  String get homeWidgetStatusSession => '会话进行中';

  @override
  String get homeWidgetStatusSim => '模拟进行中';

  @override
  String get homeWidgetQuickExit => '快速退出';

  @override
  String get homeWidgetFakeCall => '模拟来电';
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
  String get commonGotIt => '知道了';

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
  String get onboardingUseSimNumber => '使用我的 SIM 卡號碼';

  @override
  String onboardingUseSimNumberHint(Object number) {
    return '$number';
  }

  @override
  String get onboardingUseSimNumberUnsupported => 'iOS 不支援此功能';

  @override
  String get onboardingUseSimNumberUnavailable => '無法讀取號碼';

  @override
  String get onboardingUseSimNumberPermissionDenied => '權限遭拒';

  @override
  String get sessionTitle => '守護中';

  @override
  String get sessionDisarm => '我很安全';

  @override
  String get sessionDisarmStealth => '不必找 Angela';

  @override
  String get homeChainSummaryTitle => '鏈路摘要';

  @override
  String get homeChainSummaryEmpty => '此模式尚無步驟——點選模式即可編輯。';

  @override
  String homeChainSummaryTimingTitle(Object name) {
    return '步驟:$name';
  }

  @override
  String homeChainSummaryWait(Object seconds) {
    return '等待:$seconds 秒';
  }

  @override
  String homeChainSummaryDuration(Object seconds) {
    return '進行中:$seconds 秒';
  }

  @override
  String homeChainSummaryGrace(Object seconds) {
    return '寬限期:$seconds 秒';
  }

  @override
  String homeChainSummaryRetry(Object count) {
    return '重試次數:$count';
  }

  @override
  String homeChainSummaryNextStep(Object name) {
    return '下一步:$name';
  }

  @override
  String get homeChainSummaryNextStepNone => '下一步:鏈路結束';

  @override
  String get homeChainSummaryClose => '關閉';

  @override
  String get chainStepNameHoldButton => '長按以保持安全';

  @override
  String get chainStepNameDisguisedReminder => '偽裝提醒';

  @override
  String get chainStepNameCountdownWarning => '倒數警告';

  @override
  String get chainStepNameFakeCall => '假來電';

  @override
  String get chainStepNameSmsContact => '簡訊聯絡人';

  @override
  String get chainStepNamePhoneCallContact => '電話聯絡人';

  @override
  String get chainStepNameLoudAlarm => '高聲警報';

  @override
  String get chainStepNameCallEmergency => '緊急呼救';

  @override
  String get chainStepNameHardwareButton => '硬體按鍵';

  @override
  String get homeChecklistTitle => '安全設定';

  @override
  String get homeChecklistDismissTooltip => '關閉清單';

  @override
  String get homeChecklistExpandTooltip => '展開清單';

  @override
  String get homeChecklistCollapseTooltip => '收合清單';

  @override
  String homeChecklistProgress(Object done, Object total) {
    return '已完成 $done/$total';
  }

  @override
  String get homeChecklistAllDoneBanner => '全部就緒——你已受到守護!';

  @override
  String get homeChecklistInfoTooltip => '為什麼這很重要';

  @override
  String get homeChecklistGotIt => '我知道了';

  @override
  String get homeChecklistGoThere => '前往';

  @override
  String get homeChecklistItem1Title => '新增緊急聯絡人';

  @override
  String get homeChecklistItem2Title => '設定會話結束 PIN';

  @override
  String get homeChecklistItem3Title => '設定隱身模式';

  @override
  String get homeChecklistItem4Title => '試一次模擬';

  @override
  String get homeChecklistItem5Title => '自訂一個安全模式';

  @override
  String get homeChecklistItem6Title => '授予所需權限';

  @override
  String get checklistInfo1Body =>
      '緊急聯絡人是你未能按時報平安時 Guardian Angela 會傳訊息與撥打電話的人。沒有至少一位聯絡人,鏈路就無處升級。';

  @override
  String get checklistInfo2Body =>
      '會話結束 PIN 可防止有人偷偷結束進行中的會話。他們仍可嘗試,但連續輸錯五次將靜默觸發你的求救鏈路。';

  @override
  String get checklistInfo3Body =>
      '隱身模式會把進行中的會話偽裝成螢幕上不起眼的東西——音樂播放器、暫停的計時器、空白的鎖定畫面。當身旁的人不能讓你看見安全應用時使用。';

  @override
  String get checklistInfo4Body =>
      '模擬會從頭到尾跑完你的安全模式,但不會真的傳簡訊、撥打電話或響起警報。用它在真正需要前熟悉時間流程。';

  @override
  String get checklistInfo5Body =>
      '自訂模式可針對特定情境調整步驟、時間與觸發條件——夜路回家、第一次約會、值晚班。內建的兩個模式只是起點,而非終點。';

  @override
  String get checklistInfo6Body =>
      '沒有通知權限,Guardian Angela 無法維持常駐前景狀態、無法傳送偽裝提醒,也無法在鏈路即將升級時提醒你。';

  @override
  String get checklistTutorial3Body =>
      '開啟隱身預設並打開「啟用隱身模式」。在這裡可以選擇一個偽裝的音樂品牌、隱藏會話計時器,或偽裝主畫面圖示。';

  @override
  String get checklistTutorial4Body =>
      '選定模式後,在主畫面點擊有外框的「模擬」按鈕。會話會以橘色外框和 [SIM] 標籤運行——任何資訊都不會離開你的手機。';

  @override
  String get checklistTutorial5Body =>
      '開啟「模式」頁,既可編輯內建模式(散步 / 約會),也可從零開始建立。調整鏈路、加入假來電、設定自訂時長。';

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
  String get sessionPausedIncomingCall => '已暫停 — 來電';

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
  String get sessionReminderEarlyCheckInHint => '點按立即報到';

  @override
  String get sessionReminderDefaultButton => '好';

  @override
  String get sessionReminderTapWordHint => '點按繼續';

  @override
  String get sessionReminderSwipeLabel => '滑動關閉';

  @override
  String get sessionReminderDismissLabel => '關閉';

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
  String get fakeCallBrandAndroid => '電話';

  @override
  String get fakeCallBrandIos => '電話';

  @override
  String get fakeCallBrandMinimal => '通話';

  @override
  String get fakeCallDeclineSafeLabel => '拒接(我很安全)';

  @override
  String get fakeCallDeclineUnsafeLabel => '拒接(保持警戒)';

  @override
  String get fakeCallHoldForDistress => '按住 5 秒以求救';

  @override
  String fakeCallVoicePrompt(String name) {
    return '語音提示:$name';
  }

  @override
  String fakeCallVibrationLabel(String pattern) {
    return '震動:$pattern';
  }

  @override
  String get fakeCallVibrationPatternDefault => '預設';

  @override
  String get fakeCallSlideToAnswerHint => '滑動以接聽';

  @override
  String fakeCallActiveDuration(String mm, String ss) {
    return '$mm:$ss';
  }

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
  String get contactFormIosSmsWarning => '在 iOS 上,簡訊會開啟「訊息」App,你必須手動點選「傳送」。';

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
  String get stepConfigTimingHeader => '計時';

  @override
  String get stepConfigEventHeader => '事件設定';

  @override
  String get stepConfigAdvancedHeader => '重試與進階';

  @override
  String get stepFieldWait => '觸發前等待（秒）';

  @override
  String get stepFieldDuration => '活動時長（秒）';

  @override
  String get stepFieldGrace => '寬限期（秒）';

  @override
  String get stepFieldRetryCount => '重試次數';

  @override
  String get stepFieldRandomize => '隨機化計時（±20%）';

  @override
  String get stepDuplicate => '複製步驟';

  @override
  String get stepResetDefaults => '重設為預設值';

  @override
  String get smsContactRecipientsHeader => '要通知的聯絡人';

  @override
  String get smsContactSummaryAll => '收件人：所有已啟用的聯絡人';

  @override
  String get smsContactSummaryNone => '未選擇收件人';

  @override
  String smsContactSummaryTo(Object names) {
    return '收件人：$names';
  }

  @override
  String get smsContactChannelDisabledTooltip => '此聯絡人未啟用此管道——編輯聯絡人以新增此管道。';

  @override
  String get smsContactEmptyAddPrompt => '尚未新增聯絡人——在「聯絡人」中新增一位';

  @override
  String get safetyOptionsHeader => '安全選項';

  @override
  String get safetyOptionsDistressModeTitle => '求救模式';

  @override
  String get safetyOptionsDistressModeUseDefault => '使用預設求救模式';

  @override
  String safetyOptionsDistressModeUseDefaultNamed(Object name) {
    return '使用預設（$name）';
  }

  @override
  String get safetyOptionsDistressModeInfo =>
      '當求救觸發器觸發時（脅迫 PIN、硬體緊急按鍵或錯誤 PIN 次數超限），此模式的鏈條會被所選求救模式的鏈條取代。保持預設即可使用應用程式全域的求救模式。';

  @override
  String get safetyOptionsManageDistressModes => '管理求救模式';

  @override
  String get safetyOptionsDistressTriggersTitle => '求救觸發器';

  @override
  String get safetyOptionsDistressTriggersInfo =>
      '求救觸發器會立即啟動求救鏈條，與主鏈條並行執行。硬體緊急按鍵會依照所設定的按鍵模式監看實體按鍵。';

  @override
  String get safetyOptionsDistressTriggersEmpty => '尚無求救觸發器';

  @override
  String get safetyOptionsAddHardwarePanic => '新增硬體緊急按鍵';

  @override
  String safetyOptionsTriggerHardwareRepeat(Object button, Object count) {
    return '$button：按 $count 次';
  }

  @override
  String safetyOptionsTriggerHardwareLong(Object button, Object seconds) {
    return '$button：長按 $seconds 秒';
  }

  @override
  String get safetyOptionsButtonVolumeUp => '音量加';

  @override
  String get safetyOptionsButtonVolumeDown => '音量減';

  @override
  String get safetyOptionsTriggerPattern => '按鍵模式';

  @override
  String get safetyOptionsPatternRepeat => '重複按壓';

  @override
  String get safetyOptionsPatternLong => '長按';

  @override
  String get safetyOptionsTriggerButton => '按鍵';

  @override
  String get safetyOptionsTriggerPressCount => '按壓次數';

  @override
  String get safetyOptionsTriggerHoldDuration => '長按時長（秒）';

  @override
  String get safetyOptionsDisarmTriggersTitle => '解除觸發器';

  @override
  String get safetyOptionsGpsArrivalTitle => 'GPS 抵達解除';

  @override
  String get safetyOptionsGpsArrivalInfo =>
      '當你抵達目的地所設定的半徑範圍內時，工作階段會自動結束。目的地在開始工作階段時設定。';

  @override
  String get safetyOptionsGpsArrivalRadius => '抵達半徑';

  @override
  String safetyOptionsRadiusMeters(Object meters) {
    return '$meters 公尺';
  }

  @override
  String safetyOptionsRadiusKilometers(Object km) {
    return '$km 公里';
  }

  @override
  String get safetyOptionsDestinationSource => '目的地';

  @override
  String get safetyOptionsDestinationPrompt => '在工作階段開始時設定目的地';

  @override
  String get safetyOptionsDestinationFixed => '固定座標';

  @override
  String get safetyOptionsLatitude => '緯度';

  @override
  String get safetyOptionsLongitude => '經度';

  @override
  String get safetyOptionsTimerDisarmTitle => '計時器解除';

  @override
  String get safetyOptionsTimerDisarmInfo => '無論是否已開始升級，工作階段都會在所設定的時間後自動結束。';

  @override
  String get safetyOptionsTimerDuration => '時長';

  @override
  String safetyOptionsDurationMinutes(Object minutes) {
    return '$minutes 分鐘';
  }

  @override
  String safetyOptionsDurationHoursMinutes(Object hours, Object minutes) {
    return '$hours 小時 $minutes 分鐘';
  }

  @override
  String get safetyOptionsGpsLoggingTitle => 'GPS 記錄';

  @override
  String get safetyOptionsGpsLoggingInfo =>
      '選擇此模式是否在工作階段期間記錄你的位置。「繼承」使用你的全域 GPS 設定；「自訂」會為此模式覆寫這些設定；「關閉」會完全停用記錄。';

  @override
  String get safetyOptionsStealthTitle => '隱身';

  @override
  String get safetyOptionsStealthInfo =>
      '選擇此模式是否在工作階段期間偽裝應用程式。「繼承」使用你的全域隱身設定；「自訂」會為此模式覆寫這些設定；「關閉」會完全停用隱身。';

  @override
  String get safetyOptionsTriStateInherit => '繼承';

  @override
  String get safetyOptionsTriStateCustom => '自訂';

  @override
  String get safetyOptionsTriStateOff => '關閉';

  @override
  String get safetyOptionsLocalTemplatesTitle => '本機範本';

  @override
  String get safetyOptionsLocalTemplatesInfo =>
      '本機範本僅為此模式新增至全域提醒範本集合中。可用於此模式專屬的偽裝提醒步驟。';

  @override
  String get safetyOptionsLocalTemplatesEmpty => '尚無本機範本';

  @override
  String get safetyOptionsAddTemplate => '新增範本';

  @override
  String get safetyOptionsManageTemplates => '管理提醒範本';

  @override
  String get safetyOptionsEventDefaultsTitle => '事件預設值';

  @override
  String get safetyOptionsEventDefaultsInfo =>
      '事件預設值設定每種步驟類型的初始設定。「繼承」使用你的全域預設值；「自訂」會為此模式中沒有自身設定的步驟覆寫這些預設值。';

  @override
  String get safetyOptionsEventDefaultsTwoStateInherit => '繼承';

  @override
  String get safetyOptionsAllowDisarmAsDistressTitle => '在求救啟用期間允許解除';

  @override
  String get safetyOptionsAllowDisarmAsDistressInfo =>
      '啟用後，你可以透過抵達安全地點或讓計時器到期來停止警報。停用後，只有完成鏈條或關閉應用程式才能停止警報——對脅迫的防護更強。';

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
  String get settingsRedoOnboardingActiveSessionTooltip => '守護進行中無法重新引導';

  @override
  String get settingsEmergencyNumberCountryPickerTitle => '選擇緊急號碼';

  @override
  String get settingsRedoOnboarding => '重新引導';

  @override
  String get settingsRedoOnboardingConfirm => '重新開始引導？';

  @override
  String get securitySessionEndPinBiometric => '使用生物辨識解鎖結束守護 PIN';

  @override
  String get securityAppPinBiometric => '為應用程式鎖定使用生物辨識';

  @override
  String get launchPinTitle => '輸入應用程式 PIN';

  @override
  String get launchPinBiometricReason => '解鎖 Guardian Angela';

  @override
  String get launchPinIncorrect => 'PIN 錯誤';

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

  @override
  String get stealthLockTaskLabel => '守護期間鎖定 App';

  @override
  String get stealthLockTaskSubtitle =>
      '守護進行中防止離開 App。在 Android 上會啟用螢幕固定;在其他平台上則不會有作用。';

  @override
  String get homeTagline => '你的天使,守護有你。';

  @override
  String get onboardingWelcomeGreeting => '嗨,我是 Angela';

  @override
  String get onboardingWelcomeBodyFull =>
      '我是你的專屬守護者。我會陪你同行、守望你的夜晚外出,並在情況不對時採取行動。';

  @override
  String get onboardingGetStarted => '開始使用';

  @override
  String get onboardingProfileNameLabel => '姓名';

  @override
  String get onboardingProfilePhoneLabel => '電話號碼';

  @override
  String get onboardingProfilePhoneHelper => '將包含在緊急訊息中。';

  @override
  String get onboardingEmergencyContactHeader => '緊急聯絡人';

  @override
  String get onboardingEmergencyContactPrompt => '若情況不對,我們該聯絡誰?';

  @override
  String get onboardingEmergencyContactAdd => '新增緊急聯絡人';

  @override
  String get onboardingPermissionsIntro => '這些權限可在守護期間保護你的安全。';

  @override
  String get onboardingPermissionsGrantAll => '全部授予';

  @override
  String get onboardingPermissionsRequired => '必要';

  @override
  String get onboardingPermissionsOptional => '選用';

  @override
  String get onboardingPermissionsMicrophone => '麥克風';

  @override
  String get onboardingPermissionsCamera => '相機';

  @override
  String get onboardingPermissionsNotificationDesc => '用於守護警示與提醒,為必要權限。';

  @override
  String get onboardingPermissionsSmsDesc => '傳送緊急簡訊警示所需。';

  @override
  String get onboardingPermissionsPhoneDesc => '撥打緊急電話與假來電所需。';

  @override
  String get onboardingPermissionsLocationDesc => '開啟 GPS 紀錄時,將包含在緊急訊息中。';

  @override
  String get onboardingPermissionsMicrophoneDesc => '用於求救期間錄製音訊。';

  @override
  String get onboardingPermissionsCameraDesc => '用於閃光燈 SOS 求救訊號。';

  @override
  String get sessionInterruptedTitle => '守護已中斷';

  @override
  String get sessionInterruptedBody =>
      'App 停止時有守護正在進行。守護狀態已遺失——未還原任何內容。我們顯示此訊息只是讓你知道。';

  @override
  String get sessionInterruptedAcknowledge => '我知道了';

  @override
  String sessionInterruptedMode(Object name) {
    return '模式:$name';
  }

  @override
  String sessionInterruptedStarted(Object time) {
    return '開始時間:$time';
  }

  @override
  String get sessionGpsDestinationTitle => '目的地';

  @override
  String get sessionGpsDestinationBody => '請輸入目的地座標,做為 GPS 抵達解除的觸發條件。';

  @override
  String get sessionGpsDestinationLat => '緯度';

  @override
  String get sessionGpsDestinationLng => '經度';

  @override
  String get sessionGpsDestinationSkip => '本次守護略過';

  @override
  String get sessionGpsDestinationConfirm => '使用此目的地';

  @override
  String get sessionEndOverlayTitle => '結束守護?';

  @override
  String get sessionEndOverlayBody => '滑動以確認你要結束守護';

  @override
  String get sessionEndOverlaySwipeLabel => '滑動以結束';

  @override
  String get sessionEndOverlaySimBadge => '[SIM] 練習模式';

  @override
  String get sessionEndPinPromptTitle => '輸入結束守護 PIN';

  @override
  String get sessionEndPinAppPinMismatch => '請使用結束守護 PIN,而非 App 鎖定 PIN。';

  @override
  String get sessionEndPinIncorrect => 'PIN 錯誤';

  @override
  String get sessionEndPinSimSkip => '略過(僅模擬)';

  @override
  String get sessionEndSimDistressWouldFire => '求救鏈路將會觸發(輸錯 5 次 PIN)';

  @override
  String get distressConfirmTitle => '已啟動求救';

  @override
  String distressConfirmCountdown(int seconds) {
    return '點按以取消——你還有 $seconds 秒';
  }

  @override
  String get distressConfirmCancel => '點按以取消';

  @override
  String get distressConfirmFooter => '若未取消,求救鏈路將立即開始。';

  @override
  String get distressCancelPinPromptTitle => '輸入結束守護 PIN';

  @override
  String distressCancelPinTimeoutLabel(int seconds) {
    return '剩餘 $seconds 秒';
  }

  @override
  String get distressCancelPinIncorrect => 'PIN 錯誤';

  @override
  String get distressCancelPinAppPinMismatch => '請使用結束守護 PIN,而非 App 鎖定 PIN。';

  @override
  String get distressCancelPinSimSkip => '略過(僅模擬)';

  @override
  String get distressCancelSimDistressWouldFire => '求救鏈路將會觸發(輸錯 5 次 PIN)';

  @override
  String get distressCancelPinBack => '取消';

  @override
  String get simulationPinPromptTitle => '輸入 PIN';

  @override
  String get simulationPinPromptBody => '練習輸入你的結束守護 PIN';

  @override
  String get simulationPinPromptSkip => '略過';

  @override
  String get simulationPinIncorrect => 'PIN 錯誤';

  @override
  String simulationSummaryDuration(String duration) {
    return '時長:$duration';
  }

  @override
  String get simulationSummaryTimelineHeader => '事件時間軸';

  @override
  String get simulationSummaryShare => '分享';

  @override
  String simulationSummaryMissedEventsBadge(int count) {
    return '錯過:$count';
  }

  @override
  String simulationSummaryDistressBadge(int count) {
    return '求救:$count';
  }

  @override
  String simulationSummaryStepsFiredBadge(int count) {
    return '已觸發步驟:$count';
  }

  @override
  String get simulationSummaryShareSubject => 'Guardian Angela 模擬摘要';

  @override
  String get notificationsChannelAlarm => '警報升級';

  @override
  String get notificationsChannelAlarmDescription => '可略過勿擾模式的重要警示';

  @override
  String get notificationsChannelReminder => '偽裝提醒';

  @override
  String get notificationsChannelReminderDescription => '守護進行中的報平安提醒';

  @override
  String get notificationsChannelFakeCall => '假來電';

  @override
  String get notificationsChannelFakeCallDescription => '全螢幕來電通知';

  @override
  String get notificationsChannelEnabled => '已啟用';

  @override
  String get notificationsChannelDisabled => '已停用';

  @override
  String get notificationsChannelsHeader => '通知管道';

  @override
  String get contactsImportFromDevice => '從通訊錄匯入';

  @override
  String get contactsImportNotSupported => '此平台不支援';

  @override
  String get contactsImportPermissionDenied => '通訊錄存取遭拒,請於系統設定中啟用。';

  @override
  String get contactsDeleteAllMenu => '全部刪除';

  @override
  String get contactsDeleteAllConfirmTitle => '刪除所有聯絡人?';

  @override
  String get contactsDeleteAllConfirmBody => '這將移除每一位緊急聯絡人,且無法復原。';

  @override
  String get contactsDeleteAllTypeConfirmTitle => '輸入文字以確認';

  @override
  String get contactsDeleteAllTypeConfirmHint => '輸入「DELETE ALL」以繼續';

  @override
  String get contactsDeleteAllTypeConfirmSentinel => 'DELETE ALL';

  @override
  String get contactsDeleteAllConfirmButton => '全部刪除';

  @override
  String get modesBuiltinBadge => '內建';

  @override
  String get modesBuiltinNoDelete => '內建模式無法刪除';

  @override
  String get sessionCompletedSimulationBanner => '模擬已完成';

  @override
  String get sessionCompletedViewEventLog => '檢視事件紀錄';

  @override
  String get settingsGeneralHeader => '一般';

  @override
  String get settingsAppHeader => '應用程式';

  @override
  String get settingsConfigurationHeader => '設定';

  @override
  String get settingsThemeLabel => '主題';

  @override
  String get settingsLanguageLabel => '語言';

  @override
  String get settingsSecurityRow => '安全性';

  @override
  String get settingsSecuritySubtitle => 'App PIN、結束守護 PIN、脅迫 PIN';

  @override
  String get settingsStealthRow => '隱身模式';

  @override
  String get settingsStealthSummaryOff => '隱身模式:關閉';

  @override
  String get settingsStealthSummaryOn => '隱身模式:開啟';

  @override
  String get settingsProfileRow => '個人資料';

  @override
  String get settingsModesRow => '模式';

  @override
  String get settingsDistressModesRow => '求救模式';

  @override
  String get settingsEventDefaultsRow => '步驟預設值';

  @override
  String get settingsGpsLoggingRow => 'GPS 紀錄';

  @override
  String get settingsRemindersRow => '提醒範本';

  @override
  String get settingsNotificationsRow => '通知';

  @override
  String get settingsHistoryRetentionRow => '紀錄與保留';

  @override
  String get settingsAboutRow => '關於';

  @override
  String get settingsFeedbackRow => '傳送意見回饋';

  @override
  String get settingsBackupRow => '備份與還原';

  @override
  String get settingsOssLicenses => '開放原始碼授權';

  @override
  String get settingsImportConfirmBody => '這將覆寫所有目前的資料。是否繼續?';

  @override
  String get securityAppPinTitle => 'App PIN';

  @override
  String get securityAppPinBody => '每次開啟 App 時鎖定。';

  @override
  String get securitySessionEndPinTitle => '結束守護 PIN';

  @override
  String get securitySessionEndPinBody => '解除或結束進行中的守護時所需。';

  @override
  String get securityDuressPinTitle => '脅迫 PIN';

  @override
  String get securityDuressPinBody => '在任何提示輸入即可靜默觸發求救鏈路。';

  @override
  String get securityRemovePin => '移除';

  @override
  String get securityRemovePinPrompt => '請輸入目前的 PIN 以將其移除。';

  @override
  String get securityRemovePinIncorrect => 'PIN 錯誤';

  @override
  String get securityWhatIsThis => '這是什麼?';

  @override
  String get securityAppPinInfo =>
      '在你開啟 App 時鎖定。鍵盤會在任何畫面之前出現。若有人短暫拿到你已解鎖的手機,此功能很有用。';

  @override
  String get securitySessionEndPinInfo =>
      '解除或結束進行中的安全守護時所需。少了它,搶走你手機的人無法停止鏈路。請設定與 App PIN 不同的密碼。';

  @override
  String get securityDuressPinInfo =>
      '若你在任何提示輸入此 PIN,求救鏈路會靜默執行——你的聯絡人會收到警示、警報會待命,而對方不會察覺。請選擇與其他所有 PIN 都不同的密碼。';

  @override
  String get securityPinTimeoutLabel => 'PIN 逾時(秒)';

  @override
  String get securityWrongPinThresholdLabel => '升級前可輸錯 PIN 的次數';

  @override
  String get securityDeceptiveDialogToggle => '輸錯 PIN 時顯示誘導性對話框';

  @override
  String get pinSetupEnterNew => '輸入新 PIN';

  @override
  String get pinSetupConfirmNew => '確認新 PIN';

  @override
  String get pinSetupTooShort => 'PIN 至少需 4 位數。';

  @override
  String get pinSetupCollision => '此 PIN 與另一組已設定的 PIN 衝突。';

  @override
  String get pinSetupSaved => 'PIN 已儲存';

  @override
  String get stealthEnabledLabel => '啟用隱身模式';

  @override
  String get stealthFakeNameLabel => '偽裝 App 名稱';

  @override
  String get stealthFakeIconLabel => '偽裝圖示';

  @override
  String get stealthNotificationDisguiseLabel => '通知偽裝';

  @override
  String get stealthTimerDisplayLabel => '計時器顯示';

  @override
  String get stealthSessionScreenLabel => '守護畫面隱身';

  @override
  String get gpsLoggingEnabled => '守護期間記錄 GPS';

  @override
  String get gpsLoggingIntervalLabel => '間隔';

  @override
  String get gpsLoggingAccuracyLabel => '精確度';

  @override
  String get gpsLoggingAccuracyHigh => '高';

  @override
  String get gpsLoggingAccuracyBalanced => '平衡';

  @override
  String get gpsLoggingAccuracyLow => '低';

  @override
  String get gpsLoggingFormatLabel => '座標格式';

  @override
  String get gpsLoggingFormatDecimal => '十進位';

  @override
  String get gpsLoggingFormatDms => '度分秒';

  @override
  String get gpsLoggingFormatAddress => 'Plus Code';

  @override
  String get gpsLoggingIncludeInSms => '在簡訊附加位置';

  @override
  String get historyRetentionLogsLabel => '守護紀錄保留(天)';

  @override
  String get historyRetentionLogsHelper => '超過此天數的紀錄會移入垃圾桶。';

  @override
  String get historyRetentionTrashLabel => '垃圾桶保留(天)';

  @override
  String get historyRetentionTrashHelper => '垃圾桶中的紀錄會在此期限後永久刪除。';

  @override
  String get historyRetentionUpdated => '保留設定已更新';

  @override
  String get historyRetentionPurgeNow => '立即清除';

  @override
  String historyRetentionPurged(Object count) {
    return '已清除 $count 筆紀錄';
  }

  @override
  String get eventDefaultsCheckInHeader => '報平安方式';

  @override
  String get eventDefaultsEscalationHeader => '升級步驟';

  @override
  String get eventDefaultsPanicHeader => '緊急觸發';

  @override
  String get templatesCreate => '建立範本';

  @override
  String get templatesEditTitle => '編輯範本';

  @override
  String get templatesCreateTitle => '新範本';

  @override
  String get templatesNameLabel => '名稱';

  @override
  String get templatesTitleLabel => '標題';

  @override
  String get templatesBodyLabel => '內文';

  @override
  String get templatesBuiltinNoDelete => '內建範本無法刪除';

  @override
  String get templatesAddFromTemplate => '從範本建立';

  @override
  String get templatesAddFromScratch => '從零開始';

  @override
  String templatesDeleteConfirmTitle(Object name) {
    return '刪除「$name」?';
  }

  @override
  String get templatesDeleteConfirmBody => '此範本將被永久移除。';

  @override
  String get templatesEmptyAddFirst => '新增你的第一個範本';

  @override
  String get templatesPickFromBuiltinTitle => '選擇內建範本';

  @override
  String get templatesIconLabel => '圖示';

  @override
  String get templatesIconCalendar => '行事曆';

  @override
  String get templatesIconAppNotification => 'App 通知';

  @override
  String get templatesIconFitness => '健身';

  @override
  String get templatesIconHealth => '健康';

  @override
  String get templatesIconFood => '食物';

  @override
  String get templatesIconCoffee => '咖啡';

  @override
  String get templatesIconBattery => '電量';

  @override
  String get templatesIconWeather => '天氣';

  @override
  String get templatesPreviewHeading => '即時預覽';

  @override
  String get templatesDiscardChangesTitle => '捨棄變更?';

  @override
  String get templatesDiscardChangesBody => '未儲存的編輯內容將會遺失。';

  @override
  String get templatesDiscardKeep => '繼續編輯';

  @override
  String get templatesDiscardDiscard => '捨棄';

  @override
  String get notificationsTitle => '通知';

  @override
  String get notificationsStatusGranted => '已授予';

  @override
  String get notificationsStatusDenied => '已拒絕';

  @override
  String get notificationsStatusUnknown => '尚未詢問';

  @override
  String get notificationsRequest => '請求權限';

  @override
  String get notificationsOpenSettings => '開啟系統設定';

  @override
  String get profileFieldPhone => '電話號碼';

  @override
  String get profileFieldDescription => '外貌描述';

  @override
  String get profileFieldMedicalConditions => '病史';

  @override
  String get profileFieldEmergencyInstructions => '緊急指示';

  @override
  String get aboutAuthor => '作者:Jonas Eschle';

  @override
  String get aboutEmail => 'guardian.angela.app@gmail.com';

  @override
  String get aboutPrivacyPolicy => '隱私權政策';

  @override
  String get aboutTermsOfService => '服務條款';

  @override
  String get aboutSourceCode => '原始碼';

  @override
  String get aboutSupport => '支持 / 贊助';

  @override
  String get aboutLicenses => '開放原始碼授權';

  @override
  String get aboutTagline => '為 LGBTQ+ 的安全而用心打造。';

  @override
  String get aboutTechnicalSection => '技術資訊';

  @override
  String aboutBundleId(Object id) {
    return '套件 ID:$id';
  }

  @override
  String aboutPlatforms(Object list) {
    return '平台:$list';
  }

  @override
  String get feedbackHeading => '我們很想聽聽你的想法';

  @override
  String get feedbackCategoryLabel => '類別';

  @override
  String get feedbackCategoryBug => '錯誤回報';

  @override
  String get feedbackCategoryFeature => '功能建議';

  @override
  String get feedbackCategoryOther => '其他';

  @override
  String get feedbackEmailLabel => '電子郵件(選填)';

  @override
  String get feedbackMessageLabel => '訊息';

  @override
  String get feedbackIncludeLog => '附上最近一次守護紀錄';

  @override
  String get feedbackSent => '感謝你的意見回饋!';

  @override
  String get feedbackMessageRequired => '訊息至少需 10 個字元。';

  @override
  String get backupIncludeLogs => '包含守護紀錄';

  @override
  String get backupIncludeMedia => '包含媒體';

  @override
  String get backupExportButton => '匯出';

  @override
  String get backupImportButton => '匯入';

  @override
  String get backupOverwriteWarning => '匯入會覆寫所有目前的資料。';

  @override
  String get backupImportSuccess => '匯入完成。請重新啟動以套用。';

  @override
  String backupImportError(Object message) {
    return '匯入失敗:$message';
  }

  @override
  String get backupActiveSessionBanner => '守護進行中無法備份。';

  @override
  String backupLastBackupAtLabel(Object when) {
    return '上次備份於 $when';
  }

  @override
  String get backupNeverExportedLabel => '尚無備份';

  @override
  String get pastEventsTitle => '過往守護';

  @override
  String get pastEventsTabReal => '實際';

  @override
  String get pastEventsTabSimulated => '模擬';

  @override
  String get pastEventsEmpty => '尚無守護紀錄';

  @override
  String get pastEventsDeleteConfirm => '刪除守護紀錄?';

  @override
  String get pastEventsDetailShareText => '以文字分享';

  @override
  String get pastEventsDetailSharePdf => '以 PDF 分享';

  @override
  String get pastEventsDetailDelete => '刪除';

  @override
  String get pastEventsOutcomeCompleted => '已完成';

  @override
  String get pastEventsOutcomeDistress => '求救';

  @override
  String get pastEventsOutcomeInterrupted => '已中斷';

  @override
  String get pastEventsTrash => '移至垃圾桶';

  @override
  String get pastEventsUndo => '復原';

  @override
  String get pastEventsSoftDeleted => '已移至垃圾桶';

  @override
  String get pastEventsDetailTitle => '守護紀錄';

  @override
  String get pastEventsDetailShare => '分享';

  @override
  String get contactUnsavedDiscardTitle => '捨棄未儲存的變更?';

  @override
  String get contactUnsavedDiscardKeep => '繼續編輯';

  @override
  String get contactUnsavedDiscardDiscard => '捨棄';

  @override
  String get modesDuplicate => '複製';

  @override
  String get modesDeleteConfirmTitle => '刪除模式?';

  @override
  String modesDeleteConfirmBody(Object name) {
    return '$name 將被永久移除。';
  }

  @override
  String get modesDistressDefaultBadge => '預設';

  @override
  String get modesDistressSetDefault => '設為預設';

  @override
  String get modesDistressCantDeleteLast => '至少需保留一個求救模式。';

  @override
  String get modesDistressInUse => '此求救模式正被另一個模式使用中。';

  @override
  String get modesDistressTitle => '求救模式';

  @override
  String get validationNameTooShort => '名稱至少需 2 個字元。';

  @override
  String get validationPhoneRequired => '電話號碼為必填。';

  @override
  String get validationChannelsRequired => '請至少選擇一個通訊管道。';

  @override
  String get sessionHoldTouchToBegin => '觸碰以開始';

  @override
  String sessionHoldReleaseCountdown(Object seconds) {
    return '倒數:$seconds 秒';
  }

  @override
  String sessionHoldGraceCountdown(Object seconds) {
    return '寬限:$seconds 秒——再次按住以保持安全';
  }

  @override
  String get sessionHoldAgain => '再次按住以保持安全';

  @override
  String sessionStepNextCheckIn(Object time) {
    return '$time 後進行下次報平安';
  }

  @override
  String sessionStepFakeCallActive(Object caller) {
    return '$caller 來電';
  }

  @override
  String get sessionStepFakeCallOpen => '開啟通話畫面';

  @override
  String sessionStepSimBlockedSms(Object count) {
    return '[SIM] 將傳送簡訊給 $count 位聯絡人';
  }

  @override
  String get sessionStepSimBlockedPhone => '[SIM] 將致電緊急聯絡人';

  @override
  String get sessionStepSimBlockedEmergency => '[SIM] 將撥打緊急服務電話';

  @override
  String get sessionStepSimBlockedAlarm => '[SIM] 警報將以最大音量響起';

  @override
  String get sessionStartFailedTitle => '無法開始守護';

  @override
  String get sessionStartFailedBody => '開始前請先修正下列問題:';

  @override
  String get sessionQuickExitTitle => '快速離開';

  @override
  String get sessionQuickExitBody => '守護資料將被保留並加密。隨時重新開啟 App 即可復原。';

  @override
  String get sessionQuickExitConfirm => '離開 App';

  @override
  String get pastEventsRestore => '還原';

  @override
  String get stepEditorWait => '等待(秒)';

  @override
  String get stepEditorDuration => '時長(秒)';

  @override
  String get stepEditorGrace => '寬限(秒)';

  @override
  String get stepEditorRetryCount => '重試次數';

  @override
  String get stepEditorRandomize => '隨機化時間(±20%)';

  @override
  String get stepEditorRemove => '移除步驟';

  @override
  String get eventDefaultsHoldStyle => '按住樣式';

  @override
  String get eventDefaultsHoldSensitivity => '放開靈敏度';

  @override
  String get eventDefaultsHoldVibrate => '放開時震動';

  @override
  String get eventDefaultsHoldSound => '放開時發聲';

  @override
  String get eventDefaultsBlackScreen => '黑屏覆蓋';

  @override
  String get eventDefaultsReminderRandomInterval => '隨機化間隔';

  @override
  String get eventDefaultsReminderRandomTemplate => '隨機化範本順序';

  @override
  String get eventDefaultsReminderResetOnEarly => '提早報平安時重設';

  @override
  String get eventDefaultsCountdownStyle => '倒數樣式';

  @override
  String get eventDefaultsCountdownVibrate => '震動';

  @override
  String get eventDefaultsCountdownSound => '聲音';

  @override
  String get eventDefaultsFakeCallStyle => '來電樣式';

  @override
  String get eventDefaultsFakeCallCallerName => '來電者名稱';

  @override
  String get eventDefaultsFakeCallRingDuration => '響鈴時長(秒)';

  @override
  String get eventDefaultsFakeCallDeclineIsSafe => '拒接視為安全';

  @override
  String get eventDefaultsFakeCallVoiceOutput => '語音輸出';

  @override
  String get eventDefaultsSmsChannel => '通訊管道';

  @override
  String get eventDefaultsSmsIncludeLocation => '包含位置';

  @override
  String get eventDefaultsSmsIncludeMedical => '包含醫療資訊';

  @override
  String get eventDefaultsSmsAutoRecord => '傳送前錄製音訊';

  @override
  String get eventDefaultsSmsRecordDuration => '錄音時長(秒)';

  @override
  String get eventDefaultsLoudAlarmVolume => '音量';

  @override
  String get eventDefaultsLoudAlarmSound => '聲音';

  @override
  String get eventDefaultsLoudAlarmFlashScreen => '閃爍螢幕';

  @override
  String get eventDefaultsLoudAlarmFlashLight => '閃爍相機閃光燈';

  @override
  String get eventDefaultsLoudAlarmGradual => '音量漸強';

  @override
  String get eventDefaultsCallEmergencyNumber => '緊急號碼(覆寫)';

  @override
  String get eventDefaultsCallEmergencyConfirm => '顯示確認倒數';

  @override
  String get eventDefaultsCallEmergencyConfirmDuration => '確認秒數';

  @override
  String get eventDefaultsCallEmergencySmsFirst => '先傳送位置簡訊';

  @override
  String get eventDefaultsPhonePrimaryContact => '主要聯絡人(id)';

  @override
  String get eventDefaultsHardwareButton => '按鍵';

  @override
  String get eventDefaultsHardwarePattern => '按壓模式';

  @override
  String get eventDefaultsHardwarePressCount => '按壓次數';

  @override
  String get eventDefaultsHardwareLongDuration => '長按時長(秒)';

  @override
  String get pastEventsTrashTitle => '垃圾桶';

  @override
  String get pastEventsTrashEmpty => '垃圾桶是空的';

  @override
  String get pastEventsTrashEmptyAll => '清空垃圾桶';

  @override
  String get pastEventsTrashEmptyAllConfirmTitle => '清空垃圾桶?';

  @override
  String get pastEventsTrashEmptyAllConfirmBody =>
      '請在下方輸入「EMPTY TRASH」以確認。這將永久刪除每一筆已丟棄的紀錄。';

  @override
  String pastEventsTrashEmptyAllSuccess(Object count) {
    return '垃圾桶已清空($count 筆紀錄)';
  }

  @override
  String pastEventsTrashRetentionNote(int days) {
    return '垃圾桶中的紀錄會在 $days 天後永久刪除。';
  }

  @override
  String pastEventsTrashRemainingDays(int days) {
    return '$days 天後永久刪除';
  }

  @override
  String get pastEventsTrashDeletePermanently => '永久刪除';

  @override
  String get pastEventsTrashDeletePermanentlyBody => '此操作無法復原。';

  @override
  String sessionEmergencyConfirmTitle(String number, int seconds) {
    return '$seconds 秒後撥打 $number';
  }

  @override
  String get sessionEmergencyConfirmSwipe => '滑動以取消';

  @override
  String get sessionEmergencyConfirmKeep => '繼續撥打';

  @override
  String get sessionEmergencyConfirmSimBadge => '[SIM] 練習模式';

  @override
  String get sessionEmergencyConfirmSimCancelled => '模擬取消——不會真的撥出電話';

  @override
  String get swipeSliderSemantics => '滑動以確認';

  @override
  String get homeWidgetStatusIdle => '待命';

  @override
  String get homeWidgetStatusSession => '守護中';

  @override
  String get homeWidgetStatusSim => '模擬中';

  @override
  String get homeWidgetQuickExit => '快速離開';

  @override
  String get homeWidgetFakeCall => '模擬來電';
}
