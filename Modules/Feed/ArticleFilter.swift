import Foundation

actor ArticleFilter {

	func filter(
		_ articles: [Article],
		query: String
	) -> [Article] {
		let query = query.trimmingCharacters(in: .whitespacesAndNewlines)

		guard !query.isEmpty else {
			return articles
		}

		return articles.filter { $0.title.localizedStandardContains(query) }
	}
}
