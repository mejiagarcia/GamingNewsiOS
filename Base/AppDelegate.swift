import FirebaseAnalytics
import FirebaseCore
import FirebaseMessaging
import OSLog
import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {

	func application(
		_ application: UIApplication,
		didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
	) -> Bool {
		FirebaseApp.configure()
		Analytics.setAnalyticsCollectionEnabled(true)
		PushNotificationService.shared.configure()

		Task {
			await PushNotificationService.shared.refresh()
		}

		return true
	}

	func application(
		_ application: UIApplication,
		didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
	) {
		Messaging.messaging().apnsToken = deviceToken
	}

	func application(
		_ application: UIApplication,
		didFailToRegisterForRemoteNotificationsWithError error: Error
	) {
		Logger(
			subsystem: Bundle.main.bundleIdentifier ?? "GamingNews",
			category: "PushNotifications"
		).error("APNs registration failed: \(error.localizedDescription, privacy: .public)")
	}
}
