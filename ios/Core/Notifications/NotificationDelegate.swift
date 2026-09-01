import Foundation
import UserNotifications

@MainActor
final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    weak var appEnvironment: AppEnvironment?

    func configure() {
        UNUserNotificationCenter.current().delegate = self
        PopPopNotificationCategories.registerAll()
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound, .badge, .list]
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        let userInfo = response.notification.request.content.userInfo
        let actionId = response.actionIdentifier

        await MainActor.run {
            handleAction(actionId: actionId, userInfo: userInfo)
        }
    }

    private func handleAction(actionId: String, userInfo: [AnyHashable: Any]) {
        guard let env = appEnvironment,
              let taskIdString = userInfo["taskId"] as? String,
              let taskId = UUID(uuidString: taskIdString) else { return }

        Task {
            guard let task = try? env.taskRepository.fetchById(taskId) else { return }

            switch actionId {
            case NotificationActionID.startNow, UNNotificationDefaultActionIdentifier:
                try? env.taskService.startTask(task)
            case NotificationActionID.complete:
                try? env.taskService.completeTask(task)
            case NotificationActionID.moveLater:
                try? env.taskService.snoozeTask(task, minutes: 60)
            case NotificationActionID.tomorrow:
                try? env.taskService.snoozeTask(task, minutes: 24 * 60)
            case NotificationActionID.snooze15:
                try? env.taskService.snoozeTask(task, minutes: 15)
            default:
                break
            }
        }
    }
}
