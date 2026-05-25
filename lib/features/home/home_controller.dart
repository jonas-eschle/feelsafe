import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';

import 'package:guardianangela/data/repositories/contacts_repository.dart';
import 'package:guardianangela/domain/enums/app_permission.dart';
import 'package:guardianangela/domain/models/emergency_contact.dart';
import 'package:guardianangela/domain/models/session_mode.dart';
import 'package:guardianangela/domain/models/validation_result.dart';
import 'package:guardianangela/features/session/session_controller.dart';
import 'package:guardianangela/services/service_providers.dart';
import 'package:guardianangela/services/session_start_validator.dart';

/// Immutable state for the home screen.
@immutable
class HomeState {
  /// Creates a [HomeState].
  const HomeState({
    required this.modes,
    required this.contacts,
    required this.selectedModeId,
    this.lastValidationErrors = const <ValidationIssue>[],
  });

  /// All non-distress modes available to the user.
  final List<SessionMode> modes;

  /// All emergency contacts in display order.
  final List<EmergencyContact> contacts;

  /// Id of the currently selected mode, or null when nothing selected.
  final String? selectedModeId;

  /// Errors from the most recent failed start attempt (for the dialog).
  final List<ValidationIssue> lastValidationErrors;

  /// Returns a copy with the listed fields replaced.
  HomeState copyWith({
    List<SessionMode>? modes,
    List<EmergencyContact>? contacts,
    String? selectedModeId,
    bool clearSelection = false,
    List<ValidationIssue>? lastValidationErrors,
  }) => HomeState(
    modes: modes ?? this.modes,
    contacts: contacts ?? this.contacts,
    selectedModeId: clearSelection
        ? null
        : (selectedModeId ?? this.selectedModeId),
    lastValidationErrors: lastValidationErrors ?? this.lastValidationErrors,
  );
}

/// Riverpod controller for the home screen.
///
/// Loads regular modes + contacts from the database, tracks the
/// selected mode, and orchestrates session start (Real / Simulation).
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

  /// Clears errors after the dialog has been dismissed.
  void clearValidationErrors() {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(lastValidationErrors: const []));
  }

  /// Starts a session.
  ///
  /// Runs pre-flight validation via [SessionStartValidator]:
  /// - For simulation sessions, errors are downgraded to warnings — the
  ///   pre-flight is lenient per spec 04 §Start Session Button.
  /// - For real sessions, any error blocks the start and the issues are
  ///   surfaced on [HomeState.lastValidationErrors] so the screen can
  ///   render the issues dialog.
  ///
  /// Returns true if the controller successfully kicked off the session
  /// and the screen should navigate to `/session`.
  Future<bool> startSession({required bool simulate}) async {
    final current = state.value;
    if (current == null) return false;
    final selectedId = current.selectedModeId;
    if (selectedId == null) return false;
    final db = await ref.read(databaseProvider.future);
    final mode = await db.sessionModesDao.getById(selectedId);
    if (mode == null) {
      return false;
    }
    final validator = ref.read(sessionStartValidatorProvider);
    if (validator is RealSessionStartValidator) {
      try {
        await validator.updateCachedState(
          contactCount: current.contacts.length,
          emergencyNumber: '112',
          requiredPermissions: AppPermission.values.toSet(),
        );
        await validator.prewarm();
      } catch (e) {
        log('validator pre-warm failed: $e', name: 'HomeController');
      }
    }
    final result = validator.validate(mode);
    if (!simulate && result.errors.isNotEmpty) {
      state = AsyncData(current.copyWith(lastValidationErrors: result.errors));
      return false;
    }
    // Resolve distress mode (mode-local id first, then global default).
    final settings = await ref.read(appSettingsRepositoryProvider).load();
    final distressId =
        mode.distressModeId ?? settings.defaults.defaultDistressModeId;
    final distressMode = distressId == null
        ? null
        : await db.sessionModesDao.getById(distressId);
    await ref
        .read(sessionControllerProvider.notifier)
        .startSession(
          mode: mode,
          simulate: simulate,
          distressMode: distressMode,
        );
    return true;
  }
}

/// Provides [HomeController].
final homeControllerProvider = AsyncNotifierProvider<HomeController, HomeState>(
  HomeController.new,
);
