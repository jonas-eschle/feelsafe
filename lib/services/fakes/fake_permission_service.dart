/// Deterministic fake implementation of [PermissionServiceProtocol]
/// for tests. Records every call to [calls] and returns scripted
/// values so tests can pin down behaviour for permanent-denied or
/// granted flows.
library;

import 'package:guardianangela/services/protocols/permission_service_protocol.dart';

/// Test double for [PermissionServiceProtocol].
final class FakePermissionService implements PermissionServiceProtocol {
  /// Creates a fake permission service.
  ///
  /// All `ensure…` methods default to `true` (granted). Tests that
  /// want a denied flow set the corresponding field to `false` after
  /// construction.
  FakePermissionService({
    this.notificationGranted = true,
    this.locationGranted = true,
    this.callPhoneGranted = true,
    this.sendSmsGranted = true,
    this.batteryOptimizationExempt = true,
  });

  /// Invocation log: one entry per method call.
  final List<String> calls = [];

  /// Scripted return for [ensureNotification].
  bool notificationGranted;

  /// Scripted return for [ensureLocation].
  bool locationGranted;

  /// Scripted return for [ensureCallPhone].
  bool callPhoneGranted;

  /// Scripted return for [ensureSendSms].
  bool sendSmsGranted;

  /// Scripted return for [ensureBatteryOptimizationExempt].
  bool batteryOptimizationExempt;

  @override
  Future<bool> ensureNotification() async {
    calls.add('ensureNotification');
    return notificationGranted;
  }

  @override
  Future<bool> ensureLocation({
    LocationPermissionLevel level = LocationPermissionLevel.whenInUse,
  }) async {
    calls.add('ensureLocation:${level.name}');
    return locationGranted;
  }

  @override
  Future<bool> ensureCallPhone() async {
    calls.add('ensureCallPhone');
    return callPhoneGranted;
  }

  @override
  Future<bool> ensureSendSms() async {
    calls.add('ensureSendSms');
    return sendSmsGranted;
  }

  @override
  Future<bool> ensureBatteryOptimizationExempt() async {
    calls.add('ensureBatteryOptimizationExempt');
    return batteryOptimizationExempt;
  }

  @override
  Future<void> openAppSettings() async {
    calls.add('openAppSettings');
  }
}
