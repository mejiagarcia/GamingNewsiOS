import SwiftUI

// MARK: - Settings

struct SettingsView: View {

	// MARK: - Internal Constants

	let state: AppState
	let navigation: any AppNavigationProtocol
	let onAppearanceChange: () -> Void

	// MARK: - View

	var body: some View {
		Form {
			Section("settings.content") {
				Picker(
					"settings.language",
					selection: binding(\.language)
				) {
					ForEach(ContentLanguage.allCases) { language in Text(language.title).tag(language) }
				}
				Button {
					navigation.showSources()
				} label: {
					Label(
						"settings.sources",
						systemImage: "line.3.horizontal.decrease.circle"
					)
				}
			}
			Section("settings.display") {
				Picker(
					"settings.appearance",
					selection: binding(\.appearance)
				) {
					ForEach(AppAppearance.allCases) { appearance in Text(appearance.title).tag(appearance) }
				}
				Toggle(
					"settings.images",
					isOn: binding(\.showImages)
				)
			}
		}
		.disabled(!state.storageAvailable || state.isUpdating)
		.navigationTitle(Text("settings.title"))
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

// MARK: - Private Methods

extension SettingsView {

	private func binding<Value: Equatable>(_ keyPath: WritableKeyPath<AppPreferences, Value>)
		-> Binding<Value>
	{
		Binding(
			get: { state.preferences[keyPath: keyPath] },
			set: { value in
				var preferences = state.preferences
				preferences[keyPath: keyPath] = value
				Task {
					await state.updatePreferences(preferences)
					onAppearanceChange()
				}
			}
		)
	}
}
