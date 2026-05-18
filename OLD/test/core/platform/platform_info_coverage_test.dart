/// Coverage for [PlatformInfo] and [FakePlatformInfo].
///
/// Line 49 — the `FakePlatformInfo` constructor — is only instrumented when
/// called at runtime (i.e., non-const). The const calls below are resolved
/// at compile time and do not produce DA hits in lcov. The non-const
/// instantiation in 'non-const instantiation covers constructor line' ensures
/// the constructor body is reachable in the coverage data.
library;

import 'package:checks/checks.dart';
import 'package:test/test.dart';

import 'package:guardianangela/core/platform/platform_info.dart';

void main() {
  group('FakePlatformInfo', () {
    test('defaults to isAndroid=false and isIOS=false', () {
      const p = FakePlatformInfo();
      check(p.isAndroid).isFalse();
      check(p.isIOS).isFalse();
    });

    test('isIOS=true is readable', () {
      const p = FakePlatformInfo(isIOS: true);
      check(p.isIOS).isTrue();
      check(p.isAndroid).isFalse();
    });

    test('isAndroid=true is readable', () {
      const p = FakePlatformInfo(isAndroid: true);
      check(p.isAndroid).isTrue();
      check(p.isIOS).isFalse();
    });

    test('non-const instantiation covers constructor line', () {
      // ignore: prefer_const_constructors
      final p = FakePlatformInfo(isAndroid: true, isIOS: false);
      check(p.isAndroid).isTrue();
      check(p.isIOS).isFalse();
    });
  });
}
