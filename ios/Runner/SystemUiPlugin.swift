import Flutter
import Foundation

/// No-op stub that registers handlers for the `system_ui` and `stealth_icon`
/// MethodChannels on iOS.
///
/// Both features — Task Locking (`toggleLockTaskMode`) and launcher-icon
/// component toggling (`setStealthIconEnabled`) — are unavailable on iOS.
/// The Dart service layer already short-circuits on iOS before invoking these
/// channels, so these handlers will rarely be called. Registering them
/// prevents `MissingPluginException` noise in edge cases (e.g. a Dart code
/// path that does not yet guard `Platform.isAndroid`).
///
/// All method calls return `nil` (success) without performing any action.
final class SystemUiPlugin {

  // MARK: - Constants

  private static let systemUiChannelName = "com.guardianangela.app/system_ui"
  private static let stealthIconChannelName = "com.guardianangela.app/stealth_icon"

  // MARK: - Properties

  private let messenger: FlutterBinaryMessenger

  // MARK: - Init

  /// Creates the plugin with the given binary messenger from the Flutter engine.
  init(messenger: FlutterBinaryMessenger) {
    self.messenger = messenger
  }

  // MARK: - Registration

  /// Registers no-op MethodChannel handlers for `system_ui` and `stealth_icon`.
  func register() {
    let systemUiChannel = FlutterMethodChannel(
      name: Self.systemUiChannelName,
      binaryMessenger: messenger
    )
    systemUiChannel.setMethodCallHandler { _, result in
      // toggleLockTaskMode — no-op on iOS (Guided Access is user-initiated).
      result(nil)
    }

    let stealthChannel = FlutterMethodChannel(
      name: Self.stealthIconChannelName,
      binaryMessenger: messenger
    )
    stealthChannel.setMethodCallHandler { _, result in
      // setStealthIconEnabled — no-op on iOS (component toggling unavailable).
      result(nil)
    }
  }
}
