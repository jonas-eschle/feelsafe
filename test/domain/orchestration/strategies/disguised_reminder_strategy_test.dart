/// Unit tests for [DisguisedReminderStrategy].
///
/// G4 update: [executeReal] now fires [VibrationServiceProtocol.reminderPattern]
/// and [NotificationServiceProtocol.showDisguisedReminder] (Extra-35 flags).
/// The strategy is no longer a pure no-op.
///
/// Spec ref: docs/spec/02-event-types.md §2 disguisedReminder.
/// Spec ref: docs/spec/05-services.md §843-867 (notification flags).
library;

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/domain/configs/step_config.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/enums/confirmation_type.dart';
import 'package:guardianangela/domain/enums/reminder_display_style.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/models/reminder_template.dart';
import 'package:guardianangela/domain/orchestration/strategies/disguised_reminder_strategy.dart';
import '../_test_fakes.dart';

// ─── Helper factories ─────────────────────────────────────────────────────────────

/// Creates a minimal [ChainStep] of type [ChainStepType.disguisedReminder].
ChainStep _step({DisguisedReminderConfig? config, int order = 0}) => ChainStep(
  id: 'test-step-id',
  type: ChainStepType.disguisedReminder,
  order: order,
  waitSeconds: 1800,
  durationSeconds: 60,
  gracePeriodSeconds: 5,
  retryCount: 1,
  randomize: false,
  config: config,
);

void main() {
  // ─── Group 1: executeReal wires reminderPattern ──────────────────────────────
  group('executeReal — wires vibration.reminderPattern', () {
    test('reminderPattern is called once (real mode)', () async {
      final vibration = FakeVibrationService();
      final services = buildServices(vibration: vibration);
      await const DisguisedReminderStrategy().executeReal(
        _step(config: const DisguisedReminderConfig()),
        services,
      );
      final vibCalls = vibration.calls
          .where((c) => c['method'] == 'reminderPattern')
          .toList();
      check(vibCalls).length.equals(1);
    });

    test(
      'reminderPattern fires when isSimulation=true (local hardware)',
      () async {
        final vibration = FakeVibrationService();
        final services = buildServices(
          vibration: vibration,
          isSimulation: true,
        );
        await const DisguisedReminderStrategy().executeReal(
          _step(config: const DisguisedReminderConfig()),
          services,
        );
        check(
          vibration.calls.any((c) => c['method'] == 'reminderPattern'),
        ).isTrue();
      },
    );
  });

  // ─── Group 2: executeReal wires showDisguisedReminder ───────────────────────
  group('executeReal — wires notification.showDisguisedReminder', () {
    test('showDisguisedReminder is called once (real mode)', () async {
      final notification = FakeNotificationService();
      final services = buildServices(notification: notification);
      await const DisguisedReminderStrategy().executeReal(
        _step(config: const DisguisedReminderConfig()),
        services,
      );
      final notifCalls = notification.calls
          .where((c) => c['method'] == 'showDisguisedReminder')
          .toList();
      check(notifCalls).length.equals(1);
    });

    test('showDisguisedReminder fires when isSimulation=true', () async {
      final notification = FakeNotificationService();
      final services = buildServices(
        notification: notification,
        isSimulation: true,
      );
      await const DisguisedReminderStrategy().executeReal(
        _step(config: const DisguisedReminderConfig()),
        services,
      );
      check(
        notification.calls.any((c) => c['method'] == 'showDisguisedReminder'),
      ).isTrue();
    });

    test(
      'threads notificationStealth=true into the stealth arg (#15 C3)',
      () async {
        final notification = FakeNotificationService();
        final services = buildServices(
          notification: notification,
          notificationStealth: true,
        );
        await const DisguisedReminderStrategy().executeReal(
          _step(config: const DisguisedReminderConfig()),
          services,
        );
        final call = notification.calls.firstWhere(
          (c) => c['method'] == 'showDisguisedReminder',
        );
        check(call['stealth']).equals(true);
      },
    );

    test('default (no stealth) passes stealth=false (#15 C3)', () async {
      final notification = FakeNotificationService();
      final services = buildServices(notification: notification);
      await const DisguisedReminderStrategy().executeReal(
        _step(config: const DisguisedReminderConfig()),
        services,
      );
      final call = notification.calls.firstWhere(
        (c) => c['method'] == 'showDisguisedReminder',
      );
      check(call['stealth']).equals(false);
    });

    test(
      'notification ID is offset by step.order (id=100 for order=0)',
      () async {
        final notification = FakeNotificationService();
        final services = buildServices(notification: notification);
        await const DisguisedReminderStrategy().executeReal(
          _step(config: const DisguisedReminderConfig()),
          services,
        );
        final call = notification.calls.firstWhere(
          (c) => c['method'] == 'showDisguisedReminder',
        );
        check(call['id']).equals(100);
      },
    );

    test(
      'notification ID shifts with step.order (id=105 for order=5)',
      () async {
        final notification = FakeNotificationService();
        final services = buildServices(notification: notification);
        await const DisguisedReminderStrategy().executeReal(
          _step(config: const DisguisedReminderConfig(), order: 5),
          services,
        );
        final call = notification.calls.firstWhere(
          (c) => c['method'] == 'showDisguisedReminder',
        );
        check(call['id']).equals(105);
      },
    );
  });

  // ─── Group 2b: notification uses the selected template disguise ─────────────
  group('executeReal — notification disguise comes from the template', () {
    final template = ReminderTemplate(
      id: 'tmpl_weather',
      name: 'Weather Alert',
      title: 'Rainy tomorrow',
      body: 'Bring an umbrella',
      confirmationType: ConfirmationType.dismiss,
      isCustom: false,
      displayStyle: ReminderDisplayStyle.subtle,
      isGlobal: true,
    );

    test('title and body match the selected template', () async {
      final notification = FakeNotificationService();
      final services = buildServices(
        notification: notification,
        selectedReminderTemplate: template,
      );
      await const DisguisedReminderStrategy().executeReal(
        _step(config: const DisguisedReminderConfig()),
        services,
      );
      final call = notification.calls.firstWhere(
        (c) => c['method'] == 'showDisguisedReminder',
      );
      check(call['title']).equals('Rainy tomorrow');
      check(call['body']).equals('Bring an umbrella');
    });

    test('falls back to defaults when no template is attached', () async {
      final notification = FakeNotificationService();
      final services = buildServices(notification: notification);
      await const DisguisedReminderStrategy().executeReal(
        _step(config: const DisguisedReminderConfig()),
        services,
      );
      final call = notification.calls.firstWhere(
        (c) => c['method'] == 'showDisguisedReminder',
      );
      check(call['title']).equals('Guardian Angela');
      check(call['body']).equals('Check in now.');
    });
  });

  // ─── Group 3: services not involved remain empty ─────────────────────────────
  group(
    'executeReal — messaging, phone, audio, flash, recording, screenFlash empty',
    () {
      test('messaging.calls is empty', () async {
        final messaging = FakeMessagingService();
        final services = buildServices(messaging: messaging);
        await const DisguisedReminderStrategy().executeReal(
          _step(config: const DisguisedReminderConfig()),
          services,
        );
        check(messaging.calls).isEmpty();
      });

      test('phone.calls is empty', () async {
        final phone = FakePhoneService();
        final services = buildServices(phone: phone);
        await const DisguisedReminderStrategy().executeReal(
          _step(config: const DisguisedReminderConfig()),
          services,
        );
        check(phone.calls).isEmpty();
      });

      test('audio.calls is empty', () async {
        final audio = FakeAudioService();
        final services = buildServices(audio: audio);
        await const DisguisedReminderStrategy().executeReal(
          _step(config: const DisguisedReminderConfig()),
          services,
        );
        check(audio.calls).isEmpty();
      });

      test('flash.calls is empty', () async {
        final flash = FakeFlashService();
        final services = buildServices(flash: flash);
        await const DisguisedReminderStrategy().executeReal(
          _step(config: const DisguisedReminderConfig()),
          services,
        );
        check(flash.calls).isEmpty();
      });

      test('recording.calls is empty', () async {
        final recording = FakeRecordingService();
        final services = buildServices(recording: recording);
        await const DisguisedReminderStrategy().executeReal(
          _step(config: const DisguisedReminderConfig()),
          services,
        );
        check(recording.calls).isEmpty();
      });

      test('screenFlash.calls is empty', () async {
        final screenFlash = FakeScreenFlashService();
        final services = buildServices(screenFlash: screenFlash);
        await const DisguisedReminderStrategy().executeReal(
          _step(config: const DisguisedReminderConfig()),
          services,
        );
        check(screenFlash.calls).isEmpty();
      });
    },
  );

  // ─── Group 4: simulationDescription returns null ──────────────────────────────
  group('simulationDescription — always returns null', () {
    test('returns null for default config, isSimulation=false', () {
      final step = _step(config: const DisguisedReminderConfig());
      final services = buildServices();
      check(
        const DisguisedReminderStrategy().simulationDescription(step, services),
      ).isNull();
    });

    test('returns null for default config, isSimulation=true', () {
      final step = _step(config: const DisguisedReminderConfig());
      final services = buildServices(isSimulation: true);
      check(
        const DisguisedReminderStrategy().simulationDescription(step, services),
      ).isNull();
    });

    test('returns null when step.config is null', () {
      check(
        const DisguisedReminderStrategy().simulationDescription(
          _step(),
          buildServices(),
        ),
      ).isNull();
    });

    test('returns null regardless of bool field combinations', () {
      final services = buildServices();
      for (final ri in [true, false]) {
        for (final rto in [true, false]) {
          for (final reci in [true, false]) {
            for (final bsm in [true, false]) {
              final result = const DisguisedReminderStrategy()
                  .simulationDescription(
                    _step(
                      config: DisguisedReminderConfig(
                        randomizeInterval: ri,
                        randomizeTemplateOrder: rto,
                        resetOnEarlyCheckIn: reci,
                        blackScreenMode: bsm,
                      ),
                    ),
                    services,
                  );
              check(result).isNull();
            }
          }
        }
      }
    });
  });

  // ─── Group 5: null step.config — strategy is safe ───────────────────────────
  group('null step.config — strategy uses defaults', () {
    test('executeReal does not throw when step.config is null', () async {
      await check(
        const DisguisedReminderStrategy().executeReal(_step(), buildServices()),
      ).completes();
    });

    test('reminderPattern fires when config is null', () async {
      final vibration = FakeVibrationService();
      await const DisguisedReminderStrategy().executeReal(
        _step(),
        buildServices(vibration: vibration),
      );
      check(
        vibration.calls.any((c) => c['method'] == 'reminderPattern'),
      ).isTrue();
    });

    test('showDisguisedReminder fires when config is null', () async {
      final notification = FakeNotificationService();
      await const DisguisedReminderStrategy().executeReal(
        _step(),
        buildServices(notification: notification),
      );
      check(
        notification.calls.any((c) => c['method'] == 'showDisguisedReminder'),
      ).isTrue();
    });
  });

  // ─── Group 6: const constructor ──────────────────────────────────────────────
  group('const constructor — strategy is a singleton constant', () {
    test('two const instances are identical', () {
      const a = DisguisedReminderStrategy();
      const b = DisguisedReminderStrategy();
      check(identical(a, b)).isTrue();
    });
  });
}
