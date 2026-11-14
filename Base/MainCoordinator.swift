import SafariServices
import SwiftUI
import UIKit

@MainActor
final class MainCoordinator: AppNavigationProtocol {

	// MARK: - Private Constants

	private let state: AppState
	private let tabs = EditorialTabController()
	private let window: UIWindow

	// MARK: - Private Variables

	private lazy var navigation = NavigationProxy(coordinator: self)
	private weak var articleOpenModeSheet: UIViewController?
	private var presentingController: UIViewController? {
		selectedNavigation?.visibleViewController
	}

	private var selectedNavigation: UINavigationController? {
		tabs.selectedViewController as? UINavigationController
	}

	// MARK: - Life Cycle

	init(window: UIWindow) {
		self.window = window
		let store = LocalStore()
		state = AppState(
			feeds: LiveFeedRepository(),
			saved: store,
			preferences: store
		)
	}
}

// MARK: - Internal Methods

extension MainCoordinator {

	func copy(_ article: Article) {
		UIPasteboard.general.url = article.url
		AnalyticsService.log(.articleCopied)
		HapticFeedback.success()
	}

	func goBack() {
		selectedNavigation?.popViewController(animated: true)
	}

	func open(_ article: Article) {
		AnalyticsService.log(.articleOpened)
		presentingController?.present(
			SFSafariViewController(url: article.url),
			animated: true
		)
	}

	func openReader(_ article: Article) {
		AnalyticsService.log(.articleOpened)
		let screen = ReaderView(
			article: article,
			showImages: state.preferences.showImages,
			navigation: navigation,
			onOpenInBrowser: { [weak self] in self?.open(article) }
		)
		selectedNavigation?.pushViewController(
			tabs.host(screen),
			animated: true
		)
	}

	func chooseArticleOpenMode(for article: Article) {
		let controller = UIHostingController(
			rootView: ArticleOpenModeSheet { [weak self] mode in
				self?.selectArticleOpenMode(mode, for: article)
			}
		)
		controller.modalPresentationStyle = .pageSheet

		if let sheet = controller.sheetPresentationController {
			sheet.detents = [.medium(), .large()]
			sheet.prefersGrabberVisible = true
		}

		articleOpenModeSheet = controller
		presentingController?.present(controller, animated: true)
	}

	func openExternally(_ article: Article) {
		AnalyticsService.log(.articleOpenedExternally)
		UIApplication.shared.open(article.url)
	}

	func share(_ article: Article) {
		AnalyticsService.log(.articleShareOpened)

		let controller = UIActivityViewController(
			activityItems: [article.url],
			applicationActivities: nil
		)

		if let popover = controller.popoverPresentationController {
			popover.sourceView = presentingController?.view
			popover.sourceRect = CGRect(
				x: presentingController?.view.bounds.midX ?? CGFloat.zero,
				y: presentingController?.view.bounds.midY ?? CGFloat.zero,
				width: 1,
				height: 1
			)
		}

		presentingController?.present(
			controller,
			animated: true
		)
	}

	func showSettings() {
		let screen = SettingsView(
			state: state,
			navigation: navigation,
			notifications: PushNotificationService.shared,
			onAppearanceChange: { [weak self] in self?.applyAppearance() }
		)

		selectedNavigation?.pushViewController(
			tabs.host(screen),
			animated: true
		)
	}

	func showSourceList(
		_ sources: [FeedSource],
		title: LocalizedStringKey
	) {
		selectedNavigation?.pushViewController(
			tabs.host(
				SourceListView(
					state: state,
					onBack: navigation.goBack,
					sources: sources,
					title: title
				)
			),
			animated: true
		)
	}

	func showSources() {
		selectedNavigation?.pushViewController(
			tabs.host(
				SourceSettingsView(
					state: state,
					navigation: navigation
				)
			),
			animated: true
		)
	}

	func showMutedHeadlines() {
		selectedNavigation?.pushViewController(
			tabs.host(MutedHeadlinesView(state: state, onBack: navigation.goBack)),
			animated: true
		)
	}

	func start() {
		let news = FeedViewModel(
			kind: .news,
			repository: state.feeds
		)
		let reviews = FeedViewModel(
			kind: .reviews,
			repository: state.feeds
		)

		let controllers: [EditorialTab: UIViewController] = [
			.news: tabs.host(
				FeedView(
					model: news,
					notifications: PushNotificationService.shared,
					state: state,
					navigation: navigation
				)
			),
			.reviews: tabs.host(
				FeedView(
					model: reviews,
					notifications: PushNotificationService.shared,
					state: state,
					navigation: navigation
				)
			),
			.releases: tabs.host(
				ReleasesView(
					model: ReleasesViewModel(repository: LiveIGDBReleasesRepository()),
					navigation: navigation
				)
			),
			.saved: tabs.host(
				SavedView(
					state: state,
					navigation: navigation
				)
			),
		]

		tabs.viewControllers = EditorialTab.allCases.compactMap { tab in
			controllers[tab].map { EditorialNavigationController(rootViewController: $0) }
		}

		window.tintColor = UIColor(named: "AccentColor")
		window.rootViewController = tabs
		window.makeKeyAndVisible()

		Task {
			await state.start()
			applyAppearance()
		}
	}
}

// MARK: - Private Methods

private extension MainCoordinator {
	func selectArticleOpenMode(
		_ mode: ArticleOpenMode,
		for article: Article
	) {
		guard let sheet = articleOpenModeSheet else { return }
		articleOpenModeSheet = nil

		Task {
			var preferences = state.preferences
			preferences.articleOpenMode = mode
			await state.updatePreferences(preferences)
			sheet.dismiss(animated: true) { [weak self] in
				self?.open(article, using: mode)
			}
		}
	}

	func open(
		_ article: Article,
		using mode: ArticleOpenMode
	) {
		switch mode {
			case .original:
				open(article)
			case .reader:
				openReader(article)
		}
	}
}

// MARK: - Private Methods

extension MainCoordinator {

	private func applyAppearance() {
		switch state.preferences.appearance {
			case .system: window.overrideUserInterfaceStyle = .unspecified
			case .light: window.overrideUserInterfaceStyle = .light
			case .dark: window.overrideUserInterfaceStyle = .dark
		}
	}
}
