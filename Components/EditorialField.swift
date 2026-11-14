import SwiftUI

struct EditorialField: View {
	let prompt: LocalizedStringKey

	@Binding
	var text: String
	var isSearch = false

	@FocusState
	private var isFocused: Bool

	var body: some View {
		let shape = RoundedRectangle(
			cornerRadius: isSearch ? DesignSystem.Radius.card : DesignSystem.Radius.small
		)

		HStack(spacing: DesignSystem.Spacing.regular) {
			if isSearch {
				EditorialGlyph.search.view
					.foregroundStyle(DesignSystem.Palette.ink)
					.frame(
						width: DesignSystem.Size.minimumTapTarget,
						height: DesignSystem.Size.minimumTapTarget
					)
					.background(DesignSystem.Palette.gold, in: .rect(cornerRadius: DesignSystem.Radius.small))
			}

			TextField(prompt, text: $text)
				.font(isSearch ? DesignSystem.Typography.display(.headline) : .body)
				.focused($isFocused)
				.submitLabel(isSearch ? .search : .done)
				.onSubmit { isFocused = false }

			if isSearch || !text.isEmpty {
				clearButton
					.opacity(text.isEmpty ? .zero : 1)
					.allowsHitTesting(!text.isEmpty)
					.accessibilityHidden(text.isEmpty)
			}
		}
		.padding(.leading, isSearch ? DesignSystem.Spacing.compact : DesignSystem.Spacing.regular)
		.padding(.trailing, DesignSystem.Spacing.regular)
		.padding(.vertical, DesignSystem.Spacing.compact)
		.frame(minHeight: DesignSystem.Size.minimumTapTarget)
		.background {
			if isSearch {
				shape.fill(DesignSystem.Palette.gold)
					.offset(
						x: DesignSystem.Size.cardOffset,
						y: DesignSystem.Size.cardOffset
					)
			}

			shape.fill(DesignSystem.Palette.paper)
			shape.strokeBorder(
				isFocused ? Color.accentColor : DesignSystem.Palette.outline,
				lineWidth: DesignSystem.Size.outline
			)
		}
	}

	private var clearButton: some View {
		Button {
			text = ""
		} label: {
			EditorialGlyph.close.view
				.foregroundStyle(Color.accentColor)
				.frame(
					width: DesignSystem.Size.minimumTapTarget,
					height: DesignSystem.Size.minimumTapTarget
				)
				.contentShape(Rectangle())
		}
		.buttonStyle(EditorialPlainButtonStyle(haptic: .selection))
		.accessibilityLabel(Text("field.clear"))
	}
}
