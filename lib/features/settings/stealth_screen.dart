/// Stealth configuration screen.
library;

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:guardianangela/domain/models/app_defaults.dart';
import 'package:guardianangela/domain/models/stealth_config.dart';
import 'package:guardianangela/features/settings/settings_controller.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';
import 'package:guardianangela/services/service_providers.dart';

/// Stealth screen.
class StealthScreen extends ConsumerWidget {
  /// Creates the stealth screen.
  const StealthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final settings = ref.watch(settingsControllerProvider).value;
    final stealth = settings?.defaults.stealth ?? const StealthConfig();

    Future<void> update(StealthConfig next) {
      final defaults = (settings?.defaults ?? const AppDefaults()).copyWith(
        stealth: next,
      );
      return ref
          .read(settingsControllerProvider.notifier)
          .setDefaults(defaults);
    }

    Future<void> pickPreset(StealthIconPreset preset) async {
      // Swap the platform alias first so an error surfaces before we
      // persist the user's choice. If the platform call throws, the
      // settings copy is not written.
      await ref.read(stealthIconServiceProvider).setPreset(preset);
      await update(stealth.copyWith(fakeIcon: preset));
    }

    return Scaffold(
      appBar: AppBar(title: Text(l.stealthTitle)),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text(l.stealthEnable),
            value: stealth.enabled,
            onChanged: (v) => update(stealth.copyWith(enabled: v)),
          ),
          // Editable fake-name TextField — the user MUST be able to
          // pick the disguise label that appears in launcher/menus to
          // align with their personal cover story.
          _FakeNameField(
            value: stealth.fakeName,
            onChanged: (v) => update(stealth.copyWith(fakeName: v)),
          ),
          SwitchListTile(
            title: Text(l.stealthNotificationDisguise),
            value: stealth.notificationDisguise,
            onChanged: (v) => update(stealth.copyWith(notificationDisguise: v)),
          ),
          SwitchListTile(
            title: Text(l.stealthTimerDisplay),
            value: stealth.timerDisplay,
            onChanged: (v) => update(stealth.copyWith(timerDisplay: v)),
          ),
          SwitchListTile(
            title: Text(l.stealthSessionScreen),
            value: stealth.sessionScreenStealth,
            onChanged: (v) => update(stealth.copyWith(sessionScreenStealth: v)),
          ),
          const Divider(),
          _IconPresetPicker(
            currentPreset: stealth.fakeIcon,
            onSelect: pickPreset,
          ),
        ],
      ),
    );
  }
}

/// Editable text field for [StealthConfig.fakeName]. Stateful so the
/// underlying [TextEditingController] is bound to the field's
/// lifecycle rather than rebuilt on every parent rebuild.
class _FakeNameField extends StatefulWidget {
  const _FakeNameField({required this.value, required this.onChanged});

  /// Current persisted fake-name.
  final String value;

  /// Called when the user finishes editing (blur or submit) with a
  /// non-empty value. Empty submissions are ignored — fakeName is
  /// always shown to an observer, so a blank value would be a tell.
  final ValueChanged<String> onChanged;

  @override
  State<_FakeNameField> createState() => _FakeNameFieldState();
}

class _FakeNameFieldState extends State<_FakeNameField> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant _FakeNameField old) {
    super.didUpdateWidget(old);
    if (_ctrl.text != widget.value) {
      _ctrl.text = widget.value;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _commit(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return;
    widget.onChanged(trimmed);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: TextField(
        controller: _ctrl,
        decoration: InputDecoration(
          labelText: l.stealthFakeName,
          border: const OutlineInputBorder(),
        ),
        onSubmitted: _commit,
        onEditingComplete: () => _commit(_ctrl.text),
      ),
    );
  }
}

/// Horizontal carousel of stealth icon presets. Tapping one swaps
/// the platform alias and persists the selection.
class _IconPresetPicker extends StatelessWidget {
  const _IconPresetPicker({
    required this.currentPreset,
    required this.onSelect,
  });

  final StealthIconPreset currentPreset;
  final Future<void> Function(StealthIconPreset) onSelect;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Text(l.stealthPickerTitle, style: textTheme.titleMedium),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Text(l.stealthPickerIntro, style: textTheme.bodySmall),
        ),
        SizedBox(
          height: 110,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: StealthIconPreset.values.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final preset = StealthIconPreset.values[index];
              return _PresetTile(
                preset: preset,
                selected: preset == currentPreset,
                label: _labelFor(l, preset),
                icon: _iconFor(preset),
                onTap: () => onSelect(preset),
              );
            },
          ),
        ),
      ],
    );
  }

  static String _labelFor(AppLocalizations l, StealthIconPreset preset) =>
      switch (preset) {
        StealthIconPreset.music => l.stealthPresetMusic,
        StealthIconPreset.calendar => l.stealthPresetCalendar,
        StealthIconPreset.fitness => l.stealthPresetFitness,
        StealthIconPreset.weather => l.stealthPresetWeather,
        StealthIconPreset.news => l.stealthPresetNews,
        StealthIconPreset.photos => l.stealthPresetPhotos,
        StealthIconPreset.notes => l.stealthPresetNotes,
        StealthIconPreset.clock => l.stealthPresetClock,
        StealthIconPreset.podcast => l.stealthPresetPodcast,
        StealthIconPreset.none => l.stealthPresetNone,
      };

  static IconData _iconFor(StealthIconPreset preset) => switch (preset) {
        StealthIconPreset.music => Icons.music_note,
        StealthIconPreset.calendar => Icons.calendar_today,
        StealthIconPreset.fitness => Icons.fitness_center,
        StealthIconPreset.weather => Icons.wb_sunny,
        StealthIconPreset.news => Icons.article,
        StealthIconPreset.photos => Icons.photo,
        StealthIconPreset.notes => Icons.note,
        StealthIconPreset.clock => Icons.access_time,
        StealthIconPreset.podcast => Icons.podcasts,
        StealthIconPreset.none => Icons.shield_outlined,
      };
}

class _PresetTile extends StatelessWidget {
  const _PresetTile({
    required this.preset,
    required this.selected,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final StealthIconPreset preset;
  final bool selected;
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 88,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? scheme.primary : scheme.outlineVariant,
            width: selected ? 2 : 1,
          ),
          color: selected ? scheme.primaryContainer : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.topRight,
              children: [
                Icon(icon, size: 40, color: scheme.primary),
                if (selected)
                  Icon(Icons.check_circle, size: 16, color: scheme.primary),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }
}
