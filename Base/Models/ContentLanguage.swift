import Foundation

nonisolated enum ContentLanguage: String, Codable, CaseIterable, Identifiable, Sendable {
	case system, en, es
	var id: String {
		rawValue
	}

	var resolved: FeedLanguage {
		switch self {
			case .en: .en
			case .es: .es
			case .system:
				Locale.preferredLanguages.lazy.compactMap { language in
					let code = Locale(identifier: language).language.languageCode?.identifier
					return code.flatMap(FeedLanguage.init(rawValue:))
				}.first ?? .en
		}
	}
}
