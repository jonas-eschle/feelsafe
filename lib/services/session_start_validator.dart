import 'dart:developer';

import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

import 'package:guardianangela/domain/configs/step_config.dart';
import 'package:guardianangela/domain/enums/app_permission.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/enums/message_channel.dart';
import 'package:guardianangela/domain/models/session_mode.dart';
import 'package:guardianangela/domain/models/validation_result.dart';
import 'package:guardianangela/services/protocols/session_start_validator_protocol.dart';

/// Production [SessionStartValidatorProtocol].
///
/// [validate] is synchronous (spec 05:1186 / protocol contract). To avoid
/// async I/O inside `validate`, the controller must call
/// [updateCachedState] (to refresh permissions) and [prewarm] (to check
/// third-party app installation) before calling [validate].
///
/// The session controller's startup flow:
/// 1. `await auditForMode(mode)` — determines which permissions are needed.
/// 2. `await validator.updateCachedState(...)` — refreshes cached state.
/// 3. `await validator.prewarm()` — queries installed third-party apps.
/// 4. `validator.validate(mode)` — synchronous.
///
/// **Single constructor location rule:** no `RealSessionStartValidator()`
/// call may appear outside `lib/services/service_providers.dart`
/// (CI grep enforces).
class RealSessionStartValidator implements SessionStartValidatorProtocol {
  /// Creates a [RealSessionStartValidator].
  ///
  /// All cached-state parameters default to a conservative "not granted /
  /// zero contacts" posture. Call [updateCachedState] and [prewarm] to
  /// refresh before each [validate] call.
  ///
  /// [canLaunchUrl] defaults to [url_launcher.canLaunchUrl]. Tests pass a
  /// fake to avoid real URL-scheme lookups.
  ///
  /// [installedApps] is an optional pre-warmed map (keyed by app name) for
  /// tests that need to bypass [prewarm].
  RealSessionStartValidator({
    int cachedContactCount = 0,
    String cachedEmergencyNumber = '',
    Map<AppPermission, bool>? cachedPermissions,
    bool cachedBatteryOptimizationExempt = false,
    Future<bool> Function()? batteryOptChecker,
    Future<PermissionStatus> Function(Permission)? permissionChecker,
    Future<bool> Function(Uri)? canLaunchUrl,
    Map<String, bool>? installedApps,
  }) : _contactCount = cachedContactCount,
       _emergencyNumber = cachedEmergencyNumber,
       _permissions = cachedPermissions ?? const <AppPermission, bool>{},
       _batteryOptExempt = cachedBatteryOptimizationExempt,
       _batteryOptChecker = batteryOptChecker ?? _defaultBatteryOptChecker,
       _permissionChecker = permissionChecker ?? _defaultPermissionChecker,
       _canLaunchUrl = canLaunchUrl ?? url_launcher.canLaunchUrl,
       _installedApps = Map<String, bool>.from(installedApps ?? const {});

  int _contactCount;
  String _emergencyNumber;
  Map<AppPermission, bool> _permissions;
  bool _batteryOptExempt;
  final Future<bool> Function() _batteryOptChecker;
  final Future<PermissionStatus> Function(Permission) _permissionChecker;
  final Future<bool> Function(Uri) _canLaunchUrl;

  /// Cached result of [prewarm] — maps app name to installed status.
  ///
  /// An absent key means the app was never checked (unknown → warn).
  /// Populated by [prewarm]; tests may inject a pre-filled map via the
  /// [installedApps] constructor parameter.
  final Map<String, bool> _installedApps;

  static Future<bool> _defaultBatteryOptChecker() async {
    final status = await Permission.ignoreBatteryOptimizations.status;
    return status.isGranted;
  }

  static Future<PermissionStatus> _defaultPermissionChecker(Permission p) =>
      p.status;

  // ---------------------------------------------------------------------------
  // State refresh (called by the session controller before validate)
  // ---------------------------------------------------------------------------

  /// Queries [canLaunchUrl] for each third-party messaging app and caches
  /// the result in [_installedApps].
  ///
  /// Must be called once before [validate] to enable real installation
  /// checks. If not called the map is empty (unknown) and [validate] falls
  /// back to always-warn, which is the conservative default.
  ///
  /// On Android, the `<queries>` entries in `AndroidManifest.xml` are
  /// required for this to return accurate results on API 30+.
  Future<void> prewarm() async {
    final results = await Future.wait([
      _canLaunchUrl(Uri.parse('whatsapp://send?phone=+10000000000')),
      _canLaunchUrl(Uri.parse('tg://msg?to=+10000000000')),
    ]);
    _installedApps['WhatsApp'] = results[0];
    _installedApps['Telegram'] = results[1];
    log(
      'prewarm: WhatsApp=${results[0]} Telegram=${results[1]}',
      name: 'SessionStartValidator',
    );
  }

  /// Refreshes cached permission statuses, contact count, and emergency number.
  ///
  /// The [SessionController] calls this immediately before [validate] to avoid
  /// stale permission data.
  Future<void> updateCachedState({
    required int contactCount,
    required String emergencyNumber,
    required Set<AppPermission> requiredPermissions,
  }) async {
    _contactCount = contactCount;
    _emergencyNumber = emergencyNumber;

    final perms = <AppPermission, bool>{};
    for (final perm in AppPermission.values) {
      final status = await _permissionChecker(_toHandlerPermission(perm));
      perms[perm] = status.isGranted;
    }
    _permissions = perms;

    _batteryOptExempt = await _batteryOptChecker();

    log(
      'updateCachedState: contacts=$contactCount '
      'emergency="$emergencyNumber" '
      'batteryExempt=$_batteryOptExempt',
      name: 'SessionStartValidator',
    );
  }

  // ---------------------------------------------------------------------------
  // SessionStartValidatorProtocol implementation
  // ---------------------------------------------------------------------------

  @override
  ValidationResult validate(SessionMode mode) {
    final errors = <ValidationIssue>[];
    final warnings = <ValidationIssue>[];

    // ---- Check 1: Notification permission (required) ----
    if (_permissions[AppPermission.notification] != true) {
      errors.add(
        const ValidationIssue(
          title: 'Notifications disabled',
          description:
              'Guardian Angela requires notification permission to alert you '
              'and your contacts during a safety session.',
          actionLabel: 'Grant Permission',
        ),
      );
    }

    final hasSmsSte = mode.chainSteps.any(
      (s) =>
          s.type == ChainStepType.smsContact ||
          s.type == ChainStepType.phoneCallContact,
    );

    // ---- Check 2: Emergency contacts (warning if chain needs them) ----
    if (hasSmsSte && _contactCount == 0) {
      warnings.add(
        const ValidationIssue(
          title: 'No emergency contacts',
          description:
              'This mode sends alerts to your emergency contacts, but none are '
              'configured. Add at least one contact before starting.',
          actionLabel: 'Add Contact',
        ),
      );
    }

    // ---- Check 3: Required third-party apps (warning if not installed) ----
    // Uses the cache populated by prewarm(). An absent key (prewarm not yet
    // called) is treated as "unknown" and warns conservatively.
    for (final step in mode.chainSteps) {
      if (step.type != ChainStepType.smsContact) continue;
      final config = step.config as SmsContactConfig?;
      final channel = config?.channel ?? MessageChannel.sms;
      final appName = switch (channel) {
        MessageChannel.whatsapp => 'WhatsApp',
        MessageChannel.telegram => 'Telegram',
        _ => null,
      };
      if (appName != null) {
        final installed = _installedApps[appName];
        if (installed != true) {
          // Warn when not installed OR when prewarm hasn't run (installed == null).
          warnings.add(
            ValidationIssue(
              title: '$appName not confirmed installed',
              description:
                  'This mode sends messages via $appName. Ensure $appName is '
                  'installed and configured on this device.',
              actionLabel: 'Edit Mode',
            ),
          );
        }
        break;
      }
    }

    // ---- Check 4: Emergency number (required if callEmergency) ----
    final hasCallEmergency = mode.chainSteps.any(
      (s) => s.type == ChainStepType.callEmergency,
    );
    if (hasCallEmergency && _emergencyNumber.trim().isEmpty) {
      errors.add(
        const ValidationIssue(
          title: 'No emergency number',
          description:
              'This mode calls emergency services, but no emergency number is '
              'configured. Set a number in Settings.',
          actionLabel: 'Grant Permission',
        ),
      );
    }

    // ---- Check 5: Location permission (required if includeLocation) ----
    final needsLocation = mode.chainSteps.any((s) {
      if (s.type == ChainStepType.smsContact) {
        final c = s.config as SmsContactConfig?;
        return c?.includeLocation ?? true;
      }
      return false;
    });
    if (needsLocation && _permissions[AppPermission.location] != true) {
      errors.add(
        const ValidationIssue(
          title: 'Location permission required',
          description:
              'This mode attaches your GPS location to alert messages. '
              'Grant location permission to continue.',
          actionLabel: 'Grant Permission',
        ),
      );
    }

    // ---- Check 6: SMS / Phone permissions ----
    final hasSmsChannel = mode.chainSteps.any((s) {
      if (s.type == ChainStepType.smsContact) {
        final c = s.config as SmsContactConfig?;
        return (c?.channel ?? MessageChannel.sms) == MessageChannel.sms;
      }
      return false;
    });
    if (hasSmsChannel && _permissions[AppPermission.sms] != true) {
      errors.add(
        const ValidationIssue(
          title: 'SMS permission required',
          description:
              'This mode sends SMS messages. Grant the SMS permission to '
              'continue.',
          actionLabel: 'Grant Permission',
        ),
      );
    }

    final hasPhoneStep = mode.chainSteps.any(
      (s) =>
          s.type == ChainStepType.phoneCallContact ||
          s.type == ChainStepType.callEmergency,
    );
    if (hasPhoneStep && _permissions[AppPermission.phone] != true) {
      errors.add(
        const ValidationIssue(
          title: 'Phone permission required',
          description:
              'This mode makes phone calls. Grant the phone permission to '
              'continue.',
          actionLabel: 'Grant Permission',
        ),
      );
    }

    // ---- Check 7: Microphone (required if autoRecordAudio) ----
    final needsMic = mode.chainSteps.any((s) {
      if (s.type == ChainStepType.smsContact) {
        final c = s.config as SmsContactConfig?;
        return c?.autoRecordAudio ?? false;
      }
      return false;
    });
    if (needsMic && _permissions[AppPermission.microphone] != true) {
      errors.add(
        const ValidationIssue(
          title: 'Microphone permission required',
          description:
              'This mode records audio before sending an alert. Grant '
              'microphone permission to continue.',
          actionLabel: 'Grant Permission',
        ),
      );
    }

    // ---- Check 8: Battery optimization (warning, not blocking) ----
    if (!_batteryOptExempt) {
      warnings.add(
        const ValidationIssue(
          title: 'Battery optimization active',
          description:
              'The system may stop Guardian Angela during a session to save '
              'battery. Whitelist the app from battery optimization for best '
              'reliability.',
          actionLabel: 'Grant Permission',
        ),
      );
    }

    log(
      'validate: errors=${errors.length} warnings=${warnings.length}',
      name: 'SessionStartValidator',
    );
    return ValidationResult(errors: errors, warnings: warnings);
  }
}

// ---------------------------------------------------------------------------
// Private helpers
// ---------------------------------------------------------------------------

Permission _toHandlerPermission(AppPermission p) => switch (p) {
  AppPermission.sms => Permission.sms,
  AppPermission.phone => Permission.phone,
  AppPermission.location => Permission.location,
  AppPermission.microphone => Permission.microphone,
  AppPermission.camera => Permission.camera,
  AppPermission.notification => Permission.notification,
};
