// Tests for SessionStartValidator (Stage 5C + 5C-fix).
//
// Uses constructor-injected state (cached permissions, contact count,
// emergency number) so no real permission_handler calls are made.
//
// Prewarm tests inject a canLaunchUrl fake via the constructor parameter
// so no real URL-scheme checks are attempted.

import 'package:checks/checks.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:test/test.dart';

import 'package:guardianangela/domain/configs/step_config.dart';
import 'package:guardianangela/domain/enums/app_permission.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/enums/message_channel.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/models/session_mode.dart';
import 'package:guardianangela/domain/models/validation_result.dart';
import 'package:guardianangela/services/session_start_validator.dart';
import 'package:guardianangela/services/sim/session_start_validator_sim.dart';

// ---------------------------------------------------------------------------
// Test helpers
// ---------------------------------------------------------------------------

ChainStep _step(
  String id,
  ChainStepType type, {
  StepConfig? config,
  int order = 0,
}) => ChainStep(
  id: id,
  type: type,
  order: order,
  waitSeconds: 60,
  durationSeconds: 30,
  gracePeriodSeconds: 10,
  retryCount: 0,
  randomize: false,
  config: config,
);

SessionMode _modeWith({List<ChainStep> steps = const []}) => SessionMode(
  id: 'test_mode',
  name: 'Test Mode',
  chainSteps: steps.isEmpty ? [_step('s1', ChainStepType.holdButton)] : steps,
);

/// Creates a [RealSessionStartValidator] with all permissions granted
/// and the given overrides.
///
/// [installedApps] pre-seeds the third-party app cache so [prewarm] need
/// not be called in basic tests. An absent entry means "unknown" (warn).
RealSessionStartValidator _makeValidator({
  int contactCount = 1,
  String emergencyNumber = '112',
  Map<AppPermission, bool> permOverrides = const {},
  bool batteryExempt = true,
  Map<String, bool>? installedApps,
}) {
  final perms = {
    for (final p in AppPermission.values) p: true,
    ...permOverrides,
  };
  return RealSessionStartValidator(
    cachedContactCount: contactCount,
    cachedEmergencyNumber: emergencyNumber,
    cachedPermissions: perms,
    cachedBatteryOptimizationExempt: batteryExempt,
    batteryOptChecker: () async => batteryExempt,
    permissionChecker: (p) async =>
        perms.values.first ? PermissionStatus.granted : PermissionStatus.denied,
    installedApps: installedApps,
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('RealSessionStartValidator — validate()', () {
    test('holdButton-only mode with all granted is valid', () {
      final v = _makeValidator();
      final result = v.validate(_modeWith());
      check(result.isValid).isTrue();
      check(result.errors).isEmpty();
    });

    // Check 1: notification permission
    test('missing notification is a blocking error', () {
      final v = _makeValidator(
        permOverrides: {AppPermission.notification: false},
      );
      final result = v.validate(_modeWith());
      check(result.isValid).isFalse();
      check(
        result.errors.map((e) => e.title),
      ).contains('Notifications disabled');
    });

    // Check 2: emergency contacts warning
    test('smsContact step with 0 contacts is a warning (not blocking)', () {
      final v = _makeValidator(contactCount: 0);
      final mode = _modeWith(steps: [_step('s1', ChainStepType.smsContact)]);
      final result = v.validate(mode);
      check(result.isValid).isTrue(); // not blocking
      check(
        result.warnings.map((w) => w.title),
      ).contains('No emergency contacts');
    });

    test('phoneCallContact step with 0 contacts is a warning', () {
      final v = _makeValidator(contactCount: 0);
      final mode = _modeWith(
        steps: [_step('s1', ChainStepType.phoneCallContact)],
      );
      final result = v.validate(mode);
      check(
        result.warnings.map((w) => w.title),
      ).contains('No emergency contacts');
    });

    test('smsContact step with contacts is not warned', () {
      final v = _makeValidator(contactCount: 2);
      final mode = _modeWith(steps: [_step('s1', ChainStepType.smsContact)]);
      final result = v.validate(mode);
      check(
        result.warnings.map((w) => w.title),
      ).not((c) => c.contains('No emergency contacts'));
    });

    // Check 3: third-party app warning (WhatsApp/Telegram)
    test('WhatsApp channel step warns when prewarm not run (unknown)', () {
      // No installedApps injected → all entries absent → conservative warn.
      final v = _makeValidator();
      final mode = _modeWith(
        steps: [
          _step(
            's1',
            ChainStepType.smsContact,
            config: const SmsContactConfig(channel: MessageChannel.whatsapp),
          ),
        ],
      );
      final result = v.validate(mode);
      check(
        result.warnings.map((w) => w.title),
      ).contains('WhatsApp not confirmed installed');
    });

    test('Telegram channel step warns when prewarm not run (unknown)', () {
      final v = _makeValidator();
      final mode = _modeWith(
        steps: [
          _step(
            's1',
            ChainStepType.smsContact,
            config: const SmsContactConfig(channel: MessageChannel.telegram),
          ),
        ],
      );
      final result = v.validate(mode);
      check(
        result.warnings.map((w) => w.title),
      ).contains('Telegram not confirmed installed');
    });

    test('WhatsApp channel step warns when explicitly marked NOT installed', () {
      final v = _makeValidator(installedApps: {'WhatsApp': false});
      final mode = _modeWith(
        steps: [
          _step(
            's1',
            ChainStepType.smsContact,
            config: const SmsContactConfig(channel: MessageChannel.whatsapp),
          ),
        ],
      );
      final result = v.validate(mode);
      check(
        result.warnings.map((w) => w.title),
      ).contains('WhatsApp not confirmed installed');
    });

    test('WhatsApp channel step does NOT warn when installed=true', () {
      final v = _makeValidator(installedApps: {'WhatsApp': true});
      final mode = _modeWith(
        steps: [
          _step(
            's1',
            ChainStepType.smsContact,
            config: const SmsContactConfig(channel: MessageChannel.whatsapp),
          ),
        ],
      );
      final result = v.validate(mode);
      check(
        result.warnings.map((w) => w.title),
      ).not((c) => c.contains('WhatsApp not confirmed installed'));
    });

    test('Telegram channel step does NOT warn when installed=true', () {
      final v = _makeValidator(installedApps: {'Telegram': true});
      final mode = _modeWith(
        steps: [
          _step(
            's1',
            ChainStepType.smsContact,
            config: const SmsContactConfig(channel: MessageChannel.telegram),
          ),
        ],
      );
      final result = v.validate(mode);
      check(
        result.warnings.map((w) => w.title),
      ).not((c) => c.contains('Telegram not confirmed installed'));
    });

    // Check 4: emergency number required for callEmergency
    test('callEmergency with empty emergency number is a blocking error', () {
      final v = _makeValidator(emergencyNumber: '');
      final mode = _modeWith(steps: [_step('s1', ChainStepType.callEmergency)]);
      final result = v.validate(mode);
      check(result.isValid).isFalse();
      check(result.errors.map((e) => e.title)).contains('No emergency number');
    });

    test('callEmergency with non-empty number is valid', () {
      final v = _makeValidator(emergencyNumber: '911');
      final mode = _modeWith(steps: [_step('s1', ChainStepType.callEmergency)]);
      final result = v.validate(mode);
      check(
        result.errors.map((e) => e.title),
      ).not((c) => c.contains('No emergency number'));
    });

    // Check 5: location permission
    test('smsContact includeLocation=true with no location perm is error', () {
      final v = _makeValidator(permOverrides: {AppPermission.location: false});
      final mode = _modeWith(
        steps: [
          _step(
            's1',
            ChainStepType.smsContact,
            config: const SmsContactConfig(),
          ),
        ],
      );
      final result = v.validate(mode);
      check(result.isValid).isFalse();
      check(
        result.errors.map((e) => e.title),
      ).contains('Location permission required');
    });

    test('smsContact includeLocation=false does not require location perm', () {
      final v = _makeValidator(permOverrides: {AppPermission.location: false});
      final mode = _modeWith(
        steps: [
          _step(
            's1',
            ChainStepType.smsContact,
            config: const SmsContactConfig(includeLocation: false),
          ),
        ],
      );
      final result = v.validate(mode);
      check(
        result.errors.map((e) => e.title),
      ).not((c) => c.contains('Location permission required'));
    });

    // Check 6: SMS permission
    test(
      'smsContact (SMS channel) missing sms permission is a blocking error',
      () {
        final v = _makeValidator(permOverrides: {AppPermission.sms: false});
        final mode = _modeWith(
          steps: [
            _step(
              's1',
              ChainStepType.smsContact,
              config: const SmsContactConfig(),
            ),
          ],
        );
        final result = v.validate(mode);
        check(result.isValid).isFalse();
        check(
          result.errors.map((e) => e.title),
        ).contains('SMS permission required');
      },
    );

    test('phoneCallContact missing phone permission is a blocking error', () {
      final v = _makeValidator(permOverrides: {AppPermission.phone: false});
      final mode = _modeWith(
        steps: [_step('s1', ChainStepType.phoneCallContact)],
      );
      final result = v.validate(mode);
      check(result.isValid).isFalse();
      check(
        result.errors.map((e) => e.title),
      ).contains('Phone permission required');
    });

    // Check 7: microphone
    test('autoRecordAudio=true missing microphone is a blocking error', () {
      final v = _makeValidator(
        permOverrides: {AppPermission.microphone: false},
      );
      final mode = _modeWith(
        steps: [
          _step(
            's1',
            ChainStepType.smsContact,
            config: const SmsContactConfig(autoRecordAudio: true),
          ),
        ],
      );
      final result = v.validate(mode);
      check(result.isValid).isFalse();
      check(
        result.errors.map((e) => e.title),
      ).contains('Microphone permission required');
    });

    // Check 8: battery optimization (warning only)
    test('battery optimization not exempt emits a warning (not blocking)', () {
      final v = _makeValidator(batteryExempt: false);
      final result = v.validate(_modeWith());
      check(result.isValid).isTrue();
      check(
        result.warnings.map((w) => w.title),
      ).contains('Battery optimization active');
    });

    test('battery optimization exempt has no battery warning', () {
      final v = _makeValidator();
      final result = v.validate(_modeWith());
      check(
        result.warnings.map((w) => w.title),
      ).not((c) => c.contains('Battery optimization active'));
    });

    // ValidationResult contract
    test('isValid = false when errors is non-empty', () {
      final v = _makeValidator(
        permOverrides: {AppPermission.notification: false},
      );
      final result = v.validate(_modeWith());
      check(result.isValid).isFalse();
      check(result.errors).isNotEmpty();
    });

    test('isValid = true when errors is empty (warnings OK)', () {
      final v = _makeValidator(batteryExempt: false);
      final result = v.validate(_modeWith());
      check(result.isValid).isTrue();
      check(result.warnings).isNotEmpty();
    });

    // ValidationResult.valid named ctor
    test('ValidationResult.valid has no errors or warnings', () {
      const result = ValidationResult.valid();
      check(result.isValid).isTrue();
      check(result.errors).isEmpty();
      check(result.warnings).isEmpty();
    });
  });

  group('RealSessionStartValidator — prewarm()', () {
    test('prewarm populates WhatsApp installed=true when canLaunchUrl returns true', () async {
      final v = RealSessionStartValidator(
        canLaunchUrl: (uri) async => uri.scheme == 'whatsapp',
        cachedPermissions: {for (final p in AppPermission.values) p: true},
        cachedBatteryOptimizationExempt: true,
        batteryOptChecker: () async => true,
      );
      await v.prewarm();

      final mode = _modeWith(
        steps: [
          _step(
            's1',
            ChainStepType.smsContact,
            config: const SmsContactConfig(channel: MessageChannel.whatsapp),
          ),
        ],
      );
      final result = v.validate(mode);
      check(
        result.warnings.map((w) => w.title),
      ).not((c) => c.contains('WhatsApp not confirmed installed'));
    });

    test('prewarm populates Telegram installed=true when canLaunchUrl returns true', () async {
      final v = RealSessionStartValidator(
        canLaunchUrl: (uri) async => uri.scheme == 'tg',
        cachedPermissions: {for (final p in AppPermission.values) p: true},
        cachedBatteryOptimizationExempt: true,
        batteryOptChecker: () async => true,
      );
      await v.prewarm();

      final mode = _modeWith(
        steps: [
          _step(
            's1',
            ChainStepType.smsContact,
            config: const SmsContactConfig(channel: MessageChannel.telegram),
          ),
        ],
      );
      final result = v.validate(mode);
      check(
        result.warnings.map((w) => w.title),
      ).not((c) => c.contains('Telegram not confirmed installed'));
    });

    test('prewarm marks WhatsApp NOT installed when canLaunchUrl returns false', () async {
      final v = RealSessionStartValidator(
        canLaunchUrl: (_) async => false,
        cachedPermissions: {for (final p in AppPermission.values) p: true},
        cachedBatteryOptimizationExempt: true,
        batteryOptChecker: () async => true,
      );
      await v.prewarm();

      final mode = _modeWith(
        steps: [
          _step(
            's1',
            ChainStepType.smsContact,
            config: const SmsContactConfig(channel: MessageChannel.whatsapp),
          ),
        ],
      );
      final result = v.validate(mode);
      check(
        result.warnings.map((w) => w.title),
      ).contains('WhatsApp not confirmed installed');
    });

    test('before prewarm is called, validate uses unknown (warn) default', () {
      final v = RealSessionStartValidator(
        canLaunchUrl: (_) async => true, // Would return true if called
        cachedPermissions: {for (final p in AppPermission.values) p: true},
        cachedBatteryOptimizationExempt: true,
        batteryOptChecker: () async => true,
      );
      // prewarm NOT called
      final mode = _modeWith(
        steps: [
          _step(
            's1',
            ChainStepType.smsContact,
            config: const SmsContactConfig(channel: MessageChannel.whatsapp),
          ),
        ],
      );
      final result = v.validate(mode);
      // Conservative: warns because map is empty (unknown).
      check(
        result.warnings.map((w) => w.title),
      ).contains('WhatsApp not confirmed installed');
    });

    test('prewarm runs canLaunchUrl checks for both WhatsApp and Telegram', () async {
      final checked = <String>[];
      final v = RealSessionStartValidator(
        canLaunchUrl: (uri) async {
          checked.add(uri.scheme);
          return false;
        },
        cachedPermissions: {for (final p in AppPermission.values) p: true},
        cachedBatteryOptimizationExempt: true,
        batteryOptChecker: () async => true,
      );
      await v.prewarm();
      check(checked).contains('whatsapp');
      check(checked).contains('tg');
    });
  });

  group('SimulationSessionStartValidator', () {
    test('returns valid by default', () {
      final v = SimulationSessionStartValidator();
      final mode = _modeWith();
      final result = v.validate(mode);
      check(result.isValid).isTrue();
    });

    test('records validated modes', () {
      final v = SimulationSessionStartValidator();
      final mode = _modeWith();
      v.validate(mode);
      v.validate(mode);
      check(v.validatedModes.length).equals(2);
    });

    test('returns constructor-injected result', () {
      const fixedResult = ValidationResult(
        errors: [
          ValidationIssue(
            title: 'No contacts',
            description: 'Add at least one.',
          ),
        ],
        warnings: [],
      );
      final v = SimulationSessionStartValidator(fixedResult: fixedResult);
      final result = v.validate(_modeWith());
      check(result.isValid).isFalse();
      check(result.errors.first.title).equals('No contacts');
    });

    test('reset clears validatedModes', () {
      final v = SimulationSessionStartValidator();
      v.validate(_modeWith());
      v.reset();
      check(v.validatedModes).isEmpty();
    });
  });
}
