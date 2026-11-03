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
			navigation.tabBarItem = UITabBarItem(
				title: title,
				image: UIImage(systemName: image),
				selectedImage: nil
			)

			return navigation
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

extension MainCoordinator {

	private func applyAppearance() {
		switch state.preferences.appearance {
			case .system: window.overrideUserInterfaceStyle = .unspecified
			case .light: window.overrideUserInterfaceStyle = .light
			case .dark: window.overrideUserInterfaceStyle = .dark
		}
	}
}
