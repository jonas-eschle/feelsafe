/// Simulation-run summary screen.
library;

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:guardianangela/core/constants/route_names.dart';
import 'package:guardianangela/domain/orchestration/event_strategy.dart';
import 'package:guardianangela/features/session/session_controller.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// Shown after a simulation run.
class SimulationSummaryScreen extends ConsumerWidget {
  /// Creates the simulation-summary screen.
  const SimulationSummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final session = ref.watch(sessionControllerProvider).value;
    final fired =
        session?.firedStepDescriptions ?? const <SimulationDescription>[];
    return Scaffold(
      appBar: AppBar(title: Text(l.simulationSummaryTitle)),
      body: fired.isEmpty
          ? Center(child: Text(l.simulationSummaryEmpty))
          : ListView.builder(
              itemCount: fired.length,
              itemBuilder: (context, i) => ListTile(
                leading: CircleAvatar(child: Text('${i + 1}')),
                title: Text(resolveSimulationDescription(l, fired[i])),
              ),
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: FilledButton(
          onPressed: () => context.go(RouteNames.home),
          child: Text(l.simulationSummaryReturn),
        ),
      ),
    );
  }
}

/// Resolves a [SimulationDescription] to a localized user-facing
/// string by switching on its [SimulationDescription.templateKey].
///
/// Why a top-level function instead of an instance method on
/// [SimulationDescription]: the value type lives in pure-Dart
/// `lib/domain/orchestration/`, which never imports Flutter or
/// `AppLocalizations`. The localization layer is the right place to
/// own this switch. Fix for `docs/verification/bugs.json` Warn 5.
String resolveSimulationDescription(
  AppLocalizations l,
  SimulationDescription d,
) {
  switch (d.templateKey) {
    case 'simLoudAlarm':
      final flash = d.args['flash'] == true;
      final tail = flash ? l.simLoudAlarmTailFlash : l.simLoudAlarmTailVibrate;
      return l.simLoudAlarm(tail);
    case 'simSmsContact':
      final channel = d.args['channel']?.toString() ?? '';
      final count = (d.args['count'] is num)
          ? (d.args['count']! as num).toInt()
          : 0;
      return l.simSmsContact(channel, count);
    case 'simFakeCallRing':
      final caller = d.args['caller']?.toString() ?? '';
      return l.simFakeCallRing(caller);
    case 'simCountdownWarning':
      final seconds = (d.args['seconds'] is num)
          ? (d.args['seconds']! as num).toInt()
          : 0;
      return l.simCountdownWarning(seconds);
    case 'simPhoneCall':
      final name = d.args['name']?.toString() ?? '';
      return l.simPhoneCall(name);
    case 'simNoContactToCall':
      return l.simNoContactToCall;
    case 'simCallEmergency':
      final number = d.args['number']?.toString() ?? '';
      return l.simCallEmergency(number);
    case 'simHardwareButton':
      return l.simHardwareButton;
    case 'simHoldButton':
      return l.simHoldButton;
    case 'simDisguisedReminder':
      final title = d.args['title']?.toString() ?? '';
      return l.simDisguisedReminder(title);
    case 'simDisguisedReminderEmpty':
      return l.simDisguisedReminderEmpty;
    case 'simGpsArrivalTrigger':
      return l.simGpsArrivalTrigger;
    case 'simLowBatteryAlert':
      return l.simLowBatteryAlert;
    default:
      // Unknown key: surface the raw template key so the developer
      // sees the gap. Better than silently rendering an empty string.
      return d.templateKey;
  }
}
