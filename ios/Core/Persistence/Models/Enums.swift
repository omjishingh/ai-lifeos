import Foundation

enum TaskStatus: String, Codable, CaseIterable {
    case planned
    case inProgress
    case completed
    case skipped
    case missed
    case postponed
    case cancelled

    var displayName: String {
        switch self {
        case .planned: return "Planned"
        case .inProgress: return "In Progress"
        case .completed: return "Completed"
        case .skipped: return "Skipped"
        case .missed: return "Missed"
        case .postponed: return "Postponed"
        case .cancelled: return "Cancelled"
        }
    }
}

enum TaskPriority: String, Codable, CaseIterable {
    case low
    case medium
    case high
    case urgent

    var displayName: String {
        rawValue.capitalized
    }

    var sortOrder: Int {
        switch self {
        case .urgent: return 0
        case .high: return 1
        case .medium: return 2
        case .low: return 3
        }
    }
}

enum TaskCategory: String, Codable, CaseIterable {
    case personalCoding = "Personal Coding"
    case college = "College"
    case routine = "Routine"
    case personal = "Personal"
    case sleep = "Sleep"
    case other = "Other"
}

enum StreakType: String, Codable, CaseIterable {
    case coding
    case task
    case sleep
    case overall
}

enum NewsCategory: String, Codable, CaseIterable {
    case majorCompanyUpdate = "Major AI Company Update"
    case newModel = "New AI Model"
    case codingTools = "AI Coding Tools"
    case appsProducts = "AI Apps/Products"
    case openSource = "Open-source AI"
    case research = "Research"
    case agents = "AI Agents"
    case business = "AI Business/Industry"
    case policy = "AI Policy/Safety"
    case trend = "Important AI Trend"
}

enum ScheduleBlockType: String, Codable, CaseIterable {
    case fixed
    case routine
    case task
    case college
    case coding
    case sleep
    case break_
    case custom

    var displayName: String {
        switch self {
        case .break_: return "Break"
        default: return rawValue.capitalized
        }
    }
}

enum DayOfWeek: Int, Codable, CaseIterable {
    case sunday = 1
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7

    var shortName: String {
        switch self {
        case .sunday: return "Sun"
        case .monday: return "Mon"
        case .tuesday: return "Tue"
        case .wednesday: return "Wed"
        case .thursday: return "Thu"
        case .friday: return "Fri"
        case .saturday: return "Sat"
        }
    }
}
