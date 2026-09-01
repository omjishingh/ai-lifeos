import Foundation

enum OnboardingStep: Int, CaseIterable {
    case welcome = 0
    case name
    case wakeTime
    case sleepTime
    case collegeSchedule
    case travelTime
    case codingTarget
    case notifications
    case aiPreferences
    case sleepMusic
    case finish

    var title: String {
        switch self {
        case .welcome: return "Welcome"
        case .name: return "Your Name"
        case .wakeTime: return "Wake Up"
        case .sleepTime: return "Sleep"
        case .collegeSchedule: return "College"
        case .travelTime: return "Travel"
        case .codingTarget: return "Coding Goal"
        case .notifications: return "Notifications"
        case .aiPreferences: return "AI"
        case .sleepMusic: return "Sleep Music"
        case .finish: return "Ready"
        }
    }

    var progress: Double {
        Double(rawValue + 1) / Double(OnboardingStep.allCases.count)
    }

    var next: OnboardingStep? {
        OnboardingStep(rawValue: rawValue + 1)
    }

    var previous: OnboardingStep? {
        OnboardingStep(rawValue: rawValue - 1)
    }
}

@MainActor
@Observable
final class OnboardingViewModel {
    private let settingsRepository: SettingsRepositoryProtocol
    private let scheduleRepository: ScheduleRepositoryProtocol
    private let streakRepository: StreakRepositoryProtocol
    private let sleepRepository: SleepRepositoryProtocol
    private let routineGenerator: RoutineGeneratorProtocol
    private let notificationScheduler: NotificationSchedulerProtocol
    private let onComplete: () -> Void

    var currentStep: OnboardingStep = .welcome
    var name: String = ""
    var wakeUpTime: Date = DateComposer.timeOnDate(hour: 6, minute: 30)
    var sleepTime: Date = DateComposer.timeOnDate(hour: 23, minute: 45)
    var collegeStartTime: Date = DateComposer.timeOnDate(hour: 9, minute: 0)
    var collegeEndTime: Date = DateComposer.timeOnDate(hour: 16, minute: 30)
    var sundayIsHoliday: Bool = true
    var travelMinutes: Int = 60
    var codingTargetMinutes: Int = 180
    var notificationsEnabled: Bool = true
    var aiEnabled: Bool = true
    var newsNotificationTime: String = "morning"
    var sleepMusicPreference: String = "rain"
    var isFinishing: Bool = false
    var errorMessage: String?

    init(
        settingsRepository: SettingsRepositoryProtocol,
        scheduleRepository: ScheduleRepositoryProtocol,
        streakRepository: StreakRepositoryProtocol,
        sleepRepository: SleepRepositoryProtocol,
        routineGenerator: RoutineGeneratorProtocol = RoutineGenerator(),
        notificationScheduler: NotificationSchedulerProtocol,
        onComplete: @escaping () -> Void
    ) {
        self.settingsRepository = settingsRepository
        self.scheduleRepository = scheduleRepository
        self.streakRepository = streakRepository
        self.sleepRepository = sleepRepository
        self.routineGenerator = routineGenerator
        self.notificationScheduler = notificationScheduler
        self.onComplete = onComplete
    }

    var canProceed: Bool {
        switch currentStep {
        case .welcome: return true
        case .name: return !name.trimmingCharacters(in: .whitespaces).isEmpty
        case .finish: return !isFinishing
        default: return true
        }
    }

    func goNext() async {
        guard canProceed else { return }

        if currentStep == .notifications && notificationsEnabled {
            _ = await notificationScheduler.requestPermission()
        }

        if currentStep == .finish {
            await finishOnboarding()
            return
        }

        if let next = currentStep.next {
            currentStep = next
        }
    }

    func goBack() {
        guard let previous = currentStep.previous else { return }
        currentStep = previous
    }

    func finishOnboarding() async {
        isFinishing = true
        errorMessage = nil

        do {
            let profile = UserProfile(
                name: name.trimmingCharacters(in: .whitespaces),
                wakeUpTime: wakeUpTime,
                sleepTime: sleepTime,
                collegeStartTime: collegeStartTime,
                collegeEndTime: collegeEndTime,
                travelMinutes: travelMinutes,
                codingTargetMinutes: codingTargetMinutes,
                sundayIsHoliday: sundayIsHoliday,
                hasCompletedOnboarding: true
            )

            try settingsRepository.saveProfile(profile)

            var settings = try settingsRepository.fetchSettings()
            settings.notificationsEnabled = notificationsEnabled
            settings.aiEnabled = aiEnabled
            settings.newsNotificationTime = newsNotificationTime
            settings.sleepMusicPreference = sleepMusicPreference
            try settingsRepository.saveSettings(settings)

            let blocks = routineGenerator.generateInitialSchedule(for: profile)
            for block in blocks {
                try scheduleRepository.create(block)
            }

            let sleepSchedule = SleepSchedule(bedtime: sleepTime, wakeTime: wakeUpTime)
            try sleepRepository.saveSchedule(sleepSchedule)

            try await initializeStreaks()
            try await scheduleReminders(profile: profile, settings: settings)

            onComplete()
        } catch {
            errorMessage = error.localizedDescription
        }

        isFinishing = false
    }

    private func initializeStreaks() throws {
        for type in [StreakType.coding, StreakType.overall] {
            let streak = Streak(streakType: type.rawValue)
            try streakRepository.save(streak)
        }
    }

    private func scheduleReminders(profile: UserProfile, settings: AppSettings) async throws {
        guard settings.notificationsEnabled else { return }
        try await notificationScheduler.scheduleWakeUp(at: profile.wakeUpTime)
        try await notificationScheduler.scheduleSleepReminder(at: profile.sleepTime)

        if settings.newsNotificationTime != "off" {
            let (hour, minute) = newsBriefingTime(for: settings.newsNotificationTime)
            try await notificationScheduler.scheduleDailyBriefing(at: hour, minute: minute)
        }
    }

    private func newsBriefingTime(for preference: String) -> (Int, Int) {
        switch preference {
        case "afternoon": return (14, 0)
        case "evening": return (18, 0)
        default: return (8, 0)
        }
    }

    var reviewSummary: [(String, String)] {
        [
            ("Name", name),
            ("Wake up", wakeUpTime.timeString()),
            ("Sleep", sleepTime.timeString()),
            ("College", "\(collegeStartTime.timeString()) – \(collegeEndTime.timeString())"),
            ("Sunday", sundayIsHoliday ? "Holiday" : "College day"),
            ("Travel", "\(travelMinutes) min"),
            ("Coding target", formatCodingTarget()),
            ("Notifications", notificationsEnabled ? "On" : "Off"),
            ("AI", aiEnabled ? "Enabled" : "Disabled"),
            ("AI News", newsNotificationTime.capitalized),
            ("Sleep music", sleepMusicPreference.capitalized)
        ]
    }

    private func formatCodingTarget() -> String {
        let hours = codingTargetMinutes / 60
        let mins = codingTargetMinutes % 60
        if mins == 0 { return "\(hours)h/day" }
        return "\(hours)h \(mins)m/day"
    }
}
