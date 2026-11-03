import Foundation

nonisolated protocol PreferencesRepositoryProtocol: Sendable {
	func load() async throws -> AppPreferences
	func save(_ preferences: AppPreferences) async throws
}
