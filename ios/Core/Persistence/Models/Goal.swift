import Foundation
import SwiftData

@Model
final class Goal {
    @Attribute(.unique) var id: UUID
    var title: String
    var goalDescription: String
    var targetDate: Date?
    var isCompleted: Bool
    var progress: Double
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        goalDescription: String = "",
        targetDate: Date? = nil,
        isCompleted: Bool = false,
        progress: Double = 0,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.title = title
        self.goalDescription = goalDescription
        self.targetDate = targetDate
        self.isCompleted = isCompleted
        self.progress = progress
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

@Model
final class Project {
    @Attribute(.unique) var id: UUID
    var name: String
    var projectDescription: String
    var goalText: String
    var isActive: Bool
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        projectDescription: String = "",
        goalText: String = "",
        isActive: Bool = true,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.projectDescription = projectDescription
        self.goalText = goalText
        self.isActive = isActive
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

@Model
final class CodingSession {
    @Attribute(.unique) var id: UUID
    var projectId: UUID?
    var startTime: Date
    var endTime: Date?
    var durationMinutes: Int
    var notes: String
    var createdAt: Date

    init(
        id: UUID = UUID(),
        projectId: UUID? = nil,
        startTime: Date = .now,
        endTime: Date? = nil,
        durationMinutes: Int = 0,
        notes: String = "",
        createdAt: Date = .now
    ) {
        self.id = id
        self.projectId = projectId
        self.startTime = startTime
        self.endTime = endTime
        self.durationMinutes = durationMinutes
        self.notes = notes
        self.createdAt = createdAt
    }
}

@Model
final class FocusSession {
    @Attribute(.unique) var id: UUID
    var taskId: UUID?
    var startTime: Date
    var endTime: Date?
    var plannedDurationMinutes: Int
    var actualDurationMinutes: Int
    var isPaused: Bool
    var createdAt: Date

    init(
        id: UUID = UUID(),
        taskId: UUID? = nil,
        startTime: Date = .now,
        endTime: Date? = nil,
        plannedDurationMinutes: Int = 25,
        actualDurationMinutes: Int = 0,
        isPaused: Bool = false,
        createdAt: Date = .now
    ) {
        self.id = id
        self.taskId = taskId
        self.startTime = startTime
        self.endTime = endTime
        self.plannedDurationMinutes = plannedDurationMinutes
        self.actualDurationMinutes = actualDurationMinutes
        self.isPaused = isPaused
        self.createdAt = createdAt
    }
}
