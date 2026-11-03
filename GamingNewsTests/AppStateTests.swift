import Testing

@testable import GamingNews

struct AppStateTests {
	@Test @MainActor func loadsRepositoriesAndTogglesSavedArticle() async {
		let article = TestFixtures.article(id: "saved", title: "Saved")
		let saved = StubSavedRepository()
		let state = AppState(
			feeds: StubFeedRepository(),
			saved: saved,
			preferences: StubPreferencesRepository(value: AppPreferences(language: .es))
		)

		await state.start()
		#expect(state.isReady)
		#expect(state.preferences.language == .es)
		#expect(state.storageAvailable)

		await state.toggleSaved(article)
		#expect(state.isSaved(article))
		#expect(state.savedArticles.map(\.id) == [article.id])

		await state.toggleSaved(article)
		#expect(!state.isSaved(article))
		#expect(state.savedArticles.isEmpty)
	}

	@Test @MainActor func persistsPreferencesAfterSuccessfulSave() async {
		let preferences = StubPreferencesRepository()
		let state = AppState(
			feeds: StubFeedRepository(),
			saved: StubSavedRepository(),
			preferences: preferences
		)
		await state.start()
		let updated = AppPreferences(language: .es, appearance: .dark)

		await state.updatePreferences(updated)
		#expect(state.preferences == updated)
		#expect(await preferences.value == updated)
	}
}
