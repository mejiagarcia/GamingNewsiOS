import Foundation

nonisolated protocol ArticleReaderRepositoryProtocol: Sendable {
	func fetchArticle(from url: URL) async throws -> ReaderArticle
}
