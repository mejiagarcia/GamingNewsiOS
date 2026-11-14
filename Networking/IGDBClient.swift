import Foundation

nonisolated private struct IGDBTokenResponse: Decodable, Sendable {
	let accessToken: String
	let expiresIn: Int

	enum CodingKeys: String, CodingKey {
		case accessToken = "access_token"
		case expiresIn = "expires_in"
	}
}

nonisolated private struct IGDBReleaseResponse: Decodable, Sendable {
	let id: Int
	let date: Int?
	let human: String?
	let dateFormat: Int?
	let platform: Int
	let game: Game?

	nonisolated struct Game: Decodable, Sendable {
		let id: Int
		let name: String?
		let url: String?
		let cover: Cover?
	}

	nonisolated struct Cover: Decodable, Sendable {
		let url: String?
	}

	enum CodingKeys: String, CodingKey {
		case id, date, human, platform, game
		case dateFormat = "date_format"
	}
}

nonisolated struct IGDBReleasePage: Sendable {
	let records: [GameReleaseRecord]
	let resultCount: Int
}

nonisolated enum IGDBClientError: Error, Equatable, Sendable {
	case credentialsMissing
	case invalidResponse
}

actor IGDBClient {
	private let clientID: String
	private let clientSecret: String
	private var accessToken: String?
	private var tokenExpiresAt = Date.distantPast

	init(
		clientID: String,
		clientSecret: String
	) {
		self.clientID = clientID
		self.clientSecret = clientSecret
	}

	func fetchPage(offset: Int) async throws -> IGDBReleasePage {
		let platformIDs = GamePlatform.supported.map(\.id).sorted().map(String.init).joined(separator: ",")
		let range = Self.upcomingWindow()
		let query = """
		fields id,date,human,date_format,platform,game.id,game.name,game.url,game.cover.url;
		where platform = (\(platformIDs)) & date >= \(range.start) & date <= \(range.end);
		sort date asc;
		limit 50;
		offset \(offset);
		"""
		guard let endpoint = URL(string: "https://api.igdb.com/v4/release_dates") else {
			throw IGDBClientError.invalidResponse
		}
		var request = URLRequest(url: endpoint)
		request.httpMethod = "POST"
		request.httpBody = Data(query.utf8)
		request.setValue("application/json", forHTTPHeaderField: "Accept")
		request.setValue("text/plain", forHTTPHeaderField: "Content-Type")
		let (data, response) = try await execute(request)
		let releases = try JSONDecoder().decode([IGDBReleaseResponse].self, from: data)
		return IGDBReleasePage(
			records: releases.compactMap(Self.record(from:)),
			resultCount: releases.count
		)
	}
}

private extension IGDBClient {
	func validAccessToken() async throws -> String {
		if let accessToken, tokenExpiresAt > Date() {
			return accessToken
		}
		guard !clientID.isEmpty, !clientSecret.isEmpty,
			!clientID.hasPrefix("$("), !clientSecret.hasPrefix("$(") else {
			throw IGDBClientError.credentialsMissing
		}
		guard var components = URLComponents(string: "https://id.twitch.tv/oauth2/token") else {
			throw IGDBClientError.invalidResponse
		}
		components.queryItems = [
			URLQueryItem(name: "client_id", value: clientID),
			URLQueryItem(name: "client_secret", value: clientSecret),
			URLQueryItem(name: "grant_type", value: "client_credentials")
		]
		guard let url = components.url else {
			throw IGDBClientError.invalidResponse
		}
		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		let (data, response) = try await URLSession.shared.data(for: request)
		guard let response = response as? HTTPURLResponse, (200..<300).contains(response.statusCode) else {
			throw IGDBClientError.invalidResponse
		}
		let token = try JSONDecoder().decode(IGDBTokenResponse.self, from: data)
		accessToken = token.accessToken
		tokenExpiresAt = Date().addingTimeInterval(TimeInterval(token.expiresIn - 120))
		return token.accessToken
	}

	func execute(_ originalRequest: URLRequest) async throws -> (Data, URLResponse) {
		let token = try await validAccessToken()
		var request = originalRequest
		request.setValue(clientID, forHTTPHeaderField: "Client-ID")
		request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
		let (data, response) = try await URLSession.shared.data(for: request)
		guard let httpResponse = response as? HTTPURLResponse else {
			throw IGDBClientError.invalidResponse
		}
		guard httpResponse.statusCode == 401 else {
			guard (200..<300).contains(httpResponse.statusCode) else {
				throw IGDBClientError.invalidResponse
			}
			return (data, response)
		}
		accessToken = nil
		tokenExpiresAt = .distantPast
		let replacement = try await validAccessToken()
		request.setValue("Bearer \(replacement)", forHTTPHeaderField: "Authorization")
		let (retryData, retryResponse) = try await URLSession.shared.data(for: request)
		guard let retryHTTPResponse = retryResponse as? HTTPURLResponse,
			(200..<300).contains(retryHTTPResponse.statusCode) else {
			throw IGDBClientError.invalidResponse
		}
		return (retryData, retryResponse)
	}

	static func record(from response: IGDBReleaseResponse) -> GameReleaseRecord? {
		guard let game = response.game, let name = game.name, let timestamp = response.date else {
			return nil
		}
		let cover = game.cover?.url.flatMap { rawValue -> URL? in
			let urlValue = rawValue.hasPrefix("//") ? "https:\(rawValue)" : rawValue
			return URL(string: urlValue.replacingOccurrences(of: "t_thumb", with: "t_cover_small"))
		}
		return GameReleaseRecord(
			id: response.id,
			gameID: game.id,
			platformID: response.platform,
			name: name,
			coverURL: cover,
			releaseDate: Date(timeIntervalSince1970: TimeInterval(timestamp)),
			gameURL: game.url.flatMap(URL.init(string:)),
			hasExactDate: response.dateFormat == Int.zero,
			humanDate: response.human
		)
	}

	static func upcomingWindow(now: Date = Date()) -> (start: Int, end: Int) {
		let calendar = Calendar.gamingNewsUTC
		let today = calendar.startOfDay(for: now)
		let yearEnd = calendar.date(from: DateComponents(year: calendar.component(.year, from: today), month: 12, day: 31, hour: 23, minute: 59, second: 59)) ?? today
		let monthsAhead = calendar.date(byAdding: .month, value: 8, to: now) ?? yearEnd
		return (Int(today.timeIntervalSince1970), Int(min(yearEnd, monthsAhead).timeIntervalSince1970))
	}
}
