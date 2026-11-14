import SwiftUI

struct ReaderView: View {
	// MARK: - Internal Constants

	let showImages: Bool
	let navigation: any AppNavigationProtocol
	let onOpenInBrowser: () -> Void

	// MARK: - Private Variables

	@State private var model: ReaderViewModel

	// MARK: - Life Cycle

	init(
		article: Article,
		showImages: Bool,
		navigation: any AppNavigationProtocol,
		onOpenInBrowser: @escaping () -> Void
	) {
		self.showImages = showImages
		self.navigation = navigation
		self.onOpenInBrowser = onOpenInBrowser
		_model = State(initialValue: ReaderViewModel(article: article))
	}

	// MARK: - View

	var body: some View {
		Group {
			switch model.state {
				case .loading:
					ProgressView("reader.loading")
						.frame(maxWidth: .infinity, maxHeight: .infinity)
				case .failed:
					ReaderErrorView(
						onRetry: { Task { await model.load() } },
						onOpenInBrowser: onOpenInBrowser
					)
				case .content(let article):
					ReaderContentView(article: article, showImages: showImages)
			}
		}
		.editorialCanvas()
		.navigationTitle("reader.title")
		.navigationBarTitleDisplayMode(.inline)
		.toolbar {
			ToolbarItem(placement: .topBarTrailing) {
				Menu {
					Button {
						navigation.share(model.article)
					} label: {
						Label("article.share", systemImage: "square.and.arrow.up")
					}
					Button {
						navigation.copy(model.article)
					} label: {
						Label("article.copy", systemImage: "doc.on.doc")
					}
				} label: {
					Image(systemName: "ellipsis.circle")
				}
				.accessibilityLabel(Text("reader.actions"))
			}
		}
		.task { await model.load() }
	}
}

private struct ReaderContentView: View {
	let article: ReaderArticle
	let showImages: Bool

	var body: some View {
		ScrollView {
			LazyVStack(alignment: .leading, spacing: DesignSystem.Spacing.regular) {
				if !article.title.isEmpty {
					Text(verbatim: article.title)
						.font(DesignSystem.Typography.display(.largeTitle))
						.accessibilityAddTraits(.isHeader)
				}
				if let byline = article.byline {
					Text(verbatim: byline)
						.font(.subheadline)
						.foregroundStyle(.secondary)
				}
				ForEach(article.elements) { element in
					ReaderElementView(element: element, showImages: showImages)
				}
			}
			.frame(maxWidth: 720, alignment: .leading)
			.frame(maxWidth: .infinity, alignment: .top)
			.padding(.horizontal, DesignSystem.Spacing.regular)
			.padding(.vertical, DesignSystem.Spacing.large)
		}
	}
}

private struct ReaderElementView: View {
	let element: ReaderElement
	let showImages: Bool

	var body: some View {
		switch element.content {
			case .heading(let level, let text):
				Text(verbatim: text)
					.font(headingFont(level))
					.accessibilityAddTraits(.isHeader)
					.frame(maxWidth: .infinity, alignment: .leading)
			case .paragraph(let text):
				Text(verbatim: text)
					.font(.body)
					.lineSpacing(DesignSystem.Spacing.compact)
					.frame(maxWidth: .infinity, alignment: .leading)
			case .image(let url, let caption):
				if showImages {
					AsyncImage(url: url) { image in
						image.resizable().scaledToFit()
					} placeholder: {
						ProgressView().frame(maxWidth: .infinity).padding()
					}
					.clipShape(.rect(cornerRadius: DesignSystem.Radius.small))
					if let caption {
						Text(verbatim: caption)
							.font(.caption)
							.foregroundStyle(.secondary)
					}
				} else {
					Label("reader.imageHidden", systemImage: "photo")
						.font(.subheadline)
						.foregroundStyle(.secondary)
						.frame(maxWidth: .infinity, alignment: .leading)
				}
			case .bulletList(let items):
				VStack(alignment: .leading, spacing: DesignSystem.Spacing.compact) {
					ForEach(items.indices, id: \.self) { index in
						Text("• \(items[index])").frame(maxWidth: .infinity, alignment: .leading)
					}
				}
				.font(.body)
			case .orderedList(let items):
				VStack(alignment: .leading, spacing: DesignSystem.Spacing.compact) {
					ForEach(items.indices, id: \.self) { index in
						Text("\(index + 1). \(items[index])")
							.frame(maxWidth: .infinity, alignment: .leading)
					}
				}
				.font(.body)
			case .quote(let text):
				Text(verbatim: text)
					.font(.body.italic())
					.frame(maxWidth: .infinity, alignment: .leading)
					.editorialCard()
					.padding(.bottom, DesignSystem.Size.cardOffset)
			case .divider:
				Divider()
		}
	}

	private func headingFont(_ level: Int) -> Font {
		switch level {
			case 1: DesignSystem.Typography.display(.title)
			case 2: DesignSystem.Typography.display(.title2)
			case 3: DesignSystem.Typography.display(.title3)
			case 4: DesignSystem.Typography.display(.headline)
			default: .subheadline.weight(.semibold)
		}
	}
}

private struct ReaderErrorView: View {
	let onRetry: () -> Void
	let onOpenInBrowser: () -> Void

	var body: some View {
		ContentUnavailableView {
			Label("reader.failed", systemImage: "doc.text.magnifyingglass")
		} description: {
			Text("reader.failed.description")
		} actions: {
			Button("reader.retry", action: onRetry)
				.buttonStyle(EditorialActionStyle())
			Button("reader.openBrowser", action: onOpenInBrowser)
				.buttonStyle(EditorialActionStyle())
		}
		.padding(DesignSystem.Spacing.large)
	}
}
