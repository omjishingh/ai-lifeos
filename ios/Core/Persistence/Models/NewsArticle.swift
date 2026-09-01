import Foundation
import SwiftData

@Model
final class NewsArticle {
    @Attribute(.unique) var id: UUID
    var title: String
    var summary: String
    var whyItMatters: String
    var sourceName: String
    var sourceUrl: String
    var publishedAt: Date
    var category: String
    var imageUrl: String?
    var tags: [String]
    var briefingDate: Date
    var sortOrder: Int
    var isRead: Bool
    var createdAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        summary: String,
        whyItMatters: String = "",
        sourceName: String,
        sourceUrl: String,
        publishedAt: Date,
        category: String,
        imageUrl: String? = nil,
        tags: [String] = [],
        briefingDate: Date = .now,
        sortOrder: Int = 0,
        isRead: Bool = false,
        createdAt: Date = .now
    ) {
        self.id = id
        self.title = title
        self.summary = summary
        self.whyItMatters = whyItMatters
        self.sourceName = sourceName
        self.sourceUrl = sourceUrl
        self.publishedAt = publishedAt
        self.category = category
        self.imageUrl = imageUrl
        self.tags = tags
        self.briefingDate = briefingDate
        self.sortOrder = sortOrder
        self.isRead = isRead
        self.createdAt = createdAt
    }
}

@Model
final class SavedArticle {
    @Attribute(.unique) var id: UUID
    var articleId: UUID
    var savedAt: Date

    init(id: UUID = UUID(), articleId: UUID, savedAt: Date = .now) {
        self.id = id
        self.articleId = articleId
        self.savedAt = savedAt
    }
}
