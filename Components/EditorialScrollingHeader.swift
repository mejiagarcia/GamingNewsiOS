import SwiftUI

struct EditorialScrollingHeader<Header: View>: ViewModifier {
	let header: Header

	@Environment(\.accessibilityReduceMotion)
	private var reduceMotion

	@State
	private var isHidden = false

	func body(content: Content) -> some View {
		content
			.environment(\.editorialHeaderHidden, $isHidden)
			.safeAreaInset(edge: .top, spacing: .zero) {
				if !isHidden {
					header
						.transition(reduceMotion ? .identity : .move(edge: .top).combined(with: .opacity))
				}
			}
			.animation(reduceMotion ? nil : .easeInOut(duration: 0.22), value: isHidden)
	}
}

extension View {
	func editorialScrollingHeader<Header: View>(
		@ViewBuilder _ header: () -> Header
	) -> some View {
		modifier(EditorialScrollingHeader(header: header()))
	}
}
