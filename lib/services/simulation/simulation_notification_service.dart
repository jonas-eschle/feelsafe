/// Simulation implementation of [NotificationServiceProtocol]. All
/// methods log via `dart:developer` and return a no-op.
library;

import 'dart:async';
import 'dart:developer' as developer;

import 'package:guardianangela/domain/models/reminder_template.dart';
import 'package:guardianangela/services/protocols/notification_service_protocol.dart';

/// Simulation double for [NotificationServiceProtocol].
final class SimulationNotificationService
    implements NotificationServiceProtocol {
  /// Creates the simulation notification service.
  SimulationNotificationService();

  int _nextId = 1;
  final StreamController<String> _tapController =
      StreamController<String>.broadcast();

  @override
  Future<void> init() async {
    developer.log('[SIM] notification.init');
  }

  @override
  Future<void> showSessionNotification({
    required String title,
    required String body,
    bool isSimulation = false,
  }) async {
    developer.log('[SIM] notification.showSessionNotification $title');
  }

  @override
  Future<void> showDisguisedReminder({
    required ReminderTemplate template,
    bool isSimulation = false,
  }) async {
    developer.log('[SIM] notification.showDisguisedReminder ${template.id}');
  }

  @override
  Future<int> scheduleNotification({
    required String title,
    required String body,
    required Duration delay,
    bool isSimulation = false,
  }) async {
    developer.log(
      '[SIM] notification.scheduleNotification $title delay=$delay',
    );
    return _nextId++;
  }

  @override
  Future<void> cancelNotification(int id) async {
    developer.log('[SIM] notification.cancelNotification $id');
  }

  @override
  Future<void> cancelAll() async {
    developer.log('[SIM] notification.cancelAll');
  }

  @override
  Stream<String> get actionTaps => _tapController.stream;

  @override
  Future<void> showToast(String message) async {
    developer.log('[SIM] notification.showToast $message');
  }

  /// Closes the tap stream controller.
  void dispose() {
    _tapController.close();
  }
}
