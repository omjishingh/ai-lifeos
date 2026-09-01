import SwiftUI

struct TasksView: View {
    @Environment(\.appEnvironment) private var appEnvironment
    @Environment(\.appColors) private var colors
    @State private var viewModel: TasksViewModel?
    @State private var filterStatus: TaskStatus?

    var filteredTasks: [TaskItem] {
        guard let viewModel else { return [] }
        guard let filterStatus else { return viewModel.tasks }
        return viewModel.tasks.filter { $0.taskStatus == filterStatus }
    }

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel {
                    content(viewModel)
                } else {
                    LoadingView(message: "Loading tasks...")
                }
            }
            .navigationTitle("Tasks")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel?.showingAddTask = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Add task")
                }
            }
            .sheet(isPresented: Binding(
                get: { viewModel?.showingAddTask ?? false },
                set: { viewModel?.showingAddTask = $0 }
            )) {
                TaskFormView(existing: nil) { title, desc, cat, pri, dur, deadline in
                    Task { await viewModel?.saveTask(title: title, description: desc, category: cat, priority: pri, durationMinutes: dur, deadline: deadline, existing: nil) }
                }
            }
            .sheet(isPresented: Binding(
                get: { viewModel?.editingTask != nil },
                set: { if !$0 { viewModel?.editingTask = nil } }
            )) {
                if let task = viewModel?.editingTask {
                    TaskFormView(existing: task) { title, desc, cat, pri, dur, deadline in
                        Task { await viewModel?.saveTask(title: title, description: desc, category: cat, priority: pri, durationMinutes: dur, deadline: deadline, existing: task) }
                    }
                }
            }
            .task {
                setupViewModel()
                await viewModel?.load()
            }
        }
    }

    @ViewBuilder
    private func content(_ viewModel: TasksViewModel) -> some View {
        if viewModel.isLoading {
            LoadingView(message: "Loading tasks...")
        } else if let error = viewModel.errorMessage {
            ErrorView(title: "Couldn't load tasks", message: error, onRetry: { Task { await viewModel.load() } })
        } else if viewModel.tasks.isEmpty {
            EmptyState(icon: "checklist", title: "No tasks yet", message: "Create your first task.", actionTitle: "Add Task") {
                viewModel.showingAddTask = true
            }
        } else {
            taskList(viewModel)
        }
    }

    private func taskList(_ viewModel: TasksViewModel) -> some View {
        VStack(spacing: 0) {
            filterChips.padding(.horizontal, AppSpacing.md).padding(.vertical, AppSpacing.sm)
            List(filteredTasks, id: \.id) { task in
                TaskCard(
                    title: task.title,
                    category: task.category,
                    timeRange: taskTimeRange(task),
                    status: task.taskStatus,
                    progress: nil,
                    onStart: { Task { await viewModel.start(task) } },
                    onComplete: { Task { await viewModel.complete(task) } }
                )
                .onTapGesture { viewModel.editingTask = task }
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) { Task { await viewModel.delete(task) } } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
                .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
            .listStyle(.plain)
        }
        .background(colors.background)
    }

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppSpacing.xs) {
                Chip(label: "All", isSelected: filterStatus == nil) { filterStatus = nil }
                ForEach(TaskStatus.allCases, id: \.self) { status in
                    Chip(label: status.displayName, isSelected: filterStatus == status) { filterStatus = status }
                }
            }
        }
    }

    private func setupViewModel() {
        guard let appEnvironment, viewModel == nil else { return }
        viewModel = TasksViewModel(taskService: appEnvironment.taskService)
    }

    private func taskTimeRange(_ task: TaskItem) -> String? {
        guard let start = task.scheduledStart else { return nil }
        if let end = task.scheduledEnd { return "\(start.timeString()) — \(end.timeString())" }
        return start.timeString()
    }
}

#Preview {
    TasksView()
        .environment(\.appEnvironment, try! AppEnvironment(modelContainer: makeModelContainer(inMemory: true)))
}
