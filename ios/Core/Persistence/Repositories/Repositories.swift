import Foundation
import SwiftData

// MARK: - Task Repository

protocol TaskRepositoryProtocol {
    func fetchAll() throws -> [TaskItem]
    func fetchForDate(_ date: Date) throws -> [TaskItem]
    func fetchById(_ id: UUID) throws -> TaskItem?
    func create(_ task: TaskItem) throws
    func update(_ task: TaskItem) throws
    func delete(_ task: TaskItem) throws
}

@MainActor
final class TaskRepository: TaskRepositoryProtocol {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchAll() throws -> [TaskItem] {
        let descriptor = FetchDescriptor<TaskItem>(sortBy: [SortDescriptor(\.scheduledStart)])
        return try modelContext.fetch(descriptor)
    }

    func fetchForDate(_ date: Date) throws -> [TaskItem] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            return []
        }
        let predicate = #Predicate<TaskItem> { task in
            if let scheduledStart = task.scheduledStart {
                scheduledStart >= startOfDay && scheduledStart < endOfDay
            } else {
                false
            }
        }
        let descriptor = FetchDescriptor<TaskItem>(predicate: predicate, sortBy: [SortDescriptor(\.scheduledStart)])
        return try modelContext.fetch(descriptor)
    }

    func fetchById(_ id: UUID) throws -> TaskItem? {
        let predicate = #Predicate<TaskItem> { $0.id == id }
        let descriptor = FetchDescriptor<TaskItem>(predicate: predicate)
        return try modelContext.fetch(descriptor).first
    }

    func create(_ task: TaskItem) throws {
        modelContext.insert(task)
        try modelContext.save()
    }

    func update(_ task: TaskItem) throws {
        task.updatedAt = .now
        try modelContext.save()
    }

    func delete(_ task: TaskItem) throws {
        modelContext.delete(task)
        try modelContext.save()
    }
}

// MARK: - Schedule Repository

protocol ScheduleRepositoryProtocol {
    func fetchAll() throws -> [ScheduleBlock]
    func fetchForDate(_ date: Date) throws -> [ScheduleBlock]
    func create(_ block: ScheduleBlock) throws
    func update(_ block: ScheduleBlock) throws
    func delete(_ block: ScheduleBlock) throws
}

@MainActor
final class ScheduleRepository: ScheduleRepositoryProtocol {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchAll() throws -> [ScheduleBlock] {
        let descriptor = FetchDescriptor<ScheduleBlock>(sortBy: [SortDescriptor(\.startTime)])
        return try modelContext.fetch(descriptor)
    }

    func fetchForDate(_ date: Date) throws -> [ScheduleBlock] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            return []
        }
        let predicate = #Predicate<ScheduleBlock> { block in
            block.startTime >= startOfDay && block.startTime < endOfDay
        }
        let descriptor = FetchDescriptor<ScheduleBlock>(predicate: predicate, sortBy: [SortDescriptor(\.startTime)])
        return try modelContext.fetch(descriptor)
    }

    func create(_ block: ScheduleBlock) throws {
        modelContext.insert(block)
        try modelContext.save()
    }

    func update(_ block: ScheduleBlock) throws {
        block.updatedAt = .now
        try modelContext.save()
    }

    func delete(_ block: ScheduleBlock) throws {
        modelContext.delete(block)
        try modelContext.save()
    }
}

// MARK: - Settings Repository

protocol SettingsRepositoryProtocol {
    func fetchSettings() throws -> AppSettings
    func fetchProfile() throws -> UserProfile?
    func saveSettings(_ settings: AppSettings) throws
    func saveProfile(_ profile: UserProfile) throws
}

@MainActor
final class SettingsRepository: SettingsRepositoryProtocol {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchSettings() throws -> AppSettings {
        let descriptor = FetchDescriptor<AppSettings>()
        if let existing = try modelContext.fetch(descriptor).first {
            return existing
        }
        let settings = AppSettings()
        modelContext.insert(settings)
        try modelContext.save()
        return settings
    }

    func fetchProfile() throws -> UserProfile? {
        let descriptor = FetchDescriptor<UserProfile>()
        return try modelContext.fetch(descriptor).first
    }

    func saveSettings(_ settings: AppSettings) throws {
        settings.updatedAt = .now
        try modelContext.save()
    }

    func saveProfile(_ profile: UserProfile) throws {
        profile.updatedAt = .now
        if profile.modelContext == nil {
            modelContext.insert(profile)
        }
        try modelContext.save()
    }
}

// MARK: - Goal Repository

protocol GoalRepositoryProtocol {
    func fetchAll() throws -> [Goal]
    func fetchForDate(_ date: Date) throws -> [Goal]
    func create(_ goal: Goal) throws
    func update(_ goal: Goal) throws
    func delete(_ goal: Goal) throws
}

@MainActor
final class GoalRepository: GoalRepositoryProtocol {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchAll() throws -> [Goal] {
        let descriptor = FetchDescriptor<Goal>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
        return try modelContext.fetch(descriptor)
    }

    func fetchForDate(_ date: Date) throws -> [Goal] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            return []
        }
        let predicate = #Predicate<Goal> { goal in
            if let targetDate = goal.targetDate {
                targetDate >= startOfDay && targetDate < endOfDay
            } else {
                !goal.isCompleted
            }
        }
        let descriptor = FetchDescriptor<Goal>(predicate: predicate)
        return try modelContext.fetch(descriptor)
    }

    func create(_ goal: Goal) throws {
        modelContext.insert(goal)
        try modelContext.save()
    }

    func update(_ goal: Goal) throws {
        goal.updatedAt = .now
        try modelContext.save()
    }

    func delete(_ goal: Goal) throws {
        modelContext.delete(goal)
        try modelContext.save()
    }
}

// MARK: - News Repository

protocol NewsRepositoryProtocol {
    func fetchToday() throws -> [NewsArticle]
    func fetchById(_ id: UUID) throws -> NewsArticle?
    func saveArticles(_ articles: [NewsArticle]) throws
    func markAsRead(_ article: NewsArticle) throws
}

@MainActor
final class NewsRepository: NewsRepositoryProtocol {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchToday() throws -> [NewsArticle] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: .now)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            return []
        }
        let predicate = #Predicate<NewsArticle> { article in
            article.briefingDate >= startOfDay && article.briefingDate < endOfDay
        }
        let descriptor = FetchDescriptor<NewsArticle>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.sortOrder)]
        )
        return try modelContext.fetch(descriptor)
    }

    func fetchById(_ id: UUID) throws -> NewsArticle? {
        let predicate = #Predicate<NewsArticle> { $0.id == id }
        let descriptor = FetchDescriptor<NewsArticle>(predicate: predicate)
        return try modelContext.fetch(descriptor).first
    }

    func saveArticles(_ articles: [NewsArticle]) throws {
        for article in articles {
            modelContext.insert(article)
        }
        try modelContext.save()
    }

    func markAsRead(_ article: NewsArticle) throws {
        article.isRead = true
        try modelContext.save()
    }
}

// MARK: - Sleep Repository

protocol SleepRepositoryProtocol {
    func fetchSchedule() throws -> SleepSchedule?
    func saveSchedule(_ schedule: SleepSchedule) throws
}

@MainActor
final class SleepRepository: SleepRepositoryProtocol {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchSchedule() throws -> SleepSchedule? {
        let descriptor = FetchDescriptor<SleepSchedule>()
        return try modelContext.fetch(descriptor).first
    }

    func saveSchedule(_ schedule: SleepSchedule) throws {
        schedule.updatedAt = .now
        if schedule.modelContext == nil {
            modelContext.insert(schedule)
        }
        try modelContext.save()
    }
}

// MARK: - Streak Repository

protocol StreakRepositoryProtocol {
    func fetchAll() throws -> [Streak]
    func fetchByType(_ type: StreakType) throws -> Streak?
    func save(_ streak: Streak) throws
}

@MainActor
final class StreakRepository: StreakRepositoryProtocol {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchAll() throws -> [Streak] {
        let descriptor = FetchDescriptor<Streak>()
        return try modelContext.fetch(descriptor)
    }

    func fetchByType(_ type: StreakType) throws -> Streak? {
        let typeRaw = type.rawValue
        let predicate = #Predicate<Streak> { $0.streakType == typeRaw }
        let descriptor = FetchDescriptor<Streak>(predicate: predicate)
        return try modelContext.fetch(descriptor).first
    }

    func save(_ streak: Streak) throws {
        streak.updatedAt = .now
        if streak.modelContext == nil {
            modelContext.insert(streak)
        }
        try modelContext.save()
    }
}
