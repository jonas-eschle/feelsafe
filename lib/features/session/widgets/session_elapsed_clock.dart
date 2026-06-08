import 'dart:async';

import 'package:flutter/material.dart';

import 'package:guardianangela/domain/enums/stealth_timer_display.dart';

/// Stable key used to locate the elapsed-time clock in widget tests.
///
/// Spec 04 §Timer Display Options asserts the clock's presence/position via
/// `find.byKey(sessionElapsedClockKey)`.
const Key sessionElapsedClockKey = Key('session-elapsed-clock');

/// Elapsed-session clock with three spec-defined presentations.
///
/// Renders the running session's elapsed time per [displayMode]
/// (spec 04 §Timer Display Options):
///
/// * [StealthTimerDisplay.normal] — full timer in a monospace heading font,
///   formatted `H:MM:SS` for sessions ≥ 1 h and `M:SS` otherwise. Always
///   100 % opacity (no fade).
/// * [StealthTimerDisplay.small] — a 12 pt monospace digital clock intended
///   for the **top-right corner** of the session screen, formatted `M:SS`
///   (falling back to `H:MM` once the session passes 99 min). After 10 s of
///   no user interaction it fades to 50 % opacity over 400 ms (G-018); any
///   interaction signalled via [interactionSignal] restores it to 100 %
///   instantly and restarts the idle timer.
/// * [StealthTimerDisplay.none] — renders nothing visible (an empty
///   [SizedBox] that still carries [sessionElapsedClockKey], so the widget
///   tree position is testable).
///
/// The widget is purely presentational: it formats the [elapsedSeconds] value
/// the controller already publishes and owns only the small-mode fade timer.
class SessionElapsedClock extends StatefulWidget {
  /// Creates a [SessionElapsedClock].
  ///
  /// The key defaults to [sessionElapsedClockKey] so callers and tests can
  /// locate it without threading a key explicitly; pass an explicit [key] to
  /// override (e.g. when two clocks coexist in one test harness).
  const SessionElapsedClock({
    Key? key,
    required this.elapsedSeconds,
    required this.displayMode,
    this.interactionSignal,
  }) : super(key: key ?? sessionElapsedClockKey);

  /// Elapsed wall-clock seconds since the session started.
  final int elapsedSeconds;

  /// Which of the three presentations to render.
  final StealthTimerDisplay displayMode;

  /// Bumped by the host whenever the user interacts with the session screen
  /// (a tap or swipe). In [StealthTimerDisplay.small] mode each change
  /// restores the clock to full opacity and restarts the 10 s idle countdown
  /// (G-018). Ignored in the other modes. Null disables the restore-on-touch
  /// behaviour (the clock still fades after the initial 10 s).
  final Listenable? interactionSignal;

  @override
  State<SessionElapsedClock> createState() => _SessionElapsedClockState();
}

class _SessionElapsedClockState extends State<SessionElapsedClock> {
  /// Idle delay after which the small-mode clock dims to 50 % (G-018).
  static const Duration _idleBeforeFade = Duration(seconds: 10);

  /// Duration of the dim animation (G-018).
  static const Duration _fadeDuration = Duration(milliseconds: 400);

  /// Dimmed opacity the small-mode clock fades to when idle (G-018).
  static const double _dimmedOpacity = 0.5;

  /// Monospace font size for the small (corner) clock, matched to a media
  /// player's playback-time indicator (spec 04 §Timer Display Options).
  static const double _smallFontSize = 12;

  Timer? _idleTimer;
  bool _dimmed = false;

  @override
  void initState() {
    super.initState();
    widget.interactionSignal?.addListener(_onInteraction);
    if (widget.displayMode == StealthTimerDisplay.small) {
      _restartIdleTimer();
    }
  }

  @override
  void didUpdateWidget(SessionElapsedClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.interactionSignal != widget.interactionSignal) {
      oldWidget.interactionSignal?.removeListener(_onInteraction);
      widget.interactionSignal?.addListener(_onInteraction);
    }
    if (oldWidget.displayMode != widget.displayMode) {
      if (widget.displayMode == StealthTimerDisplay.small) {
        _dimmed = false;
        _restartIdleTimer();
      } else {
        _idleTimer?.cancel();
        _idleTimer = null;
        _dimmed = false;
      }
    }
  }

  @override
  void dispose() {
    widget.interactionSignal?.removeListener(_onInteraction);
    _idleTimer?.cancel();
    super.dispose();
  }

  void _onInteraction() {
    if (widget.displayMode != StealthTimerDisplay.small) return;
    if (_dimmed) {
      setState(() => _dimmed = false);
    }
    _restartIdleTimer();
  }

  void _restartIdleTimer() {
    _idleTimer?.cancel();
    _idleTimer = Timer(_idleBeforeFade, () {
      if (!mounted) return;
      setState(() => _dimmed = true);
    });
  }

  /// Formats [seconds] for [StealthTimerDisplay.normal]: `H:MM:SS` once the
  /// session reaches an hour, `M:SS` below it (non-padded leading field).
  static String _formatNormal(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    String two(int v) => v.toString().padLeft(2, '0');
    if (hours > 0) {
      return '$hours:${two(minutes)}:${two(secs)}';
    }
    return '$minutes:${two(secs)}';
  }

  /// Formats [seconds] for [StealthTimerDisplay.small]: `M:SS` while the
  /// session is at or below 99 min, falling back to `H:MM` beyond it so the
  /// corner clock stays compact (spec 04 §Timer Display Options, G-018).
  static String _formatSmall(int seconds) {
    final totalMinutes = seconds ~/ 60;
    String two(int v) => v.toString().padLeft(2, '0');
    if (totalMinutes > 99) {
      final hours = seconds ~/ 3600;
      final minutes = (seconds % 3600) ~/ 60;
      return '$hours:${two(minutes)}';
    }
    final secs = seconds % 60;
    return '$totalMinutes:${two(secs)}';
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.displayMode) {
      case StealthTimerDisplay.none:
        return const SizedBox.shrink();
      case StealthTimerDisplay.normal:
        final textTheme = Theme.of(context).textTheme;
        return Text(
          _formatNormal(widget.elapsedSeconds),
          style: textTheme.headlineSmall?.copyWith(
            fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
            fontFamilyFallback: const <String>['monospace'],
          ),
        );
      case StealthTimerDisplay.small:
        return AnimatedOpacity(
          duration: _fadeDuration,
          opacity: _dimmed ? _dimmedOpacity : 1.0,
          child: Text(
            _formatSmall(widget.elapsedSeconds),
            style: const TextStyle(
              fontSize: _smallFontSize,
              fontFamily: 'monospace',
              fontFamilyFallback: <String>['monospace'],
              fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
            ),
          ),
        );
    }
  }
}
