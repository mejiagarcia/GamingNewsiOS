import SwiftUI

struct EditorialLabel: View {
	let title: LocalizedStringKey
	let glyph: EditorialGlyph

	var body: some View {
		HStack(spacing: DesignSystem.Spacing.compact) {
			glyph.view
			Text(title)
		}
	}
}
