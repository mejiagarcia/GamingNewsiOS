import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

	// MARK: - Private Variables

	private var coordinator: MainCoordinator?

	// MARK: - Internal Variables

	var window: UIWindow?
}

// MARK: - Internal Methods

extension SceneDelegate {

	func scene(
		_ scene: UIScene,
		willConnectTo session: UISceneSession,
		options connectionOptions: UIScene.ConnectionOptions
	) {
		guard let scene = scene as? UIWindowScene else {
			return
		}

		let window = UIWindow(windowScene: scene)
		let coordinator = MainCoordinator(window: window)

		self.window = window
		self.coordinator = coordinator
		coordinator.start()
	}
}
