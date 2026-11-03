import SwiftUI

extension ContentLanguage {
	var title: LocalizedStringKey {
		switch self {
			case .system: "settings.system"
			case .en: "language.english"
			case .es: "language.spanish"
		}
	}
}
