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
			EditorialFilterStrip {
				EditorialField(prompt: "search.prompt", text: $query, isSearch: true)
					.padding(DesignSystem.Spacing.regular)
			}

			if !state.isReady {
				ProgressView().frame(maxWidth: .infinity).padding()
			} else if articles.isEmpty {
				ContentUnavailableView {
					EditorialLabel(title: query.isEmpty ? "saved.empty" : "search.empty", glyph: .saved)
				}
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
					.editorialCardRow()
				}
			}
		}
		.editorialList()
		.onAppear { AnalyticsService.screen("saved") }
		.onSubmit(of: .text) {
			if !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
				AnalyticsService.log(.searchSubmitted)
			}
		}
		.editorialScrollingHeader {
			EditorialHeader(title: "tab.saved") {
				Button {
					navigation.showSettings()
				} label: {
					EditorialGlyph.filters.view
				}
				.buttonStyle(EditorialButtonStyle(hierarchy: .tertiary))
				.accessibilityLabel(Text("settings.title"))
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
