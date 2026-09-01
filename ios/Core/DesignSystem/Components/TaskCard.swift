import SwiftUI

struct TaskCard: View {
    let title: String
    let category: String
    let timeRange: String?
    let status: TaskStatus
    let progress: Double?
    var onStart: (() -> Void)?
    var onComplete: (() -> Void)?

    @Environment(\.appColors) private var colors

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack {
                categoryChip
                Spacer()
                statusBadge
            }

            Text(title)
                .font(AppTypography.headline)
                .foregroundStyle(colors.primaryText)

            if let timeRange {
                Label(timeRange, systemImage: "clock")
                    .font(AppTypography.subheadline)
                    .foregroundStyle(colors.secondaryText)
            }

            if let progress {
                ProgressView(value: progress)
                    .tint(colors.accent)
                    .accessibilityLabel("Progress \(Int(progress * 100)) percent")
            }

            if onStart != nil || onComplete != nil {
                HStack(spacing: AppSpacing.sm) {
                    if let onStart {
                        SecondaryButton("Focus", icon: "bolt.fill", action: onStart)
                    }
                    if let onComplete {
                        PrimaryButton("Complete", icon: "checkmark", action: onComplete)
                    }
                }
            }
        }
        .padding(AppSpacing.md)
        .background(colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
        .accessibilityElement(children: .combine)
    }

    private var categoryChip: some View {
        Chip(label: category, color: categoryColor)
    }

    private var statusBadge: some View {
        Text(status.displayName)
            .font(AppTypography.caption)
            .padding(.horizontal, AppSpacing.xs)
            .padding(.vertical, AppSpacing.xxs)
            .background(statusColor.opacity(0.15))
            .foregroundStyle(statusColor)
            .clipShape(Capsule())
    }

    private var categoryColor: Color {
        switch category.lowercased() {
        case "coding", "personal coding": return colors.coding
        case "college": return colors.college
        case "sleep": return colors.sleep
        default: return colors.accent
        }
    }

    private var statusColor: Color {
        switch status {
        case .completed: return colors.success
        case .inProgress: return colors.accent
        case .missed: return colors.error
        case .skipped, .cancelled: return colors.secondaryText
        default: return colors.warning
        }
    }
}

#Preview {
    TaskCard(
        title: "Build notification system",
        category: "Personal Coding",
        timeRange: "6:00 PM — 8:30 PM",
        status: .inProgress,
        progress: 0.65,
        onStart: {},
        onComplete: {}
    )
    .padding()
}
