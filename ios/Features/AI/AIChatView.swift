import SwiftUI

struct AIChatView: View {
    @Environment(\.appEnvironment) private var appEnvironment
    @Environment(\.appColors) private var colors
    @State private var messages: [(role: String, text: String)] = []
    @State private var input = ""
    @State private var isLoading = false

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: AppSpacing.sm) {
                        ForEach(Array(messages.enumerated()), id: \.offset) { index, msg in
                            messageBubble(msg)
                                .id(index)
                        }
                        if isLoading {
                            HStack {
                                ProgressView()
                                Text("Thinking...")
                                    .font(AppTypography.caption)
                                    .foregroundStyle(colors.secondaryText)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, AppSpacing.md)
                        }
                    }
                    .padding(.vertical, AppSpacing.md)
                }
                .onChange(of: messages.count) { _, _ in
                    if let last = messages.indices.last {
                        proxy.scrollTo(last, anchor: .bottom)
                    }
                }
            }

            Divider()

            HStack(spacing: AppSpacing.sm) {
                TextField("Ask AI Coach...", text: $input, axis: .vertical)
                    .lineLimit(1...4)
                    .padding(AppSpacing.sm)
                    .background(colors.secondaryBackground)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))

                Button {
                    sendMessage()
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                        .foregroundStyle(input.isEmpty ? colors.tertiaryText : colors.accent)
                }
                .disabled(input.isEmpty || isLoading)
                .accessibilityLabel("Send message")
            }
            .padding(AppSpacing.md)
        }
        .background(colors.background)
        .navigationTitle("AI Coach")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if messages.isEmpty {
                messages.append((role: "assistant", text: "Hi! I can help plan your day, break down tasks, or repair your schedule. What do you need?"))
            }
        }
    }

    private func messageBubble(_ msg: (role: String, text: String)) -> some View {
        HStack {
            if msg.role == "user" { Spacer() }
            Text(msg.text)
                .font(AppTypography.body)
                .padding(AppSpacing.md)
                .background(msg.role == "user" ? colors.accent : colors.secondaryBackground)
                .foregroundStyle(msg.role == "user" ? .white : colors.primaryText)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
                .frame(maxWidth: 280, alignment: msg.role == "user" ? .trailing : .leading)
            if msg.role == "assistant" { Spacer() }
        }
        .padding(.horizontal, AppSpacing.md)
        .accessibilityLabel(msg.role == "user" ? "You said \(msg.text)" : "AI said \(msg.text)")
    }

    private func sendMessage() {
        let text = input.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty, let aiService = appEnvironment?.aiService else { return }
        messages.append((role: "user", text: text))
        input = ""
        isLoading = true

        Task {
            do {
                let response = try await aiService.chat(message: text)
                messages.append((role: "assistant", text: response.reply))
                if let suggestions = response.suggestions, !suggestions.isEmpty {
                    let list = suggestions.map { "• \($0.title) (\($0.durationMinutes)m)" }.joined(separator: "\n")
                    messages.append((role: "assistant", text: "Suggestions:\n\(list)\n\nTap Apply in Schedule to confirm."))
                }
            } catch {
                messages.append((role: "assistant", text: "AI is temporarily unavailable. Your schedule is safe."))
            }
            isLoading = false
        }
    }
}

#Preview {
    NavigationStack {
        AIChatView()
            .environment(\.appEnvironment, try! AppEnvironment(modelContainer: makeModelContainer(inMemory: true)))
    }
}
