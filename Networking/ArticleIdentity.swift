import Foundation

nonisolated enum ArticleIdentity {

	static func make(_ url: URL) -> String? {
		guard
			var parts = URLComponents(
				url: url,
				resolvingAgainstBaseURL: false
			),
			let scheme = parts.scheme?.lowercased(), ["http", "https"].contains(scheme),
			let host = parts.host?.lowercased(), !host.isEmpty
		else {
			return nil
		}
		parts.scheme = scheme
		parts.host = host
		parts.fragment = nil

		if (scheme == "http" && parts.port == 80) || (scheme == "https" && parts.port == 443) {
			parts.port = nil
		}

		return parts.string
	}
}
