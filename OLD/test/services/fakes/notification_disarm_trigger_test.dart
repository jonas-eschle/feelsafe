/// Tests for [FakeNotificationService] and [SimulationNotificationService]
/// focused on the disarm-trigger notification path.
///
/// Spec 04 §Disarm trigger confirmation: when the app is backgrounded and
/// a disarm trigger fires, the notification service posts a notification with
/// action buttons "End session" / "Continue". The action tap is injected
/// via [FakeNotificationService.injectTap] and propagated through
/// [actionTaps].
library;

import 'dart:async';

import 'package:checks/checks.dart';
import 'package:test/test.dart';

import 'package:guardianangela/services/fakes/fake_notification_service.dart';
import 'package:guardianangela/services/simulation/simulation_notification_service.dart';

void main() {
  group('FakeNotificationService – showDisarmTriggerNotification', () {
    test('records the call with its title', () async {
      // Arrange
      final s = FakeNotificationService();
      addTearDown(s.dispose);

      // Act
      await s.showDisarmTriggerNotification(
        title: 'Disarm trigger fired',
        body: 'A trigger fired',
        endSessionLabel: 'End session',
        continueLabel: 'Continue',
      );

      // Assert — recorded call has the title prefix.
      check(
        s.calls.any((c) => c.startsWith('showDisarmTriggerNotification:')),
      ).isTrue();
      check(s.calls.any((c) => c.contains('Disarm trigger fired'))).isTrue();
    });

    test('multiple disarm-trigger calls are each recorded', () async {
      // Arrange
      final s = FakeNotificationService();
      addTearDown(s.dispose);

      // Act
      await s.showDisarmTriggerNotification(
        title: 'First',
        body: 'body1',
        endSessionLabel: 'End',
        continueLabel: 'Continue',
      );
      await s.showDisarmTriggerNotification(
        title: 'Second',
        body: 'body2',
        endSessionLabel: 'End',
        continueLabel: 'Continue',
      );

      // Assert
      final disarmCalls = s.calls
          .where((c) => c.startsWith('showDisarmTriggerNotification:'))
          .toList();
      check(disarmCalls.length).equals(2);
    });
  });

  group('FakeNotificationService – actionTaps stream', () {
    test('injectTap delivers tap event on actionTaps stream', () async {
      // Arrange
      final s = FakeNotificationService();
      addTearDown(s.dispose);
      final received = <String>[];
      final sub = s.actionTaps.listen(received.add);
      addTearDown(sub.cancel);

      // Act
      s.injectTap('disarmTriggerEnd');
      await Future<void>.delayed(Duration.zero);

      // Assert
      check(received).deepEquals(['disarmTriggerEnd']);
    });

    test('injectTap delivers multiple sequential action IDs', () async {
      // Arrange
      final s = FakeNotificationService();
      addTearDown(s.dispose);
      final received = <String>[];
      final sub = s.actionTaps.listen(received.add);
      addTearDown(sub.cancel);

      // Act
      s.injectTap('disarmTriggerEnd');
      s.injectTap('disarmTriggerContinue');
      await Future<void>.delayed(Duration.zero);

      // Assert — both delivered in order.
      check(received).deepEquals(['disarmTriggerEnd', 'disarmTriggerContinue']);
    });

    test(
      'disarmTriggerEnd action ID is a broadcast — multiple listeners',
      () async {
        // Arrange
        final s = FakeNotificationService();
        addTearDown(s.dispose);
        final a = <String>[];
        final b = <String>[];
        final sa = s.actionTaps.listen(a.add);
        final sb = s.actionTaps.listen(b.add);
        addTearDown(sa.cancel);
        addTearDown(sb.cancel);

        // Act
        s.injectTap('disarmTriggerEnd');
        await Future<void>.delayed(Duration.zero);

        // Assert — both listeners received the event.
        check(a).deepEquals(['disarmTriggerEnd']);
        check(b).deepEquals(['disarmTriggerEnd']);
      },
    );
  });

  group('SimulationNotificationService – showDisarmTriggerNotification', () {
    test('does not throw (no-op log call)', () async {
      // Arrange
      final s = SimulationNotificationService();
      addTearDown(s.dispose);

      // Act & Assert — must complete without error.
      await check(
        s.showDisarmTriggerNotification(
          title: 'Sim Disarm',
          body: 'sim body',
          endSessionLabel: 'End',
          continueLabel: 'Continue',
        ),
      ).completes();
    });

    test('actionTaps stream emits nothing by default', () async {
      // Arrange
      final s = SimulationNotificationService();
      addTearDown(s.dispose);

      // Act — listen to the stream but inject nothing.
      final events = <String>[];
      final sub = s.actionTaps.listen(events.add);
      addTearDown(sub.cancel);
      await Future<void>.delayed(Duration.zero);

      // Assert — no events delivered.
      check(events).isEmpty();
    });
  });
}
