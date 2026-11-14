import SwiftUI

struct ArticleOpenModeSheet: View {
	let onSelect: (ArticleOpenMode) -> Void

	var body: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: DesignSystem.Spacing.regular) {
				VStack(alignment: .leading, spacing: DesignSystem.Spacing.compact) {
					Text("article.openMode.title")
						.font(DesignSystem.Typography.display(.largeTitle))
						.textCase(.uppercase)
						.accessibilityAddTraits(.isHeader)
					Text("article.openMode.description")
						.font(.subheadline)
						.foregroundStyle(.secondary)
				}
				.frame(maxWidth: .infinity, alignment: .leading)

				Button {
					onSelect(.reader)
				} label: {
					EditorialLabel(title: "article.openMode.reader", glyph: .reader)
						.frame(maxWidth: .infinity)
				}
				.buttonStyle(EditorialActionStyle())

				Button {
					onSelect(.original)
				} label: {
					EditorialLabel(title: "article.openMode.original", glyph: .external)
						.frame(maxWidth: .infinity)
				}
				.buttonStyle(EditorialButtonStyle(hierarchy: .secondary))
			}
			.editorialCard()
			.padding(DesignSystem.Spacing.large)
		}
		.editorialCanvas()
	}
}
