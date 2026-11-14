import Foundation

nonisolated protocol ReleasesRepositoryProtocol: Sendable {
	func loadCached() async throws -> [GameReleaseRecord]
	func fetchNextPage() async throws -> [GameReleaseRecord]
	func refresh() async throws -> [GameReleaseRecord]
	func hasMorePages() async -> Bool
}
