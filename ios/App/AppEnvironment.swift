import SwiftUI
import SwiftData

@MainActor
@Observable
final class AppEnvironment {
    let modelContainer: ModelContainer
    let modelContext: ModelContext

    let taskRepository: TaskRepositoryProtocol
    let scheduleRepository: ScheduleRepositoryProtocol
    let settingsRepository: SettingsRepositoryProtocol
    let goalRepository: GoalRepositoryProtocol
    let newsRepository: NewsRepositoryProtocol
    let streakRepository: StreakRepositoryProtocol
    let sleepRepository: SleepRepositoryProtocol

    let scheduleService: ScheduleServiceProtocol
    let taskService: TaskServiceProtocol
    let streakService: StreakServiceProtocol
    let routineGenerator: RoutineGeneratorProtocol
    let apiClient: APIClientProtocol
    let newsService: NewsServiceProtocol
    let aiService: AIServiceProtocol
    let notificationScheduler: NotificationSchedulerProtocol
    let networkMonitor: NetworkMonitorProtocol
    let focusTimer: FocusTimerService
    let sleepMusicPlayer: SleepMusicPlayer

    var userProfile: UserProfile?
    var appSettings: AppSettings?
    var hasCompletedOnboarding: Bool = false

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        self.modelContext = modelContainer.mainContext

        self.taskRepository = TaskRepository(modelContext: modelContext)
        self.scheduleRepository = ScheduleRepository(modelContext: modelContext)
        self.settingsRepository = SettingsRepository(modelContext: modelContext)
        self.goalRepository = GoalRepository(modelContext: modelContext)
        self.newsRepository = NewsRepository(modelContext: modelContext)
        self.streakRepository = StreakRepository(modelContext: modelContext)
        self.sleepRepository = SleepRepository(modelContext: modelContext)

        self.notificationScheduler = NotificationScheduler()
        self.networkMonitor = NetworkMonitor()
        self.apiClient = APIClient()
        self.routineGenerator = RoutineGenerator()

        self.scheduleService = ScheduleService(scheduleRepository: scheduleRepository)
        self.taskService = TaskService(taskRepository: taskRepository, notificationScheduler: notificationScheduler)
        self.streakService = StreakService(streakRepository: streakRepository, taskRepository: taskRepository)
        self.newsService = NewsService(apiClient: apiClient, newsRepository: newsRepository, networkMonitor: networkMonitor)
        self.aiService = AIService(apiClient: apiClient, networkMonitor: networkMonitor)

        self.focusTimer = FocusTimerService(modelContext: modelContext, streakService: streakService)
        self.sleepMusicPlayer = SleepMusicPlayer()
        self.focusTimer.profileProvider = { [weak self] in self?.userProfile }
    }

    func loadInitialState() {
        do {
            appSettings = try settingsRepository.fetchSettings()
            userProfile = try settingsRepository.fetchProfile()
            hasCompletedOnboarding = userProfile?.hasCompletedOnboarding ?? false
        } catch {
            print("Failed to load initial state: \(error)")
        }
    }

    func completeOnboarding(profile: UserProfile) throws {
        profile.hasCompletedOnboarding = true
        try settingsRepository.saveProfile(profile)
        userProfile = profile
        hasCompletedOnboarding = true
    }

    func resetOnboarding() throws {
        if let profile = userProfile {
            profile.hasCompletedOnboarding = false
            try settingsRepository.saveProfile(profile)
        }
        hasCompletedOnboarding = false
    }

    func deleteAllData() throws {
        try modelContext.delete(model: TaskItem.self)
        try modelContext.delete(model: ScheduleBlock.self)
        try modelContext.delete(model: Goal.self)
        try modelContext.delete(model: Streak.self)
        try modelContext.delete(model: NewsArticle.self)
        try modelContext.delete(model: UserProfile.self)
        try modelContext.save()
        userProfile = nil
        hasCompletedOnboarding = false
    }
}

private struct AppEnvironmentKey: EnvironmentKey {
    @MainActor static let defaultValue: AppEnvironment? = nil
}

extension EnvironmentValues {
    @MainActor
    var appEnvironment: AppEnvironment? {
        get { self[AppEnvironmentKey.self] }
        set { self[AppEnvironmentKey.self] = newValue }
    }
}
