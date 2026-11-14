import Foundation

nonisolated private struct CachedReleasePage: Codable, Sendable {
	let dayKey: String
	let records: [GameReleaseRecord]
	let nextOffset: Int
	let hasMorePages: Bool
}

actor LiveIGDBReleasesRepository: ReleasesRepositoryProtocol {
	private let client: IGDBClient
	private let cacheURL: URL?
	private var records: [GameReleaseRecord] = []
	private var nextOffset = Int.zero
	private var didLoadCache = false
	private var hasMore = true

	init() {
		let bundle = Bundle.main
		let clientID = bundle.object(forInfoDictionaryKey: "IGDBClientID") as? String ?? ""
		let clientSecret = bundle.object(forInfoDictionaryKey: "IGDBClientSecret") as? String ?? ""
		client = IGDBClient(clientID: clientID, clientSecret: clientSecret)
		cacheURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
			.first?.appendingPathComponent("GamingNews", isDirectory: true)
			.appendingPathComponent("releases.json")
	}

	func loadCached() async throws -> [GameReleaseRecord] {
		guard !didLoadCache else {
			return records
		}
		didLoadCache = true
		guard let cacheURL,
			let data = try? Data(contentsOf: cacheURL),
			let cached = try? JSONDecoder().decode(CachedReleasePage.self, from: data),
			cached.dayKey == Self.dayKey()
		else {
			return records
		}
		records = cached.records
		nextOffset = cached.nextOffset
		hasMore = cached.hasMorePages
		return records
	}

	func fetchNextPage() async throws -> [GameReleaseRecord] {
		_ = try await loadCached()
		guard hasMore else {
			return records
		}
		let page = try await client.fetchPage(offset: nextOffset)
		if nextOffset == Int.zero {
			records = page.records
		} else {
			let existingIDs = Set(records.map(\.id))
			records.append(contentsOf: page.records.filter { !existingIDs.contains($0.id) })
		}
		nextOffset += page.resultCount
		hasMore = page.resultCount == 50
		try saveCache()
		return records
	}

	func hasMorePages() -> Bool {
		hasMore
	}

	func refresh() async throws -> [GameReleaseRecord] {
		didLoadCache = true
		let page = try await client.fetchPage(offset: Int.zero)
		records = page.records
		nextOffset = page.resultCount
		hasMore = page.resultCount == 50
		try saveCache()
		return records
	}
}

private extension LiveIGDBReleasesRepository {
	func saveCache() throws {
		guard let cacheURL else {
			return
		}
		try FileManager.default.createDirectory(
			at: cacheURL.deletingLastPathComponent(),
			withIntermediateDirectories: true
		)
		let cached = CachedReleasePage(
			dayKey: Self.dayKey(),
			records: records,
			nextOffset: nextOffset,
			hasMorePages: hasMore
		)
		try JSONEncoder().encode(cached).write(to: cacheURL, options: .atomic)
	}

	static func dayKey(now: Date = Date()) -> String {
		let formatter = DateFormatter()
		formatter.calendar = Calendar.gamingNewsUTC
		formatter.timeZone = TimeZone(secondsFromGMT: Int.zero)
		formatter.dateFormat = "yyyy-MM-dd"
		return formatter.string(from: now)
	}
}
