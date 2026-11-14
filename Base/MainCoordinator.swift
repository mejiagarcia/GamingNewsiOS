import SafariServices
import SwiftUI
import UIKit

@MainActor
final class MainCoordinator: AppNavigationProtocol {

	// MARK: - Private Constants

	private let state: AppState
	private let tabs = UITabBarController()
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
			UIHostingController(rootView: screen),
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
			sheet.detents = [.medium()]
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
			UIHostingController(rootView: screen),
			animated: true
		)
	}

	func showSourceList(
		_ sources: [FeedSource],
		title: LocalizedStringKey
	) {
		selectedNavigation?.pushViewController(
			UIHostingController(
				rootView: SourceListView(
					state: state,
					sources: sources,
					title: title
				)
			),
			animated: true
		)
	}

	func showSources() {
		selectedNavigation?.pushViewController(
			UIHostingController(
				rootView: SourceSettingsView(
					state: state,
					navigation: navigation
				)
			),
			animated: true
		)
	}

	func showMutedHeadlines() {
		selectedNavigation?.pushViewController(
			UIHostingController(rootView: MutedHeadlinesView(state: state)),
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

		let controllers: [(UIViewController, String, String)] = [
				(
					UIHostingController(
						rootView: FeedView(
							model: news,
							state: state,
							navigation: navigation
						)
					),
					String(localized: "tab.news"),
					"newspaper"
				),
				(
					UIHostingController(
						rootView: FeedView(
							model: reviews,
							state: state,
							navigation: navigation
						)
					),
					String(localized: "tab.reviews"),
					"star.bubble"
				),
				(
					UIHostingController(
						rootView: ReleasesView(
							model: ReleasesViewModel(
								repository: LiveIGDBReleasesRepository()
							),
							navigation: navigation
						)
					),
					String(localized: "tab.releases"),
					"calendar"
				),
				(
					UIHostingController(
						rootView: SavedView(
							state: state,
							navigation: navigation
						)
					),
					String(localized: "tab.saved"),
					"bookmark"
				)
			]

		tabs.viewControllers = controllers.map { controller, title, image in
			let navigation = UINavigationController(rootViewController: controller)
			styleNavigationBar(navigation.navigationBar)
			navigation.tabBarItem = UITabBarItem(
				title: title,
				image: UIImage(systemName: image),
				selectedImage: nil
			)

			return navigation
		}

		styleTabBar(tabs.tabBar)
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

	private func styleNavigationBar(_ bar: UINavigationBar) {
		let appearance = UINavigationBarAppearance()
		appearance.configureWithOpaqueBackground()
		appearance.backgroundColor = UIColor(named: "EditorialCanvas")
		appearance.shadowColor = UIColor(named: "EditorialOutline")

		bar.standardAppearance = appearance
		bar.scrollEdgeAppearance = appearance
		bar.compactAppearance = appearance
	}

	private func styleTabBar(_ bar: UITabBar) {
		let appearance = UITabBarAppearance()
		appearance.configureWithOpaqueBackground()
		appearance.backgroundColor = UIColor(named: "EditorialInk")
		appearance.shadowColor = UIColor(named: "EditorialOutline")

		let normalColor = UIColor(named: "EditorialOnBanner") ?? .label
		let selectedColor = UIColor(named: "EditorialGold") ?? normalColor
		let layouts = [
			appearance.stackedLayoutAppearance,
			appearance.inlineLayoutAppearance,
			appearance.compactInlineLayoutAppearance,
		]

		for layout in layouts {
			layout.normal.iconColor = normalColor
			layout.normal.titleTextAttributes = [.foregroundColor: normalColor]
			layout.selected.iconColor = selectedColor
			layout.selected.titleTextAttributes = [.foregroundColor: selectedColor]
		}

		bar.standardAppearance = appearance
		bar.scrollEdgeAppearance = appearance
		bar.tintColor = UIColor(named: "EditorialGold")
	}
}
