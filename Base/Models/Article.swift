import Foundation

nonisolated struct Article: Codable, Identifiable, Hashable, Sendable {
	let id: String
	let title: String
	let summary: String
	let url: URL
	let imageURL: URL?
	let author: String?
	let publisher: String
	let publishedAt: Date?
}
