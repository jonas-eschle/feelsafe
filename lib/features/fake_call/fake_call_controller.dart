/// Fake-call feature controller stub.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Stub AsyncNotifier for the fake-call overlay.
class FakeCallController extends AsyncNotifier<Object?> {
  @override
  Future<Object?> build() async => null;
}

/// Provider for `FakeCallController`.
final AsyncNotifierProvider<FakeCallController, Object?>
    fakeCallControllerProvider =
    AsyncNotifierProvider<FakeCallController, Object?>(
  FakeCallController.new,
);
