import Foundation

nonisolated struct ReaderArticle: Sendable {
	let title: String
	let byline: String?
	let elements: [ReaderElement]
}

nonisolated struct ReaderListItem: Identifiable, Sendable {
	let id: Int
	let text: String
}

nonisolated struct ReaderElement: Identifiable, Sendable {
	enum Content: Sendable {
		case heading(level: Int, text: String)
		case paragraph(String)
		case image(url: URL, caption: String?)
		case bulletList([ReaderListItem])
		case orderedList([ReaderListItem])
		case quote(String)
		case divider
	}

	let id: String
	let content: Content
}
