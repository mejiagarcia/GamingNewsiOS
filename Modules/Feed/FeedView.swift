import SwiftUI
import UserNotifications

// MARK: - News and reviews

struct FeedView: View {

	// MARK: - Internal Properties

	@Bindable
	var model: FeedViewModel
	@Bindable
	var notifications: PushNotificationService
	let state: AppState
	let navigation: any AppNavigationProtocol
	@State
	private var isNotificationBannerDismissed = false

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
			if model.kind == .news && shouldShowNotificationBanner {
				notificationBanner
					.editorialCardRow()
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
				NewspaperLayout(spacing: DesignSystem.Spacing.regular) {
					ForEach(model.articles.indices, id: \.self) { index in
						articleCard(at: index)
					}
				}
					.listRowBackground(Color.clear)
					.listRowSeparator(.hidden)
			}
		}
		.editorialList()
		.onAppear { AnalyticsService.screen(model.kind == .news ? "news" : "reviews") }
		.editorialScrollingHeader {
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
		.task { await notifications.refresh() }
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

	private var shouldShowNotificationBanner: Bool {
		!isNotificationBannerDismissed
			&& [.notDetermined, .denied].contains(notifications.authorizationStatus)
	}

	private func articleCard(at index: Int) -> some View {
		let article = model.articles[index]

		return ArticleRow(
			article: article,
			isSaved: state.isSaved(article),
			showImages: state.preferences.showImages,
			isUpdating: state.isUpdating,
			isMuted: model.mutedArticleIDs.contains(article.id),
			layout: .newspaper(featured: index.isMultiple(of: 5)),
			onAction: { action in
				ArticleActionHandler(
					state: state,
					navigation: navigation
				).handle(action, article: article)
			}
		)
		.frame(maxWidth: .infinity, alignment: .topLeading)
		.editorialCard()
	}

	private var notificationBanner: some View {
		VStack(alignment: .leading, spacing: DesignSystem.Spacing.regular) {
			HStack(alignment: .top, spacing: DesignSystem.Spacing.regular) {
				Image(systemName: "bell.badge.fill")
					.font(.title2)
					.foregroundStyle(DesignSystem.Palette.gold)
					.frame(width: DesignSystem.Size.glyph)
				VStack(alignment: .leading, spacing: DesignSystem.Spacing.compact) {
					Text("notifications.banner.title")
						.font(DesignSystem.Typography.display(.headline))
						.foregroundStyle(DesignSystem.Palette.onBanner)
					Text("notifications.banner.message")
						.font(.subheadline)
						.foregroundStyle(DesignSystem.Palette.onBanner)
				}
				Spacer(minLength: .zero)
				Button {
					isNotificationBannerDismissed = true
				} label: {
					Image(systemName: "xmark")
						.font(.caption.weight(.bold))
						.foregroundStyle(DesignSystem.Palette.onBanner)
						.frame(
							width: DesignSystem.Size.minimumTapTarget,
							height: DesignSystem.Size.minimumTapTarget
						)
				}
				.accessibilityLabel(Text("common.dismiss"))
				.buttonStyle(EditorialPlainButtonStyle(haptic: .selection))
			}
			Button {
				Task {
					do {
						try await notifications.requestOrOpenSettings()
					} catch {
						state.errorMessage = String(localized: "error.notifications")
					}
				}
			} label: {
				Text(
					notifications.authorizationStatus == .denied
						? "notifications.banner.settings"
						: "notifications.banner.action"
				)
					.frame(maxWidth: .infinity)
			}
			.buttonStyle(EditorialButtonStyle(hierarchy: .primary))
			.disabled(notifications.isUpdating)
		}
		.padding(DesignSystem.Spacing.regular)
		.background(
			DesignSystem.Palette.banner,
			in: RoundedRectangle(cornerRadius: DesignSystem.Radius.card)
		)
		.accessibilityElement(children: .contain)
	}
}

private struct NewspaperLayout: Layout {
	let spacing: CGFloat

	func sizeThatFits(
		proposal: ProposedViewSize,
		subviews: Subviews,
		cache: inout ()
	) -> CGSize {
		let width = proposal.width ?? .zero
		let columnWidth = (width - spacing) / 2
		let placements = placements(for: subviews, columnWidth: columnWidth)
		let height = placements.map { $0.origin.y + $0.size.height }.max() ?? .zero

		return CGSize(width: width, height: height)
	}

	func placeSubviews(
		in bounds: CGRect,
		proposal: ProposedViewSize,
		subviews: Subviews,
		cache: inout ()
	) {
		let columnWidth = (bounds.width - spacing) / 2
		let placements = placements(for: subviews, columnWidth: columnWidth)

		for (index, placement) in placements.enumerated() {
			subviews[index].place(
				at: CGPoint(x: bounds.minX + placement.origin.x, y: bounds.minY + placement.origin.y),
				proposal: ProposedViewSize(width: columnWidth, height: placement.size.height)
			)
		}
	}

	private func placements(for subviews: Subviews, columnWidth: CGFloat) -> [Placement] {
		var columnHeights = [CGFloat.zero, CGFloat.zero]
		var result: [Placement] = []

		for subview in subviews {
			let column = columnHeights[0] <= columnHeights[1] ? 0 : 1
			let size = subview.sizeThatFits(ProposedViewSize(width: columnWidth, height: nil))
			let x = column == 0 ? CGFloat.zero : columnWidth + spacing

			result.append(Placement(origin: CGPoint(x: x, y: columnHeights[column]), size: size))
			columnHeights[column] += size.height + spacing
		}

		return result
	}

	private struct Placement {
		let origin: CGPoint
		let size: CGSize
	}
}

private struct FeedLoadKey: Equatable {
	let request: FeedRequest
	let ready: Bool
}
