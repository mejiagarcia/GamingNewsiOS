import SwiftUI

struct ArticleRow: View {

	enum Action: Sendable {
		case copy
		case open
		case openReader
		case openExternally
		case share
		case toggleSaved
	}

	// MARK: - Internal Constants

	let article: Article
	let isSaved: Bool
	let showImages: Bool
	let isUpdating: Bool
	var isMuted = false
	let onAction: (Action) -> Void

	@Environment(\.dynamicTypeSize)
	private var dynamicTypeSize

	// MARK: - View

	var body: some View {
		HStack(
			alignment: .top,
			spacing: DesignSystem.Spacing.regular
		) {
			Button { onAction(.open) } label: {
				let layout = dynamicTypeSize.isAccessibilitySize
					? AnyLayout(VStackLayout(alignment: .leading, spacing: DesignSystem.Spacing.regular))
					: AnyLayout(HStackLayout(alignment: .top, spacing: DesignSystem.Spacing.regular))

				layout {
					if showImages, let url = article.imageURL {
						ArticleThumbnail(url: url)
					}
					VStack(
						alignment: .leading,
						spacing: DesignSystem.Spacing.compact
					) {
						Text(verbatim: article.publisher)
							.font(DesignSystem.Typography.display(.subheadline))
							.textCase(.uppercase)
							.foregroundStyle(Color.accentColor)
							.multilineTextAlignment(.leading)
						Text(verbatim: article.title)
							.font(DesignSystem.Typography.display(.title2))
							.foregroundStyle(.primary)
							.multilineTextAlignment(.leading)
							.fixedSize(horizontal: false, vertical: true)
						if isMuted {
							Text("mute.badge")
								.font(.caption2)
								.padding(.horizontal, DesignSystem.Spacing.compact)
								.padding(.vertical, DesignSystem.Spacing.compact)
								.foregroundStyle(DesignSystem.Palette.ink)
								.background(DesignSystem.Palette.gold, in: Capsule())
						}
						if let date = article.publishedAt {
							Text(
								date,
								style: .date
							).font(.caption).foregroundStyle(.secondary)
						}
					}
					.frame(
						maxWidth: .infinity,
						alignment: .leading
					)
				}
				.contentShape(Rectangle())
			}
			.buttonStyle(.plain)
			.accessibilityHint(Text("article.open.hint"))
			Menu {
				Button { onAction(.toggleSaved) } label: {
					Label(
						isSaved ? "article.remove" : "article.save",
						systemImage: isSaved ? "bookmark.slash" : "bookmark"
					)
				}
				.disabled(isUpdating)
				Button { onAction(.share) } label: {
					Label(
						"article.share",
						systemImage: "square.and.arrow.up"
					)
				}
				Button { onAction(.copy) } label: {
					Label(
						"article.copy",
						systemImage: "doc.on.doc"
					)
				}
				Button { onAction(.openExternally) } label: {
					Label(
						"article.external",
						systemImage: "safari"
					)
				}
				Button { onAction(.openReader) } label: {
					Label(
						"article.reader",
						systemImage: "doc.text"
					)
				}
			} label: {
				Image(systemName: isSaved ? "bookmark.fill" : "ellipsis")
					.frame(
						width: DesignSystem.Size.minimumTapTarget,
						height: DesignSystem.Size.minimumTapTarget
					)
					.foregroundStyle(isSaved ? DesignSystem.Palette.ink : DesignSystem.Palette.onBanner)
					.background(
						isSaved ? DesignSystem.Palette.gold : DesignSystem.Palette.ink,
						in: Circle()
					)
					.contentShape(Circle())
			}
			.accessibilityLabel(Text("article.actions"))
		}
	}
}
