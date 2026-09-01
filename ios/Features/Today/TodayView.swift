import SwiftUI

struct TodayView: View {
    @Environment(\.appEnvironment) private var appEnvironment
    @Environment(\.appColors) private var colors
    @State private var viewModel: TodayViewModel?

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel { content(for: viewModel) }
                else { LoadingView(message: "Loading your day...") }
            }
            .navigationTitle("Today")
            .navigationBarTitleDisplayMode(.inline)
            .task { setupViewModel(); await viewModel?.load() }
            .refreshable { await viewModel?.load() }
            .sheet(isPresented: Binding(get: { viewModel?.showAddTask ?? false }, set: { viewModel?.showAddTask = $0 })) {
                TaskFormView(existing: nil) { title, desc, cat, pri, dur, deadline in
                    Task {
                        try? appEnvironment?.taskService.createTask(TaskItem(
                            title: title, taskDescription: desc, category: cat,
                            priority: pri.rawValue, estimatedDurationMinutes: dur,
                            deadline: deadline, scheduledStart: .now.adding(minutes: 15),
                            scheduledEnd: .now.adding(minutes: 15 + dur)
                        ))
                        await viewModel?.load()
                    }
                }
            }
            .fullScreenCover(isPresented: Binding(get: { viewModel?.showFocus ?? false }, set: { viewModel?.showFocus = $0 })) {
                NavigationStack {
                    FocusView(
                        taskTitle: viewModel?.currentTask?.title ?? viewModel?.currentBlock?.title ?? "Personal Coding",
                        taskId: viewModel?.currentTask?.id,
                        plannedMinutes: viewModel?.currentTask?.estimatedDurationMinutes ?? 25
                    )
                }
            }
        }
    }

    @ViewBuilder
    private func content(for viewModel: TodayViewModel) -> some View {
        switch viewModel.state {
        case .loading: LoadingView(message: "Loading your day...")
        case .empty: emptyContent(viewModel)
        case .error(let msg): ErrorView(title: "Couldn't load today", message: msg, onRetry: { Task { await viewModel.load() } })
        case .loaded: loadedContent(viewModel)
        }
    }

    private func emptyContent(_ viewModel: TodayViewModel) -> some View {
        EmptyState(icon: "sun.max", title: "No tasks today", message: "You are free 🎉", actionTitle: "Add a task") {
            viewModel.showAddTask = true
        }
    }

    private func loadedContent(_ viewModel: TodayViewModel) -> some View {
        ScrollView {
            LazyVStack(spacing: AppSpacing.lg) {
                headerSection(viewModel)
                nowSection(viewModel)
                progressSection(viewModel)
                timelineSection(viewModel)
                quickActionsSection(viewModel)
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.bottom, AppSpacing.xl)
        }
        .background(colors.background)
    }

    private func headerSection(_ vm: TodayViewModel) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text(vm.greeting).font(AppTypography.title2)
            Text(vm.dateString).font(AppTypography.subheadline).foregroundStyle(colors.secondaryText)
            if vm.currentStreak > 0 { StreakBadge(days: vm.currentStreak) }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, AppSpacing.sm)
    }

    @ViewBuilder
    private func nowSection(_ vm: TodayViewModel) -> some View {
        if let task = vm.currentTask {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                Text("NOW").font(AppTypography.caption).foregroundStyle(colors.accent).fontWeight(.semibold)
                if let remaining = vm.remainingTime(for: task) {
                    Text("\(remaining) remaining").font(AppTypography.caption).foregroundStyle(colors.secondaryText).monospacedDigit()
                }
                TaskCard(title: task.title, category: task.category, timeRange: taskTimeRange(task), status: task.taskStatus, progress: nil,
                    onStart: { Task { await vm.startCurrentTask(); vm.showFocus = true } },
                    onComplete: { Task { await vm.completeCurrentTask() } })
            }
        } else if let block = vm.currentBlock {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                Text("NOW").font(AppTypography.caption).foregroundStyle(colors.accent).fontWeight(.semibold)
                GlassCard {
                    HStack {
                        Image(systemName: block.icon ?? "circle.fill").foregroundStyle(colors.accent)
                        VStack(alignment: .leading) {
                            Text(block.title).font(AppTypography.headline)
                            Text("\(block.startTime.timeString()) — \(block.endTime.timeString())").font(AppTypography.caption).foregroundStyle(colors.secondaryText)
                        }
                    }
                }
            }
        }
    }

    private func progressSection(_ vm: TodayViewModel) -> some View {
        GlassCard {
            HStack(spacing: AppSpacing.lg) {
                ProgressRing(progress: vm.progressPercentage, label: "Today")
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text("Today's Progress").font(AppTypography.headline)
                    Text(vm.progressLabel).font(AppTypography.subheadline).foregroundStyle(colors.secondaryText)
                }
                Spacer()
            }
        }
    }

    private func timelineSection(_ vm: TodayViewModel) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Timeline").font(AppTypography.headline)
            ForEach(vm.scheduleBlocks) { block in
                TimelineCard(title: block.title, startTime: block.startTime.timeString(), endTime: block.endTime.timeString(),
                    icon: block.icon ?? "circle.fill", color: blockColor(block), isActive: isBlockActive(block), isCompleted: block.endTime < .now)
            }
        }
    }

    private func quickActionsSection(_ vm: TodayViewModel) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Quick Actions").font(AppTypography.headline)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: AppSpacing.sm) {
                QuickActionChip(title: "Task", icon: "plus") { vm.showAddTask = true }
                NavigationLink { SleepView() } label: { QuickActionLabel(title: "Sleep", icon: "moon.fill") }
                NavigationLink { CollegeView() } label: { QuickActionLabel(title: "College", icon: "graduationcap.fill") }
                NavigationLink { AIChatView() } label: { QuickActionLabel(title: "AI Plan", icon: "sparkles") }
                QuickActionChip(title: "Focus", icon: "bolt.fill") { vm.showFocus = true }
            }
        }
    }

    private func setupViewModel() {
        guard let env = appEnvironment, viewModel == nil else { return }
        viewModel = TodayViewModel(taskService: env.taskService, scheduleService: env.scheduleService,
            goalRepository: env.goalRepository, streakRepository: env.streakRepository, userProfile: env.userProfile)
    }

    private func taskTimeRange(_ task: TaskItem) -> String? {
        guard let start = task.scheduledStart else { return nil }
        if let end = task.scheduledEnd { return "\(start.timeString()) — \(end.timeString())" }
        return start.timeString()
    }

    private func blockColor(_ block: ResolvedScheduleBlock) -> Color {
        switch block.blockType {
        case ScheduleBlockType.college.rawValue: return colors.college
        case ScheduleBlockType.coding.rawValue: return colors.coding
        case ScheduleBlockType.sleep.rawValue: return colors.sleep
        default: return colors.accent
        }
    }

    private func isBlockActive(_ block: ResolvedScheduleBlock) -> Bool {
        let now = Date.now
        return block.startTime <= now && block.endTime > now
    }
}

struct QuickActionChip: View {
    let title: String; let icon: String; let action: () -> Void
    @Environment(\.appColors) private var colors
    var body: some View {
        Button(action: action) {
            VStack(spacing: AppSpacing.xs) {
                Image(systemName: icon).font(.title3)
                Text(title).font(AppTypography.caption)
            }
            .frame(maxWidth: .infinity).frame(minHeight: AppHitTarget.minimum)
            .background(colors.secondaryBackground).clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
        }.buttonStyle(.plain).accessibilityLabel(title)
    }
}

struct QuickActionLabel: View {
    let title: String; let icon: String
    @Environment(\.appColors) private var colors
    var body: some View {
        VStack(spacing: AppSpacing.xs) {
            Image(systemName: icon).font(.title3)
            Text(title).font(AppTypography.caption)
        }
        .frame(maxWidth: .infinity).frame(minHeight: AppHitTarget.minimum)
        .background(colors.secondaryBackground).clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
        .foregroundStyle(colors.primaryText)
    }
}

#Preview {
    TodayView().environment(\.appEnvironment, try! AppEnvironment(modelContainer: makeModelContainer(inMemory: true)))
}
