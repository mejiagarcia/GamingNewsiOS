import Foundation
import UserNotifications

nonisolated final class PushNotificationDelegate: NSObject {}

nonisolated extension PushNotificationDelegate: UNUserNotificationCenterDelegate {

	func userNotificationCenter(
		_ center: UNUserNotificationCenter,
		willPresent notification: UNNotification
	) async -> UNNotificationPresentationOptions {
		[.banner, .sound, .badge]
	}
}
