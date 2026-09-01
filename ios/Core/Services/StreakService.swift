import Foundation

protocol StreakServiceProtocol {
    func recordCodingSession(minutes: Int, profile: UserProfile?) throws
    func recordTaskCompletion() throws
    func fetchStreak(type: StreakType) throws -> Streak?
    func fetchAll() throws -> [Streak]
}

struct StreakService: StreakServiceProtocol {
    private let streakRepository: StreakRepositoryProtocol
    private let taskRepository: TaskRepositoryProtocol

    init(streakRepository: StreakRepositoryProtocol, taskRepository: TaskRepositoryProtocol) {
        self.streakRepository = streakRepository
        self.taskRepository = taskRepository
    }

    func fetchStreak(type: StreakType) throws -> Streak? {
        try streakRepository.fetchByType(type)
    }

    func fetchAll() throws -> [Streak] {
        try streakRepository.fetchAll()
    }

    func recordCodingSession(minutes: Int, profile: UserProfile?) throws {
        guard let target = profile?.codingTargetMinutes, minutes >= target else { return }
        try incrementStreak(type: .coding)
        try incrementStreak(type: .overall)
    }

    func recordTaskCompletion() throws {
        let today = Date.now
        let tasks = try taskRepository.fetchForDate(today)
        guard !tasks.isEmpty else { return }
        let completed = tasks.filter { $0.taskStatus == .completed }.count
        let rate = Double(completed) / Double(tasks.count)
        if rate >= 0.8 {
            try incrementStreak(type: .task)
            try incrementStreak(type: .overall)
        }
    }

    private func incrementStreak(type: StreakType) throws {
        let streak = try streakRepository.fetchByType(type) ?? Streak(streakType: type.rawValue)
        let today = Calendar.current.startOfDay(for: .now)

        if let last = streak.lastQualifiedDate {
            let lastDay = Calendar.current.startOfDay(for: last)
            if lastDay == today { return }
            let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
            if lastDay == yesterday {
                streak.currentStreak += 1
            } else if !streak.isRestDay && !streak.isVacationMode {
                streak.currentStreak = 1
            }
        } else {
            streak.currentStreak = 1
        }

        streak.longestStreak = max(streak.longestStreak, streak.currentStreak)
        streak.lastQualifiedDate = today
        try streakRepository.save(streak)
    }
}
