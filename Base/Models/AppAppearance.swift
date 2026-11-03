import Foundation

nonisolated enum AppAppearance: String, Codable, CaseIterable, Identifiable, Sendable {
	case system, light, dark
	var id: String {
		rawValue
	}
}
