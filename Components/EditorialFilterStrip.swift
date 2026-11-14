import SwiftUI

struct EditorialFilterStrip<Content: View>: View {
	@ViewBuilder
	let content: Content

	var body: some View {
		VStack(alignment: .leading, spacing: .zero) {
			content
		}
		.background(DesignSystem.Palette.ink)
		.listRowInsets(EdgeInsets())
		.listRowBackground(Color.clear)
		.listRowSeparator(.hidden)
	}
}
