import SwiftUI

struct SourceSettingsView: View {

	// MARK: - Internal Constants

	let state: AppState
	let navigation: any AppNavigationProtocol

	// MARK: - View

	var body: some View {
		List {
			ForEach(
				FeedLanguage.allCases,
				id: \.self
			) { language in
				Section(language == .en ? "language.english" : "language.spanish") {
					ForEach(NewsCategory.allCases) { category in
						let sources = state.sources.filter {
							$0.language == language && $0.kind == .news && $0.category == category
						}
						if !sources.isEmpty {
							Button {
								navigation.showSourceList(
									sources,
									title: category.title
								)
							} label: {
								Text(category.title)
							}
						}
					}
					let reviews = state.sources.filter { $0.language == language && $0.kind == .reviews }
					if !reviews.isEmpty {
						Button {
							navigation.showSourceList(
								reviews,
								title: "tab.reviews"
							)
						} label: {
							Text("tab.reviews")
						}
					}
				}
			}
			Section {
				Button("settings.restoreSources") {
					var preferences = state.preferences
					preferences.disabledSourceIDs.removeAll()
					Task { await state.updatePreferences(preferences) }
				}
				.disabled(state.preferences.disabledSourceIDs.isEmpty)
			}
		}
		.disabled(!state.storageAvailable || state.isUpdating)
		.navigationTitle(Text("settings.sources"))
		.alert(
			"error.title",
			isPresented: Binding(
				get: { state.errorMessage != nil },
				set: { if !$0 { state.errorMessage = nil } }
			)
		) {
			Button(
				"common.ok",
				role: .cancel
			) {}
		} message: {
			Text(verbatim: state.errorMessage ?? "")
		}
	}
}
