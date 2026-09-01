import Foundation
import UserNotifications

struct PopPopPreferences {
    var enabled: Bool = true
    var beforeTaskMinutes: [Int] = [30, 15, 10, 5]
    var beforeEndMinutes: [Int] = [10, 5]
    var morningBriefingHour: Int = 8
    var morningBriefingMinute: Int = 0
    var newsBriefingHour: Int = 8
    var newsBriefingMinute: Int = 30
    var soundEnabled: Bool = true
    var badgeEnabled: Bool = true
    var timeSensitive: Bool = true
}

protocol PopPopNotificationEngineProtocol {
    func requestPermission() async -> Bool
    func scheduleFullDay(
        profile: UserProfile,
        blocks: [ResolvedScheduleBlock],
        tasks: [TaskItem],
        preferences: PopPopPreferences
    ) async throws
    func scheduleTaskPops(task: TaskItem, preferences: PopPopPreferences) async throws
    func scheduleMissedTask(task: TaskItem) async throws
    func cancelTaskPops(taskId: UUID) async
    func cancelAll() async
    func pendingCount() async -> Int
    func upcomingPops(limit: Int) async -> [UpcomingPop]
}

struct UpcomingPop: Identifiable {
    let id: String
    let title: String
    let body: String
    let date: Date
    let icon: String
}

final class PopPopNotificationEngine: PopPopNotificationEngineProtocol {
    private let center = UNUserNotificationCenter.current()

    init() {
        PopPopNotificationCategories.registerAll()
    }

    func requestPermission() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge, .providesAppNotificationSettings])
            if granted {
                PopPopNotificationCategories.registerAll()
            }
            return granted
        } catch {
            return false
        }
    }

    func scheduleFullDay(
        profile: UserProfile,
        blocks: [ResolvedScheduleBlock],
        tasks: [TaskItem],
        preferences: PopPopPreferences
    ) async throws {
        guard preferences.enabled else { return }
        await cancelAll()

        for block in blocks {
            try await scheduleBlockPops(block: block, preferences: preferences)
        }

        for task in tasks where task.taskStatus == .planned || task.taskStatus == .inProgress {
            try await scheduleTaskPops(task: task, preferences: preferences)
        }

        try await scheduleWakeUp(at: profile.wakeUpTime, preferences: preferences)
        try await scheduleWindDown(bedtime: profile.sleepTime, preferences: preferences)
        try await scheduleSleep(at: profile.sleepTime, preferences: preferences)
        try await scheduleMorningBriefing(
            hour: preferences.morningBriefingHour,
            minute: preferences.morningBriefingMinute,
            name: profile.name,
            preferences: preferences
        )
        try await scheduleAINews(
            hour: preferences.newsBriefingHour,
            minute: preferences.newsBriefingMinute,
            preferences: preferences
        )
    }

    func scheduleTaskPops(task: TaskItem, preferences: PopPopPreferences) async throws {
        guard preferences.enabled, let start = task.scheduledStart else { return }
        await cancelTaskPops(taskId: task.id)

        for minutes in preferences.beforeTaskMinutes {
            let fireDate = start.addingTimeInterval(-Double(minutes * 60))
            guard fireDate > .now else { continue }

            let content = makeContent(
                title: "🔔 \(task.title)",
                body: "Starts in \(minutes) minutes — get ready!",
                category: NotificationCategoryID.taskReminder,
                threadId: "task-\(task.id.uuidString)",
                userInfo: [
                    "taskId": task.id.uuidString,
                    "action": "reminder",
                    "minutesBefore": minutes
                ],
                preferences: preferences
            )

            try await scheduleOne(
                id: "task-\(task.id.uuidString)-before-\(minutes)",
                content: content,
                date: fireDate
            )
        }

        let startContent = makeContent(
            title: iconForCategory(task.category) + " " + task.title,
            body: "POP! Your planned session has started. Tap to focus.",
            category: NotificationCategoryID.taskStart,
            threadId: "task-\(task.id.uuidString)",
            userInfo: ["taskId": task.id.uuidString, "action": "start"],
            preferences: preferences
        )
        try await scheduleOne(id: "task-\(task.id.uuidString)-start", content: startContent, date: start)

        if let end = task.scheduledEnd {
            for minutes in preferences.beforeEndMinutes {
                let fireDate = end.addingTimeInterval(-Double(minutes * 60))
                guard fireDate > .now else { continue }

                let content = makeContent(
                    title: "⏰ \(minutes)m left — \(task.title)",
                    body: "Wrap up or extend your session.",
                    category: NotificationCategoryID.taskReminder,
                    threadId: "task-\(task.id.uuidString)",
                    userInfo: ["taskId": task.id.uuidString, "action": "ending"],
                    preferences: preferences
                )
                try await scheduleOne(id: "task-\(task.id.uuidString)-end-\(minutes)", content: content, date: fireDate)
            }

            let missedDate = end.addingTimeInterval(5 * 60)
            if missedDate > .now {
                let missedContent = makeContent(
                    title: "⚠️ You missed this task",
                    body: task.title,
                    category: NotificationCategoryID.taskMissed,
                    threadId: "task-\(task.id.uuidString)",
                    userInfo: ["taskId": task.id.uuidString, "action": "missed"],
                    preferences: preferences
                )
                try await scheduleOne(id: "task-\(task.id.uuidString)-missed", content: missedContent, date: missedDate)
            }
        }
    }

    func scheduleMissedTask(task: TaskItem) async throws {
        let content = makeContent(
            title: "⚠️ You missed this task",
            body: "\(task.title)\n\nStart now or reschedule?",
            category: NotificationCategoryID.taskMissed,
            threadId: "task-\(task.id.uuidString)",
            userInfo: ["taskId": task.id.uuidString, "action": "missed"],
            preferences: PopPopPreferences()
        )
        try await scheduleOne(id: "missed-now-\(task.id.uuidString)", content: content, date: .now.addingTimeInterval(2))
    }

    func cancelTaskPops(taskId: UUID) async {
        let pending = await center.pendingNotificationRequests()
        let ids = pending.map(\.identifier).filter { $0.contains(taskId.uuidString) }
        center.removePendingNotificationRequests(withIdentifiers: ids)
        center.removeDeliveredNotifications(withIdentifiers: ids)
    }

    func cancelAll() async {
        center.removeAllPendingNotificationRequests()
    }

    func pendingCount() async -> Int {
        await center.pendingNotificationRequests().count
    }

    func upcomingPops(limit: Int) async -> [UpcomingPop] {
        let pending = await center.pendingNotificationRequests()
        return pending.compactMap { req -> UpcomingPop? in
            guard let trigger = req.trigger as? UNCalendarNotificationTrigger,
                  let next = trigger.nextTriggerDate() else { return nil }
            let icon: String
            if req.content.title.contains("🔔") { icon = "bell.fill" }
            else if req.content.title.contains("⚠️") { icon = "exclamationmark.triangle.fill" }
            else if req.content.title.contains("☀️") { icon = "sun.max.fill" }
            else if req.content.title.contains("🌙") { icon = "moon.fill" }
            else if req.content.title.contains("🤖") { icon = "sparkles" }
            else { icon = "bolt.fill" }

            return UpcomingPop(
                id: req.identifier,
                title: req.content.title,
                body: req.content.body,
                date: next,
                icon: icon
            )
        }
        .sorted { $0.date < $1.date }
        .prefix(limit)
        .map { $0 }
    }

    // MARK: - Schedule blocks

    private func scheduleBlockPops(block: ResolvedScheduleBlock, preferences: PopPopPreferences) async throws {
        let icon = block.icon ?? "calendar"
        let emoji = emojiForBlock(block)

        for minutes in [30, 15, 5] {
            let fireDate = block.startTime.addingTimeInterval(-Double(minutes * 60))
            guard fireDate > .now else { continue }

            let content = makeContent(
                title: "🔔 \(block.title) in \(minutes)m",
                body: "\(emoji) Starting at \(block.startTime.timeString())",
                category: NotificationCategoryID.scheduleBlock,
                threadId: "block-\(block.sourceBlockId.uuidString)",
                userInfo: ["blockId": block.sourceBlockId.uuidString, "action": "blockReminder"],
                preferences: preferences
            )
            try await scheduleOne(
                id: "block-\(block.sourceBlockId.uuidString)-\(minutes)",
                content: content,
                date: fireDate
            )
        }

        let startContent = makeContent(
            title: "\(emoji) \(block.title)",
            body: "POP! Your \(block.title.lowercased()) block has started.",
            category: NotificationCategoryID.scheduleBlock,
            threadId: "block-\(block.sourceBlockId.uuidString)",
            userInfo: ["blockId": block.sourceBlockId.uuidString, "action": "blockStart"],
            preferences: preferences
        )
        try await scheduleOne(
            id: "block-\(block.sourceBlockId.uuidString)-start",
            content: startContent,
            date: block.startTime
        )
    }

    private func scheduleWakeUp(at date: Date, preferences: PopPopPreferences) async throws {
        let content = makeContent(
            title: "☀️ Wake up!",
            body: "Good morning! Your schedule is ready. Let's go.",
            category: NotificationCategoryID.wakeUp,
            threadId: "daily-routine",
            userInfo: ["action": "wakeUp"],
            preferences: preferences
        )
        try await scheduleRepeating(id: "wake-up", content: content, date: date)
    }

    private func scheduleWindDown(bedtime: Date, preferences: PopPopPreferences) async throws {
        let windDown = bedtime.addingTimeInterval(-30 * 60)
        let content = makeContent(
            title: "🌙 Wind Down",
            body: "30 minutes to bedtime. Start winding down.",
            category: NotificationCategoryID.windDown,
            threadId: "daily-routine",
            userInfo: ["action": "windDown"],
            preferences: preferences
        )
        try await scheduleRepeating(id: "wind-down", content: content, date: windDown)
    }

    private func scheduleSleep(at date: Date, preferences: PopPopPreferences) async throws {
        let content = makeContent(
            title: "😴 Sleep Time",
            body: "Put your phone down. Rest well.",
            category: NotificationCategoryID.sleep,
            threadId: "daily-routine",
            userInfo: ["action": "sleep"],
            preferences: preferences
        )
        try await scheduleRepeating(id: "sleep-time", content: content, date: date)
    }

    private func scheduleMorningBriefing(hour: Int, minute: Int, name: String, preferences: PopPopPreferences) async throws {
        var content = makeContent(
            title: "☀️ Good Morning, \(name)!",
            body: "Your day is planned. Tap to see today's schedule.",
            category: NotificationCategoryID.morningBriefing,
            threadId: "daily-routine",
            userInfo: ["action": "morningBriefing"],
            preferences: preferences
        )
        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        try await center.add(UNNotificationRequest(identifier: "morning-briefing", content: content, trigger: trigger))
    }

    private func scheduleAINews(hour: Int, minute: Int, preferences: PopPopPreferences) async throws {
        let content = makeContent(
            title: "🤖 Your 10 AI updates are ready",
            body: "Today's AI briefing is waiting for you.",
            category: NotificationCategoryID.aiNews,
            threadId: "ai-news",
            userInfo: ["action": "aiNews"],
            preferences: preferences
        )
        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        try await center.add(UNNotificationRequest(identifier: "ai-news-daily", content: content, trigger: trigger))
    }

    // MARK: - Helpers

    private func makeContent(
        title: String,
        body: String,
        category: String,
        threadId: String,
        userInfo: [String: Any],
        preferences: PopPopPreferences
    ) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.categoryIdentifier = category
        content.threadIdentifier = threadId
        content.userInfo = userInfo
        if preferences.soundEnabled {
            content.sound = .default
        }
        if preferences.badgeEnabled {
            content.badge = 1
        }
        if preferences.timeSensitive {
            content.interruptionLevel = .timeSensitive
        }
        content.relevanceScore = 1.0
        return content
    }

    private func scheduleOne(id: String, content: UNMutableNotificationContent, date: Date) async throws {
        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: date
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        try await center.add(UNNotificationRequest(identifier: id, content: content, trigger: trigger))
    }

    private func scheduleRepeating(id: String, content: UNMutableNotificationContent, date: Date) async throws {
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        try await center.add(UNNotificationRequest(identifier: id, content: content, trigger: trigger))
    }

    private func iconForCategory(_ category: String) -> String {
        switch category.lowercased() {
        case "personal coding": return "💻"
        case "college": return "🎓"
        case "sleep": return "🌙"
        default: return "📋"
        }
    }

    private func emojiForBlock(_ block: ResolvedScheduleBlock) -> String {
        switch block.blockType {
        case ScheduleBlockType.college.rawValue: return "🎓"
        case ScheduleBlockType.coding.rawValue: return "💻"
        case ScheduleBlockType.sleep.rawValue: return "🌙"
        case ScheduleBlockType.routine.rawValue: return "☀️"
        default: return "📅"
        }
    }
}

// Backward-compatible protocol adapter
extension PopPopNotificationEngine: NotificationSchedulerProtocol {
    func scheduleTaskReminder(taskId: UUID, title: String, date: Date, minutesBefore: Int) async throws {
        let task = TaskItem(id: taskId, title: title, scheduledStart: date, scheduledEnd: date.adding(minutes: 30))
        var prefs = PopPopPreferences()
        prefs.beforeTaskMinutes = [minutesBefore]
        try await scheduleTaskPops(task: task, preferences: prefs)
    }

    func cancelReminders(for taskId: UUID) async {
        await cancelTaskPops(taskId: taskId)
    }

    func scheduleDailyBriefing(at hour: Int, minute: Int) async throws {
        var prefs = PopPopPreferences()
        prefs.newsBriefingHour = hour
        prefs.newsBriefingMinute = minute
        try await scheduleAINews(hour: hour, minute: minute, preferences: prefs)
    }

    func scheduleWakeUp(at date: Date) async throws {
        try await scheduleWakeUp(at: date, preferences: PopPopPreferences())
    }

    func scheduleSleepReminder(at date: Date) async throws {
        try await scheduleWindDown(bedtime: date, preferences: PopPopPreferences())
    }
}
