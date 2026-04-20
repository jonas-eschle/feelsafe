/// Real stealth-icon-service implementation.
///
/// Dart-side only. Android uses a method channel
/// (`com.guardianangela.app/stealth_icon`) to swap between
/// activity-aliases (one per preset). iOS does not support runtime
/// launcher-icon swaps without `UIApplication.setAlternateIconName` —
/// for Guardian Angela's v1 we treat it as a no-op and persist the
/// last requested preset so the UI still reflects the user's choice.
/// Phase 10 writes the native Android backend (and, optionally, the
/// iOS setAlternateIconName path).
library;

import 'dart:developer' as developer;
import 'dart:io' show Platform;

import 'package:flutter/services.dart';

import 'package:guardianangela/domain/models/stealth_config.dart';
import 'package:guardianangela/services/protocols/stealth_icon_service_protocol.dart';

/// Real platform-backed implementation of
/// [StealthIconServiceProtocol].
final class StealthIconService implements StealthIconServiceProtocol {
  /// Creates the real stealth-icon service.
  StealthIconService();

  static const MethodChannel _channel = MethodChannel(
    'com.guardianangela.app/stealth_icon',
  );

  /// In-memory fallback for iOS / when native side is not wired.
  StealthIconPreset _cachedPreset = StealthIconPreset.calendar;

  @override
  Future<void> setPreset(StealthIconPreset preset) async {
    _cachedPreset = preset;
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod<void>('setPreset', {'preset': preset.name});
    } on MissingPluginException {
      return Future.error('Not wired — Phase 10');
    } on PlatformException catch (e, s) {
      developer.log(
        'stealth_icon.setPreset platform error',
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }

  @override
  Future<StealthIconPreset> getCurrentPreset() async {
    if (!Platform.isAndroid) return _cachedPreset;
    try {
      final raw = await _channel.invokeMethod<String>('getCurrentPreset');
      if (raw == null) return _cachedPreset;
      return _presetFromString(raw) ?? _cachedPreset;
    } on MissingPluginException {
      return _cachedPreset;
    } on PlatformException catch (e, s) {
      developer.log(
        'stealth_icon.getCurrentPreset platform error',
        error: e,
        stackTrace: s,
      );
      return _cachedPreset;
    }
  }

  StealthIconPreset? _presetFromString(String raw) => switch (raw) {
    'music' => StealthIconPreset.music,
    'calendar' => StealthIconPreset.calendar,
    'fitness' => StealthIconPreset.fitness,
    'weather' => StealthIconPreset.weather,
    'news' => StealthIconPreset.news,
    'photos' => StealthIconPreset.photos,
    'notes' => StealthIconPreset.notes,
    'clock' => StealthIconPreset.clock,
    _ => null,
  };
}
