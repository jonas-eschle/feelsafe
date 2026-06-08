import 'package:flutter/material.dart';

import 'package:guardianangela/core/widgets/swipe_slider.dart';
import 'package:guardianangela/domain/enums/stealth_timer_display.dart';
import 'package:guardianangela/features/session/widgets/session_elapsed_clock.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// Full-screen music-player disguise for an active stealth session.
///
/// Presents the running session as an ordinary music app (spec 04 §Fake
/// Music Player): a minimalist header, an album-art placeholder, track/artist
/// chrome, standard transport controls, and a progress track. The controls
/// are bound to the **real** session controls — they invent no new session
/// semantics:
///
/// * The play/pause button calls [onPlayPause]; the host wires it to the
///   controller's `pause()` / `resume()` (play = resume, pause = pause).
/// * Swiping the progress track left-to-right past its threshold calls
///   [onDisarm] — the host wires it to the controller's `disarm()` ("I feel
///   fine"). A swipe (not a tap) is required so a stray screen-press cannot
///   disarm the chain (spec 04 §Grace Period Slider).
///
/// The elapsed-time clock is shown as the playback-time indicator per
/// [timerDisplay] via [SessionElapsedClock]; [interactionSignal] feeds its
/// G-018 idle-fade behaviour.
class FakeMusicPlayer extends StatelessWidget {
  /// Creates a [FakeMusicPlayer].
  const FakeMusicPlayer({
    super.key,
    required this.elapsedSeconds,
    required this.isPaused,
    required this.timerDisplay,
    required this.fakeName,
    required this.onPlayPause,
    required this.onDisarm,
    this.interactionSignal,
  });

  /// Elapsed wall-clock seconds since the session started (the "playback
  /// time").
  final int elapsedSeconds;

  /// Whether the session is currently paused — drives the play/pause glyph
  /// (paused → show the play arrow; running → show the pause bars).
  final bool isPaused;

  /// Which clock presentation to render as the playback-time indicator.
  final StealthTimerDisplay timerDisplay;

  /// The resolved disguise app name ([StealthConfig.fakeName]) shown as the
  /// player's app/brand line in the header — the slot the spec mockup labels
  /// "Spotify / Apple Music" (spec 04 §Fake Music Player; 06:85 — fakeName is
  /// the disguise app name). Falls back to a neutral "Now playing" label when
  /// empty so the header is never blank.
  final String fakeName;

  /// Invoked when the user taps the central transport button. The host wires
  /// this to `resume()` when [isPaused] is true and `pause()` otherwise.
  final VoidCallback onPlayPause;

  /// Invoked when the user swipes the progress track past its threshold — the
  /// disguised "I feel fine" disarm. The host wires this to `disarm()`.
  final VoidCallback onDisarm;

  /// Forwarded to [SessionElapsedClock] so a screen-wide tap/swipe restores
  /// the small corner clock to full opacity (G-018).
  final Listenable? interactionSignal;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final textTheme = theme.textTheme;
    return SafeArea(
      child: LayoutBuilder(
        builder: (BuildContext _, BoxConstraints constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight.isFinite
                    ? constraints.maxHeight - 48
                    : 0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  // Minimalist header: chevron + brand line + corner clock.
                  Row(
                    children: <Widget>[
                      Icon(Icons.expand_more, color: cs.onSurfaceVariant),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          // The disguise app name occupies the header (the
                          // "Spotify / Apple Music" slot). Empty fakeName falls
                          // back to a neutral localized label so the header is
                          // never blank.
                          fakeName.trim().isEmpty
                              ? l10n.sessionStealthNowPlaying
                              : fakeName,
                          style: textTheme.titleSmall,
                        ),
                      ),
                      // The elapsed clock doubles as the media-player time
                      // indicator. In `small` mode it lives here in the
                      // top-right (G-018); the `normal` clock renders here as a
                      // full timer; `none` collapses to nothing.
                      SessionElapsedClock(
                        elapsedSeconds: elapsedSeconds,
                        displayMode: timerDisplay,
                        interactionSignal: interactionSignal,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Album-art placeholder.
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 240,
                        maxHeight: 240,
                      ),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Semantics(
                          label: l10n.sessionStealthAlbumArtLabel,
                          image: true,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: cs.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.music_note,
                              size: 96,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Track + artist chrome.
                  Text(
                    l10n.sessionStealthTrackTitle,
                    style: textTheme.titleLarge,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.sessionStealthArtistName,
                    style: textTheme.titleMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 24),
                  // Standard transport controls. Skip-prev / skip-next are
                  // decorative (no session semantics); the centre button is
                  // the real pause/resume toggle.
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Icon(
                        Icons.skip_previous,
                        size: 40,
                        color: cs.onSurfaceVariant,
                      ),
                      IconButton(
                        iconSize: 64,
                        tooltip: isPaused
                            ? l10n.sessionStealthPlay
                            : l10n.sessionStealthPause,
                        icon: Icon(
                          isPaused
                              ? Icons.play_circle_fill
                              : Icons.pause_circle_filled,
                          color: cs.primary,
                        ),
                        onPressed: onPlayPause,
                      ),
                      Icon(
                        Icons.skip_next,
                        size: 40,
                        color: cs.onSurfaceVariant,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Progress track — swiping it left-to-right disarms ("I feel
                  // fine"). Styled as a scrubber; the reused stealth disarm
                  // label keeps the safety meaning hidden from an observer.
                  SwipeSlider(
                    label: l10n.sessionDisarmStealth,
                    semanticsLabel: l10n.sessionDisarmStealth,
                    onConfirm: onDisarm,
                    threshold: 0.85,
                    height: 48,
                    trackColor: cs.surfaceContainerHighest,
                    knobColor: cs.primary,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
