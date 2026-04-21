/// Plugin-boundary tests for [AudioService].
///
/// Exercises the branches that normally reach `just_audio` /
/// `flutter_tts` by injecting mocks through the DI seams
/// (`playerFactory`, `ttsFactory`). This covers both the non-simulation
/// happy paths and the `isSimulation` short-circuits.
library;

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mocktail/mocktail.dart';

import 'package:guardianangela/services/implementations/audio_service.dart';

class _MockAudioPlayer extends Mock implements AudioPlayer {}

class _MockFlutterTts extends Mock implements FlutterTts {}

/// Stub-factory that hands out a queue of pre-built players so the
/// `AudioService`'s three lazy slots (alarm, ringtone, voice) can each
/// be verified independently.
class _PlayerQueue {
  _PlayerQueue(List<AudioPlayer> players) : _players = List.of(players);

  final List<AudioPlayer> _players;
  final List<AudioPlayer> handedOut = <AudioPlayer>[];

  AudioPlayer next() {
    final p = _players.removeAt(0);
    handedOut.add(p);
    return p;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(LoopMode.off);
  });

  _MockAudioPlayer makePlayer() {
    final p = _MockAudioPlayer();
    when(() => p.setVolume(any())).thenAnswer((_) async {});
    when(() => p.setAsset(any())).thenAnswer((_) async => null);
    when(() => p.setLoopMode(any())).thenAnswer((_) async {});
    when(p.play).thenAnswer((_) async {});
    when(p.stop).thenAnswer((_) async {});
    return p;
  }

  _MockFlutterTts makeTts() {
    final t = _MockFlutterTts();
    when(() => t.speak(any())).thenAnswer((_) async => 1);
    when(t.stop).thenAnswer((_) async => 1);
    return t;
  }

  AudioService build({
    List<AudioPlayer>? players,
    FlutterTts? tts,
  }) {
    final queue = _PlayerQueue(
      players ?? [makePlayer(), makePlayer(), makePlayer()],
    );
    final ttsInstance = tts ?? makeTts();
    return AudioService(
      playerFactory: queue.next,
      ttsFactory: () => ttsInstance,
    );
  }

  group('AudioService.playAlarm', () {
    test('simulation branch does not touch the player factory', () async {
      var built = 0;
      final s = AudioService(
        playerFactory: () {
          built++;
          return makePlayer();
        },
        ttsFactory: makeTts,
      );
      await s.playAlarm(isSimulation: true);
      check(built).equals(0);
    });

    test('real branch configures volume, asset, loop and plays', () async {
      final player = makePlayer();
      final s = build(players: [player, makePlayer(), makePlayer()]);
      await s.playAlarm();
      verify(() => player.setVolume(1.0)).called(1);
      verify(() => player.setAsset('assets/audio/alarm.mp3')).called(1);
      verify(() => player.setLoopMode(LoopMode.all)).called(1);
      verify(player.play).called(1);
    });

    test('maxVolume=false skips setVolume', () async {
      final player = makePlayer();
      final s = build(players: [player, makePlayer(), makePlayer()]);
      await s.playAlarm(maxVolume: false);
      verifyNever(() => player.setVolume(any()));
      verify(() => player.setAsset('assets/audio/alarm.mp3')).called(1);
      verify(player.play).called(1);
    });

    test('second call reuses the same alarm player (lazy singleton)',
        () async {
      final p1 = makePlayer();
      final p2 = makePlayer();
      final s = build(players: [p1, p2, makePlayer(), makePlayer()]);
      await s.playAlarm();
      await s.playAlarm();
      verify(p1.play).called(2);
      verifyNever(p2.play);
    });
  });

  group('AudioService.stopAlarm', () {
    test('no-op before first play (lazy player never constructed)',
        () async {
      var built = 0;
      final s = AudioService(
        playerFactory: () {
          built++;
          return makePlayer();
        },
        ttsFactory: makeTts,
      );
      await s.stopAlarm();
      check(built).equals(0);
    });

    test('stops the alarm player after playAlarm', () async {
      final player = makePlayer();
      final s = build(players: [player, makePlayer(), makePlayer()]);
      await s.playAlarm();
      await s.stopAlarm();
      verify(player.stop).called(1);
    });
  });

  group('AudioService.playRingtone', () {
    test('simulation branch is a no-op', () async {
      var built = 0;
      final s = AudioService(
        playerFactory: () {
          built++;
          return makePlayer();
        },
        ttsFactory: makeTts,
      );
      await s.playRingtone(isSimulation: true);
      check(built).equals(0);
    });

    test('uses default asset when none given', () async {
      // First factory hand-out maps to whatever slot is touched first.
      final ringtone = makePlayer();
      final s = build(players: [ringtone, makePlayer(), makePlayer()]);
      await s.playRingtone();
      verify(() => ringtone.setAsset('assets/audio/ringtone.wav')).called(1);
      verify(() => ringtone.setLoopMode(LoopMode.all)).called(1);
      verify(ringtone.play).called(1);
    });

    test('honors caller-supplied assetPath', () async {
      final ringtone = makePlayer();
      final s = build(players: [ringtone, makePlayer(), makePlayer()]);
      await s.playRingtone(assetPath: 'assets/audio/custom.wav');
      verify(() => ringtone.setAsset('assets/audio/custom.wav')).called(1);
      verify(ringtone.play).called(1);
    });

    test('does not reuse the alarm player', () async {
      final alarm = makePlayer();
      final ringtone = makePlayer();
      final s = build(players: [alarm, ringtone, makePlayer()]);
      await s.playAlarm();
      await s.playRingtone();
      verify(alarm.play).called(1);
      verify(ringtone.play).called(1);
      verifyNever(() => alarm.setAsset('assets/audio/ringtone.wav'));
    });
  });

  group('AudioService.stopRingtone', () {
    test('no-op before first playRingtone', () async {
      var built = 0;
      final s = AudioService(
        playerFactory: () {
          built++;
          return makePlayer();
        },
        ttsFactory: makeTts,
      );
      await s.stopRingtone();
      check(built).equals(0);
    });

    test('stops the ringtone player', () async {
      final ringtone = makePlayer();
      final s = build(players: [ringtone, makePlayer(), makePlayer()]);
      await s.playRingtone();
      await s.stopRingtone();
      verify(ringtone.stop).called(1);
    });
  });

  group('AudioService.playVoiceRecording', () {
    test('simulation branch skips both player and tts', () async {
      var built = 0;
      final tts = makeTts();
      final s = AudioService(
        playerFactory: () {
          built++;
          return makePlayer();
        },
        ttsFactory: () => tts,
      );
      await s.playVoiceRecording(
        assetPath: 'assets/voice/anything.wav',
        isSimulation: true,
      );
      check(built).equals(0);
      verifyNever(() => tts.speak(any()));
    });

    test('plays the asset when it exists on the bundle', () async {
      final voice = makePlayer();
      final s = build(players: [voice, makePlayer(), makePlayer()]);
      // alarm.mp3 is a real bundled asset declared in pubspec.yaml and
      // copied into the unit-test asset bundle, so rootBundle.load
      // succeeds here and the method chooses the player path.
      const path = 'assets/audio/alarm.mp3';
      await s.playVoiceRecording(assetPath: path);
      verify(() => voice.setAsset(path)).called(1);
      verify(() => voice.setLoopMode(LoopMode.off)).called(1);
      verify(voice.play).called(1);
    });

    test('falls back to TTS when the asset is missing', () async {
      final voice = makePlayer();
      final tts = makeTts();
      final s = AudioService(
        playerFactory: _PlayerQueue([voice, makePlayer(), makePlayer()]).next,
        ttsFactory: () => tts,
      );
      // Asset definitely not bundled in the test harness.
      const missing = 'assets/voice/does-not-exist.wav';
      await s.playVoiceRecording(assetPath: missing);
      verify(() => tts.speak(any())).called(1);
      verifyNever(() => voice.setAsset(any()));
      verifyNever(voice.play);
    });
  });

  group('AudioService.stopVoiceRecording', () {
    test('no-op when neither voice nor tts were touched', () async {
      var builtPlayers = 0;
      var builtTts = 0;
      final s = AudioService(
        playerFactory: () {
          builtPlayers++;
          return makePlayer();
        },
        ttsFactory: () {
          builtTts++;
          return makeTts();
        },
      );
      await s.stopVoiceRecording();
      check(builtPlayers).equals(0);
      check(builtTts).equals(0);
    });

    test('stops the voice player after a successful play', () async {
      final voice = makePlayer();
      final s = build(players: [voice, makePlayer(), makePlayer()]);
      await s.playVoiceRecording(assetPath: 'assets/audio/alarm.mp3');
      await s.stopVoiceRecording();
      verify(voice.stop).called(1);
    });

    test('stops the tts engine after a fallback', () async {
      final tts = makeTts();
      final s = AudioService(
        playerFactory: _PlayerQueue(
          [makePlayer(), makePlayer(), makePlayer()],
        ).next,
        ttsFactory: () => tts,
      );
      await s.playVoiceRecording(
        assetPath: 'assets/voice/missing.wav',
      );
      await s.stopVoiceRecording();
      verify(tts.stop).called(1);
    });
  });

  group('AudioService default constructor', () {
    test('zero-arg constructor still builds (backward compat)', () {
      // Must not throw — just constructing a real AudioService used to
      // work and still must work from production DI.
      check(() => AudioService()).returnsNormally();
    });
  });
}
