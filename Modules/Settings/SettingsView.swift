import SwiftUI
import UserNotifications

// MARK: - Settings

struct SettingsView: View {

	// MARK: - Internal Constants

	let state: AppState
	let navigation: any AppNavigationProtocol
	let notifications: PushNotificationService
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
			.disabled(!state.storageAvailable || state.isUpdating)
			Section("settings.notifications") {
				Button {
					Task {
						do {
							try await notifications.requestOrOpenSettings()
						} catch {
							state.errorMessage = String(localized: "error.notifications")
							HapticFeedback.error()
						}
					}
				} label: {
					VStack(alignment: .leading) {
						Text("settings.notifications")
						Text(notificationStatus).font(.caption).foregroundStyle(.secondary)
					}
				}
				.disabled(notifications.isUpdating)
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
			.disabled(!state.storageAvailable || state.isUpdating)
		}
		.onAppear { AnalyticsService.screen("settings") }
		.task { await notifications.refresh() }
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

	private var notificationStatus: LocalizedStringKey {
		switch notifications.authorizationStatus {
			case .notDetermined: "notifications.enable"
			case .denied: "notifications.denied"
			case .authorized, .provisional, .ephemeral: "notifications.enabled"
			@unknown default: "notifications.manage"
		}
	}

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
