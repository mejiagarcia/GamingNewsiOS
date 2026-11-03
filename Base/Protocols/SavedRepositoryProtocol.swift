import Foundation

nonisolated protocol SavedRepositoryProtocol: Sendable {
	func load() async throws -> [SavedArticle]
	func setSaved(
		_ article: Article,
		saved: Bool
	) async throws -> [SavedArticle]
}
