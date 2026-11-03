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
				navigation.open(article)
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
}
