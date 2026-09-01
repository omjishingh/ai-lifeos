import SwiftUI

struct AIHubView: View {
    @Environment(\.appColors) private var colors

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: AppSpacing.lg) {
                    NavigationLink { AIChatView() } label: { aiCoachCard }
                    NavigationLink { NewsListView() } label: { aiNewsCard }
                    NavigationLink { FocusView() } label: { focusCard }
                    NavigationLink { SleepView() } label: { sleepCard }
                }
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, AppSpacing.sm)
            }
            .background(colors.background)
            .navigationTitle("AI")
        }
    }

    private var aiCoachCard: some View {
        hubCard(icon: "sparkles", title: "AI Coach", subtitle: "Plan my day, break down tasks, repair schedule", color: colors.accent)
    }

    private var aiNewsCard: some View {
        hubCard(icon: "newspaper.fill", title: "AI Daily", subtitle: "10 important AI updates every day", color: colors.coding)
    }

    private var focusCard: some View {
        hubCard(icon: "bolt.fill", title: "Focus Mode", subtitle: "Start a coding timer session", color: colors.streak)
    }

    private var sleepCard: some View {
        hubCard(icon: "moon.fill", title: "Sleep", subtitle: "Wind down & sleep music", color: colors.sleep)
    }

    private func hubCard(icon: String, title: String, subtitle: String, color: Color) -> some View {
        GlassCard {
            HStack(spacing: AppSpacing.md) {
                Image(systemName: icon).font(.title2).foregroundStyle(color).frame(width: 40)
                VStack(alignment: .leading, spacing: 4) {
                    Text(title).font(AppTypography.headline).foregroundStyle(colors.primaryText)
                    Text(subtitle).font(AppTypography.caption).foregroundStyle(colors.secondaryText)
                }
                Spacer()
                Image(systemName: "chevron.right").foregroundStyle(colors.tertiaryText)
            }
        }
    }
}

#Preview { AIHubView() }
