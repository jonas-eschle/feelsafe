import 'dart:async';
import 'dart:developer';

import 'package:home_widget/home_widget.dart';

import 'package:guardianangela/domain/enums/home_widget_status.dart';
import 'package:guardianangela/services/protocols/home_widget_service_protocol.dart';

// ─── Widget data keys (frozen contract for native agents) ────────────────────
//
// Android WidgetProvider reads these via AppWidgetManager + SharedPreferences.
// iOS WidgetKit reads them via the shared App Group UserDefaults.
//
// Key              Type      Meaning
// ──────────────── ──────── ────────────────────────────────────────────────
// ga_status        String   Status slug: "idle"|"sessionActive"|
//                            "simulationActive"
// ga_status_text   String   Pre-localised status label (e.g. "Session active")
// ga_elapsed       String   Elapsed mm:ss string, or "" when no session
// ga_quick_exit    String   Pre-localised "Quick Exit" button label
// ga_fake_call     String   Pre-localised "Fake Call" button label

/// Data key for the status slug written to widget storage.
const String kWidgetKeyStatus = 'ga_status';

/// Data key for the pre-localised status display text.
const String kWidgetKeyStatusText = 'ga_status_text';

/// Data key for the elapsed `mm:ss` string (empty when idle).
const String kWidgetKeyElapsed = 'ga_elapsed';

/// Data key for the pre-localised "Quick Exit" button label.
const String kWidgetKeyQuickExit = 'ga_quick_exit';

/// Data key for the pre-localised "Fake Call" button label.
const String kWidgetKeyFakeCall = 'ga_fake_call';

// ─── Widget identity ─────────────────────────────────────────────────────────

/// Android AppWidgetProvider class name used by [HomeWidget.updateWidget].
///
/// Must match the `android:name` attribute of the `<receiver>` in
/// AndroidManifest.xml and the class name in `GuardianAngelaAppWidget.kt`.
const String kAndroidWidgetName = 'GuardianAngelaAppWidget';

/// iOS WidgetKit widget kind (the `kind` parameter in `WidgetCenter.shared`).
///
/// Must match the `kind` string passed to `WidgetInfo` in the Swift extension.
const String kIosWidgetName = 'GuardianAngelaWidget';

/// iOS / Android App Group identifier shared between the main app and the
/// widget extension.
const String kAppGroupId = 'group.com.guardianangela.shared';

// ─── Dart-side interactivity callback dispatcher ─────────────────────────────

/// Top-level callback invoked by the `home_widget` plugin when the user taps
/// a widget button on Android.
///
/// Must be a top-level function (not a closure) because the plugin invokes
/// it via `PluginUtilities.getCallbackHandle` after the isolate is restored.
/// The URI scheme is `guardianangela://`. Known paths:
///  - `quick-exit` — end session, PIN-gated
///  - `fake-call`  — navigate to /fake-call
///
/// The app's [HomeScreen] subscribes to [HomeWidget.widgetClicked] for
/// foreground routing. This callback handles background/cold-start wakeups
/// on Android only; on iOS deep-link routing uses the standard URL scheme.
@pragma('vm:entry-point')
Future<void> homeWidgetCallback(Uri? uri) async {
  log('homeWidgetCallback: uri=$uri', name: 'HomeWidgetService');
  // Background callback: the app is not running. Log the intent; the app will
  // drain [HomeWidget.initiallyLaunchedFromHomeWidget] on next foreground entry
  // and route from there. No routing happens here to avoid a headless-Flutter
  // isolate trying to push routes on a non-existent navigator.
}

/// Real [HomeWidgetServiceProtocol] backed by `package:home_widget`.
///
/// Writes five string keys to shared widget storage then triggers a widget
/// refresh via [HomeWidget.updateWidget]. All keys are pre-localised by the
/// caller (SessionController), so the native widget renders without any l10n.
final class RealHomeWidgetService implements HomeWidgetServiceProtocol {
  /// Creates a [RealHomeWidgetService] and sets the iOS App Group id.
  ///
  /// [HomeWidget.setAppGroupId] must be called before any data can be read by
  /// the iOS widget extension; calling it in the constructor ensures it fires
  /// before the first [publishStatus].
  RealHomeWidgetService() {
    HomeWidget.setAppGroupId(kAppGroupId);
  }

  @override
  Future<void> publishStatus({
    required HomeWidgetStatus status,
    Duration? elapsed,
    required String statusText,
    required String quickExitLabel,
    required String fakeCallLabel,
  }) async {
    final elapsedStr = elapsed == null ? '' : _formatElapsed(elapsed);
    try {
      await Future.wait(<Future<void>>[
        HomeWidget.saveWidgetData<String>(
          kWidgetKeyStatus,
          status.name,
        ).then((_) {}),
        HomeWidget.saveWidgetData<String>(
          kWidgetKeyStatusText,
          statusText,
        ).then((_) {}),
        HomeWidget.saveWidgetData<String>(
          kWidgetKeyElapsed,
          elapsedStr,
        ).then((_) {}),
        HomeWidget.saveWidgetData<String>(
          kWidgetKeyQuickExit,
          quickExitLabel,
        ).then((_) {}),
        HomeWidget.saveWidgetData<String>(
          kWidgetKeyFakeCall,
          fakeCallLabel,
        ).then((_) {}),
      ]);
      await HomeWidget.updateWidget(
        androidName: kAndroidWidgetName,
        iOSName: kIosWidgetName,
      );
    } catch (e, st) {
      log(
        'HomeWidgetService.publishStatus failed: $e',
        name: 'HomeWidgetService',
        error: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<void> registerCallback() async {
    try {
      await HomeWidget.registerInteractivityCallback(homeWidgetCallback);
    } catch (e, st) {
      log(
        'HomeWidgetService.registerCallback failed: $e',
        name: 'HomeWidgetService',
        error: e,
        stackTrace: st,
      );
    }
  }

  /// Formats [d] as `mm:ss` for the widget elapsed timer.
  static String _formatElapsed(Duration d) {
    final total = d.inSeconds.clamp(0, 359999); // cap at 99h 59m 59s
    final minutes = total ~/ 60;
    final seconds = total % 60;
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }
}
