import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';

import 'package:guardianangela/data/repositories/contacts_repository.dart';
import 'package:guardianangela/domain/models/emergency_contact.dart';
import 'package:guardianangela/domain/models/session_mode.dart';
import 'package:guardianangela/services/service_providers.dart';

/// Immutable state for the home screen.
@immutable
class HomeState {
  /// Creates a [HomeState].
  const HomeState({
    required this.modes,
    required this.contacts,
    required this.selectedModeId,
  });

  /// All non-distress modes available to the user.
  final List<SessionMode> modes;

  /// All emergency contacts in display order.
  final List<EmergencyContact> contacts;

  /// Id of the currently selected mode, or null when nothing selected.
  final String? selectedModeId;

  /// Returns a copy with the listed fields replaced.
  HomeState copyWith({
    List<SessionMode>? modes,
    List<EmergencyContact>? contacts,
    String? selectedModeId,
    bool clearSelection = false,
  }) => HomeState(
    modes: modes ?? this.modes,
    contacts: contacts ?? this.contacts,
    selectedModeId: clearSelection
        ? null
        : (selectedModeId ?? this.selectedModeId),
  );
}

/// Riverpod controller for the home screen.
///
/// Loads regular modes + contacts from the database, tracks the
/// selected mode, and handles session start (Real / Simulation).
class HomeController extends AsyncNotifier<HomeState> {
  @override
  Future<HomeState> build() async {
    final db = await ref.watch(databaseProvider.future);
    final modes = await db.sessionModesDao.getRegularModes();
    final contacts = await ContactsRepository(db.contactsDao).getAll();
    final settings = await ref.read(appSettingsRepositoryProvider).load();
    final selected =
        settings.selectedModeId ?? (modes.isNotEmpty ? modes.first.id : null);
    return HomeState(
      modes: modes,
      contacts: contacts,
      selectedModeId: selected,
    );
  }

  /// Selects [modeId] and persists it as the next-start default.
  Future<void> selectMode(String modeId) async {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(selectedModeId: modeId));
    final repo = ref.read(appSettingsRepositoryProvider);
    final settings = await repo.load();
    await repo.save(settings.copyWith(selectedModeId: modeId));
  }

  /// Starts a session. Returns true if the navigation should proceed.
  ///
  /// For now, the real session orchestration is owned by `SessionController`
  /// (Phase 7); this method only validates that a mode is selected.
  Future<bool> startSession({required bool simulate}) async {
    final current = state.value;
    if (current == null) return false;
    return current.selectedModeId != null;
  }
}

/// Provides [HomeController].
final homeControllerProvider = AsyncNotifierProvider<HomeController, HomeState>(
  HomeController.new,
);
