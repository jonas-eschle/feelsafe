import 'package:checks/checks.dart';
import 'package:test/test.dart';

import 'package:guardianangela/services/audio_service.dart';
import 'package:guardianangela/services/protocols/audio_service_protocol.dart';
import 'package:guardianangela/services/sim/audio_service_sim.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

SimulationAudioService _sim() => SimulationAudioService();

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // -----------------------------------------------------------------------
  // resolveBuiltInVoicePath helper
  // -----------------------------------------------------------------------
  group('resolveBuiltInVoicePath', () {
    test('en returns english asset', () {
      check(resolveBuiltInVoicePath('en')).equals('assets/voice/angela_en.m4a');
    });

    test('en_US resolves via prefix to english', () {
      check(
        resolveBuiltInVoicePath('en_US'),
      ).equals('assets/voice/angela_en.m4a');
    });

    test('de returns german asset', () {
      check(resolveBuiltInVoicePath('de')).equals('assets/voice/angela_de.m4a');
    });

    test('de_DE resolves via prefix to german', () {
      check(
        resolveBuiltInVoicePath('de_DE'),
      ).equals('assets/voice/angela_de.m4a');
    });

    test('fr returns french asset', () {
      check(resolveBuiltInVoicePath('fr')).equals('assets/voice/angela_fr.m4a');
    });

    test('es returns spanish asset', () {
      check(resolveBuiltInVoicePath('es')).equals('assets/voice/angela_es.m4a');
    });

    test('ru returns russian asset', () {
      check(resolveBuiltInVoicePath('ru')).equals('assets/voice/angela_ru.m4a');
    });

    test('zh returns simplified chinese asset', () {
      check(resolveBuiltInVoicePath('zh')).equals('assets/voice/angela_zh.m4a');
    });

    test('zh_TW returns traditional chinese asset (full-tag match)', () {
      check(
        resolveBuiltInVoicePath('zh_TW'),
      ).equals('assets/voice/angela_zh_TW.m4a');
    });

    test('zh_CN resolves via prefix to simplified chinese', () {
      check(
        resolveBuiltInVoicePath('zh_CN'),
      ).equals('assets/voice/angela_zh.m4a');
    });

    test('hi returns hindi asset', () {
      check(resolveBuiltInVoicePath('hi')).equals('assets/voice/angela_hi.m4a');
    });

    test('fa returns farsi asset', () {
      check(resolveBuiltInVoicePath('fa')).equals('assets/voice/angela_fa.m4a');
    });

    test('uk returns ukrainian asset', () {
      check(resolveBuiltInVoicePath('uk')).equals('assets/voice/angela_uk.m4a');
    });

    test('pl returns polish asset', () {
      check(resolveBuiltInVoicePath('pl')).equals('assets/voice/angela_pl.m4a');
    });

    test('el returns greek asset', () {
      check(resolveBuiltInVoicePath('el')).equals('assets/voice/angela_el.m4a');
    });

    test('ar returns arabic asset', () {
      check(resolveBuiltInVoicePath('ar')).equals('assets/voice/angela_ar.m4a');
    });

    test('he returns hebrew asset', () {
      check(resolveBuiltInVoicePath('he')).equals('assets/voice/angela_he.m4a');
    });

    test('unknown locale falls back to english asset', () {
      check(
        resolveBuiltInVoicePath('xx_YY'),
      ).equals('assets/voice/angela_en.m4a');
    });

    test('empty locale string falls back to english', () {
      check(resolveBuiltInVoicePath('')).equals('assets/voice/angela_en.m4a');
    });

    test('all 14 built-in locales resolve to unique paths', () {
      final locales = [
        'en',
        'de',
        'es',
        'fr',
        'ru',
        'zh',
        'zh_TW',
        'hi',
        'fa',
        'uk',
        'pl',
        'el',
        'ar',
        'he',
      ];
      final paths = locales.map(resolveBuiltInVoicePath).toSet();
      check(paths).length.equals(14);
    });

    test('all resolved paths start with assets/voice/angela_', () {
      final locales = [
        'en',
        'de',
        'es',
        'fr',
        'ru',
        'zh',
        'zh_TW',
        'hi',
        'fa',
        'uk',
        'pl',
        'el',
        'ar',
        'he',
      ];
      for (final loc in locales) {
        check(resolveBuiltInVoicePath(loc)).startsWith('assets/voice/angela_');
      }
    });

    test('all resolved paths end with .m4a', () {
      final locales = ['en', 'de', 'zh_TW', 'ar'];
      for (final loc in locales) {
        check(resolveBuiltInVoicePath(loc)).endsWith('.m4a');
      }
    });
  });

  // -----------------------------------------------------------------------
  // SimulationAudioService
  // -----------------------------------------------------------------------
  group('SimulationAudioService', () {
    group('constructor', () {
      test('implements AudioServiceProtocol', () {
        check(_sim()).isA<AudioServiceProtocol>();
      });

      test('starts with empty calls list', () {
        check(_sim().calls).isEmpty();
      });

      test('wasStopped is false initially', () {
        check(_sim().wasStopped).isFalse();
      });
    });

    group('playAlarmWithConfig — isSimulation: false', () {
      test('records call', () async {
        final s = _sim();
        await s.playAlarmWithConfig();
        check(s.calls).length.equals(1);
        check(s.calls.first.method).equals('playAlarmWithConfig');
      });

      test('records soundChoice=siren by default', () async {
        final s = _sim();
        await s.playAlarmWithConfig();
        check(s.calls.first.soundChoice).equals('siren');
      });

      test('records custom soundChoice', () async {
        final s = _sim();
        await s.playAlarmWithConfig(
          soundChoice: 'custom',
          customSoundPath: '/path/to/alarm.m4a',
        );
        check(s.calls.first.soundChoice).equals('custom');
        check(s.calls.first.customSoundPath).equals('/path/to/alarm.m4a');
      });

      test('records volume', () async {
        final s = _sim();
        await s.playAlarmWithConfig(volume: 0.5);
        check(s.calls.first.volume).equals(0.5);
      });

      test('isSimulation is false in recorded call', () async {
        final s = _sim();
        await s.playAlarmWithConfig();
        check(s.calls.first.isSimulation).isFalse();
      });
    });

    group('playAlarmWithConfig — isSimulation: true (Layer 3)', () {
      test('records call with isSimulation=true', () async {
        final s = _sim();
        await s.playAlarmWithConfig(isSimulation: true);
        check(s.calls).length.equals(1);
        check(s.calls.first.isSimulation).isTrue();
      });

      test('isSimulation=true still records the call', () async {
        final s = _sim();
        await s.playAlarmWithConfig(isSimulation: true);
        check(s.calls.first.method).equals('playAlarmWithConfig');
      });
    });

    group('playSound', () {
      test('records call with assetPath', () async {
        final s = _sim();
        await s.playSound('assets/audio/countdown.ogg');
        check(s.calls).length.equals(1);
        check(s.calls.first.method).equals('playSound');
        check(s.calls.first.assetPath).equals('assets/audio/countdown.ogg');
      });

      test('does not record isSimulation field for playSound', () async {
        final s = _sim();
        await s.playSound('assets/audio/test.ogg');
        check(s.calls.first.isSimulation).isFalse();
      });

      test('multiple playSound calls accumulate', () async {
        final s = _sim();
        await s.playSound('a.ogg');
        await s.playSound('b.ogg');
        check(s.calls).length.equals(2);
        check(s.calls[0].assetPath).equals('a.ogg');
        check(s.calls[1].assetPath).equals('b.ogg');
      });
    });

    group('stop', () {
      test('records stop call', () async {
        final s = _sim();
        await s.stop();
        check(s.calls).length.equals(1);
        check(s.calls.first.method).equals('stop');
      });

      test('wasStopped becomes true after stop', () async {
        final s = _sim();
        await s.stop();
        check(s.wasStopped).isTrue();
      });

      test('safe to call multiple times', () async {
        final s = _sim();
        await s.stop();
        await s.stop();
        check(s.calls.where((c) => c.method == 'stop').length).equals(2);
      });
    });

    group('playVoiceRecording', () {
      test('records call with filePath=null (built-in)', () async {
        final s = _sim();
        await s.playVoiceRecording(null);
        check(s.calls).length.equals(1);
        check(s.calls.first.method).equals('playVoiceRecording');
        check(s.calls.first.filePath).isNull();
      });

      test('records call with explicit filePath', () async {
        final s = _sim();
        await s.playVoiceRecording('/docs/my_voice.m4a');
        check(s.calls.first.filePath).equals('/docs/my_voice.m4a');
      });

      test('records useSpeaker=false by default', () async {
        final s = _sim();
        await s.playVoiceRecording(null);
        check(s.calls.first.useSpeaker).equals(false);
      });

      test('records useSpeaker=true', () async {
        final s = _sim();
        await s.playVoiceRecording(null, useSpeaker: true);
        check(s.calls.first.useSpeaker).equals(true);
      });

      test('isSimulation=true no-op (Layer 3) — still recorded', () async {
        final s = _sim();
        await s.playVoiceRecording(null, isSimulation: true);
        check(s.calls.first.isSimulation).isTrue();
        check(s.calls.first.method).equals('playVoiceRecording');
      });
    });

    group('reset', () {
      test('clears calls list', () async {
        final s = _sim();
        await s.playAlarmWithConfig();
        await s.stop();
        s.reset();
        check(s.calls).isEmpty();
      });

      test('wasStopped is false after reset', () async {
        final s = _sim();
        await s.stop();
        s.reset();
        check(s.wasStopped).isFalse();
      });
    });

    group('sequence recording', () {
      test('full session sequence recorded in order', () async {
        final s = _sim();
        await s.playAlarmWithConfig();
        await s.playVoiceRecording(null);
        await s.stop();
        check(
          s.calls.map((c) => c.method).toList(),
        ).deepEquals(['playAlarmWithConfig', 'playVoiceRecording', 'stop']);
      });
    });

    group('playRingtone', () {
      test('records call with assetPath', () async {
        final s = _sim();
        await s.playRingtone('assets/audio/ringtone.mp3');
        check(s.calls).length.equals(1);
        check(s.calls.first.method).equals('playRingtone');
        check(s.calls.first.assetPath).equals('assets/audio/ringtone.mp3');
      });

      test('records call with null assetPath', () async {
        final s = _sim();
        await s.playRingtone(null);
        check(s.calls.first.method).equals('playRingtone');
        check(s.calls.first.assetPath).isNull();
      });
    });

    group('playAlarm', () {
      test('records call', () async {
        final s = _sim();
        await s.playAlarm();
        check(s.calls).length.equals(1);
        check(s.calls.first.method).equals('playAlarm');
      });

      test('playAlarm then playAlarmWithConfig accumulates', () async {
        final s = _sim();
        await s.playAlarm();
        await s.playAlarmWithConfig();
        check(s.calls).length.equals(2);
        check(s.calls[0].method).equals('playAlarm');
        check(s.calls[1].method).equals('playAlarmWithConfig');
      });
    });

    group('rampSeconds', () {
      test('default rampSeconds is kDefaultAlarmRampSeconds', () async {
        final s = _sim();
        await s.playAlarmWithConfig();
        check(s.calls.first.rampSeconds).equals(kDefaultAlarmRampSeconds);
      });

      test('kDefaultAlarmRampSeconds is 5', () {
        check(kDefaultAlarmRampSeconds).equals(5);
      });

      test('custom rampSeconds is recorded', () async {
        final s = _sim();
        await s.playAlarmWithConfig(rampSeconds: 10);
        check(s.calls.first.rampSeconds).equals(10);
      });

      test('rampSeconds=0 disables ramp (recorded correctly)', () async {
        final s = _sim();
        await s.playAlarmWithConfig(rampSeconds: 0);
        check(s.calls.first.rampSeconds).equals(0);
      });

      test('rampSeconds=1 min ramp (recorded correctly)', () async {
        final s = _sim();
        await s.playAlarmWithConfig(rampSeconds: 1);
        check(s.calls.first.rampSeconds).equals(1);
      });

      test('rampSeconds preserved in sequence of calls', () async {
        final s = _sim();
        await s.playAlarmWithConfig(rampSeconds: 3);
        await s.playAlarmWithConfig(rampSeconds: 7);
        check(s.calls[0].rampSeconds).equals(3);
        check(s.calls[1].rampSeconds).equals(7);
      });
    });
  });

  // -----------------------------------------------------------------------
  // AudioCall
  // -----------------------------------------------------------------------
  group('AudioCall', () {
    test('method is stored correctly', () {
      const call = AudioCall(method: 'test');
      check(call.method).equals('test');
    });

    test('toString contains method name', () {
      const call = AudioCall(method: 'playSound');
      check(call.toString()).contains('playSound');
    });

    test('rampSeconds is null by default', () {
      const call = AudioCall(method: 'test');
      check(call.rampSeconds).isNull();
    });

    test('rampSeconds is preserved when set', () {
      const call = AudioCall(method: 'playAlarmWithConfig', rampSeconds: 8);
      check(call.rampSeconds).equals(8);
    });
  });
}
