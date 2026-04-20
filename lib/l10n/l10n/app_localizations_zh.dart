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
  String get commonCancel => '取消';

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
  String get homeTitle => 'Guardian Angela';

  @override
  String get homeStartSession => '开始会话';

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
  String get modeFieldDistressChain => '求救链';

  @override
  String get modeFieldDistressChainDefault => '使用默认';

  @override
  String get modeChainHeader => '升级链';

  @override
  String get modeChainAddStep => '添加步骤';

  @override
  String get modeChainEmpty => '尚无步骤。点击“添加步骤”。';

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
  String get stepPreview => '在模拟中预览';

  @override
  String stepPreviewFired(Object description) {
    return '已运行预览：$description';
  }

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
  String get distressChainsTitle => '求救链';

  @override
  String get distressChainsEmpty => '尚无求救链。';

  @override
  String get distressChainsAdd => '添加链';

  @override
  String get distressChainEditorTitleCreate => '新建求救链';

  @override
  String get distressChainEditorTitleEdit => '编辑求救链';

  @override
  String get distressChainName => '链名称';

  @override
  String get distressCountdown => '正在触发求救链……';

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
  String get settingsSectionDistressChains => '求救链';

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
  String get stealthSessionScreen => '隐藏会话界面品牌标识';

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
  String get historyTitle => '历史会话';

  @override
  String get historyEmpty => '尚无历史会话。';

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
}

/// The translations for Chinese, as used in Taiwan (`zh_TW`).
class AppLocalizationsZhTw extends AppLocalizationsZh {
  AppLocalizationsZhTw() : super('zh_TW');

  @override
  String get appTitle => 'Guardian Angela';

  @override
  String get commonSave => '儲存';

  @override
  String get commonCancel => '取消';

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
  String get homeTitle => 'Guardian Angela';

  @override
  String get homeStartSession => '開始守護';

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
  String get modeFieldDistressChain => '求救流程';

  @override
  String get modeFieldDistressChainDefault => '使用預設';

  @override
  String get modeChainHeader => '警報升級流程';

  @override
  String get modeChainAddStep => '新增步驟';

  @override
  String get modeChainEmpty => '尚未有任何步驟。點選「新增步驟」。';

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
  String get stepPreview => '模擬預覽';

  @override
  String stepPreviewFired(Object description) {
    return '預覽已執行:$description';
  }

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
  String get distressChainsTitle => '求救流程';

  @override
  String get distressChainsEmpty => '尚未建立求救流程。';

  @override
  String get distressChainsAdd => '新增流程';

  @override
  String get distressChainEditorTitleCreate => '新求救流程';

  @override
  String get distressChainEditorTitleEdit => '編輯求救流程';

  @override
  String get distressChainName => '流程名稱';

  @override
  String get distressCountdown => '正在觸發求救流程…';

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
  String get settingsSectionDistressChains => '求救流程';

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
  String get stealthSessionScreen => '移除守護畫面的品牌標示';

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
  String get historyTitle => '過往紀錄';

  @override
  String get historyEmpty => '尚無過往紀錄。';

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
}
