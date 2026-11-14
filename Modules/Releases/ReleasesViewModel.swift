import Foundation
import Observation

@MainActor
@Observable
final class ReleasesViewModel {
	private let repository: any ReleasesRepositoryProtocol
	private var records: [GameReleaseRecord] = []
	private var loaded = false

	var errorKey: String?
	var isLoading = false
	var isRefreshing = false
	var isLoadingMore = false
	var platformIDs: Set<Int> = [] {
		didSet { filtersChanged() }
	}
	var query = "" {
		didSet { filtersChanged() }
	}
	var releases: [GameRelease] = []
	var hasMorePages = true

	init(repository: any ReleasesRepositoryProtocol) {
		self.repository = repository
	}
}

extension ReleasesViewModel {
	func load() async {
		guard !loaded else {
			return
		}
		loaded = true
		isLoading = true
		defer { isLoading = false }
		do {
			records = try await repository.loadCached()
			updateReleases()
			hasMorePages = await repository.hasMorePages()
			if records.isEmpty {
				while hasMorePages, releases.isEmpty, errorKey == nil {
					await loadNextPage()
				}
			}
		} catch {
			errorKey = Self.errorKey(for: error)
		}
	}

	func loadNextPage() async {
		guard !isLoadingMore, hasMorePages else {
			return
		}
		isLoadingMore = true
		defer { isLoadingMore = false }
		do {
			repeat {
				records = try await repository.fetchNextPage()
				hasMorePages = await repository.hasMorePages()
				errorKey = nil
				updateReleases()
			} while releases.isEmpty && hasMorePages
		} catch {
			errorKey = Self.errorKey(for: error)
		}
	}

	func refresh() async {
		guard !isRefreshing else {
			return
		}
		isRefreshing = true
		defer { isRefreshing = false }
		do {
			records = try await repository.refresh()
			hasMorePages = await repository.hasMorePages()
			errorKey = nil
			updateReleases()
		} catch {
			errorKey = Self.errorKey(for: error)
		}
	}

	func togglePlatform(_ platformID: Int) {
		if platformIDs.contains(platformID) {
			platformIDs.remove(platformID)
		} else {
			platformIDs.insert(platformID)
		}
	}
}

private extension ReleasesViewModel {
	func filtersChanged() {
		updateReleases()
		guard loaded, releases.isEmpty, hasMorePages, !isLoadingMore else {
			return
		}
		Task { await loadNextPage() }
	}

	func updateReleases() {
		releases = GameRelease.grouped(
			from: records,
			query: query.trimmingCharacters(in: .whitespacesAndNewlines),
			platformIDs: platformIDs
		)
	}

	static func errorKey(for error: Error) -> String {
		if let error = error as? IGDBClientError, error == .credentialsMissing {
			return "releases.credentialsMissing"
		}
		return "releases.loadFailed"
	}
}
