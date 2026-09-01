import Foundation
import UserNotifications

final class NotificationScheduler: NotificationSchedulerProtocol {
    private let center = UNUserNotificationCenter.current()

    func requestPermission() async -> Bool {
        do {
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    func scheduleTaskReminder(taskId: UUID, title: String, date: Date, minutesBefore: Int) async throws {
        let triggerDate = date.addingTimeInterval(-Double(minutesBefore * 60))
        guard triggerDate > .now else { return }

        let content = UNMutableNotificationContent()
        content.title = "🔔 \(title) starts in \(minutesBefore) minutes"
        content.body = "Your planned session is coming up."
        content.sound = .default
        content.userInfo = ["taskId": taskId.uuidString, "action": "taskReminder"]

        try await schedule(
            identifier: "task-\(taskId.uuidString)-\(minutesBefore)",
            content: content,
            date: triggerDate
        )

        let startContent = UNMutableNotificationContent()
        startContent.title = "💻 \(title)"
        startContent.body = "Your planned session has started."
        startContent.sound = .default
        startContent.userInfo = ["taskId": taskId.uuidString, "action": "taskStart"]

        try await schedule(
            identifier: "task-start-\(taskId.uuidString)",
            content: startContent,
            date: date
        )
    }

    func cancelReminders(for taskId: UUID) async {
        let pending = await center.pendingNotificationRequests()
        let ids = pending
            .map(\.identifier)
            .filter { $0.contains(taskId.uuidString) }
        center.removePendingNotificationRequests(withIdentifiers: ids)
    }

    func scheduleDailyBriefing(at hour: Int, minute: Int) async throws {
        let content = UNMutableNotificationContent()
        content.title = "🤖 Your 10 AI updates are ready"
        content.body = "Tap to read today's AI briefing."
        content.sound = .default

        var components = DateComponents()
        components.hour = hour
        components.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "daily-ai-news", content: content, trigger: trigger)
        try await center.add(request)
    }

    func scheduleWakeUp(at date: Date) async throws {
        let content = UNMutableNotificationContent()
        content.title = "☀️ Wake up"
        content.body = "Good morning! Your day is ready."
        content.sound = .default

        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "wake-up", content: content, trigger: trigger)
        try await center.add(request)
    }

    func scheduleSleepReminder(at date: Date) async throws {
        let windDown = date.addingTimeInterval(-30 * 60)
        let content = UNMutableNotificationContent()
        content.title = "🌙 Wind Down"
        content.body = "Time to start winding down for sleep."
        content.sound = .default

        let components = Calendar.current.dateComponents([.hour, .minute], from: windDown)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "sleep-winddown", content: content, trigger: trigger)
        try await center.add(request)
    }

    private func schedule(identifier: String, content: UNMutableNotificationContent, date: Date) async throws {
        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: date
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        try await center.add(request)
    }
}
