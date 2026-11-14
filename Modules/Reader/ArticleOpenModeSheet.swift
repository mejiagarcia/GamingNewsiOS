import SwiftUI

struct ArticleOpenModeSheet: View {
	let onSelect: (ArticleOpenMode) -> Void

	var body: some View {
		VStack(alignment: .leading, spacing: DesignSystem.Spacing.regular) {
			VStack(alignment: .leading, spacing: DesignSystem.Spacing.compact) {
				Text("article.openMode.title")
					.font(.title2.weight(.bold))
				Text("article.openMode.description")
					.font(.subheadline)
					.foregroundStyle(.secondary)
			}
			.frame(maxWidth: .infinity, alignment: .leading)

			Button {
				onSelect(.reader)
			} label: {
				Label("article.openMode.reader", systemImage: "doc.text")
					.frame(maxWidth: .infinity)
			}
			.buttonStyle(.borderedProminent)

			Button {
				onSelect(.original)
			} label: {
				Label("article.openMode.original", systemImage: "safari")
					.frame(maxWidth: .infinity)
			}
			.buttonStyle(.bordered)
		}
		.padding(DesignSystem.Spacing.regular)
		.presentationDetents([.medium])
		.presentationDragIndicator(.visible)
	}
}
