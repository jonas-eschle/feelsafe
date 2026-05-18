import Flutter
import Foundation
import UIKit
import os.log

/// Stub implementation of the shared `com.guardianangela.app/system_ui`
/// method channel. Android exposes real OS-level integrations
/// (`finishAndRemoveTask`, battery-optimization exemption); iOS has
/// equivalent concepts either missing or forbidden by Apple HIG, so the
/// plugin returns success with neutral values and logs a warning.
///
/// Supported methods:
///  - `quickExit`
///      No-op. iOS apps are not permitted to terminate themselves and
///      doing so is explicitly rejected in Apple Human Interface
///      Guidelines. Returns `true`.
///  - `requestBatteryOptimizationExemption`
///      No-op. iOS has no equivalent user-facing toggle; power
///      management is automatic. Returns `false` (no change made).
///  - `isBatteryOptimized`
///      Always returns `false`. iOS does not expose doze-mode state.
public class SystemUiPlugin: NSObject, FlutterPlugin {
  private static let channelName = "com.guardianangela.app/system_ui"
  private static let logger = OSLog(
    subsystem: "com.guardianangela.app", category: "SystemUiPlugin")

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: channelName, binaryMessenger: registrar.messenger())
    let instance = SystemUiPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "quickExit":
      os_log(
        "quickExit requested — iOS does not allow programmatic app termination (Apple HIG). Ignoring.",
        log: Self.logger, type: .info)
      result(true)
    case "requestBatteryOptimizationExemption":
      os_log(
        "requestBatteryOptimizationExemption requested — not applicable on iOS. Ignoring.",
        log: Self.logger, type: .info)
      result(false)
    case "isBatteryOptimized":
      // iOS has no equivalent of Android Doze whitelisting that the app
      // can query. Always report "not optimized" so Dart callers don't
      // badger the user.
      result(false)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
