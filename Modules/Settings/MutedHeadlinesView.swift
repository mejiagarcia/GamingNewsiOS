import SwiftUI

struct MutedHeadlinesView: View {

	// MARK: - Internal Constants

	let state: AppState

	// MARK: - Private Variables

	@State private var editor: MutedHeadlineRule?
	@State private var ruleToDelete: MutedHeadlineRule?

	// MARK: - View

	var body: some View {
		List {
			Section {
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
			} footer: {
				Text("mute.applyToReviews.footer")
			}

			Section {
				if state.preferences.mutedHeadlineRules.isEmpty {
					Text("mute.empty")
						.foregroundStyle(.secondary)
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
						.buttonStyle(.plain)
						.swipeActions {
							Button("common.delete", role: .destructive) { ruleToDelete = rule }
						}
					}
				}
			}
		}
		.disabled(state.isUpdating || !state.storageAvailable)
		.navigationTitle(Text("settings.mutedHeadlines"))
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
		.toolbar {
			ToolbarItem(placement: .topBarTrailing) {
				Button("common.add", systemImage: "plus") {
					editor = MutedHeadlineRule(text: "")
				}
				.disabled(state.isUpdating || !state.storageAvailable)
			}
		}
		.sheet(item: $editor) { rule in
			NavigationStack {
				MutedHeadlineRuleEditor(
					rule: rule,
					existingRules: state.preferences.mutedHeadlineRules,
					onSave: save,
					onCancel: { editor = nil }
				)
			}
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
		Form {
			Section("mute.rule.text.section") {
				TextField("mute.rule.text", text: $text)
					.textInputAutocapitalization(.never)
					.autocorrectionDisabled()
				if isDuplicate {
					Text("mute.error.duplicate").foregroundStyle(.red)
				}
				if matchMode == .wholeWord && normalizedText.contains(where: \.isWhitespace) {
					Text("mute.error.wholeWord").foregroundStyle(.red)
				}
			}
			Section("mute.rule.match.section") {
				Picker("mute.rule.match", selection: $matchMode) {
					Text("mute.match.contains").tag(HeadlineMatchMode.contains)
					Text("mute.match.wholeWord").tag(HeadlineMatchMode.wholeWord)
					Text("mute.match.exactPhrase").tag(HeadlineMatchMode.exactPhrase)
				}
				Toggle("mute.rule.caseSensitive", isOn: $caseSensitive)
			}
			Section("mute.rule.scope.section") {
				Toggle("mute.scope.everywhere", isOn: $appliesEverywhere)
				if !appliesEverywhere {
					ForEach(NewsCategory.allCases) { category in
						Toggle(category.title, isOn: categoryBinding(category))
					}
					if categories.isEmpty {
						Text("mute.error.scope").foregroundStyle(.red)
					}
				}
			}
		}
		.navigationTitle(originalExists ? Text("mute.rule.edit") : Text("mute.rule.add"))
		.navigationBarTitleDisplayMode(.inline)
		.toolbar {
			ToolbarItem(placement: .cancellationAction) {
				Button("common.cancel", action: onCancel)
			}
			ToolbarItem(placement: .confirmationAction) {
				Button("common.save") { onSave(makeRule()) }
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
