import 'dart:convert' show utf8;

import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';

import 'package:guardianangela/domain/models/session_log.dart';
import 'package:guardianangela/services/service_providers.dart';

/// Immutable state for [SimulationSummaryController].
@immutable
class SimulationSummaryState {
  /// Creates a [SimulationSummaryState].
  const SimulationSummaryState({
    required this.log,
    required this.pinRequired,
    required this.pinUnlocked,
    this.pinError = false,
  });

  /// The session log being summarised; null while loading.
  final SessionLog? log;

  /// Whether a PIN prompt must be shown before revealing the summary.
  final bool pinRequired;

  /// Whether the summary is currently visible (PIN passed or skipped).
  final bool pinUnlocked;

  /// True after a wrong-PIN entry — triggers the shake animation in
  /// the UI.
  final bool pinError;

  /// Returns a copy of this state with the given fields replaced.
  SimulationSummaryState copyWith({
    SessionLog? log,
    bool? pinRequired,
    bool? pinUnlocked,
    bool? pinError,
  }) => SimulationSummaryState(
    log: log ?? this.log,
    pinRequired: pinRequired ?? this.pinRequired,
    pinUnlocked: pinUnlocked ?? this.pinUnlocked,
    pinError: pinError ?? this.pinError,
  );

  /// Returns the number of `missed` events in the log.
  int get missedCount =>
      log?.events.where((e) => e.eventType == 'missed').length ?? 0;

  /// Returns the number of distress events in the log.
  int get distressCount =>
      log?.events
          .where(
            (e) =>
                e.eventType == 'step_fired' &&
                e.description.contains('distress'),
          )
          .length ??
      0;

  /// Returns the total number of `step_fired` events.
  int get stepsFiredCount =>
      log?.events.where((e) => e.eventType == 'step_fired').length ?? 0;

  /// Total session duration in seconds.
  ///
  /// Returns 0 when the log lacks an `endedAt` timestamp.
  int get durationSeconds {
    final l = log;
    if (l == null) return 0;
    final end = l.endedAt ?? DateTime.now().toUtc();
    return end.difference(l.startedAt).inSeconds;
  }
}

/// Single-parameter [AsyncNotifier] for the simulation-summary screen.
///
/// The screen calls [loadFor] once with the log id passed via the
/// route. Loading then resolves [state]; subsequent calls to
/// [submitPin] and [skipPin] mutate state synchronously. See spec 04
/// §Simulation Summary Screen (lines 1202–1288).
class SimulationSummaryController
    extends AsyncNotifier<SimulationSummaryState> {
  String? _logId;

  @override
  Future<SimulationSummaryState> build() async {
    final id = _logId;
    if (id == null || id.isEmpty) {
      return const SimulationSummaryState(
        log: null,
        pinRequired: false,
        pinUnlocked: true,
      );
    }
    final repo = await ref.read(sessionLogRepositoryProvider.future);
    final log = await repo.getById(id);
    final settings = await ref.read(appSettingsRepositoryProvider).load();
    final pinSet = settings.sessionEndPinHash != null;
    return SimulationSummaryState(
      log: log,
      pinRequired: pinSet,
      pinUnlocked: !pinSet,
    );
  }

  /// Sets the log id and triggers a rebuild.
  void loadFor(String? id) {
    if (_logId == id) return;
    _logId = id;
    ref.invalidateSelf();
  }

  /// Verifies [pin] against `appSettings.sessionEndPinHash`.
  ///
  /// On match the summary is unlocked; on mismatch [pinError] is set
  /// so the UI can shake the input. There is no counter and no
  /// distress chain — this is a simulation (spec 04:1232–1234).
  Future<void> submitPin(String pin) async {
    final current = state.value;
    if (current == null) return;
    final settings = await ref.read(appSettingsRepositoryProvider).load();
    final hash = sha256.convert(utf8.encode(pin)).toString();
    if (hash == settings.sessionEndPinHash) {
      state = AsyncData(
        current.copyWith(pinUnlocked: true, pinError: false),
      );
      return;
    }
    state = AsyncData(current.copyWith(pinError: true));
  }

  /// Reveals the summary without entering a PIN (Skip button per
  /// spec 04:1208).
  void skipPin() {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(pinUnlocked: true, pinError: false),
    );
  }

  /// Clears the error flag (called after the shake animation completes).
  void clearPinError() {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(pinError: false));
  }
}

/// Provides [SimulationSummaryController].
final simulationSummaryControllerProvider =
    AsyncNotifierProvider<SimulationSummaryController, SimulationSummaryState>(
      SimulationSummaryController.new,
    );
