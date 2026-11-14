import SwiftUI
import UIKit

@MainActor
final class EditorialTabController: UITabBarController {
	private lazy var bar = UIHostingController(rootView: tabBarContent())
	private var isCompact = false

	override func viewDidLoad() {
		super.viewDidLoad()

		setTabBarHidden(true, animated: false)
		bar.sizingOptions = .intrinsicContentSize

		addChild(bar)
		view.addSubview(bar.view)
		bar.view.backgroundColor = .clear
		bar.view.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			bar.view.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
			bar.view.bottomAnchor.constraint(
				equalTo: view.safeAreaLayoutGuide.bottomAnchor,
				constant: -DesignSystem.Spacing.compact
			),
		])
		bar.didMove(toParent: self)
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		view.bringSubviewToFront(bar.view)

		let inset = DesignSystem.Size.expandedTabHeight + DesignSystem.Spacing.compact * 3
		for controller in viewControllers ?? [] where controller.additionalSafeAreaInsets.bottom != inset {
			controller.additionalSafeAreaInsets.bottom = inset
		}
	}

	func host<Content: View>(_ content: Content) -> UIViewController {
		UIHostingController(
			rootView: content.environment(\.setEditorialTabCompact) { [weak self] isCompact in
				guard let self, self.isCompact != isCompact else { return }

				self.isCompact = isCompact
				bar.rootView = tabBarContent()
			}
		)
	}

	private func tabBarContent() -> EditorialTabBar {
		EditorialTabBar(
			selected: EditorialTab(rawValue: selectedIndex) ?? .news,
			isCompact: isCompact
		) { [weak self] tab in
			guard let self, selectedIndex != tab.rawValue else { return }

			selectedIndex = tab.rawValue
			bar.rootView = tabBarContent()
		}
	}
}
