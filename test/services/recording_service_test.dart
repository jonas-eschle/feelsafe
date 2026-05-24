import 'package:checks/checks.dart';
import 'package:test/test.dart';

import 'package:guardianangela/services/protocols/recording_service_protocol.dart';
import 'package:guardianangela/services/recording_service.dart';
import 'package:guardianangela/services/sim/recording_service_sim.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

SimulationRecordingService _sim() => SimulationRecordingService();

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // -----------------------------------------------------------------------
  // validateVoiceRecordingDuration
  // -----------------------------------------------------------------------
  group('validateVoiceRecordingDuration', () {
    test('valid duration — no throw', () {
      validateVoiceRecordingDuration(const Duration(seconds: 10));
    });

    test('exactly 120 seconds — no throw', () {
      validateVoiceRecordingDuration(
        const Duration(seconds: kMaxVoiceRecordingDurationSeconds),
      );
    });

    test('zero duration — throws ArgumentError', () {
      check(
        () => validateVoiceRecordingDuration(Duration.zero),
      ).throws<ArgumentError>();
    });

    test('negative duration — throws ArgumentError', () {
      check(
        () => validateVoiceRecordingDuration(const Duration(seconds: -1)),
      ).throws<ArgumentError>();
    });

    test('121 seconds — throws ArgumentError', () {
      check(
        () => validateVoiceRecordingDuration(const Duration(seconds: 121)),
      ).throws<ArgumentError>();
    });

    test('error message mentions the cap', () {
      expect(
        () => validateVoiceRecordingDuration(const Duration(seconds: 200)),
        throwsA(
          predicate<dynamic>((e) {
            if (e is ArgumentError) {
              return e.message.toString().contains('120');
            }
            return false;
          }),
        ),
      );
    });

    test('1 second is valid', () {
      validateVoiceRecordingDuration(const Duration(seconds: 1));
    });

    test('119 seconds is valid', () {
      validateVoiceRecordingDuration(const Duration(seconds: 119));
    });
  });

  // -----------------------------------------------------------------------
  // kMaxVoiceRecordingDurationSeconds constant
  // -----------------------------------------------------------------------
  group('kMaxVoiceRecordingDurationSeconds', () {
    test('equals 120', () {
      check(kMaxVoiceRecordingDurationSeconds).equals(120);
    });
  });

  // -----------------------------------------------------------------------
  // SimulationRecordingService
  // -----------------------------------------------------------------------
  group('SimulationRecordingService', () {
    group('constructor', () {
      test('implements RecordingServiceProtocol', () {
        check(_sim()).isA<RecordingServiceProtocol>();
      });

      test('starts with empty calls list', () {
        check(_sim().calls).isEmpty();
      });

      test('starts with empty createdPaths', () {
        check(_sim().createdPaths).isEmpty();
      });
    });

    group('recordForDuration — happy path (isSimulation: false)', () {
      test('records call in calls list', () async {
        final s = _sim();
        await s.recordForDuration(duration: const Duration(seconds: 5));
        check(s.calls).length.equals(1);
        check(s.calls.first.method).equals('recordForDuration');
      });

      test('records duration in call entry', () async {
        final s = _sim();
        await s.recordForDuration(duration: const Duration(seconds: 30));
        check(s.calls.first.duration).equals(const Duration(seconds: 30));
      });

      test('records fileName in call entry when provided', () async {
        final s = _sim();
        await s.recordForDuration(
          duration: const Duration(seconds: 10),
          fileName: 'my_clip',
        );
        check(s.calls.first.fileName).equals('my_clip');
      });

      test('fileName is null in call entry when not provided', () async {
        final s = _sim();
        await s.recordForDuration(duration: const Duration(seconds: 10));
        check(s.calls.first.fileName).isNull();
      });

      test('returns a non-null path', () async {
        final s = _sim();
        final path = await s.recordForDuration(
          duration: const Duration(seconds: 5),
        );
        check(path).isNotNull();
      });

      test('returned path ends with .m4a', () async {
        final s = _sim();
        final path = await s.recordForDuration(
          duration: const Duration(seconds: 5),
        );
        check(path!).endsWith('.m4a');
      });

      test('adds path to createdPaths', () async {
        final s = _sim();
        final path = await s.recordForDuration(
          duration: const Duration(seconds: 5),
        );
        check(s.createdPaths).contains(path!);
      });

      test('multiple calls accumulate in order', () async {
        final s = _sim();
        await s.recordForDuration(duration: const Duration(seconds: 5));
        await s.recordForDuration(duration: const Duration(seconds: 10));
        check(s.calls).length.equals(2);
        check(s.calls[0].duration).equals(const Duration(seconds: 5));
        check(s.calls[1].duration).equals(const Duration(seconds: 10));
      });
    });

    group('recordForDuration — isSimulation: true (Layer 3 guard)', () {
      test('returns null', () async {
        final s = _sim();
        final path = await s.recordForDuration(
          duration: const Duration(seconds: 10),
          isSimulation: true,
        );
        check(path).isNull();
      });

      test('still records the call in calls list', () async {
        final s = _sim();
        await s.recordForDuration(
          duration: const Duration(seconds: 10),
          isSimulation: true,
        );
        check(s.calls).length.equals(1);
        check(s.calls.first.isSimulation).isTrue();
      });

      test('does not add to createdPaths', () async {
        final s = _sim();
        await s.recordForDuration(
          duration: const Duration(seconds: 10),
          isSimulation: true,
        );
        check(s.createdPaths).isEmpty();
      });
    });

    group('startVoiceRecordingWithCap validation', () {
      test('zero duration throws ArgumentError', () async {
        final s = _sim();
        await check(
          s.startVoiceRecordingWithCap(maxDuration: Duration.zero),
        ).throws<ArgumentError>();
      });

      test('121-second duration throws ArgumentError', () async {
        final s = _sim();
        await check(
          s.startVoiceRecordingWithCap(
            maxDuration: const Duration(seconds: 121),
          ),
        ).throws<ArgumentError>();
      });

      test('validation throws even when isSimulation=true', () async {
        final s = _sim();
        await check(
          s.startVoiceRecordingWithCap(
            maxDuration: const Duration(seconds: 200),
            isSimulation: true,
          ),
        ).throws<ArgumentError>();
      });

      test(
        'valid 60-second duration succeeds when isSimulation=false',
        () async {
          final s = _sim();
          await s.startVoiceRecordingWithCap(
            maxDuration: const Duration(seconds: 60),
          );
          check(s.calls).length.equals(1);
        },
      );

      test(
        'valid 120-second duration with isSimulation=true returns null',
        () async {
          final s = _sim();
          final result = await s.startVoiceRecordingWithCap(
            maxDuration: const Duration(seconds: 120),
            isSimulation: true,
          );
          check(result).isNull();
        },
      );
    });

    group('reset', () {
      test('clears calls list', () async {
        final s = _sim();
        await s.recordForDuration(duration: const Duration(seconds: 5));
        s.reset();
        check(s.calls).isEmpty();
      });

      test('clears createdPaths', () async {
        final s = _sim();
        await s.recordForDuration(duration: const Duration(seconds: 5));
        s.reset();
        check(s.createdPaths).isEmpty();
      });
    });
  });
}
