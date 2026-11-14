import SwiftUI

enum DesignSystem: Sendable {
	enum Palette: Sendable {
		static let banner = Color("EditorialBanner")
		static let canvas = Color("EditorialCanvas")
		static let destructive = Color("EditorialDestructive")
		static let gold = Color("EditorialGold")
		static let ink = Color("EditorialInk")
		static let onBanner = Color("EditorialOnBanner")
		static let outline = Color("EditorialOutline")
		static let paper = Color("EditorialPaper")
	}

	enum Typography: Sendable {
		static func display(_ style: Font.TextStyle) -> Font {
			.system(style, design: .default, weight: .black).width(.compressed)
		}
	}

	enum Spacing: Sendable {
		static let compact: CGFloat = 6
		static let large: CGFloat = 24
		static let regular: CGFloat = 12
	}

	enum Size: Sendable {
		static let cardOffset: CGFloat = 4
		static let minimumTapTarget: CGFloat = 44
		static let outline: CGFloat = 2
		static let releaseThumbnailHeight: CGFloat = 112
		static let thumbnailHeight: CGFloat = 72
		static let thumbnailWidth: CGFloat = 88
	}

	enum Radius: Sendable {
		static let card: CGFloat = 16
		static let small: CGFloat = 8
	}
}
