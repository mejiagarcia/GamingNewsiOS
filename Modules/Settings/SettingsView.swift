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
		List {

			EditorialSettingsSection(title: "settings.articleOpening") {
				EditorialChoice(title: "settings.articleOpening.ask", value: nil, selection: binding(\.articleOpenMode))
				EditorialChoice(title: "article.openMode.reader", value: .reader, selection: binding(\.articleOpenMode))
				EditorialChoice(title: "article.openMode.original", value: .original, selection: binding(\.articleOpenMode))
			}
			.disabled(!state.storageAvailable || state.isUpdating)
			EditorialSettingsSection(title: "settings.language") {
				ForEach(ContentLanguage.allCases) { language in
					EditorialChoice(title: language.title, value: language, selection: binding(\.language))
				}
			}
			.disabled(!state.storageAvailable || state.isUpdating)
			EditorialSettingsSection(title: "settings.content") {
				Button {
					navigation.showSources()
				} label: {
					EditorialLabel(title: "settings.sources", glyph: .filters)
				}
				Button {
					navigation.showMutedHeadlines()
				} label: {
					EditorialLabel(title: "settings.mutedHeadlines", glyph: .mute)
				}
			}
			.buttonStyle(EditorialButtonStyle(hierarchy: .secondary))
			.disabled(!state.storageAvailable || state.isUpdating)
			EditorialSettingsSection(title: "settings.notifications") {
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
				.buttonStyle(EditorialButtonStyle(hierarchy: .secondary))
				.disabled(notifications.isUpdating)
			}
			EditorialSettingsSection(title: "settings.display") {
				Text("settings.appearance")
				ForEach(AppAppearance.allCases) { appearance in
					EditorialChoice(title: appearance.title, value: appearance, selection: binding(\.appearance))
				}
				Toggle(
					"settings.images",
					isOn: binding(\.showImages)
				)
			}
			.disabled(!state.storageAvailable || state.isUpdating)
		}
		.editorialSettingsPage()
		.onAppear { AnalyticsService.screen("settings") }
		.task { await notifications.refresh() }
		.editorialScrollingHeader {
			EditorialHeader(title: "settings.title", onBack: navigation.goBack) {
				EmptyView()
			}
		}
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
