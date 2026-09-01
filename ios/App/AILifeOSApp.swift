import SwiftUI
import SwiftData

@main
struct AILifeOSApp: App {
    @State private var appEnvironment: AppEnvironment

    init() {
        do {
            let container = try makeModelContainer()
            let environment = AppEnvironment(modelContainer: container)
            environment.loadInitialState()
            environment.notificationDelegate.configure()
            _appEnvironment = State(initialValue: environment)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.appEnvironment, appEnvironment)
                .environment(\.appColors, AppColors.light)
                .modelContainer(appEnvironment.modelContainer)
                .task {
                    _ = await appEnvironment.popPopEngine.requestPermission()
                    await appEnvironment.refreshPopsAndMissedTasks()
                }
        }
    }
}

struct RootView: View {
    @Environment(\.appEnvironment) private var appEnvironment
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        Group {
            if appEnvironment?.hasCompletedOnboarding == true {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
        .environment(\.appColors, colorScheme == .dark ? AppColors.dark : AppColors.light)
        .onChange(of: scenePhase) { _, phase in
            guard phase == .active, let env = appEnvironment else { return }
            Task { await env.refreshPopsAndMissedTasks() }
        }
    }
}

#Preview {
    RootView()
        .environment(\.appEnvironment, try! AppEnvironment(modelContainer: makeModelContainer(inMemory: true)))
}
