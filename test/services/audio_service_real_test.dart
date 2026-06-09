// Host tests for the REAL RealAudioService paths not covered by
// audio_service_test.dart (which covers resolveBuiltInVoicePath, the Sim, the
// G6 ramp, and the F3 ringtone fallback).
//
// Drives the genuine production logic — playSound / playAlarmWithConfig
// (custom + siren + immediate-volume), playVoiceRecording (file + built-in +
// Layer-3 guard), stop + player recreation, and bootstrapVoiceAssets (per-
// locale TTS synthesize-to-file + skip-cached + onFailure) — against a mocked
// [AudioPlayer] / [FlutterTts] and a mocked path_provider channel. NOT the
// SimulationAudioService.

import 'dart:io';

import 'package:flutter/services.dart';

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mocktail/mocktail.dart';

import 'package:guardianangela/services/audio_service.dart';

class _MockAudioPlayer extends Mock implements AudioPlayer {}

class _MockFlutterTts extends Mock implements FlutterTts {}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Builds a [RealAudioService] over a fully-stubbed mock player that records
/// the asset / file / loop / volume calls. The audio_session plugin channel is
/// NOT mocked, so the real `AudioSession.configure` throws
/// MissingPluginException on the host and the service's degrade-catch runs.
({
  RealAudioService svc,
  _MockAudioPlayer player,
  List<String> assets,
  List<String> files,
  List<LoopMode> loops,
})
_build() {
  final player = _MockAudioPlayer();
  final assets = <String>[];
  final files = <String>[];
  final loops = <LoopMode>[];
  when(() => player.processingState).thenReturn(ProcessingState.idle);
  when(() => player.setAsset(any())).thenAnswer((inv) async {
    assets.add(inv.positionalArguments[0] as String);
    return null;
  });
  when(() => player.setFilePath(any())).thenAnswer((inv) async {
    files.add(inv.positionalArguments[0] as String);
    return null;
  });
  when(() => player.setLoopMode(any())).thenAnswer((inv) async {
    loops.add(inv.positionalArguments[0] as LoopMode);
  });
  when(() => player.setVolume(any())).thenAnswer((_) async {});
  when(player.play).thenAnswer((_) async {});
  when(player.stop).thenAnswer((_) async {});
  when(player.dispose).thenAnswer((_) async {});
  final svc = RealAudioService(player: player, tts: _MockFlutterTts());
  return (svc: svc, player: player, assets: assets, files: files, loops: loops);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() => registerFallbackValue(LoopMode.all));

  // -------------------------------------------------------------------------
  // playSound — one-shot, loop off
  // -------------------------------------------------------------------------
  group('RealAudioService.playSound', () {
    test('loads the asset and sets loop OFF (one-shot)', () async {
      final f = _build();
      await f.svc.playSound('assets/audio/countdown.wav');
      check(f.assets).deepEquals(const ['assets/audio/countdown.wav']);
      check(f.loops).deepEquals(const [LoopMode.off]);
      verify(f.player.play).called(1);
    });
  });

  // -------------------------------------------------------------------------
  // playAlarmWithConfig — siren / custom / immediate-volume / guards
  // -------------------------------------------------------------------------
  group('RealAudioService.playAlarmWithConfig', () {
    test('isSimulation=true is a Layer-3 no-op (no player calls)', () async {
      final f = _build();
      await f.svc.playAlarmWithConfig(isSimulation: true);
      check(f.assets).isEmpty();
      check(f.files).isEmpty();
      verifyNever(f.player.play);
    });

    test(
      'soundChoice=custom without customSoundPath throws ArgumentError',
      () async {
        final f = _build();
        await check(
          f.svc.playAlarmWithConfig(soundChoice: 'custom'),
        ).throws<ArgumentError>();
      },
    );

    test('siren choice loads the built-in siren asset and loops ALL', () async {
      final f = _build();
      // rampSeconds=0 → immediate volume, no Timer (deterministic).
      await f.svc.playAlarmWithConfig(rampSeconds: 0);
      check(f.assets).deepEquals(const ['assets/audio/siren.wav']);
      check(f.loops).deepEquals(const [LoopMode.all]);
    });

    test('custom choice + path loads the file path', () async {
      final f = _build();
      await f.svc.playAlarmWithConfig(
        soundChoice: 'custom',
        customSoundPath: '/sd/alarm.m4a',
        rampSeconds: 0,
      );
      check(f.files).deepEquals(const ['/sd/alarm.m4a']);
    });

    test('rampSeconds=0 sets the clamped volume directly (no ramp)', () async {
      final f = _build();
      await f.svc.playAlarmWithConfig(volume: 1.5, rampSeconds: 0);
      // volume is clamped to 1.0 and applied directly.
      verify(() => f.player.setVolume(1.0)).called(1);
      verify(f.player.play).called(1);
    });
  });

  // -------------------------------------------------------------------------
  // playRingtone — configures + loops ALL + plays (the happy non-fallback path)
  // -------------------------------------------------------------------------
  group('RealAudioService.playRingtone', () {
    test('full-volume looping default ring is started', () async {
      final f = _build();
      await f.svc.playRingtone(null);
      verify(() => f.player.setVolume(1.0)).called(1);
      check(f.loops).deepEquals(const [LoopMode.all]);
      verify(f.player.play).called(1);
    });
  });

  // -------------------------------------------------------------------------
  // playVoiceRecording — file vs built-in vs Layer-3 guard
  // -------------------------------------------------------------------------
  group('RealAudioService.playVoiceRecording', () {
    test('isSimulation=true is a no-op', () async {
      final f = _build();
      await f.svc.playVoiceRecording(null, isSimulation: true);
      check(f.assets).isEmpty();
      check(f.files).isEmpty();
    });

    test('explicit filePath loads via setFilePath, loop OFF', () async {
      final f = _build();
      await f.svc.playVoiceRecording('/docs/angela_mine.m4a');
      check(f.files).deepEquals(const ['/docs/angela_mine.m4a']);
      check(f.loops).deepEquals(const [LoopMode.off]);
      verify(f.player.play).called(1);
    });

    test('null filePath resolves a built-in locale asset', () async {
      final f = _build();
      await f.svc.playVoiceRecording(null);
      // The resolved built-in path is one of the bundled angela_* assets.
      check(f.assets).length.equals(1);
      check(f.assets.single).startsWith('assets/voice/angela_');
    });
  });

  // -------------------------------------------------------------------------
  // stop — disposes the player and recreates it so a later call still works
  // -------------------------------------------------------------------------
  group('RealAudioService.stop', () {
    test(
      'cancels the ramp timer, stops, and disposes the injected player',
      () async {
        final f = _build();
        // Kick off a ramp so stop() also cancels the active _rampTimer
        // (covers the `_rampTimer?.cancel()` branch).
        await f.svc.playAlarmWithConfig();
        await f.svc.stop();
        verify(f.player.stop).called(1);
        verify(f.player.dispose).called(1);
      },
    );
  });

  // -------------------------------------------------------------------------
  // bootstrapVoiceAssets — per-locale TTS synth, skip-cached, onFailure
  // -------------------------------------------------------------------------
  group('RealAudioService.bootstrapVoiceAssets', () {
    late Directory tmp;

    setUp(() async {
      tmp = await Directory.systemTemp.createTemp('ga_voice_');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('plugins.flutter.io/path_provider'),
            (call) async => call.method == 'getApplicationDocumentsDirectory'
                ? tmp.path
                : null,
          );
    });

    tearDown(() async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('plugins.flutter.io/path_provider'),
            null,
          );
      await tmp.delete(recursive: true);
    });

    test('synthesizes one file per locale (sets language + writes), and the '
        'zh/zh_TW BCP-47 tags are mapped', () async {
      final tts = _MockFlutterTts();
      final languages = <String>[];
      final outPaths = <String>[];
      when(() => tts.setLanguage(any())).thenAnswer((inv) async {
        languages.add(inv.positionalArguments[0] as String);
        return 1;
      });
      when(() => tts.synthesizeToFile(any(), any())).thenAnswer((inv) async {
        outPaths.add(inv.positionalArguments[1] as String);
        return 1;
      });
      final svc = RealAudioService(player: _MockAudioPlayer(), tts: tts);

      await svc.bootstrapVoiceAssets();

      // 14 supported locales → 14 synth calls.
      check(outPaths).length.equals(14);
      // The TTS language tags include the BCP-47 mapping for chinese.
      check(languages).contains('zh-TW');
      check(languages).contains('zh-CN');
      // A plain locale passes through unchanged.
      check(languages).contains('de');
    });

    test('skips a locale whose cached m4a already exists on disk', () async {
      // Pre-create the english cache file so en is skipped.
      Directory('${tmp.path}/voice').createSync(recursive: true);
      File('${tmp.path}/voice/angela_en.m4a').writeAsBytesSync(const [0]);

      final tts = _MockFlutterTts();
      final synthLocales = <String>[];
      when(() => tts.setLanguage(any())).thenAnswer((_) async => 1);
      when(() => tts.synthesizeToFile(any(), any())).thenAnswer((inv) async {
        // path is .../angela_<locale>.m4a — capture which were synthesized.
        synthLocales.add(inv.positionalArguments[1] as String);
        return 1;
      });
      final svc = RealAudioService(player: _MockAudioPlayer(), tts: tts);

      await svc.bootstrapVoiceAssets();

      // en was cached → not re-synthesized; the other 13 are.
      check(synthLocales.any((p) => p.endsWith('angela_en.m4a'))).isFalse();
      check(synthLocales).length.equals(13);
    });

    test('a per-locale synth failure routes to onFailure but never throws '
        'and continues the other locales', () async {
      final tts = _MockFlutterTts();
      when(() => tts.setLanguage(any())).thenAnswer((_) async => 1);
      // Fail only the german synth; succeed the rest.
      when(() => tts.synthesizeToFile(any(), any())).thenAnswer((inv) async {
        final path = inv.positionalArguments[1] as String;
        if (path.endsWith('angela_de.m4a')) {
          throw Exception('tts engine missing de voice');
        }
        return 1;
      });
      final svc = RealAudioService(player: _MockAudioPlayer(), tts: tts);

      final failures = <String>[];
      await svc.bootstrapVoiceAssets(
        onFailure: (locale, error, stack) => failures.add(locale),
      );

      // de failed → routed to onFailure; bootstrap did not abort.
      check(failures).deepEquals(const ['de']);
    });
  });
}
