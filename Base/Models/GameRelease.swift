import Foundation

nonisolated struct GamePlatform: Identifiable, Hashable, Sendable {
	let id: Int
	let name: String

	static let supported: [GamePlatform] = [
		GamePlatform(id: 167, name: "PS5"),
		GamePlatform(id: 508, name: "Switch 2"),
		GamePlatform(id: 169, name: "Xbox Series X|S"),
		GamePlatform(id: 6, name: "PC"),
		GamePlatform(id: 130, name: "Nintendo Switch"),
		GamePlatform(id: 48, name: "PS4"),
		GamePlatform(id: 49, name: "Xbox One")
	]
}

nonisolated struct GameReleaseRecord: Codable, Hashable, Identifiable, Sendable {
	let id: Int
	let gameID: Int
	let platformID: Int
	let name: String
	let coverURL: URL?
	let releaseDate: Date
	let gameURL: URL?
	let hasExactDate: Bool
	let humanDate: String?
}

nonisolated struct GameRelease: Hashable, Identifiable, Sendable {
	let id: String
	let name: String
	let coverURL: URL?
	let releaseDate: Date
	let platforms: [String]
	let gameURL: URL?
	let hasExactDate: Bool
	let humanDate: String?

	static func grouped(
		from records: [GameReleaseRecord],
		query: String,
		platformIDs: Set<Int>
	) -> [GameRelease] {
		let filtered = records.filter { record in
			(platformIDs.isEmpty || platformIDs.contains(record.platformID))
				&& (query.isEmpty || record.name.localizedCaseInsensitiveContains(query))
		}
		var groups: [String: [GameReleaseRecord]] = [:]
		for record in filtered {
			let day = Calendar.gamingNewsUTC.startOfDay(for: record.releaseDate).timeIntervalSince1970
			groups["\(record.gameID)-\(Int(day))", default: []].append(record)
		}

		return groups.values.compactMap { values in
			guard let first = values.first else {
				return nil
			}
			let platformIDs = Set(values.map(\.platformID))
			let platformNames = GamePlatform.supported
				.filter { platformIDs.contains($0.id) }
				.map(\.name)
			return GameRelease(
				id: "\(first.gameID)-\(Int(Calendar.gamingNewsUTC.startOfDay(for: first.releaseDate).timeIntervalSince1970))",
				name: first.name,
				coverURL: first.coverURL,
				releaseDate: first.releaseDate,
				platforms: platformNames.sorted(),
				gameURL: first.gameURL,
				hasExactDate: values.allSatisfy(\.hasExactDate),
				humanDate: values.first(where: { !$0.hasExactDate })?.humanDate
			)
		}.sorted {
			if $0.releaseDate != $1.releaseDate {
				return $0.releaseDate < $1.releaseDate
			}
			return $0.name.localizedStandardCompare($1.name) == .orderedAscending
		}
	}
}

nonisolated extension Calendar {
	static var gamingNewsUTC: Calendar {
		var calendar = Calendar(identifier: .gregorian)
		calendar.timeZone = TimeZone(secondsFromGMT: Int.zero) ?? .current
		return calendar
	}
}
