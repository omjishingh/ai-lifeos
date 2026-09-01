import Foundation
import SwiftData

@MainActor
@Observable
final class FocusTimerService {
    private let modelContext: ModelContext?
    private let streakService: StreakServiceProtocol
    var profileProvider: (() -> UserProfile?)?

    var isRunning = false
    var isPaused = false
    var elapsedSeconds: Int = 0
    var plannedMinutes: Int = 25
    var taskTitle: String = ""
    var taskId: UUID?
    private var timer: Timer?
    private var sessionStart: Date?

    init(modelContext: ModelContext?, streakService: StreakServiceProtocol) {
        self.modelContext = modelContext
        self.streakService = streakService
    }

    var formattedTime: String {
        let hours = elapsedSeconds / 3600
        let minutes = (elapsedSeconds % 3600) / 60
        let seconds = elapsedSeconds % 60
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var progress: Double {
        guard plannedMinutes > 0 else { return 0 }
        return min(Double(elapsedSeconds) / Double(plannedMinutes * 60), 1)
    }

    func start(taskTitle: String, taskId: UUID? = nil, plannedMinutes: Int = 25) {
        self.taskTitle = taskTitle
        self.taskId = taskId
        self.plannedMinutes = plannedMinutes
        self.elapsedSeconds = 0
        self.sessionStart = .now
        isRunning = true
        isPaused = false
        startTimer()
    }

    func pause() {
        isPaused = true
        timer?.invalidate()
    }

    func resume() {
        isPaused = false
        startTimer()
    }

    func finish() throws {
        timer?.invalidate()
        isRunning = false
        let minutes = max(elapsedSeconds / 60, 1)

        if let modelContext {
            let session = FocusSession(
                taskId: taskId,
                startTime: sessionStart ?? .now,
                endTime: .now,
                plannedDurationMinutes: plannedMinutes,
                actualDurationMinutes: minutes
            )
            modelContext.insert(session)

            let codingSession = CodingSession(
                startTime: sessionStart ?? .now,
                endTime: .now,
                durationMinutes: minutes
            )
            modelContext.insert(codingSession)
            try modelContext.save()
        }

        try streakService.recordCodingSession(minutes: minutes, profile: profileProvider?())
        reset()
    }

    func reset() {
        timer?.invalidate()
        isRunning = false
        isPaused = false
        elapsedSeconds = 0
        taskTitle = ""
        taskId = nil
        sessionStart = nil
    }

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.elapsedSeconds += 1
            }
        }
    }
}
