import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';

/// Immutable view-model for [SessionScreen].
///
/// Phase 6 supplies a thin facade over the engine. The full session
/// orchestration (engine + strategies + recorder wiring) lives in
/// Phase 7's `lib/features/session/session_runtime.dart`; this Phase 6
/// surface gives the UI everything it needs to render the screen.
@immutable
class SessionState {
  /// Creates a [SessionState].
  const SessionState({
    required this.isSimulation,
    required this.elapsedSeconds,
    this.priorInterrupted = false,
    this.priorModeName,
    this.priorStartedAt,
  });

  /// Whether this session is a simulation (orange border + speed slider).
  final bool isSimulation;

  /// Elapsed session time in seconds (wall-clock; sim time when simulating).
  final int elapsedSeconds;

  /// Whether the prior session was interrupted (Extra 13).
  final bool priorInterrupted;

  /// Name of the prior interrupted session's mode.
  final String? priorModeName;

  /// Wall-clock start time of the prior interrupted session.
  final DateTime? priorStartedAt;
}

/// Controller for the session screen.
///
/// The full engine wiring (timer-driven step transitions, strategy
/// execution, log recording) is owned by Phase 7. Phase 6 exposes the
/// surface that the UI uses: simulation flag, elapsed time, and the
/// session-interrupted prompt.
class SessionController extends AsyncNotifier<SessionState> {
  @override
  Future<SessionState> build() async {
    // Phase 7 will detect the interrupted-marker file and resolve a
    // mode name. Phase 6 returns a clean state so navigation works.
    return const SessionState(isSimulation: false, elapsedSeconds: 0);
  }
}

/// Provides the [SessionController].
final sessionControllerProvider =
    AsyncNotifierProvider<SessionController, SessionState>(
      SessionController.new,
    );
