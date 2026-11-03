import SwiftUI

struct ArticleThumbnail: View {

	// MARK: - Internal Constants

	let url: URL

	// MARK: - Private Variables

	@State
	private var image: UIImage?

	// MARK: - View

	var body: some View {
		Group {
			if let image {
				Image(uiImage: image).resizable().scaledToFill()
			} else {
				Image(systemName: "newspaper").foregroundStyle(.secondary).frame(
					maxWidth: .infinity,
					maxHeight: .infinity
				).background(Color("ArticlePlaceholder"))
			}
		}
		.frame(
			width: DesignSystem.Size.thumbnailWidth,
			height: DesignSystem.Size.thumbnailHeight
		)
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
