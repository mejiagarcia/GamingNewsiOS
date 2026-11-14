import SwiftUI

nonisolated enum EditorialTab: Int, CaseIterable, Identifiable, Sendable {
	case news, reviews, releases, saved

	var id: Int {
		rawValue
	}

	var title: LocalizedStringKey {
		switch self {
			case .news: "tab.news"
			case .reviews: "tab.reviews"
			case .releases: "tab.releases"
			case .saved: "tab.saved"
		}
	}

	var glyph: EditorialGlyph {
		switch self {
			case .news: .news
			case .reviews: .reviews
			case .releases: .calendar
			case .saved: .saved
		}
	}
}

struct EditorialTabBar: View {
	let selected: EditorialTab
	let isCompact: Bool
	let onSelect: (EditorialTab) -> Void

	@Environment(\.accessibilityReduceMotion)
	private var reduceMotion

	var body: some View {
		HStack(spacing: DesignSystem.Spacing.compact) {
			ForEach(EditorialTab.allCases) { tab in
				let isSelected = tab == selected

				Button {
					onSelect(tab)
				} label: {
					tab.glyph.view
						.scaleEffect(isCompact ? 0.8 : 1)
						.frame(
							width: isCompact ? DesignSystem.Size.minimumTapTarget : DesignSystem.Size.expandedTabWidth,
							height: isCompact ? DesignSystem.Size.minimumTapTarget : DesignSystem.Size.expandedTabHeight
						)
						.foregroundStyle(isSelected ? DesignSystem.Palette.ink : DesignSystem.Palette.onBanner)
						.background(
							isSelected ? DesignSystem.Palette.gold : DesignSystem.Palette.banner,
							in: Capsule()
						)
						.contentShape(Capsule())
				}
				.buttonStyle(EditorialPlainButtonStyle(haptic: .selection))
				.accessibilityLabel(Text(tab.title))
				.accessibilityAddTraits(isSelected ? .isSelected : [])
			}
		}
		.padding(DesignSystem.Spacing.compact)
		.background {
			Capsule()
				.fill(DesignSystem.Palette.ink)
				.shadow(
					color: DesignSystem.Palette.ink.opacity(0.35),
					radius: DesignSystem.Size.cardOffset,
					y: DesignSystem.Size.cardOffset
				)
		}
		.overlay {
			Capsule()
				.strokeBorder(DesignSystem.Palette.outline, lineWidth: DesignSystem.Size.outline)
				.allowsHitTesting(false)
		}
		.animation(reduceMotion ? nil : .easeInOut, value: isCompact)
	}
}
