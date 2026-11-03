import Foundation

// MARK: - Concurrent feed loading

nonisolated private struct SourceResult: Sendable {
	let source: FeedSource
	let articles: [Article]?
}

nonisolated private struct CachedSource: Sendable {
	let articles: [Article]
	let fetchedAt: Date
}

actor LiveFeedRepository: FeedRepositoryProtocol {

	// MARK: - Private Variables

	private var cache: [String: CachedSource] = [:]
	private var catalog: [FeedSource]?
	private var generations: [FeedContext: UUID] = [:]
}

// MARK: - Internal Methods

extension LiveFeedRepository {

	func load(
		context: FeedContext,
		disabledSourceIDs: Set<String>,
		force: Bool
	) async throws -> FeedSnapshot {
		let selected = try sources().filter {
			$0.kind == context.kind && $0.language == context.language
				&& ($0.kind == .reviews || $0.category == context.category)
				&& !disabledSourceIDs.contains($0.id)
		}

		let generation = UUID()
		generations[context] = generation
		let now = Date()
		let pending = selected.filter {
			force || (cache[$0.id].map { now.timeIntervalSince($0.fetchedAt) >= 900 } ?? true)
		}

		var results: [SourceResult] = []
		// A sliding window limits concurrent publisher requests to four.
		await withTaskGroup(of: SourceResult.self) { group in
			var iterator = pending.makeIterator()

			for _
				in Int.zero..<min(
					4,
					pending.count
				)
			{
				if let source = iterator.next() { group.addTask { await Self.fetch(source) } }
			}

			while let result = await group.next() {
				results.append(result)

				if !Task.isCancelled, let source = iterator.next() {
					group.addTask { await Self.fetch(source) }
				}
			}
		}

		try Task.checkCancellation()

		guard generations[context] == generation else {
			throw CancellationError()
		}

		for result in results {
			if let articles = result.articles {
				cache[result.source.id] = CachedSource(
					articles: articles,
					fetchedAt: Date()
				)
			}
		}

		let failed = Set(results.filter { $0.articles == nil }.map(\.source.id))
		var seen = Set<String>()
		let ordered = selected.flatMap { cache[$0.id]?.articles ?? [] }.sorted {
			switch (
				$0.publishedAt,
				$1.publishedAt
			) {
				case let (
					left?,
					right?
				): left == right ? $0.id < $1.id : left > right
				case (
					_?,
					nil
				): true
				case (
					nil,
					_?
				): false
				case (
					nil,
					nil
				): $0.id < $1.id
			}
		}.filter { seen.insert($0.id).inserted }

		return FeedSnapshot(
			articles: ordered,
			failedSourceIDs: selected.filter { failed.contains($0.id) }.map(\.id),
			staleSourceIDs: selected.filter { failed.contains($0.id) && cache[$0.id] != nil }.map(\.id),
			enabledSourceCount: selected.count
		)
	}

	func sources() throws -> [FeedSource] {
		if let catalog {
			return catalog
		}

		let result = try FeedCatalog.load()
		catalog = result

		return result
	}
}

// MARK: - Private Methods

extension LiveFeedRepository {

	@concurrent
	private static func fetch(_ source: FeedSource) async -> SourceResult {
		do {
			if source.kind == .reviews && source.eligibilityPolicy != "gaming_feed_reviews" {
				return SourceResult(
					source: source,
					articles: nil
				)
			}

			var request = URLRequest(
				url: source.url,
				timeoutInterval: 20
			)
			request.setValue(
				"GamingNews/1.0",
				forHTTPHeaderField: "User-Agent"
			)
			let session = URLSession(configuration: .ephemeral)

			defer { session.finishTasksAndInvalidate() }
			let (
				data,
				response
			) = try await session.data(for: request)

			guard let response = response as? HTTPURLResponse, (200..<300).contains(response.statusCode)
			else {
				return SourceResult(
					source: source,
					articles: nil
				)
			}

			try Task.checkCancellation()

			return SourceResult(
				source: source,
				articles: try FeedParser(source: source).parse(data)
			)
		} catch {
			return SourceResult(
				source: source,
				articles: nil
			)
		}
	}
}
