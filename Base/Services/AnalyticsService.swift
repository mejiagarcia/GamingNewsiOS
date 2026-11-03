import FirebaseAnalytics

@MainActor
enum AnalyticsService {

	enum Event: String, Sendable {
		case articleCopied = "article_copied"
		case articleOpened = "article_opened"
		case articleOpenedExternally = "article_opened_externally"
		case articleRemoved = "article_removed"
		case articleSaved = "article_saved"
		case articleShareOpened = "article_share_opened"
		case categoryChanged = "category_changed"
		case feedRefreshed = "feed_refreshed"
		case notificationPermission = "notification_permission"
		case searchSubmitted = "search_submitted"
		case settingsChanged = "settings_changed"
	}

	static func log(_ event: Event) {
		Analytics.logEvent(
			event.rawValue,
			parameters: nil
		)
	}

	static func screen(_ name: String) {
		Analytics.logEvent(
			AnalyticsEventScreenView,
			parameters: [AnalyticsParameterScreenName: name]
		)
	}
}
