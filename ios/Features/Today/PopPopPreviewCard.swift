import SwiftUI

struct PopPopPreviewCard: View {
    let upcomingPops: [UpcomingPop]
    let pendingCount: Int
    @Environment(\.appColors) private var colors

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack {
                Label("POP-POP Alerts", systemImage: "bell.badge.fill")
                    .font(AppTypography.headline)
                    .foregroundStyle(colors.accent)
                Spacer()
                Text("\(pendingCount) scheduled")
                    .font(AppTypography.caption)
                    .foregroundStyle(colors.secondaryText)
                    .monospacedDigit()
            }

            Text("Lock screen par ye notifications aayengi")
                .font(AppTypography.caption)
                .foregroundStyle(colors.tertiaryText)

            if upcomingPops.isEmpty {
                HStack(spacing: AppSpacing.sm) {
                    Image(systemName: "bell.slash")
                        .foregroundStyle(colors.secondaryText)
                    Text("No upcoming alerts — enable notifications in Settings")
                        .font(AppTypography.caption)
                        .foregroundStyle(colors.secondaryText)
                }
                .padding(.vertical, AppSpacing.sm)
            } else {
                ForEach(upcomingPops.prefix(4)) { pop in
                    HStack(alignment: .top, spacing: AppSpacing.sm) {
                        Image(systemName: pop.icon)
                            .foregroundStyle(colors.accent)
                            .frame(width: 24)
                            .padding(.top, 2)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(pop.title)
                                .font(AppTypography.subheadline)
                                .fontWeight(.medium)
                                .lineLimit(1)
                            Text(pop.body)
                                .font(AppTypography.caption)
                                .foregroundStyle(colors.secondaryText)
                                .lineLimit(2)
                        }

                        Spacer()

                        Text(pop.date.timeString())
                            .font(AppTypography.caption2)
                            .foregroundStyle(colors.tertiaryText)
                            .monospacedDigit()
                    }
                    .padding(.vertical, AppSpacing.xxs)

                    if pop.id != upcomingPops.prefix(4).last?.id {
                        Divider()
                    }
                }
            }
        }
        .padding(AppSpacing.md)
        .background {
            RoundedRectangle(cornerRadius: AppRadius.lg)
                .fill(colors.cardBackground)
                .shadow(color: colors.accent.opacity(0.15), radius: 12, y: 4)
                .overlay {
                    RoundedRectangle(cornerRadius: AppRadius.lg)
                        .stroke(
                            LinearGradient(
                                colors: [colors.accent.opacity(0.4), colors.coding.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Upcoming notifications, \(pendingCount) scheduled")
    }
}

struct HeroNowCard: View {
    let title: String
    let subtitle: String
    let timeRange: String
    let remaining: String?
    let progress: Double
    let icon: String
    let color: Color
    var onFocus: (() -> Void)?
    var onComplete: (() -> Void)?

    @Environment(\.appColors) private var colors

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                Text("NOW")
                    .font(AppTypography.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.white.opacity(0.9))
                Spacer()
                if let remaining {
                    Label(remaining, systemImage: "timer")
                        .font(AppTypography.caption)
                        .foregroundStyle(.white.opacity(0.85))
                        .monospacedDigit()
                }
            }

            HStack(spacing: AppSpacing.md) {
                Image(systemName: icon)
                    .font(.system(size: 36))
                    .foregroundStyle(.white)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(AppTypography.title3)
                        .foregroundStyle(.white)
                    Text(subtitle)
                        .font(AppTypography.caption)
                        .foregroundStyle(.white.opacity(0.8))
                    Text(timeRange)
                        .font(AppTypography.subheadline)
                        .foregroundStyle(.white.opacity(0.9))
                        .monospacedDigit()
                }
            }

            ProgressView(value: progress)
                .tint(.white)
                .background(Color.white.opacity(0.2))
                .clipShape(Capsule())

            if onFocus != nil || onComplete != nil {
                HStack(spacing: AppSpacing.sm) {
                    if let onFocus {
                        Button(action: onFocus) {
                            Label("Focus", systemImage: "bolt.fill")
                                .font(AppTypography.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, AppSpacing.sm)
                                .background(.white.opacity(0.2))
                                .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
                        }
                        .buttonStyle(.plain)
                    }
                    if let onComplete {
                        Button(action: onComplete) {
                            Label("Done", systemImage: "checkmark")
                                .font(AppTypography.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, AppSpacing.sm)
                                .background(.white)
                                .foregroundStyle(color)
                                .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(AppSpacing.lg)
        .background {
            RoundedRectangle(cornerRadius: AppRadius.xl)
                .fill(
                    LinearGradient(
                        colors: [color, color.opacity(0.7), colors.accent.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: color.opacity(0.4), radius: 16, y: 8)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        HeroNowCard(
            title: "Personal Coding",
            subtitle: "Build notification system",
            timeRange: "6:00 PM — 8:30 PM",
            remaining: "01:42:19",
            progress: 0.65,
            icon: "laptopcomputer",
            color: .purple
        )
        PopPopPreviewCard(upcomingPops: [], pendingCount: 12)
    }
    .padding()
}
