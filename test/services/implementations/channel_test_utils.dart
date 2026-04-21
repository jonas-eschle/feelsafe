/// Test utilities for mocking MethodChannels and EventChannels.
///
/// Callers install a handler and receive the list of received
/// invocations, then uninstall in `addTearDown`. Reusable across
/// every service_test file.
library;

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Installs a mock handler for [channel] and returns the list of
/// received method calls. Optionally returns a value from [responder]
/// for specific methods, or throws if [responder] throws.
List<MethodCall> installMethodChannelMock(
  MethodChannel channel, {
  Object? Function(MethodCall call)? responder,
}) {
  final calls = <MethodCall>[];
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (call) async {
    calls.add(call);
    if (responder == null) return null;
    return responder(call);
  });
  addTearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });
  return calls;
}

/// Installs a handler that throws [MissingPluginException] for every
/// method invoked on [channel].
List<MethodCall> installMissingPluginMock(MethodChannel channel) {
  return installMethodChannelMock(
    channel,
    responder: (call) {
      throw MissingPluginException('no mock for ${call.method}');
    },
  );
}

/// Installs a handler that throws [PlatformException] for every
/// method invoked on [channel].
List<MethodCall> installPlatformErrorMock(MethodChannel channel) {
  return installMethodChannelMock(
    channel,
    responder: (call) {
      throw PlatformException(
        code: 'ERR',
        message: 'simulated platform error',
      );
    },
  );
}

/// Mock backend for an EventChannel. Callers publish events via
/// [push]; listeners installed on the matching Dart side receive
/// them. Returns a function to uninstall (auto-installed in
/// `addTearDown`).
EventChannelMock installEventChannelMock(EventChannel channel) {
  final mock = EventChannelMock._(channel);
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    MethodChannel(channel.name, channel.codec),
    (MethodCall call) async => mock._onMethodCall(call),
  );
  addTearDown(mock._tearDown);
  return mock;
}

/// Mock backend for an [EventChannel]. Use [push] to inject events
/// and [pushError] to inject a native error.
class EventChannelMock {
  EventChannelMock._(this._channel);

  final EventChannel _channel;
  bool _listening = false;

  Object? _onMethodCall(MethodCall call) {
    if (call.method == 'listen') {
      _listening = true;
    } else if (call.method == 'cancel') {
      _listening = false;
    }
    return null;
  }

  /// Pushes an event to any currently listening Dart side. Returns
  /// whether a listener is currently attached.
  Future<bool> push(Object? event) async {
    if (!_listening) return false;
    final data = _channel.codec.encodeSuccessEnvelope(event);
    final completer = Completer<void>();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .handlePlatformMessage(
      _channel.name,
      data,
      (_) => completer.complete(),
    );
    await completer.future;
    return true;
  }

  void _tearDown() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      MethodChannel(_channel.name, _channel.codec),
      null,
    );
  }
}
