/// Contract tests for [FlashServiceProtocol] — exercised against
/// every implementation (fake + simulation + real with injected
/// torch callbacks). These pin down strobe state, idempotent stop,
/// and toggle semantics.
library;

import 'dart:async';

import 'package:checks/checks.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/services/fakes/fake_flash_service.dart';
import 'package:guardianangela/services/implementations/flash_service.dart';
import 'package:guardianangela/services/protocols/flash_service_protocol.dart';
import 'package:guardianangela/services/simulation/simulation_flash_service.dart';

void main() {
  group('FlashServiceProtocol contract', () {
    for (final entry in <(String, FlashServiceProtocol Function())>[
      ('FakeFlashService', FakeFlashService.new),
      ('SimulationFlashService', SimulationFlashService.new),
    ]) {
      final (label, factory) = entry;

      test('$label: starts not strobing', () async {
        final svc = factory();
        check(svc.isStrobing).isFalse();
      });

      test('$label: start sets isStrobing, stop clears it', () async {
        final svc = factory();
        await svc.startStrobe(interval: const Duration(milliseconds: 200));
        check(svc.isStrobing).isTrue();
        await svc.stopStrobe();
        check(svc.isStrobing).isFalse();
      });

      test('$label: stopStrobe idempotent when idle', () async {
        final svc = factory();
        await svc.stopStrobe();
        await svc.stopStrobe();
        check(svc.isStrobing).isFalse();
      });

      test('$label: default interval matches the constant', () async {
        final svc = factory();
        await svc.startStrobe();
        check(svc.isStrobing).isTrue();
        await svc.stopStrobe();
        // The constant lives on the protocol — not directly observable
        // through the contract but exercised here as a documentation
        // anchor.
        check(kDefaultFlashStrobeInterval.inMilliseconds).equals(500);
      });
    }
  });

  group('FakeFlashService invocation log', () {
    test('records start interval and stop', () async {
      final svc = FakeFlashService();
      await svc.startStrobe(interval: const Duration(milliseconds: 250));
      await svc.stopStrobe();
      check(svc.calls).deepEquals(['startStrobe:250', 'stopStrobe']);
    });
  });

  group('FlashService (real impl with injected torch callbacks)', () {
    test('strobe toggles torch on then off across half-cycles', () {
      fakeAsync((async) {
        final events = <String>[];
        final svc = FlashService(
          enableTorch: () async => events.add('on'),
          disableTorch: () async => events.add('off'),
        );
        unawaited(svc.startStrobe(interval: const Duration(milliseconds: 100)));
        async.elapse(const Duration(milliseconds: 250));
        check(events.length).isGreaterOrEqual(3);
        check(events.first).equals('on');
        check(svc.isStrobing).isTrue();
        unawaited(svc.stopStrobe());
        async.flushMicrotasks();
        check(svc.isStrobing).isFalse();
      });
    });

    test('startStrobe rejects sub-microsecond intervals', () async {
      final svc = FlashService(
        enableTorch: () async {},
        disableTorch: () async {},
      );
      await check(
        svc.startStrobe(interval: Duration.zero),
      ).throws<ArgumentError>();
    });

    test('startStrobe rebases an in-flight strobe', () {
      fakeAsync((async) {
        final events = <String>[];
        final svc = FlashService(
          enableTorch: () async => events.add('on'),
          disableTorch: () async => events.add('off'),
        );
        unawaited(svc.startStrobe(interval: const Duration(milliseconds: 200)));
        async.elapse(const Duration(milliseconds: 150));
        unawaited(svc.startStrobe(interval: const Duration(milliseconds: 100)));
        async.elapse(const Duration(milliseconds: 200));
        check(svc.isStrobing).isTrue();
        unawaited(svc.stopStrobe());
        async.flushMicrotasks();
      });
    });

    test('plugin exception stops the strobe gracefully', () {
      fakeAsync((async) {
        final svc = FlashService(
          enableTorch: () async => throw Exception('no torch'),
          disableTorch: () async {},
        );
        unawaited(svc.startStrobe(interval: const Duration(milliseconds: 100)));
        async.elapse(const Duration(milliseconds: 150));
        check(svc.isStrobing).isFalse();
      });
    });
  });
}
