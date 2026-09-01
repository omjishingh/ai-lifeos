import SwiftUI

struct StreakBadge: View {
    let days: Int
    let label: String?

    @Environment(\.appColors) private var colors

    init(days: Int, label: String? = nil) {
        self.days = days
        self.label = label
    }

    var body: some View {
        HStack(spacing: AppSpacing.xxs) {
            Image(systemName: "flame.fill")
                .foregroundStyle(colors.streak)
                .accessibilityHidden(true)

            Text("\(days)")
                .font(AppTypography.headline)
                .monospacedDigit()

            if let label {
                Text(label)
                    .font(AppTypography.caption)
                    .foregroundStyle(colors.secondaryText)
            } else {
                Text(days == 1 ? "day" : "days")
                    .font(AppTypography.caption)
                    .foregroundStyle(colors.secondaryText)
            }
        }
        .padding(.horizontal, AppSpacing.sm)
        .padding(.vertical, AppSpacing.xs)
        .background(colors.streak.opacity(0.12))
        .clipShape(Capsule())
        .accessibilityLabel("\(days) day streak")
    }
}

#Preview {
    VStack(spacing: 16) {
        StreakBadge(days: 7)
        StreakBadge(days: 1, label: "coding streak")
        StreakBadge(days: 30, label: "task streak")
    }
    .padding()
}
