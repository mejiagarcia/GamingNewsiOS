import SwiftUI

struct ReleasesView: View {
	@Bindable
	var model: ReleasesViewModel
	let navigation: any AppNavigationProtocol

	var body: some View {
		List {
			EditorialMasthead(title: "tab.releases") {
				ScrollView(.horizontal) {
					HStack(spacing: DesignSystem.Spacing.regular) {
						platformButton(name: String(localized: "releases.allPlatforms"), id: nil)
						ForEach(GamePlatform.supported) { platform in
							platformButton(name: platform.name, id: platform.id)
						}
					}
					.padding(.horizontal, DesignSystem.Spacing.large)
				}
				.scrollIndicators(.hidden)
				.padding(.vertical, DesignSystem.Spacing.regular)
			}

			if let errorKey = model.errorKey {
				Section {
					ContentUnavailableView {
						Label("releases.failed", systemImage: "wifi.exclamationmark")
					} description: {
						Text(LocalizedStringKey(errorKey))
					} actions: {
						Button("feed.retry") {
							Task { await model.refresh() }
						}
						.buttonStyle(EditorialActionStyle())
					}
				}
			}
			if model.isLoading && model.releases.isEmpty {
				ProgressView().frame(maxWidth: .infinity).padding()
			} else if model.releases.isEmpty, model.errorKey == nil {
				ContentUnavailableView(
					model.query.isEmpty ? "releases.empty" : "search.empty",
					systemImage: "calendar"
				)
			} else if !model.releases.isEmpty {
				ForEach(model.releases) { release in
					ReleaseRow(release: release)
						.editorialCardRow()
						.onAppear {
							guard release.id == model.releases.last?.id else {
								return
							}
							Task { await model.loadNextPage() }
						}
				}
				if model.isLoadingMore {
					ProgressView().frame(maxWidth: .infinity).padding()
				}
			}
		}
		.editorialList()
		.navigationBarTitleDisplayMode(.inline)
		.searchable(text: $model.query, prompt: Text("search.prompt"))
		.toolbar {
			ToolbarItem(placement: .topBarTrailing) {
				Button("settings.title", systemImage: "gearshape") {
					navigation.showSettings()
				}
				.buttonStyle(EditorialPlainButtonStyle(haptic: .light))
			}
			ToolbarItem(placement: .topBarTrailing) {
				Button("releases.refresh", systemImage: "arrow.clockwise") {
					Task { await model.refresh() }
				}
				.buttonStyle(EditorialPlainButtonStyle(haptic: .light))
				.disabled(model.isRefreshing)
			}
		}
		.refreshable { await model.refresh() }
		.task { await model.load() }
	}
}

private extension ReleasesView {
	@ViewBuilder
	func platformButton(
		name: String,
		id: Int?
	) -> some View {
		let selected = id.map { model.platformIDs.contains($0) } ?? model.platformIDs.isEmpty
		Button(name) {
			if let id {
				model.togglePlatform(id)
			} else {
				model.platformIDs = []
			}
		}
			.buttonStyle(EditorialFilterStyle(isSelected: selected))
			.accessibilityAddTraits(selected ? .isSelected : [])
	}
}

private struct ReleaseRow: View {
	let release: GameRelease

	@Environment(\.dynamicTypeSize)
	private var dynamicTypeSize

	var body: some View {
		Group {
			if let gameURL = release.gameURL {
				Link(destination: gameURL) { content }
					.buttonStyle(EditorialPlainButtonStyle(haptic: .light))
			} else {
				content
			}
		}
	}

	private var content: some View {
		let layout = dynamicTypeSize.isAccessibilitySize
			? AnyLayout(VStackLayout(alignment: .leading, spacing: DesignSystem.Spacing.regular))
			: AnyLayout(HStackLayout(alignment: .top, spacing: DesignSystem.Spacing.regular))

		return layout {
			AsyncImage(url: release.coverURL) { image in
				image.resizable().scaledToFill()
			} placeholder: {
				Image(systemName: "gamecontroller.fill")
					.foregroundStyle(.secondary)
					.frame(maxWidth: .infinity, maxHeight: .infinity)
					.background(Color("ArticlePlaceholder"))
			}
			.frame(
				width: DesignSystem.Size.thumbnailWidth,
				height: DesignSystem.Size.releaseThumbnailHeight
			)
			.clipShape(.rect(cornerRadius: DesignSystem.Radius.small))
			.accessibilityHidden(true)

			VStack(alignment: .leading, spacing: DesignSystem.Spacing.compact) {
				Text(verbatim: release.name)
					.font(DesignSystem.Typography.display(.title2))
					.foregroundStyle(.primary)
					.accessibilityAddTraits(.isHeader)
					.fixedSize(horizontal: false, vertical: true)
				Text(release.platforms.joined(separator: " · "))
					.font(.subheadline)
					.foregroundStyle(.secondary)
				Text(dateLabel)
					.font(.subheadline.weight(.medium))
					.foregroundStyle(Color.accentColor)
			}
			.frame(maxWidth: .infinity, alignment: .leading)
		}
		.padding(.vertical, DesignSystem.Spacing.compact)
	}

	private var dateLabel: String {
		if release.hasExactDate {
			return release.releaseDate.formatted(.dateTime.month(.wide).day().year())
		}
		return release.humanDate ?? String(localized: "releases.dateUnknown")
	}
}
