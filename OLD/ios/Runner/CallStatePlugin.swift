import CallKit
import Flutter
import Foundation
import os.log

/// Reports incoming/outgoing call state changes (ringing / active / ended)
/// to Dart via a `FlutterEventChannel`.
///
/// Uses `CXCallObserver` (CallKit) which fires whenever a call on the
/// device transitions states — including cellular, FaceTime, and VoIP.
/// The observer does **not** require any special permission on iOS 17+
/// because CallKit itself gatekeeps the APIs.
///
/// Channels:
///  - method channel `com.guardianangela.app/call_state`:
///      - `getCurrentState` -> String (`"idle"` / `"ringing"` / `"active"`)
///  - event channel `com.guardianangela.app/call_state_events`:
///      - emits String events on every state change.
public class CallStatePlugin: NSObject, FlutterPlugin, FlutterStreamHandler,
  CXCallObserverDelegate
{
  private static let methodChannelName = "com.guardianangela.app/call_state"
  private static let eventChannelName = "com.guardianangela.app/call_state_events"
  private static let logger = OSLog(
    subsystem: "com.guardianangela.app", category: "CallStatePlugin")

  private let callObserver = CXCallObserver()
  private var eventSink: FlutterEventSink?
  private var lastState: String = "idle"

  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = CallStatePlugin()
    let methodChannel = FlutterMethodChannel(
      name: methodChannelName, binaryMessenger: registrar.messenger())
    registrar.addMethodCallDelegate(instance, channel: methodChannel)

    let eventChannel = FlutterEventChannel(
      name: eventChannelName, binaryMessenger: registrar.messenger())
    eventChannel.setStreamHandler(instance)
  }

  public override init() {
    super.init()
    callObserver.setDelegate(self, queue: DispatchQueue.main)
  }

  // MARK: - FlutterPlugin

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getCurrentState":
      result(currentState())
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  // MARK: - FlutterStreamHandler

  public func onListen(
    withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink
  ) -> FlutterError? {
    eventSink = events
    // Push current state immediately so late subscribers don't miss it.
    events(currentState())
    return nil
  }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    eventSink = nil
    return nil
  }

  // MARK: - CXCallObserverDelegate

  public func callObserver(_ observer: CXCallObserver, callChanged call: CXCall) {
    let newState: String
    if call.hasEnded {
      newState = "ended"
    } else if call.isOutgoing && !call.hasConnected {
      newState = "ringing"  // outgoing, still dialing
    } else if !call.isOutgoing && !call.hasConnected {
      newState = "ringing"  // incoming, not yet answered
    } else if call.hasConnected {
      newState = "active"
    } else {
      newState = "idle"
    }

    guard newState != lastState else { return }
    lastState = newState
    os_log("call state -> %{public}@", log: Self.logger, type: .info, newState)
    eventSink?(newState)

    // After "ended" settle back to idle so subsequent calls start clean.
    if newState == "ended" {
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
        guard let self else { return }
        if self.lastState == "ended" {
          self.lastState = "idle"
          self.eventSink?("idle")
        }
      }
    }
  }

  // MARK: - Helpers

  private func currentState() -> String {
    for call in callObserver.calls {
      if call.hasEnded { continue }
      if call.hasConnected { return "active" }
      return "ringing"
    }
    return "idle"
  }
}
