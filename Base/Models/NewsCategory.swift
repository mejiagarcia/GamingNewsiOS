import Foundation

nonisolated enum NewsCategory: String, Codable, CaseIterable, Identifiable, Sendable {
	case all, sony, microsoft, nintendo, pc
	var id: String {
		rawValue
	}
}
