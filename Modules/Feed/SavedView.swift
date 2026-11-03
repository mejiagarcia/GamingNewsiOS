import SwiftUI

// MARK: - Saved articles

struct SavedView: View {

	// MARK: - Internal Constants

	let state: AppState
	let navigation: any AppNavigationProtocol

	// MARK: - Private Properties

	@State
	private var query = ""

	@State
	private var articles: [Article] = []
	private let filter = ArticleFilter()

	// MARK: - View

	var body: some View {
		List {
			if !state.isReady {
				ProgressView().frame(maxWidth: .infinity).padding()
			} else if articles.isEmpty {
				ContentUnavailableView(
					query.isEmpty ? "saved.empty" : "search.empty",
					systemImage: "bookmark"
				)
			} else {
				ForEach(articles) { article in
					ArticleRow(
						article: article,
						isSaved: true,
						showImages: state.preferences.showImages,
						isUpdating: state.isUpdating,
						onAction: { action in
							ArticleActionHandler(
								state: state,
								navigation: navigation
							).handle(
								action,
								article: article
							)
						}
					)
				}
			}
		}
		.navigationTitle(Text("tab.saved"))
		.searchable(
			text: $query,
			prompt: Text("search.prompt")
		)
		.toolbar {
			ToolbarItem(placement: .topBarTrailing) {
				Button(
					"settings.title",
					systemImage: "gearshape"
				) { navigation.showSettings() }
			}
		}
		.task(
			id: SavedFilterKey(
				query: query,
				saved: state.savedArticles
			)
		) {
			let result = await filter.filter(
				state.savedArticles.map(\.article),
				query: query
			)
			guard !Task.isCancelled else {
				return
			}

			articles = result
		}
		.alert(
			"error.title",
			isPresented: Binding(
				get: { state.errorMessage != nil },
				set: { if !$0 { state.errorMessage = nil } }
			)
		) {
			Button(
				"common.ok",
				role: .cancel
			) {}
		} message: {
			Text(verbatim: state.errorMessage ?? "")
		}
	}
}

private struct SavedFilterKey: Equatable {
	let query: String
	let saved: [SavedArticle]
}
