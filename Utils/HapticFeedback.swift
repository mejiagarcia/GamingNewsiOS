import UIKit

enum ButtonHapticLevel: Sendable {
	case firm
	case light
	case selection
	case warning
}

@MainActor
enum HapticFeedback {

	static func error() {
		UINotificationFeedbackGenerator().notificationOccurred(.error)
	}

	static func buttonPress(_ level: ButtonHapticLevel) {
		switch level {
			case .firm:
				UIImpactFeedbackGenerator(style: .medium).impactOccurred()
			case .light:
				UIImpactFeedbackGenerator(style: .light).impactOccurred()
			case .selection:
				UISelectionFeedbackGenerator().selectionChanged()
			case .warning:
				UINotificationFeedbackGenerator().notificationOccurred(.warning)
		}
	}

	static func success() {
		UISelectionFeedbackGenerator().selectionChanged()
	}
}
