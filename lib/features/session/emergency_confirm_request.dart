/// Request emitted by [SessionController.emergencyConfirmationRequests]
/// when a `callEmergency` step begins with `showConfirmation == true`
/// and the stealth-suppression escape hatch is NOT engaged.
///
/// Spec 04 §EmergencyCallConfirmationScreen.
library;

import 'package:meta/meta.dart';

/// Describes an emergency-call confirmation shown before dialing.
@immutable
class EmergencyConfirmRequest {
  /// Creates an emergency-call confirmation request.
  const EmergencyConfirmRequest({
    required this.number,
    required this.durationSeconds,
  });

  /// The number the strategy is about to dial.
  final String number;

  /// How many seconds the UI countdown should show. Must match the
  /// `CallEmergencyConfig.confirmationDurationSeconds` so that the
  /// UI countdown and the strategy's pre-dial delay finish together.
  final int durationSeconds;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmergencyConfirmRequest &&
          other.number == number &&
          other.durationSeconds == durationSeconds;

  @override
  int get hashCode => Object.hash(number, durationSeconds);

  @override
  String toString() =>
      'EmergencyConfirmRequest(number: $number, '
      'durationSeconds: $durationSeconds)';
}
