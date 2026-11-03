import Foundation

nonisolated struct SavedArticle: Codable, Identifiable, Hashable, Sendable {
	var id: String {
		article.id
	}
	let article: Article
	let savedAt: Date
}
