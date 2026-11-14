import Foundation

nonisolated enum HeadlineMatchMode: String, Codable, CaseIterable, Identifiable, Sendable {
	case contains, wholeWord, exactPhrase

	var id: String {
		rawValue
	}
}

nonisolated struct MutedHeadlineRule: Codable, Equatable, Identifiable, Sendable {
	let id: String
	var text: String
	var matchMode: HeadlineMatchMode
	var caseSensitive: Bool
	var appliesEverywhere: Bool
	var categories: Set<NewsCategory>

	init(
		id: String = UUID().uuidString,
		text: String,
		matchMode: HeadlineMatchMode = .contains,
		caseSensitive: Bool = false,
		appliesEverywhere: Bool = true,
		categories: Set<NewsCategory> = []
	) {
		self.id = id
		self.text = text
		self.matchMode = matchMode
		self.caseSensitive = caseSensitive
		self.appliesEverywhere = appliesEverywhere
		self.categories = categories
	}
}
