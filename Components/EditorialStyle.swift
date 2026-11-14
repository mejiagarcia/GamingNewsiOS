import SwiftUI

// Shared surfaces and typography for the app's editorial layout.
private struct EditorialCardModifier: ViewModifier {
	func body(content: Content) -> some View {
		let shape = RoundedRectangle(cornerRadius: DesignSystem.Radius.card)

		content
			.padding(DesignSystem.Spacing.regular)
			.background {
				shape.fill(DesignSystem.Palette.outline)
					.offset(
						x: DesignSystem.Size.cardOffset,
						y: DesignSystem.Size.cardOffset
					)
				shape.fill(DesignSystem.Palette.paper)
				shape.strokeBorder(
					DesignSystem.Palette.outline,
					lineWidth: DesignSystem.Size.outline
				)
			}
	}
}

struct EditorialFilterStyle: ButtonStyle {
	let isSelected: Bool

	func makeBody(configuration: Configuration) -> some View {
		let shape = RoundedRectangle(cornerRadius: DesignSystem.Radius.small)

		configuration.label
			.font(DesignSystem.Typography.display(.subheadline))
			.textCase(.uppercase)
			.foregroundStyle(isSelected ? DesignSystem.Palette.ink : DesignSystem.Palette.onBanner)
			.padding(.horizontal, DesignSystem.Spacing.regular)
			.padding(.vertical, DesignSystem.Spacing.compact)
			.frame(minHeight: DesignSystem.Size.minimumTapTarget)
			.background(
				isSelected ? DesignSystem.Palette.gold : DesignSystem.Palette.banner,
				in: shape
			)
			.overlay {
				shape.strokeBorder(
					isSelected ? DesignSystem.Palette.ink : DesignSystem.Palette.onBanner,
					lineWidth: DesignSystem.Size.outline
				)
			}
			.offset(y: configuration.isPressed ? DesignSystem.Size.outline : .zero)
	}
}

struct EditorialActionStyle: ButtonStyle {
	@Environment(\.isEnabled)
	private var isEnabled

	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.font(DesignSystem.Typography.display(.subheadline))
			.textCase(.uppercase)
			.multilineTextAlignment(.center)
			.foregroundStyle(DesignSystem.Palette.ink)
			.padding(.horizontal, DesignSystem.Spacing.regular)
			.padding(.vertical, DesignSystem.Spacing.compact)
			.frame(minHeight: DesignSystem.Size.minimumTapTarget)
			.background(DesignSystem.Palette.gold, in: Capsule())
			.overlay {
				Capsule().strokeBorder(
					DesignSystem.Palette.ink,
					lineWidth: DesignSystem.Size.outline
				)
			}
			.opacity(isEnabled ? 1 : 0.5)
			.offset(y: configuration.isPressed ? DesignSystem.Size.outline : .zero)
	}
}

extension View {
	func editorialCard() -> some View {
		modifier(EditorialCardModifier())
	}

	func editorialCardRow() -> some View {
		editorialCard()
			.padding(.vertical, DesignSystem.Spacing.compact)
			.listRowBackground(Color.clear)
			.listRowSeparator(.hidden)
	}

	func editorialCanvas() -> some View {
		background {
			DesignSystem.Palette.canvas.ignoresSafeArea()
		}
	}

	func editorialList() -> some View {
		listStyle(.plain)
			.scrollContentBackground(.hidden)
			.editorialCanvas()
	}

	func editorialForm() -> some View {
		scrollContentBackground(.hidden)
			.editorialCanvas()
	}
}
