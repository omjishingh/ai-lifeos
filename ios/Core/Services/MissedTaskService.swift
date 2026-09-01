import Foundation

protocol MissedTaskServiceProtocol {
    func checkAndMarkMissedTasks() async throws
    func rescheduleAllPops() async throws
}

struct MissedTaskService: MissedTaskServiceProtocol {
    private let taskRepository: TaskRepositoryProtocol
    private let scheduleService: ScheduleServiceProtocol
    private let settingsRepository: SettingsRepositoryProtocol
    private let popEngine: PopPopNotificationEngineProtocol

    init(
        taskRepository: TaskRepositoryProtocol,
        scheduleService: ScheduleServiceProtocol,
        settingsRepository: SettingsRepositoryProtocol,
        popEngine: PopPopNotificationEngineProtocol
    ) {
        self.taskRepository = taskRepository
        self.scheduleService = scheduleService
        self.settingsRepository = settingsRepository
        self.popEngine = popEngine
    }

    func checkAndMarkMissedTasks() async throws {
        let tasks = try taskRepository.fetchAll()
        let now = Date.now

        for task in tasks {
            guard task.taskStatus == .planned || task.taskStatus == .inProgress else { continue }
            guard let end = task.scheduledEnd, end < now else { continue }

            task.taskStatus = .missed
            try taskRepository.update(task)
            try await popEngine.scheduleMissedTask(task: task)
        }
    }

    func rescheduleAllPops() async throws {
        guard let profile = try settingsRepository.fetchProfile() else { return }
        let settings = try settingsRepository.fetchSettings()
        guard settings.notificationsEnabled else { return }

        let blocks = try scheduleService.resolvedBlocks(for: .now)
        let tasks = try taskRepository.fetchForDate(.now)

        var prefs = PopPopPreferences()
        prefs.enabled = settings.notificationsEnabled
        prefs.newsBriefingHour = briefingHour(from: settings.newsNotificationTime)

        try await popEngine.scheduleFullDay(
            profile: profile,
            blocks: blocks,
            tasks: tasks,
            preferences: prefs
        )
    }

    private func briefingHour(from time: String) -> Int {
        switch time {
        case "afternoon": return 14
        case "evening": return 18
        default: return 8
        }
    }
}
