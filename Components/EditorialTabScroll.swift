import SwiftUI

extension EnvironmentValues {
	@Entry var editorialHeaderHidden: Binding<Bool>? = nil

	@Entry var setEditorialTabCompact: (@MainActor (Bool) -> Void)? = nil
}

struct EditorialTabScroll: ViewModifier {
	@Environment(\.editorialHeaderHidden)
	private var headerHidden

	@Environment(\.setEditorialTabCompact)
	private var setCompact

	@State
	private var isDragging = false

	@State
	private var directionAnchor: CGFloat?

	func body(content: Content) -> some View {
		content
			.onScrollPhaseChange { _, phase in
				isDragging = phase == .interacting
				directionAnchor = nil
			}
			.onScrollGeometryChange(for: ScrollPosition.self) { geometry in
				let offset = geometry.contentOffset.y + geometry.contentInsets.top
				let scrollableHeight = geometry.contentSize.height + geometry.contentInsets.top
					+ geometry.contentInsets.bottom - geometry.containerSize.height

				return ScrollPosition(
					offset: min(max(offset, .zero), max(scrollableHeight, .zero)),
					topInset: geometry.contentInsets.top
				)
			} action: { previous, current in
				// Resizing the header changes the inset without a new scroll gesture.
				guard previous.topInset == current.topInset else {
					directionAnchor = nil
					return
				}

				if current.offset == .zero {
					updateBars(isCompact: false)
					directionAnchor = nil
					return
				}

				guard isDragging else { return }

				let anchor = directionAnchor ?? previous.offset
				let distance = current.offset - anchor
				guard abs(distance) >= DesignSystem.Size.tabScrollThreshold else {
					directionAnchor = anchor
					return
				}

				updateBars(isCompact: distance > .zero)
				directionAnchor = current.offset
			}
	}

	private func updateBars(isCompact: Bool) {
		if let headerHidden, headerHidden.wrappedValue != isCompact {
			headerHidden.wrappedValue = isCompact
		}

		setCompact?(isCompact)
	}

	private struct ScrollPosition: Equatable, Sendable {
		let offset: CGFloat
		let topInset: CGFloat
	}
}
