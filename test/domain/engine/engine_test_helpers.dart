import 'dart:math';

import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/models/session_mode.dart';
import 'package:guardianangela/domain/triggers/disarm_trigger.dart';
import 'package:guardianangela/domain/triggers/distress_trigger.dart';
import 'package:uuid/uuid.dart';

/// A [Random] subclass that always returns a fixed value.
///
/// With [value] = 0.5: jitter factor = 0.8 + 0.5 * 0.4 = 1.0 (no jitter).
/// This makes timing deterministic in tests.
final class FixedRandom implements Random {
  /// Creates a fixed-value random that always returns [value].
  ///
  /// [value] defaults to 0.5 — eliminates jitter (factor = 1.0).
  const FixedRandom([this.value = 0.5]);

  /// The fixed value returned by [nextDouble].
  final double value;

  @override
  double nextDouble() => value;

  @override
  int nextInt(int max) => (value * (max - 1)).round().clamp(0, max - 1);

  @override
  bool nextBool() => value >= 0.5;
}

const _uuid = Uuid();

/// Factory for [ChainStep] with sensible defaults — minimal boilerplate in
/// tests.
///
/// All time fields default to sensible short values so tests can use
/// `fakeAsync` without huge elapsed durations.
ChainStep step({
  ChainStepType type = ChainStepType.loudAlarm,
  int waitSeconds = 0,
  int durationSeconds = 10,
  int gracePeriodSeconds = 5,
  int retryCount = 0,
  bool randomize = false,
  int order = 0,
}) => ChainStep(
  id: _uuid.v4(),
  type: type,
  order: order,
  waitSeconds: waitSeconds,
  durationSeconds: durationSeconds,
  gracePeriodSeconds: gracePeriodSeconds,
  retryCount: retryCount,
  randomize: randomize,
);

/// Factory for a [SessionMode] with sensible defaults.
SessionMode mode({
  List<ChainStep>? chainSteps,
  List<DistressTrigger>? distressTriggers,
  List<DisarmTrigger>? disarmTriggers,
  bool allowDisarmAsDistress = true,
  bool isDistressMode = false,
  int? maxPauseMinutes,
}) => SessionMode(
  id: _uuid.v4(),
  name: 'Test Mode',
  chainSteps: chainSteps ?? [step(), step(type: ChainStepType.callEmergency)],
  distressTriggers: distressTriggers ?? const [],
  disarmTriggers: disarmTriggers ?? const [],
  allowDisarmAsDistress: allowDisarmAsDistress,
  isDistressMode: isDistressMode,
  maxPauseMinutes: maxPauseMinutes,
);
