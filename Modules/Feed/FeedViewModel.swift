import Foundation
import Observation

@MainActor
@Observable
final class FeedViewModel {

	// MARK: - Private Constants

	private let filter = ArticleFilter()
	private let repository: any FeedRepositoryProtocol

	// MARK: - Private Variables

	private var filterID = UUID()
	private var previousRequest: FeedRequest?
	private var requestID = UUID()
	private var snapshot: FeedSnapshot?

	// MARK: - Internal Constants

	let kind: FeedKind

	// MARK: - Internal Variables

	var articles: [Article] = []
	var category: NewsCategory = .all
	var failed = false
	var isLoading = false
	var loaded = false
	var noSources = false
	var partialFailure = false
	var query = ""
	var stale = false

	// MARK: - Life Cycle

	init(
		kind: FeedKind,
		repository: any FeedRepositoryProtocol
	) {
		self.kind = kind
		self.repository = repository
	}
}

// MARK: - Internal Methods

extension FeedViewModel {

	func applySearch() async {
		let id = UUID()
		filterID = id

		let result = await filter.filter(
			snapshot?.articles ?? [],
			query: query
		)

		guard id == filterID else {
			return
		}

		articles = result
	}

	func load(
		_ request: FeedRequest,
		force: Bool = false
	) async {
		let id = UUID()
		requestID = id

		if previousRequest != request {
			previousRequest = request
			filterID = UUID()
			snapshot = nil
			articles = []
			loaded = false
			failed = false
			partialFailure = false
			noSources = false
		}

		isLoading = true

		defer { if requestID == id { isLoading = false } }

		do {
			let result = try await repository.load(
				context: request.context,
				disabledSourceIDs: request.disabled,
				force: force
			)

			guard !Task.isCancelled, requestID == id else {
				return
			}

			snapshot = result
			noSources = result.enabledSourceCount == Int.zero
			failed =
				!noSources && result.articles.isEmpty
				&& result.failedSourceIDs.count == result.enabledSourceCount
			partialFailure = !result.failedSourceIDs.isEmpty && !failed
			stale = !result.staleSourceIDs.isEmpty
			loaded = true

			await applySearch()
		} catch is CancellationError {
			return
		} catch {
			guard requestID == id else {
				return
			}

			failed = true
			loaded = true
		}
	}
}
