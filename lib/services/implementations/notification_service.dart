/// Real notification-service implementation stub. Phase 9 fills bodies.
library;

import 'package:guardianangela/domain/models/reminder_template.dart';
import 'package:guardianangela/services/protocols/notification_service_protocol.dart';

/// Real platform-backed implementation of [NotificationServiceProtocol].
final class NotificationService implements NotificationServiceProtocol {
  /// Creates the real notification service.
  NotificationService();

  @override
  Future<void> init() async =>
      throw UnimplementedError('TODO: Phase 9 real impl');

  @override
  Future<void> showSessionNotification({
    required String title,
    required String body,
    bool isSimulation = false,
  }) async => throw UnimplementedError('TODO: Phase 9 real impl');

  @override
  Future<void> showDisguisedReminder({
    required ReminderTemplate template,
    bool isSimulation = false,
  }) async => throw UnimplementedError('TODO: Phase 9 real impl');

  @override
  Future<int> scheduleNotification({
    required String title,
    required String body,
    required Duration delay,
    bool isSimulation = false,
  }) async => throw UnimplementedError('TODO: Phase 9 real impl');

  @override
  Future<void> cancelNotification(int id) async =>
      throw UnimplementedError('TODO: Phase 9 real impl');

  @override
  Future<void> cancelAll() async =>
      throw UnimplementedError('TODO: Phase 9 real impl');

  @override
  Stream<String> get actionTaps =>
      throw UnimplementedError('TODO: Phase 9 real impl');

  @override
  Future<void> showToast(String message) async =>
      throw UnimplementedError('TODO: Phase 9 real impl');
}
