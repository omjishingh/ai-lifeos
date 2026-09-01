import Foundation
import SwiftUI

@MainActor
@Observable
final class TasksViewModel {
    private let taskService: TaskServiceProtocol

    var tasks: [TaskItem] = []
    var isLoading = false
    var errorMessage: String?
    var showingAddTask = false
    var editingTask: TaskItem?

    init(taskService: TaskServiceProtocol) {
        self.taskService = taskService
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        do {
            tasks = try taskService.fetchAll()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func complete(_ task: TaskItem) async {
        do {
            try taskService.completeTask(task)
            await load()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func start(_ task: TaskItem) async {
        do {
            try taskService.startTask(task)
            await load()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func delete(_ task: TaskItem) async {
        do {
            try taskService.deleteTask(task)
            await load()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func saveTask(
        title: String,
        description: String,
        category: String,
        priority: TaskPriority,
        durationMinutes: Int,
        deadline: Date?,
        existing: TaskItem?
    ) async {
        do {
            if let existing {
                existing.title = title
                existing.taskDescription = description
                existing.category = category
                existing.priority = priority.rawValue
                existing.estimatedDurationMinutes = durationMinutes
                existing.deadline = deadline
                try taskService.updateTask(existing)
            } else {
                let task = TaskItem(
                    title: title,
                    taskDescription: description,
                    category: category,
                    priority: priority.rawValue,
                    estimatedDurationMinutes: durationMinutes,
                    deadline: deadline,
                    scheduledStart: Date.now.adding(minutes: 30),
                    scheduledEnd: Date.now.adding(minutes: 30 + durationMinutes)
                )
                try taskService.createTask(task)
            }
            showingAddTask = false
            editingTask = nil
            await load()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
