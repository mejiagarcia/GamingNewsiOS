import SwiftUI

// MARK: - News and reviews

struct FeedView: View {

	// MARK: - Internal Properties

	@Bindable
	var model: FeedViewModel
	let state: AppState
	let navigation: any AppNavigationProtocol

	// MARK: - Private Properties

	private var request: FeedRequest {
		FeedRequest(
			context: FeedContext(
				kind: model.kind,
				language: state.preferences.language.resolved,
				category: model.category
			),
			disabled: state.preferences.disabledSourceIDs
		)
	}

	// MARK: - View

	var body: some View {
		List {
			if model.kind == .news {
				Section {
					ScrollView(.horizontal) {
						HStack {
							ForEach(NewsCategory.allCases) { category in
								Button(category.title) {
									if model.category != category {
										model.category = category
										AnalyticsService.log(.categoryChanged)
									}
								}
									.buttonStyle(.bordered)
									.tint(model.category == category ? .accentColor : .secondary)
									.accessibilityAddTraits(model.category == category ? .isSelected : [])
							}
						}
					}
					.scrollIndicators(.hidden)
				}
			}
			if model.partialFailure {
				Section {
					Label(
						model.stale ? "feed.stale" : "feed.partial",
						systemImage: "exclamationmark.triangle"
					)
					.font(.subheadline).foregroundStyle(.secondary)
					Button("feed.retry") {
						Task {
							await model.load(
								request,
								force: true
							)
						}
					}
				}
			}
			if model.isLoading && model.articles.isEmpty {
				ProgressView().frame(maxWidth: .infinity).padding()
			} else if model.noSources {
				ContentUnavailableView {
					Label(
						"feed.noSources",
						systemImage: "line.3.horizontal.decrease.circle"
					)
				} description: {
					Text("feed.noSources.description")
				} actions: {
					Button("settings.title") { navigation.showSettings() }
				}
			} else if model.failed {
				ContentUnavailableView {
					Label(
						"feed.failed",
						systemImage: "wifi.exclamationmark"
					)
				} description: {
					Text("feed.failed.description")
				} actions: {
					Button("feed.retry") {
						Task {
							await model.load(
								request,
								force: true
							)
						}
					}
				}
			} else if model.loaded && model.articles.isEmpty {
				ContentUnavailableView(
					model.query.isEmpty ? "feed.empty" : "search.empty",
					systemImage: "newspaper"
				)
			} else {
				ForEach(model.articles) { article in
					ArticleRow(
						article: article,
						isSaved: state.isSaved(article),
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
		.onAppear { AnalyticsService.screen(model.kind == .news ? "news" : "reviews") }
		.navigationTitle(model.kind == .news ? Text("tab.news") : Text("tab.reviews"))
		.searchable(
			text: $model.query,
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
		.onSubmit(of: .search) {
			if !model.query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
				AnalyticsService.log(.searchSubmitted)
			}
		}
		.refreshable {
			AnalyticsService.log(.feedRefreshed)
			await model.load(
				request,
				force: true
			)
		}
		.task(
			id: FeedLoadKey(
				request: request,
				ready: state.isReady
			)
		) { if state.isReady { await model.load(request) } }
		.task(id: model.query) { await model.applySearch() }
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

private struct FeedLoadKey: Equatable {
	let request: FeedRequest
	let ready: Bool
}
