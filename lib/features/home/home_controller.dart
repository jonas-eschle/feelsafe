/// Home-feature controller stub.
///
/// Phase 12 will hook this up to the active session providers and
/// the mode list, driving the real start-session UI.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Stub AsyncNotifier for the home screen.
///
/// State is `Object?` as a deliberate TODO placeholder until the
/// real view-model is defined.
class HomeController extends AsyncNotifier<Object?> {
  @override
  Future<Object?> build() async => null;
}

/// Provider for `HomeController`.
final AsyncNotifierProvider<HomeController, Object?>
    homeControllerProvider =
    AsyncNotifierProvider<HomeController, Object?>(HomeController.new);
