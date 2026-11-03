import Observation
import UIKit

@MainActor
@Observable
final class AppState {

	// MARK: - Repositories

	private let preferencesRepository: any PreferencesRepositoryProtocol
	private let savedRepository: any SavedRepositoryProtocol

	// MARK: - Internal Constants

	let feeds: any FeedRepositoryProtocol

	// MARK: - Private

	private var savedIDs: Set<String> = []

	// MARK: - Internal Variables

	var errorMessage: String?
	var isReady = false
	var isUpdating = false
	var preferences = AppPreferences()
	var savedArticles: [SavedArticle] = []
	var sources: [FeedSource] = []
	var storageAvailable = true

	// MARK: - Life Cycle

	init(
		feeds: any FeedRepositoryProtocol,
		saved: any SavedRepositoryProtocol,
		preferences: any PreferencesRepositoryProtocol
	) {
		self.feeds = feeds
		savedRepository = saved
		preferencesRepository = preferences
	}
}

// MARK: - Internal Methods

extension AppState {

	func isSaved(_ article: Article) -> Bool {
		savedIDs.contains(article.id)
	}

	func start() async {
		do {
			savedArticles = try await savedRepository.load()
			savedIDs = Set(savedArticles.map(\.id))
		} catch {
			storageAvailable = false
			errorMessage = String(localized: "error.startup")
		}

		do {
			preferences = try await preferencesRepository.load()
		} catch {
			storageAvailable = false
			errorMessage = String(localized: "error.startup")
		}

		do {
			sources = try await feeds.sources()
		} catch {
			errorMessage = String(localized: "error.sources")
		}

		isReady = true
	}

	func toggleSaved(_ article: Article) async {
		guard storageAvailable, !isUpdating else {
			return
		}

		isUpdating = true

		defer { isUpdating = false }

		let wasSaved = isSaved(article)

		do {
			savedArticles = try await savedRepository.setSaved(
				article,
				saved: !wasSaved
			)
			savedIDs = Set(savedArticles.map(\.id))
			AnalyticsService.log(wasSaved ? .articleRemoved : .articleSaved)
			HapticFeedback.success()
		} catch {
			errorMessage = String(localized: "error.save")
			HapticFeedback.error()
		}
	}

	func updatePreferences(_ value: AppPreferences) async {
		guard storageAvailable, !isUpdating, value != preferences else {
			return
		}

		isUpdating = true

		defer { isUpdating = false }

		do {
			try await preferencesRepository.save(value)
			preferences = value
			AnalyticsService.log(.settingsChanged)
			HapticFeedback.success()
		} catch {
			errorMessage = String(localized: "error.preferences")
			HapticFeedback.error()
		}
	}
}
