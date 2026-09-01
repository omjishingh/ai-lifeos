import Foundation
import SwiftData

@Model
final class AIConversation {
    @Attribute(.unique) var id: UUID
    var title: String
    var createdAt: Date
    var updatedAt: Date

    @Relationship(deleteRule: .cascade, inverse: \AIMessage.conversation)
    var messages: [AIMessage] = []

    init(
        id: UUID = UUID(),
        title: String = "New Chat",
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.title = title
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

@Model
final class AIMessage {
    @Attribute(.unique) var id: UUID
    var role: String
    var content: String
    var structuredData: String?
    var createdAt: Date
    var conversation: AIConversation?

    init(
        id: UUID = UUID(),
        role: String,
        content: String,
        structuredData: String? = nil,
        createdAt: Date = .now
    ) {
        self.id = id
        self.role = role
        self.content = content
        self.structuredData = structuredData
        self.createdAt = createdAt
    }
}

@Model
final class NotificationRule {
    @Attribute(.unique) var id: UUID
    var ruleType: String
    var minutesBefore: Int?
    var isEnabled: Bool
    var taskId: UUID?
    var createdAt: Date

    init(
        id: UUID = UUID(),
        ruleType: String,
        minutesBefore: Int? = nil,
        isEnabled: Bool = true,
        taskId: UUID? = nil,
        createdAt: Date = .now
    ) {
        self.id = id
        self.ruleType = ruleType
        self.minutesBefore = minutesBefore
        self.isEnabled = isEnabled
        self.taskId = taskId
        self.createdAt = createdAt
    }
}

@Model
final class AppSettings {
    @Attribute(.unique) var id: UUID
    var notificationsEnabled: Bool
    var newsNotificationTime: String
    var aiEnabled: Bool
    var weeklyReviewEnabled: Bool
    var appearanceMode: String
    var sleepMusicPreference: String
    var calendarSyncEnabled: Bool
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        notificationsEnabled: Bool = true,
        newsNotificationTime: String = "morning",
        aiEnabled: Bool = true,
        weeklyReviewEnabled: Bool = true,
        appearanceMode: String = "system",
        sleepMusicPreference: String = "rain",
        calendarSyncEnabled: Bool = false,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.notificationsEnabled = notificationsEnabled
        self.newsNotificationTime = newsNotificationTime
        self.aiEnabled = aiEnabled
        self.weeklyReviewEnabled = weeklyReviewEnabled
        self.appearanceMode = appearanceMode
        self.sleepMusicPreference = sleepMusicPreference
        self.calendarSyncEnabled = calendarSyncEnabled
        self.updatedAt = updatedAt
    }
}
