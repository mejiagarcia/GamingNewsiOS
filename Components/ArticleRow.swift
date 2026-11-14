import SwiftUI

struct ArticleRow: View {
	enum Layout {
		case row
		case newspaper(featured: Bool)
	}

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
	var layout: Layout = .row
	let onAction: (Action) -> Void

	@Environment(\.dynamicTypeSize)
	private var dynamicTypeSize

	// MARK: - View

	var body: some View {
		if case let .newspaper(featured) = layout {
			newspaperCard(featured: featured)
		} else {
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
			.buttonStyle(EditorialPlainButtonStyle(haptic: .light))
			.accessibilityHint(Text("article.open.hint"))
			Menu {
				Button { onAction(.toggleSaved) } label: {
					EditorialLabel(title: isSaved ? "article.remove" : "article.save", glyph: .saved)
				}
				.buttonStyle(EditorialPlainButtonStyle(haptic: .light))
				.disabled(isUpdating)
				Button { onAction(.share) } label: {
					EditorialLabel(title: "article.share", glyph: .share)
				}
				.buttonStyle(EditorialPlainButtonStyle(haptic: .light))
				Button { onAction(.copy) } label: {
					EditorialLabel(title: "article.copy", glyph: .copy)
				}
				.buttonStyle(EditorialPlainButtonStyle(haptic: .light))
				Button { onAction(.openExternally) } label: {
					EditorialLabel(title: "article.external", glyph: .external)
				}
				.buttonStyle(EditorialPlainButtonStyle(haptic: .light))
				Button { onAction(.openReader) } label: {
					EditorialLabel(title: "article.reader", glyph: .reader)
				}
				.buttonStyle(EditorialPlainButtonStyle(haptic: .light))
			} label: {
				(isSaved ? EditorialGlyph.saved : EditorialGlyph.more).view
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

	private func newspaperCard(featured: Bool) -> some View {
		VStack(alignment: .leading, spacing: DesignSystem.Spacing.compact) {
			Button { onAction(.open) } label: {
				VStack(alignment: .leading, spacing: DesignSystem.Spacing.compact) {
					if showImages, let url = article.imageURL {
						ArticleThumbnail(url: url, fillsWidth: true)
							.frame(maxWidth: .infinity)
							.frame(height: featured ? 150 : 96)
							.clipped()
					}
					Text(verbatim: article.publisher.uppercased())
						.font(.caption.weight(.bold))
						.foregroundStyle(Color.accentColor)
					Text(verbatim: article.title)
						.font(DesignSystem.Typography.display(featured ? .title2 : .headline))
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
						Text(date, style: .date)
							.font(.caption2)
							.foregroundStyle(.secondary)
					}
				}
				.frame(maxWidth: .infinity, alignment: .leading)
				.contentShape(Rectangle())
			}
			.buttonStyle(EditorialPlainButtonStyle(haptic: .light))
			.accessibilityHint(Text("article.open.hint"))
			HStack {
				Spacer()
				articleActions
			}
		}
	}

	private var articleActions: some View {
		Menu {
			Button { onAction(.toggleSaved) } label: {
				EditorialLabel(title: isSaved ? "article.remove" : "article.save", glyph: .saved)
			}
			.disabled(isUpdating)
			Button { onAction(.share) } label: {
				EditorialLabel(title: "article.share", glyph: .share)
			}
			Button { onAction(.copy) } label: {
				EditorialLabel(title: "article.copy", glyph: .copy)
			}
			Button { onAction(.openExternally) } label: {
				EditorialLabel(title: "article.external", glyph: .external)
			}
			Button { onAction(.openReader) } label: {
				EditorialLabel(title: "article.reader", glyph: .reader)
			}
		} label: {
			(isSaved ? EditorialGlyph.saved : EditorialGlyph.more).view
				.frame(width: DesignSystem.Size.minimumTapTarget, height: DesignSystem.Size.minimumTapTarget)
				.foregroundStyle(isSaved ? DesignSystem.Palette.ink : DesignSystem.Palette.onBanner)
				.background(isSaved ? DesignSystem.Palette.gold : DesignSystem.Palette.ink, in: Circle())
		}
		.accessibilityLabel(Text("article.actions"))
	}
}
