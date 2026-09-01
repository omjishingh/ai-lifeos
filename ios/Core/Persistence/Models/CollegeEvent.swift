import Foundation
import SwiftData

@Model
final class CollegeEvent {
    @Attribute(.unique) var id: UUID
    var title: String
    var eventType: String
    var startTime: Date
    var endTime: Date?
    var subjectId: UUID?
    var location: String?
    var notes: String
    var isHoliday: Bool
    var createdAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        eventType: String = "class",
        startTime: Date,
        endTime: Date? = nil,
        subjectId: UUID? = nil,
        location: String? = nil,
        notes: String = "",
        isHoliday: Bool = false,
        createdAt: Date = .now
    ) {
        self.id = id
        self.title = title
        self.eventType = eventType
        self.startTime = startTime
        self.endTime = endTime
        self.subjectId = subjectId
        self.location = location
        self.notes = notes
        self.isHoliday = isHoliday
        self.createdAt = createdAt
    }
}

@Model
final class Subject {
    @Attribute(.unique) var id: UUID
    var name: String
    var code: String?
    var color: String?
    var professor: String?
    var createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        code: String? = nil,
        color: String? = nil,
        professor: String? = nil,
        createdAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.code = code
        self.color = color
        self.professor = professor
        self.createdAt = createdAt
    }
}

@Model
final class Assignment {
    @Attribute(.unique) var id: UUID
    var title: String
    var subjectId: UUID?
    var dueDate: Date
    var isCompleted: Bool
    var notes: String
    var createdAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        subjectId: UUID? = nil,
        dueDate: Date,
        isCompleted: Bool = false,
        notes: String = "",
        createdAt: Date = .now
    ) {
        self.id = id
        self.title = title
        self.subjectId = subjectId
        self.dueDate = dueDate
        self.isCompleted = isCompleted
        self.notes = notes
        self.createdAt = createdAt
    }
}
