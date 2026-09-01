import SwiftUI

struct ScheduleView: View {
    @Environment(\.appEnvironment) private var appEnvironment
    @Environment(\.appColors) private var colors
    @State private var scheduleBlocks: [ResolvedScheduleBlock] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var selectedDate = Date.now

    var body: some View {
        NavigationStack {
            Group {
                if isLoading { LoadingView(message: "Loading schedule...") }
                else if let errorMessage { ErrorView(title: "Couldn't load schedule", message: errorMessage, onRetry: { Task { await loadSchedule() } }) }
                else if scheduleBlocks.isEmpty { EmptyState(icon: "calendar", title: "No schedule", message: "Complete onboarding to generate your routine.", actionTitle: "Set up") {} }
                else { scheduleList }
            }
            .navigationTitle("Schedule")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    DatePicker("", selection: $selectedDate, displayedComponents: .date)
                        .labelsHidden()
                        .onChange(of: selectedDate) { _, _ in Task { await loadSchedule() } }
                }
            }
            .task { await loadSchedule() }
        }
    }

    private var scheduleList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                Text(DateFormatters.dayAndDate.string(from: selectedDate))
                    .font(AppTypography.subheadline)
                    .foregroundStyle(colors.secondaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.bottom, AppSpacing.sm)

                ForEach(scheduleBlocks) { block in
                    TimelineCard(title: block.title, startTime: block.startTime.timeString(), endTime: block.endTime.timeString(),
                        icon: block.icon ?? "circle.fill", color: blockColor(block),
                        isActive: isBlockActive(block), isCompleted: block.endTime < .now)
                }
            }
            .padding(.vertical, AppSpacing.sm)
        }
        .background(colors.background)
    }

    private func loadSchedule() async {
        guard let appEnvironment else { return }
        isLoading = true; errorMessage = nil
        do {
            scheduleBlocks = try appEnvironment.scheduleService.resolvedBlocks(for: selectedDate)
        } catch { errorMessage = error.localizedDescription }
        isLoading = false
    }

    private func blockColor(_ block: ResolvedScheduleBlock) -> Color {
        switch block.blockType {
        case ScheduleBlockType.college.rawValue: return colors.college
        case ScheduleBlockType.coding.rawValue: return colors.coding
        case ScheduleBlockType.sleep.rawValue: return colors.sleep
        default: return colors.accent
        }
    }

    private func isBlockActive(_ block: ResolvedScheduleBlock) -> Bool {
        Calendar.current.isDateInToday(selectedDate) && block.startTime <= .now && block.endTime > .now
    }
}

#Preview {
    ScheduleView().environment(\.appEnvironment, try! AppEnvironment(modelContainer: makeModelContainer(inMemory: true)))
}
