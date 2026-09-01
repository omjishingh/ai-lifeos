import SwiftUI

// MARK: - Welcome

struct WelcomeStepView: View {
    @Environment(\.appColors) private var colors

    var body: some View {
        VStack(spacing: AppSpacing.xl) {
            Spacer(minLength: AppSpacing.xxl)

            VStack(spacing: AppSpacing.md) {
                Text("Your day.")
                    .font(AppTypography.largeTitle)
                Text("Under control.")
                    .font(AppTypography.largeTitle)
                    .foregroundStyle(colors.accent)
            }
            .multilineTextAlignment(.center)

            Text("AI LifeOS helps you manage college, coding, tasks, and your daily routine — all in one place.")
                .font(AppTypography.body)
                .foregroundStyle(colors.secondaryText)
                .multilineTextAlignment(.center)

            featureHighlights
                .padding(.top, AppSpacing.md)

            Spacer(minLength: AppSpacing.xxl)
        }
    }

    private var featureHighlights: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            FeatureRow(icon: "calendar", text: "Smart daily schedule")
            FeatureRow(icon: "laptopcomputer", text: "Personal coding tracker")
            FeatureRow(icon: "sparkles", text: "AI coach & daily news")
            FeatureRow(icon: "moon.fill", text: "Sleep & wind-down routines")
        }
        .padding(AppSpacing.md)
        .background(colors.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    @Environment(\.appColors) private var colors

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: icon)
                .foregroundStyle(colors.accent)
                .frame(width: 24)
            Text(text)
                .font(AppTypography.subheadline)
                .foregroundStyle(colors.primaryText)
        }
    }
}

// MARK: - Name

struct NameStepView: View {
    @Binding var name: String
    @Environment(\.appColors) private var colors
    @FocusState private var isFocused: Bool

    var body: some View {
        OnboardingStepHeader(
            title: "What's your name?",
            subtitle: "We'll use this to personalize your dashboard."
        )

        TextField("Your name", text: $name)
            .font(AppTypography.title3)
            .padding(AppSpacing.md)
            .background(colors.secondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
            .focused($isFocused)
            .textInputAutocapitalization(.words)
            .autocorrectionDisabled()
            .accessibilityLabel("Your name")
            .onAppear { isFocused = true }
    }
}

// MARK: - Wake / Sleep

struct WakeTimeStepView: View {
    @Binding var wakeUpTime: Date
    @Environment(\.appColors) private var colors

    var body: some View {
        OnboardingStepHeader(
            title: "When do you wake up?",
            subtitle: "Default: 6:30 AM. You can change this anytime."
        )

        TimePickerRow(title: "Wake Up", icon: "sun.max.fill", time: $wakeUpTime)

        Text("Your morning routine will be built around this time.")
            .font(AppTypography.caption)
            .foregroundStyle(colors.secondaryText)
    }
}

struct SleepTimeStepView: View {
    @Binding var sleepTime: Date
    @Environment(\.appColors) private var colors

    var body: some View {
        OnboardingStepHeader(
            title: "When do you go to sleep?",
            subtitle: "Default: 11:45 PM. Wind-down starts 15 minutes before."
        )

        TimePickerRow(title: "Sleep", icon: "moon.zzz.fill", time: $sleepTime)

        let wakeMinutes = 6 * 60 + 30
        let sleepMinutes = DateComposer.minutesSinceMidnight(from: sleepTime)
        let targetHours = max(1, (sleepMinutes > wakeMinutes ? sleepMinutes - wakeMinutes : (24 * 60 - wakeMinutes + sleepMinutes)) / 60)

        Text("Target sleep: ~\(targetHours) hours (based on default wake time)")
            .font(AppTypography.caption)
            .foregroundStyle(colors.secondaryText)
    }
}

// MARK: - College

struct CollegeScheduleStepView: View {
    @Binding var startTime: Date
    @Binding var endTime: Date
    @Binding var sundayIsHoliday: Bool
    @Environment(\.appColors) private var colors

    var body: some View {
        OnboardingStepHeader(
            title: "College schedule",
            subtitle: "Monday–Saturday by default. Sunday is a holiday."
        )

        VStack(spacing: AppSpacing.sm) {
            TimePickerRow(title: "College starts", icon: "graduationcap.fill", time: $startTime)
            TimePickerRow(title: "College ends", icon: "clock.fill", time: $endTime)
        }

        Toggle(isOn: $sundayIsHoliday) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Sunday is a holiday")
                    .font(AppTypography.body)
                Text("No college blocks on Sundays")
                    .font(AppTypography.caption)
                    .foregroundStyle(colors.secondaryText)
            }
        }
        .tint(colors.accent)
        .padding(AppSpacing.md)
        .background(colors.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
        .accessibilityLabel("Sunday is a holiday")
    }
}

// MARK: - Travel & Coding

struct TravelTimeStepView: View {
    @Binding var travelMinutes: Int

    var body: some View {
        OnboardingStepHeader(
            title: "Travel time",
            subtitle: "How long does it take to get home from college?"
        )

        DurationPickerRow(
            title: "Travel home",
            icon: "car.fill",
            minutes: $travelMinutes,
            step: 15,
            range: 15...180
        )
    }
}

struct CodingTargetStepView: View {
    @Binding var codingTargetMinutes: Int
    @Environment(\.appColors) private var colors

    var body: some View {
        OnboardingStepHeader(
            title: "Personal coding target",
            subtitle: "How much time do you want to code each day?"
        )

        DurationPickerRow(
            title: "Daily coding goal",
            icon: "laptopcomputer",
            minutes: $codingTargetMinutes,
            step: 30,
            range: 30...480
        )

        Text("Default: 3 hours/day. Split across evening coding sessions.")
            .font(AppTypography.caption)
            .foregroundStyle(colors.secondaryText)
    }
}

// MARK: - Notifications

struct NotificationsStepView: View {
    @Binding var notificationsEnabled: Bool
    @Environment(\.appColors) private var colors

    var body: some View {
        OnboardingStepHeader(
            title: "Notifications",
            subtitle: "Used to remind you about tasks, routines, and your daily briefing."
        )

        Toggle(isOn: $notificationsEnabled) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Enable notifications")
                    .font(AppTypography.body)
                Text("Task reminders, wake-up, sleep, and AI news")
                    .font(AppTypography.caption)
                    .foregroundStyle(colors.secondaryText)
            }
        }
        .tint(colors.accent)
        .padding(AppSpacing.md)
        .background(colors.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))

        if notificationsEnabled {
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                notificationPreview(title: "Coding starts in 15 minutes", icon: "bell.fill")
                notificationPreview(title: "Your 10 AI updates are ready", icon: "sparkles")
            }
            .padding(.top, AppSpacing.sm)
        }
    }

    private func notificationPreview(title: String, icon: String) -> some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: icon)
                .foregroundStyle(colors.accent)
            Text(title)
                .font(AppTypography.caption)
                .foregroundStyle(colors.secondaryText)
        }
        .padding(AppSpacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(colors.tertiaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.sm))
    }
}

// MARK: - AI Preferences

struct AIPreferencesStepView: View {
    @Binding var aiEnabled: Bool
    @Binding var newsNotificationTime: String
    @Environment(\.appColors) private var colors

    private let newsTimes = [
        ("morning", "Morning", "8:00 AM"),
        ("afternoon", "Afternoon", "2:00 PM"),
        ("evening", "Evening", "6:00 PM"),
        ("off", "Off", "No notification")
    ]

    var body: some View {
        OnboardingStepHeader(
            title: "AI preferences",
            subtitle: "AI requests go through a secure backend — no API keys in the app."
        )

        Toggle(isOn: $aiEnabled) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Enable AI Coach")
                    .font(AppTypography.body)
                Text("Plan your day, break down tasks, repair schedule")
                    .font(AppTypography.caption)
                    .foregroundStyle(colors.secondaryText)
            }
        }
        .tint(colors.accent)
        .padding(AppSpacing.md)
        .background(colors.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))

        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Daily AI news briefing")
                .font(AppTypography.headline)

            ForEach(newsTimes, id: \.0) { value, label, time in
                Button {
                    newsNotificationTime = value
                } label: {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(label)
                                .font(AppTypography.body)
                            Text(time)
                                .font(AppTypography.caption)
                                .foregroundStyle(colors.secondaryText)
                        }
                        Spacer()
                        if newsNotificationTime == value {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(colors.accent)
                        }
                    }
                    .padding(AppSpacing.md)
                    .background(newsNotificationTime == value ? colors.accent.opacity(0.1) : colors.secondaryBackground)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("\(label) news briefing at \(time)")
                .accessibilityAddTraits(newsNotificationTime == value ? .isSelected : [])
            }
        }
    }
}

// MARK: - Sleep Music

struct SleepMusicStepView: View {
    @Binding var sleepMusicPreference: String
    @Environment(\.appColors) private var colors

    private let options: [(String, String, String)] = [
        ("rain", "Rain", "cloud.rain.fill"),
        ("forest", "Forest", "tree.fill"),
        ("ocean", "Ocean", "water.waves"),
        ("white_noise", "White Noise", "waveform"),
        ("ambient", "Ambient", "music.note")
    ]

    var body: some View {
        OnboardingStepHeader(
            title: "Sleep music",
            subtitle: "Choose your default sound for wind-down and sleep."
        )

        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: AppSpacing.sm) {
            ForEach(options, id: \.0) { value, label, icon in
                Button {
                    sleepMusicPreference = value
                } label: {
                    VStack(spacing: AppSpacing.sm) {
                        Image(systemName: icon)
                            .font(.title2)
                        Text(label)
                            .font(AppTypography.caption)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: AppHitTarget.minimum + 20)
                    .foregroundStyle(sleepMusicPreference == value ? .white : colors.primaryText)
                    .background(sleepMusicPreference == value ? colors.accent : colors.secondaryBackground)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
                }
                .buttonStyle(.plain)
                .accessibilityLabel(label)
                .accessibilityAddTraits(sleepMusicPreference == value ? .isSelected : [])
            }
        }
    }
}

// MARK: - Finish

struct FinishStepView: View {
    let summary: [(String, String)]
    @Environment(\.appColors) private var colors
    var errorMessage: String?

    var body: some View {
        OnboardingStepHeader(
            title: "You're all set!",
            subtitle: "Review your settings, then we'll build your schedule."
        )

        VStack(spacing: 0) {
            ForEach(Array(summary.enumerated()), id: \.offset) { index, item in
                HStack {
                    Text(item.0)
                        .font(AppTypography.subheadline)
                        .foregroundStyle(colors.secondaryText)
                    Spacer()
                    Text(item.1)
                        .font(AppTypography.subheadline)
                        .foregroundStyle(colors.primaryText)
                }
                .padding(.vertical, AppSpacing.sm)

                if index < summary.count - 1 {
                    Divider()
                }
            }
        }
        .padding(AppSpacing.md)
        .background(colors.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))

        GlassCard {
            HStack(spacing: AppSpacing.md) {
                Image(systemName: "calendar.badge.clock")
                    .font(.title2)
                    .foregroundStyle(colors.accent)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Your routine includes")
                        .font(AppTypography.headline)
                    Text("Wake up, college, coding sessions, dinner, wind-down, and sleep — all editable after setup.")
                        .font(AppTypography.caption)
                        .foregroundStyle(colors.secondaryText)
                }
            }
        }
    }
}

// MARK: - Shared Header

struct OnboardingStepHeader: View {
    let title: String
    let subtitle: String
    @Environment(\.appColors) private var colors

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text(title)
                .font(AppTypography.title2)
                .foregroundStyle(colors.primaryText)
            Text(subtitle)
                .font(AppTypography.subheadline)
                .foregroundStyle(colors.secondaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, AppSpacing.md)
    }
}
