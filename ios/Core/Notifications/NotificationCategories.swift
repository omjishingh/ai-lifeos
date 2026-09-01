import Foundation
import UserNotifications

enum NotificationCategoryID {
    static let taskReminder = "TASK_REMINDER"
    static let taskStart = "TASK_START"
    static let taskMissed = "TASK_MISSED"
    static let scheduleBlock = "SCHEDULE_BLOCK"
    static let morningBriefing = "MORNING_BRIEFING"
    static let windDown = "WIND_DOWN"
    static let sleep = "SLEEP"
    static let wakeUp = "WAKE_UP"
    static let aiNews = "AI_NEWS"
}

enum NotificationActionID {
    static let startNow = "START_NOW"
    static let moveLater = "MOVE_LATER"
    static let tomorrow = "TOMORROW"
    static let snooze15 = "SNOOZE_15"
    static let complete = "COMPLETE"
    static let openApp = "OPEN_APP"
}

enum PopPopNotificationCategories {
    static func registerAll() {
        let center = UNUserNotificationCenter.current()

        let startNow = UNNotificationAction(
            identifier: NotificationActionID.startNow,
            title: "Start Now",
            options: [.foreground]
        )
        let moveLater = UNNotificationAction(
            identifier: NotificationActionID.moveLater,
            title: "Move to Later",
            options: []
        )
        let tomorrow = UNNotificationAction(
            identifier: NotificationActionID.tomorrow,
            title: "Tomorrow",
            options: []
        )
        let snooze = UNNotificationAction(
            identifier: NotificationActionID.snooze15,
            title: "Snooze 15m",
            options: []
        )
        let complete = UNNotificationAction(
            identifier: NotificationActionID.complete,
            title: "Complete",
            options: [.foreground]
        )
        let openApp = UNNotificationAction(
            identifier: NotificationActionID.openApp,
            title: "Open",
            options: [.foreground]
        )

        let missed = UNNotificationCategory(
            identifier: NotificationCategoryID.taskMissed,
            actions: [startNow, moveLater, tomorrow],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )

        let reminder = UNNotificationCategory(
            identifier: NotificationCategoryID.taskReminder,
            actions: [snooze, startNow],
            intentIdentifiers: [],
            options: []
        )

        let taskStart = UNNotificationCategory(
            identifier: NotificationCategoryID.taskStart,
            actions: [startNow, complete, snooze],
            intentIdentifiers: [],
            options: []
        )

        let schedule = UNNotificationCategory(
            identifier: NotificationCategoryID.scheduleBlock,
            actions: [openApp, snooze],
            intentIdentifiers: [],
            options: []
        )

        let briefing = UNNotificationCategory(
            identifier: NotificationCategoryID.morningBriefing,
            actions: [openApp],
            intentIdentifiers: [],
            options: []
        )

        let windDown = UNNotificationCategory(
            identifier: NotificationCategoryID.windDown,
            actions: [openApp],
            intentIdentifiers: [],
            options: []
        )

        let wake = UNNotificationCategory(
            identifier: NotificationCategoryID.wakeUp,
            actions: [openApp],
            intentIdentifiers: [],
            options: []
        )

        let news = UNNotificationCategory(
            identifier: NotificationCategoryID.aiNews,
            actions: [openApp],
            intentIdentifiers: [],
            options: []
        )

        center.setNotificationCategories([
            missed, reminder, taskStart, schedule, briefing, windDown, wake, news
        ])
    }
}
