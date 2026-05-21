/// Simulation-only advanced controls shown on the SessionScreen.
///
/// Spec 04 §SessionScreen — Simulation Advanced controls. A
/// collapsible expander that reveals a logarithmic speed slider +
/// three trigger buttons (Arrival / Battery / Panic). Visible only
/// when `session.isSimulation == true`.
library;

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:guardianangela/core/widgets/logarithmic_slider.dart';
import 'package:guardianangela/features/session/session_controller.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// Maximum simulation speed offered by the slider.
const double kSimulationSpeedMax = 1000.0;

/// Minimum simulation speed offered by the slider.
const double kSimulationSpeedMin = 1.0;

/// Speed preset chips shown alongside the slider.
const List<double> kSimulationSpeedPresets = <double>[1, 10, 60, 1000];

/// Simulation advanced controls — visible only during simulation
/// sessions.
class SimulationAdvancedControls extends ConsumerStatefulWidget {
  /// Creates the advanced-controls expander.
  const SimulationAdvancedControls({super.key});

  @override
  ConsumerState<SimulationAdvancedControls> createState() =>
      _SimulationAdvancedControlsState();
}

class _SimulationAdvancedControlsState
    extends ConsumerState<SimulationAdvancedControls> {
  double _speed = 1.0;

  void _setSpeed(double value) {
    setState(() => _speed = value);
    ref
        .read(sessionControllerProvider.notifier)
        .setSimulationSpeedMultiplier(value);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    // Informational note: whenever the configured speed exceeds
    // the 60× background cap, surface it so the user understands
    // the backgrounded-effective ceiling. The actual clamp is
    // engaged by the SessionScreen's lifecycle observer when the
    // app transitions to background.
    final willBeCapped = _speed > 60.0;
    final effectiveSpeed = _speed;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ExpansionTile(
        title: Text(l.sessionSimAdvancedLabel),
        leading: const Icon(Icons.tune),
        childrenPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        children: [
          _SpeedSection(
            speed: _speed,
            effectiveSpeed: effectiveSpeed,
            backgroundCapped: willBeCapped,
            onChanged: _setSpeed,
            presets: kSimulationSpeedPresets,
          ),
          const SizedBox(height: 16),
          _TriggerButtons(
            arrivalLabel: l.sessionSimTriggerArrival,
            batteryLabel: l.sessionSimTriggerBattery,
            panicLabel: l.sessionSimTriggerPanic,
            onArrival: () => ref
                .read(sessionControllerProvider.notifier)
                .simulateGpsArrival(),
            onBattery: () => ref
                .read(sessionControllerProvider.notifier)
                .simulateLowBattery(),
            onPanic: () => ref
                .read(sessionControllerProvider.notifier)
                .triggerDistressChain(),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _SpeedSection extends StatelessWidget {
  const _SpeedSection({
    required this.speed,
    required this.effectiveSpeed,
    required this.backgroundCapped,
    required this.onChanged,
    required this.presets,
  });

  final double speed;
  final double effectiveSpeed;
  final bool backgroundCapped;
  final ValueChanged<double> onChanged;
  final List<double> presets;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(l.sessionSimSpeedLabel)),
            Text(
              l.sessionSimSpeedValue(effectiveSpeed.round()),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        LogarithmicSlider(
          minValue: kSimulationSpeedMin,
          maxValue: kSimulationSpeedMax,
          value: speed,
          onChanged: onChanged,
        ),
        if (backgroundCapped)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              l.sessionSimSpeedBackgroundCap,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.tertiary,
              ),
            ),
          ),
        Wrap(
          spacing: 8,
          children: presets
              .map(
                (p) => ChoiceChip(
                  label: Text('${p.round()}×'),
                  selected: speed == p,
                  onSelected: (_) => onChanged(p),
                ),
              )
              .toList(growable: false),
        ),
      ],
    );
  }
}

class _TriggerButtons extends StatelessWidget {
  const _TriggerButtons({
    required this.arrivalLabel,
    required this.batteryLabel,
    required this.panicLabel,
    required this.onArrival,
    required this.onBattery,
    required this.onPanic,
  });

  final String arrivalLabel;
  final String batteryLabel;
  final String panicLabel;
  final VoidCallback onArrival;
  final VoidCallback onBattery;
  final VoidCallback onPanic;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: [
      FilledButton.tonalIcon(
        icon: const Icon(Icons.location_on),
        label: Text(arrivalLabel),
        onPressed: onArrival,
      ),
      FilledButton.tonalIcon(
        icon: const Icon(Icons.battery_alert),
        label: Text(batteryLabel),
        onPressed: onBattery,
      ),
      FilledButton.tonalIcon(
        icon: const Icon(Icons.warning_amber),
        label: Text(panicLabel),
        onPressed: onPanic,
      ),
    ],
  );
}
