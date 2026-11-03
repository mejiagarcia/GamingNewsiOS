import UIKit

@MainActor
enum HapticFeedback {

	static func error() {
		UINotificationFeedbackGenerator().notificationOccurred(.error)
	}

	static func success() {
		UISelectionFeedbackGenerator().selectionChanged()
	}
}
