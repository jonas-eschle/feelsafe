/// Fake incoming-call overlay.
///
/// Renders an OS-style ringtone UI and presents Answer / Decline /
/// Hang-up controls wired to [FakeCallController]. Used as a safety
/// pretext during fakeCall escalation steps.
///
/// **CallStyle dispatch** (spec 03 §FakeCallConfig + spec 02 §5):
/// the screen renders a different lock-screen treatment per
/// [CallStyle]:
///
/// * `android` — Material 3 lockscreen: large round answer/decline
///   buttons, default Android styling.
/// * `ios` — iOS lockscreen with green/red horizontal slider.
/// * `whatsapp`, `telegram`, `signal` — themed colour palettes plus
///   the corresponding chat-app brand mark.
///
/// **Ringtone:** during the ring window the screen plays
/// `audioService.playRingtone(assetPath: cfg.ringtoneAsset)`. In a
/// simulation the ringtone fires unless `simulationSilent` is set
/// (per `AudioServiceProtocol` simulation matrix).
///
/// **Voice on answer:** the screen splits `cfg.voiceSource` ×
/// `cfg.voiceRoute`. When `voiceSource == VoiceSource.recording`
/// the path is played via the audio service; when
/// `voiceSource == VoiceSource.tts` the screen falls back to
/// `flutter_tts` for a synthesized line; `VoiceSource.none` keeps
/// silence after answer.
///
/// **Decline-with-distress:** holding the Decline button for
/// [FakeCallConfig.declineWithDistressHoldSeconds] (Q21: default
/// 5 s) silently fires the mode's distress chain (spec 01 §Fake
/// Call Lifecycle). A circular progress ring surrounds the button
/// while holding.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:go_router/go_router.dart';

import 'package:guardianangela/domain/models/step_config.dart';
import 'package:guardianangela/features/fake_call/fake_call_controller.dart';
import 'package:guardianangela/features/session/session_controller.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';
import 'package:guardianangela/services/service_providers.dart';

/// Fallback hold window when the active fakeCall step's
/// `FakeCallConfig` cannot be resolved (e.g. degraded distress-chain
/// path). Spec 01 §Fake Call Lifecycle: Q21 default is 5 s.
const Duration _fallbackDeclineHold = Duration(seconds: 5);

/// Offset at which the haptic feedback fires during the
/// decline-with-distress hold — confirms to the user that the
/// gesture is being detected. Spec 01 §Fake Call Lifecycle.
const Duration _declineDistressHaptic = Duration(milliseconds: 800);

/// Factory that builds a fresh [FlutterTts]. Tests inject a stub.
/// *Why:* `flutter_tts` requires the platform binding; widget tests
/// substitute a no-op fake.
typedef FakeCallTtsFactory = FlutterTts Function();

/// Provider for the TTS engine factory. Override in tests.
final fakeCallTtsFactoryProvider = Provider<FakeCallTtsFactory>(
  (_) => FlutterTts.new,
);

/// Simulated incoming-call overlay.
///
/// Two operating modes:
/// * **Live (default)** — wired to the active session via
///   [fakeCallControllerProvider]; answer/decline/distress dispatch
///   to the real session controller and the ringtone uses the audio
///   service appropriate for the session's `isSimulation` flag.
/// * **Preview** (`previewConfig != null`) — used by issue #13/#14
///   step-preview from the mode editor and by simulation runs that
///   want the real call UI without a real phone call. The screen
///   skips the controller, plays the ringtone via the simulation
///   audio service, and just pops on answer/decline/distress.
class FakeCallScreen extends ConsumerStatefulWidget {
  /// Creates the fake-call screen.
  ///
  /// [previewConfig] — when non-null, switches the screen to preview
  /// mode (issues-v4 #13/#14). The config is used directly instead
  /// of being resolved from the active session.
  const FakeCallScreen({super.key, this.previewConfig});

  /// Optional preview-mode config. Non-null forces preview mode.
  final FakeCallConfig? previewConfig;

  @override
  ConsumerState<FakeCallScreen> createState() => _FakeCallScreenState();
}

class _FakeCallScreenState extends ConsumerState<FakeCallScreen>
    with SingleTickerProviderStateMixin {
  bool _answered = false;
  bool _distressFired = false;

  /// True when the screen is hosted from the mode-editor preview
  /// (issues-v4 #13/#14). In preview mode the controller is not
  /// invoked and the screen plays the ringtone via the simulation
  /// audio service so it doesn't blast at full volume.
  bool get _isPreview => widget.previewConfig != null;

  /// Resolved hold duration for the current step. Hydrated from
  /// `cfg.declineWithDistressHoldSeconds` once the FakeCallConfig is
  /// resolved; until then we fall back to the spec default so the
  /// gesture is always available even if hydration is racy.
  Duration _declineHoldDuration = _fallbackDeclineHold;

  /// Resolved config for the active fakeCall step. Defaults until
  /// [_hydrateFromConfig] completes.
  FakeCallConfig _cfg = const FakeCallConfig();

  late final AnimationController _declineHold = AnimationController(
    vsync: this,
    duration: _declineHoldDuration,
  );
  Timer? _declineTimer;
  Timer? _hapticTimer;

  /// Lazily-initialised TTS instance, used when answering with
  /// [VoiceSource.tts]. Disposed in [dispose] to release platform
  /// resources.
  FlutterTts? _tts;

  @override
  void initState() {
    super.initState();
    // Hydrate the config + start the ringtone once the first frame
    // is drawn — the controller already has the session state at
    // that point.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_hydrateFromConfig());
    });
  }

  Future<void> _hydrateFromConfig() async {
    final FakeCallConfig cfg;
    if (_isPreview) {
      cfg = widget.previewConfig!;
    } else {
      final controller = ref.read(fakeCallControllerProvider.notifier);
      cfg = await controller.currentFakeCallConfig();
    }
    if (!mounted) return;
    final seconds = cfg.declineWithDistressHoldSeconds;
    final next = Duration(milliseconds: (seconds * 1000).round());
    setState(() {
      _cfg = cfg;
      if (next != _declineHoldDuration) {
        _declineHoldDuration = next;
        _declineHold.duration = next;
      }
    });
    await _startRingtone();
  }

  /// True when the active session (or preview) is in simulation
  /// mode. Preview mode is always simulation per issues-v4 #14.
  bool get _isSimulation =>
      _isPreview ||
      (ref.read(sessionControllerProvider).value?.isSimulation ?? false);

  /// Starts the ringtone via the appropriate (real / simulation)
  /// audio service. Failures are swallowed — UI must remain usable
  /// even when audio backends are missing in tests.
  ///
  /// Issue #14 — in simulation and preview the ringtone reuses
  /// `assets/audio/ringtone.wav` via the simulation audio service so
  /// it doesn't blast at full volume; in real mode the live audio
  /// service plays the asset normally.
  Future<void> _startRingtone() async {
    final isSim = _isSimulation;
    final audio = isSim
        ? ref.read(simulationAudioProvider)
        : ref.read(audioServiceProvider);
    try {
      await audio.playRingtone(
        assetPath: _cfg.ringtoneAsset,
        isSimulation: isSim,
      );
    } on Object {
      // Ringtone is best-effort: missing audio backend in tests, or
      // platform refusing the asset path, MUST NOT crash the UI.
    }
  }

  /// Stops the ringtone if it is still playing.
  Future<void> _stopRingtone() async {
    final isSim = _isSimulation;
    final audio = isSim
        ? ref.read(simulationAudioProvider)
        : ref.read(audioServiceProvider);
    try {
      await audio.stopRingtone();
    } on Object {
      // Best-effort.
    }
  }

  /// Plays the answer audio per `cfg.voiceSource`:
  /// * `recording` → `audioService.playVoiceRecording(cfg.voiceRecordingAsset)`
  /// * `tts` → `flutter_tts.speak(...)` with a localized line.
  /// * `none` → silent.
  ///
  /// `cfg.voiceRoute` (earpiece / speaker) is honoured at the
  /// platform layer of the audio service (AudioContext on Android,
  /// AVAudioSession on iOS).
  Future<void> _playAnswerAudio() async {
    final isSim = _isSimulation;
    final audio = isSim
        ? ref.read(simulationAudioProvider)
        : ref.read(audioServiceProvider);
    switch (_cfg.voiceSource) {
      case VoiceSource.recording:
        final path = _cfg.voiceRecordingAsset;
        if (path == null || path.isEmpty) {
          await _speakTtsFallback();
          return;
        }
        try {
          await audio.playVoiceRecording(assetPath: path, isSimulation: isSim);
        } on Object {
          await _speakTtsFallback();
        }
      case VoiceSource.tts:
        await _speakTtsFallback();
      case VoiceSource.none:
        // Silent — the user pretends to talk.
        return;
    }
  }

  Future<void> _speakTtsFallback() async {
    try {
      final tts = _tts ??= ref.read(fakeCallTtsFactoryProvider)();
      // The phrase is intentionally generic so it works for any
      // localised "Angela" default — full TTS i18n lives in spec
      // 02 §fakeCall and is wired in via flutter_tts language codes.
      await tts.speak('Hi, I am running late. I will call you back soon.');
    } on Object {
      // TTS may be unavailable in tests / on iOS simulator — best-
      // effort.
    }
  }

  @override
  void dispose() {
    _declineTimer?.cancel();
    _hapticTimer?.cancel();
    _declineHold.dispose();
    // Note: we do NOT call _stopRingtone here because it touches
    // Riverpod via `ref`, which is unsafe in `dispose()`. Callers
    // (decline / answer / hangUp) are responsible for stopping the
    // ringtone before navigating away. TTS owns its own lifecycle so
    // it's safe to stop without `ref`.
    unawaited(_tts?.stop());
    super.dispose();
  }

  void _onDeclineHoldStart() {
    if (_distressFired) return;
    _declineHold.forward(from: 0);
    _declineTimer?.cancel();
    _hapticTimer?.cancel();
    _declineTimer = Timer(_declineHoldDuration, _onDeclineDistressFire);
    // Haptic at 800ms confirms the gesture is being detected before
    // the full hold completes. Spec 01 §Fake Call Lifecycle.
    _hapticTimer = Timer(_declineDistressHaptic, HapticFeedback.mediumImpact);
  }

  void _onDeclineHoldEnd() {
    _declineTimer?.cancel();
    _declineTimer = null;
    _hapticTimer?.cancel();
    _hapticTimer = null;
    _declineHold.reverse();
  }

  Future<void> _onDeclineDistressFire() async {
    if (_distressFired) return;
    _distressFired = true;
    await _stopRingtone();
    if (!_isPreview) {
      final controller = ref.read(fakeCallControllerProvider.notifier);
      await controller.declineWithDistress();
    }
    if (mounted) context.pop();
  }

  Future<void> _onDeclineTap() async {
    if (_distressFired) return;
    await _stopRingtone();
    if (!_isPreview) {
      final controller = ref.read(fakeCallControllerProvider.notifier);
      await controller.decline();
    }
    if (mounted) context.pop();
  }

  Future<void> _onAnswerTap() async {
    await _stopRingtone();
    if (!_isPreview) {
      final controller = ref.read(fakeCallControllerProvider.notifier);
      await controller.answer();
    }
    if (!mounted) return;
    setState(() => _answered = true);
    await _playAnswerAudio();
  }

  Future<void> _onHangUpTap() async {
    try {
      await ref.read(audioServiceProvider).stopVoiceRecording();
    } on Object {
      // Best-effort.
    }
    await _tts?.stop();
    if (!_isPreview) {
      final controller = ref.read(fakeCallControllerProvider.notifier);
      await controller.hangUp();
    }
    if (mounted && context.mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final callerName = (_cfg.callerName?.trim().isNotEmpty ?? false)
        ? _cfg.callerName!
        : l.fakeCallUnknownCaller;
    final photoPath = _cfg.callerPhotoPath;
    return Scaffold(
      backgroundColor: _backgroundColor(_cfg.callStyle),
      body: SafeArea(
        child: _StyleDispatch(
          style: _cfg.callStyle,
          callerName: callerName,
          callerPhotoPath: photoPath,
          answered: _answered,
          declineHoldProgress: _declineHold,
          onAnswer: _onAnswerTap,
          onDeclineTap: _onDeclineTap,
          onDeclineHoldStart: _onDeclineHoldStart,
          onDeclineHoldEnd: _onDeclineHoldEnd,
          onHangUp: _onHangUpTap,
          incomingLabel: _incomingLabel(l, _cfg.callStyle),
          answerLabel: l.fakeCallAnswer,
          declineLabel: l.fakeCallDecline,
          hangUpLabel: l.fakeCallHangUp,
          slideToAnswerLabel: l.fakeCallSlideToAnswer,
          brandBadge: _brandBadge(_cfg.callStyle, l),
        ),
      ),
    );
  }

  Color _backgroundColor(CallStyle style) => switch (style) {
    CallStyle.android => Colors.black,
    CallStyle.ios => const Color(0xFF1C1C1E),
    CallStyle.whatsapp => const Color(0xFF075E54),
    CallStyle.telegram => const Color(0xFF1C2A3A),
    CallStyle.signal => const Color(0xFF1B1B1B),
  };

  String _incomingLabel(AppLocalizations l, CallStyle style) => switch (style) {
    CallStyle.whatsapp => l.fakeCallIncomingWhatsapp,
    CallStyle.telegram => l.fakeCallIncomingTelegram,
    CallStyle.signal => l.fakeCallIncomingSignal,
    CallStyle.android => l.fakeCallTitle,
    CallStyle.ios => l.fakeCallTitle,
  };

  String? _brandBadge(CallStyle style, AppLocalizations l) => switch (style) {
    CallStyle.whatsapp => l.fakeCallBrandWhatsapp,
    CallStyle.telegram => l.fakeCallBrandTelegram,
    CallStyle.signal => l.fakeCallBrandSignal,
    CallStyle.android => null,
    CallStyle.ios => null,
  };
}

/// Dispatches to the appropriate per-style layout. Each style is a
/// private widget class (Effective Dart: prefer composition over
/// helper methods returning Widget).
class _StyleDispatch extends StatelessWidget {
  const _StyleDispatch({
    required this.style,
    required this.callerName,
    required this.callerPhotoPath,
    required this.answered,
    required this.declineHoldProgress,
    required this.onAnswer,
    required this.onDeclineTap,
    required this.onDeclineHoldStart,
    required this.onDeclineHoldEnd,
    required this.onHangUp,
    required this.incomingLabel,
    required this.answerLabel,
    required this.declineLabel,
    required this.hangUpLabel,
    required this.slideToAnswerLabel,
    required this.brandBadge,
  });

  final CallStyle style;
  final String callerName;
  final String? callerPhotoPath;
  final bool answered;
  final Animation<double> declineHoldProgress;
  final VoidCallback onAnswer;
  final VoidCallback onDeclineTap;
  final VoidCallback onDeclineHoldStart;
  final VoidCallback onDeclineHoldEnd;
  final VoidCallback onHangUp;
  final String incomingLabel;
  final String answerLabel;
  final String declineLabel;
  final String hangUpLabel;
  final String slideToAnswerLabel;
  final String? brandBadge;

  @override
  Widget build(BuildContext context) {
    if (style == CallStyle.ios) {
      return _IosLayout(
        callerName: callerName,
        callerPhotoPath: callerPhotoPath,
        answered: answered,
        declineHoldProgress: declineHoldProgress,
        onAnswer: onAnswer,
        onDeclineTap: onDeclineTap,
        onDeclineHoldStart: onDeclineHoldStart,
        onDeclineHoldEnd: onDeclineHoldEnd,
        onHangUp: onHangUp,
        incomingLabel: incomingLabel,
        slideToAnswerLabel: slideToAnswerLabel,
        declineLabel: declineLabel,
        hangUpLabel: hangUpLabel,
      );
    }
    return _MaterialLayout(
      style: style,
      callerName: callerName,
      callerPhotoPath: callerPhotoPath,
      answered: answered,
      declineHoldProgress: declineHoldProgress,
      onAnswer: onAnswer,
      onDeclineTap: onDeclineTap,
      onDeclineHoldStart: onDeclineHoldStart,
      onDeclineHoldEnd: onDeclineHoldEnd,
      onHangUp: onHangUp,
      incomingLabel: incomingLabel,
      answerLabel: answerLabel,
      declineLabel: declineLabel,
      hangUpLabel: hangUpLabel,
      brandBadge: brandBadge,
    );
  }
}

/// Material 3 lockscreen layout — used by Android, WhatsApp,
/// Telegram, and Signal styles. The accent colour comes from
/// [_styleAccent]; chat brands also render the brand badge.
class _MaterialLayout extends StatelessWidget {
  const _MaterialLayout({
    required this.style,
    required this.callerName,
    required this.callerPhotoPath,
    required this.answered,
    required this.declineHoldProgress,
    required this.onAnswer,
    required this.onDeclineTap,
    required this.onDeclineHoldStart,
    required this.onDeclineHoldEnd,
    required this.onHangUp,
    required this.incomingLabel,
    required this.answerLabel,
    required this.declineLabel,
    required this.hangUpLabel,
    required this.brandBadge,
  });

  final CallStyle style;
  final String callerName;
  final String? callerPhotoPath;
  final bool answered;
  final Animation<double> declineHoldProgress;
  final VoidCallback onAnswer;
  final VoidCallback onDeclineTap;
  final VoidCallback onDeclineHoldStart;
  final VoidCallback onDeclineHoldEnd;
  final VoidCallback onHangUp;
  final String incomingLabel;
  final String answerLabel;
  final String declineLabel;
  final String hangUpLabel;
  final String? brandBadge;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      const SizedBox(height: 40),
      if (brandBadge != null)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            brandBadge!,
            style: TextStyle(
              color: _styleAccent(style),
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
            ),
          ),
        ),
      Text(
        incomingLabel,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 14,
          letterSpacing: 1.2,
        ),
      ),
      const SizedBox(height: 24),
      _CallerAvatar(photoPath: callerPhotoPath, accent: _styleAccent(style)),
      const SizedBox(height: 16),
      Text(
        callerName,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.w500,
        ),
      ),
      const Spacer(),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (!answered) ...[
              _DeclineWithDistressButton(
                label: declineLabel,
                progress: declineHoldProgress,
                onTap: onDeclineTap,
                onHoldStart: onDeclineHoldStart,
                onHoldEnd: onDeclineHoldEnd,
              ),
              _CallButton(
                icon: Icons.call,
                color: Colors.green,
                label: answerLabel,
                onTap: onAnswer,
              ),
            ] else
              _CallButton(
                icon: Icons.call_end,
                color: Colors.red,
                label: hangUpLabel,
                onTap: onHangUp,
              ),
          ],
        ),
      ),
    ],
  );
}

/// iOS lockscreen layout — green/red horizontal slider replaces the
/// round buttons before the call is answered.
class _IosLayout extends StatelessWidget {
  const _IosLayout({
    required this.callerName,
    required this.callerPhotoPath,
    required this.answered,
    required this.declineHoldProgress,
    required this.onAnswer,
    required this.onDeclineTap,
    required this.onDeclineHoldStart,
    required this.onDeclineHoldEnd,
    required this.onHangUp,
    required this.incomingLabel,
    required this.slideToAnswerLabel,
    required this.declineLabel,
    required this.hangUpLabel,
  });

  final String callerName;
  final String? callerPhotoPath;
  final bool answered;
  final Animation<double> declineHoldProgress;
  final VoidCallback onAnswer;
  final VoidCallback onDeclineTap;
  final VoidCallback onDeclineHoldStart;
  final VoidCallback onDeclineHoldEnd;
  final VoidCallback onHangUp;
  final String incomingLabel;
  final String slideToAnswerLabel;
  final String declineLabel;
  final String hangUpLabel;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      const SizedBox(height: 60),
      Text(
        incomingLabel,
        style: const TextStyle(color: Colors.white70, fontSize: 14),
      ),
      const SizedBox(height: 40),
      _CallerAvatar(
        photoPath: callerPhotoPath,
        accent: const Color(0xFF34C759),
      ),
      const SizedBox(height: 16),
      Text(
        callerName,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.w300,
        ),
      ),
      const Spacer(),
      if (!answered)
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 60),
          child: _IosSlider(
            label: slideToAnswerLabel,
            // Long-press distress lives on the decline gesture per
            // spec; we expose Decline as a separate button above the
            // slide for parity with the other styles.
            onAnswer: onAnswer,
            declineLabel: declineLabel,
            declineHoldProgress: declineHoldProgress,
            onDeclineTap: onDeclineTap,
            onDeclineHoldStart: onDeclineHoldStart,
            onDeclineHoldEnd: onDeclineHoldEnd,
          ),
        )
      else
        Padding(
          padding: const EdgeInsets.only(bottom: 60),
          child: _CallButton(
            icon: Icons.call_end,
            color: Colors.red,
            label: hangUpLabel,
            onTap: onHangUp,
          ),
        ),
    ],
  );
}

/// iOS-style slide-to-answer track. Dragging the green knob to the
/// right end calls [onAnswer]. The Decline button sits above the
/// slider so the press-and-hold-distress gesture remains available.
class _IosSlider extends StatefulWidget {
  const _IosSlider({
    required this.label,
    required this.onAnswer,
    required this.declineLabel,
    required this.declineHoldProgress,
    required this.onDeclineTap,
    required this.onDeclineHoldStart,
    required this.onDeclineHoldEnd,
  });

  final String label;
  final VoidCallback onAnswer;
  final String declineLabel;
  final Animation<double> declineHoldProgress;
  final VoidCallback onDeclineTap;
  final VoidCallback onDeclineHoldStart;
  final VoidCallback onDeclineHoldEnd;

  @override
  State<_IosSlider> createState() => _IosSliderState();
}

class _IosSliderState extends State<_IosSlider> {
  double _drag = 0;
  static const double _trackHeight = 64;
  static const double _knob = 56;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: _DeclineWithDistressButton(
          label: widget.declineLabel,
          progress: widget.declineHoldProgress,
          onTap: widget.onDeclineTap,
          onHoldStart: widget.onDeclineHoldStart,
          onHoldEnd: widget.onDeclineHoldEnd,
        ),
      ),
      LayoutBuilder(
        builder: (context, constraints) {
          final maxDrag = constraints.maxWidth - _knob;
          return GestureDetector(
            onHorizontalDragUpdate: (d) {
              setState(() {
                _drag = (_drag + d.delta.dx).clamp(0, maxDrag);
              });
            },
            onHorizontalDragEnd: (_) {
              if (_drag >= maxDrag * 0.9) {
                widget.onAnswer();
              } else {
                setState(() => _drag = 0);
              }
            },
            child: Container(
              height: _trackHeight,
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(_trackHeight / 2),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    widget.label,
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  Positioned(
                    left: _drag,
                    top: (_trackHeight - _knob) / 2,
                    child: Container(
                      width: _knob,
                      height: _knob,
                      decoration: const BoxDecoration(
                        color: Color(0xFF34C759),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.call,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ],
  );
}

/// Round photo (or fallback initials) avatar.
class _CallerAvatar extends StatelessWidget {
  const _CallerAvatar({required this.photoPath, required this.accent});

  final String? photoPath;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final p = photoPath;
    if (p != null && p.isNotEmpty) {
      return CircleAvatar(
        radius: 64,
        backgroundColor: accent.withValues(alpha: 0.2),
        backgroundImage: AssetImage(p),
      );
    }
    return CircleAvatar(
      radius: 64,
      backgroundColor: accent.withValues(alpha: 0.2),
      child: Icon(Icons.person, color: accent, size: 56),
    );
  }
}

/// Per-style accent colour. Used for buttons + brand badges.
Color _styleAccent(CallStyle style) => switch (style) {
  CallStyle.whatsapp => const Color(0xFF25D366),
  CallStyle.telegram => const Color(0xFF2AABEE),
  CallStyle.signal => const Color(0xFF3A76F0),
  CallStyle.android => Colors.green,
  CallStyle.ios => const Color(0xFF34C759),
};

class _CallButton extends StatelessWidget {
  const _CallButton({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: Icon(icon, color: Colors.white, size: 32),
        ),
      ),
      const SizedBox(height: 8),
      Text(label, style: const TextStyle(color: Colors.white)),
    ],
  );
}

/// Decline button that fires the distress chain after a press-and-
/// hold gesture whose duration is read from
/// [FakeCallConfig.declineWithDistressHoldSeconds] (Q21). A short
/// tap performs the normal decline.
class _DeclineWithDistressButton extends StatelessWidget {
  const _DeclineWithDistressButton({
    required this.label,
    required this.progress,
    required this.onTap,
    required this.onHoldStart,
    required this.onHoldEnd,
  });

  final String label;
  final Animation<double> progress;
  final VoidCallback onTap;
  final VoidCallback onHoldStart;
  final VoidCallback onHoldEnd;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      GestureDetector(
        onTap: onTap,
        onLongPressStart: (_) => onHoldStart(),
        onLongPressEnd: (_) => onHoldEnd(),
        onLongPressCancel: onHoldEnd,
        child: SizedBox(
          width: 80,
          height: 80,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.call_end,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              IgnorePointer(
                child: AnimatedBuilder(
                  animation: progress,
                  builder: (context, _) => SizedBox(
                    width: 80,
                    height: 80,
                    child: CircularProgressIndicator(
                      value: progress.value,
                      strokeWidth: 4,
                      backgroundColor: Colors.transparent,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.yellow,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 8),
      Text(label, style: const TextStyle(color: Colors.white)),
    ],
  );
}
