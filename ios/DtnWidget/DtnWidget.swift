import WidgetKit
import SwiftUI

// "Do The Next" widget. Reads the current top task pushed from Flutter via the
// home_widget plugin (shared App Group UserDefaults). Supports Home Screen and
// iOS 16+ Lock Screen widgets.
//
// SETUP (must be done in Xcode — see ios/DtnWidget/SETUP.md):
//   • Add a Widget Extension target named "DtnWidget".
//   • Add App Group "group.com.taskera.taskera_app" to BOTH the app and the extension.
//   • Set the App Group id below to match.

private let appGroupId = "group.com.taskera.taskera_app"

struct DtnEntry: TimelineEntry {
    let date: Date
    let title: String
    let meta: String
}

struct DtnProvider: TimelineProvider {
    private func read() -> DtnEntry {
        let defaults = UserDefaults(suiteName: appGroupId)
        let title = defaults?.string(forKey: "dtn_title") ?? "Nothing queued"
        let meta  = defaults?.string(forKey: "dtn_meta") ?? "Do The Next"
        return DtnEntry(date: Date(), title: title, meta: meta)
    }

    func placeholder(in context: Context) -> DtnEntry {
        DtnEntry(date: Date(), title: "Finish the auth flow", meta: "Q2")
    }

    func getSnapshot(in context: Context, completion: @escaping (DtnEntry) -> Void) {
        completion(read())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DtnEntry>) -> Void) {
        completion(Timeline(entries: [read()], policy: .never))
    }
}

struct DtnWidgetEntryView: View {
    var entry: DtnEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(entry.meta.uppercased())
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(Color(red: 0.50, green: 0.73, blue: 0.0))
            Text(entry.title)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.primary)
                .lineLimit(2)
            Spacer(minLength: 0)
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .widgetURL(URL(string: "taskeraapp://focus"))
    }
}

@main
struct DtnWidget: Widget {
    let kind: String = "DtnWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DtnProvider()) { entry in
            DtnWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Do The Next")
        .description("Your current top task at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryRectangular])
    }
}
