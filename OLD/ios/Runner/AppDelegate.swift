import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // Register custom Guardian Angela platform plugins.
    //
    // Note: iOS does NOT register the following channels (they are
    // Android-only); the corresponding Dart services fall back to URL
    // schemes or unsupported-stubs on iOS:
    //   - /sms             (iOS uses url_launcher with sms: URI)
    //   - /phone           (iOS uses url_launcher with tel: URI)
    //   - /hardware_buttons (iOS uses audio_service MediaButton)
    //   - /stealth_icon    (app-icon swap: unsupported on iOS)
    //   - /device_state    (Dart returns false on iOS)
    if let registrar = self.registrar(forPlugin: "CallStatePlugin") {
      CallStatePlugin.register(with: registrar)
    }
    if let registrar = self.registrar(forPlugin: "SystemUiPlugin") {
      SystemUiPlugin.register(with: registrar)
    }
    if let registrar = self.registrar(forPlugin: "AlarmAudioPlugin") {
      AlarmAudioPlugin.register(with: registrar)
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
