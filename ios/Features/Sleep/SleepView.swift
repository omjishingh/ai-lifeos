import SwiftUI

struct SleepView: View {
    @Environment(\.appEnvironment) private var appEnvironment
    @Environment(\.appColors) private var colors
    @State private var sleepSchedule: SleepSchedule?
    @State private var selectedTimer = 30

    private let timerOptions = [15, 30, 45, 60]

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.lg) {
                sleepGoalCard
                musicPlayerCard
                historyNote
            }
            .padding(AppSpacing.md)
        }
        .background(colors.background)
        .navigationTitle("Sleep")
        .task { loadSchedule() }
    }

    private var sleepGoalCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                Text("Sleep Goal")
                    .font(AppTypography.headline)

                if let schedule = sleepSchedule {
                    HStack {
                        Label(schedule.bedtime.timeString(), systemImage: "moon.fill")
                        Image(systemName: "arrow.right")
                            .foregroundStyle(colors.secondaryText)
                        Label(schedule.wakeTime.timeString(), systemImage: "sun.max.fill")
                    }
                    .font(AppTypography.title3)

                    let minutes = sleepDurationMinutes(bed: schedule.bedtime, wake: schedule.wakeTime)
                    Text("\(minutes / 60)h \(minutes % 60)m target")
                        .font(AppTypography.subheadline)
                        .foregroundStyle(colors.secondaryText)
                } else {
                    Text("Complete onboarding to set your sleep schedule.")
                        .font(AppTypography.subheadline)
                        .foregroundStyle(colors.secondaryText)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var musicPlayerCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("🌙 Sleep Mode")
                .font(AppTypography.headline)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: AppSpacing.sm) {
                ForEach(SleepMusicPlayer.soundOptions, id: \.id) { sound in
                    Button {
                        appEnvironment?.sleepMusicPlayer.selectedSound = sound.id
                        if appEnvironment?.sleepMusicPlayer.isPlaying == true {
                            appEnvironment?.sleepMusicPlayer.play(sound: sound.id)
                        }
                    } label: {
                        VStack(spacing: AppSpacing.xs) {
                            Image(systemName: sound.icon)
                            Text(sound.name)
                                .font(AppTypography.caption)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppSpacing.md)
                        .background(
                            appEnvironment?.sleepMusicPlayer.selectedSound == sound.id
                                ? colors.accent.opacity(0.15) : colors.secondaryBackground
                        )
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
                    }
                    .buttonStyle(.plain)
                }
            }

            HStack {
                ForEach(timerOptions, id: \.self) { mins in
                    Chip(label: "\(mins)m", isSelected: selectedTimer == mins) {
                        selectedTimer = mins
                        appEnvironment?.sleepMusicPlayer.setTimer(minutes: mins)
                    }
                }
            }

            if appEnvironment?.sleepMusicPlayer.isPlaying == true {
                PrimaryButton("Stop", icon: "stop.fill") {
                    appEnvironment?.sleepMusicPlayer.stop()
                }
            } else {
                PrimaryButton("Play", icon: "play.fill") {
                    appEnvironment?.sleepMusicPlayer.setTimer(minutes: selectedTimer)
                    appEnvironment?.sleepMusicPlayer.play()
                }
            }
        }
    }

    private var historyNote: some View {
        Text("Add licensed audio files (rain.mp3, forest.mp3, etc.) to the app bundle for playback. Timer auto-stops music.")
            .font(AppTypography.caption)
            .foregroundStyle(colors.tertiaryText)
            .multilineTextAlignment(.center)
    }

    private func loadSchedule() {
        sleepSchedule = try? appEnvironment?.sleepRepository.fetchSchedule()
    }

    private func sleepDurationMinutes(bed: Date, wake: Date) -> Int {
        let bedM = DateComposer.minutesSinceMidnight(from: bed)
        let wakeM = DateComposer.minutesSinceMidnight(from: wake)
        return bedM > wakeM ? bedM - wakeM : (24 * 60 - wakeM + bedM)
    }
}

#Preview {
    NavigationStack {
        SleepView()
            .environment(\.appEnvironment, try! AppEnvironment(modelContainer: makeModelContainer(inMemory: true)))
    }
}
