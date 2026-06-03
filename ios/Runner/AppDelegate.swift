import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {

  // MARK: - Properties

  /// Retained plugin instances so they are not deallocated after registration.
  private var callStatePlugin: CallStatePlugin?
  private var systemUiPlugin: SystemUiPlugin?
  /// Retained quick-exit channel so it is not deallocated after registration.
  private var quickExitChannel: FlutterMethodChannel?

  // MARK: - UIApplicationDelegate

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // MARK: - FlutterImplicitEngineDelegate

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    let registry = engineBridge.pluginRegistry

    // Register auto-generated Flutter plugins (pub.dev packages).
    GeneratedPluginRegistrant.register(with: registry)

    // Obtain a binary messenger for custom channel registration.
    // Each plugin gets its own registrar to follow the plugin contract.
    // registrar(forPlugin:) is nullable but returns nil only for a duplicate
    // plugin key; these keys are unique, so non-nil is an invariant. Fail loud
    // if it is ever violated rather than silently dropping a safety channel.
    guard
      let quickExitRegistrar = registry.registrar(forPlugin: "GuardianAngelaQuickExit"),
      let callStateRegistrar = registry.registrar(forPlugin: "GuardianAngelaCallState"),
      let systemUiRegistrar = registry.registrar(forPlugin: "GuardianAngelaSystemUi")
    else {
      fatalError("Guardian Angela plugin registrars must be non-nil")
    }

    registerQuickExit(messenger: quickExitRegistrar.messenger())

    let callState = CallStatePlugin(messenger: callStateRegistrar.messenger())
    callState.register()
    callStatePlugin = callState

    let systemUi = SystemUiPlugin(messenger: systemUiRegistrar.messenger())
    systemUi.register()
    systemUiPlugin = systemUi

    AlarmAudioPlugin.configure()
  }

  // MARK: - Quick-exit channel

  /// Registers the `com.guardianangela.app/quick_exit` MethodChannel.
  ///
  /// On invocation of `quickExit`, the process terminates immediately via
  /// `exit(0)`. iOS cannot remove the app from the app-switcher; the next
  /// launch will be a cold start.
  private func registerQuickExit(messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(
      name: "com.guardianangela.app/quick_exit",
      binaryMessenger: messenger
    )
    channel.setMethodCallHandler { call, result in
      guard call.method == "quickExit" else {
        result(FlutterMethodNotImplemented)
        return
      }
      // Acknowledge before terminating. In practice the process exits before
      // the Dart future resolves, which callers expect (fire-and-forget).
      result(nil)
      exit(0)
    }
    // Retain the channel so it is not deallocated and the handler stays live.
    quickExitChannel = channel
  }

  // MARK: - Deep-link URL handling (UIApplicationDelegate path for iOS <13)

  /// Forwards `guardianangela://` URLs to the Flutter engine so that the
  /// `home_widget` plugin's `widgetClicked` stream can deliver them to Dart.
  /// The scene-based path is handled in `SceneDelegate`.
  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
  ) -> Bool {
    return super.application(app, open: url, options: options)
  }
}
