import Foundation

nonisolated protocol FeedRepositoryProtocol: Sendable {
	func load(
		context: FeedContext,
		disabledSourceIDs: Set<String>,
		force: Bool
	) async throws -> FeedSnapshot
	func sources() async throws -> [FeedSource]
}
