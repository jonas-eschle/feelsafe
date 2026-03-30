import 'package:just_audio/just_audio.dart';

class AudioService {
  AudioPlayer? _player;

  /// Play a ringtone from assets. Loops until stopped.
  Future<void> playRingtone() async {
    await stop();
    _player = AudioPlayer();
    try {
      await _player!.setAsset('assets/audio/ringtone.wav');
      await _player!.setLoopMode(LoopMode.one);
      await _player!.play();
    } catch (_) {
      // Asset may not exist yet — silently fail
    }
  }

  /// Play alarm sound at max volume, looping.
  Future<void> playAlarm() async {
    await stop();
    _player = AudioPlayer();
    try {
      await _player!.setAsset('assets/audio/alarm.mp3');
      await _player!.setLoopMode(LoopMode.one);
      await _player!.setVolume(1.0);
      await _player!.play();
    } catch (_) {
      // Asset may not exist yet — silently fail
    }
  }

  /// Play a voice recording file from the filesystem.
  Future<void> playVoiceRecording(String filePath) async {
    await stop();
    _player = AudioPlayer();
    await _player!.setFilePath(filePath);
    await _player!.play();
  }

  Future<void> stop() async {
    await _player?.stop();
    await _player?.dispose();
    _player = null;
  }
}
