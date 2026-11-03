import Foundation

// MARK: - Versioned persistence

nonisolated private struct StoreFile<Value: Codable & Sendable>: Codable, Sendable {
	let version: Int
	let value: Value
}

nonisolated enum StoreError: Error {
	case unsupportedVersion
	case noApplicationSupport
}

actor LocalStore: SavedRepositoryProtocol, PreferencesRepositoryProtocol {

	// MARK: - Private Constants

	private let directory: URL?

	// MARK: - Private Variables

	private var preferences: AppPreferences?
	private var saved: [SavedArticle]?

	// MARK: - Life Cycle

	init() {
		let base = FileManager.default.urls(
			for: .applicationSupportDirectory,
			in: .userDomainMask
		).first
		directory = base?.appendingPathComponent(
			"GamingNews",
			isDirectory: true
		)
	}
}

// MARK: - Internal Methods

extension LocalStore {

	func load() throws -> [SavedArticle] {
		if let saved {
			return saved
		}

		let result: [SavedArticle] = (try read("saved.json") ?? []).sorted { $0.savedAt > $1.savedAt }
		saved = result

		return result
	}

	func load() throws -> AppPreferences {
		if let preferences {
			return preferences
		}

		let result: AppPreferences = try read("preferences.json") ?? AppPreferences()
		preferences = result

		return result
	}

	func save(_ value: AppPreferences) throws {
		try write(
			value,
			to: "preferences.json"
		)
		preferences = value
	}

	func setSaved(
		_ article: Article,
		saved shouldSave: Bool
	) throws -> [SavedArticle] {
		var result: [SavedArticle] = try load()
		result.removeAll { $0.id == article.id }

		if shouldSave {
			result.insert(
				SavedArticle(
					article: article,
					savedAt: Date()
				),
				at: Int.zero
			)
		}
		try write(
			result,
			to: "saved.json"
		)
		saved = result

		return result
	}
}

// MARK: - Private Methods

extension LocalStore {

	private func read<Value: Codable & Sendable>(_ name: String) throws -> Value? {
		guard let directory else {
			throw StoreError.noApplicationSupport
		}

		let url = directory.appendingPathComponent(name)

		guard FileManager.default.fileExists(atPath: url.path) else {
			return nil
		}

		let file = try JSONDecoder().decode(
			StoreFile<Value>.self,
			from: Data(contentsOf: url)
		)

		guard file.version == 1 else {
			throw StoreError.unsupportedVersion
		}

		return file.value
	}

	private func write<Value: Codable & Sendable>(
		_ value: Value,
		to name: String
	) throws {
		guard let directory else {
			throw StoreError.noApplicationSupport
		}

		try FileManager.default.createDirectory(
			at: directory,
			withIntermediateDirectories: true
		)
		let data = try JSONEncoder().encode(
			StoreFile(
				version: 1,
				value: value
			)
		)
		try data.write(
			to: directory.appendingPathComponent(name),
			options: .atomic
		)
	}
}
