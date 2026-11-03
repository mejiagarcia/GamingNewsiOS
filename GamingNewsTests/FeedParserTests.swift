import Foundation
import Testing

@testable import GamingNews

struct FeedParserTests {
	@Test func readsRSSFieldsAndResolvesRelativeImages() throws {
		let parser = FeedParser(source: TestFixtures.newsSource)
		let articles = try parser.parse(TestFixtures.data("""
		<?xml version="1.0" encoding="UTF-8"?>
		<rss version="2.0" xmlns:dc="http://purl.org/dc/elements/1.1/"><channel><item>
		<title>New &amp;amp; Improved &amp;quot;Game&amp;quot;</title>
		<link>https://publisher.example/story#top</link>
		<description><![CDATA[<p>A&nbsp;summary</p><img src="/cover.jpg">]]></description>
		<dc:creator>Jane Doe</dc:creator>
		<pubDate>Tue, 03 Jun 2025 10:00:00 +0000</pubDate>
		</item></channel></rss>
		"""))

		let article = try #require(articles.first)
		#expect(articles.count == 1)
		#expect(article.title == "New & Improved \"Game\"")
		#expect(article.summary == "A summary")
		#expect(article.url.absoluteString == "https://publisher.example/story#top")
		#expect(article.id == "https://publisher.example/story")
		#expect(article.imageURL?.absoluteString == "https://publisher.example/cover.jpg")
		#expect(article.author == "Jane Doe")
		#expect(article.publisher == TestFixtures.newsSource.name)
		#expect(article.publishedAt != nil)
	}

	@Test func readsAtomAlternateLinkAndCDATA() throws {
		let parser = FeedParser(source: TestFixtures.newsSource)
		let articles = try parser.parse(TestFixtures.data("""
		<feed xmlns="http://www.w3.org/2005/Atom">
		<entry><title>Atom story</title><link rel="self" href="https://publisher.example/self"/>
		<link rel="alternate" href="https://publisher.example/atom"/>
		<summary><![CDATA[<b>Atom</b> summary]]></summary>
		<author><name>Atom Author</name></author>
		<updated>2025-06-03T10:00:00Z</updated></entry></feed>
		"""))

		let article = try #require(articles.first)
		#expect(articles.count == 1)
		#expect(article.title == "Atom story")
		#expect(article.url.absoluteString == "https://publisher.example/atom")
		#expect(article.summary == "Atom summary")
		#expect(article.author == "Atom Author")
		#expect(article.publishedAt != nil)
	}

	@Test func prefersImageEnclosuresAndSkipsInvalidItems() throws {
		let parser = FeedParser(source: TestFixtures.newsSource)
		let articles = try parser.parse(TestFixtures.data("""
		<rss><channel>
		<item><title>Missing link</title></item>
		<item><link>https://publisher.example/empty</link></item>
		<item><title>Image enclosure</title><link>https://publisher.example/image</link>
		<enclosure url="https://images.example/cover.png" type="image/png"/></item>
		<item><title>Audio enclosure</title><link>https://publisher.example/audio</link>
		<enclosure url="https://images.example/audio.mp3" type="audio/mpeg"/></item>
		</channel></rss>
		"""))

		#expect(articles.count == 2)
		#expect(articles.first?.imageURL?.absoluteString == "https://images.example/cover.png")
		#expect(articles.last?.imageURL == nil)
	}

	@Test func rejectsMalformedXML() {
		let parser = FeedParser(source: TestFixtures.newsSource)
		let result = Result { try parser.parse(TestFixtures.data("<rss><item>")) }

		if case .success = result {
			Issue.record("Malformed XML should fail parsing")
		}
	}
}
