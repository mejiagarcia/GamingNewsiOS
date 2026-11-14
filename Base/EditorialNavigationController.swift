import UIKit

@MainActor
final class EditorialNavigationController: UINavigationController {
	override func viewDidLoad() {
		super.viewDidLoad()

		setNavigationBarHidden(true, animated: false)
		interactivePopGestureRecognizer?.delegate = self
	}
}

extension EditorialNavigationController: UIGestureRecognizerDelegate {
	func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
		viewControllers.count > 1 && transitionCoordinator == nil
	}
}
