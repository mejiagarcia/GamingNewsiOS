import Foundation

@testable import GamingNews

enum TestFixtures {
	static var newsSource: FeedSource {
		FeedSource(
			id: "test-source",
			name: "Test Publisher",
			url: URL(string: "https://publisher.example/feed") ?? URL(fileURLWithPath: "/feed"),
			language: .en,
			category: .all,
			kind: .news,
			eligibilityPolicy: nil
		)
	}

	static var feedRequest: FeedRequest {
		FeedRequest(
			context: FeedContext(kind: .news, language: .en, category: .all),
			disabled: []
		)
	}

	static func article(
		id: String,
		title: String,
		summary: String = ""
	) -> Article {
		let url = URL(string: "https://publisher.example/\(id)") ?? URL(fileURLWithPath: "/\(id)")

		return Article(
			id: id,
			title: title,
			summary: summary,
			url: url,
			imageURL: nil,
			author: nil,
			publisher: "Test Publisher",
			publishedAt: nil
		)
	}

	static func data(_ string: String) -> Data {
		Data(string.utf8)
	}
}

enum TestError: Error {
	case expected
}

actor StubFeedRepository: FeedRepositoryProtocol {
	private let error: (any Error)?
	private let snapshot: FeedSnapshot

	init(
		snapshot: FeedSnapshot = FeedSnapshot(
			articles: [],
			failedSourceIDs: [],
			staleSourceIDs: [],
			enabledSourceCount: Int.zero
		),
		error: (any Error)? = nil
	) {
		self.snapshot = snapshot
		self.error = error
	}

	func load(
		context: FeedContext,
		disabledSourceIDs: Set<String>,
		force: Bool
	) async throws -> FeedSnapshot {
		if let error {
			throw error
		}

		return snapshot
	}

	func sources() async throws -> [FeedSource] {
		[]
	}
}

actor StubSavedRepository: SavedRepositoryProtocol {
	private var articles: [SavedArticle] = []

	func load() async throws -> [SavedArticle] {
		articles
	}

	func setSaved(_ article: Article, saved: Bool) async throws -> [SavedArticle] {
		articles.removeAll { $0.id == article.id }

		if saved {
			articles.append(SavedArticle(article: article, savedAt: Date(timeIntervalSince1970: 0)))
		}

		return articles
	}
}

actor StubPreferencesRepository: PreferencesRepositoryProtocol {
	private(set) var value: AppPreferences

	init(value: AppPreferences = AppPreferences()) {
		self.value = value
	}

	func load() async throws -> AppPreferences {
		value
	}

	func save(_ preferences: AppPreferences) async throws {
		value = preferences
	}
}
