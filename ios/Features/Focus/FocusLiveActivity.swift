import ActivityKit
import SwiftUI
import WidgetKit

struct FocusActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var taskTitle: String
        var elapsedSeconds: Int
        var plannedMinutes: Int
        var isPaused: Bool
    }

    var sessionName: String
}

@MainActor
enum FocusLiveActivityManager {
    private static var currentActivity: Activity<FocusActivityAttributes>?

    static var isSupported: Bool {
        ActivityAuthorizationInfo().areActivitiesEnabled
    }

    static func start(taskTitle: String, plannedMinutes: Int) {
        guard isSupported else { return }
        end()

        let attributes = FocusActivityAttributes(sessionName: "Focus")
        let state = FocusActivityAttributes.ContentState(
            taskTitle: taskTitle,
            elapsedSeconds: 0,
            plannedMinutes: plannedMinutes,
            isPaused: false
        )

        do {
            currentActivity = try Activity.request(
                attributes: attributes,
                content: .init(state: state, staleDate: nil),
                pushType: nil
            )
        } catch {
            print("Live Activity start failed: \(error)")
        }
    }

    static func update(elapsedSeconds: Int, isPaused: Bool, taskTitle: String, plannedMinutes: Int) {
        guard let activity = currentActivity else { return }
        let state = FocusActivityAttributes.ContentState(
            taskTitle: taskTitle,
            elapsedSeconds: elapsedSeconds,
            plannedMinutes: plannedMinutes,
            isPaused: isPaused
        )
        Task {
            await activity.update(ActivityContent(state: state, staleDate: nil))
        }
    }

    static func end() {
        guard let activity = currentActivity else { return }
        Task {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
        currentActivity = nil
    }
}

struct FocusLiveActivityView: View {
    let context: ActivityViewContext<FocusActivityAttributes>

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "bolt.fill")
                .foregroundStyle(.purple)
            VStack(alignment: .leading, spacing: 2) {
                Text(context.state.taskTitle)
                    .font(.headline)
                    .lineLimit(1)
                Text(formattedTime(context.state.elapsedSeconds))
                    .font(.title2.monospacedDigit().bold())
                if context.state.isPaused {
                    Text("Paused")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            ProgressView(value: progress)
                .tint(.purple)
                .frame(width: 40)
        }
        .padding()
    }

    private var progress: Double {
        let total = max(context.state.plannedMinutes * 60, 1)
        return min(Double(context.state.elapsedSeconds) / Double(total), 1)
    }

    private func formattedTime(_ seconds: Int) -> String {
        let m = (seconds % 3600) / 60
        let s = seconds % 60
        let h = seconds / 3600
        if h > 0 { return String(format: "%02d:%02d:%02d", h, m, s) }
        return String(format: "%02d:%02d", m, s)
    }
}

@available(iOS 16.2, *)
struct FocusLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: FocusActivityAttributes.self) { context in
            FocusLiveActivityView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: "bolt.fill").foregroundStyle(.purple)
                }
                DynamicIslandExpandedRegion(.center) {
                    Text(context.state.taskTitle).font(.caption)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(formattedShort(context.state.elapsedSeconds))
                        .monospacedDigit()
                }
            } compactLeading: {
                Image(systemName: "bolt.fill")
            } compactTrailing: {
                Text(formattedShort(context.state.elapsedSeconds))
                    .monospacedDigit()
                    .font(.caption2)
            } minimal: {
                Image(systemName: "bolt.fill")
            }
        }
    }

    private func formattedShort(_ seconds: Int) -> String {
        String(format: "%02d:%02d", (seconds % 3600) / 60, seconds % 60)
    }
}
