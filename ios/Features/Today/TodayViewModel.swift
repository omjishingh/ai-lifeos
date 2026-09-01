import Foundation

@MainActor
@Observable
final class TodayViewModel {
    private let taskService: TaskServiceProtocol
    private let scheduleService: ScheduleServiceProtocol
    private let goalRepository: GoalRepositoryProtocol
    private let streakRepository: StreakRepositoryProtocol
    private let userProfile: UserProfile?
    private let popPopEngine: PopPopNotificationEngineProtocol

    var state: TodayViewState = .loading
    var tasks: [TaskItem] = []
    var scheduleBlocks: [ResolvedScheduleBlock] = []
    var goals: [Goal] = []
    var currentStreak: Int = 0
    var goalsCompleted: Int = 0
    var goalsTotal: Int = 0
    var showAddTask = false
    var showFocus = false
    var upcomingPops: [UpcomingPop] = []
    var pendingPopCount: Int = 0
    var tick = Date.now

    var greeting: String {
        let name = userProfile?.name ?? "there"
        return "\(GreetingHelper.greeting()), \(name)"
    }

    var dateString: String {
        DateFormatters.dayAndDate.string(from: .now)
    }

    var progressPercentage: Double {
        let taskTotal = tasks.count
        let taskDone = tasks.filter { $0.taskStatus == .completed }.count
        if taskTotal > 0 {
            return Double(taskDone) / Double(taskTotal)
        }
        guard goalsTotal > 0 else { return 0 }
        return Double(goalsCompleted) / Double(goalsTotal)
    }

    var progressLabel: String {
        let taskTotal = tasks.count
        let taskDone = tasks.filter { $0.taskStatus == .completed }.count
        if taskTotal > 0 {
            return "\(taskDone) / \(taskTotal) tasks completed"
        }
        return "\(goalsCompleted) / \(goalsTotal) goals completed"
    }

    var currentTask: TaskItem? {
        tasks.first { $0.taskStatus == .inProgress }
            ?? tasks.first { $0.taskStatus == .planned && isTaskNow($0) }
            ?? tasks.first { $0.taskStatus == .planned }
    }

    var currentBlock: ResolvedScheduleBlock? {
        let now = Date.now
        return scheduleBlocks.first { $0.startTime <= now && $0.endTime > now }
    }

    init(
        taskService: TaskServiceProtocol,
        scheduleService: ScheduleServiceProtocol,
        goalRepository: GoalRepositoryProtocol,
        streakRepository: StreakRepositoryProtocol,
        userProfile: UserProfile?,
        popPopEngine: PopPopNotificationEngineProtocol
    ) {
        self.taskService = taskService
        self.scheduleService = scheduleService
        self.goalRepository = goalRepository
        self.streakRepository = streakRepository
        self.userProfile = userProfile
        self.popPopEngine = popPopEngine
    }

    func load() async {
        state = .loading
        do {
            let today = Date.now
            tasks = try taskService.fetchForDate(today)
            scheduleBlocks = try scheduleService.resolvedBlocks(for: today)
            goals = try goalRepository.fetchForDate(today)
            goalsTotal = max(goals.count, 1)
            goalsCompleted = goals.filter(\.isCompleted).count

            if let streak = try streakRepository.fetchByType(.overall) {
                currentStreak = streak.currentStreak
            } else if let coding = try streakRepository.fetchByType(.coding) {
                currentStreak = coding.currentStreak
            }

            pendingPopCount = await popPopEngine.pendingCount()
            upcomingPops = await popPopEngine.upcomingPops(limit: 8)

            state = scheduleBlocks.isEmpty && tasks.isEmpty ? .empty : .loaded
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    func completeCurrentTask() async {
        guard let task = currentTask else { return }
        do {
            try taskService.completeTask(task)
            await load()
        } catch {}
    }

    func startCurrentTask() async {
        guard let task = currentTask else { return }
        do {
            try taskService.startTask(task)
            await load()
        } catch {}
    }

    func remainingTime(for task: TaskItem) -> String? {
        guard let end = task.scheduledEnd else { return nil }
        let remaining = Int(end.timeIntervalSince(.now))
        guard remaining > 0 else { return nil }
        let h = remaining / 3600
        let m = (remaining % 3600) / 60
        let s = remaining % 60
        if h > 0 { return String(format: "%02d:%02d:%02d", h, m, s) }
        return String(format: "%02d:%02d", m, s)
    }

    func refreshTick() {
        tick = .now
    }

    func progressForCurrent() -> Double {
        if let task = currentTask,
           let start = task.scheduledStart,
           let end = task.scheduledEnd {
            let total = end.timeIntervalSince(start)
            guard total > 0 else { return 0 }
            let elapsed = Date.now.timeIntervalSince(start)
            return min(max(elapsed / total, 0), 1)
        }
        if let block = currentBlock {
            let total = block.endTime.timeIntervalSince(block.startTime)
            guard total > 0 else { return 0 }
            let elapsed = Date.now.timeIntervalSince(block.startTime)
            return min(max(elapsed / total, 0), 1)
        }
        return 0
    }

    private func isTaskNow(_ task: TaskItem) -> Bool {
        guard let start = task.scheduledStart, let end = task.scheduledEnd else { return false }
        let now = Date.now
        return start <= now && end > now
    }
}

enum TodayViewState {
    case loading, loaded, empty, error(String)
}
