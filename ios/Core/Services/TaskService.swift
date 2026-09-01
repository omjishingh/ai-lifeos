import Foundation

protocol TaskServiceProtocol {
    func createTask(_ task: TaskItem) throws
    func updateTask(_ task: TaskItem) throws
    func deleteTask(_ task: TaskItem) throws
    func completeTask(_ task: TaskItem) throws
    func startTask(_ task: TaskItem) throws
    func snoozeTask(_ task: TaskItem, minutes: Int) throws
    func fetchAll() throws -> [TaskItem]
    func fetchForDate(_ date: Date) throws -> [TaskItem]
}

struct TaskService: TaskServiceProtocol {
    private let taskRepository: TaskRepositoryProtocol
    private let popEngine: PopPopNotificationEngineProtocol

    init(taskRepository: TaskRepositoryProtocol, popEngine: PopPopNotificationEngineProtocol) {
        self.taskRepository = taskRepository
        self.popEngine = popEngine
    }

    func fetchAll() throws -> [TaskItem] {
        try taskRepository.fetchAll()
    }

    func fetchForDate(_ date: Date) throws -> [TaskItem] {
        try taskRepository.fetchForDate(date)
    }

    func createTask(_ task: TaskItem) throws {
        try taskRepository.create(task)
        scheduleReminders(for: task)
    }

    func updateTask(_ task: TaskItem) throws {
        try taskRepository.update(task)
        Task { await popEngine.cancelTaskPops(taskId: task.id) }
        scheduleReminders(for: task)
    }

    func deleteTask(_ task: TaskItem) throws {
        Task { await popEngine.cancelTaskPops(taskId: task.id) }
        try taskRepository.delete(task)
    }

    func completeTask(_ task: TaskItem) throws {
        task.taskStatus = .completed
        task.completedAt = .now
        try taskRepository.update(task)
        Task { await popEngine.cancelTaskPops(taskId: task.id) }
    }

    func startTask(_ task: TaskItem) throws {
        task.taskStatus = .inProgress
        try taskRepository.update(task)
    }

    func snoozeTask(_ task: TaskItem, minutes: Int = 15) throws {
        task.taskStatus = .postponed
        if let start = task.scheduledStart {
            task.scheduledStart = start.adding(minutes: minutes)
            if let end = task.scheduledEnd {
                task.scheduledEnd = end.adding(minutes: minutes)
            }
        } else {
            task.scheduledStart = Date.now.adding(minutes: minutes)
        }
        task.taskStatus = .planned
        try taskRepository.update(task)
        scheduleReminders(for: task)
    }

    private func scheduleReminders(for task: TaskItem) {
        guard task.scheduledStart != nil,
              task.taskStatus == .planned || task.taskStatus == .inProgress else { return }
        Task {
            var prefs = PopPopPreferences()
            try? await popEngine.scheduleTaskPops(task: task, preferences: prefs)
        }
    }
}
