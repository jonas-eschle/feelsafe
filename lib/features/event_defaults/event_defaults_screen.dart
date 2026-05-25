import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/features/event_defaults/event_defaults_controller.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// Event defaults screen.
///
/// Renders an [ExpansionTile] per step type for inline per-type config.
/// Phase 6 displays each step type's name and current defaults; full
/// per-field editors live in `EventDefaultsScreen.subform()` for Phase
/// 7's editor reuse. See spec 04 §Event Defaults.
class EventDefaultsScreen extends ConsumerWidget {
  /// Creates an [EventDefaultsScreen].
  const EventDefaultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final stateAsync = ref.watch(eventDefaultsControllerProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.eventDefaultsTitle)),
      body: stateAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, _) => Center(child: Text('Error: $e')),
        data: (state) => ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            _Header(text: l10n.eventDefaultsCheckInHeader),
            for (final t in <ChainStepType>[
              ChainStepType.holdButton,
              ChainStepType.disguisedReminder,
            ])
              _TypeTile(type: t),
            const Divider(),
            _Header(text: l10n.eventDefaultsEscalationHeader),
            for (final t in <ChainStepType>[
              ChainStepType.countdownWarning,
              ChainStepType.fakeCall,
              ChainStepType.smsContact,
              ChainStepType.phoneCallContact,
              ChainStepType.loudAlarm,
              ChainStepType.callEmergency,
            ])
              _TypeTile(type: t),
            const Divider(),
            _Header(text: l10n.eventDefaultsPanicHeader),
            const _TypeTile(type: ChainStepType.hardwareButton),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(text, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

class _TypeTile extends StatelessWidget {
  const _TypeTile({required this.type});

  final ChainStepType type;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        leading: Icon(_iconFor(type)),
        title: Text(type.name),
        subtitle: Text(_descriptionFor(type)),
        children: const <Widget>[
          Padding(
            padding: EdgeInsets.all(16),
            child: Text('Configure timing and behaviour for this step type.'),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(ChainStepType t) {
    return switch (t) {
      ChainStepType.holdButton => Icons.touch_app_outlined,
      ChainStepType.disguisedReminder => Icons.notifications_outlined,
      ChainStepType.countdownWarning => Icons.warning_amber_outlined,
      ChainStepType.fakeCall => Icons.phone_outlined,
      ChainStepType.smsContact => Icons.message_outlined,
      ChainStepType.phoneCallContact => Icons.phone_forwarded_outlined,
      ChainStepType.loudAlarm => Icons.volume_up_outlined,
      ChainStepType.callEmergency => Icons.emergency_outlined,
      ChainStepType.hardwareButton => Icons.touch_app,
    };
  }

  String _descriptionFor(ChainStepType t) {
    return switch (t) {
      ChainStepType.holdButton =>
        'Hold to stay safe — releasing starts a grace countdown.',
      ChainStepType.disguisedReminder =>
        'Sends a disguised notification — respond to confirm safety.',
      ChainStepType.countdownWarning =>
        'Shows a countdown with sound and flash as a last warning.',
      ChainStepType.fakeCall =>
        'Simulates an incoming call — answer or decline.',
      ChainStepType.smsContact =>
        'Sends an SMS with your location to emergency contacts.',
      ChainStepType.phoneCallContact => 'Calls an emergency contact directly.',
      ChainStepType.loudAlarm =>
        'Plays a max-volume alarm with flash to attract attention.',
      ChainStepType.callEmergency =>
        'Calls emergency services (112/911) automatically.',
      ChainStepType.hardwareButton =>
        'Watches a hardware button for a panic press pattern.',
    };
  }
}
