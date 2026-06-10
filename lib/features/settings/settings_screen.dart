import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:guardianangela/core/constants/route_names.dart';
import 'package:guardianangela/core/utils/phone_validators.dart';
import 'package:guardianangela/core/utils/phone_warning_l10n.dart';
import 'package:guardianangela/core/widgets/info_icon_button.dart';
import 'package:guardianangela/core/widgets/settings_tile.dart';
import 'package:guardianangela/core/widgets/timing_slider.dart';
import 'package:guardianangela/domain/enums/app_theme_mode.dart';
import 'package:guardianangela/features/session/session_controller.dart';
import 'package:guardianangela/features/settings/settings_controller.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// Settings hub.
///
/// Shows only Theme + Language inline. Every other setting is a
/// subcategory row. See spec 04 §Settings Screen and spec 06.
class SettingsScreen extends ConsumerWidget {
  /// Creates a [SettingsScreen].
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final stateAsync = ref.watch(settingsControllerProvider);
    final sessionState = ref.watch(sessionControllerProvider).value;
    final sessionRunning =
        sessionState != null &&
        sessionState.activeChain.isNotEmpty &&
        sessionState.phase != SessionPhase.idle &&
        sessionState.phase != SessionPhase.ended;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.homeMenuSettings)),
      body: stateAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, _) =>
            Center(child: Text(l10n.commonErrorWithDetail(e))),
        data: (state) => ListView(
          children: <Widget>[
            _SectionHeader(text: l10n.settingsGeneralHeader),
            ListTile(
              leading: const Icon(Icons.brightness_6),
              title: Text(l10n.settingsThemeLabel),
              subtitle: Wrap(
                spacing: 8,
                children: <Widget>[
                  for (final m in AppThemeMode.values)
                    ChoiceChip(
                      label: Text(_themeLabel(m, l10n)),
                      selected: state.themeMode == m,
                      onSelected: (bool s) {
                        if (s) {
                          ref
                              .read(settingsControllerProvider.notifier)
                              .setThemeMode(m);
                        }
                      },
                    ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: Text(l10n.settingsLanguageLabel),
              subtitle: Text(state.languageCode),
              onTap: () => _pickLanguage(context, ref, state.languageCode),
            ),
            const Divider(),
            _SectionHeader(text: l10n.settingsConfigurationHeader),
            SettingsTile(
              icon: Icons.person_outline,
              title: l10n.settingsProfileRow,
              onTap: () => context.pushNamed(RouteNames.profile),
            ),
            SettingsTile(
              icon: Icons.shield_outlined,
              title: l10n.settingsSecurityRow,
              subtitle: l10n.settingsSecuritySubtitle,
              onTap: () => context.pushNamed(RouteNames.settingsSecurity),
            ),
            SettingsTile(
              icon: Icons.visibility_off_outlined,
              title: l10n.settingsStealthRow,
              subtitle: state.stealthEnabled
                  ? l10n.settingsStealthSummaryOn
                  : l10n.settingsStealthSummaryOff,
              onTap: () => context.pushNamed(RouteNames.settingsStealth),
            ),
            SettingsTile(
              icon: Icons.directions_walk,
              title: l10n.settingsModesRow,
              onTap: () => context.pushNamed(RouteNames.modes),
            ),
            SettingsTile(
              icon: Icons.warning_amber_outlined,
              title: l10n.settingsDistressModesRow,
              onTap: () => context.pushNamed(RouteNames.distressModes),
            ),
            SettingsTile(
              icon: Icons.tune,
              title: l10n.settingsEventDefaultsRow,
              onTap: () => context.pushNamed(RouteNames.settingsEventDefaults),
            ),
            SettingsTile(
              icon: Icons.location_on_outlined,
              title: l10n.settingsGpsLoggingRow,
              onTap: () => context.pushNamed(RouteNames.settingsGpsLogging),
            ),
            SettingsTile(
              icon: Icons.notifications_outlined,
              title: l10n.settingsRemindersRow,
              onTap: () =>
                  context.pushNamed(RouteNames.settingsReminderTemplates),
            ),
            SettingsTile(
              icon: Icons.notifications_active_outlined,
              title: l10n.settingsNotificationsRow,
              onTap: () => context.pushNamed(RouteNames.settingsNotifications),
            ),
            const Divider(),
            _SectionHeader(text: l10n.settingsAlarmHeader),
            _AlarmSection(state: state),
            const Divider(),
            _SectionHeader(text: l10n.settingsAppHeader),
            SettingsTile(
              icon: Icons.history,
              title: l10n.settingsHistoryRetentionRow,
              onTap: () =>
                  context.pushNamed(RouteNames.settingsHistoryRetention),
            ),
            SettingsTile(
              icon: Icons.backup_outlined,
              title: l10n.settingsBackupRow,
              onTap: () => context.pushNamed(RouteNames.settingsBackup),
            ),
            SettingsTile(
              icon: Icons.feedback_outlined,
              title: l10n.settingsFeedbackRow,
              onTap: () => context.pushNamed(RouteNames.settingsFeedback),
            ),
            SettingsTile(
              icon: Icons.info_outline,
              title: l10n.settingsAboutRow,
              onTap: () => context.pushNamed(RouteNames.settingsAbout),
            ),
            if (sessionRunning)
              Tooltip(
                message: l10n.settingsRedoOnboardingActiveSessionTooltip,
                child: ListTile(
                  leading: const Icon(Icons.restart_alt),
                  title: Text(l10n.settingsRedoOnboarding),
                  // spec:04:1951: disabled because a session is active
                  enabled: false,
                ),
              )
            else
              ListTile(
                leading: const Icon(Icons.restart_alt),
                title: Text(l10n.settingsRedoOnboarding),
                onTap: () => _redoOnboarding(context, ref),
              ),
            ListTile(
              leading: const Icon(Icons.local_phone_outlined),
              title: Text(l10n.settingsEmergencyNumberLabel),
              subtitle: Text(state.emergencyCallNumber),
              onTap: () =>
                  _pickEmergencyNumber(context, ref, state.emergencyCallNumber),
            ),
            ListTile(
              leading: const Icon(Icons.article_outlined),
              title: Text(l10n.settingsOssLicenses),
              onTap: () => showLicensePage(
                context: context,
                applicationName: 'Guardian Angela',
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _themeLabel(AppThemeMode m, AppLocalizations l10n) {
    return switch (m) {
      AppThemeMode.light => l10n.settingsThemeLight,
      AppThemeMode.dark => l10n.settingsThemeDark,
      AppThemeMode.system => l10n.settingsThemeSystem,
    };
  }

  Future<void> _pickLanguage(
    BuildContext context,
    WidgetRef ref,
    String current,
  ) async {
    const supported = <String>[
      'en',
      'de',
      'es',
      'fr',
      'ru',
      'zh',
      'zh_TW',
      'hi',
      'fa',
      'uk',
      'pl',
      'el',
      'ar',
      'he',
    ];
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (BuildContext ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            for (final code in supported)
              ListTile(
                title: Text(code),
                trailing: code == current ? const Icon(Icons.check) : null,
                onTap: () => Navigator.of(ctx).pop(code),
              ),
          ],
        ),
      ),
    );
    if (selected != null) {
      await ref.read(settingsControllerProvider.notifier).setLanguage(selected);
    }
  }

  Future<void> _pickEmergencyNumber(
    BuildContext context,
    WidgetRef ref,
    String current,
  ) async {
    // Editable free-form dialog (spec 06 §Emergency Number): the user can type
    // any country-specific short code or carrier variant. A live, non-blocking
    // validator warns on odd input; an empty field blocks Save (the input
    // never persists a blank — clearing it leaves the prior value untouched).
    final selected = await showDialog<String>(
      context: context,
      builder: (BuildContext ctx) => _EmergencyNumberDialog(initial: current),
    );
    if (selected != null) {
      await ref
          .read(settingsControllerProvider.notifier)
          .setEmergencyCallNumber(selected);
    }
  }

  Future<void> _redoOnboarding(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: Text(l10n.settingsRedoOnboarding),
        content: Text(l10n.settingsRedoOnboardingConfirm),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.commonConfirm),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    await ref.read(settingsControllerProvider.notifier).resetOnboarding();
    if (!context.mounted) return;
    context.goNamed(RouteNames.onboarding);
  }
}

/// App-wide alarm behavior controls (spec 06 §Alarm Section).
///
/// Exposes the three global loudAlarm settings: DND/silent override,
/// the gradual-volume master, and the ramp duration (revealed only when
/// gradual volume is on). All three persist to `AppSettings` via
/// [SettingsController]; the loudAlarm strategy reads them at runtime.
class _AlarmSection extends ConsumerWidget {
  const _AlarmSection({required this.state});

  final SettingsHubState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final notifier = ref.read(settingsControllerProvider.notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SwitchListTile(
          secondary: const Icon(Icons.notifications_off_outlined),
          title: Text(l10n.settingsAlarmDndOverrideLabel),
          value: state.alarmDndOverride,
          onChanged: notifier.setAlarmDndOverride,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 4),
          child: Row(
            children: <Widget>[
              Expanded(
                child: state.alarmDndOverride
                    ? const SizedBox.shrink()
                    : Text(
                        l10n.settingsAlarmDndOverrideWarning,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
              ),
              InfoIconButton(
                title: l10n.settingsAlarmDndOverrideLabel,
                body: l10n.settingsAlarmDndOverrideInfo,
              ),
            ],
          ),
        ),
        SwitchListTile(
          secondary: const Icon(Icons.volume_up_outlined),
          title: Text(l10n.settingsAlarmGradualLabel),
          value: state.alarmGradualVolume,
          onChanged: notifier.setAlarmGradualVolume,
        ),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: InfoIconButton(
            title: l10n.settingsAlarmGradualLabel,
            body: l10n.settingsAlarmGradualInfo,
          ),
        ),
        if (state.alarmGradualVolume)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 4, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        l10n.settingsAlarmRampLabel,
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                    InfoIconButton(
                      title: l10n.settingsAlarmRampLabel,
                      body: l10n.settingsAlarmRampInfo,
                    ),
                  ],
                ),
                TimingSlider(
                  valueSeconds: state.alarmGradualVolumeDurationSeconds,
                  minSeconds: 1,
                  maxSeconds: 60,
                  onChanged: notifier.setAlarmGradualVolumeDurationSeconds,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Editable emergency-services-number dialog (spec 06 §Emergency Number).
///
/// A free-form text field with a live, non-blocking [PhoneValidators]
/// warning rendered below the input, a Save action that is disabled while the
/// trimmed field is empty (the empty case blocks Save — a blank never
/// persists), and a small list of common-number quick-fills. Returns the
/// trimmed number via [Navigator.pop], or `null` on cancel.
class _EmergencyNumberDialog extends StatefulWidget {
  const _EmergencyNumberDialog({required this.initial});

  final String initial;

  @override
  State<_EmergencyNumberDialog> createState() => _EmergencyNumberDialogState();
}

class _EmergencyNumberDialogState extends State<_EmergencyNumberDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initial,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Common emergency-services numbers offered as one-tap quick-fills. Labels
  /// are region names (kept simple, not exhaustive); the user can still type
  /// any number directly.
  static const List<(String label, String number)> _presets =
      <(String, String)>[
        ('International (GSM)', '112'),
        ('US / Canada / Latin America', '911'),
        ('UK / Bangladesh / Kenya', '999'),
        ('Australia', '000'),
        ('New Zealand', '111'),
        ('China / Japan', '110'),
      ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.settingsEmergencyNumberEditTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // ValueListenableBuilder keeps the warning + Save-enabled state in
            // sync with each keystroke without a full setState rebuild.
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _controller,
              builder: (BuildContext context, TextEditingValue value, _) {
                final String trimmed = value.text.trim();
                final PhoneNumberWarning? warning =
                    PhoneValidators.warnEmergencyNumber(trimmed);
                final String? message = warning == null
                    ? null
                    : phoneWarningMessage(l10n, warning);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TextField(
                      controller: _controller,
                      autofocus: true,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: l10n.settingsEmergencyNumberFieldLabel,
                        // The empty-block hint is shown as an errorText (it is
                        // the only case that disables Save); the other advisory
                        // warnings are non-blocking helperText.
                        errorText: warning == PhoneNumberWarning.empty
                            ? message
                            : null,
                        helperText: warning == PhoneNumberWarning.empty
                            ? null
                            : message,
                        helperMaxLines: 3,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.settingsEmergencyNumberPresetsLabel,
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ],
                );
              },
            ),
            for (final (String label, String number) in _presets)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(label),
                trailing: Text(
                  number,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                onTap: () => _controller.text = number,
              ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel),
        ),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _controller,
          builder: (BuildContext context, TextEditingValue value, _) {
            final String trimmed = value.text.trim();
            return FilledButton(
              // Empty blocks Save (spec 06): the action is disabled, so a blank
              // can never overwrite the stored value.
              onPressed: trimmed.isEmpty
                  ? null
                  : () => Navigator.of(context).pop(trimmed),
              child: Text(l10n.commonSave),
            );
          },
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        text.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
