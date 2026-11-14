import SwiftUI

enum EditorialButtonHierarchy: Equatable, Sendable {
	case primary
	case secondary
	case tertiary
	case destructive
	case selected
	case unselected

	var haptic: ButtonHapticLevel {
		switch self {
			case .primary: .firm
			case .secondary: .light
			case .tertiary, .selected, .unselected: .selection
			case .destructive: .warning
		}
	}
}

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

struct EditorialButtonStyle: ButtonStyle {
	let hierarchy: EditorialButtonHierarchy

	@Environment(\.isEnabled)
	private var isEnabled

	func makeBody(configuration: Configuration) -> some View {
		let isFilter = hierarchy == .selected || hierarchy == .unselected
		let shape = RoundedRectangle(
			cornerRadius: isFilter ? DesignSystem.Radius.small : DesignSystem.Radius.card
		)
		let fill = backgroundColor
		let foreground = foregroundColor

		configuration.label
			.font(DesignSystem.Typography.display(.subheadline))
			.textCase(.uppercase)
			.multilineTextAlignment(.center)
			.foregroundStyle(foreground)
			.padding(.horizontal, DesignSystem.Spacing.regular)
			.padding(.vertical, DesignSystem.Spacing.compact)
			.frame(minHeight: DesignSystem.Size.minimumTapTarget)
			.background(fill, in: shape)
			.overlay {
				shape.strokeBorder(
					outlineColor,
					lineWidth: DesignSystem.Size.outline
				)
			}
			.opacity(isEnabled ? 1 : 0.5)
			.offset(y: configuration.isPressed ? DesignSystem.Size.outline : .zero)
			.onChange(of: configuration.isPressed) { _, isPressed in
				guard isPressed, isEnabled else { return }
				HapticFeedback.buttonPress(hierarchy.haptic)
			}
	}

	private var backgroundColor: Color {
		switch hierarchy {
			case .primary: DesignSystem.Palette.gold
			case .secondary: DesignSystem.Palette.paper
			case .tertiary: .clear
			case .destructive: DesignSystem.Palette.destructive
			case .selected: DesignSystem.Palette.gold
			case .unselected: DesignSystem.Palette.banner
		}
	}

	private var foregroundColor: Color {
		switch hierarchy {
			case .primary, .selected: DesignSystem.Palette.ink
			case .secondary: .primary
			case .tertiary, .unselected: DesignSystem.Palette.onBanner
			case .destructive: DesignSystem.Palette.onBanner
		}
	}

	private var outlineColor: Color {
		switch hierarchy {
			case .tertiary, .unselected: DesignSystem.Palette.onBanner
			case .secondary: DesignSystem.Palette.outline
			default: DesignSystem.Palette.ink
		}
	}
}

struct EditorialFilterStyle: ButtonStyle {
	let isSelected: Bool

	func makeBody(configuration: Configuration) -> some View {
		EditorialButtonStyle(hierarchy: isSelected ? .selected : .unselected)
			.makeBody(configuration: configuration)
	}
}

struct EditorialActionStyle: ButtonStyle {
	func makeBody(configuration: Configuration) -> some View {
		EditorialButtonStyle(hierarchy: .primary)
			.makeBody(configuration: configuration)
	}
}

struct EditorialPlainButtonStyle: ButtonStyle {
	let haptic: ButtonHapticLevel

	@Environment(\.isEnabled)
	private var isEnabled

	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.opacity(configuration.isPressed ? 0.7 : 1)
			.onChange(of: configuration.isPressed) { _, isPressed in
				guard isPressed, isEnabled else { return }
				HapticFeedback.buttonPress(haptic)
			}
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
			.buttonStyle(EditorialPlainButtonStyle(haptic: .light))
			.scrollDismissesKeyboard(.interactively)
			.modifier(EditorialTabScroll())
	}

	func editorialSettingsPage() -> some View {
		editorialList()
			.toggleStyle(EditorialToggleStyle())
	}
}
