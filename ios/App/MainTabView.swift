import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Tab = .today

    enum Tab: String, CaseIterable {
        case today
        case schedule
        case tasks
        case ai
        case profile

        var title: String {
            switch self {
            case .today: return "Today"
            case .schedule: return "Schedule"
            case .tasks: return "Tasks"
            case .ai: return "AI"
            case .profile: return "Profile"
            }
        }

        var icon: String {
            switch self {
            case .today: return "sun.max.fill"
            case .schedule: return "calendar"
            case .tasks: return "checklist"
            case .ai: return "sparkles"
            case .profile: return "person.fill"
            }
        }
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            TodayView()
                .tabItem {
                    Label(Tab.today.title, systemImage: Tab.today.icon)
                }
                .tag(Tab.today)

            ScheduleView()
                .tabItem {
                    Label(Tab.schedule.title, systemImage: Tab.schedule.icon)
                }
                .tag(Tab.schedule)

            TasksView()
                .tabItem {
                    Label(Tab.tasks.title, systemImage: Tab.tasks.icon)
                }
                .tag(Tab.tasks)

            AIHubView()
                .tabItem {
                    Label(Tab.ai.title, systemImage: Tab.ai.icon)
                }
                .tag(Tab.ai)

            ProfileView()
                .tabItem {
                    Label(Tab.profile.title, systemImage: Tab.profile.icon)
                }
                .tag(Tab.profile)
        }
        .tint(.accentColor)
    }
}

#Preview {
    MainTabView()
        .environment(\.appEnvironment, try! AppEnvironment(modelContainer: makeModelContainer(inMemory: true)))
}
