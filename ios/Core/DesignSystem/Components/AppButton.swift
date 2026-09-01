import SwiftUI

struct AppButton: View {
    let title: String
    let icon: String?
    let style: Style
    let isLoading: Bool
    let action: () -> Void

    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    enum Style {
        case primary
        case secondary
        case destructive
        case ghost
    }

    init(
        _ title: String,
        icon: String? = nil,
        style: Style = .primary,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.style = style
        self.isLoading = isLoading
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.xs) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(foregroundColor)
                } else {
                    if let icon {
                        Image(systemName: icon)
                    }
                    Text(title)
                        .font(AppTypography.headline)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: AppHitTarget.minimum)
            .padding(.horizontal, AppSpacing.md)
            .foregroundStyle(foregroundColor)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
            .overlay {
                if style == .secondary || style == .ghost {
                    RoundedRectangle(cornerRadius: AppRadius.md)
                        .stroke(borderColor, lineWidth: 1)
                }
            }
        }
        .disabled(isLoading || !isEnabled)
        .opacity(isEnabled ? 1 : 0.5)
        .animation(AppAnimation.reducedMotionAware(AppAnimation.standard, reduceMotion: reduceMotion), value: isLoading)
        .accessibilityLabel(title)
        .accessibilityAddTraits(.isButton)
    }

    private var foregroundColor: Color {
        switch style {
        case .primary: return .white
        case .secondary, .ghost: return .accentColor
        case .destructive: return .white
        }
    }

    private var background: some ShapeStyle {
        switch style {
        case .primary: return AnyShapeStyle(AppGradients.accent)
        case .secondary: return AnyShapeStyle(Color(.secondarySystemGroupedBackground))
        case .destructive: return AnyShapeStyle(Color.red)
        case .ghost: return AnyShapeStyle(Color.clear)
        }
    }

    private var borderColor: Color {
        switch style {
        case .secondary: return Color(.separator)
        case .ghost: return Color.accentColor.opacity(0.5)
        default: return .clear
        }
    }
}

struct PrimaryButton: View {
    let title: String
    let icon: String?
    let isLoading: Bool
    let action: () -> Void

    init(_ title: String, icon: String? = nil, isLoading: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.isLoading = isLoading
        self.action = action
    }

    var body: some View {
        AppButton(title, icon: icon, style: .primary, isLoading: isLoading, action: action)
    }
}

struct SecondaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void

    init(_ title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }

    var body: some View {
        AppButton(title, icon: icon, style: .secondary, action: action)
    }
}

#Preview("Buttons") {
    VStack(spacing: 16) {
        PrimaryButton("Focus", icon: "bolt.fill") {}
        SecondaryButton("Reschedule", icon: "calendar") {}
        AppButton("Delete", style: .destructive) {}
        AppButton("Cancel", style: .ghost) {}
    }
    .padding()
}
