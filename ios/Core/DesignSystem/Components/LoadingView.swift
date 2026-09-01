import SwiftUI

struct LoadingView: View {
    var message: String = "Loading..."

    @Environment(\.appColors) private var colors

    var body: some View {
        VStack(spacing: AppSpacing.md) {
            ProgressView()
                .progressViewStyle(.circular)
                .scaleEffect(1.2)

            Text(message)
                .font(AppTypography.subheadline)
                .foregroundStyle(colors.secondaryText)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(message)
    }
}

#Preview {
    LoadingView(message: "Loading your schedule...")
}
