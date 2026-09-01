import SwiftUI

struct TimelineCard: View {
    let title: String
    let subtitle: String?
    let startTime: String
    let endTime: String?
    let icon: String
    let color: Color
    let isActive: Bool
    let isCompleted: Bool

    @Environment(\.appColors) private var colors

    init(
        title: String,
        subtitle: String? = nil,
        startTime: String,
        endTime: String? = nil,
        icon: String = "circle.fill",
        color: Color = .accentColor,
        isActive: Bool = false,
        isCompleted: Bool = false
    ) {
        self.title = title
        self.subtitle = subtitle
        self.startTime = startTime
        self.endTime = endTime
        self.icon = icon
        self.color = color
        self.isActive = isActive
        self.isCompleted = isCompleted
    }

    var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.sm) {
            timelineIndicator

            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                HStack {
                    Text(startTime)
                        .font(AppTypography.caption)
                        .foregroundStyle(colors.secondaryText)
                        .monospacedDigit()
                    if let endTime {
                        Text("—")
                            .font(AppTypography.caption)
                            .foregroundStyle(colors.tertiaryText)
                        Text(endTime)
                            .font(AppTypography.caption)
                            .foregroundStyle(colors.secondaryText)
                            .monospacedDigit()
                    }
                }

                Text(title)
                    .font(isActive ? AppTypography.headline : AppTypography.body)
                    .foregroundStyle(isCompleted ? colors.secondaryText : colors.primaryText)
                    .strikethrough(isCompleted)

                if let subtitle {
                    Text(subtitle)
                        .font(AppTypography.caption)
                        .foregroundStyle(colors.secondaryText)
                }
            }
            .padding(.vertical, AppSpacing.xs)

            Spacer()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityDescription)
    }

    private var timelineIndicator: some View {
        VStack(spacing: 0) {
            Image(systemName: isCompleted ? "checkmark.circle.fill" : icon)
                .font(.system(size: 12))
                .foregroundStyle(isCompleted ? colors.success : (isActive ? color : colors.tertiaryText))
                .frame(width: 24, height: 24)
                .background(
                    Circle()
                        .fill(isActive ? color.opacity(0.15) : colors.tertiaryBackground)
                        .frame(width: 28, height: 28)
                )

            Rectangle()
                .fill(colors.separator)
                .frame(width: 2)
                .frame(maxHeight: .infinity)
        }
        .frame(width: 28)
    }

    private var accessibilityDescription: String {
        var parts = [title, "at \(startTime)"]
        if let endTime { parts.append("until \(endTime)") }
        if isActive { parts.append("currently active") }
        if isCompleted { parts.append("completed") }
        return parts.joined(separator: ", ")
    }
}

#Preview {
    VStack(spacing: 0) {
        TimelineCard(
            title: "College",
            startTime: "9:00 AM",
            endTime: "4:30 PM",
            icon: "graduationcap.fill",
            color: .blue,
            isCompleted: true
        )
        TimelineCard(
            title: "Personal Coding",
            subtitle: "Build notification system",
            startTime: "6:00 PM",
            endTime: "8:30 PM",
            icon: "laptopcomputer",
            color: .purple,
            isActive: true
        )
        TimelineCard(
            title: "Sleep",
            startTime: "11:45 PM",
            icon: "moon.fill",
            color: .indigo
        )
    }
    .padding()
}
