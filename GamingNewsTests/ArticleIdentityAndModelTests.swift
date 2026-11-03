import Foundation
import Testing

@testable import GamingNews

struct ArticleIdentityAndModelTests {
	@Test(arguments: [
		("HTTP://Example.COM:80/story?id=1#section", "http://example.com/story?id=1"),
		("https://EXAMPLE.com:443/story", "https://example.com/story"),
		("https://example.com:8443/story#part", "https://example.com:8443/story"),
	])
	func articleIdentityCanonicalizesURLs(_ rawURL: String, _ expected: String) throws {
		let url = try #require(URL(string: rawURL))

		#expect(ArticleIdentity.make(url) == expected)
	}

	@Test(arguments: ["file:///story", "mailto:news@example.com", "https:///missing-host"])
	func articleIdentityRejectsUnsupportedOrHostlessURLs(_ rawURL: String) throws {
		let url = try #require(URL(string: rawURL))

		#expect(ArticleIdentity.make(url) == nil)
	}

	@Test(arguments: [
		(AppAppearance.system, "system"),
		(AppAppearance.light, "light"),
		(AppAppearance.dark, "dark"),
	])
	func appearanceRawValuesAreStable(_ value: AppAppearance, _ rawValue: String) {
		#expect(value.rawValue == rawValue)
		#expect(value.id == rawValue)
	}

	@Test(arguments: [
		(ContentLanguage.en, FeedLanguage.en),
		(ContentLanguage.es, FeedLanguage.es),
	])
	func explicitContentLanguageResolvesDeterministically(
		_ language: ContentLanguage,
		_ expected: FeedLanguage
	) {
		#expect(language.resolved == expected)
	}

	@Test func preferencesEncodeAndDecode() throws {
		let preferences = AppPreferences(
			language: .es,
			appearance: .dark,
			showImages: false,
			disabledSourceIDs: ["source-a", "source-b"]
		)
		let data = try JSONEncoder().encode(preferences)
		let decoded = try JSONDecoder().decode(AppPreferences.self, from: data)

		#expect(decoded == preferences)
	}
}
