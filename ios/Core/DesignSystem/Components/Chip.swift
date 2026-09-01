import SwiftUI

struct Chip: View {
    let label: String
    var icon: String?
    var color: Color = .accentColor
    var isSelected: Bool = false
    var action: (() -> Void)?

    var body: some View {
        Group {
            if let action {
                Button(action: action) { chipContent }
                    .buttonStyle(.plain)
            } else {
                chipContent
            }
        }
        .accessibilityLabel(label)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var chipContent: some View {
        HStack(spacing: AppSpacing.xxs) {
            if let icon {
                Image(systemName: icon)
                    .font(.caption2)
            }
            Text(label)
                .font(AppTypography.caption)
        }
        .padding(.horizontal, AppSpacing.sm)
        .padding(.vertical, AppSpacing.xs)
        .background(isSelected ? color : color.opacity(0.12))
        .foregroundStyle(isSelected ? .white : color)
        .clipShape(Capsule())
    }
}

#Preview {
    HStack {
        Chip(label: "Coding", icon: "laptopcomputer", color: .purple)
        Chip(label: "College", color: .blue, isSelected: true)
        Chip(label: "High", color: .red) {}
    }
    .padding()
}
