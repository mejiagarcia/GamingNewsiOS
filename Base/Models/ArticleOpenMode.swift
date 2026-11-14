import Foundation

nonisolated enum ArticleOpenMode: String, Codable, CaseIterable, Hashable, Identifiable, Sendable {
	case original
	case reader

	var id: Self { self }
}
