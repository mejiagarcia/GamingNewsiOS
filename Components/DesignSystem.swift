import CoreGraphics

enum DesignSystem: Sendable {
	enum Spacing: Sendable {
		static let compact: CGFloat = 6
		static let regular: CGFloat = 12
	}

	enum Size: Sendable {
		static let minimumTapTarget: CGFloat = 44
		static let thumbnailHeight: CGFloat = 72
		static let thumbnailWidth: CGFloat = 88
	}

	enum Radius: Sendable {
		static let small: CGFloat = 8
	}
}
