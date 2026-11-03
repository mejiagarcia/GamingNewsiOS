import Foundation

// MARK: - Bundled feed catalog

nonisolated private struct CatalogGroup: Decodable {
	let language: FeedLanguage
	let all: [SourceEntry]
	let sony: [SourceEntry]
	let microsoft: [SourceEntry]
	let nintendo: [SourceEntry]
	let pc: [SourceEntry]
}

nonisolated private struct SourceEntry: Decodable {
	let id: String
	let name: String
	let url: URL
}

nonisolated private struct ReviewEntry: Decodable {
	let id: String
	let language: FeedLanguage
	let name: String
	let url: URL
	let eligibilityPolicy: String
}

nonisolated enum CatalogError: Error {
	case missingResource
}

nonisolated enum FeedCatalog {

	static func load() throws -> [FeedSource] {
		guard
			let newsURL = Bundle.main.url(
				forResource: "news-feeds",
				withExtension: "json"
			),
			let reviewsURL = Bundle.main.url(
				forResource: "review-feeds",
				withExtension: "json"
			)
		else {
			throw CatalogError.missingResource
		}

		let decoder = JSONDecoder()
		let groups = try decoder.decode(
			[CatalogGroup].self,
			from: Data(contentsOf: newsURL)
		)
		let news = groups.flatMap { group in
			let categories: [(NewsCategory, [SourceEntry])] = [
				(.all, group.all),
				(.sony, group.sony),
				(.microsoft, group.microsoft),
				(.nintendo, group.nintendo),
				(.pc, group.pc)
			]

			return categories.flatMap { category, entries in
				entries.map {
					FeedSource(
						id: $0.id,
						name: $0.name,
						url: $0.url,
						language: group.language,
						category: category,
						kind: .news,
						eligibilityPolicy: nil
					)
				}
			}
		}

		let reviews = try decoder.decode(
			[ReviewEntry].self,
			from: Data(contentsOf: reviewsURL)
		).map {
			FeedSource(
				id: $0.id,
				name: $0.name,
				url: $0.url,
				language: $0.language,
				category: nil,
				kind: .reviews,
				eligibilityPolicy: $0.eligibilityPolicy
			)
		}

		return news + reviews
	}
}
