import SwiftUI

struct NewsListView: View {
    @Environment(\.appEnvironment) private var appEnvironment
    @Environment(\.appColors) private var colors
    @State private var articles: [NewsArticle] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        Group {
            if isLoading {
                LoadingView(message: "Loading AI briefing...")
            } else if let errorMessage {
                ErrorView(title: "Couldn't load news", message: errorMessage, onRetry: { Task { await load() } })
            } else if articles.isEmpty {
                EmptyState(icon: "newspaper", title: "No updates yet", message: "Check back later for today's AI briefing.", actionTitle: "Refresh") {
                    Task { await load() }
                }
            } else {
                newsList
            }
        }
        .background(colors.background)
        .navigationTitle("AI Daily")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { Task { await load() } } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .accessibilityLabel("Refresh news")
            }
        }
        .task { await load() }
    }

    private var newsList: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                    Text(DateFormatters.dayAndDate.string(from: .now))
                        .font(AppTypography.subheadline)
                        .foregroundStyle(colors.secondaryText)
                    Text("\(articles.count) important updates")
                        .font(AppTypography.headline)
                }
                .padding(.horizontal, AppSpacing.md)

                ForEach(articles.sorted(by: { $0.sortOrder < $1.sortOrder }), id: \.id) { article in
                    NewsCardView(article: article) {
                        try? appEnvironment?.newsRepository.markAsRead(article)
                    }
                }
            }
            .padding(.bottom, AppSpacing.xl)
        }
    }

    private func load() async {
        guard let newsService = appEnvironment?.newsService else { return }
        isLoading = true
        errorMessage = nil
        do {
            articles = try await newsService.fetchToday()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}

struct NewsCardView: View {
    let article: NewsArticle
    let onRead: () -> Void
    @Environment(\.appColors) private var colors

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack(alignment: .top) {
                Text(String(format: "%02d", article.sortOrder))
                    .font(AppTypography.caption)
                    .foregroundStyle(colors.accent)
                    .fontWeight(.bold)
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text(article.title)
                        .font(AppTypography.headline)
                    Chip(label: article.category, color: colors.accent)
                    Text(article.summary)
                        .font(AppTypography.subheadline)
                        .foregroundStyle(colors.secondaryText)
                    if !article.whyItMatters.isEmpty {
                        Text("Why it matters: \(article.whyItMatters)")
                            .font(AppTypography.caption)
                            .foregroundStyle(colors.tertiaryText)
                    }
                    HStack {
                        Text(article.sourceName)
                            .font(AppTypography.caption2)
                            .foregroundStyle(colors.tertiaryText)
                        Spacer()
                        if let url = URL(string: article.sourceUrl) {
                            Link("Read", destination: url)
                                .font(AppTypography.caption)
                        }
                    }
                }
            }
        }
        .padding(AppSpacing.md)
        .background(colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
        .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
        .padding(.horizontal, AppSpacing.md)
        .onTapGesture { onRead() }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    NavigationStack {
        NewsListView()
            .environment(\.appEnvironment, try! AppEnvironment(modelContainer: makeModelContainer(inMemory: true)))
    }
}
