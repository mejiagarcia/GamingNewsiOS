import SwiftUI

// MARK: - News and reviews

struct FeedView: View {

	// MARK: - Internal Properties

	@Bindable
	var model: FeedViewModel
	let state: AppState
	let navigation: any AppNavigationProtocol

	// MARK: - Private Properties

	@ViewBuilder
	private var mutedArticleActions: some View {
		Button(model.revealsMutedHeadlines ? "mute.hideAgain" : "mute.showHidden") {
			Task { await model.toggleRevealedMutedHeadlines() }
		}
		.buttonStyle(EditorialActionStyle())

		Button("mute.manage") {
			navigation.showMutedHeadlines()
		}
		.buttonStyle(EditorialActionStyle())
	}

	private var request: FeedRequest {
		FeedRequest(
			context: FeedContext(
				kind: model.kind,
				language: state.preferences.language.resolved,
				category: model.category
			),
			disabled: state.preferences.disabledSourceIDs,
			mutedHeadlineRules: state.preferences.mutedHeadlineRules,
			applyGlobalMuteRulesToReviews: state.preferences.applyGlobalMuteRulesToReviews
		)
	}

	// MARK: - View

	var body: some View {
		List {
			EditorialFilterStrip {
				EditorialField(prompt: "search.prompt", text: $model.query, isSearch: true)
					.padding(DesignSystem.Spacing.regular)
				if model.kind == .news {
					ScrollView(.horizontal) {
						HStack(spacing: DesignSystem.Spacing.regular) {
							ForEach(NewsCategory.allCases) { category in
								let selected = model.category == category

								Button(category.title) {
									if !selected {
										model.category = category
										AnalyticsService.log(.categoryChanged)
									}
								}
								.buttonStyle(EditorialFilterStyle(isSelected: selected))
								.accessibilityAddTraits(selected ? .isSelected : [])
							}
						}
						.padding(.horizontal, DesignSystem.Spacing.large)
					}
					.scrollIndicators(.hidden)
					.padding(.vertical, DesignSystem.Spacing.regular)
				}
			}
			if model.partialFailure {
				VStack(alignment: .leading, spacing: DesignSystem.Spacing.regular) {
					EditorialLabel(
						title: model.stale ? "feed.stale" : "feed.partial",
						glyph: .warning
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
					.buttonStyle(EditorialActionStyle())
				}
				.frame(maxWidth: .infinity, alignment: .leading)
				.editorialCardRow()
			}
			if model.isLoading && model.articles.isEmpty {
				ProgressView().frame(maxWidth: .infinity).padding()
			} else if model.noSources {
				ContentUnavailableView {
					EditorialLabel(title: "feed.noSources", glyph: .filters)
				} description: {
					Text("feed.noSources.description")
				} actions: {
					Button("settings.title") { navigation.showSettings() }
						.buttonStyle(EditorialActionStyle())
				}
			} else if model.failed {
				ContentUnavailableView {
					EditorialLabel(title: "feed.failed", glyph: .warning)
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
					.buttonStyle(EditorialActionStyle())
				}
			} else if model.loaded && model.articles.isEmpty && model.mutedCount > 0 {
				ContentUnavailableView {
					EditorialLabel(title: "mute.allMuted.title", glyph: .mute)
				} description: {
					Text("mute.allMuted.message")
				} actions: {
					Button("mute.showHidden") {
						Task { await model.toggleRevealedMutedHeadlines() }
					}
					.buttonStyle(EditorialActionStyle())
					Button("mute.manage") { navigation.showMutedHeadlines() }
						.buttonStyle(EditorialActionStyle())
				}
			} else if model.loaded && model.articles.isEmpty {
				ContentUnavailableView {
					EditorialLabel(title: model.query.isEmpty ? "feed.empty" : "search.empty", glyph: .news)
				}
			} else {
				if model.mutedCount > 0 {
					Section {
						VStack(alignment: .leading, spacing: DesignSystem.Spacing.compact) {
							Text(verbatim: String.localizedStringWithFormat(
								String(localized: model.mutedCount == 1 ? "mute.hiddenCount.one" : "mute.hiddenCount.other"),
								model.mutedCount
							))
								.font(.subheadline)
							ViewThatFits(in: .horizontal) {
								HStack(spacing: DesignSystem.Spacing.compact) {
									mutedArticleActions
								}
								VStack(alignment: .leading, spacing: DesignSystem.Spacing.compact) {
									mutedArticleActions
								}
							}
						}
						.frame(maxWidth: .infinity, alignment: .leading)
						.editorialCardRow()
					}
				}
				ForEach(model.articles) { article in
					ArticleRow(
						article: article,
						isSaved: state.isSaved(article),
						showImages: state.preferences.showImages,
						isUpdating: state.isUpdating,
						isMuted: model.mutedArticleIDs.contains(article.id),
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
		.onAppear { AnalyticsService.screen(model.kind == .news ? "news" : "reviews") }
		.safeAreaInset(edge: .top, spacing: .zero) {
			EditorialHeader(title: model.kind == .news ? "tab.news" : "tab.reviews") {
				Button {
					navigation.showSettings()
				} label: {
					EditorialGlyph.filters.view
				}
				.buttonStyle(EditorialButtonStyle(hierarchy: .tertiary))
				.accessibilityLabel(Text("settings.title"))
			}
		}
		.onSubmit(of: .text) {
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
