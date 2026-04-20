/// Fake-call feature controller.
///
/// Thin wrapper around [sessionControllerProvider] that exposes the
/// three fake-call actions as typed methods. UI layers use this
/// instead of touching the session controller directly.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:guardianangela/features/session/session_controller.dart';

/// Async controller for the fake-call overlay.
///
/// State is `Object?` today; a future revision may expose an
/// immutable snapshot (caller name, ringtone state). For now the
/// overlay reads everything it needs from
/// [sessionControllerProvider] directly.
class FakeCallController extends AsyncNotifier<Object?> {
  @override
  Future<Object?> build() async => null;

  /// Answers the currently-ringing fake call.
  Future<void> answer() =>
      ref.read(sessionControllerProvider.notifier).answerFakeCall();

  /// Hangs up an in-progress fake call.
  Future<void> hangUp() =>
      ref.read(sessionControllerProvider.notifier).hangUp();

  /// Declines the ringing fake call.
  Future<void> decline() =>
      ref.read(sessionControllerProvider.notifier).declineFakeCall();
}

/// Provider for `FakeCallController`.
final AsyncNotifierProvider<FakeCallController, Object?>
    fakeCallControllerProvider =
    AsyncNotifierProvider<FakeCallController, Object?>(
  FakeCallController.new,
);
