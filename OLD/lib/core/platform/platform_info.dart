/// Dependency-injection seam for platform detection.
///
/// Services previously branched on `dart:io` `Platform.isAndroid` /
/// `Platform.isIOS` directly, which made the Android-only branches
/// unreachable from a Linux test host (so `flutter test --coverage`
/// reported those lines as uncovered). Code now accepts a
/// [PlatformInfo] instance; production resolves via the const default
/// [PlatformInfo()] (which reads `dart:io`), tests inject a
/// [FakePlatformInfo].
library;

import 'dart:io' show Platform;

/// Abstraction over host-platform detection.
///
/// Construct the real implementation via the const factory
/// `const PlatformInfo()`; for tests, inject a [FakePlatformInfo].
abstract class PlatformInfo {
  /// Returns the real `dart:io`-backed implementation.
  const factory PlatformInfo() = _RealPlatformInfo;

  /// Whether the current host is Android.
  bool get isAndroid;

  /// Whether the current host is iOS.
  bool get isIOS;
}

/// Real implementation delegating to `dart:io` [Platform].
final class _RealPlatformInfo implements PlatformInfo {
  const _RealPlatformInfo();

  @override
  bool get isAndroid => Platform.isAndroid;

  @override
  bool get isIOS => Platform.isIOS;
}

/// Test double for [PlatformInfo].
///
/// Both flags default to `false` so a bare `FakePlatformInfo()`
/// represents "neither Android nor iOS" (i.e., what a Linux host
/// looks like from the app's point of view).
final class FakePlatformInfo implements PlatformInfo {
  /// Creates a fake platform descriptor.
  ///
  /// The [isAndroid] and [isIOS] fields default to `false`.
  const FakePlatformInfo({this.isAndroid = false, this.isIOS = false});

  @override
  final bool isAndroid;

  @override
  final bool isIOS;
}
