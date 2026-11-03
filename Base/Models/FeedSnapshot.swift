import Foundation

nonisolated struct FeedSnapshot: Sendable {
	let articles: [Article]
	let failedSourceIDs: [String]
	let staleSourceIDs: [String]
	let enabledSourceCount: Int
}
