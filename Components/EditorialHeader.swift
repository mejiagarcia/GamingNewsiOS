import SwiftUI

struct EditorialHeader<Actions: View>: View {
	let title: LocalizedStringKey
	var onBack: (() -> Void)? = nil

	@ViewBuilder
	let actions: Actions

	var body: some View {
		HStack(spacing: DesignSystem.Spacing.compact) {
			if let onBack {
				Button(action: onBack) {
					EditorialGlyph.back.view
						.flipsForRightToLeftLayoutDirection(true)
				}
				.buttonStyle(EditorialButtonStyle(hierarchy: .tertiary))
				.accessibilityLabel(Text("navigation.back"))
			}

			Text(title)
				.font(DesignSystem.Typography.display(.largeTitle))
				.textCase(.uppercase)
				.accessibilityAddTraits(.isHeader)
				.fixedSize(horizontal: false, vertical: true)
				.frame(maxWidth: .infinity, alignment: .leading)

			actions
		}
		.foregroundStyle(DesignSystem.Palette.onBanner)
		.padding(.horizontal, DesignSystem.Spacing.regular)
		.padding(.vertical, DesignSystem.Spacing.compact)
		.background {
			DesignSystem.Palette.banner.ignoresSafeArea(edges: .top)
		}
		.overlay(alignment: .bottom) {
			DesignSystem.Palette.gold
				.frame(height: DesignSystem.Size.outline)
				.accessibilityHidden(true)
		}
	}
}
