import SwiftUI

struct TimePickerRow: View {
    let title: String
    let icon: String
    @Binding var time: Date

    @Environment(\.appColors) private var colors

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(colors.accent)
                .frame(width: 32)
                .accessibilityHidden(true)

            Text(title)
                .font(AppTypography.body)
                .foregroundStyle(colors.primaryText)

            Spacer()

            DatePicker(
                "",
                selection: $time,
                displayedComponents: .hourAndMinute
            )
            .labelsHidden()
            .accessibilityLabel("\(title) time")
        }
        .padding(AppSpacing.md)
        .background(colors.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
    }
}

struct DurationPickerRow: View {
    let title: String
    let icon: String
    @Binding var minutes: Int
    let step: Int
    let range: ClosedRange<Int>
    var unitLabel: String = "min"

    @Environment(\.appColors) private var colors

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack(spacing: AppSpacing.md) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(colors.accent)
                    .frame(width: 32)
                    .accessibilityHidden(true)

                Text(title)
                    .font(AppTypography.body)
                    .foregroundStyle(colors.primaryText)

                Spacer()

                Text(formattedDuration)
                    .font(AppTypography.headline)
                    .monospacedDigit()
                    .foregroundStyle(colors.accent)
            }

            Stepper(value: $minutes, in: range, step: step) {
                EmptyView()
            }
            .labelsHidden()
            .accessibilityLabel("\(title): \(formattedDuration)")
        }
        .padding(AppSpacing.md)
        .background(colors.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
    }

    private var formattedDuration: String {
        if minutes >= 60 && minutes % 60 == 0 {
            let hours = minutes / 60
            return "\(hours)h"
        }
        if minutes >= 60 {
            let hours = minutes / 60
            let mins = minutes % 60
            return "\(hours)h \(mins)m"
        }
        return "\(minutes) \(unitLabel)"
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var time = Date()
        @State private var minutes = 60

        var body: some View {
            VStack(spacing: 16) {
                TimePickerRow(title: "Wake Up", icon: "sun.max.fill", time: $time)
                DurationPickerRow(title: "Travel", icon: "car.fill", minutes: $minutes, step: 15, range: 15...180)
            }
            .padding()
        }
    }
    return PreviewWrapper()
}
