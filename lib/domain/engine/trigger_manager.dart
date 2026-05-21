import 'dart:async';

import 'package:guardianangela/domain/enums/end_reason.dart';
import 'package:guardianangela/domain/triggers/disarm_trigger.dart';
import 'package:guardianangela/domain/triggers/distress_trigger.dart';

/// Manages parallel distress and disarm triggers alongside the main engine.
///
/// Triggers run independently of the chain steps — they are not chain steps
/// themselves. See spec 03 §DistressTrigger / §DisarmTrigger and spec 01
/// §Invariant 13 (G-014).
///
/// Distress triggers fire the mode's distress chain via [onDistress].
/// Disarm triggers end the session via [onDisarm], subject to the
/// [allowDisarmDuringDistress] gate when the engine is running a distress
/// chain.
final class TriggerManager {
  /// Creates a trigger manager.
  ///
  /// [distressTriggers] and [disarmTriggers] are the mode's configured
  /// trigger lists. [allowDisarmDuringDistress] mirrors
  /// [SessionMode.allowDisarmAsDistress] and governs whether [onDisarm]
  /// fires while the engine is in distress-chain mode (G-014).
  TriggerManager({
    required List<DistressTrigger> distressTriggers,
    required List<DisarmTrigger> disarmTriggers,
    required void Function(EndReason reason) onDistress,
    required void Function() onDisarm,
    bool allowDisarmDuringDistress = true,
  }) : _distressTriggers = List.unmodifiable(distressTriggers),
       _disarmTriggers = List.unmodifiable(disarmTriggers),
       _onDistress = onDistress,
       _onDisarm = onDisarm,
       _allowDisarmDuringDistress = allowDisarmDuringDistress;

  final List<DistressTrigger> _distressTriggers;
  final List<DisarmTrigger> _disarmTriggers;
  final void Function(EndReason reason) _onDistress;
  final void Function() _onDisarm;
  final bool _allowDisarmDuringDistress;

  /// Whether the engine is currently running the distress chain.
  ///
  /// Set to true by [enterDistressMode]; affects whether disarm triggers
  /// are honoured per G-014.
  bool _inDistressMode = false;

  /// Active timer subscriptions (timer-based disarm triggers).
  final List<Timer> _timers = [];

  /// Whether the manager has been stopped.
  bool _stopped = false;

  /// Start monitoring all configured triggers.
  ///
  /// Activates [TimerDisarmTrigger]s immediately. GPS and hardware-button
  /// triggers are activated externally via [notifyGpsArrival] and
  /// [notifyHardwarePanic].
  void start() {
    if (_stopped) {
      return;
    }
    for (final trigger in _disarmTriggers) {
      if (trigger is TimerDisarmTrigger) {
        _startTimerDisarm(trigger);
      }
    }
  }

  /// Stop all active trigger timers. Idempotent.
  void stop() {
    _stopped = true;
    for (final t in _timers) {
      t.cancel();
    }
    _timers.clear();
  }

  /// Notify that the engine has entered distress-chain mode.
  ///
  /// Once called, [onDisarm] will only fire for disarm triggers if
  /// [allowDisarmDuringDistress] is true (G-014).
  void enterDistressMode() {
    _inDistressMode = true;
    // Re-evaluate: if disarm is not allowed during distress, cancel timers.
    if (!_allowDisarmDuringDistress) {
      for (final t in _timers) {
        t.cancel();
      }
      _timers.clear();
    }
  }

  /// Notify that GPS arrival was detected.
  ///
  /// Fires [onDisarm] if the mode has a [GpsArrivalDisarmTrigger] and
  /// [allowDisarmDuringDistress] permits it.
  void notifyGpsArrival() {
    if (_stopped) {
      return;
    }
    final hasGpsTrigger = _disarmTriggers.any(
      (t) => t is GpsArrivalDisarmTrigger,
    );
    if (!hasGpsTrigger) {
      return;
    }
    if (_inDistressMode && !_allowDisarmDuringDistress) {
      return;
    }
    _onDisarm();
  }

  /// Notify that a hardware panic sequence was detected.
  ///
  /// Fires [onDistress] with [EndReason.hardwarePanic] if the mode has a
  /// [HardwareButtonDistressTrigger]. Hardware panic always fires distress,
  /// even during an active distress chain (ignored when distress already
  /// active — caller checks [SessionEngine.isDistressChain]).
  void notifyHardwarePanic() {
    if (_stopped) {
      return;
    }
    final hasTrigger = _distressTriggers.any(
      (t) => t is HardwareButtonDistressTrigger,
    );
    if (!hasTrigger) {
      return;
    }
    _onDistress(EndReason.hardwarePanic);
  }

  void _startTimerDisarm(TimerDisarmTrigger trigger) {
    final duration = Duration(seconds: trigger.durationSeconds);
    final timer = Timer(duration, () {
      if (_stopped) {
        return;
      }
      if (_inDistressMode && !_allowDisarmDuringDistress) {
        return;
      }
      _onDisarm();
    });
    _timers.add(timer);
  }
}
