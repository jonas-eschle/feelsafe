import CallKit
import Flutter
import Foundation

/// Bridges CallKit `CXCallObserver` telephony state into the Flutter engine.
///
/// Registers two channels under the shared name string
/// `com.guardianangela.app/call_state`:
///
/// - **MethodChannel** — Dart calls `startListening` / `stopListening` to
///   arm/disarm event delivery.
/// - **EventChannel** — emits `"idle"`, `"ringing"`, or `"offhook"` strings
///   to the Dart `_onNativeEvent` handler in `call_state_service.dart`.
///
/// CXCallObserver is reliable only while audio is active (partial coverage on
/// iOS — see contract §2.2 / spec 10 §iOS Limitations).
final class CallStatePlugin: NSObject {

  // MARK: - Constants

  private static let channelName = "com.guardianangela.app/call_state"

  // MARK: - Properties

  private let messenger: FlutterBinaryMessenger
  private let callObserver = CXCallObserver()
  private var eventSink: FlutterEventSink?
  private var isListening = false

  // MARK: - Init

  /// Creates the plugin with the given binary messenger from the Flutter engine.
  init(messenger: FlutterBinaryMessenger) {
    self.messenger = messenger
    super.init()
    callObserver.setDelegate(self, queue: .main)
  }

  // MARK: - Registration

  /// Registers the MethodChannel and EventChannel with the Flutter engine.
  func register() {
    let methodChannel = FlutterMethodChannel(
      name: Self.channelName,
      binaryMessenger: messenger
    )
    methodChannel.setMethodCallHandler(handleMethodCall(_:result:))

    let eventChannel = FlutterEventChannel(
      name: Self.channelName,
      binaryMessenger: messenger
    )
    eventChannel.setStreamHandler(self)
  }

  // MARK: - MethodChannel handler

  private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "startListening":
      isListening = true
      // Emit the current state immediately so Dart has a baseline.
      emitCurrentState()
      result(nil)
    case "stopListening":
      isListening = false
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  // MARK: - State helpers

  /// Derives the current telephony state from the active CX calls and emits it.
  private func emitCurrentState() {
    guard isListening, let sink = eventSink else { return }
    let stateString = callStateString(for: callObserver.calls)
    sink(stateString)
  }

  /// Maps the current set of CX calls to one of the three Dart-expected strings.
  private func callStateString(for calls: [CXCall]) -> String {
    guard !calls.isEmpty else { return "idle" }
    let hasConnected = calls.contains { $0.hasConnected && !$0.hasEnded }
    let hasIncoming = calls.contains { !$0.isOutgoing && !$0.hasConnected && !$0.hasEnded }
    if hasConnected {
      return "offhook"
    } else if hasIncoming {
      return "ringing"
    }
    return "idle"
  }
}

// MARK: - CXCallObserverDelegate

extension CallStatePlugin: CXCallObserverDelegate {
  func callObserver(_ callObserver: CXCallObserver, callChanged call: CXCall) {
    guard isListening else { return }
    emitCurrentState()
  }
}

// MARK: - FlutterStreamHandler

extension CallStatePlugin: FlutterStreamHandler {

  /// Called by the Flutter engine when Dart subscribes to the EventChannel.
  func onListen(
    withArguments arguments: Any?,
    eventSink events: @escaping FlutterEventSink
  ) -> FlutterError? {
    eventSink = events
    // Emit the baseline state if startListening was already called.
    if isListening {
      emitCurrentState()
    }
    return nil
  }

  /// Called by the Flutter engine when Dart cancels the EventChannel subscription.
  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    eventSink = nil
    return nil
  }
}
