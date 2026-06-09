// Host tests for the production [RealCallStateService] (C6 coverage push).
//
// RealCallStateService subscribes to the native EventChannel
// `com.guardianangela.app/call_state` and parses each delivered string into a
// typed [CallState]. The simulation counterpart (covered by
// call_state_service_test.dart) bypasses the native channel via setState; this
// file drives the REAL channel through TestDefaultBinaryMessenger so the
// genuine _onNativeEvent dispatch + _parseCallState string→enum switch runs —
// including the malformed-event branches that feed the engine pause/resume
// path (device-proven in M5 C4 via real telephony).

import 'package:flutter/services.dart';

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/domain/enums/call_state.dart';
import 'package:guardianangela/services/call_state_service.dart';
import 'package:guardianangela/services/protocols/call_state_service_protocol.dart';

// ---------------------------------------------------------------------------
// Channel-driving harness
// ---------------------------------------------------------------------------

const String _kChannelName = 'com.guardianangela.app/call_state';

/// Drives the native call-state channel that [RealCallStateService] listens on.
///
/// Registers a method-call handler so the service's `startListening` /
/// `stopListening` invocations (and the EventChannel `listen`/`cancel`
/// handshake) resolve cleanly, and pushes raw native events to the
/// `receiveBroadcastStream()` listener via a StandardMethodCodec success
/// envelope (the same delivery the real `CallStateChannel.kt` produces).
class _CallStateChannelMock {
  final List<String> methodCalls = [];

  /// When `true`, `startListening`/`stopListening` throw to exercise the
  /// service's swallow-and-log catch branches.
  bool throwOnMethod = false;

  void register() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel(_kChannelName), (
          call,
        ) async {
          methodCalls.add(call.method);
          if (throwOnMethod &&
              (call.method == 'startListening' ||
                  call.method == 'stopListening')) {
            throw PlatformException(code: 'boom');
          }
          return null;
        });
  }

  void unregister() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel(_kChannelName), null);
  }

  /// Pushes a single native event string onto the EventChannel stream.
  Future<void> fire(Object? event) async {
    await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .handlePlatformMessage(
          _kChannelName,
          const StandardMethodCodec().encodeSuccessEnvelope(event),
          (_) {},
        );
  }

  /// Pushes a platform error onto the EventChannel stream (→ stream onError).
  Future<void> fireError() async {
    await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .handlePlatformMessage(
          _kChannelName,
          const StandardMethodCodec().encodeErrorEnvelope(
            code: 'NATIVE_ERR',
            message: 'telephony listener failed',
          ),
          (_) {},
        );
  }

  /// Sends an end-of-stream signal (a null reply closes the stream → onDone).
  Future<void> fireEndOfStream() async {
    await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .handlePlatformMessage(_kChannelName, null, (_) {});
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RealCallStateService', () {
    late _CallStateChannelMock channel;
    late RealCallStateService svc;

    setUp(() {
      channel = _CallStateChannelMock()..register();
      svc = RealCallStateService();
    });

    tearDown(() async {
      await svc.stop();
      channel.unregister();
    });

    test('implements CallStateServiceProtocol', () {
      check(svc).isA<CallStateServiceProtocol>();
    });

    test('callState is a broadcast stream (multiple listeners allowed)', () {
      final sub1 = svc.callState.listen((_) {});
      final sub2 = svc.callState.listen((_) {});
      addTearDown(sub1.cancel);
      addTearDown(sub2.cancel);
      // No StateError on the second listen confirms a broadcast stream.
    });

    test('start invokes startListening on the native MethodChannel', () async {
      await svc.start();
      check(channel.methodCalls).contains('startListening');
    });

    test(
      'start while already listening is a no-op (no second subscribe)',
      () async {
        await svc.start();
        channel.methodCalls.clear();
        await svc.start();
        check(channel.methodCalls).not((c) => c.contains('startListening'));
      },
    );

    test('native "ringing" parses to CallState.ringing', () async {
      await svc.start();
      final events = <CallState>[];
      final sub = svc.callState.listen(events.add);
      addTearDown(sub.cancel);

      await channel.fire('ringing');
      await Future<void>.delayed(Duration.zero);

      check(events).deepEquals([CallState.ringing]);
    });

    test('native "offhook" parses to CallState.offhook', () async {
      await svc.start();
      final events = <CallState>[];
      final sub = svc.callState.listen(events.add);
      addTearDown(sub.cancel);

      await channel.fire('offhook');
      await Future<void>.delayed(Duration.zero);

      check(events).deepEquals([CallState.offhook]);
    });

    test('native "idle" parses to CallState.idle', () async {
      await svc.start();
      final events = <CallState>[];
      final sub = svc.callState.listen(events.add);
      addTearDown(sub.cancel);

      await channel.fire('idle');
      await Future<void>.delayed(Duration.zero);

      check(events).deepEquals([CallState.idle]);
    });

    test(
      'a full ringing→offhook→idle transition is delivered in order',
      () async {
        await svc.start();
        final events = <CallState>[];
        final sub = svc.callState.listen(events.add);
        addTearDown(sub.cancel);

        await channel.fire('ringing');
        await channel.fire('offhook');
        await channel.fire('idle');
        await Future<void>.delayed(Duration.zero);

        check(
          events,
        ).deepEquals([CallState.ringing, CallState.offhook, CallState.idle]);
      },
    );

    test('an unknown state string is dropped (no event, no throw)', () async {
      await svc.start();
      final events = <CallState>[];
      final sub = svc.callState.listen(events.add);
      addTearDown(sub.cancel);

      await channel.fire('busy'); // not in the parse switch
      await Future<void>.delayed(Duration.zero);

      check(events).isEmpty();
    });

    test('a non-String native event is dropped (no event, no throw)', () async {
      await svc.start();
      final events = <CallState>[];
      final sub = svc.callState.listen(events.add);
      addTearDown(sub.cancel);

      await channel.fire(42); // wrong type — guarded by `event is! String`
      await Future<void>.delayed(Duration.zero);

      check(events).isEmpty();
    });

    test('a valid event after a dropped one still parses', () async {
      await svc.start();
      final events = <CallState>[];
      final sub = svc.callState.listen(events.add);
      addTearDown(sub.cancel);

      await channel.fire('garbage');
      await channel.fire('ringing');
      await Future<void>.delayed(Duration.zero);

      check(events).deepEquals([CallState.ringing]);
    });

    test('stop invokes stopListening and ends event delivery', () async {
      await svc.start();
      final events = <CallState>[];
      final sub = svc.callState.listen(events.add);
      addTearDown(sub.cancel);

      await svc.stop();
      check(channel.methodCalls).contains('stopListening');

      await channel.fire('ringing');
      await Future<void>.delayed(Duration.zero);
      check(events).isEmpty();
    });

    test('stop before start is safe (no throw)', () async {
      await svc.stop();
      check(channel.methodCalls).contains('stopListening');
    });

    test('restart after stop resumes parsing', () async {
      await svc.start();
      await svc.stop();
      await svc.start();

      final events = <CallState>[];
      final sub = svc.callState.listen(events.add);
      addTearDown(sub.cancel);

      await channel.fire('ringing');
      await Future<void>.delayed(Duration.zero);
      check(events).deepEquals([CallState.ringing]);
    });

    test('a native stream error is absorbed (logged, not rethrown)', () async {
      await svc.start();
      final events = <CallState>[];
      final sub = svc.callState.listen(events.add);
      addTearDown(sub.cancel);

      // The service's onError handler logs and swallows; a subsequent valid
      // event must still be parsed (the subscription survives the error).
      await channel.fireError();
      await channel.fire('ringing');
      await Future<void>.delayed(Duration.zero);

      check(events).deepEquals([CallState.ringing]);
    });

    test('an end-of-stream signal is handled (onDone, no throw)', () async {
      await svc.start();
      final events = <CallState>[];
      final sub = svc.callState.listen(events.add);
      addTearDown(sub.cancel);

      await channel.fireEndOfStream();
      await Future<void>.delayed(Duration.zero);
      // Closing the native stream must not surface any spurious CallState.
      check(events).isEmpty();
    });

    test('start swallows a native MethodChannel error', () async {
      channel.throwOnMethod = true;
      // startListening throws on the native side; start() must not rethrow.
      await svc.start();
      check(channel.methodCalls).contains('startListening');
    });

    test('stop swallows a native MethodChannel error', () async {
      channel.throwOnMethod = true;
      await svc.stop();
      check(channel.methodCalls).contains('stopListening');
    });
  });
}
