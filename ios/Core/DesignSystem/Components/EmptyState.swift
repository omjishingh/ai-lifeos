import SwiftUI

struct EmptyState: View {
    let icon: String
    let title: String
    let message: String
    var actionTitle: String?
    var action: (() -> Void)?

    @Environment(\.appColors) private var colors

    var body: some View {
        VStack(spacing: AppSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundStyle(colors.secondaryText)
                .accessibilityHidden(true)

            Text(title)
                .font(AppTypography.title3)
                .foregroundStyle(colors.primaryText)
                .multilineTextAlignment(.center)

            Text(message)
                .font(AppTypography.body)
                .foregroundStyle(colors.secondaryText)
                .multilineTextAlignment(.center)

            if let actionTitle, let action {
                PrimaryButton(actionTitle, action: action)
                    .frame(maxWidth: 240)
                    .padding(.top, AppSpacing.sm)
            }
        }
        .padding(AppSpacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    EmptyState(
        icon: "checkmark.circle",
        title: "No tasks today",
        message: "You are free 🎉",
        actionTitle: "Add a task",
        action: {}
    )
}
