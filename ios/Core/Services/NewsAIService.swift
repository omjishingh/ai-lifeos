import Foundation

struct NewsItemDTO: Codable, Identifiable {
    let id: String
    let title: String
    let summary: String
    let whyItMatters: String
    let sourceName: String
    let sourceUrl: String
    let publishedAt: String
    let category: String
    let imageUrl: String?
    let tags: [String]
    let sortOrder: Int
}

struct TodayNewsResponse: Codable {
    let date: String
    let count: Int
    let items: [NewsItemDTO]
}

struct AIChatRequest: Codable {
    let message: String
    let context: AIContext?
}

struct AIContext: Codable {
    let schedule: String?
    let tasks: [String]?
}

struct AIChatResponse: Codable {
    let reply: String
    let suggestions: [AISuggestion]?
}

struct AISuggestion: Codable, Identifiable {
    var id: String { title }
    let title: String
    let durationMinutes: Int
    let priority: String
}

struct AIPlanResponse: Codable {
    let suggestions: [AISuggestion]
}

protocol NewsServiceProtocol {
    func fetchToday() async throws -> [NewsArticle]
    func refreshToday() async throws -> [NewsArticle]
}

protocol AIServiceProtocol {
    func chat(message: String) async throws -> AIChatResponse
    func planDay(hoursAvailable: Double) async throws -> AIPlanResponse
    func breakdownTask(_ title: String) async throws -> [String]
}

struct NewsService: NewsServiceProtocol {
    private let apiClient: APIClientProtocol
    private let newsRepository: NewsRepositoryProtocol
    private let networkMonitor: NetworkMonitorProtocol

    init(apiClient: APIClientProtocol, newsRepository: NewsRepositoryProtocol, networkMonitor: NetworkMonitorProtocol) {
        self.apiClient = apiClient
        self.newsRepository = newsRepository
        self.networkMonitor = networkMonitor
    }

    func fetchToday() async throws -> [NewsArticle] {
        let cached = try newsRepository.fetchToday()
        if !cached.isEmpty { return cached }
        return try await refreshToday()
    }

    func refreshToday() async throws -> [NewsArticle] {
        if networkMonitor.isConnected {
            do {
                let response: TodayNewsResponse = try await apiClient.get("/news/today")
                let articles = response.items.map { dto -> NewsArticle in
                    NewsArticle(
                        id: UUID(uuidString: dto.id) ?? UUID(),
                        title: dto.title,
                        summary: dto.summary,
                        whyItMatters: dto.whyItMatters,
                        sourceName: dto.sourceName,
                        sourceUrl: dto.sourceUrl,
                        publishedAt: ISO8601DateFormatter().date(from: dto.publishedAt) ?? .now,
                        category: dto.category,
                        imageUrl: dto.imageUrl,
                        tags: dto.tags,
                        briefingDate: .now,
                        sortOrder: dto.sortOrder
                    )
                }
                try newsRepository.saveArticles(articles)
                return articles
            } catch {
                return MockNewsProvider.articles()
            }
        }
        return MockNewsProvider.articles()
    }
}

struct AIService: AIServiceProtocol {
    private let apiClient: APIClientProtocol
    private let networkMonitor: NetworkMonitorProtocol

    init(apiClient: APIClientProtocol, networkMonitor: NetworkMonitorProtocol) {
        self.apiClient = apiClient
        self.networkMonitor = networkMonitor
    }

    func chat(message: String) async throws -> AIChatResponse {
        guard networkMonitor.isConnected else {
            return MockAIProvider.chatResponse(for: message)
        }
        do {
            return try await apiClient.post("/ai/chat", body: AIChatRequest(message: message, context: nil))
        } catch {
            return MockAIProvider.chatResponse(for: message)
        }
    }

    func planDay(hoursAvailable: Double) async throws -> AIPlanResponse {
        guard networkMonitor.isConnected else {
            return MockAIProvider.planResponse(hours: hoursAvailable)
        }
        struct PlanRequest: Codable { let hoursAvailable: Double }
        do {
            return try await apiClient.post("/ai/plan", body: PlanRequest(hoursAvailable: hoursAvailable))
        } catch {
            return MockAIProvider.planResponse(hours: hoursAvailable)
        }
    }

    func breakdownTask(_ title: String) async throws -> [String] {
        guard networkMonitor.isConnected else {
            return MockAIProvider.breakdown(for: title)
        }
        struct BreakdownRequest: Codable { let task: String }
        struct BreakdownResponse: Codable { let steps: [String] }
        do {
            let response: BreakdownResponse = try await apiClient.post("/ai/breakdown", body: BreakdownRequest(task: title))
            return response.steps
        } catch {
            return MockAIProvider.breakdown(for: title)
        }
    }
}

enum MockNewsProvider {
    static func articles() -> [NewsArticle] {
        let categories = NewsCategory.allCases
        return categories.enumerated().map { index, category in
            NewsArticle(
                title: "AI Update: \(category.rawValue)",
                summary: "Latest developments in \(category.rawValue.lowercased()). Connect backend for live news.",
                whyItMatters: "Staying informed helps you make better decisions about tools and trends.",
                sourceName: "AI LifeOS Briefing",
                sourceUrl: "https://example.com/news/\(index + 1)",
                publishedAt: .now,
                category: category.rawValue,
                briefingDate: .now,
                sortOrder: index + 1
            )
        }
    }
}

enum MockAIProvider {
    static func chatResponse(for message: String) -> AIChatResponse {
        AIChatResponse(
            reply: "I understand: \"\(message)\". Connect the backend for full AI responses. Your schedule is safe.",
            suggestions: nil
        )
    }

    static func planResponse(hours: Double) -> AIPlanResponse {
        let minutes = Int(hours * 60)
        AIPlanResponse(suggestions: [
            AISuggestion(title: "Personal Coding", durationMinutes: min(minutes * 2 / 3, 120), priority: "high"),
            AISuggestion(title: "College Review", durationMinutes: min(minutes / 3, 60), priority: "medium")
        ])
    }

    static func breakdown(for title: String) -> [String] {
        [
            "Research requirements for \(title)",
            "Design the approach",
            "Implement core functionality",
            "Test and validate",
            "Review and iterate"
        ]
    }
}
