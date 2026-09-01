import SwiftUI

struct ErrorView: View {
    let title: String
    let message: String
    var retryTitle: String = "Try Again"
    var onRetry: (() -> Void)?

    @Environment(\.appColors) private var colors

    var body: some View {
        VStack(spacing: AppSpacing.md) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundStyle(colors.warning)
                .accessibilityHidden(true)

            Text(title)
                .font(AppTypography.title3)
                .foregroundStyle(colors.primaryText)
                .multilineTextAlignment(.center)

            Text(message)
                .font(AppTypography.body)
                .foregroundStyle(colors.secondaryText)
                .multilineTextAlignment(.center)

            if let onRetry {
                PrimaryButton(retryTitle, icon: "arrow.clockwise", action: onRetry)
                    .frame(maxWidth: 240)
                    .padding(.top, AppSpacing.sm)
            }
        }
        .padding(AppSpacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ErrorView(
        title: "AI is temporarily unavailable",
        message: "Your schedule is safe.",
        onRetry: {}
    )
}
