// M0 / #21 — built-in audio assets decode and play on a real device.
//
// The loud-alarm siren, default ringtone, and countdown-warning beep are
// bundled WAV assets. A unit test cannot catch a missing or non-decodable
// asset because it injects a *fake* player; only loading the real asset
// bundle through `just_audio` on-device exercises the decoder. If an asset
// is absent or the platform cannot decode it, `setAsset` throws
// `PlayerException` and these tests fail — which is precisely the silent-alarm
// bug this milestone fixes (the assets were previously named `*.ogg` and did
// not exist, and OGG does not decode on iOS/AVFoundation).
//
// A non-null `player.duration` after the wired service call proves the asset
// was found in the bundle AND decoded by the platform. Playback audibility is
// not asserted (the emulator runs with `-no-audio`); loadability is.

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:just_audio/just_audio.dart';

import 'package:guardianangela/services/audio_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  /// Asserts the injected player loaded a real, decodable clip.
  void expectDecoded(AudioPlayer player, String label) {
    expect(player.duration, isNotNull, reason: '$label: asset failed to load');
    expect(
      player.duration!.inMilliseconds,
      greaterThan(0),
      reason: '$label: decoded clip has zero duration',
    );
  }

  testWidgets('siren.wav decodes through RealAudioService.playAlarm', (
    tester,
  ) async {
    final player = AudioPlayer();
    final service = RealAudioService(player: player);
    // rampSeconds: 0 → no volume-ramp timer to leak across the test.
    await service.playAlarmWithConfig(rampSeconds: 0);
    expectDecoded(player, 'siren.wav');
    await service.stop();
  });

  testWidgets('ringtone_default.wav decodes through playRingtone(null)', (
    tester,
  ) async {
    final player = AudioPlayer();
    final service = RealAudioService(player: player);
    await service.playRingtone(null);
    expectDecoded(player, 'ringtone_default.wav');
    await service.stop();
  });

  testWidgets('countdown_warning.wav decodes through playSound', (
    tester,
  ) async {
    final player = AudioPlayer();
    final service = RealAudioService(player: player);
    await service.playSound('assets/audio/countdown_warning.wav');
    expectDecoded(player, 'countdown_warning.wav');
    await service.stop();
  });

  // #17: the fake-call answer flow plays the built-in voice clip via
  // playVoiceRecording(null), which resolves the bundled locale asset
  // (assets/voice/angela_<lang>.m4a). Proves the M4A voice asset decodes
  // on-device, so the answered fake call is not silent.
  testWidgets('built-in voice clip decodes through playVoiceRecording(null)', (
    tester,
  ) async {
    final player = AudioPlayer();
    final service = RealAudioService(player: player);
    await service.playVoiceRecording(null);
    expectDecoded(player, 'built-in voice');
    await service.stop();
  });
}
