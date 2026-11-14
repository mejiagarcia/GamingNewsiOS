import Foundation

@MainActor
struct ArticleActionHandler {
	let state: AppState
	let navigation: any AppNavigationProtocol

	func handle(
		_ action: ArticleRow.Action,
		article: Article
	) {
		switch action {
			case .copy:
				navigation.copy(article)
			case .open:
				if let mode = state.preferences.articleOpenMode {
					open(article, using: mode)
				} else {
					navigation.chooseArticleOpenMode(for: article)
				}
			case .openReader:
				navigation.openReader(article)
			case .openExternally:
				navigation.openExternally(article)
			case .share:
				navigation.share(article)
			case .toggleSaved:
				Task {
					await state.toggleSaved(article)
				}
		}
	}

	private func open(
		_ article: Article,
		using mode: ArticleOpenMode
	) {
		switch mode {
			case .original:
				navigation.open(article)
			case .reader:
				navigation.openReader(article)
		}
	}
}
