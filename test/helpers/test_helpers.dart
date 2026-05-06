/// Shared test helpers used across unit, widget, and integration tests.
///
/// - [FixedRandom] — deterministic `Random` implementation returning a
///   fixed double (default 0.5). Eliminates jitter in engine tests per
///   D-TEST-1.
/// - [step] / [holdStep] / [smsStep] / [fakeCallStep] — `ChainStep`
///   factories that cover the boilerplate (`id`, ordering, type).
/// - [makeMode] / [makeContact] / [makeDistressMode] — small model
///   factories with reasonable defaults.
/// - [makeContainer] — returns a configured `ProviderContainer`; the
///   caller is responsible for disposing it in `addTearDown`.
/// - [fixedClock] — returns a `DateTime Function()` that always returns
///   the provided instant.
library;

import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/models/models.dart';

/// Deterministic [Random] that always returns a fixed double.
///
/// Per D-TEST-1, tests that exercise timer jitter must eliminate
/// randomness. A [FixedRandom] with value 0.5 pairs with the engine's
/// ±20% jitter math to cancel out the random component while still
/// exercising the randomize code path.
final class FixedRandom implements Random {
  /// Creates a [FixedRandom] that returns [value] from [nextDouble].
  FixedRandom([this.value = 0.5]);

  /// The fixed value returned by [nextDouble]. Defaults to 0.5.
  final double value;

  @override
  bool nextBool() => value >= 0.5;

  @override
  double nextDouble() => value;

  @override
  int nextInt(int max) {
    if (max <= 0) {
      throw RangeError.range(max, 1, null, 'max');
    }
    final scaled = (value * max).floor();
    return scaled >= max ? max - 1 : scaled;
  }
}

/// Builds a [ChainStep] with sensible defaults so each test only
/// specifies what it cares about.
///
/// [id] — defaults to a deterministic value derived from [order] and
/// [type].
/// [type] — defaults to [ChainStepType.holdButton].
/// [order] — defaults to 0.
/// [durationSeconds] — defaults to 30.
/// [gracePeriodSeconds] — defaults to 5.
/// [waitSeconds] — defaults to 0.
/// [retryCount] — defaults to 0.
/// [randomize] — defaults to 0.0.
/// [config] — defaults to null (engine falls back to event defaults).
ChainStep step({
  String? id,
  ChainStepType type = ChainStepType.holdButton,
  int order = 0,
  int durationSeconds = 30,
  int gracePeriodSeconds = 5,
  int waitSeconds = 0,
  int retryCount = 0,
  double randomize = 0.0,
  StepConfig? config,
}) => ChainStep(
  id: id ?? 'step-$order-${type.name}',
  type: type,
  order: order,
  durationSeconds: durationSeconds,
  gracePeriodSeconds: gracePeriodSeconds,
  waitSeconds: waitSeconds,
  retryCount: retryCount,
  randomize: randomize,
  config: config,
);

/// Builds a hold-button [ChainStep] with [HoldButtonConfig].
ChainStep holdStep({
  String? id,
  int order = 0,
  int durationSeconds = 30,
  int gracePeriodSeconds = 5,
  double releaseSensitivity = 0.3,
}) => step(
  id: id,
  type: ChainStepType.holdButton,
  order: order,
  durationSeconds: durationSeconds,
  gracePeriodSeconds: gracePeriodSeconds,
  config: HoldButtonConfig(releaseSensitivity: releaseSensitivity),
);

/// Builds an SMS-contact [ChainStep] with [SmsContactConfig].
ChainStep smsStep({
  String? id,
  int order = 0,
  int durationSeconds = 10,
  int gracePeriodSeconds = 0,
  String? message,
  List<String>? contactIds,
}) => step(
  id: id,
  type: ChainStepType.smsContact,
  order: order,
  durationSeconds: durationSeconds,
  gracePeriodSeconds: gracePeriodSeconds,
  config: SmsContactConfig(
    contactIds: contactIds,
    contactSelection: contactIds == null
        ? SmsContactSelection.allContacts
        : SmsContactSelection.specificIds,
    messageTemplate: message,
  ),
);

/// Builds a fake-call [ChainStep] with [FakeCallConfig].
ChainStep fakeCallStep({
  String? id,
  int order = 0,
  int durationSeconds = 30,
  int gracePeriodSeconds = 5,
  bool declineIsSafe = false,
}) => step(
  id: id,
  type: ChainStepType.fakeCall,
  order: order,
  durationSeconds: durationSeconds,
  gracePeriodSeconds: gracePeriodSeconds,
  config: FakeCallConfig(declineIsSafe: declineIsSafe),
);

/// Builds a [SessionMode] for tests.
///
/// [id] — defaults to `'mode-<name>'`.
/// [name] — defaults to 'Test'.
/// [checkInType] — defaults to [ChainStepType.holdButton].
/// [steps] — defaults to a single [holdStep] at order 0.
/// [distressModeId] — defaults to null (use repo's first chain).
SessionMode makeMode({
  String? id,
  String name = 'Test',
  ChainStepType checkInType = ChainStepType.holdButton,
  List<ChainStep>? steps,
  String? distressModeId,
}) => SessionMode(
  id: id ?? 'mode-$name',
  name: name,
  checkInType: checkInType,
  chainSteps: steps ?? [holdStep()],
  distressModeId: distressModeId,
);

/// Builds an [EmergencyContact] for tests.
///
/// [id] — defaults to `'contact-<name>'`.
/// [name] — defaults to 'Alice'.
/// [phoneNumber] — defaults to '+15551234567'.
/// [sortOrder] — defaults to 0.
/// [channels] — defaults to `[MessageChannel.sms]`.
EmergencyContact makeContact({
  String? id,
  String name = 'Alice',
  String phoneNumber = '+15551234567',
  int sortOrder = 0,
  List<MessageChannel>? channels,
}) => EmergencyContact(
  id: id ?? 'contact-$name',
  name: name,
  phoneNumber: phoneNumber,
  sortOrder: sortOrder,
  channels: channels ?? const [MessageChannel.sms],
);

/// Builds a distress-flagged [SessionMode] for tests.
///
/// [id] — defaults to 'default'.
/// [name] — defaults to 'Default'.
/// [steps] — defaults to a single [smsStep].
SessionMode makeDistressMode({
  String id = 'default',
  String name = 'Default',
  List<ChainStep>? steps,
}) {
  final s = steps ?? [smsStep()];
  return SessionMode(
    id: id,
    name: name,
    checkInType: s.first.type,
    chainSteps: s,
    isDistressMode: true,
  );
}

/// Builds a configured [ProviderContainer].
///
/// Caller is responsible for disposing via
/// `addTearDown(container.dispose)`.
ProviderContainer makeContainer({List<Override> overrides = const []}) =>
    ProviderContainer(overrides: overrides);

/// Returns a `DateTime Function()` that always returns [fixed].
DateTime Function() fixedClock(DateTime fixed) =>
    () => fixed;
