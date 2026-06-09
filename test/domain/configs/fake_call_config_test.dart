/// Unit tests for [FakeCallConfig] per spec 03 §StepConfig (lines 344-354).
///
/// Covers default values, JSON round-trip across every [CallStyle],
/// nullable photo/voice path preservation, [copyWith] semantics,
/// and equality + hashCode invariants. The `callStyle` default is the
/// spec'd `platformNative` value introduced in commit 936515d.
library;

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/domain/configs/step_config.dart';
import 'package:guardianangela/domain/enums/call_style.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/enums/voice_output_mode.dart';

void main() {
  group('FakeCallConfig — defaults match spec 03:344-354', () {
    test('default callStyle is CallStyle.platformNative', () {
      const cfg = FakeCallConfig();
      check(cfg.callStyle).equals(CallStyle.platformNative);
    });

    test("default callerName is 'Angela'", () {
      const cfg = FakeCallConfig();
      check(cfg.callerName).equals('Angela');
    });

    test('default callerPhotoPath is null', () {
      const cfg = FakeCallConfig();
      check(cfg.callerPhotoPath).isNull();
    });

    test('default voiceRecordingPath is null (falls back to built-in '
        'per-language recording per C2/32)', () {
      const cfg = FakeCallConfig();
      check(cfg.voiceRecordingPath).isNull();
    });

    test('default customRingtonePath is null (Tier-F F3 — bundled default '
        'ring is used)', () {
      const cfg = FakeCallConfig();
      check(cfg.customRingtonePath).isNull();
    });

    test('default voiceOutputMode is VoiceOutputMode.earpiece', () {
      const cfg = FakeCallConfig();
      check(cfg.voiceOutputMode).equals(VoiceOutputMode.earpiece);
    });

    test('default ringDurationSeconds is 30', () {
      const cfg = FakeCallConfig();
      check(cfg.ringDurationSeconds).equals(30);
    });

    test('default declineIsSafe is true (A1 — decline resets to step 0)', () {
      const cfg = FakeCallConfig();
      check(cfg.declineIsSafe).isTrue();
    });

    test('default declineWithDistressHoldSeconds is 5', () {
      const cfg = FakeCallConfig();
      check(cfg.declineWithDistressHoldSeconds).equals(5);
    });

    test('default blackScreenMode is false', () {
      const cfg = FakeCallConfig();
      check(cfg.blackScreenMode).isFalse();
    });

    test('constructor is const (compile-time constant)', () {
      // ignore: prefer_const_constructors
      const a = FakeCallConfig();
      const b = FakeCallConfig();
      check(identical(a, b)).isTrue();
    });
  });

  group('FakeCallConfig — JSON round-trip', () {
    test('toJson serialises callStyle by enum name (platformNative)', () {
      const cfg = FakeCallConfig();
      check(cfg.toJson()['callStyle']).equals('platformNative');
    });

    test('toJson serialises voiceOutputMode by enum name', () {
      const cfg = FakeCallConfig();
      check(cfg.toJson()['voiceOutputMode']).equals('earpiece');
    });

    test('toJson omits null callerPhotoPath', () {
      const cfg = FakeCallConfig();
      check(cfg.toJson().containsKey('callerPhotoPath')).isFalse();
    });

    test('toJson omits null voiceRecordingPath', () {
      const cfg = FakeCallConfig();
      check(cfg.toJson().containsKey('voiceRecordingPath')).isFalse();
    });

    test('toJson includes non-null callerPhotoPath', () {
      const cfg = FakeCallConfig(callerPhotoPath: '/path/to/photo.png');
      check(cfg.toJson()['callerPhotoPath']).equals('/path/to/photo.png');
    });

    test('toJson includes non-null voiceRecordingPath', () {
      const cfg = FakeCallConfig(voiceRecordingPath: '/path/to/audio.m4a');
      check(cfg.toJson()['voiceRecordingPath']).equals('/path/to/audio.m4a');
    });

    test('toJson omits null customRingtonePath', () {
      const cfg = FakeCallConfig();
      check(cfg.toJson().containsKey('customRingtonePath')).isFalse();
    });

    test('toJson includes non-null customRingtonePath', () {
      const cfg = FakeCallConfig(customRingtonePath: '/data/ringtones/abc.mp3');
      check(
        cfg.toJson()['customRingtonePath'],
      ).equals('/data/ringtones/abc.mp3');
    });

    test('round-trip preserves a custom ringtone path through draft→DB '
        '(Tier-F F3 picked path persists)', () {
      const original = FakeCallConfig(
        callerName: 'Mom',
        customRingtonePath: '/data/ringtones/picked.m4a',
      );
      final restored = StepConfig.fromJson(
        ChainStepType.fakeCall,
        original.toJson(),
      );
      check(restored).equals(original);
      check(
        (restored as FakeCallConfig).customRingtonePath,
      ).equals('/data/ringtones/picked.m4a');
    });

    test('round-trip preserves default values', () {
      const original = FakeCallConfig();
      final restored = StepConfig.fromJson(
        ChainStepType.fakeCall,
        original.toJson(),
      );
      check(restored).equals(original);
    });

    test('round-trip preserves custom values with non-null paths', () {
      const original = FakeCallConfig(
        callStyle: CallStyle.androidNative,
        callerName: 'Mom',
        callerPhotoPath: '/photos/mom.jpg',
        voiceRecordingPath: '/audio/mom.m4a',
        voiceOutputMode: VoiceOutputMode.speaker,
        ringDurationSeconds: 60,
        declineIsSafe: false,
        declineWithDistressHoldSeconds: 3,
        blackScreenMode: true,
      );
      final restored = StepConfig.fromJson(
        ChainStepType.fakeCall,
        original.toJson(),
      );
      check(restored).equals(original);
    });

    test(
      'round-trip preserves null callerPhotoPath and voiceRecordingPath',
      () {
        const original = FakeCallConfig(callerName: 'Bob');
        final restored = StepConfig.fromJson(
          ChainStepType.fakeCall,
          original.toJson(),
        );
        check((restored as FakeCallConfig).callerPhotoPath).isNull();
        check(restored.voiceRecordingPath).isNull();
      },
    );

    test('fromJson falls back to defaults when fields missing', () {
      final cfg = FakeCallConfig.fromJson(const <String, dynamic>{});
      check(cfg).equals(const FakeCallConfig());
    });

    test('round-trip preserves every CallStyle value (including '
        'platformNative)', () {
      for (final style in CallStyle.values) {
        final original = FakeCallConfig(callStyle: style);
        final restored = StepConfig.fromJson(
          ChainStepType.fakeCall,
          original.toJson(),
        );
        check(restored).equals(original);
        check((restored as FakeCallConfig).callStyle).equals(style);
      }
    });

    test('round-trip preserves every VoiceOutputMode value', () {
      for (final mode in VoiceOutputMode.values) {
        final original = FakeCallConfig(voiceOutputMode: mode);
        final restored = StepConfig.fromJson(
          ChainStepType.fakeCall,
          original.toJson(),
        );
        check(restored).equals(original);
        check((restored as FakeCallConfig).voiceOutputMode).equals(mode);
      }
    });

    test('StepConfig.fromJson with ChainStepType.fakeCall returns '
        'FakeCallConfig', () {
      const original = FakeCallConfig(callerName: 'Eve');
      final restored = StepConfig.fromJson(
        ChainStepType.fakeCall,
        original.toJson(),
      );
      check(restored).isA<FakeCallConfig>();
    });

    test('fromJson accepts integer for ringDurationSeconds', () {
      final cfg = FakeCallConfig.fromJson(const <String, dynamic>{
        'ringDurationSeconds': 45,
      });
      check(cfg.ringDurationSeconds).equals(45);
    });

    test('fromJson accepts integer for declineWithDistressHoldSeconds', () {
      final cfg = FakeCallConfig.fromJson(const <String, dynamic>{
        'declineWithDistressHoldSeconds': 8,
      });
      check(cfg.declineWithDistressHoldSeconds).equals(8);
    });
  });

  group('FakeCallConfig — copyWith', () {
    test('no-arg copyWith() returns an equivalent value', () {
      const cfg = FakeCallConfig(
        callStyle: CallStyle.iosNative,
        callerName: 'Alex',
        callerPhotoPath: '/photo.jpg',
        voiceRecordingPath: '/audio.m4a',
        voiceOutputMode: VoiceOutputMode.speaker,
        ringDurationSeconds: 45,
        declineIsSafe: false,
        declineWithDistressHoldSeconds: 7,
        blackScreenMode: true,
      );
      check(cfg.copyWith()).equals(cfg);
    });

    test('copyWith replaces callStyle', () {
      const cfg = FakeCallConfig();
      final updated = cfg.copyWith(callStyle: CallStyle.minimal);
      check(updated.callStyle).equals(CallStyle.minimal);
      check(updated.callerName).equals(cfg.callerName);
    });

    test('copyWith replaces callerName', () {
      const cfg = FakeCallConfig();
      final updated = cfg.copyWith(callerName: 'Dad');
      check(updated.callerName).equals('Dad');
    });

    test('copyWith replaces callerPhotoPath', () {
      const cfg = FakeCallConfig();
      final updated = cfg.copyWith(callerPhotoPath: '/new/photo.png');
      check(updated.callerPhotoPath).equals('/new/photo.png');
    });

    test('copyWith replaces voiceRecordingPath', () {
      const cfg = FakeCallConfig();
      final updated = cfg.copyWith(voiceRecordingPath: '/new/audio.m4a');
      check(updated.voiceRecordingPath).equals('/new/audio.m4a');
    });

    test('copyWith replaces customRingtonePath', () {
      const cfg = FakeCallConfig();
      final updated = cfg.copyWith(
        customRingtonePath: '/data/ringtones/new.mp3',
      );
      check(updated.customRingtonePath).equals('/data/ringtones/new.mp3');
    });

    test('copyWith CANNOT clear customRingtonePath (x ?? this.x keeps the '
        'old value) — KEY FINDING', () {
      const cfg = FakeCallConfig(customRingtonePath: '/data/ringtones/x.mp3');
      // Passing null means "leave unchanged", so the path survives.
      final updated = cfg.copyWith(callerName: 'Dad');
      check(updated.customRingtonePath).equals('/data/ringtones/x.mp3');
    });

    test('direct construction clears customRingtonePath back to null '
        '(the editor _withCustomRingtone path)', () {
      const cfg = FakeCallConfig(customRingtonePath: '/data/ringtones/x.mp3');
      final cleared = FakeCallConfig(
        callStyle: cfg.callStyle,
        callerName: cfg.callerName,
        callerPhotoPath: cfg.callerPhotoPath,
        voiceRecordingPath: cfg.voiceRecordingPath,
        voiceOutputMode: cfg.voiceOutputMode,
        ringDurationSeconds: cfg.ringDurationSeconds,
        declineIsSafe: cfg.declineIsSafe,
        declineWithDistressHoldSeconds: cfg.declineWithDistressHoldSeconds,
        blackScreenMode: cfg.blackScreenMode,
      );
      check(cleared.customRingtonePath).isNull();
    });

    test('copyWith replaces voiceOutputMode', () {
      const cfg = FakeCallConfig();
      final updated = cfg.copyWith(voiceOutputMode: VoiceOutputMode.speaker);
      check(updated.voiceOutputMode).equals(VoiceOutputMode.speaker);
    });

    test('copyWith replaces ringDurationSeconds', () {
      const cfg = FakeCallConfig();
      final updated = cfg.copyWith(ringDurationSeconds: 120);
      check(updated.ringDurationSeconds).equals(120);
    });

    test('copyWith replaces declineIsSafe', () {
      const cfg = FakeCallConfig();
      final updated = cfg.copyWith(declineIsSafe: false);
      check(updated.declineIsSafe).isFalse();
    });

    test('copyWith replaces declineWithDistressHoldSeconds', () {
      const cfg = FakeCallConfig();
      final updated = cfg.copyWith(declineWithDistressHoldSeconds: 10);
      check(updated.declineWithDistressHoldSeconds).equals(10);
    });

    test('copyWith replaces blackScreenMode', () {
      const cfg = FakeCallConfig();
      final updated = cfg.copyWith(blackScreenMode: true);
      check(updated.blackScreenMode).isTrue();
    });
  });

  group('FakeCallConfig — equality + hashCode', () {
    test('equality is reflexive', () {
      const cfg = FakeCallConfig(callerName: 'Sam');
      check(cfg).equals(cfg);
    });

    test('equality is symmetric', () {
      const a = FakeCallConfig(callerName: 'Sam');
      const b = FakeCallConfig(callerName: 'Sam');
      check(a).equals(b);
      check(b).equals(a);
    });

    test('equality is transitive', () {
      const a = FakeCallConfig(ringDurationSeconds: 60);
      const b = FakeCallConfig(ringDurationSeconds: 60);
      const c = FakeCallConfig(ringDurationSeconds: 60);
      check(a == b).isTrue();
      check(b == c).isTrue();
      check(a == c).isTrue();
    });

    test('equal values have equal hashCodes', () {
      const a = FakeCallConfig(
        callStyle: CallStyle.androidNative,
        callerName: 'Lee',
        ringDurationSeconds: 45,
      );
      const b = FakeCallConfig(
        callStyle: CallStyle.androidNative,
        callerName: 'Lee',
        ringDurationSeconds: 45,
      );
      check(a.hashCode).equals(b.hashCode);
    });

    test('inequality on callStyle', () {
      const a = FakeCallConfig();
      const b = FakeCallConfig(callStyle: CallStyle.androidNative);
      check(a == b).isFalse();
    });

    test('inequality on callerName', () {
      const a = FakeCallConfig();
      const b = FakeCallConfig(callerName: 'Other');
      check(a == b).isFalse();
    });

    test('inequality on callerPhotoPath', () {
      const a = FakeCallConfig();
      const b = FakeCallConfig(callerPhotoPath: '/x.jpg');
      check(a == b).isFalse();
    });

    test('inequality on voiceRecordingPath', () {
      const a = FakeCallConfig();
      const b = FakeCallConfig(voiceRecordingPath: '/x.m4a');
      check(a == b).isFalse();
    });

    test('inequality on customRingtonePath', () {
      const a = FakeCallConfig();
      const b = FakeCallConfig(customRingtonePath: '/r.mp3');
      check(a == b).isFalse();
    });

    test('inequality on voiceOutputMode', () {
      const a = FakeCallConfig();
      const b = FakeCallConfig(voiceOutputMode: VoiceOutputMode.speaker);
      check(a == b).isFalse();
    });

    test('inequality on ringDurationSeconds', () {
      const a = FakeCallConfig();
      const b = FakeCallConfig(ringDurationSeconds: 60);
      check(a == b).isFalse();
    });

    test('inequality on declineIsSafe', () {
      const a = FakeCallConfig();
      const b = FakeCallConfig(declineIsSafe: false);
      check(a == b).isFalse();
    });

    test('inequality on declineWithDistressHoldSeconds', () {
      const a = FakeCallConfig();
      const b = FakeCallConfig(declineWithDistressHoldSeconds: 7);
      check(a == b).isFalse();
    });

    test('inequality on blackScreenMode', () {
      const a = FakeCallConfig();
      const b = FakeCallConfig(blackScreenMode: true);
      check(a == b).isFalse();
    });
  });

  group('FakeCallConfig — edge cases', () {
    test('ringDurationSeconds accepts spec lower bound 5', () {
      const cfg = FakeCallConfig(ringDurationSeconds: 5);
      check(cfg.ringDurationSeconds).equals(5);
    });

    test('ringDurationSeconds accepts spec upper bound 120', () {
      const cfg = FakeCallConfig(ringDurationSeconds: 120);
      check(cfg.ringDurationSeconds).equals(120);
    });

    test('platformNative is the default-encoded callStyle in JSON', () {
      const original = FakeCallConfig();
      final json = original.toJson();
      check(json['callStyle']).equals('platformNative');
    });

    test('platformNative round-trips back to platformNative', () {
      const original = FakeCallConfig();
      final restored = StepConfig.fromJson(
        ChainStepType.fakeCall,
        original.toJson(),
      );
      check(
        (restored as FakeCallConfig).callStyle,
      ).equals(CallStyle.platformNative);
    });
  });
}
