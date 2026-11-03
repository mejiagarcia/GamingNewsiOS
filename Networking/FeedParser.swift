import Foundation

// MARK: - RSS and Atom parsing

nonisolated enum FeedParseError: Error {
	case invalidDocument
}

nonisolated final class FeedParser: NSObject {

	// MARK: - Private Constants

	private let source: FeedSource

	// MARK: - Private Variables

	private var articles: [Article] = []
	private var element = ""
	private var fields: [String: String] = [:]
	private var imageLink: String?
	private var inItem = false
	private var itemLink: String?

	// MARK: - Life Cycle

	init(source: FeedSource) {
		self.source = source
	}
}

// MARK: - XMLParserDelegate

nonisolated extension FeedParser: XMLParserDelegate {

	func parse(_ data: Data) throws -> [Article] {
		let parser = XMLParser(data: data)
		parser.delegate = self
		parser.shouldResolveExternalEntities = false

		guard parser.parse() else {
			throw parser.parserError ?? FeedParseError.invalidDocument
		}

		return articles
	}

	func parser(
		_ parser: XMLParser,
		didStartElement elementName: String,
		namespaceURI: String?,
		qualifiedName qName: String?,
		attributes: [String: String]
	) {
		let name = elementName.lowercased()

		if name == "item" || name == "entry" {
			inItem = true
			fields = [:]
			itemLink = nil
			imageLink = nil
		}

		guard inItem else {
			return
		}

		element = name

		if name == "link", let href = attributes["href"],
			attributes["rel"] == nil || attributes["rel"] == "alternate"
		{
			itemLink = href
		}

		if ["media:content", "media:thumbnail", "enclosure"].contains(name),
			let url = attributes["url"],
			name != "enclosure" || attributes["type"]?.hasPrefix("image/") == true
		{
			imageLink = imageLink ?? url
		}
	}

	func parser(
		_ parser: XMLParser,
		foundCharacters string: String
	) {
		guard inItem else {
			return
		}

		fields[element, default: ""] += string
	}

	func parser(
		_ parser: XMLParser,
		foundCDATA CDATABlock: Data
	) {
		if let text = String(
			data: CDATABlock,
			encoding: .utf8
		) {
			self.parser(
				parser,
				foundCharacters: text
			)
		}
	}

	func parser(
		_ parser: XMLParser,
		didEndElement elementName: String,
		namespaceURI: String?,
		qualifiedName qName: String?
	) {
		let name = elementName.lowercased()

		guard inItem else {
			return
		}

		if name == "item" || name == "entry" {
			appendArticle()
			inItem = false
		}

		element = ""
	}
}

// MARK: - Private Methods

nonisolated extension FeedParser {

	private func appendArticle() {
		let title = clean(fields["title"] ?? "")
		let link = (itemLink ?? fields["link"] ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

		guard !title.isEmpty, let url = URL(string: link), let id = ArticleIdentity.make(url) else {
			return
		}

		let rawSummary =
			fields["description"] ?? fields["summary"] ?? fields["content:encoded"] ?? fields["content"]
			?? ""
		let image = imageLink ?? firstImage(in: rawSummary)
		let imageURL = image.flatMap {
			URL(
				string: $0,
				relativeTo: url
			)?.absoluteURL
		}.flatMap { ArticleIdentity.make($0) == nil ? nil : $0 }
		let author = clean(fields["dc:creator"] ?? fields["author"] ?? fields["name"] ?? "")
		let date = parseDate(
			fields["pubdate"] ?? fields["published"] ?? fields["updated"] ?? fields["dc:date"]
		)

		articles.append(
			Article(
				id: id,
				title: title,
				summary: clean(rawSummary),
				url: url,
				imageURL: imageURL,
				author: author.isEmpty ? nil : author,
				publisher: source.name,
				publishedAt: date
			)
		)
	}

	private func clean(_ value: String) -> String {
		value.replacingOccurrences(
			of: "<[^>]+>",
			with: " ",
			options: .regularExpression
		)
		.replacingOccurrences(
			of: "&amp;",
			with: "&"
		)
		.replacingOccurrences(
			of: "&nbsp;",
			with: " "
		)
		.replacingOccurrences(
			of: "&quot;",
			with: "\""
		)
		.replacingOccurrences(
			of: "&#39;",
			with: "'"
		)
		.replacingOccurrences(
			of: "\\s+",
			with: " ",
			options: .regularExpression
		)
		.trimmingCharacters(in: .whitespacesAndNewlines)
	}

	private func firstImage(in html: String) -> String? {
		guard
			let regex = try? NSRegularExpression(
				pattern: "<img[^>]+src\\s*=\\s*['\"]([^'\"]+)",
				options: .caseInsensitive
			),
			let match = regex.firstMatch(
				in: html,
				range: NSRange(
					html.startIndex...,
					in: html
				)
			),
			let range = Range(
				match.range(at: 1),
				in: html
			)
		else {
			return nil
		}

		return String(html[range])
	}

	private func parseDate(_ value: String?) -> Date? {
		guard let value else {
			return nil
		}

		let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
		let iso = ISO8601DateFormatter()

		if let date = iso.date(from: trimmed) {
			return date
		}

		iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

		if let date = iso.date(from: trimmed) {
			return date
		}

		let formatter = DateFormatter()
		formatter.locale = Locale(identifier: "en_US_POSIX")

		for format in [
			"EEE, dd MMM yyyy HH:mm:ss Z", "EEE, d MMM yyyy HH:mm:ss Z", "dd MMM yyyy HH:mm:ss Z",
			"EEE, dd MMM yyyy HH:mm Z"
		] {
			formatter.dateFormat = format

			if let date = formatter.date(from: trimmed) {
				return date
			}
		}

		return nil
	}
}
