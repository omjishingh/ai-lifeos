import SwiftUI

struct CollegeView: View {
    @Environment(\.appEnvironment) private var appEnvironment
    @Environment(\.appColors) private var colors

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.lg) {
                todayCard
                featuresCard
            }
            .padding(AppSpacing.md)
        }
        .background(colors.background)
        .navigationTitle("College")
    }

    private var todayCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                Text("TODAY")
                    .font(AppTypography.caption)
                    .foregroundStyle(colors.accent)
                    .fontWeight(.semibold)

                if let profile = appEnvironment?.userProfile {
                    collegeRow(icon: "graduationcap.fill", label: "College", time: profile.collegeStartTime.timeString())
                    collegeRow(icon: "clock.fill", label: "Finish", time: profile.collegeEndTime.timeString())
                    let homeTime = profile.collegeEndTime.adding(minutes: profile.travelMinutes)
                    collegeRow(icon: "house.fill", label: "Home", time: homeTime.timeString())

                    if profile.sundayIsHoliday {
                        HStack {
                            Image(systemName: "sun.max.fill")
                                .foregroundStyle(colors.streak)
                            Text("Sunday is a holiday")
                                .font(AppTypography.caption)
                                .foregroundStyle(colors.secondaryText)
                        }
                        .padding(.top, AppSpacing.xs)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var featuresCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Coming in updates")
                .font(AppTypography.headline)
            ForEach(["Classes", "Assignments", "Exams", "Notes", "Attendance"], id: \.self) { item in
                HStack {
                    Image(systemName: "circle")
                        .font(.caption2)
                        .foregroundStyle(colors.tertiaryText)
                    Text(item)
                        .font(AppTypography.subheadline)
                        .foregroundStyle(colors.secondaryText)
                }
            }
        }
        .padding(AppSpacing.md)
        .background(colors.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
    }

    private func collegeRow(icon: String, label: String, time: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(colors.college)
                .frame(width: 28)
            Text(label)
                .font(AppTypography.body)
            Spacer()
            Text(time)
                .font(AppTypography.headline)
                .monospacedDigit()
        }
    }
}

#Preview {
    NavigationStack {
        CollegeView()
            .environment(\.appEnvironment, try! AppEnvironment(modelContainer: makeModelContainer(inMemory: true)))
    }
}
