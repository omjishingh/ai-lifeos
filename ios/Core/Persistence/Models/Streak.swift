import Foundation
import SwiftData

@Model
final class Streak {
    @Attribute(.unique) var id: UUID
    var streakType: String
    var currentStreak: Int
    var longestStreak: Int
    var lastQualifiedDate: Date?
    var isRestDay: Bool
    var isVacationMode: Bool
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        streakType: String = StreakType.overall.rawValue,
        currentStreak: Int = 0,
        longestStreak: Int = 0,
        lastQualifiedDate: Date? = nil,
        isRestDay: Bool = false,
        isVacationMode: Bool = false,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.streakType = streakType
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.lastQualifiedDate = lastQualifiedDate
        self.isRestDay = isRestDay
        self.isVacationMode = isVacationMode
        self.updatedAt = updatedAt
    }
}

@Model
final class SleepSchedule {
    @Attribute(.unique) var id: UUID
    var bedtime: Date
    var wakeTime: Date
    var windDownMinutes: Int
    var isEnabled: Bool
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        bedtime: Date = Calendar.current.date(from: DateComponents(hour: 23, minute: 45)) ?? .now,
        wakeTime: Date = Calendar.current.date(from: DateComponents(hour: 6, minute: 30)) ?? .now,
        windDownMinutes: Int = 30,
        isEnabled: Bool = true,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.bedtime = bedtime
        self.wakeTime = wakeTime
        self.windDownMinutes = windDownMinutes
        self.isEnabled = isEnabled
        self.updatedAt = updatedAt
    }
}

@Model
final class SleepSession {
    @Attribute(.unique) var id: UUID
    var bedtime: Date
    var wakeTime: Date?
    var durationMinutes: Int
    var quality: Int?
    var createdAt: Date

    init(
        id: UUID = UUID(),
        bedtime: Date,
        wakeTime: Date? = nil,
        durationMinutes: Int = 0,
        quality: Int? = nil,
        createdAt: Date = .now
    ) {
        self.id = id
        self.bedtime = bedtime
        self.wakeTime = wakeTime
        self.durationMinutes = durationMinutes
        self.quality = quality
        self.createdAt = createdAt
    }
}
