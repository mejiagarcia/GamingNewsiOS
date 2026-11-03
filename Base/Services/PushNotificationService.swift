import Observation
import UIKit
import UserNotifications

@MainActor
@Observable
final class PushNotificationService {

	// MARK: - Internal Constants

	static let shared = PushNotificationService()

	// MARK: - Private Constants

	private let delegate = PushNotificationDelegate()

	// MARK: - Internal Variables

	private(set) var authorizationStatus: UNAuthorizationStatus = .notDetermined
	private(set) var isUpdating = false

	// MARK: - Life Cycle

	private init() {}
}

// MARK: - Internal Methods

extension PushNotificationService {

	func configure() {
		UNUserNotificationCenter.current().delegate = delegate
	}

	func refresh() async {
		let settings = await UNUserNotificationCenter.current().notificationSettings()
		authorizationStatus = settings.authorizationStatus

		if [.authorized, .provisional, .ephemeral].contains(settings.authorizationStatus) {
			UIApplication.shared.registerForRemoteNotifications()
		}
	}

	func requestOrOpenSettings() async throws {
		guard !isUpdating else {
			return
		}

		isUpdating = true

		defer { isUpdating = false }

		if authorizationStatus == .notDetermined {
			let granted = try await UNUserNotificationCenter.current().requestAuthorization(
				options: [.alert, .badge, .sound]
			)

			await refresh()
			AnalyticsService.log(.notificationPermission)

			if granted {
				HapticFeedback.success()
			}
		} else if let url = URL(string: UIApplication.openSettingsURLString) {
			_ = await UIApplication.shared.open(url)
		}
	}
}
