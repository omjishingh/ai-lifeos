import Foundation
import SwiftData

enum PersistenceError: LocalizedError {
    case notFound
    case saveFailed(Error)
    case deleteFailed(Error)

    var errorDescription: String? {
        switch self {
        case .notFound: return "Item not found."
        case .saveFailed(let error): return "Failed to save: \(error.localizedDescription)"
        case .deleteFailed(let error): return "Failed to delete: \(error.localizedDescription)"
        }
    }
}

let swiftDataSchema = Schema([
    UserProfile.self,
    TaskItem.self,
    Subtask.self,
    ScheduleBlock.self,
    RecurringRule.self,
    Goal.self,
    Project.self,
    CodingSession.self,
    FocusSession.self,
    Streak.self,
    SleepSchedule.self,
    SleepSession.self,
    NewsArticle.self,
    SavedArticle.self,
    CollegeEvent.self,
    Subject.self,
    Assignment.self,
    AIConversation.self,
    AIMessage.self,
    NotificationRule.self,
    AppSettings.self
])

@MainActor
func makeModelContainer(inMemory: Bool = false) throws -> ModelContainer {
    let config = ModelConfiguration(isStoredInMemoryOnly: inMemory)
    return try ModelContainer(for: swiftDataSchema, configurations: config)
}
