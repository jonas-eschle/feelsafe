/// Session state enum for the active walk/date session.
enum SessionState {
  idle,
  active,
  checkInPrompt,
  warning,
  fakeCall,
  smsSent,
  alarm,
  emergencyCall,
  completed,
}

/// A point in the GPS location history.
class LocationPoint {
  final double latitude;
  final double longitude;
  final DateTime timestamp;

  const LocationPoint({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });

  String toMapsUrl() => 'https://maps.google.com/?q=$latitude,$longitude';
}

/// Ephemeral session data — not persisted.
class WalkSession {
  final DateTime startTime;
  final SessionState state;
  final String modeId;
  final int currentEscalationIndex;
  final DateTime? lastCheckIn;
  final int missedCheckIns;
  final List<LocationPoint> locationHistory;

  const WalkSession({
    required this.startTime,
    required this.modeId,
    this.state = SessionState.active,
    this.currentEscalationIndex = -1,
    this.lastCheckIn,
    this.missedCheckIns = 0,
    this.locationHistory = const [],
  });

  WalkSession copyWith({
    SessionState? state,
    int? currentEscalationIndex,
    DateTime? lastCheckIn,
    int? missedCheckIns,
    List<LocationPoint>? locationHistory,
  }) {
    return WalkSession(
      startTime: startTime,
      modeId: modeId,
      state: state ?? this.state,
      currentEscalationIndex:
          currentEscalationIndex ?? this.currentEscalationIndex,
      lastCheckIn: lastCheckIn ?? this.lastCheckIn,
      missedCheckIns: missedCheckIns ?? this.missedCheckIns,
      locationHistory: locationHistory ?? this.locationHistory,
    );
  }
}
