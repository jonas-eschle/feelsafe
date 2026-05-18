import AVFoundation
import Flutter
import Foundation
import os.log

/// Configures the shared `AVAudioSession` so that the alarm can play
/// at full volume even when the device is in silent mode, and without
/// stopping other audio (it mixes and ducks).
///
/// Dart still handles the actual playback through `just_audio`; this
/// plugin only touches the audio session so that silent-switch and
/// background-mode behavior match the Android alarm path.
///
/// Channel: `com.guardianangela.app/alarm_audio`
/// Methods:
///  - `configureAlarmSession` — activates playAndRecord + mixWithOthers
///    + duckOthers. Returns `true` on success.
///  - `deactivateAlarmSession` — returns session to default
///    (`.ambient`, not active). Returns `true` on success.
///
/// Loud-fail: platform errors are surfaced as `FlutterError` so the Dart
/// side can log them; it does NOT swallow `AVAudioSession` failures.
public class AlarmAudioPlugin: NSObject, FlutterPlugin {
  private static let channelName = "com.guardianangela.app/alarm_audio"
  private static let logger = OSLog(
    subsystem: "com.guardianangela.app", category: "AlarmAudioPlugin")

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: channelName, binaryMessenger: registrar.messenger())
    let instance = AlarmAudioPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "configureAlarmSession":
      configureAlarmSession(result: result)
    case "deactivateAlarmSession":
      deactivateAlarmSession(result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func configureAlarmSession(result: @escaping FlutterResult) {
    let session = AVAudioSession.sharedInstance()
    do {
      // playAndRecord lets us mix with microphone-holding apps (voice notes),
      // while .playback would override them. mixWithOthers lets background
      // music continue; duckOthers lowers their volume while alarm plays.
      // defaultToSpeaker routes output to the loudspeaker, not the earpiece.
      try session.setCategory(
        .playAndRecord,
        mode: .default,
        options: [.mixWithOthers, .duckOthers, .defaultToSpeaker, .allowBluetooth])
      try session.setActive(true, options: [.notifyOthersOnDeactivation])
      os_log("alarm audio session configured", log: Self.logger, type: .info)
      result(true)
    } catch {
      os_log(
        "alarm audio session config failed: %{public}@", log: Self.logger, type: .error,
        error.localizedDescription)
      result(
        FlutterError(
          code: "AUDIO_SESSION_FAIL",
          message: "Failed to configure audio session: \(error.localizedDescription)",
          details: nil))
    }
  }

  private func deactivateAlarmSession(result: @escaping FlutterResult) {
    let session = AVAudioSession.sharedInstance()
    do {
      try session.setActive(false, options: [.notifyOthersOnDeactivation])
      try session.setCategory(.ambient, mode: .default, options: [])
      os_log("alarm audio session deactivated", log: Self.logger, type: .info)
      result(true)
    } catch {
      os_log(
        "alarm audio session deactivate failed: %{public}@", log: Self.logger, type: .error,
        error.localizedDescription)
      result(
        FlutterError(
          code: "AUDIO_SESSION_FAIL",
          message: "Failed to deactivate audio session: \(error.localizedDescription)",
          details: nil))
    }
  }
}
