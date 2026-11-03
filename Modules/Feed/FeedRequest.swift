import Foundation

nonisolated struct FeedRequest: Equatable, Sendable {
	let context: FeedContext
	let disabled: Set<String>
}
