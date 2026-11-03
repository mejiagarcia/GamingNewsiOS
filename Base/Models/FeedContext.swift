import Foundation

nonisolated struct FeedContext: Hashable, Sendable {
	let kind: FeedKind
	let language: FeedLanguage
	let category: NewsCategory
}
