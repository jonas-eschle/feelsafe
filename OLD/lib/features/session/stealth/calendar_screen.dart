/// Calendar disguise screen used when
/// `StealthConfig.fakeIcon == StealthIconPreset.calendar`.
///
/// Per Q24 the disguise must be a *full* calendar UI — a list of
/// mock events, with the active session timer woven in as an
/// "event-until-start" countdown for a fake upcoming event.
///
/// Disarm affordances (Q24, spec 04 §Stealth Mode UI):
///   * Horizontal swipe across ≥ 50% of the screen width = disarm.
///   * Long-press anywhere on the body = disarm (accessibility
///     fallback).
///   * Long-press on any event row = disarm. *Why per-row:* a
///     real calendar app's long-press shows a context menu; an
///     attacker has no way to verify that — they just see the user
///     holding a row.
library;

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:guardianangela/domain/models/stealth_config.dart';
import 'package:guardianangela/domain/models/walk_session.dart';
import 'package:guardianangela/features/session/stealth/disarm_gesture_wrapper.dart';
import 'package:guardianangela/features/settings/settings_controller.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// Calendar disguise screen.
class CalendarScreen extends ConsumerWidget {
  /// Creates the Calendar disguise screen.
  const CalendarScreen({
    super.key,
    required this.session,
    required this.onDisarm,
  });

  /// Snapshot of the active session — the remaining seconds drive
  /// the "in N min" countdown next to the upcoming event.
  final WalkSession session;

  /// Callback invoked when the user performs a disarm gesture.
  final VoidCallback onDisarm;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final stealth =
        ref.watch(settingsControllerProvider).value?.defaults.stealth ??
            const StealthConfig();
    final fakeName = stealth.fakeName.isNotEmpty
        ? stealth.fakeName
        : l.stealthPresetCalendar;
    // Convert remainingSeconds into "minutes until event" (round
    // up so 30s still reads "in 1 min" rather than "in 0 min").
    final remainingSeconds = session.remainingSeconds ?? 0;
    final minutesUntil = remainingSeconds <= 0
        ? 0
        : ((remainingSeconds + 59) ~/ 60);
    final showTimer = stealth.timerDisplay != StealthTimerDisplay.none;

    return Scaffold(
      appBar: AppBar(
        title: Text(fakeName),
        leading: const Icon(Icons.calendar_month),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search',
            onPressed: () {},
          ),
        ],
      ),
      body: DisarmGestureWrapper(
        onDisarm: onDisarm,
        hint: l.stealthDisarmGestureHint,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _SectionHeader(text: l.stealthCalendarUpcoming),
              _UpcomingEventCard(
                title: l.stealthCalendarUpcomingEvent,
                countdown: showTimer
                    ? l.stealthCalendarUntilEvent(minutesUntil)
                    : '',
                onLongPress: onDisarm,
              ),
              const SizedBox(height: 16),
              _SectionHeader(text: l.stealthCalendarToday),
              for (final entry in <(String, String)>[
                ('09:00', l.stealthCalendarEvent2),
                ('11:30', l.stealthCalendarEvent3),
                ('14:00', l.stealthCalendarEvent4),
                ('18:00', l.stealthCalendarEvent5),
                ('21:00', l.stealthCalendarEvent1),
              ])
                _EventRow(
                  time: entry.$1,
                  title: entry.$2,
                  onLongPress: onDisarm,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}

/// Card for the next upcoming event. The countdown copy is the
/// disguised session timer.
class _UpcomingEventCard extends StatelessWidget {
  const _UpcomingEventCard({
    required this.title,
    required this.countdown,
    required this.onLongPress,
  });

  final String title;
  final String countdown;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: scheme.primaryContainer,
      child: InkWell(
        onTap: () {},
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: scheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    if (countdown.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        countdown,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.notifications_outlined, color: scheme.onPrimaryContainer),
            ],
          ),
        ),
      ),
    );
  }
}

/// Single event row. Long-press fires the disarm gesture.
class _EventRow extends StatelessWidget {
  const _EventRow({
    required this.time,
    required this.title,
    required this.onLongPress,
  });

  final String time;
  final String title;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: SizedBox(
        width: 48,
        child: Text(
          time,
          style: Theme.of(context).textTheme.labelMedium,
        ),
      ),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onLongPress: onLongPress,
      onTap: () {},
    );
  }
}
