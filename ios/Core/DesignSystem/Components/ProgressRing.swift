import SwiftUI

struct ProgressRing: View {
    let progress: Double
    let lineWidth: CGFloat
    let size: CGFloat
    var label: String?
    var showPercentage: Bool

    @Environment(\.appColors) private var colors

    init(
        progress: Double,
        lineWidth: CGFloat = 8,
        size: CGFloat = 80,
        label: String? = nil,
        showPercentage: Bool = true
    ) {
        self.progress = min(max(progress, 0), 1)
        self.lineWidth = lineWidth
        self.size = size
        self.label = label
        self.showPercentage = showPercentage
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(colors.separator.opacity(0.3), lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AppGradients.accent,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.5), value: progress)

            VStack(spacing: 2) {
                if showPercentage {
                    Text("\(Int(progress * 100))%")
                        .font(AppTypography.title3)
                        .monospacedDigit()
                }
                if let label {
                    Text(label)
                        .font(AppTypography.caption2)
                        .foregroundStyle(colors.secondaryText)
                }
            }
        }
        .frame(width: size, height: size)
        .accessibilityLabel("Progress \(Int(progress * 100)) percent")
    }
}

#Preview {
    HStack(spacing: 24) {
        ProgressRing(progress: 0.78, label: "Today")
        ProgressRing(progress: 0.45, size: 60, showPercentage: false)
    }
    .padding()
}
