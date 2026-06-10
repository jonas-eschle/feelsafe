import 'dart:developer';

import 'package:guardianangela/domain/configs/step_config.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/orchestration/event_services.dart';
import 'package:guardianangela/domain/orchestration/event_strategy.dart';
import 'package:guardianangela/services/protocols/messaging_service_protocol.dart';

/// Unique notification ID for the loud-alarm escalation notification.
///
/// Must not collide with [kForegroundNotificationId] (1),
/// the fake-call ID (50), or the disguised-reminder base (100+).
const int _kLoudAlarmNotificationId = 51;

/// Strategy for [ChainStepType.loudAlarm] steps.
///
/// Fires the alarm sound via [AudioServiceProtocol.playAlarm] (STREAM_ALARM
/// routing, bypasses silent/vibrate), always fires the alarm vibration
/// pattern, posts an alarm escalation notification so the alarm surfaces on
/// the lock screen (spec 05:880-886), and optionally starts camera flash
/// and/or screen flash based on [LoudAlarmConfig].
///
/// **Gradual volume ramp:** The linear volume ramp (spec 02 §8 loudAlarm
/// §Gradual Volume Increase) is handled at the service level by
/// [AudioService], not in this strategy. The ramp fires only when BOTH
/// `AppSettings.alarmGradualVolume` and `LoudAlarmConfig.gradualVolume`
/// are `true`. The strategy passes the config to the service; the service
/// decides whether to ramp.
///
/// **Simulation behavior (partial-fire, no blanket short-circuit):**
/// - Vibration: always fires; local hardware, safe in sim (spec 02 line 422).
/// - Audio: always fires; [isSimulation] flag forwarded so the service mutes
///   internally at Layer 3/4 (spec 02 line 941 + line 587).
/// - Camera flash + screen flash: suppressed in sim — bystander-attracting,
///   not local-only (spec 02 line 927 "Always muted … vibration still fires").
///
/// **Note on [LoudAlarmConfig.logGps]:** This field is a per-step GPS-logging
/// override and is consumed by the orchestration layer (SessionLogRecorder /
/// LocationService), not by this strategy. The strategy does not
/// read it.
///
/// See spec 02 §8 loudAlarm.
final class LoudAlarmStrategy implements EventStrategy {
  /// Creates a [LoudAlarmStrategy].
  const LoudAlarmStrategy();

  @override
  Future<List<MessageWorkId>> executeReal(
    ChainStep step,
    EventServices services,
  ) async {
    final config = step.config is LoudAlarmConfig
        ? step.config! as LoudAlarmConfig
        : const LoudAlarmConfig();

    // Vibration: always fires the alarm pattern (overrides silent mode).
    // Local hardware — fires identically in sim per spec 02 line 422.
    await services.vibration.alarmPattern(isSimulation: services.isSimulation);

    // Audio: always fires; service mutes internally when isSimulation=true.
    // Forwarding the flag satisfies the Layer 3 contract (spec 02 line 941).
    // STREAM_ALARM routing is applied at the service level (G1 AudioService
    // fix) for spec 05:79-82 bypass of silent/vibrate modes.
    log(
      'LoudAlarmStrategy: sound=${config.soundChoice.name} '
      'volume=${config.volume} isSimulation=${services.isSimulation}',
      name: 'LoudAlarmStrategy',
    );
    // Gradual volume ramps only when BOTH the global master toggle and the
    // per-step flag are on; the duration is the global setting. Otherwise the
    // alarm jumps straight to full volume (rampSeconds: 0). DND override is the
    // global opt-in (default false) — spec 02 §loudAlarm, 06 §Alarm Settings.
    final gradual = services.alarmGradualVolume && config.gradualVolume;
    await services.audio.playAlarmWithConfig(
      soundChoice: config.soundChoice.name,
      volume: config.volume,
      isSimulation: services.isSimulation,
      rampSeconds: gradual ? services.alarmGradualVolumeDurationSeconds : 0,
      alarmDndOverride: services.alarmDndOverride,
    );

    // Alarm escalation notification: surfaces the alarm on the lock screen
    // (spec 05:880-886). Fires in real mode only (bystander-attracting).
    // The strings were resolved in the user's app language at session start
    // by the SessionController (see EventServices.alarmNotificationTitle) —
    // the domain layer stays l10n-free.
    if (!services.isSimulation) {
      await services.notification.showAlarmEscalation(
        id: _kLoudAlarmNotificationId,
        title: services.alarmNotificationTitle,
        body: services.alarmNotificationBody,
      );
    }

    // Bystander-attracting effects: suppressed in simulation.
    // Spec 02 line 927: "Always muted in simulation. Vibration still fires."
    if (!services.isSimulation) {
      // Optional camera flash: SOS morse pattern.
      if (config.flashLight) {
        await services.flash.startSosFlash();
      }

      // Optional screen flash: white/red alternating strobe.
      if (config.flashScreen) {
        // Derive speed string from flashSpeedMs:
        //   ≥ 1000 ms cycle → 'slow' (photosensitivity-safe default).
        //   < 1000 ms cycle → 'fast' (more attention-grabbing).
        final speed = config.flashSpeedMs >= 1000 ? 'slow' : 'fast';
        await services.screenFlash.startScreenFlash(speed: speed);
      }
    }
    // No SMS enqueued — nothing for the orchestrator to cancel (A5).
    return const [];
  }

  /// Returns the simulation card text.
  ///
  /// Spec 02 §Simulation behavior summary: "Muted; `[SIM]` notification
  /// shown: 'Alarm would have sounded at full volume'. Vibration still
  /// fires."
  @override
  String? simulationDescription(ChainStep step, EventServices services) =>
      'Alarm would have sounded at full volume';
}
