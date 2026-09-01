import SwiftUI

struct TaskFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.appColors) private var colors

    let existing: TaskItem?
    let onSave: (String, String, String, TaskPriority, Int, Date?) -> Void

    @State private var title = ""
    @State private var description = ""
    @State private var category = TaskCategory.personalCoding.rawValue
    @State private var priority = TaskPriority.medium
    @State private var durationMinutes = 30
    @State private var hasDeadline = false
    @State private var deadline = Date.now.addingTimeInterval(86400)

    var body: some View {
        NavigationStack {
            Form {
                Section("Task") {
                    TextField("Title", text: $title)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section("Details") {
                    Picker("Category", selection: $category) {
                        ForEach(TaskCategory.allCases, id: \.rawValue) { cat in
                            Text(cat.rawValue).tag(cat.rawValue)
                        }
                    }

                    Picker("Priority", selection: $priority) {
                        ForEach(TaskPriority.allCases, id: \.self) { p in
                            Text(p.displayName).tag(p)
                        }
                    }

                    Stepper("Duration: \(durationMinutes) min", value: $durationMinutes, in: 15...480, step: 15)

                    Toggle("Has deadline", isOn: $hasDeadline)
                    if hasDeadline {
                        DatePicker("Deadline", selection: $deadline, displayedComponents: [.date, .hourAndMinute])
                    }
                }
            }
            .navigationTitle(existing == nil ? "New Task" : "Edit Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(title, description, category, priority, durationMinutes, hasDeadline ? deadline : nil)
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                if let existing {
                    title = existing.title
                    description = existing.taskDescription
                    category = existing.category
                    priority = existing.taskPriority
                    durationMinutes = existing.estimatedDurationMinutes
                    if let d = existing.deadline {
                        hasDeadline = true
                        deadline = d
                    }
                }
            }
        }
    }
}
