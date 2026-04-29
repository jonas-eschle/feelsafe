/// Coverage test for [service_providers.dart] — exercises the
/// `biometricServiceProvider` factory (line 104: `(_) => BiometricService()`).
///
/// The existing service_providers_test.dart omits `biometricServiceProvider`
/// from its provider-construction smoke test, leaving that line uncovered.
library;

import 'package:checks/checks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/services/service_providers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('service_providers biometricServiceProvider', () {
    test(
      'biometricServiceProvider constructs a BiometricServiceProtocol instance',
      () {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        // Reading the provider triggers the factory `(_) => BiometricService()`.
        // ignore: unused_local_variable
        final service = container.read(biometricServiceProvider);
        check(service).isNotNull();
      },
    );
  });
}
