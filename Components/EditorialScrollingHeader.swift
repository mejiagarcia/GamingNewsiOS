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
				header
					.opacity(isHidden ? .zero : 1)
					.offset(y: isHidden ? -headerHeight : .zero)
					.allowsHitTesting(!isHidden)
					.accessibilityHidden(isHidden)
					.background {
						GeometryReader { geometry in
							Color.clear
								.preference(key: HeaderHeightPreferenceKey.self, value: geometry.size.height)
						}
					}
			}
			.onPreferenceChange(HeaderHeightPreferenceKey.self) { headerHeight = $0 }
			.animation(reduceMotion ? nil : .easeInOut(duration: 0.22), value: isHidden)
	}

	@State
	private var headerHeight: CGFloat = .zero
}

private struct HeaderHeightPreferenceKey: PreferenceKey {
	static let defaultValue: CGFloat = .zero

	static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
		value = nextValue()
	}
}

extension View {
	func editorialScrollingHeader<Header: View>(
		@ViewBuilder _ header: () -> Header
	) -> some View {
		modifier(EditorialScrollingHeader(header: header()))
	}
}
