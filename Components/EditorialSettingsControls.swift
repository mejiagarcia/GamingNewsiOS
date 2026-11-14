import SwiftUI

struct EditorialSettingsSection<Content: View>: View {
	let title: LocalizedStringKey
	@ViewBuilder
	let content: Content

	var body: some View {
		VStack(alignment: .leading, spacing: DesignSystem.Spacing.regular) {
			Text(title)
				.font(DesignSystem.Typography.display(.title2))
				.textCase(.uppercase)
				.foregroundStyle(Color.accentColor)
				.accessibilityAddTraits(.isHeader)

			content
		}
		.frame(maxWidth: .infinity, alignment: .leading)
		.editorialCardRow()
	}
}

struct EditorialToggleStyle: ToggleStyle {
	func makeBody(configuration: Configuration) -> some View {
		Button {
			configuration.isOn.toggle()
		} label: {
			HStack(spacing: DesignSystem.Spacing.regular) {
				configuration.label
					.frame(maxWidth: .infinity, alignment: .leading)
				(configuration.isOn ? EditorialGlyph.check : EditorialGlyph.close).view
					.foregroundStyle(DesignSystem.Palette.ink)
					.frame(width: DesignSystem.Size.minimumTapTarget, height: DesignSystem.Size.minimumTapTarget)
					.background(
						configuration.isOn ? DesignSystem.Palette.gold : DesignSystem.Palette.onBanner,
						in: .rect(cornerRadius: DesignSystem.Radius.small)
					)
					.overlay {
						RoundedRectangle(cornerRadius: DesignSystem.Radius.small)
							.strokeBorder(DesignSystem.Palette.outline, lineWidth: DesignSystem.Size.outline)
					}
			}
		}
		.buttonStyle(EditorialPlainButtonStyle(haptic: .selection))
		.accessibilityValue(Text(configuration.isOn ? "toggle.on" : "toggle.off"))
		.accessibilityAddTraits(configuration.isOn ? .isSelected : [])
	}
}

struct EditorialChoice<Value: Equatable>: View {
	let title: LocalizedStringKey
	let value: Value
	@Binding
	var selection: Value

	var body: some View {
		Button {
			guard selection != value else { return }
			selection = value
		} label: {
			HStack(spacing: DesignSystem.Spacing.regular) {
				Text(title)
					.frame(maxWidth: .infinity, alignment: .leading)
				if value == selection {
					EditorialGlyph.check.view
				}
			}
		}
		.buttonStyle(EditorialButtonStyle(hierarchy: value == selection ? .selected : .secondary))
		.accessibilityAddTraits(value == selection ? .isSelected : [])
	}
}
