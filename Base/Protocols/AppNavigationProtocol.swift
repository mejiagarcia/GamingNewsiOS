import SwiftUI

@MainActor
protocol AppNavigationProtocol: AnyObject {

	func copy(_ article: Article)
	func open(_ article: Article)
	func openExternally(_ article: Article)
	func share(_ article: Article)
	func showSettings()
	func showSourceList(
		_ sources: [FeedSource],
		title: LocalizedStringKey
	)
	func showSources()
}
