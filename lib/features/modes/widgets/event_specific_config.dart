import 'package:flutter/material.dart';

import 'package:path/path.dart' as p;

import 'package:guardianangela/core/utils/ringtone_picker.dart';
import 'package:guardianangela/core/widgets/info_icon_button.dart';
import 'package:guardianangela/domain/configs/step_config.dart';
import 'package:guardianangela/domain/enums/button_type.dart';
import 'package:guardianangela/domain/enums/call_style.dart';
import 'package:guardianangela/domain/enums/countdown_style.dart';
import 'package:guardianangela/domain/enums/hold_style.dart';
import 'package:guardianangela/domain/enums/loud_alarm_sound.dart';
import 'package:guardianangela/domain/enums/message_channel.dart';
import 'package:guardianangela/domain/enums/press_pattern.dart';
import 'package:guardianangela/domain/enums/sms_contact_selection.dart';
import 'package:guardianangela/domain/enums/voice_output_mode.dart';
import 'package:guardianangela/domain/models/emergency_contact.dart';
import 'package:guardianangela/domain/orchestration/strategies/sms_contact_strategy.dart';
import 'package:guardianangela/features/modes/widgets/config_fields.dart';
import 'package:guardianangela/features/modes/widgets/sms_contact_grid.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// Renders the type-specific configuration form for a [StepConfig].
///
/// Shared by the Mode Editor's `StepConfigPanel` (per-step config) and the
/// Event Defaults screen (global per-type defaults). Dispatches on the
/// sealed [StepConfig] subtype — adding a new step type is a compile error
/// until a branch is added. Each field calls [onChanged] with an updated
/// config; the caller decides whether to persist immediately (Event
/// Defaults) or stage the change in a draft (Mode Editor). See spec 04
/// §Event configuration.
///
/// Every field carries a trailing [InfoIconButton] that opens a bottom
/// sheet with a plain-language explanation, and the `fakeCall`,
/// `smsContact`, and `loudAlarm` forms open with a live preview card of
/// the configured effect (spec 04:1591).
///
/// [contacts] is non-null only in the Mode Editor context, where an
/// `smsContact` step renders the [SmsContactGrid] recipient picker; in Event
/// Defaults it is null (a global default has no specific recipients).
class EventSpecificConfig extends StatelessWidget {
  /// Creates an [EventSpecificConfig] for [config].
  const EventSpecificConfig({
    super.key,
    required this.config,
    required this.onChanged,
    this.contacts,
    this.onManageContacts,
    this.onManageTemplates,
    this.ringtonePicker,
  });

  /// The current per-step config to edit.
  final StepConfig config;

  /// Called with an updated config whenever a field changes.
  final ValueChanged<StepConfig> onChanged;

  /// All emergency contacts, for the `smsContact` recipient grid. Null in the
  /// Event Defaults context (no grid shown).
  final List<EmergencyContact>? contacts;

  /// Called when the user wants to manage contacts (empty-state deep link).
  final VoidCallback? onManageContacts;

  /// Opens the global reminder-templates screen from a `disguisedReminder`
  /// form (spec 04:1635). Null in the Event Defaults context (no link shown).
  final VoidCallback? onManageTemplates;

  /// Imports a user-supplied fake-call ringtone (Tier-F F3). Injected by
  /// tests; production leaves it null and a default [RingtonePicker] is used.
  final RingtonePicker? ringtonePicker;

  @override
  Widget build(BuildContext context) => switch (config) {
    final HoldButtonConfig c => _HoldButtonForm(
      config: c,
      onChanged: onChanged,
    ),
    final DisguisedReminderConfig c => _DisguisedReminderForm(
      config: c,
      onChanged: onChanged,
      onManageTemplates: onManageTemplates,
    ),
    final CountdownWarningConfig c => _CountdownWarningForm(
      config: c,
      onChanged: onChanged,
    ),
    final FakeCallConfig c => _FakeCallForm(
      config: c,
      onChanged: onChanged,
      ringtonePicker: ringtonePicker,
    ),
    final SmsContactConfig c => _SmsContactForm(
      config: c,
      onChanged: onChanged,
      contacts: contacts,
      onManageContacts: onManageContacts,
    ),
    final PhoneCallContactConfig c => _PhoneCallContactForm(
      config: c,
      onChanged: onChanged,
    ),
    final LoudAlarmConfig c => _LoudAlarmForm(config: c, onChanged: onChanged),
    final CallEmergencyConfig c => _CallEmergencyForm(
      config: c,
      onChanged: onChanged,
    ),
    final HardwareButtonConfig c => _HardwareButtonForm(
      config: c,
      onChanged: onChanged,
    ),
  };
}

// ─── Per-field info-icon wrapper (spec 04:1591) ────────────────────────────

/// Lays out a form field with a trailing [InfoIconButton].
///
/// Implements spec 04:1591: "Every field has a small info-icon button that
/// opens a bottom sheet with a plain-language explanation." [title] doubles
/// as the sheet title and the button tooltip; [body] is the explanation.
class _FieldWithInfo extends StatelessWidget {
  const _FieldWithInfo({
    required this.title,
    required this.body,
    required this.child,
  });

  final String title;
  final String body;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(child: child),
        InfoIconButton(title: title, body: body),
      ],
    );
  }
}

// ─── Preview cards (spec 04:1591) ──────────────────────────────────────────

/// Shared chrome for the three at-a-glance preview cards.
///
/// Spec 04:1591: "Three step types (fakeCall, smsContact, loudAlarm) render
/// a preview card so users can see the effect of their settings at a
/// glance." Pure presentation — the parent form rebuilds it with the
/// current config, so it live-updates as fields change.
class _PreviewCard extends StatelessWidget {
  const _PreviewCard({
    required this.icon,
    required this.title,
    required this.lines,
  });

  final IconData icon;
  final String title;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme text = Theme.of(context).textTheme;
    return Card(
      color: scheme.surfaceContainerHighest,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(icon, color: scheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    AppLocalizations.of(context).eventPreviewCardLabel,
                    style: text.labelSmall?.copyWith(color: scheme.primary),
                  ),
                  Text(title, style: text.titleSmall),
                  for (final String line in lines)
                    Text(
                      line,
                      style: text.bodySmall,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Live preview of the configured fake call: caller, ring timing, and what
/// declining does.
class _FakeCallPreviewCard extends StatelessWidget {
  const _FakeCallPreviewCard({required this.config});

  final FakeCallConfig config;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _PreviewCard(
      icon: Icons.phone_in_talk_outlined,
      title: l10n.eventPreviewFakeCallCaller(config.callerName),
      lines: <String>[
        l10n.eventPreviewFakeCallRing(
          config.ringDurationSeconds,
          config.callStyle.name,
        ),
        if (config.declineIsSafe)
          l10n.eventPreviewFakeCallDeclineSafe
        else
          l10n.eventPreviewFakeCallDeclineNotSafe,
      ],
    );
  }
}

/// Live preview of the configured alert message: recipients, channel, and
/// the message text (with placeholders) that will be sent.
class _SmsPreviewCard extends StatelessWidget {
  const _SmsPreviewCard({required this.config});

  final SmsContactConfig config;

  /// One-line recipients summary, mirroring the runtime target resolver
  /// (`resolveSmsTargets`): `allContacts` with a non-empty explicit id list
  /// is treated as specific IDs.
  String _recipients(AppLocalizations l10n) {
    final String channel = config.channel.name;
    final List<String>? ids = config.contactIds;
    final bool legacySpecific =
        config.contactSelection == SmsContactSelection.allContacts &&
        ids != null &&
        ids.isNotEmpty;
    if (legacySpecific) {
      return l10n.eventPreviewSmsToCount(ids.length, channel);
    }
    return switch (config.contactSelection) {
      SmsContactSelection.allContacts => l10n.eventPreviewSmsToAll(channel),
      SmsContactSelection.firstContact => l10n.eventPreviewSmsToFirst(channel),
      SmsContactSelection.specificIds => l10n.eventPreviewSmsToCount(
        ids?.length ?? 0,
        channel,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final String gist = config.messageTemplate ?? kDefaultSmsMessageTemplate;
    return _PreviewCard(
      icon: Icons.sms_outlined,
      title: _recipients(l10n),
      lines: <String>[l10n.eventPreviewSmsMessage(gist)],
    );
  }
}

/// Live preview of the configured alarm: volume, sound, ramp, and flashing.
class _LoudAlarmPreviewCard extends StatelessWidget {
  const _LoudAlarmPreviewCard({required this.config});

  final LoudAlarmConfig config;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final List<String> flashes = <String>[
      if (config.flashScreen) l10n.eventPreviewLoudAlarmFlashScreen,
      if (config.flashLight) l10n.eventPreviewLoudAlarmFlashLight,
    ];
    return _PreviewCard(
      icon: Icons.campaign_outlined,
      title: l10n.eventPreviewLoudAlarmTitle(
        (config.volume * 100).round(),
        config.soundChoice.name,
      ),
      lines: <String>[
        if (config.gradualVolume)
          l10n.eventPreviewLoudAlarmRampOn
        else
          l10n.eventPreviewLoudAlarmRampOff,
        if (flashes.isEmpty)
          l10n.eventPreviewLoudAlarmNoFlash
        else
          flashes.join(' · '),
      ],
    );
  }
}

// ─── Per-type forms ───────────────────────────────────────────────────────

class _HoldButtonForm extends StatelessWidget {
  const _HoldButtonForm({required this.config, required this.onChanged});

  final HoldButtonConfig config;
  final ValueChanged<HoldButtonConfig> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _FieldWithInfo(
          title: l10n.eventDefaultsHoldStyle,
          body: l10n.eventDefaultsHoldStyleInfo,
          child: EnumDropdownField<HoldStyle>(
            label: l10n.eventDefaultsHoldStyle,
            values: HoldStyle.values,
            value: config.holdStyle,
            labelFor: (HoldStyle v) => v.name,
            onChanged: (HoldStyle v) =>
                onChanged(config.copyWith(holdStyle: v)),
          ),
        ),
        _FieldWithInfo(
          title: l10n.eventDefaultsHoldSensitivity,
          body: l10n.eventDefaultsHoldSensitivityInfo,
          child: DoubleSliderField(
            label: l10n.eventDefaultsHoldSensitivity,
            value: config.releaseSensitivity,
            min: 0.3,
            max: 3.0,
            onChanged: (double v) =>
                onChanged(config.copyWith(releaseSensitivity: v)),
          ),
        ),
        _FieldWithInfo(
          title: l10n.eventDefaultsHoldVibrate,
          body: l10n.eventDefaultsHoldVibrateInfo,
          child: SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.eventDefaultsHoldVibrate),
            value: config.vibrateOnRelease,
            onChanged: (bool v) =>
                onChanged(config.copyWith(vibrateOnRelease: v)),
          ),
        ),
        _FieldWithInfo(
          title: l10n.eventDefaultsHoldSound,
          body: l10n.eventDefaultsHoldSoundInfo,
          child: SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.eventDefaultsHoldSound),
            value: config.soundOnRelease,
            onChanged: (bool v) =>
                onChanged(config.copyWith(soundOnRelease: v)),
          ),
        ),
        _BlackScreenSwitch(
          value: config.blackScreenMode,
          onChanged: (bool v) => onChanged(config.copyWith(blackScreenMode: v)),
        ),
      ],
    );
  }
}

class _DisguisedReminderForm extends StatelessWidget {
  const _DisguisedReminderForm({
    required this.config,
    required this.onChanged,
    this.onManageTemplates,
  });

  final DisguisedReminderConfig config;
  final ValueChanged<DisguisedReminderConfig> onChanged;
  final VoidCallback? onManageTemplates;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final VoidCallback? onManageTemplates = this.onManageTemplates;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _FieldWithInfo(
          title: l10n.eventDefaultsReminderRandomInterval,
          body: l10n.eventDefaultsReminderRandomIntervalInfo,
          child: SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.eventDefaultsReminderRandomInterval),
            value: config.randomizeInterval,
            onChanged: (bool v) =>
                onChanged(config.copyWith(randomizeInterval: v)),
          ),
        ),
        _FieldWithInfo(
          title: l10n.eventDefaultsReminderRandomTemplate,
          body: l10n.eventDefaultsReminderRandomTemplateInfo,
          child: SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.eventDefaultsReminderRandomTemplate),
            value: config.randomizeTemplateOrder,
            onChanged: (bool v) =>
                onChanged(config.copyWith(randomizeTemplateOrder: v)),
          ),
        ),
        _FieldWithInfo(
          title: l10n.eventDefaultsReminderResetOnEarly,
          body: l10n.eventDefaultsReminderResetOnEarlyInfo,
          child: SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.eventDefaultsReminderResetOnEarly),
            value: config.resetOnEarlyCheckIn,
            onChanged: (bool v) =>
                onChanged(config.copyWith(resetOnEarlyCheckIn: v)),
          ),
        ),
        _BlackScreenSwitch(
          value: config.blackScreenMode,
          onChanged: (bool v) => onChanged(config.copyWith(blackScreenMode: v)),
        ),
        if (onManageTemplates != null)
          _ManageTemplatesLink(onManageTemplates: onManageTemplates),
      ],
    );
  }
}

/// The "Manage reminder templates" deep link of a `disguisedReminder` form.
///
/// Spec 04:1635: the form renders a "Manage reminder templates" ListTile
/// (leading `collections_outlined`, chevron trailing) that navigates to
/// `/settings/reminder-templates`, with an [InfoIconButton] above the link
/// explaining what templates are. Shown only in the Mode Editor context
/// (where a navigation callback exists).
class _ManageTemplatesLink extends StatelessWidget {
  const _ManageTemplatesLink({required this.onManageTemplates});

  final VoidCallback onManageTemplates;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                l10n.eventDefaultsReminderTemplatesTitle,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            InfoIconButton(
              title: l10n.eventDefaultsReminderTemplatesTitle,
              body: l10n.eventDefaultsReminderTemplatesInfo,
            ),
          ],
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.collections_outlined),
          title: Text(l10n.safetyOptionsManageTemplates),
          trailing: const Icon(Icons.chevron_right),
          onTap: onManageTemplates,
        ),
      ],
    );
  }
}

class _CountdownWarningForm extends StatelessWidget {
  const _CountdownWarningForm({required this.config, required this.onChanged});

  final CountdownWarningConfig config;
  final ValueChanged<CountdownWarningConfig> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _FieldWithInfo(
          title: l10n.eventDefaultsCountdownStyle,
          body: l10n.eventDefaultsCountdownStyleInfo,
          child: EnumDropdownField<CountdownStyle>(
            label: l10n.eventDefaultsCountdownStyle,
            values: CountdownStyle.values,
            value: config.style,
            labelFor: (CountdownStyle v) => v.name,
            onChanged: (CountdownStyle v) =>
                onChanged(config.copyWith(style: v)),
          ),
        ),
        _FieldWithInfo(
          title: l10n.eventDefaultsCountdownVibrate,
          body: l10n.eventDefaultsCountdownVibrateInfo,
          child: SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.eventDefaultsCountdownVibrate),
            value: config.vibrate,
            onChanged: (bool v) => onChanged(config.copyWith(vibrate: v)),
          ),
        ),
        _FieldWithInfo(
          title: l10n.eventDefaultsCountdownSound,
          body: l10n.eventDefaultsCountdownSoundInfo,
          child: SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.eventDefaultsCountdownSound),
            value: config.sound,
            onChanged: (bool v) => onChanged(config.copyWith(sound: v)),
          ),
        ),
        _BlackScreenSwitch(
          value: config.blackScreenMode,
          onChanged: (bool v) => onChanged(config.copyWith(blackScreenMode: v)),
        ),
      ],
    );
  }
}

class _FakeCallForm extends StatelessWidget {
  const _FakeCallForm({
    required this.config,
    required this.onChanged,
    this.ringtonePicker,
  });

  final FakeCallConfig config;
  final ValueChanged<FakeCallConfig> onChanged;
  final RingtonePicker? ringtonePicker;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _FakeCallPreviewCard(config: config),
        _FieldWithInfo(
          title: l10n.eventDefaultsFakeCallStyle,
          body: l10n.eventDefaultsFakeCallStyleInfo,
          child: EnumDropdownField<CallStyle>(
            label: l10n.eventDefaultsFakeCallStyle,
            values: CallStyle.values,
            value: config.callStyle,
            labelFor: (CallStyle v) => v.name,
            onChanged: (CallStyle v) =>
                onChanged(config.copyWith(callStyle: v)),
          ),
        ),
        _FieldWithInfo(
          title: l10n.eventDefaultsFakeCallCallerName,
          body: l10n.eventDefaultsFakeCallCallerNameInfo,
          child: LabeledTextField(
            label: l10n.eventDefaultsFakeCallCallerName,
            value: config.callerName,
            onChanged: (String v) => onChanged(
              config.copyWith(callerName: v.isEmpty ? 'Angela' : v),
            ),
          ),
        ),
        _FieldWithInfo(
          title: l10n.eventDefaultsFakeCallRingDuration,
          body: l10n.eventDefaultsFakeCallRingDurationInfo,
          child: IntSpinnerField(
            label: l10n.eventDefaultsFakeCallRingDuration,
            value: config.ringDurationSeconds,
            min: 5,
            max: 120,
            onChanged: (int v) =>
                onChanged(config.copyWith(ringDurationSeconds: v)),
          ),
        ),
        _FieldWithInfo(
          title: l10n.eventDefaultsFakeCallVoiceOutput,
          body: l10n.eventDefaultsFakeCallVoiceOutputInfo,
          child: EnumDropdownField<VoiceOutputMode>(
            label: l10n.eventDefaultsFakeCallVoiceOutput,
            values: VoiceOutputMode.values,
            value: config.voiceOutputMode,
            labelFor: (VoiceOutputMode v) => v.name,
            onChanged: (VoiceOutputMode v) =>
                onChanged(config.copyWith(voiceOutputMode: v)),
          ),
        ),
        _FieldWithInfo(
          title: l10n.eventDefaultsFakeCallRingtone,
          body: l10n.eventDefaultsFakeCallRingtoneInfo,
          child: _RingtonePickerField(
            config: config,
            onChanged: onChanged,
            ringtonePicker: ringtonePicker,
          ),
        ),
        _FieldWithInfo(
          title: l10n.eventDefaultsFakeCallDeclineIsSafe,
          body: l10n.eventDefaultsFakeCallDeclineIsSafeInfo,
          child: SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.eventDefaultsFakeCallDeclineIsSafe),
            value: config.declineIsSafe,
            onChanged: (bool v) => onChanged(config.copyWith(declineIsSafe: v)),
          ),
        ),
        _BlackScreenSwitch(
          value: config.blackScreenMode,
          onChanged: (bool v) => onChanged(config.copyWith(blackScreenMode: v)),
        ),
      ],
    );
  }
}

/// Ringtone picker row for the fake-call config (Tier-F F3).
///
/// Shows the current ringtone (the bundled default, or the imported file's
/// name) and a button to import a user-supplied audio file via
/// [RingtonePicker]. When a custom ringtone is set, a "Use default" action
/// clears it back to the bundled ring (via a direct construction, since
/// `copyWith` cannot null a field).
class _RingtonePickerField extends StatelessWidget {
  const _RingtonePickerField({
    required this.config,
    required this.onChanged,
    this.ringtonePicker,
  });

  final FakeCallConfig config;
  final ValueChanged<FakeCallConfig> onChanged;
  final RingtonePicker? ringtonePicker;

  /// Rebuilds the config with [customRingtonePath], which may be null.
  ///
  /// `copyWith` cannot clear a field (`x ?? this.x`), so a direct construction
  /// is required to set the ringtone back to null (= bundled default ring).
  FakeCallConfig _withCustomRingtone(String? customRingtonePath) =>
      FakeCallConfig(
        callStyle: config.callStyle,
        callerName: config.callerName,
        callerPhotoPath: config.callerPhotoPath,
        voiceRecordingPath: config.voiceRecordingPath,
        customRingtonePath: customRingtonePath,
        voiceOutputMode: config.voiceOutputMode,
        ringDurationSeconds: config.ringDurationSeconds,
        declineIsSafe: config.declineIsSafe,
        declineWithDistressHoldSeconds: config.declineWithDistressHoldSeconds,
        blackScreenMode: config.blackScreenMode,
      );

  Future<void> _pick(BuildContext context) async {
    final RingtonePicker picker = ringtonePicker ?? RingtonePicker();
    final String? stored = await picker.pickAndStoreRingtone();
    if (stored != null) {
      onChanged(config.copyWith(customRingtonePath: stored));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final String? path = config.customRingtonePath;
    final String currentLabel = path == null
        ? l10n.eventDefaultsFakeCallRingtoneDefault
        : l10n.eventDefaultsFakeCallRingtoneCustom(p.basename(path));
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            l10n.eventDefaultsFakeCallRingtone,
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 4),
          Row(
            children: <Widget>[
              const Icon(Icons.music_note_outlined, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  currentLabel,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: <Widget>[
              TextButton.icon(
                onPressed: () => _pick(context),
                icon: const Icon(Icons.upload_file_outlined),
                label: Text(l10n.eventDefaultsFakeCallRingtoneChoose),
              ),
              if (path != null)
                TextButton(
                  onPressed: () => onChanged(_withCustomRingtone(null)),
                  child: Text(l10n.eventDefaultsFakeCallRingtoneUseDefault),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The SMS message-template placeholder tokens offered in the editor.
///
/// Matches the supported placeholders in spec 02:287-291 (`{photo}` is
/// intentionally excluded per spec audit G-017).
const List<String> kSmsTemplatePlaceholders = <String>[
  '{name}',
  '{location}',
  '{time}',
  '{description}',
];

class _SmsContactForm extends StatelessWidget {
  const _SmsContactForm({
    required this.config,
    required this.onChanged,
    this.contacts,
    this.onManageContacts,
  });

  final SmsContactConfig config;
  final ValueChanged<SmsContactConfig> onChanged;
  final List<EmergencyContact>? contacts;
  final VoidCallback? onManageContacts;

  /// Rebuilds the config with [messageTemplate], which may be null.
  ///
  /// `copyWith` cannot clear a field (`x ?? this.x`), so a direct construction
  /// is required to set the template back to null (= use the seeded default).
  SmsContactConfig _withTemplate(String? messageTemplate) => SmsContactConfig(
    contactIds: config.contactIds,
    contactSelection: config.contactSelection,
    channel: config.channel,
    includeLocation: config.includeLocation,
    includeMedicalInfo: config.includeMedicalInfo,
    autoRecordAudio: config.autoRecordAudio,
    recordDurationSeconds: config.recordDurationSeconds,
    messageTemplate: messageTemplate,
    blackScreenMode: config.blackScreenMode,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final List<EmergencyContact>? contacts = this.contacts;
    final bool isIos = Theme.of(context).platform == TargetPlatform.iOS;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _SmsPreviewCard(config: config),
        _FieldWithInfo(
          title: l10n.eventDefaultsSmsChannel,
          body: l10n.eventDefaultsSmsChannelInfo,
          child: EnumDropdownField<MessageChannel>(
            label: l10n.eventDefaultsSmsChannel,
            values: MessageChannel.values,
            value: config.channel,
            labelFor: (MessageChannel v) => v.name,
            onChanged: (MessageChannel v) =>
                onChanged(config.copyWith(channel: v)),
          ),
        ),
        if (isIos && config.channel == MessageChannel.sms)
          _PlatformWarning(message: l10n.eventDefaultsSmsIosWarning),
        if (contacts != null) ...<Widget>[
          const SizedBox(height: 8),
          _FieldWithInfo(
            title: l10n.smsContactRecipientsHeader,
            body: l10n.smsContactRecipientsInfo,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(l10n.smsContactRecipientsHeader),
            ),
          ),
          SmsContactGrid(
            contacts: contacts,
            config: config,
            onChanged: onChanged,
            onManageContacts: onManageContacts ?? () {},
          ),
        ],
        _FieldWithInfo(
          title: l10n.eventDefaultsSmsMessageTemplate,
          // Passes the literal tokens so the sheet shows them verbatim (the
          // l10n placeholder mechanism keeps them untranslated per locale).
          body: l10n.eventDefaultsSmsMessageTemplateInfo(
            kSmsTemplatePlaceholders[0],
            kSmsTemplatePlaceholders[1],
          ),
          child: MessageTemplateField(
            label: l10n.eventDefaultsSmsMessageTemplate,
            hint: l10n.eventDefaultsSmsMessageTemplateHint,
            value: config.messageTemplate,
            placeholders: kSmsTemplatePlaceholders,
            onChanged: (String? v) => onChanged(_withTemplate(v)),
          ),
        ),
        _FieldWithInfo(
          title: l10n.eventDefaultsSmsIncludeLocation,
          body: l10n.eventDefaultsSmsIncludeLocationInfo,
          child: SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.eventDefaultsSmsIncludeLocation),
            value: config.includeLocation,
            onChanged: (bool v) =>
                onChanged(config.copyWith(includeLocation: v)),
          ),
        ),
        _FieldWithInfo(
          title: l10n.eventDefaultsSmsIncludeMedical,
          body: l10n.eventDefaultsSmsIncludeMedicalInfo,
          child: SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.eventDefaultsSmsIncludeMedical),
            value: config.includeMedicalInfo,
            onChanged: (bool v) =>
                onChanged(config.copyWith(includeMedicalInfo: v)),
          ),
        ),
        _FieldWithInfo(
          title: l10n.eventDefaultsSmsAutoRecord,
          body: l10n.eventDefaultsSmsAutoRecordInfo,
          child: SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.eventDefaultsSmsAutoRecord),
            value: config.autoRecordAudio,
            onChanged: (bool v) =>
                onChanged(config.copyWith(autoRecordAudio: v)),
          ),
        ),
        if (config.autoRecordAudio)
          _FieldWithInfo(
            title: l10n.eventDefaultsSmsRecordDuration,
            body: l10n.eventDefaultsSmsRecordDurationInfo,
            child: IntSpinnerField(
              label: l10n.eventDefaultsSmsRecordDuration,
              value: config.recordDurationSeconds,
              min: 5,
              max: 120,
              onChanged: (int v) =>
                  onChanged(config.copyWith(recordDurationSeconds: v)),
            ),
          ),
        _BlackScreenSwitch(
          value: config.blackScreenMode,
          onChanged: (bool v) => onChanged(config.copyWith(blackScreenMode: v)),
        ),
      ],
    );
  }
}

class _PhoneCallContactForm extends StatelessWidget {
  const _PhoneCallContactForm({required this.config, required this.onChanged});

  final PhoneCallContactConfig config;
  final ValueChanged<PhoneCallContactConfig> onChanged;

  /// Rebuilds the config with [contactId], which may be null.
  ///
  /// `copyWith` cannot clear a field (`x ?? this.x`), so a direct construction
  /// is required to set the contact back to null (= no primary contact).
  PhoneCallContactConfig _withContactId(String? contactId) =>
      PhoneCallContactConfig(
        contactId: contactId,
        alternativeContactIds: config.alternativeContactIds,
        logGps: config.logGps,
        blackScreenMode: config.blackScreenMode,
      );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _FieldWithInfo(
          title: l10n.eventDefaultsPhonePrimaryContact,
          body: l10n.eventDefaultsPhonePrimaryContactInfo,
          child: LabeledTextField(
            label: l10n.eventDefaultsPhonePrimaryContact,
            value: config.contactId ?? '',
            onChanged: (String v) =>
                onChanged(_withContactId(v.isEmpty ? null : v)),
          ),
        ),
        _BlackScreenSwitch(
          value: config.blackScreenMode,
          onChanged: (bool v) => onChanged(config.copyWith(blackScreenMode: v)),
        ),
      ],
    );
  }
}

class _LoudAlarmForm extends StatelessWidget {
  const _LoudAlarmForm({required this.config, required this.onChanged});

  final LoudAlarmConfig config;
  final ValueChanged<LoudAlarmConfig> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _LoudAlarmPreviewCard(config: config),
        _FieldWithInfo(
          title: l10n.eventDefaultsLoudAlarmVolume,
          body: l10n.eventDefaultsLoudAlarmVolumeInfo,
          child: DoubleSliderField(
            label: l10n.eventDefaultsLoudAlarmVolume,
            value: config.volume,
            min: 0,
            max: 1,
            onChanged: (double v) => onChanged(config.copyWith(volume: v)),
          ),
        ),
        _FieldWithInfo(
          title: l10n.eventDefaultsLoudAlarmSound,
          body: l10n.eventDefaultsLoudAlarmSoundInfo,
          child: EnumDropdownField<LoudAlarmSound>(
            label: l10n.eventDefaultsLoudAlarmSound,
            values: LoudAlarmSound.values,
            value: config.soundChoice,
            labelFor: (LoudAlarmSound v) => v.name,
            onChanged: (LoudAlarmSound v) =>
                onChanged(config.copyWith(soundChoice: v)),
          ),
        ),
        _FieldWithInfo(
          title: l10n.eventDefaultsLoudAlarmFlashScreen,
          body: l10n.eventDefaultsLoudAlarmFlashScreenInfo,
          child: SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.eventDefaultsLoudAlarmFlashScreen),
            value: config.flashScreen,
            onChanged: (bool v) => onChanged(config.copyWith(flashScreen: v)),
          ),
        ),
        _FieldWithInfo(
          title: l10n.eventDefaultsLoudAlarmFlashLight,
          body: l10n.eventDefaultsLoudAlarmFlashLightInfo,
          child: SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.eventDefaultsLoudAlarmFlashLight),
            value: config.flashLight,
            onChanged: (bool v) => onChanged(config.copyWith(flashLight: v)),
          ),
        ),
        _FieldWithInfo(
          title: l10n.eventDefaultsLoudAlarmGradual,
          body: l10n.eventDefaultsLoudAlarmGradualInfo,
          child: SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.eventDefaultsLoudAlarmGradual),
            value: config.gradualVolume,
            onChanged: (bool v) => onChanged(config.copyWith(gradualVolume: v)),
          ),
        ),
        _BlackScreenSwitch(
          value: config.blackScreenMode,
          onChanged: (bool v) => onChanged(config.copyWith(blackScreenMode: v)),
        ),
      ],
    );
  }
}

class _CallEmergencyForm extends StatelessWidget {
  const _CallEmergencyForm({required this.config, required this.onChanged});

  final CallEmergencyConfig config;
  final ValueChanged<CallEmergencyConfig> onChanged;

  /// Rebuilds the config with [emergencyNumber], which may be null.
  ///
  /// `copyWith` cannot clear a field (`x ?? this.x`), so a direct construction
  /// is required to set the number back to null (= the regional default).
  CallEmergencyConfig _withNumber(String? emergencyNumber) =>
      CallEmergencyConfig(
        emergencyNumber: emergencyNumber,
        sendLocationSmsFirst: config.sendLocationSmsFirst,
        showConfirmation: config.showConfirmation,
        confirmationDurationSeconds: config.confirmationDurationSeconds,
        blackScreenMode: config.blackScreenMode,
      );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bool isIos = Theme.of(context).platform == TargetPlatform.iOS;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (isIos)
          _PlatformWarning(message: l10n.eventDefaultsCallEmergencyIosWarning),
        _FieldWithInfo(
          title: l10n.eventDefaultsCallEmergencyNumber,
          body: l10n.eventDefaultsCallEmergencyNumberInfo,
          child: LabeledTextField(
            label: l10n.eventDefaultsCallEmergencyNumber,
            value: config.emergencyNumber ?? '',
            onChanged: (String v) =>
                onChanged(_withNumber(v.isEmpty ? null : v)),
          ),
        ),
        _FieldWithInfo(
          title: l10n.eventDefaultsCallEmergencySmsFirst,
          body: l10n.eventDefaultsCallEmergencySmsFirstInfo,
          child: SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.eventDefaultsCallEmergencySmsFirst),
            value: config.sendLocationSmsFirst,
            onChanged: (bool v) =>
                onChanged(config.copyWith(sendLocationSmsFirst: v)),
          ),
        ),
        _FieldWithInfo(
          title: l10n.eventDefaultsCallEmergencyConfirm,
          body: l10n.eventDefaultsCallEmergencyConfirmInfo,
          child: SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.eventDefaultsCallEmergencyConfirm),
            value: config.showConfirmation,
            onChanged: (bool v) =>
                onChanged(config.copyWith(showConfirmation: v)),
          ),
        ),
        if (config.showConfirmation)
          _FieldWithInfo(
            title: l10n.eventDefaultsCallEmergencyConfirmDuration,
            body: l10n.eventDefaultsCallEmergencyConfirmDurationInfo,
            child: IntSpinnerField(
              label: l10n.eventDefaultsCallEmergencyConfirmDuration,
              value: config.confirmationDurationSeconds,
              max: 30,
              onChanged: (int v) =>
                  onChanged(config.copyWith(confirmationDurationSeconds: v)),
            ),
          ),
        _BlackScreenSwitch(
          value: config.blackScreenMode,
          onChanged: (bool v) => onChanged(config.copyWith(blackScreenMode: v)),
        ),
      ],
    );
  }
}

class _HardwareButtonForm extends StatelessWidget {
  const _HardwareButtonForm({required this.config, required this.onChanged});

  final HardwareButtonConfig config;
  final ValueChanged<HardwareButtonConfig> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isRepeat = config.pressPattern == PressPattern.repeatPress;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _FieldWithInfo(
          title: l10n.eventDefaultsHardwareButton,
          body: l10n.eventDefaultsHardwareButtonInfo,
          child: EnumDropdownField<ButtonType>(
            label: l10n.eventDefaultsHardwareButton,
            values: ButtonType.values,
            value: config.buttonType,
            labelFor: (ButtonType v) => v.name,
            onChanged: (ButtonType v) =>
                onChanged(config.copyWith(buttonType: v)),
          ),
        ),
        _FieldWithInfo(
          title: l10n.eventDefaultsHardwarePattern,
          body: l10n.eventDefaultsHardwarePatternInfo,
          child: EnumDropdownField<PressPattern>(
            label: l10n.eventDefaultsHardwarePattern,
            values: PressPattern.values,
            value: config.pressPattern,
            labelFor: (PressPattern v) => v.name,
            onChanged: (PressPattern v) =>
                onChanged(config.copyWith(pressPattern: v)),
          ),
        ),
        if (isRepeat)
          _FieldWithInfo(
            title: l10n.eventDefaultsHardwarePressCount,
            body: l10n.eventDefaultsHardwarePressCountInfo,
            child: IntSpinnerField(
              label: l10n.eventDefaultsHardwarePressCount,
              value: config.pressCount,
              min: 2,
              max: 10,
              onChanged: (int v) => onChanged(config.copyWith(pressCount: v)),
            ),
          )
        else
          _FieldWithInfo(
            title: l10n.eventDefaultsHardwareLongDuration,
            body: l10n.eventDefaultsHardwareLongDurationInfo,
            child: DoubleSliderField(
              label: l10n.eventDefaultsHardwareLongDuration,
              value: config.longPressDurationSeconds,
              min: 0.5,
              max: 10,
              onChanged: (double v) =>
                  onChanged(config.copyWith(longPressDurationSeconds: v)),
            ),
          ),
        _BlackScreenSwitch(
          value: config.blackScreenMode,
          onChanged: (bool v) => onChanged(config.copyWith(blackScreenMode: v)),
        ),
      ],
    );
  }
}

// ─── iOS platform-limitation warning banner ────────────────────────────────

/// An inline warning card surfacing an iOS platform limitation for a step.
///
/// Rendered only on iOS (the caller gates on [Theme.platform]); it explains a
/// documented iOS behaviour the user cannot change — SMS requiring a manual
/// Send tap (spec 02:325) or the emergency-call confirmation dialog (02:479).
class _PlatformWarning extends StatelessWidget {
  const _PlatformWarning({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: scheme.tertiaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(
              Icons.info_outline,
              size: 20,
              color: scheme.onTertiaryContainer,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: scheme.onTertiaryContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Black-screen toggle (shared across all step types) ────────────────────

class _BlackScreenSwitch extends StatelessWidget {
  const _BlackScreenSwitch({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _FieldWithInfo(
      title: l10n.eventDefaultsBlackScreen,
      body: l10n.eventDefaultsBlackScreenInfo,
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(l10n.eventDefaultsBlackScreen),
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}
