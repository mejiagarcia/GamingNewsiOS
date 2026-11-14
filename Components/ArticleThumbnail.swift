import SwiftUI

struct ArticleThumbnail: View {

	// MARK: - Internal Constants

	let url: URL
	var fillsWidth = false

	// MARK: - Private Variables

	@State
	private var image: UIImage?

	// MARK: - View

	var body: some View {
		Group {
			if let image {
				Image(uiImage: image).resizable().scaledToFill()
			} else {
				EditorialGlyph.news.view.foregroundStyle(.secondary).frame(
					maxWidth: .infinity,
					maxHeight: .infinity
				).background(Color("ArticlePlaceholder"))
			}
		}
		.frame(
			width: fillsWidth ? nil : DesignSystem.Size.thumbnailWidth,
			height: DesignSystem.Size.thumbnailHeight
		)
		.frame(maxWidth: fillsWidth ? .infinity : nil)
		.clipped()
		.clipShape(.rect(cornerRadius: DesignSystem.Radius.small))
		.accessibilityHidden(true)
		.task(id: url) {
			image = nil
			guard let data = try? await ThumbnailLoader.shared.imageData(for: url), !Task.isCancelled
			else {
				return
			}

			image = UIImage(data: data)
		}
	}
}
