import SwiftUI

@MainActor
final class NavigationProxy: AppNavigationProtocol {

	// MARK: - Private Variables

	private weak var coordinator: MainCoordinator?

	// MARK: - Life Cycle

	init(coordinator: MainCoordinator) {
		self.coordinator = coordinator
	}
}

// MARK: - Internal Methods

extension NavigationProxy {

	func copy(_ article: Article) {
		coordinator?.copy(article)
	}

	func open(_ article: Article) {
		coordinator?.open(article)
	}

	func openExternally(_ article: Article) {
		coordinator?.openExternally(article)
	}

	func share(_ article: Article) {
		coordinator?.share(article)
	}

	func showSettings() {
		coordinator?.showSettings()
	}

	func showSourceList(
		_ sources: [FeedSource],
		title: LocalizedStringKey
	) {
		coordinator?.showSourceList(
			sources,
			title: title
		)
	}

	func showSources() {
		coordinator?.showSources()
	}
}
