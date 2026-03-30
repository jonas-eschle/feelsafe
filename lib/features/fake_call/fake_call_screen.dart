import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:safewayhome/l10n/app_localizations.dart';

import '../../data/models/fake_call_config.dart';
import '../../services/service_providers.dart';
import '../session/session_controller.dart';
import 'fake_call_controller.dart';

class FakeCallScreen extends ConsumerStatefulWidget {
  const FakeCallScreen({super.key});

  @override
  ConsumerState<FakeCallScreen> createState() => _FakeCallScreenState();
}

class _FakeCallScreenState extends ConsumerState<FakeCallScreen>
    with SingleTickerProviderStateMixin {
  bool _answered = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _startRinging();
  }

  Future<void> _startRinging() async {
    final audio = ref.read(audioServiceProvider);
    await audio.playRingtone();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _answer() async {
    final audio = ref.read(audioServiceProvider);
    await audio.stop();

    // Check in the session — user is safe
    ref.read(sessionControllerProvider.notifier).checkIn();

    setState(() => _answered = true);

    // Optionally play voice recording
    final config = await ref.read(fakeCallConfigProvider.future);
    if (config.voiceRecordingPath != null) {
      await audio.playVoiceRecording(config.voiceRecordingPath!);
    }
  }

  Future<void> _decline() async {
    final audio = ref.read(audioServiceProvider);
    await audio.stop();
    if (mounted) context.pop();
  }

  Future<void> _hangUp() async {
    final audio = ref.read(audioServiceProvider);
    await audio.stop();
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final configAsync = ref.watch(fakeCallConfigProvider);
    final l10n = AppLocalizations.of(context);

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: configAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Text('$e', style: const TextStyle(color: Colors.white)),
          ),
          data: (config) => _answered
              ? _ActiveCallBody(
                  config: config,
                  l10n: l10n,
                  onHangUp: _hangUp,
                )
              : _IncomingCallBody(
                  config: config,
                  l10n: l10n,
                  pulseController: _pulseController,
                  onAnswer: _answer,
                  onDecline: _decline,
                ),
        ),
      ),
    );
  }
}

class _IncomingCallBody extends StatelessWidget {
  final FakeCallConfig config;
  final AppLocalizations l10n;
  final AnimationController pulseController;
  final VoidCallback onAnswer;
  final VoidCallback onDecline;

  const _IncomingCallBody({
    required this.config,
    required this.l10n,
    required this.pulseController,
    required this.onAnswer,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const Spacer(flex: 2),
          // Caller avatar
          _CallerAvatar(
            photoPath: config.photoPath,
            callerName: config.callerName,
            pulseController: pulseController,
          ),
          const SizedBox(height: 24),
          // Caller name
          Text(
            config.callerName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.fakeCallIncoming,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 16,
            ),
          ),
          const Spacer(flex: 3),
          // Slide to answer + decline
          _SlideToAnswer(
            l10n: l10n,
            onAnswer: onAnswer,
          ),
          const SizedBox(height: 24),
          // Decline button
          GestureDetector(
            onTap: onDecline,
            child: Container(
              width: 64,
              height: 64,
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
          ),
          const SizedBox(height: 16),
          Text(
            l10n.fakeCallDecline,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}

class _ActiveCallBody extends StatelessWidget {
  final FakeCallConfig config;
  final AppLocalizations l10n;
  final VoidCallback onHangUp;

  const _ActiveCallBody({
    required this.config,
    required this.l10n,
    required this.onHangUp,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const Spacer(flex: 2),
          _CallerAvatar(
            photoPath: config.photoPath,
            callerName: config.callerName,
          ),
          const SizedBox(height: 24),
          Text(
            config.callerName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.fakeCallActive,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 16,
            ),
          ),
          const Spacer(flex: 3),
          // Hang up button
          GestureDetector(
            onTap: onHangUp,
            child: Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.call_end,
                color: Colors.white,
                size: 36,
              ),
            ),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}

class _CallerAvatar extends StatelessWidget {
  final String? photoPath;
  final String callerName;
  final AnimationController? pulseController;

  const _CallerAvatar({
    required this.photoPath,
    required this.callerName,
    this.pulseController,
  });

  @override
  Widget build(BuildContext context) {
    Widget avatar;
    if (photoPath != null && File(photoPath!).existsSync()) {
      avatar = CircleAvatar(
        radius: 60,
        backgroundImage: FileImage(File(photoPath!)),
      );
    } else {
      avatar = CircleAvatar(
        radius: 60,
        backgroundColor: Colors.grey.shade800,
        child: Text(
          callerName.isNotEmpty ? callerName[0].toUpperCase() : '?',
          style: const TextStyle(fontSize: 48, color: Colors.white),
        ),
      );
    }

    if (pulseController != null) {
      return AnimatedBuilder(
        animation: pulseController!,
        builder: (context, child) {
          final scale = 1.0 + pulseController!.value * 0.08;
          return Transform.scale(scale: scale, child: child);
        },
        child: avatar,
      );
    }

    return avatar;
  }
}

/// A slide-to-answer widget that mimics the phone's answer gesture.
class _SlideToAnswer extends StatefulWidget {
  final AppLocalizations l10n;
  final VoidCallback onAnswer;

  const _SlideToAnswer({
    required this.l10n,
    required this.onAnswer,
  });

  @override
  State<_SlideToAnswer> createState() => _SlideToAnswerState();
}

class _SlideToAnswerState extends State<_SlideToAnswer> {
  double _dragExtent = 0;
  static const _trackWidth = 280.0;
  static const _thumbSize = 64.0;
  static const _maxDrag = _trackWidth - _thumbSize;
  static const _threshold = 0.85;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _trackWidth,
      height: _thumbSize,
      child: Stack(
        children: [
          // Track background
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(_thumbSize / 2),
              color: Colors.white.withValues(alpha: 0.15),
            ),
            alignment: Alignment.center,
            child: Text(
              widget.l10n.slideToAnswer,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 16,
              ),
            ),
          ),
          // Draggable thumb
          Positioned(
            left: _dragExtent,
            child: GestureDetector(
              onHorizontalDragUpdate: (details) {
                setState(() {
                  _dragExtent =
                      (_dragExtent + details.delta.dx).clamp(0, _maxDrag);
                });
              },
              onHorizontalDragEnd: (_) {
                if (_dragExtent / _maxDrag >= _threshold) {
                  widget.onAnswer();
                } else {
                  setState(() => _dragExtent = 0);
                }
              },
              child: Container(
                width: _thumbSize,
                height: _thumbSize,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.call,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
