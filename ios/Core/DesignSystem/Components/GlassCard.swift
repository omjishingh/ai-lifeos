import SwiftUI

struct GlassCard<Content: View>: View {
    let content: Content
    var padding: CGFloat = AppSpacing.md

    init(padding: CGFloat = AppSpacing.md, @ViewBuilder content: () -> Content) {
        self.padding = padding
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .background {
                RoundedRectangle(cornerRadius: AppRadius.lg)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
            }
            .overlay {
                RoundedRectangle(cornerRadius: AppRadius.lg)
                    .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
            }
    }
}

#Preview {
    GlassCard {
        VStack(alignment: .leading, spacing: 8) {
            Text("Personal Coding")
                .font(AppTypography.headline)
            Text("6:00 PM — 8:30 PM")
                .font(AppTypography.subheadline)
                .foregroundStyle(.secondary)
        }
    }
    .padding()
}
