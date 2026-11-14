import SwiftUI

struct EditorialMasthead<Filters: View>: View {
	let title: LocalizedStringKey
	@ViewBuilder
	let filters: Filters

	var body: some View {
		VStack(
			alignment: .leading,
			spacing: .zero
		) {
			Text(title)
				.font(DesignSystem.Typography.display(.largeTitle))
				.textCase(.uppercase)
				.foregroundStyle(DesignSystem.Palette.onBanner)
				.accessibilityAddTraits(.isHeader)
				.frame(maxWidth: .infinity, alignment: .leading)
				.padding(DesignSystem.Spacing.large)
				.background(DesignSystem.Palette.banner)

			filters
		}
		.background(DesignSystem.Palette.ink)
		.overlay(alignment: .bottom) {
			DesignSystem.Palette.gold
				.frame(height: DesignSystem.Size.outline)
				.accessibilityHidden(true)
		}
		.listRowInsets(EdgeInsets())
		.listRowBackground(Color.clear)
		.listRowSeparator(.hidden)
	}
}
