import SwiftUI

struct MutedHeadlinesView: View {

	// MARK: - Internal Constants

	let state: AppState
	let onBack: () -> Void

	// MARK: - Private Variables

	@State private var editor: MutedHeadlineRule?
	@State private var ruleToDelete: MutedHeadlineRule?

	// MARK: - View

	var body: some View {
		List {
			EditorialSettingsSection(title: "tab.reviews") {
				Text("mute.explanation")
				Toggle(
					"mute.applyToReviews",
					isOn: Binding(
						get: { state.preferences.applyGlobalMuteRulesToReviews },
						set: { enabled in
							var preferences = state.preferences
							preferences.applyGlobalMuteRulesToReviews = enabled
							Task { await state.updatePreferences(preferences) }
						}
					)
				)
				.disabled(state.isUpdating || !state.storageAvailable)
				Text("mute.applyToReviews.footer")
					.font(.caption)
					.foregroundStyle(.secondary)
			}

			Section {
				if state.preferences.mutedHeadlineRules.isEmpty {
					Text("mute.empty")
						.foregroundStyle(.secondary)
						.editorialCardRow()
				} else {
					ForEach(state.preferences.mutedHeadlineRules) { rule in
						Button {
							editor = rule
						} label: {
							VStack(alignment: .leading, spacing: DesignSystem.Spacing.compact) {
								Text(verbatim: rule.text)
									.font(.body.weight(.medium))
								Text(verbatim: ruleSummary(rule))
									.font(.caption)
									.foregroundStyle(.secondary)
							}
							.frame(maxWidth: .infinity, alignment: .leading)
						}
						.buttonStyle(EditorialPlainButtonStyle(haptic: .light))
						.editorialCardRow()
						.swipeActions {
							Button("common.delete", role: .destructive) { ruleToDelete = rule }
								.buttonStyle(EditorialButtonStyle(hierarchy: .destructive))
						}
					}
				}
			}
		}
		.editorialSettingsPage()
		.disabled(state.isUpdating || !state.storageAvailable)
		.alert(
			"error.title",
			isPresented: Binding(
				get: { state.errorMessage != nil },
				set: { if !$0 { state.errorMessage = nil } }
			)
		) {
			Button("common.ok", role: .cancel) {}
		} message: {
			Text(verbatim: state.errorMessage ?? "")
		}
		.safeAreaInset(edge: .top, spacing: .zero) {
			EditorialHeader(title: "settings.mutedHeadlines", onBack: onBack) {
				Button {
					editor = MutedHeadlineRule(text: "")
				} label: {
					EditorialGlyph.add.view
				}
				.buttonStyle(EditorialActionStyle())
				.accessibilityLabel(Text("common.add"))
				.disabled(state.isUpdating || !state.storageAvailable)
			}
		}
		.sheet(item: $editor) { rule in
			MutedHeadlineRuleEditor(
				rule: rule,
				existingRules: state.preferences.mutedHeadlineRules,
				onSave: save,
				onCancel: { editor = nil }
			)
		}
		.confirmationDialog(
			Text("mute.delete.title"),
			isPresented: Binding(
				get: { ruleToDelete != nil },
				set: { if !$0 { ruleToDelete = nil } }
			),
			titleVisibility: .visible
		) {
			Button("common.delete", role: .destructive) {
				guard let ruleToDelete else { return }
				var preferences = state.preferences
				preferences.mutedHeadlineRules.removeAll { $0.id == ruleToDelete.id }
				Task { await state.updatePreferences(preferences) }
				self.ruleToDelete = nil
			}
			.buttonStyle(EditorialButtonStyle(hierarchy: .destructive))
		} message: {
			Text("mute.delete.message")
		}
	}
}

// MARK: - Private Methods

extension MutedHeadlinesView {

	private func ruleSummary(_ rule: MutedHeadlineRule) -> String {
		let mode = switch rule.matchMode {
			case .contains: String(localized: "mute.match.contains")
			case .wholeWord: String(localized: "mute.match.wholeWord")
			case .exactPhrase: String(localized: "mute.match.exactPhrase")
		}
		let scope = rule.appliesEverywhere
			? String(localized: "mute.scope.everywhere")
			: rule.categories
				.sorted { $0.rawValue < $1.rawValue }
				.map(categoryTitle)
				.joined(separator: ", ")
		let caseMode = rule.caseSensitive ? " · \(String(localized: "mute.rule.caseSensitive"))" : ""

		return "\(mode) · \(scope)\(caseMode)"
	}

	private func categoryTitle(_ category: NewsCategory) -> String {
		switch category {
			case .all: String(localized: "category.all")
			case .sony: String(localized: "category.playstation")
			case .microsoft: String(localized: "category.xbox")
			case .nintendo: String(localized: "category.nintendo")
			case .pc: String(localized: "category.pc")
		}
	}

	private func save(_ rule: MutedHeadlineRule) {
		var preferences = state.preferences
		if let index = preferences.mutedHeadlineRules.firstIndex(where: { $0.id == rule.id }) {
			preferences.mutedHeadlineRules[index] = rule
		} else {
			preferences.mutedHeadlineRules.append(rule)
		}
		Task {
			await state.updatePreferences(preferences)
			editor = nil
		}
	}
}

private struct MutedHeadlineRuleEditor: View {

	// MARK: - Internal Constants

	let onSave: (MutedHeadlineRule) -> Void
	let onCancel: () -> Void

	// MARK: - Private Constants

	private let existingRules: [MutedHeadlineRule]
	private let originalID: String

	// MARK: - Private Variables

	@State private var text: String
	@State private var matchMode: HeadlineMatchMode
	@State private var caseSensitive: Bool
	@State private var appliesEverywhere: Bool
	@State private var categories: Set<NewsCategory>

	// MARK: - Life Cycle

	init(
		rule: MutedHeadlineRule,
		existingRules: [MutedHeadlineRule],
		onSave: @escaping (MutedHeadlineRule) -> Void,
		onCancel: @escaping () -> Void
	) {
		self.existingRules = existingRules
		self.onSave = onSave
		self.onCancel = onCancel
		originalID = rule.id
		_text = State(initialValue: rule.text)
		_matchMode = State(initialValue: rule.matchMode)
		_caseSensitive = State(initialValue: rule.caseSensitive)
		_appliesEverywhere = State(initialValue: rule.appliesEverywhere)
		_categories = State(initialValue: rule.categories)
	}

	// MARK: - View

	var body: some View {
		List {
			EditorialSettingsSection(title: "mute.rule.text.section") {
				EditorialField(prompt: "mute.rule.text", text: $text)
					.textInputAutocapitalization(.never)
					.autocorrectionDisabled()
				if isDuplicate {
					Text("mute.error.duplicate").foregroundStyle(Color.accentColor)
				}
				if matchMode == .wholeWord && normalizedText.contains(where: \.isWhitespace) {
					Text("mute.error.wholeWord").foregroundStyle(Color.accentColor)
				}
			}
			EditorialSettingsSection(title: "mute.rule.match.section") {
				EditorialChoice(title: "mute.match.contains", value: .contains, selection: $matchMode)
				EditorialChoice(title: "mute.match.wholeWord", value: .wholeWord, selection: $matchMode)
				EditorialChoice(title: "mute.match.exactPhrase", value: .exactPhrase, selection: $matchMode)
				Toggle("mute.rule.caseSensitive", isOn: $caseSensitive)
			}
			EditorialSettingsSection(title: "mute.rule.scope.section") {
				Toggle("mute.scope.everywhere", isOn: $appliesEverywhere)
				if !appliesEverywhere {
					ForEach(NewsCategory.allCases) { category in
						Toggle(category.title, isOn: categoryBinding(category))
					}
					if categories.isEmpty {
						Text("mute.error.scope").foregroundStyle(Color.accentColor)
					}
				}
			}
		}
		.editorialSettingsPage()
		.safeAreaInset(edge: .top, spacing: .zero) {
			EditorialHeader(title: originalExists ? "mute.rule.edit" : "mute.rule.add") {
				Button(action: onCancel) {
					EditorialGlyph.close.view
				}
				.buttonStyle(EditorialButtonStyle(hierarchy: .tertiary))
				.accessibilityLabel(Text("common.cancel"))

				Button("common.save") { onSave(makeRule()) }
					.buttonStyle(EditorialActionStyle())
					.disabled(!isValid)
			}
		}
	}
}

// MARK: - Private Methods

private extension MutedHeadlineRuleEditor {

	var isDuplicate: Bool {
		guard !normalizedText.isEmpty else { return false }
		return existingRules.contains { rule in
			guard rule.id != originalID,
				rule.matchMode == matchMode,
				rule.caseSensitive == caseSensitive,
				rule.appliesEverywhere == appliesEverywhere,
				(appliesEverywhere || rule.categories == categories)
			else { return false }

			return comparableText(rule.text, caseSensitive: caseSensitive)
				== comparableText(text, caseSensitive: caseSensitive)
		}
	}

	var isValid: Bool {
		!normalizedText.isEmpty
			&& !isDuplicate
			&& (matchMode != .wholeWord || !normalizedText.contains(where: \.isWhitespace))
			&& (appliesEverywhere || !categories.isEmpty)
	}

	var normalizedText: String {
		normalize(text)
	}

	var originalExists: Bool {
		existingRules.contains { $0.id == originalID }
	}

	func categoryBinding(_ category: NewsCategory) -> Binding<Bool> {
		Binding(
			get: { categories.contains(category) },
			set: { selected in
				if selected {
					categories.insert(category)
				} else {
					categories.remove(category)
				}
			}
		)
	}

	func comparableText(_ value: String, caseSensitive: Bool) -> String {
		let value = normalize(value)
		return caseSensitive ? value : value.lowercased()
	}

	func makeRule() -> MutedHeadlineRule {
		MutedHeadlineRule(
			id: originalID,
			text: normalizedText,
			matchMode: matchMode,
			caseSensitive: caseSensitive,
			appliesEverywhere: appliesEverywhere,
			categories: categories
		)
	}

	func normalize(_ value: String) -> String {
		value
			.precomposedStringWithCanonicalMapping
			.split(whereSeparator: \.isWhitespace)
			.joined(separator: " ")
	}
}
