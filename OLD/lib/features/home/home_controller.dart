/// Home-feature controller.
///
/// Aggregates read-only view-state for the home screen (selected
/// mode id, active session, contact/mode counts). Does not mutate
/// any other controller; it is a pure presentation accessor.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:guardianangela/domain/models/models.dart';
import 'package:guardianangela/features/contacts/contacts_controller.dart';
import 'package:guardianangela/features/modes/modes_controller.dart';
import 'package:guardianangela/features/session/session_controller.dart';
import 'package:guardianangela/features/settings/settings_controller.dart';

/// Immutable snapshot of the home-screen view state.
final class HomeState {
  /// Creates a home state.
  ///
  /// [modes] — all available modes.
  /// [contacts] — all emergency contacts.
  /// [selectedModeId] — currently selected mode id, or null.
  /// [activeSession] — currently-running session, or null.
  /// [isFirstLaunch] — true until onboarding is complete.
  const HomeState({
    this.modes = const [],
    this.contacts = const [],
    this.selectedModeId,
    this.activeSession,
    this.isFirstLaunch = false,
  });

  /// Available modes.
  final List<SessionMode> modes;

  /// Emergency contacts.
  final List<EmergencyContact> contacts;

  /// Currently selected mode id.
  final String? selectedModeId;

  /// Active session, or null if none is running.
  final WalkSession? activeSession;

  /// Whether the user still needs to complete onboarding.
  final bool isFirstLaunch;

  /// Returns the [SessionMode] matching [selectedModeId], or the
  /// first mode when no selection is set.
  SessionMode? get selectedMode {
    final id = selectedModeId;
    if (id != null) {
      for (final m in modes) {
        if (m.id == id) return m;
      }
    }
    return modes.isEmpty ? null : modes.first;
  }
}

/// Async controller aggregating home-screen view state.
class HomeController extends AsyncNotifier<HomeState> {
  @override
  Future<HomeState> build() async {
    final settings = await ref.watch(settingsControllerProvider.future);
    final modes = await ref.watch(modesControllerProvider.future);
    final contacts = await ref.watch(contactsControllerProvider.future);
    final session = ref.watch(sessionControllerProvider).value;
    return HomeState(
      modes: modes,
      contacts: contacts,
      selectedModeId: settings.selectedModeId,
      activeSession: session,
      isFirstLaunch: settings.isFirstLaunch,
    );
  }
}

/// Provider for `HomeController`.
final AsyncNotifierProvider<HomeController, HomeState> homeControllerProvider =
    AsyncNotifierProvider<HomeController, HomeState>(HomeController.new);
