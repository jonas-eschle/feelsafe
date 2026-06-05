import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:guardianangela/domain/configs/step_config.dart';
import 'package:guardianangela/domain/enums/call_style.dart';
import 'package:guardianangela/domain/enums/voice_output_mode.dart';
import 'package:guardianangela/features/fake_call/fake_call_controller.dart';
import 'package:guardianangela/features/session/session_controller.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// Full-screen fake-call UI.
///
/// Renders one of 5 visual call styles (Android-native, iOS-native,
/// WhatsApp, Telegram, Signal) and exposes the slide-to-answer +
/// hold-for-distress gestures specified in spec 04 §Fake Call Screen
/// (lines 1044–1159). Disables back navigation (PopScope) and locks
/// orientation to portrait.
class FakeCallScreen extends ConsumerStatefulWidget {
  /// Creates a [FakeCallScreen].
  ///
  /// [config] drives every visible aspect (caller name, call style,
  /// decline-safe flag, voice prompt name, ring duration). Defaults to
  /// `FakeCallConfig()` so the route handler can instantiate without a
  /// config when the chain step has none.
  const FakeCallScreen({super.key, this.config = const FakeCallConfig()});

  /// Per-step configuration loaded from the chain step (or defaults).
  final FakeCallConfig config;

  @override
  ConsumerState<FakeCallScreen> createState() => _FakeCallScreenState();
}

class _FakeCallScreenState extends ConsumerState<FakeCallScreen> {
  late final FakeCallController _controller;
  Timer? _activeTicker;
  DateTime? _holdStart;
  Timer? _holdTicker;

  /// Guards [_onSlideUpdate] so the voice clip is requested exactly once when
  /// the call is answered.
  bool _answered = false;

  @override
  void initState() {
    super.initState();
    _controller = FakeCallController(widget.config);
    SystemChrome.setPreferredOrientations(<DeviceOrientation>[
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  void dispose() {
    _activeTicker?.cancel();
    _holdTicker?.cancel();
    _controller.dispose();
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  void _startActiveTicker() {
    _activeTicker?.cancel();
    final started = DateTime.now();
    _activeTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      _controller.tickActive(DateTime.now().difference(started));
    });
  }

  void _startHold() {
    _holdStart = DateTime.now();
    _holdTicker?.cancel();
    _holdTicker = Timer.periodic(const Duration(milliseconds: 80), (_) {
      final started = _holdStart;
      if (started == null || !mounted) return;
      final holdSeconds = widget.config.declineWithDistressHoldSeconds;
      final elapsed = DateTime.now().difference(started).inMilliseconds / 1000;
      final progress = (elapsed / holdSeconds).clamp(0.0, 1.0);
      _controller.updateHold(progress);
      // Spec 04:1130 — haptic at 800ms into hold.
      if (elapsed >= 0.8 && elapsed < 0.88) {
        HapticFeedback.mediumImpact();
      }
      if (progress >= 1.0) {
        _holdTicker?.cancel();
        _holdStart = null;
        ref.read(sessionControllerProvider.notifier).confirmDistress();
        if (mounted) context.pop();
      }
    });
  }

  void _cancelHold() {
    _holdTicker?.cancel();
    _holdStart = null;
    _controller.releaseHold();
  }

  void _onSlideUpdate(double value) {
    _controller.updateSlide(value);
    if (_controller.value.phase == FakeCallPhase.active && !_answered) {
      _answered = true;
      _startActiveTicker();
      // Answer: stop the ringtone and play the voice clip. The engine timer
      // keeps running (Pivot 2). See spec 02 §fakeCall Voice Recording.
      final useSpeaker =
          widget.config.voiceOutputMode == VoiceOutputMode.speaker;
      unawaited(
        ref
            .read(sessionControllerProvider.notifier)
            .answerFakeCall(
              voiceRecordingPath: widget.config.voiceRecordingPath,
              useSpeaker: useSpeaker,
            ),
      );
    }
  }

  void _onSlideRelease() => _controller.releaseSlide();

  void _hangUp() {
    _activeTicker?.cancel();
    // Hang-up after answering disarms (reset to step 0); engine keeps running
    // until then (Pivot 2). See spec 02 §fakeCall Answer / Hang-up Semantics.
    ref.read(sessionControllerProvider.notifier).hangUpFakeCall();
    context.pop();
  }

  void _decline() {
    _activeTicker?.cancel();
    _holdTicker?.cancel();
    // Decline: disarm when declineIsSafe (default), otherwise count a miss and
    // re-ring (spec 02 §fakeCall Decline).
    ref
        .read(sessionControllerProvider.notifier)
        .declineFakeCall(declineIsSafe: widget.config.declineIsSafe);
    context.pop();
  }

  CallStyle _resolvedStyle() {
    final raw = widget.config.callStyle;
    if (raw != CallStyle.platformNative) return raw;
    if (Platform.isIOS) return CallStyle.iosNative;
    return CallStyle.androidNative;
  }

  @override
  Widget build(BuildContext context) {
    final style = _resolvedStyle();
    return PopScope(
      canPop: false,
      child: ValueListenableBuilder<FakeCallState>(
        valueListenable: _controller,
        builder: (BuildContext ctx, FakeCallState state, _) {
          return Scaffold(
            backgroundColor: _backgroundFor(style),
            body: SafeArea(
              child: state.phase == FakeCallPhase.incoming
                  ? _IncomingLayout(
                      config: widget.config,
                      style: style,
                      state: state,
                      onSlideUpdate: _onSlideUpdate,
                      onSlideRelease: _onSlideRelease,
                      onDecline: _decline,
                      onHoldStart: _startHold,
                      onHoldCancel: _cancelHold,
                    )
                  : _ActiveLayout(
                      config: widget.config,
                      style: style,
                      state: state,
                      onHangUp: _hangUp,
                    ),
            ),
          );
        },
      ),
    );
  }

  static Color _backgroundFor(CallStyle style) => switch (style) {
    CallStyle.platformNative ||
    CallStyle.androidNative => const Color(0xFF111111),
    CallStyle.iosNative => const Color(0xFF1C1C1E),
    CallStyle.minimal => Colors.black,
    CallStyle.whatsapp => const Color(0xFF075E54),
    CallStyle.telegram => const Color(0xFF0E76A8),
    CallStyle.signal => const Color(0xFF2C6BED),
  };
}

class _IncomingLayout extends StatelessWidget {
  const _IncomingLayout({
    required this.config,
    required this.style,
    required this.state,
    required this.onSlideUpdate,
    required this.onSlideRelease,
    required this.onDecline,
    required this.onHoldStart,
    required this.onHoldCancel,
  });

  final FakeCallConfig config;
  final CallStyle style;
  final FakeCallState state;
  final ValueChanged<double> onSlideUpdate;
  final VoidCallback onSlideRelease;
  final VoidCallback onDecline;
  final VoidCallback onHoldStart;
  final VoidCallback onHoldCancel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final declineLabel = config.declineIsSafe
        ? l10n.fakeCallDeclineSafeLabel
        : l10n.fakeCallDeclineUnsafeLabel;
    final callerName = config.callerName.isEmpty
        ? l10n.fakeCallUnknownCaller
        : config.callerName;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: <Widget>[
          _BrandHeader(style: style),
          const SizedBox(height: 16),
          Text(
            _styleHeader(style, l10n),
            style: textTheme.titleMedium?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 24),
          CircleAvatar(
            radius: 48,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: const Icon(Icons.person, size: 48, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            callerName,
            style: textTheme.headlineMedium?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 12),
          _Indicators(config: config),
          const Spacer(),
          _SlideToAnswerTrack(
            style: style,
            progress: state.slideProgress,
            onUpdate: onSlideUpdate,
            onRelease: onSlideRelease,
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onLongPressStart: (_) => onHoldStart(),
            onLongPressEnd: (_) => onHoldCancel(),
            onLongPressCancel: onHoldCancel,
            child: FilledButton.icon(
              icon: const Icon(Icons.call_end),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size.fromHeight(56),
              ),
              onPressed: onDecline,
              label: Text(declineLabel),
            ),
          ),
          const SizedBox(height: 8),
          if (state.holdProgress > 0)
            LinearProgressIndicator(
              value: state.holdProgress,
              backgroundColor: Colors.white24,
              color: Colors.redAccent,
            ),
          const SizedBox(height: 8),
          Text(
            l10n.fakeCallHoldForDistress,
            style: textTheme.bodySmall?.copyWith(color: Colors.white60),
          ),
        ],
      ),
    );
  }

  String _styleHeader(CallStyle style, AppLocalizations l10n) {
    return switch (style) {
      CallStyle.platformNative ||
      CallStyle.androidNative ||
      CallStyle.iosNative ||
      CallStyle.minimal => l10n.fakeCallTitle,
      CallStyle.whatsapp => l10n.fakeCallIncomingWhatsapp,
      CallStyle.telegram => l10n.fakeCallIncomingTelegram,
      CallStyle.signal => l10n.fakeCallIncomingSignal,
    };
  }
}

class _ActiveLayout extends StatelessWidget {
  const _ActiveLayout({
    required this.config,
    required this.style,
    required this.state,
    required this.onHangUp,
  });

  final FakeCallConfig config;
  final CallStyle style;
  final FakeCallState state;
  final VoidCallback onHangUp;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final callerName = config.callerName.isEmpty
        ? l10n.fakeCallUnknownCaller
        : config.callerName;
    final mm = state.activeElapsed.inMinutes
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    final ss = state.activeElapsed.inSeconds
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: <Widget>[
          _BrandHeader(style: style),
          const SizedBox(height: 24),
          Text(
            callerName,
            style: textTheme.headlineMedium?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.fakeCallActiveDuration(mm, ss),
            style: textTheme.titleMedium?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 24),
          CircleAvatar(
            radius: 48,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: const Icon(Icons.person, size: 48, color: Colors.white),
          ),
          const SizedBox(height: 16),
          _Indicators(config: config),
          const Spacer(),
          FilledButton.icon(
            icon: const Icon(Icons.call_end),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              minimumSize: const Size.fromHeight(56),
            ),
            onPressed: onHangUp,
            label: Text(l10n.fakeCallHangUp),
          ),
        ],
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader({required this.style});

  final CallStyle style;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final label = switch (style) {
      CallStyle.platformNative ||
      CallStyle.androidNative => l10n.fakeCallBrandAndroid,
      CallStyle.iosNative => l10n.fakeCallBrandIos,
      CallStyle.minimal => l10n.fakeCallBrandMinimal,
      CallStyle.whatsapp => l10n.fakeCallBrandWhatsapp,
      CallStyle.telegram => l10n.fakeCallBrandTelegram,
      CallStyle.signal => l10n.fakeCallBrandSignal,
    };
    return Text(
      label,
      style: Theme.of(
        context,
      ).textTheme.labelLarge?.copyWith(color: Colors.white70, letterSpacing: 2),
    );
  }
}

class _Indicators extends StatelessWidget {
  const _Indicators({required this.config});

  final FakeCallConfig config;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final voicePromptName = config.voiceRecordingPath;
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      alignment: WrapAlignment.center,
      children: <Widget>[
        if (voicePromptName != null && voicePromptName.isNotEmpty)
          Chip(
            backgroundColor: Colors.white12,
            label: Text(
              l10n.fakeCallVoicePrompt(voicePromptName),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        Chip(
          backgroundColor: Colors.white12,
          label: Text(
            l10n.fakeCallVibrationLabel(l10n.fakeCallVibrationPatternDefault),
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class _SlideToAnswerTrack extends StatefulWidget {
  const _SlideToAnswerTrack({
    required this.style,
    required this.progress,
    required this.onUpdate,
    required this.onRelease,
  });

  final CallStyle style;
  final double progress;
  final ValueChanged<double> onUpdate;
  final VoidCallback onRelease;

  @override
  State<_SlideToAnswerTrack> createState() => _SlideToAnswerTrackState();
}

class _SlideToAnswerTrackState extends State<_SlideToAnswerTrack> {
  double _trackWidth = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final accent = _accentFor(widget.style);
    return Column(
      children: <Widget>[
        Text(
          l10n.fakeCallSlideToAnswerHint,
          style: const TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (BuildContext ctx, BoxConstraints c) {
            _trackWidth = c.maxWidth;
            final range = (_trackWidth - 56).clamp(1.0, double.infinity);
            final knobX = (widget.progress * range).clamp(0.0, range);
            return Stack(
              children: <Widget>[
                Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    l10n.fakeCallSlideToAnswer,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
                Positioned(
                  left: knobX,
                  child: GestureDetector(
                    onHorizontalDragUpdate: (DragUpdateDetails details) {
                      final newX = knobX + details.delta.dx;
                      final clamped = newX.clamp(0.0, range);
                      widget.onUpdate(clamped / range);
                    },
                    onHorizontalDragEnd: (_) => widget.onRelease(),
                    onHorizontalDragCancel: widget.onRelease,
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: accent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.call, color: Colors.white),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Color _accentFor(CallStyle style) => switch (style) {
    CallStyle.platformNative ||
    CallStyle.androidNative ||
    CallStyle.minimal => Colors.green,
    CallStyle.iosNative => Colors.lightGreenAccent.shade400,
    CallStyle.whatsapp => const Color(0xFF25D366),
    CallStyle.telegram => const Color(0xFF2AABEE),
    CallStyle.signal => const Color(0xFF7B8AFF),
  };
}
