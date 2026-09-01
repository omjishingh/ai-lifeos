import Foundation
import SwiftData

@Model
final class ScheduleBlock {
    @Attribute(.unique) var id: UUID
    var title: String
    var blockType: String
    var startTime: Date
    var endTime: Date
    var isRecurring: Bool
    var recurringDays: [Int]
    var taskId: UUID?
    var color: String?
    var icon: String?
    var isEditable: Bool
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        blockType: String = ScheduleBlockType.custom.rawValue,
        startTime: Date,
        endTime: Date,
        isRecurring: Bool = false,
        recurringDays: [Int] = [],
        taskId: UUID? = nil,
        color: String? = nil,
        icon: String? = nil,
        isEditable: Bool = true,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.title = title
        self.blockType = blockType
        self.startTime = startTime
        self.endTime = endTime
        self.isRecurring = isRecurring
        self.recurringDays = recurringDays
        self.taskId = taskId
        self.color = color
        self.icon = icon
        self.isEditable = isEditable
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

@Model
final class RecurringRule {
    @Attribute(.unique) var id: UUID
    var frequency: String
    var interval: Int
    var daysOfWeek: [Int]
    var endDate: Date?
    var createdAt: Date

    init(
        id: UUID = UUID(),
        frequency: String = "daily",
        interval: Int = 1,
        daysOfWeek: [Int] = [],
        endDate: Date? = nil,
        createdAt: Date = .now
    ) {
        self.id = id
        self.frequency = frequency
        self.interval = interval
        self.daysOfWeek = daysOfWeek
        self.endDate = endDate
        self.createdAt = createdAt
    }
}
