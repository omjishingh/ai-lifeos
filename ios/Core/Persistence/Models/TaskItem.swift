import Foundation
import SwiftData

@Model
final class TaskItem {
    @Attribute(.unique) var id: UUID
    var title: String
    var taskDescription: String
    var category: String
    var priority: String
    var estimatedDurationMinutes: Int
    var deadline: Date?
    var scheduledStart: Date?
    var scheduledEnd: Date?
    var status: String
    var repeatRule: String?
    var goalId: UUID?
    var projectId: UUID?
    var createdAt: Date
    var completedAt: Date?
    var notes: String
    var updatedAt: Date

    @Relationship(deleteRule: .cascade, inverse: \Subtask.parentTask)
    var subtasks: [Subtask] = []

    init(
        id: UUID = UUID(),
        title: String,
        taskDescription: String = "",
        category: String = TaskCategory.other.rawValue,
        priority: String = TaskPriority.medium.rawValue,
        estimatedDurationMinutes: Int = 30,
        deadline: Date? = nil,
        scheduledStart: Date? = nil,
        scheduledEnd: Date? = nil,
        status: String = TaskStatus.planned.rawValue,
        repeatRule: String? = nil,
        goalId: UUID? = nil,
        projectId: UUID? = nil,
        createdAt: Date = .now,
        completedAt: Date? = nil,
        notes: String = "",
        updatedAt: Date = .now
    ) {
        self.id = id
        self.title = title
        self.taskDescription = taskDescription
        self.category = category
        self.priority = priority
        self.estimatedDurationMinutes = estimatedDurationMinutes
        self.deadline = deadline
        self.scheduledStart = scheduledStart
        self.scheduledEnd = scheduledEnd
        self.status = status
        self.repeatRule = repeatRule
        self.goalId = goalId
        self.projectId = projectId
        self.createdAt = createdAt
        self.completedAt = completedAt
        self.notes = notes
        self.updatedAt = updatedAt
    }

    var taskStatus: TaskStatus {
        get { TaskStatus(rawValue: status) ?? .planned }
        set { status = newValue.rawValue }
    }

    var taskPriority: TaskPriority {
        get { TaskPriority(rawValue: priority) ?? .medium }
        set { priority = newValue.rawValue }
    }
}

@Model
final class Subtask {
    @Attribute(.unique) var id: UUID
    var title: String
    var isCompleted: Bool
    var sortOrder: Int
    var parentTask: TaskItem?

    init(
        id: UUID = UUID(),
        title: String,
        isCompleted: Bool = false,
        sortOrder: Int = 0
    ) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.sortOrder = sortOrder
    }
}
