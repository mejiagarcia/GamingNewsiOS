import SwiftUI

struct ArticleRow: View {

	enum Action: Sendable {
		case copy
		case open
		case openExternally
		case share
		case toggleSaved
	}

	// MARK: - Internal Constants

	let article: Article
	let isSaved: Bool
	let showImages: Bool
	let isUpdating: Bool
	let onAction: (Action) -> Void

	// MARK: - View

	var body: some View {
		HStack(
			alignment: .top,
			spacing: DesignSystem.Spacing.regular
		) {
			Button { onAction(.open) } label: {
				HStack(
					alignment: .top,
					spacing: DesignSystem.Spacing.regular
				) {
					if showImages, let url = article.imageURL { ArticleThumbnail(url: url) }
					VStack(
						alignment: .leading,
						spacing: DesignSystem.Spacing.compact
					) {
						Text(verbatim: article.title).font(.headline).foregroundStyle(.primary)
							.multilineTextAlignment(.leading)
						Text(verbatim: article.publisher).font(.subheadline).foregroundStyle(.secondary)
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
			} label: {
				Image(systemName: isSaved ? "bookmark.fill" : "ellipsis")
					.frame(
						width: DesignSystem.Size.minimumTapTarget,
						height: DesignSystem.Size.minimumTapTarget
					)
					.contentShape(Rectangle())
			}
			.accessibilityLabel(Text("article.actions"))
		}
		.padding(
			.vertical,
			DesignSystem.Spacing.compact
		)
	}
}
