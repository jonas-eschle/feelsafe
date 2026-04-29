/// Deterministic fake implementation of
/// [NotificationServiceProtocol] for tests. Every call is recorded
/// to [calls]; tap events are broadcast via a controller.
library;

import 'dart:async';

import 'package:guardianangela/domain/models/reminder_template.dart';
import 'package:guardianangela/services/protocols/notification_service_protocol.dart';

/// Test double for [NotificationServiceProtocol].
final class FakeNotificationService implements NotificationServiceProtocol {
  /// Creates a fake notification service.
  FakeNotificationService();

  /// Invocation log: one entry per method call.
  final List<String> calls = [];

  int _nextId = 1;
  final StreamController<String> _tapController =
      StreamController<String>.broadcast();

  @override
  Future<void> init() async {
    calls.add('init');
  }

  @override
  Future<void> showSessionNotification({
    required String title,
    required String body,
    bool isSimulation = false,
  }) async {
    calls.add('showSessionNotification:$title');
  }

  @override
  Future<void> showDisguisedReminder({
    required ReminderTemplate template,
    bool isSimulation = false,
  }) async {
    calls.add('showDisguisedReminder:${template.id}');
  }

  @override
  Future<int> scheduleNotification({
    required String title,
    required String body,
    required Duration delay,
    bool isSimulation = false,
  }) async {
    calls.add('scheduleNotification:$title/${delay.inSeconds}s');
    return _nextId++;
  }

  @override
  Future<void> cancelNotification(int id) async {
    calls.add('cancelNotification:$id');
  }

  @override
  Future<void> cancelAll() async {
    calls.add('cancelAll');
  }

  @override
  Stream<String> get actionTaps => _tapController.stream;

  @override
  Future<void> showToast(String message) async {
    calls.add('showToast:$message');
  }

  @override
  Future<void> showDisarmTriggerNotification({
    required String title,
    required String body,
    required String endSessionLabel,
    required String continueLabel,
  }) async {
    calls.add('showDisarmTriggerNotification:$title');
  }

  /// Test helper: synthesize a tap event on the stream.
  void injectTap(String actionId) {
    _tapController.add(actionId);
  }

  /// Closes the tap stream controller.
  void dispose() {
    _tapController.close();
  }
}
