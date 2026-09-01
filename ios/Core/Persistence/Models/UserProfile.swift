import Foundation
import SwiftData

@Model
final class UserProfile {
    @Attribute(.unique) var id: UUID
    var name: String
    var wakeUpTime: Date
    var sleepTime: Date
    var collegeStartTime: Date
    var collegeEndTime: Date
    var travelMinutes: Int
    var codingTargetMinutes: Int
    var sundayIsHoliday: Bool
    var hasCompletedOnboarding: Bool
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        name: String = "",
        wakeUpTime: Date = Calendar.current.date(from: DateComponents(hour: 6, minute: 30)) ?? .now,
        sleepTime: Date = Calendar.current.date(from: DateComponents(hour: 23, minute: 45)) ?? .now,
        collegeStartTime: Date = Calendar.current.date(from: DateComponents(hour: 9, minute: 0)) ?? .now,
        collegeEndTime: Date = Calendar.current.date(from: DateComponents(hour: 16, minute: 30)) ?? .now,
        travelMinutes: Int = 60,
        codingTargetMinutes: Int = 180,
        sundayIsHoliday: Bool = true,
        hasCompletedOnboarding: Bool = false,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.wakeUpTime = wakeUpTime
        self.sleepTime = sleepTime
        self.collegeStartTime = collegeStartTime
        self.collegeEndTime = collegeEndTime
        self.travelMinutes = travelMinutes
        self.codingTargetMinutes = codingTargetMinutes
        self.sundayIsHoliday = sundayIsHoliday
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
