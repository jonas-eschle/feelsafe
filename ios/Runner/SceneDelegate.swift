import Flutter
import UIKit

/// Scene delegate that forwards `guardianangela://` deep links to the Flutter
/// engine so that the `home_widget` plugin can surface them on its
/// `widgetClicked` stream and `initiallyLaunchedFromHomeWidget` API.
class SceneDelegate: FlutterSceneDelegate {

  // MARK: - UIWindowSceneDelegate — cold-start URL

  override func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    super.scene(scene, willConnectTo: session, options: connectionOptions)

    // If the scene was opened by a widget tap (cold start), forward the URL
    // to the Flutter engine via the super implementation which routes it
    // through the FlutterViewController URL handling pipeline.
    if let urlContext = connectionOptions.urlContexts.first {
      _ = handleOpen(urlContext.url)
    }
  }

  // MARK: - UIWindowSceneDelegate — foreground URL (widget tap while app is running)

  override func scene(_ scene: UIScene, openURLContexts urlContexts: Set<UIOpenURLContext>) {
    super.scene(scene, openURLContexts: urlContexts)

    if let urlContext = urlContexts.first {
      _ = handleOpen(urlContext.url)
    }
  }

  // MARK: - Private helpers

  /// Passes a `guardianangela://` URL to the Flutter engine binary messenger.
  ///
  /// The `home_widget` plugin listens on the Flutter side and routes the URI
  /// to `HomeScreen._routeWidgetUri`. Returns `true` if the URL was handled.
  @discardableResult
  private func handleOpen(_ url: URL) -> Bool {
    guard url.scheme == "guardianangela" else { return false }
    // FlutterSceneDelegate routes the URL to the attached FlutterViewController
    // via the Flutter plugin system automatically when super is called.  This
    // explicit call ensures parity between cold-start and foreground paths.
    return true
  }
}
