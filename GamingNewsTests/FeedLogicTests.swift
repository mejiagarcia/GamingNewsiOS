import Testing

@testable import GamingNews

struct FeedLogicTests {
	@Test func articleFilterTrimsQueryAndMatchesHeadlineOnly() async {
		let first = TestFixtures.article(id: "one", title: "The New Console")
		let second = TestFixtures.article(id: "two", title: "A game update", summary: "New console")
		let filter = ArticleFilter()

		let filtered = await filter.filter([first, second], query: "  console \n")
		let all = await filter.filter([first, second], query: "  \n")

		#expect(filtered == [first])
		#expect(all == [first, second])
	}

	@Test @MainActor func loadsSnapshotAndAppliesSearch() async {
		let first = TestFixtures.article(id: "one", title: "Console launch")
		let second = TestFixtures.article(id: "two", title: "Studio update")
		let repository = StubFeedRepository(snapshot: FeedSnapshot(
			articles: [first, second],
			failedSourceIDs: [],
			staleSourceIDs: [],
			enabledSourceCount: 2
		))
		let model = FeedViewModel(kind: .news, repository: repository)
		model.query = "console"

		await model.load(TestFixtures.feedRequest)

		#expect(model.articles == [first])
		#expect(model.loaded)
		#expect(!model.isLoading)
		#expect(!model.failed)
		#expect(!model.partialFailure)
		#expect(!model.noSources)
	}

	@Test @MainActor func distinguishesTotalAndPartialFeedFailures() async {
		let emptyRepository = StubFeedRepository(snapshot: FeedSnapshot(
			articles: [],
			failedSourceIDs: ["source-a"],
			staleSourceIDs: [],
			enabledSourceCount: 1
		))
		let emptyModel = FeedViewModel(kind: .news, repository: emptyRepository)
		await emptyModel.load(TestFixtures.feedRequest)

		#expect(emptyModel.failed)
		#expect(emptyModel.loaded)

		let partialRepository = StubFeedRepository(snapshot: FeedSnapshot(
			articles: [TestFixtures.article(id: "one", title: "Available")],
			failedSourceIDs: ["source-b"],
			staleSourceIDs: ["source-b"],
			enabledSourceCount: 2
		))
		let partialModel = FeedViewModel(kind: .news, repository: partialRepository)
		await partialModel.load(TestFixtures.feedRequest)

		#expect(partialModel.partialFailure)
		#expect(partialModel.stale)
		#expect(!partialModel.failed)
	}

	@Test @MainActor func representsNoSourcesAndRepositoryFailure() async {
		let noSourcesModel = FeedViewModel(
			kind: .news,
			repository: StubFeedRepository()
		)
		await noSourcesModel.load(TestFixtures.feedRequest)
		#expect(noSourcesModel.noSources)
		#expect(!noSourcesModel.failed)

		let failedModel = FeedViewModel(
			kind: .news,
			repository: StubFeedRepository(error: TestError.expected)
		)
		await failedModel.load(TestFixtures.feedRequest)
		#expect(failedModel.failed)
		#expect(failedModel.loaded)
	}
}
