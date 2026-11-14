import SwiftUI
import UIKit

enum EditorialGlyph: Sendable {
	case add, arrow, back, calendar, check, close, copy, external, filters, game
	case image, more, mute, news, reader, refresh, reviews, saved, search, share, warning

	var view: some View {
		GlyphShape(glyph: self)
			.stroke(style: StrokeStyle(lineWidth: DesignSystem.Size.outline, lineCap: .round, lineJoin: .round))
			.frame(width: DesignSystem.Size.glyph, height: DesignSystem.Size.glyph)
			.accessibilityHidden(true)
	}

	func tabImage() -> UIImage {
		let size = CGSize(width: DesignSystem.Size.glyph, height: DesignSystem.Size.glyph)
		return UIGraphicsImageRenderer(size: size).image { context in
			context.cgContext.setLineWidth(DesignSystem.Size.outline)
			context.cgContext.setLineJoin(.round)
			context.cgContext.setLineCap(.round)
			context.cgContext.addPath(GlyphShape(glyph: self).path(in: CGRect(origin: .zero, size: size)).cgPath)
			context.cgContext.strokePath()
		}.withRenderingMode(.alwaysTemplate)
	}
}

nonisolated private struct GlyphShape: Shape {
	let glyph: EditorialGlyph

	func path(in rect: CGRect) -> Path {
		var path = Path()

		func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
			CGPoint(x: rect.minX + x * rect.width / 24, y: rect.minY + y * rect.height / 24)
		}

		func line(_ points: [(CGFloat, CGFloat)]) {
			guard let first = points.first else { return }
			path.move(to: point(first.0, first.1))
			for (x, y) in points.dropFirst() {
				path.addLine(to: point(x, y))
			}
		}

		func box(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) {
			path.addRect(CGRect(origin: point(x, y), size: CGSize(width: width * rect.width / 24, height: height * rect.height / 24)))
		}

		switch glyph {
			case .add:
				line([(4, 12), (20, 12)])
				line([(12, 4), (12, 20)])
			case .arrow:
				line([(3, 12), (21, 12), (15, 6)])
				line([(21, 12), (15, 18)])
			case .back:
				line([(21, 12), (3, 12), (9, 6)])
				line([(3, 12), (9, 18)])
			case .calendar:
				box(3, 5, 18, 16)
				line([(3, 10), (21, 10)])
				line([(8, 3), (8, 7)])
				line([(16, 3), (16, 7)])
			case .check:
				line([(4, 12), (9, 17), (20, 6)])
			case .close:
				line([(5, 5), (19, 19)])
				line([(19, 5), (5, 19)])
			case .copy:
				box(8, 8, 12, 13)
				line([(15, 4), (4, 4), (4, 17)])
			case .external:
				line([(12, 4), (20, 4), (20, 12)])
				line([(20, 4), (10, 14)])
				line([(8, 5), (4, 5), (4, 20), (19, 20), (19, 16)])
			case .filters:
				line([(3, 6), (21, 6)])
				line([(7, 3), (7, 9)])
				line([(3, 12), (21, 12)])
				line([(16, 9), (16, 15)])
				line([(3, 18), (21, 18)])
				line([(10, 15), (10, 21)])
			case .game:
				line([(5, 7), (19, 7), (22, 17), (19, 19), (15, 15), (9, 15), (5, 19), (2, 17), (5, 7)])
				line([(6, 11), (10, 11)])
				line([(8, 9), (8, 13)])
				line([(16, 11), (18, 11)])
			case .image:
				box(3, 4, 18, 16)
				line([(4, 17), (9, 11), (13, 15), (16, 12), (20, 17)])
			case .more:
				for x in [CGFloat(5), 12, 19] {
					line([(x, 10), (x, 14)])
				}
			case .mute:
				line([(3, 9), (7, 9), (12, 4), (12, 20), (7, 15), (3, 15), (3, 9)])
				line([(16, 9), (21, 15)])
				line([(21, 9), (16, 15)])
			case .news:
				box(3, 4, 18, 16)
				box(6, 8, 5, 5)
				line([(14, 8), (18, 8)])
				line([(14, 12), (18, 12)])
				line([(6, 16), (18, 16)])
			case .reader:
				box(5, 3, 14, 18)
				line([(8, 8), (16, 8)])
				line([(8, 12), (16, 12)])
				line([(8, 16), (14, 16)])
			case .refresh:
				line([(20, 4), (20, 10), (14, 10)])
				line([(20, 10), (16, 5), (8, 5), (4, 9), (4, 16), (8, 20), (16, 20), (20, 16)])
			case .reviews:
				line([(12, 2), (15, 9), (22, 10), (17, 15), (18, 22), (12, 18), (6, 22), (7, 15), (2, 10), (9, 9), (12, 2)])
			case .saved:
				line([(5, 3), (19, 3), (19, 21), (12, 16), (5, 21), (5, 3)])
			case .search:
				path.addEllipse(in: CGRect(origin: point(3, 3), size: CGSize(width: rect.width / 2, height: rect.height / 2)))
				line([(14, 14), (21, 21)])
			case .share:
				line([(6, 11), (4, 11), (4, 21), (20, 21), (20, 11), (18, 11)])
				line([(12, 16), (12, 3), (7, 8)])
				line([(12, 3), (17, 8)])
			case .warning:
				line([(12, 3), (22, 21), (2, 21), (12, 3)])
				line([(12, 9), (12, 14)])
				line([(12, 17), (12, 18)])
		}

		return path
	}
}
