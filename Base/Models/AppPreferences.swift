import Foundation

nonisolated struct AppPreferences: Codable, Equatable, Sendable {
	var language: ContentLanguage = .system
	var appearance: AppAppearance = .system
	var showImages = true
	var disabledSourceIDs: Set<String> = []
}
