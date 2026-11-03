import SwiftUI

struct SourceListView: View {

	// MARK: - Internal Constants

	let state: AppState
	let sources: [FeedSource]
	let title: LocalizedStringKey

	// MARK: - View

	var body: some View {
		List(sources) { source in
			Toggle(
				isOn: Binding(
					get: { !state.preferences.disabledSourceIDs.contains(source.id) },
					set: { enabled in
						var preferences = state.preferences
						if enabled {
							preferences.disabledSourceIDs.remove(source.id)
						} else {
							preferences.disabledSourceIDs.insert(source.id)
						}
						Task { await state.updatePreferences(preferences) }
					}
				)
			) { Text(verbatim: source.name) }
		}
		.disabled(!state.storageAvailable || state.isUpdating)
		.navigationTitle(Text(title))
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
