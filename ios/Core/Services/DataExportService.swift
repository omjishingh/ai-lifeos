import Foundation

struct DataExportService {
    static func exportJSON(
        profile: UserProfile?,
        tasks: [TaskItem],
        blocks: [ScheduleBlock],
        goals: [Goal],
        streaks: [Streak]
    ) -> Data? {
        let export: [String: Any] = [
            "exportedAt": ISO8601DateFormatter().string(from: .now),
            "profile": profileExport(profile),
            "tasks": tasks.map(taskExport),
            "scheduleBlocks": blocks.map(blockExport),
            "goals": goals.map(goalExport),
            "streaks": streaks.map(streakExport)
        ]
        return try? JSONSerialization.data(withJSONObject: export, options: .prettyPrinted)
    }

    private static func profileExport(_ p: UserProfile?) -> [String: Any] {
        guard let p else { return [:] }
        return [
            "name": p.name,
            "wakeUpTime": p.wakeUpTime.timeString(),
            "sleepTime": p.sleepTime.timeString(),
            "codingTargetMinutes": p.codingTargetMinutes
        ]
    }

    private static func taskExport(_ t: TaskItem) -> [String: Any] {
        [
            "id": t.id.uuidString,
            "title": t.title,
            "status": t.status,
            "category": t.category,
            "priority": t.priority
        ]
    }

    private static func blockExport(_ b: ScheduleBlock) -> [String: Any] {
        [
            "title": b.title,
            "start": b.startTime.timeString(),
            "end": b.endTime.timeString(),
            "type": b.blockType
        ]
    }

    private static func goalExport(_ g: Goal) -> [String: Any] {
        ["title": g.title, "progress": g.progress, "isCompleted": g.isCompleted]
    }

    private static func streakExport(_ s: Streak) -> [String: Any] {
        ["type": s.streakType, "current": s.currentStreak, "longest": s.longestStreak]
    }
}
