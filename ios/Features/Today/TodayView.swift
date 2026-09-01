import SwiftUI
import Combine

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
            .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
                viewModel?.refreshTick()
            }
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
                PopPopPreviewCard(upcomingPops: viewModel.upcomingPops, pendingCount: viewModel.pendingPopCount)
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
        let _ = vm.tick
        if let task = vm.currentTask {
            HeroNowCard(
                title: task.title,
                subtitle: task.category,
                timeRange: taskTimeRange(task) ?? "",
                remaining: vm.remainingTime(for: task),
                progress: vm.progressForCurrent(),
                icon: iconForCategory(task.category),
                color: colorForCategory(task.category),
                onFocus: { Task { await vm.startCurrentTask(); vm.showFocus = true } },
                onComplete: { Task { await vm.completeCurrentTask() } }
            )
        } else if let block = vm.currentBlock {
            HeroNowCard(
                title: block.title,
                subtitle: block.blockType.capitalized,
                timeRange: "\(block.startTime.timeString()) — \(block.endTime.timeString())",
                remaining: remainingTimeForBlock(block),
                progress: vm.progressForCurrent(),
                icon: block.icon ?? "calendar",
                color: blockColor(block)
            )
        }
    }

    private func remainingTimeForBlock(_ block: ResolvedScheduleBlock) -> String? {
        let remaining = Int(block.endTime.timeIntervalSince(.now))
        guard remaining > 0 else { return nil }
        let h = remaining / 3600
        let m = (remaining % 3600) / 60
        let s = remaining % 60
        if h > 0 { return String(format: "%02d:%02d:%02d", h, m, s) }
        return String(format: "%02d:%02d", m, s)
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
            goalRepository: env.goalRepository, streakRepository: env.streakRepository,
            userProfile: env.userProfile, popPopEngine: env.popPopEngine)
    }

    private func iconForCategory(_ category: String) -> String {
        switch category.lowercased() {
        case "personal coding": return "laptopcomputer"
        case "college": return "graduationcap.fill"
        case "sleep": return "moon.fill"
        default: return "checkmark.circle"
        }
    }

    private func colorForCategory(_ category: String) -> Color {
        switch category.lowercased() {
        case "personal coding": return colors.coding
        case "college": return colors.college
        case "sleep": return colors.sleep
        default: return colors.accent
        }
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
