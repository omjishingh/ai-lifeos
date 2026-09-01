import SwiftUI

// MARK: - Spacing

enum AppSpacing {
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}

// MARK: - Corner Radius

enum AppRadius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 24
    static let full: CGFloat = 999
}

// MARK: - Typography

enum AppTypography {
    static let largeTitle = Font.largeTitle.weight(.bold)
    static let title = Font.title.weight(.semibold)
    static let title2 = Font.title2.weight(.semibold)
    static let title3 = Font.title3.weight(.medium)
    static let headline = Font.headline
    static let body = Font.body
    static let callout = Font.callout
    static let subheadline = Font.subheadline
    static let footnote = Font.footnote
    static let caption = Font.caption
    static let caption2 = Font.caption2
}

// MARK: - Colors

struct AppColors {
    let background: Color
    let secondaryBackground: Color
    let tertiaryBackground: Color
    let cardBackground: Color
    let primaryText: Color
    let secondaryText: Color
    let tertiaryText: Color
    let accent: Color
    let accentSecondary: Color
    let success: Color
    let warning: Color
    let error: Color
    let streak: Color
    let coding: Color
    let college: Color
    let sleep: Color
    let separator: Color

    static let light = AppColors(
        background: Color(.systemGroupedBackground),
        secondaryBackground: Color(.secondarySystemGroupedBackground),
        tertiaryBackground: Color(.tertiarySystemGroupedBackground),
        cardBackground: Color(.systemBackground),
        primaryText: Color(.label),
        secondaryText: Color(.secondaryLabel),
        tertiaryText: Color(.tertiaryLabel),
        accent: Color.accentColor,
        accentSecondary: Color.blue.opacity(0.8),
        success: Color.green,
        warning: Color.orange,
        error: Color.red,
        streak: Color.orange,
        coding: Color.purple,
        college: Color.blue,
        sleep: Color.indigo,
        separator: Color(.separator)
    )

    static let dark = AppColors(
        background: Color(.systemGroupedBackground),
        secondaryBackground: Color(.secondarySystemGroupedBackground),
        tertiaryBackground: Color(.tertiarySystemGroupedBackground),
        cardBackground: Color(.systemBackground),
        primaryText: Color(.label),
        secondaryText: Color(.secondaryLabel),
        tertiaryText: Color(.tertiaryLabel),
        accent: Color.accentColor,
        accentSecondary: Color.blue.opacity(0.8),
        success: Color.green,
        warning: Color.orange,
        error: Color.red,
        streak: Color.orange,
        coding: Color.purple,
        college: Color.blue,
        sleep: Color.indigo,
        separator: Color(.separator)
    )
}

// MARK: - Environment Key

private struct AppColorsKey: EnvironmentKey {
    static let defaultValue = AppColors.light
}

extension EnvironmentValues {
    var appColors: AppColors {
        get { self[AppColorsKey.self] }
        set { self[AppColorsKey.self] = newValue }
    }
}

// MARK: - Gradients

enum AppGradients {
    static let accent = LinearGradient(
        colors: [Color.accentColor, Color.blue],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let card = LinearGradient(
        colors: [Color.accentColor.opacity(0.15), Color.purple.opacity(0.1)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - Animation

enum AppAnimation {
    static let standard = Animation.easeInOut(duration: 0.25)
    static let spring = Animation.spring(response: 0.35, dampingFraction: 0.8)

    static func reducedMotionAware(_ animation: Animation, reduceMotion: Bool) -> Animation? {
        reduceMotion ? nil : animation
    }
}

// MARK: - Hit Target

enum AppHitTarget {
    static let minimum: CGFloat = 44
}
