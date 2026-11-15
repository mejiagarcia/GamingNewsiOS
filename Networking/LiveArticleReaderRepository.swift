import Foundation
import SwiftSoup

actor LiveArticleReaderRepository: ArticleReaderRepositoryProtocol {
	private static let minimumContentLength = 100

	func fetchArticle(from url: URL) async throws -> ReaderArticle {
		var request = URLRequest(url: url, timeoutInterval: 30)
		request.setValue("Mozilla/5.0 GamingNews iOS Reader", forHTTPHeaderField: "User-Agent")
		request.setValue("text/html,application/xhtml+xml", forHTTPHeaderField: "Accept")

		let (data, response) = try await URLSession.shared.data(for: request)
		guard let response = response as? HTTPURLResponse,
			(200..<300).contains(response.statusCode)
		else {
			throw URLError(.cannotDecodeContentData)
		}

		let html = String(decoding: data, as: UTF8.self)
		let document = try SwiftSoup.parse(html, url.absoluteString)
		try document.select("script, style, noscript, nav, footer, header, aside, form").remove()

		let content = try Self.mainContent(in: document)
		guard try content.text().count >= Self.minimumContentLength else {
			throw ReaderRepositoryError.noReadableContent
		}

		let title = try Self.firstNonEmptyText(
			try document.select("meta[property=og:title]").first()?.attr("content"),
			try document.select("meta[name=twitter:title]").first()?.attr("content"),
			try document.select("h1").first()?.text(),
			try document.title()
		) ?? ""
		let byline = try Self.firstNonEmptyText(
			try document.select("meta[name=author], meta[property=article:author]").first()?.attr("content"),
			try document.select("[rel=author], [itemprop=author], .byline, .author").first()?.text()
		)

		return ReaderArticle(
			title: title,
			byline: byline,
			elements: try Self.elements(
				in: content,
				baseURL: url
			)
		)
	}
}

private enum ReaderRepositoryError: Error {
	case noReadableContent
}

private extension LiveArticleReaderRepository {
	static func elements(
		in root: Element,
		baseURL: URL
	) throws -> [ReaderElement] {
		var result: [ReaderElement] = []
		for child in root.children().array() {
			try append(
				child,
				baseURL: baseURL,
				to: &result
			)
		}
		return result
	}

	static func mainContent(in document: Document) throws -> Element {
		let preferred = try document.select("article, main, [role=main], .article-content, .entry-content, .post-content")
		let candidates: [Element]
		if preferred.array().isEmpty {
			candidates = try document.select("body").array()
		} else {
			candidates = preferred.array()
		}
		let scored = try candidates.map { element in
			let paragraphs = try element.select("p").array()
			let textLength = try element.text().count
			let paragraphLength = try paragraphs.reduce(Int.zero) { $0 + (try $1.text().count) }
			return (element, paragraphLength + paragraphs.count * 40 + textLength / 5)
		}
		guard let best = scored.max(by: { $0.1 < $1.1 })?.0 else {
			throw ReaderRepositoryError.noReadableContent
		}
		return best
	}

	static func append(
		_ element: Element,
		baseURL: URL,
		to output: inout [ReaderElement]
	) throws {
		let tag = element.tagName().lowercased()
		let text = try element.text().trimmingCharacters(in: .whitespacesAndNewlines)
		let id = String(output.count)

		switch tag {
			case "h1", "h2", "h3", "h4", "h5", "h6":
				if !text.isEmpty, let level = Int(tag.dropFirst()) {
					output.append(ReaderElement(id: id, content: .heading(level: level, text: text)))
				}
			case "p":
				if !text.isEmpty {
					output.append(ReaderElement(id: id, content: .paragraph(text)))
				}
				for image in try element.select("img").array() {
					try appendImage(
						image,
						baseURL: baseURL,
						to: &output
					)
				}
			case "figure":
				if let image = try element.select("img").first() {
					try appendImage(
						image,
						caption: try element.select("figcaption").first()?.text(),
						baseURL: baseURL,
						to: &output
					)
				}
			case "img":
				try appendImage(
					element,
					baseURL: baseURL,
					to: &output
				)
			case "ul", "ol":
				let items = try element.select("li").array().enumerated().map { index, item in
					ReaderListItem(
						id: index,
						text: try item.text()
					)
				}
				if !items.isEmpty {
					output.append(ReaderElement(
						id: id,
						content: tag == "ul" ? .bulletList(items) : .orderedList(items)
					))
				}
			case "blockquote":
				if !text.isEmpty {
					output.append(ReaderElement(id: id, content: .quote(text)))
				}
			case "hr":
				output.append(ReaderElement(id: id, content: .divider))
			default:
				let children = element.children().array()
				if children.isEmpty {
					if text.count >= 2 {
						output.append(ReaderElement(id: id, content: .paragraph(text)))
					}
				} else {
					for child in children {
						try append(
							child,
							baseURL: baseURL,
							to: &output
						)
					}
				}
		}
	}

	static func appendImage(
		_ image: Element,
		caption: String? = nil,
		baseURL: URL,
		to output: inout [ReaderElement]
	) throws {
		let rawSource = try firstNonEmptyText(
			image.attr("src"),
			image.attr("data-src"),
			image.attr("data-lazy-src"),
			image.attr("data-original")
		)
		let source: String
		if let rawSource,
			let resolvedURL = URL(string: rawSource, relativeTo: baseURL)?.absoluteURL
		{
			source = resolvedURL.absoluteString
		} else {
			source = ""
		}
		guard let url = URL(string: source), ["http", "https"].contains(url.scheme?.lowercased() ?? "") else {
			return
		}
		let imageCaption = firstNonEmptyText(caption, try image.attr("alt"), try image.attr("title"))
		output.append(ReaderElement(id: String(output.count), content: .image(url: url, caption: imageCaption)))
	}

	static func firstNonEmptyText(_ values: String?...) -> String? {
		values.compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
			.first { !$0.isEmpty }
	}
}
