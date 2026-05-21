/// Supplemental tests for [BackgroundSessionService] covering the
/// `updateStatus` branch when `_running = true` (line 84).
library;

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/services/fakes/fake_notification_service.dart';
import 'package:guardianangela/services/implementations/background_session_service.dart';

void main() {
  group('BackgroundSessionService.updateStatus — running path (line 84)', () {
    test('updateStatus when running calls showSessionNotification', () async {
      final notif = FakeNotificationService();
      final svc = BackgroundSessionService(notification: notif);
      addTearDown(notif.dispose);

      // Arm the service first.
      await svc.start(title: 'start', body: 'b');
      final callsBeforeUpdate = List<String>.of(notif.calls);

      // Now call updateStatus while running — should delegate to the
      // notification layer (line 84 covered).
      await svc.updateStatus(title: 'updated', body: 'new body');

      check(notif.calls.length).isGreaterThan(callsBeforeUpdate.length);
      check(notif.calls.any((c) => c.contains('updated'))).isTrue();

      await svc.dispose();
    });
  });
}
