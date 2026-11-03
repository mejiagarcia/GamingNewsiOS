import SwiftUI

extension AppAppearance {
	var title: LocalizedStringKey {
		switch self {
			case .system: "settings.system"
			case .light: "settings.light"
			case .dark: "settings.dark"
		}
	}
}
