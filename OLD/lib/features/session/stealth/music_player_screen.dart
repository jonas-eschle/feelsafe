/// Music-player disguise screen used when
/// `StealthConfig.fakeIcon == StealthIconPreset.music`.
///
/// Per Q24 the disguise must be a *full* music-player UI — Now-
/// Playing card with album art, transport controls, scrubber. An
/// observer looking over the user's shoulder must read this as a
/// regular streaming app, not a "stealth" placeholder.
///
/// Disarm affordances (Q24, spec 04 §Stealth Mode UI):
///   * Horizontal swipe across ≥ 50% of the screen width = treat
///     as the "I'm safe" disarm gesture (forwards to
///     `SessionController.disarm` via the parent
///     [StealthSessionScreen]). *Why a swipe:* it visually reads as
///     "skip track", which is what an attacker would expect; the
///     50% threshold prevents accidental disarms from a tiny
///     thumb-drag.
///   * Long-press anywhere on the body = disarm fallback. *Why:*
///     accessibility — TalkBack users cannot reliably perform a
///     half-screen swipe, but they can long-press.
///
/// The session timer is woven into the scrubber: the engine's
/// `remainingSeconds` is mapped onto the track-progress bar so the
/// user retains a sense of the countdown without breaking the
/// disguise. When stealth's `timerDisplay == none` the digital
/// time text under the scrubber is hidden but the bar itself stays
/// visible (it just looks like a normal music progress bar).
library;

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:guardianangela/domain/models/stealth_config.dart';
import 'package:guardianangela/domain/models/walk_session.dart';
import 'package:guardianangela/features/session/stealth/disarm_gesture_wrapper.dart';
import 'package:guardianangela/features/settings/settings_controller.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// Music-player disguise screen.
///
/// Receives the active [WalkSession] from the parent disguise router
/// so the scrubber can map the engine timer onto the progress bar
/// without pulling its own session subscription. [onDisarm] is the
/// callback that ultimately runs the PIN-gated
/// `SessionController.disarm()` flow — wiring lives in
/// [StealthSessionScreen] so all three disguises share the same
/// gate.
class MusicPlayerScreen extends ConsumerWidget {
  /// Creates the Music disguise screen.
  const MusicPlayerScreen({
    super.key,
    required this.session,
    required this.onDisarm,
  });

  /// Snapshot of the active session — used to drive the scrubber.
  final WalkSession session;

  /// Callback invoked when the user performs a disarm gesture
  /// (long-press or qualifying horizontal swipe).
  final VoidCallback onDisarm;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final stealth =
        ref.watch(settingsControllerProvider).value?.defaults.stealth ??
            const StealthConfig();
    final fakeName =
        stealth.fakeName.isNotEmpty ? stealth.fakeName : l.stealthPresetMusic;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(fakeName),
        // Per spec 04: stealth-respecting branding — no Guardian
        // Angela logo, no shield. A neutral leading icon matches a
        // real music app's "library" affordance.
        leading: const Icon(Icons.queue_music),
      ),
      body: DisarmGestureWrapper(
        onDisarm: onDisarm,
        hint: l.stealthDisarmGestureHint,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l.stealthMusicNowPlaying,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: scheme.onSurfaceVariant,
                        letterSpacing: 1.2,
                      ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: _AlbumArt(scheme: scheme),
                ),
                const SizedBox(height: 24),
                Text(
                  l.stealthMusicTrackTitle,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  '${l.stealthMusicArtist} — ${l.stealthMusicAlbum}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                _Scrubber(
                  session: session,
                  hideDigits:
                      stealth.timerDisplay == StealthTimerDisplay.none,
                ),
                const SizedBox(height: 16),
                _TransportControls(
                  l: l,
                  onSkipNext: onDisarm,
                ),
                const SizedBox(height: 8),
                Text(
                  l.stealthMusicSwipeHint,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Album-art placeholder. A real app would resolve this from the
/// playback metadata; here we render a gradient square with a music
/// icon so the disguise still looks polished without shipping an
/// artwork asset.
class _AlbumArt extends StatelessWidget {
  const _AlbumArt({required this.scheme});

  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: AlignmentDirectional.topStart,
            end: AlignmentDirectional.bottomEnd,
            colors: [
              scheme.primary.withValues(alpha: 0.85),
              scheme.tertiary.withValues(alpha: 0.85),
            ],
          ),
        ),
        child: Center(
          child: Icon(
            Icons.music_note,
            size: 96,
            color: scheme.onPrimary.withValues(alpha: 0.9),
          ),
        ),
      ),
    );
  }
}

/// Progress bar bound to the engine's remaining seconds. We render a
/// real `Slider` (read-only) so it visually matches a streaming
/// app's scrubber. The user CANNOT drag it — moving it would not
/// influence the engine and would just look broken.
class _Scrubber extends StatelessWidget {
  const _Scrubber({required this.session, required this.hideDigits});

  final WalkSession session;
  final bool hideDigits;

  @override
  Widget build(BuildContext context) {
    final remaining = session.remainingSeconds ?? 0;
    // Synthesise a "track length" that's stable across rebuilds:
    // double the remaining seconds gives a steady scrubber that
    // looks like a long song. Falls back to 60 when the engine is
    // idle so the bar still renders.
    final total = remaining > 0 ? remaining * 2 : 60;
    final elapsed = total - remaining;
    final fraction = total == 0 ? 0.0 : (elapsed / total).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            overlayShape: SliderComponentShape.noOverlay,
          ),
          child: Slider(
            value: fraction,
            onChanged: null,
          ),
        ),
        if (!hideDigits)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_formatMmSs(elapsed)),
                Text(_formatMmSs(total)),
              ],
            ),
          ),
      ],
    );
  }

  static String _formatMmSs(int seconds) {
    final s = seconds.clamp(0, 99 * 60 + 59);
    final m = s ~/ 60;
    final r = s % 60;
    return '${m.toString().padLeft(1, '0')}:${r.toString().padLeft(2, '0')}';
  }
}

/// Transport controls — Skip Previous / Play-Pause / Skip Next.
/// "Skip Next" forwards to the disarm callback; the other two are
/// purely visual (tapping them does nothing to the engine, which
/// keeps the disguise honest while still letting the user hit
/// Pause without consequence).
class _TransportControls extends StatelessWidget {
  const _TransportControls({required this.l, required this.onSkipNext});

  final AppLocalizations l;
  final VoidCallback onSkipNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          iconSize: 36,
          icon: const Icon(Icons.skip_previous),
          tooltip: l.stealthMusicPrevious,
          onPressed: () {},
        ),
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.primary,
          ),
          child: IconButton(
            iconSize: 48,
            icon: Icon(
              Icons.pause,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            tooltip: l.stealthMusicPause,
            onPressed: () {},
          ),
        ),
        IconButton(
          iconSize: 36,
          icon: const Icon(Icons.skip_next),
          tooltip: l.stealthMusicNext,
          onPressed: onSkipNext,
        ),
      ],
    );
  }
}

