import SwiftUI

struct ProfileView: View {
    @Environment(\.appEnvironment) private var appEnvironment
    @Environment(\.appColors) private var colors
    @State private var showExportSheet = false
    @State private var exportData: Data?
    @State private var showDeleteConfirm = false

    var body: some View {
        NavigationStack {
            List {
                profileHeader
                ForEach(settingsSections, id: \.title) { section in
                    Section(section.title) {
                        ForEach(section.items) { item in
                            settingsRow(item)
                        }
                    }
                }
            }
            .navigationTitle("Profile")
            .sheet(isPresented: $showExportSheet) {
                if let exportData {
                    ShareSheet(data: exportData)
                }
            }
            .alert("Delete all data?", isPresented: $showDeleteConfirm) {
                Button("Delete", role: .destructive) {
                    try? appEnvironment?.deleteAllData()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will remove all tasks, schedules, and settings. This cannot be undone.")
            }
        }
    }

    private var profileHeader: some View {
        Section {
            HStack(spacing: AppSpacing.md) {
                Image(systemName: "person.circle.fill").font(.system(size: 56)).foregroundStyle(colors.accent)
                VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                    Text(appEnvironment?.userProfile?.name ?? "User").font(AppTypography.title3)
                    if let profile = appEnvironment?.userProfile {
                        Text("Coding: \(profile.codingTargetMinutes / 60)h/day · Streak active")
                            .font(AppTypography.caption).foregroundStyle(colors.secondaryText)
                    }
                }
            }.padding(.vertical, AppSpacing.sm)
        }
    }

    private let settingsSections: [(title: String, items: [SettingsItem])] = [
        ("Schedule", [
            SettingsItem(title: "College", icon: "graduationcap.fill", destination: .college),
            SettingsItem(title: "Sleep & Music", icon: "moon.fill", destination: .sleep)
        ]),
        ("Data", [
            SettingsItem(title: "Export Data", icon: "square.and.arrow.up", destination: .export),
            SettingsItem(title: "Delete Data", icon: "trash", destination: .delete, isDestructive: true),
            SettingsItem(title: "Reset Onboarding", icon: "arrow.counterclockwise", destination: .resetOnboarding)
        ]),
        ("About", [
            SettingsItem(title: "Version", icon: "info.circle", destination: .about)
        ])
    ]

    private func settingsRow(_ item: SettingsItem) -> some View {
        Group {
            if item.destination == .college {
                NavigationLink { CollegeView() } label: { rowContent(item) }
            } else if item.destination == .sleep {
                NavigationLink { SleepView() } label: { rowContent(item) }
            } else {
                Button { handleAction(item) } label: { rowContent(item) }
            }
        }
    }

    private func rowContent(_ item: SettingsItem) -> some View {
        HStack {
            Image(systemName: item.icon).foregroundStyle(item.isDestructive ? colors.error : colors.accent).frame(width: 28)
            Text(item.title).foregroundStyle(item.isDestructive ? colors.error : colors.primaryText)
            Spacer()
            if item.destination == .about {
                Text("1.0.0").font(AppTypography.caption).foregroundStyle(colors.secondaryText)
            } else if item.destination != .resetOnboarding && item.destination != .export && item.destination != .delete {
                Image(systemName: "chevron.right").font(.caption).foregroundStyle(colors.tertiaryText)
            }
        }
    }

    private func handleAction(_ item: SettingsItem) {
        guard let env = appEnvironment else { return }
        switch item.destination {
        case .export:
            exportData = DataExportService.exportJSON(
                profile: env.userProfile,
                tasks: (try? env.taskRepository.fetchAll()) ?? [],
                blocks: (try? env.scheduleRepository.fetchAll()) ?? [],
                goals: (try? env.goalRepository.fetchAll()) ?? [],
                streaks: (try? env.streakRepository.fetchAll()) ?? []
            )
            showExportSheet = true
        case .delete: showDeleteConfirm = true
        case .resetOnboarding: try? env.resetOnboarding()
        default: break
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let data: Data
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("ailifeos-export.json")
        try? data.write(to: url)
        return UIActivityViewController(activityItems: [url], applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct SettingsItem: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let destination: SettingsDestination
    var isDestructive: Bool = false
}

enum SettingsDestination {
    case profile, schedule, college, notifications, ai, news, sleep, appearance
    case export, delete, resetOnboarding, about
}

#Preview {
    ProfileView().environment(\.appEnvironment, try! AppEnvironment(modelContainer: makeModelContainer(inMemory: true)))
}
