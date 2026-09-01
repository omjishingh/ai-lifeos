import SwiftUI

struct NotificationSettingsView: View {
    @Environment(\.appEnvironment) private var appEnvironment
    @Environment(\.appColors) private var colors
    @State private var notificationsEnabled = true
    @State private var soundEnabled = true
    @State private var timeSensitive = true
    @State private var before30 = true
    @State private var before15 = true
    @State private var before10 = true
    @State private var before5 = true
    @State private var pendingCount = 0
    @State private var isRescheduling = false
    @State private var message: String?

    var body: some View {
        List {
            Section {
                Toggle("POP-POP Notifications", isOn: $notificationsEnabled)
                Toggle("Sound", isOn: $soundEnabled)
                Toggle("Time Sensitive (lock screen priority)", isOn: $timeSensitive)
            } header: {
                Text("Lock Screen Alerts")
            } footer: {
                Text("Time Sensitive notifications appear prominently on your lock screen and break through Focus modes when allowed.")
            }

            Section("Before task starts") {
                Toggle("30 minutes before", isOn: $before30)
                Toggle("15 minutes before", isOn: $before15)
                Toggle("10 minutes before", isOn: $before10)
                Toggle("5 minutes before", isOn: $before5)
            }

            Section("Also scheduled automatically") {
                Label("At task start — POP!", systemImage: "bolt.fill")
                Label("10 & 5 min before end", systemImage: "timer")
                Label("Missed task alert", systemImage: "exclamationmark.triangle")
                Label("Morning briefing", systemImage: "sun.max")
                Label("Wind down & sleep", systemImage: "moon.fill")
                Label("Wake up", systemImage: "alarm")
                Label("AI news briefing", systemImage: "sparkles")
            }

            Section {
                HStack {
                    Text("Scheduled alerts")
                    Spacer()
                    Text("\(pendingCount)")
                        .monospacedDigit()
                        .foregroundStyle(colors.accent)
                }

                Button {
                    Task { await reschedule() }
                } label: {
                    HStack {
                        if isRescheduling { ProgressView() }
                        Text("Reschedule all POP-POPs")
                    }
                }
                .disabled(isRescheduling)

                if let message {
                    Text(message)
                        .font(AppTypography.caption)
                        .foregroundStyle(colors.secondaryText)
                }
            }
        }
        .navigationTitle("POP-POP Settings")
        .task { await load() }
        .onChange(of: notificationsEnabled) { _, _ in Task { await saveAndReschedule() } }
        .onChange(of: soundEnabled) { _, _ in Task { await saveAndReschedule() } }
        .onChange(of: timeSensitive) { _, _ in Task { await reschedule() } }
        .onChange(of: before30) { _, _ in Task { await reschedule() } }
        .onChange(of: before15) { _, _ in Task { await reschedule() } }
        .onChange(of: before10) { _, _ in Task { await reschedule() } }
        .onChange(of: before5) { _, _ in Task { await reschedule() } }
    }

    private func load() async {
        guard let env = appEnvironment else { return }
        if let settings = env.appSettings {
            notificationsEnabled = settings.notificationsEnabled
        }
        pendingCount = await env.popPopEngine.pendingCount()
    }

    private func saveAndReschedule() async {
        guard let env = appEnvironment, var settings = env.appSettings else { return }
        settings.notificationsEnabled = notificationsEnabled
        try? env.settingsRepository.saveSettings(settings)
        env.appSettings = settings
        await reschedule()
    }

    private func reschedule() async {
        guard let env = appEnvironment else { return }
        isRescheduling = true
        message = nil

        if notificationsEnabled {
            _ = await env.popPopEngine.requestPermission()
        }

        do {
            try await env.missedTaskService.rescheduleAllPops()
            pendingCount = await env.popPopEngine.pendingCount()
            message = "✅ \(pendingCount) lock screen alerts scheduled!"
        } catch {
            message = "Failed: \(error.localizedDescription)"
        }
        isRescheduling = false
    }
}

#Preview {
    NavigationStack {
        NotificationSettingsView()
            .environment(\.appEnvironment, try! AppEnvironment(modelContainer: makeModelContainer(inMemory: true)))
    }
}
