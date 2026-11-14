import Foundation

nonisolated struct ArticleFilterResult: Sendable {
	let articles: [Article]
	let mutedArticleIDs: Set<String>
}

actor ArticleFilter {

	func filter(
		_ articles: [Article],
		query: String
	) -> [Article] {
		filterFeed(
			articles,
			query: query,
			rules: [],
			context: FeedContext(kind: .news, language: .en, category: .all),
			applyGlobalRulesToReviews: false,
			revealMuted: true
		).articles
	}

	func filterFeed(
		_ articles: [Article],
		query: String,
		rules: [MutedHeadlineRule],
		context: FeedContext,
		applyGlobalRulesToReviews: Bool,
		revealMuted: Bool
	) -> ArticleFilterResult {
		let query = query.trimmingCharacters(in: .whitespacesAndNewlines)
		let candidates = query.isEmpty
			? articles
			: articles.filter { $0.title.localizedStandardContains(query) }
		let applicableRules = rules.filter { rule in
			if context.kind == .reviews {
				return applyGlobalRulesToReviews && rule.appliesEverywhere
			}
			return rule.appliesEverywhere || rule.categories.contains(context.category)
		}
		let mutedIDs = Set(candidates.filter { article in
			applicableRules.contains { matches(article.title, rule: $0) }
		}.map(\.id))

		return ArticleFilterResult(
			articles: revealMuted ? candidates : candidates.filter { !mutedIDs.contains($0.id) },
			mutedArticleIDs: mutedIDs
		)
	}

	private func matches(_ title: String, rule: MutedHeadlineRule) -> Bool {
		let needle = normalize(rule.text)
		let haystack = normalize(title)

		guard !needle.isEmpty else {
			return false
		}

		var searchStart = haystack.startIndex
		while searchStart < haystack.endIndex,
			let range = haystack.range(
				of: needle,
				options: rule.caseSensitive ? [] : [.caseInsensitive],
				range: searchStart..<haystack.endIndex
			) {
			if rule.matchMode == .contains
				|| (isBoundary(before: range.lowerBound, in: haystack)
					&& isBoundary(after: range.upperBound, in: haystack)) {
				return true
			}
			searchStart = range.lowerBound < haystack.endIndex
				? haystack.index(after: range.lowerBound)
				: haystack.endIndex
		}

		return false
	}

	private func isBoundary(before index: String.Index, in text: String) -> Bool {
		guard index > text.startIndex, let character = text[..<index].last else {
			return true
		}

		return !isWordCharacter(character)
	}

	private func isBoundary(after index: String.Index, in text: String) -> Bool {
		guard index < text.endIndex, let character = text[index...].first else {
			return true
		}

		return !isWordCharacter(character)
	}

	private func isWordCharacter(_ character: Character) -> Bool {
		character.unicodeScalars.contains { scalar in
			CharacterSet.alphanumerics.contains(scalar)
				|| CharacterSet.nonBaseCharacters.contains(scalar)
				|| scalar.properties.generalCategory == .connectorPunctuation
		}
	}

	private func normalize(_ value: String) -> String {
		value
			.precomposedStringWithCanonicalMapping
			.split(whereSeparator: \.isWhitespace)
			.joined(separator: " ")
	}
}
