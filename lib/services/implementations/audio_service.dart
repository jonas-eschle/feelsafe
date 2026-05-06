/// Real audio-service implementation.
///
/// Uses `just_audio` for alarm/ringtone/voice playback. Falls back to
/// `flutter_tts` if a requested voice asset is missing. Respects
/// `isSimulation` — in simulation mode all methods log and no-op
/// (4-layer defense, layer 2).
///
/// All platform-dependent instances (`AudioPlayer`, `FlutterTts`) are
/// created lazily so the constructor can be called safely from
/// Riverpod provider graphs before `WidgetsFlutterBinding` is
/// initialized (e.g., in tests and at boot time).
library;

import 'dart:developer' as developer;

import 'package:flutter/foundation.dart' show FlutterError;
import 'package:flutter/services.dart' show rootBundle;

import 'package:flutter_tts/flutter_tts.dart';
import 'package:just_audio/just_audio.dart';

import 'package:guardianangela/core/platform/platform_info.dart';
import 'package:guardianangela/services/protocols/audio_service_protocol.dart';

/// Factory that builds a fresh [AudioPlayer]. Injected for tests.
typedef AudioPlayerFactory = AudioPlayer Function();

/// Factory that builds a fresh [FlutterTts]. Injected for tests.
typedef FlutterTtsFactory = FlutterTts Function();

/// Real platform-backed implementation of [AudioServiceProtocol].
final class AudioService implements AudioServiceProtocol {
  /// Creates the real audio service.
  ///
  /// [platform] defaults to the const production [PlatformInfo()];
  /// injected in tests.
  /// [playerFactory] and [ttsFactory] default to building real
  /// `just_audio` / `flutter_tts` instances; tests inject fakes to
  /// exercise the plugin-boundary branches.
  AudioService({
    PlatformInfo platform = const PlatformInfo(),
    AudioPlayerFactory? playerFactory,
    FlutterTtsFactory? ttsFactory,
  })  : _platform = platform,
        _playerFactory = playerFactory ?? AudioPlayer.new,
        _ttsFactory = ttsFactory ?? FlutterTts.new;

  // ignore: unused_field
  final PlatformInfo _platform;
  final AudioPlayerFactory _playerFactory;
  final FlutterTtsFactory _ttsFactory;

  /// Bundled alarm asset path.
  static const String _alarmAsset = 'assets/audio/alarm.mp3';

  /// Bundled ringtone asset path (fallback for fake calls).
  static const String _defaultRingtoneAsset = 'assets/audio/ringtone.wav';

  AudioPlayer? _alarmPlayer;
  AudioPlayer? _ringtonePlayer;
  AudioPlayer? _voicePlayer;
  FlutterTts? _tts;

  AudioPlayer get _alarm => _alarmPlayer ??= _playerFactory();
  AudioPlayer get _ringtone => _ringtonePlayer ??= _playerFactory();
  AudioPlayer get _voice => _voicePlayer ??= _playerFactory();
  FlutterTts get _ttsEngine => _tts ??= _ttsFactory();

  @override
  Future<void> playAlarm({
    bool maxVolume = true,
    bool isSimulation = false,
  }) async {
    if (isSimulation) {
      developer.log('[SIM-BLOCK] audio.playAlarm maxVolume=$maxVolume');
      return;
    }
    final player = _alarm;
    if (maxVolume) {
      await player.setVolume(1.0);
    }
    await player.setAsset(_alarmAsset);
    await player.setLoopMode(LoopMode.all);
    await player.play();
  }

  @override
  Future<void> stopAlarm() async => _alarmPlayer?.stop();

  @override
  Future<void> playRingtone({
    String? assetPath,
    bool isSimulation = false,
  }) async {
    if (isSimulation) {
      developer.log('[SIM-BLOCK] audio.playRingtone path=$assetPath');
      return;
    }
    final resolved = assetPath ?? _defaultRingtoneAsset;
    final player = _ringtone;
    await player.setAsset(resolved);
    await player.setLoopMode(LoopMode.all);
    await player.play();
  }

  @override
  Future<void> stopRingtone() async => _ringtonePlayer?.stop();

  @override
  Future<void> playVoiceRecording({
    required String assetPath,
    bool isSimulation = false,
  }) async {
    if (isSimulation) {
      developer.log('[SIM-BLOCK] audio.playVoiceRecording path=$assetPath');
      return;
    }
    final exists = await _assetExists(assetPath);
    if (!exists) {
      developer.log('voice asset missing: $assetPath — falling back to TTS');
      await _ttsEngine.speak(
        'Hi, I am running late. I will call you back soon.',
      );
      return;
    }
    final player = _voice;
    await player.setAsset(assetPath);
    await player.setLoopMode(LoopMode.off);
    await player.play();
  }

  @override
  Future<void> stopVoiceRecording() async {
    await _voicePlayer?.stop();
    await _tts?.stop();
  }

  /// Releases every lazily-allocated player and shuts the TTS engine
  /// down. Wired via `ref.onDispose(audioService.dispose)` in
  /// `service_providers.dart` so a hot-reload or container teardown
  /// doesn't leak platform resources (bugs.json Warn 1).
  Future<void> dispose() async {
    await _alarmPlayer?.dispose();
    await _ringtonePlayer?.dispose();
    await _voicePlayer?.dispose();
    await _tts?.stop();
    _alarmPlayer = null;
    _ringtonePlayer = null;
    _voicePlayer = null;
    _tts = null;
  }

  /// Checks whether a bundled asset exists. Used to decide TTS
  /// fallback for voice recordings.
  Future<bool> _assetExists(String assetPath) async {
    try {
      await rootBundle.load(assetPath);
      return true;
    } on FlutterError {
      return false;
    }
  }
}
