import Foundation
import Observation

@MainActor
@Observable
final class ReaderViewModel {
	enum State {
		case loading
		case failed
		case content(ReaderArticle)
	}

	private let repository: any ArticleReaderRepositoryProtocol
	private var requestID = UUID()

	let article: Article
	var state: State = .loading

	init(
		article: Article,
		repository: any ArticleReaderRepositoryProtocol = LiveArticleReaderRepository()
	) {
		self.article = article
		self.repository = repository
	}

	func load() async {
		let id = UUID()
		requestID = id
		state = .loading

		do {
			let result = try await repository.fetchArticle(from: article.url)
			guard requestID == id, !Task.isCancelled else { return }
			state = .content(
				ReaderArticle(
					title: result.title.isEmpty ? article.title : result.title,
					byline: result.byline ?? article.publisher,
					elements: result.elements
				)
			)
		} catch is CancellationError {
			return
		} catch {
			guard requestID == id else { return }
			state = .failed
		}
	}
}
