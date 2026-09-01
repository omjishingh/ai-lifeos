import SwiftUI

struct FocusView: View {
    @Environment(\.appEnvironment) private var appEnvironment
    @Environment(\.dismiss) private var dismiss
    @Environment(\.appColors) private var colors

    var taskTitle: String = "Personal Coding"
    var taskId: UUID?
    var plannedMinutes: Int = 25

    var body: some View {
        VStack(spacing: AppSpacing.xl) {
            Spacer()

            Text("PERSONAL CODING")
                .font(AppTypography.caption)
                .foregroundStyle(colors.accent)
                .fontWeight(.semibold)

            if let appEnvironment {
                Text(appEnvironment.focusTimer.formattedTime)
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(colors.primaryText)
                    .accessibilityLabel("Timer \(appEnvironment.focusTimer.formattedTime)")

                Text(appEnvironment.focusTimer.taskTitle.isEmpty ? taskTitle : appEnvironment.focusTimer.taskTitle)
                    .font(AppTypography.title3)
                    .foregroundStyle(colors.secondaryText)
                    .multilineTextAlignment(.center)

                ProgressRing(progress: appEnvironment.focusTimer.progress, size: 100, showPercentage: false)

                if let target = appEnvironment.userProfile?.codingTargetMinutes {
                    Text("Today's coding: \(appEnvironment.focusTimer.elapsedSeconds / 60)m / \(target / 60)h target")
                        .font(AppTypography.subheadline)
                        .foregroundStyle(colors.secondaryText)
                }
            }

            Spacer()

            HStack(spacing: AppSpacing.md) {
                if appEnvironment?.focusTimer.isRunning == true {
                    if appEnvironment?.focusTimer.isPaused == true {
                        PrimaryButton("Resume", icon: "play.fill") {
                            appEnvironment?.focusTimer.resume()
                        }
                    } else {
                        SecondaryButton("Pause", icon: "pause.fill") {
                            appEnvironment?.focusTimer.pause()
                        }
                    }
                    PrimaryButton("Finish", icon: "checkmark") {
                        try? appEnvironment?.focusTimer.finish()
                        dismiss()
                    }
                } else {
                    PrimaryButton("Start Focus", icon: "bolt.fill") {
                        appEnvironment?.focusTimer.start(
                            taskTitle: taskTitle,
                            taskId: taskId,
                            plannedMinutes: plannedMinutes
                        )
                    }
                }
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.bottom, AppSpacing.xl)
        }
        .background(colors.background)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Close") { dismiss() }
            }
        }
    }
}

#Preview {
    NavigationStack {
        FocusView()
            .environment(\.appEnvironment, try! AppEnvironment(modelContainer: makeModelContainer(inMemory: true)))
    }
}
