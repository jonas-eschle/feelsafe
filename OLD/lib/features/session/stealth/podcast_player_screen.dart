/// Podcast-player disguise screen used when
/// `StealthConfig.fakeIcon == StealthIconPreset.podcast`.
///
/// Per Q24 the disguise must be a *full* podcast-player UI — show
/// title + episode title, a speed control (0.5x / 1x / 1.5x / 2x),
/// and a scrollable mock episode list below the now-playing card.
/// An observer reading over the user's shoulder must read this as
/// a real podcast app.
///
/// Disarm affordances (Q24, spec 04 §Stealth Mode UI):
///   * Horizontal swipe across ≥ 50% of the screen width = treat
///     as the "I'm safe" disarm gesture.
///   * Long-press anywhere on the body = disarm fallback
///     (accessibility).
///   * Long-press on any episode row = disarm. *Why per-row:* the
///     long-press affordance feels natural in a list ("more
///     options"); a real podcast app shows a context menu, but a
///     curious onlooker has no way to verify that — they just see
///     the user holding a row.
library;

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:guardianangela/domain/models/stealth_config.dart';
import 'package:guardianangela/domain/models/walk_session.dart';
import 'package:guardianangela/features/session/stealth/disarm_gesture_wrapper.dart';
import 'package:guardianangela/features/settings/settings_controller.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// Podcast-player disguise screen.
class PodcastPlayerScreen extends ConsumerStatefulWidget {
  /// Creates the Podcast disguise screen.
  const PodcastPlayerScreen({
    super.key,
    required this.session,
    required this.onDisarm,
  });

  /// Snapshot of the active session — used to drive the playback
  /// progress bar.
  final WalkSession session;

  /// Callback invoked when the user performs a disarm gesture.
  final VoidCallback onDisarm;

  @override
  ConsumerState<PodcastPlayerScreen> createState() =>
      _PodcastPlayerScreenState();
}

class _PodcastPlayerScreenState extends ConsumerState<PodcastPlayerScreen> {
  /// User-selected playback speed. Purely visual — does NOT affect
  /// the engine. *Why expose it anyway:* a real podcast app always
  /// has a speed selector; leaving it out would tip off an observer.
  double _speed = 1.0;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final stealth =
        ref.watch(settingsControllerProvider).value?.defaults.stealth ??
            const StealthConfig();
    final fakeName =
        stealth.fakeName.isNotEmpty ? stealth.fakeName : l.stealthPresetPodcast;

    return Scaffold(
      appBar: AppBar(
        title: Text(fakeName),
        leading: const Icon(Icons.podcasts),
      ),
      body: DisarmGestureWrapper(
        onDisarm: widget.onDisarm,
        hint: l.stealthDisarmGestureHint,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _NowPlayingCard(
                showName: l.stealthPodcastShowName,
                episodeTitle: l.stealthPodcastEpisodeTitle,
                session: widget.session,
                hideDigits:
                    stealth.timerDisplay == StealthTimerDisplay.none,
              ),
              const SizedBox(height: 16),
              _SpeedSelector(
                speed: _speed,
                label: l.stealthPodcastSpeedLabel,
                onChanged: (v) => setState(() => _speed = v),
              ),
              const SizedBox(height: 24),
              Text(
                l.stealthPodcastEpisodesHeader,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              for (final title in <String>[
                l.stealthPodcastEpisode1,
                l.stealthPodcastEpisode2,
                l.stealthPodcastEpisode3,
                l.stealthPodcastEpisode4,
              ])
                _EpisodeRow(
                  title: title,
                  showName: l.stealthPodcastShowName,
                  onLongPress: widget.onDisarm,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Now-Playing card with show + episode + a passive progress bar.
class _NowPlayingCard extends StatelessWidget {
  const _NowPlayingCard({
    required this.showName,
    required this.episodeTitle,
    required this.session,
    required this.hideDigits,
  });

  final String showName;
  final String episodeTitle;
  final WalkSession session;
  final bool hideDigits;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final remaining = session.remainingSeconds ?? 0;
    final total = remaining > 0 ? remaining * 3 : 1800;
    final fraction =
        total == 0 ? 0.0 : ((total - remaining) / total).clamp(0.0, 1.0);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: scheme.secondaryContainer,
                  ),
                  child: Icon(
                    Icons.graphic_eq,
                    size: 32,
                    color: scheme.onSecondaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        showName,
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        episodeTitle,
                        style: Theme.of(context).textTheme.bodyMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: fraction),
            if (!hideDigits)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _format(remaining),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
          ],
        ),
      ),
    );
  }

  static String _format(int seconds) {
    final s = seconds.clamp(0, 24 * 3600);
    final h = s ~/ 3600;
    final m = (s % 3600) ~/ 60;
    final ss = s % 60;
    if (h > 0) {
      return '$h:${m.toString().padLeft(2, '0')}:'
          '${ss.toString().padLeft(2, '0')}';
    }
    return '$m:${ss.toString().padLeft(2, '0')}';
  }
}

/// Playback-speed selector. Renders 0.5x / 1x / 1.5x / 2x as
/// `ChoiceChip`s — selecting one is purely cosmetic.
class _SpeedSelector extends StatelessWidget {
  const _SpeedSelector({
    required this.speed,
    required this.label,
    required this.onChanged,
  });

  final double speed;
  final String label;
  final ValueChanged<double> onChanged;

  static const List<double> _options = [0.5, 1.0, 1.5, 2.0];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (final option in _options)
              ChoiceChip(
                label: Text('${option}x'),
                selected: speed == option,
                onSelected: (sel) {
                  if (sel) onChanged(option);
                },
              ),
          ],
        ),
      ],
    );
  }
}

/// Single episode row in the mock list. Long-press fires the disarm.
class _EpisodeRow extends StatelessWidget {
  const _EpisodeRow({
    required this.title,
    required this.showName,
    required this.onLongPress,
  });

  final String title;
  final String showName;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.play_circle_outline),
      title: Text(title),
      subtitle: Text(showName),
      trailing: const Icon(Icons.more_vert),
      onLongPress: onLongPress,
      onTap: () {},
    );
  }
}
