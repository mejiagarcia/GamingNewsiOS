import Foundation

nonisolated struct FeedSource: Codable, Identifiable, Hashable, Sendable {
	let id: String
	let name: String
	let url: URL
	let language: FeedLanguage
	let category: NewsCategory?
	let kind: FeedKind
	let eligibilityPolicy: String?
}
