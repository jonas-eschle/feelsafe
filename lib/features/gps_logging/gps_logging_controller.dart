import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';

import 'package:guardianangela/domain/enums/gps_accuracy.dart';
import 'package:guardianangela/domain/models/gps_logging_config.dart';
import 'package:guardianangela/services/service_providers.dart';

/// Immutable state for the GPS logging screen.
@immutable
class GpsLoggingState {
  /// Creates a [GpsLoggingState].
  const GpsLoggingState({required this.config});

  /// Current global GPS logging config.
  final GpsLoggingConfig config;
}

/// Controller for the GPS logging settings.
class GpsLoggingController extends AsyncNotifier<GpsLoggingState> {
  @override
  Future<GpsLoggingState> build() async {
    final settings = await ref.read(appSettingsRepositoryProvider).load();
    return GpsLoggingState(config: settings.defaults.gpsLogging);
  }

  Future<void> _save(GpsLoggingConfig cfg) async {
    final repo = ref.read(appSettingsRepositoryProvider);
    final settings = await repo.load();
    await repo.save(
      settings.copyWith(defaults: settings.defaults.copyWith(gpsLogging: cfg)),
    );
    ref.invalidateSelf();
  }

  /// Toggle the master enabled flag.
  Future<void> setEnabled(bool v) async {
    final current = state.value;
    if (current == null) return;
    await _save(current.config.copyWith(enabled: v));
  }

  /// Update interval seconds.
  Future<void> setInterval(int seconds) async {
    final current = state.value;
    if (current == null) return;
    await _save(current.config.copyWith(intervalSeconds: seconds));
  }

  /// Update accuracy.
  Future<void> setAccuracy(GpsAccuracy a) async {
    final current = state.value;
    if (current == null) return;
    await _save(current.config.copyWith(accuracy: a));
  }
}

/// Provides [GpsLoggingController].
final gpsLoggingControllerProvider =
    AsyncNotifierProvider<GpsLoggingController, GpsLoggingState>(
      GpsLoggingController.new,
    );
