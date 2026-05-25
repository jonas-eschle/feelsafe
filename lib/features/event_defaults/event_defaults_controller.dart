import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';

import 'package:guardianangela/domain/models/event_defaults.dart';
import 'package:guardianangela/services/service_providers.dart';

/// Immutable state for the event defaults screen.
@immutable
class EventDefaultsState {
  /// Creates an [EventDefaultsState].
  const EventDefaultsState({required this.defaults});

  /// Current global event defaults.
  final EventDefaults defaults;
}

/// Controller for the event defaults screen.
class EventDefaultsController extends AsyncNotifier<EventDefaultsState> {
  @override
  Future<EventDefaultsState> build() async {
    final settings = await ref.read(appSettingsRepositoryProvider).load();
    return EventDefaultsState(defaults: settings.defaults.eventDefaults);
  }

  /// Persists [updated] to the app settings.
  Future<void> save(EventDefaults updated) async {
    final repo = ref.read(appSettingsRepositoryProvider);
    final settings = await repo.load();
    await repo.save(
      settings.copyWith(
        defaults: settings.defaults.copyWith(eventDefaults: updated),
      ),
    );
    ref.invalidateSelf();
  }
}

/// Provides [EventDefaultsController].
final eventDefaultsControllerProvider =
    AsyncNotifierProvider<EventDefaultsController, EventDefaultsState>(
      EventDefaultsController.new,
    );
