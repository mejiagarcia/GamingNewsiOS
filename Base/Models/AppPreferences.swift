import Foundation

nonisolated struct AppPreferences: Codable, Equatable, Sendable {
	var language: ContentLanguage = .system
	var appearance: AppAppearance = .system
	var articleOpenMode: ArticleOpenMode?
	var showImages = true
	var disabledSourceIDs: Set<String> = []
	var mutedHeadlineRules: [MutedHeadlineRule] = []
	var applyGlobalMuteRulesToReviews = false

	private enum CodingKeys: String, CodingKey {
		case language, appearance, articleOpenMode, showImages, disabledSourceIDs
		case mutedHeadlineRules, applyGlobalMuteRulesToReviews
	}

	init(
		language: ContentLanguage = .system,
		appearance: AppAppearance = .system,
		articleOpenMode: ArticleOpenMode? = nil,
		showImages: Bool = true,
		disabledSourceIDs: Set<String> = [],
		mutedHeadlineRules: [MutedHeadlineRule] = [],
		applyGlobalMuteRulesToReviews: Bool = false
	) {
		self.language = language
		self.appearance = appearance
		self.articleOpenMode = articleOpenMode
		self.showImages = showImages
		self.disabledSourceIDs = disabledSourceIDs
		self.mutedHeadlineRules = mutedHeadlineRules
		self.applyGlobalMuteRulesToReviews = applyGlobalMuteRulesToReviews
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		language = try values.decodeIfPresent(ContentLanguage.self, forKey: .language) ?? .system
		appearance = try values.decodeIfPresent(AppAppearance.self, forKey: .appearance) ?? .system
		articleOpenMode = try values.decodeIfPresent(ArticleOpenMode.self, forKey: .articleOpenMode)
		showImages = try values.decodeIfPresent(Bool.self, forKey: .showImages) ?? true
		disabledSourceIDs = try values.decodeIfPresent(Set<String>.self, forKey: .disabledSourceIDs) ?? []
		mutedHeadlineRules = try values.decodeIfPresent([MutedHeadlineRule].self, forKey: .mutedHeadlineRules) ?? []
		applyGlobalMuteRulesToReviews = try values.decodeIfPresent(Bool.self, forKey: .applyGlobalMuteRulesToReviews) ?? false
	}
}
