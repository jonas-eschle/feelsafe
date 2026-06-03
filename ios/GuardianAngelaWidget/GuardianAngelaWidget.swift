import AppIntents
import SwiftUI
import WidgetKit

// MARK: - App Group shared storage

/// Reads Guardian Angela widget data from the shared App Group UserDefaults.
///
/// All keys are written by `RealHomeWidgetService.publishStatus` in Dart via
/// the `home_widget` plugin (key contract: home-widget-contract.md §1).
///
/// Internal (not `private`): it is the type of `GuardianAngelaEntry.data`, an
/// internal `TimelineEntry` property, so its access level must be at least as
/// visible as that property.
struct WidgetData {
  let status: String
  let statusText: String
  let elapsed: String
  let quickExitLabel: String
  let fakeCallLabel: String

  /// Default values match the contract's "idle" state.
  static let placeholder = WidgetData(
    status: "idle",
    statusText: "Idle",
    elapsed: "",
    quickExitLabel: "Quick Exit",
    fakeCallLabel: "Fake Call"
  )

  /// Reads from `group.com.guardianangela.shared` UserDefaults.
  static func read() -> WidgetData {
    let defaults = UserDefaults(suiteName: "group.com.guardianangela.shared")
    return WidgetData(
      status: defaults?.string(forKey: "ga_status") ?? "idle",
      statusText: defaults?.string(forKey: "ga_status_text") ?? "Idle",
      elapsed: defaults?.string(forKey: "ga_elapsed") ?? "",
      quickExitLabel: defaults?.string(forKey: "ga_quick_exit") ?? "Quick Exit",
      fakeCallLabel: defaults?.string(forKey: "ga_fake_call") ?? "Fake Call"
    )
  }

  /// Whether a session is currently active (elapsed timer should be shown).
  var isSessionActive: Bool { status != "idle" }
}

// MARK: - TimelineEntry

struct GuardianAngelaEntry: TimelineEntry {
  let date: Date
  let data: WidgetData
}

// MARK: - TimelineProvider

struct GuardianAngelaProvider: TimelineProvider {

  func placeholder(in context: Context) -> GuardianAngelaEntry {
    GuardianAngelaEntry(date: .now, data: .placeholder)
  }

  func getSnapshot(in context: Context, completion: @escaping (GuardianAngelaEntry) -> Void) {
    completion(GuardianAngelaEntry(date: .now, data: context.isPreview ? .placeholder : .read()))
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<GuardianAngelaEntry>) -> Void) {
    let entry = GuardianAngelaEntry(date: .now, data: .read())
    // The widget does not self-refresh on a timer — it is driven by
    // WidgetCenter.reloadAllTimelines() called from the Dart side via
    // HomeWidget.updateWidget(). Use .never to avoid spurious reloads.
    completion(Timeline(entries: [entry], policy: .never))
  }
}

// MARK: - Widget views

/// Root widget view — dispatches to the appropriate button implementation
/// based on the iOS version.
struct GuardianAngelaWidgetView: View {
  let entry: GuardianAngelaEntry

  var body: some View {
    VStack(alignment: .leading, spacing: 6) {
      StatusLineView(data: entry.data)
      Spacer(minLength: 4)
      ButtonRowView(data: entry.data)
    }
    .padding(12)
    .background(Color(.systemBackground))
  }
}

private struct StatusLineView: View {
  let data: WidgetData

  var body: some View {
    VStack(alignment: .leading, spacing: 2) {
      Text(data.statusText)
        .font(.headline)
        .lineLimit(1)
      if data.isSessionActive && !data.elapsed.isEmpty {
        Text(data.elapsed)
          .font(.subheadline.monospacedDigit())
          .foregroundStyle(.secondary)
      }
    }
  }
}

/// Renders the Quick Exit and Fake Call buttons using the strategy appropriate
/// for the running OS version.
private struct ButtonRowView: View {
  let data: WidgetData

  var body: some View {
    HStack(spacing: 8) {
      quickExitButton
      fakeCallButton
    }
  }

  @ViewBuilder
  private var quickExitButton: some View {
    if #available(iOS 17.0, *) {
      Button(intent: QuickExitIntent()) {
        WidgetButtonLabel(title: data.quickExitLabel, color: .red)
      }
      .buttonStyle(.plain)
    } else {
      // iOS 16 fallback: open the app via URL scheme; Dart routes the URI.
      Link(destination: URL(string: "guardianangela://quick-exit")!) {
        WidgetButtonLabel(title: data.quickExitLabel, color: .red)
      }
    }
  }

  @ViewBuilder
  private var fakeCallButton: some View {
    if #available(iOS 17.0, *) {
      Button(intent: FakeCallIntent()) {
        WidgetButtonLabel(title: data.fakeCallLabel, color: .blue)
      }
      .buttonStyle(.plain)
    } else {
      Link(destination: URL(string: "guardianangela://fake-call")!) {
        WidgetButtonLabel(title: data.fakeCallLabel, color: .blue)
      }
    }
  }
}

private struct WidgetButtonLabel: View {
  let title: String
  let color: Color

  var body: some View {
    Text(title)
      .font(.caption.bold())
      .foregroundStyle(.white)
      .padding(.horizontal, 10)
      .padding(.vertical, 6)
      .frame(maxWidth: .infinity)
      .background(color, in: RoundedRectangle(cornerRadius: 8))
  }
}

// MARK: - AppIntents (iOS 17+)

/// Interactive widget intent that triggers the Quick Exit flow.
///
/// Setting `openAppWhenRun = true` causes the system to foreground the app
/// before `perform()` executes. The `home_widget` Dart layer then receives
/// the URI and `HomeScreen._routeWidgetUri` routes to the session screen.
@available(iOS 17.0, *)
struct QuickExitIntent: AppIntent {
  static let title: LocalizedStringResource = "Quick Exit"
  static let description = IntentDescription("Trigger Guardian Angela Quick Exit.")
  static let openAppWhenRun: Bool = true

  func perform() async throws -> some IntentResult {
    return .result()
  }
}

/// Interactive widget intent that opens the Fake Call screen.
@available(iOS 17.0, *)
struct FakeCallIntent: AppIntent {
  static let title: LocalizedStringResource = "Fake Call"
  static let description = IntentDescription("Trigger a Guardian Angela fake call.")
  static let openAppWhenRun: Bool = true

  func perform() async throws -> some IntentResult {
    return .result()
  }
}

// MARK: - Widget declaration

/// The WidgetKit widget for Guardian Angela.
///
/// `kind` must match the `iOSName` passed to `HomeWidget.updateWidget()` in
/// Dart (home-widget-contract.md §3 / §5).
struct GuardianAngelaWidget: Widget {
  let kind: String = "GuardianAngelaWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: GuardianAngelaProvider()) { entry in
      GuardianAngelaWidgetView(entry: entry)
    }
    .configurationDisplayName("Guardian Angela")
    .description("Monitor your active session and trigger Quick Exit or a Fake Call.")
    .supportedFamilies([.systemSmall, .systemMedium])
  }
}

// MARK: - WidgetBundle entry point

@main
struct GuardianAngelaWidgetBundle: WidgetBundle {
  var body: some Widget {
    GuardianAngelaWidget()
  }
}

// MARK: - Previews

struct GuardianAngelaWidget_Previews: PreviewProvider {
  static var previews: some View {
    GuardianAngelaWidgetView(
      entry: GuardianAngelaEntry(date: .now, data: .placeholder)
    )
    .previewContext(WidgetPreviewContext(family: .systemMedium))

    GuardianAngelaWidgetView(
      entry: GuardianAngelaEntry(
        date: .now,
        data: WidgetData(
          status: "sessionActive",
          statusText: "Session active",
          elapsed: "12:34",
          quickExitLabel: "Quick Exit",
          fakeCallLabel: "Fake Call"
        )
      )
    )
    .previewContext(WidgetPreviewContext(family: .systemMedium))
  }
}
