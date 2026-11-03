Xcode:

- Always use folders, not groups on file selection
- Always remove the new files signature "created by..."
- Keep the indentation/spacing used in other files.
- Do NOT create previews of any SwiftUI or UIKit view.
- Do NOT create .xib files or storyboards.

General:

- Always ask the user before doing any UI validation, like using a preview, like using the simulator or even a real device.
- Always ask the user before creating or running any unit test. You are allowed to update affected unit tests, but not allowed to build or running them without explicit approval from the user.
- You are not allowed to spend tokens building the app. The normal flow is to do all the requested changes and later ask the user if the build is permitted. This is a global rule and should never be skipped unless explicit authorization.
- You are allowed to run the app on simulators or real devices if asked by the user.

Coding:

- You are NOT allowd to force unwrap an optional variable or constant.
- You should always act as a senior engineer that prioritize SIMPLICITY over COMPLEXITY.
- Structure nontrivial files in logical blocks or groups using // MARK: where the separation improves readability; omit unnecessary marks in small or undivided types.
- You MUST follow Swift 6 patterns, @MainActor, actor, etc.
- You MUST use async/await Swift concurrency. You can still use closures and delegates with user approval.
- You MUST prioritize performance for SwiftUI, this means, every view has an ID, has plan old data, and its considered to be as performant as it can on SwiftUI.
- You are an expert on threading, Tasks, and all threading strategies. You always consider that the UI must never be blocked on the main thread.
- You make EVERY protocol, struct, or anything that can be Sendable, Sendable.
- Every class must be final if needed, use proper access modifiers.

UI:

- Do not hardcode any string, use the localized version in Spanish and English. English is primary lang.
- Do not hardcode any color, add it to the internal system design of colors for reusability.
- Do not duplicate components, creating shared components is always preffered.
- Every new color should support light and dark variant.
- Architecure:
- Folder structure:
  - Base: AppDelegate/SceneDelegate, Config files, providers, 3rd parties.
  - Components: Shared UI components.
  - Networking: NetworkLayer, decoders, headers, general network configuration.
  - Modules:
    - ScreenA: ScreenAView, ScreenAViewModel, ScreenACoordinator, UseCase, etc.
  - Utils: Formatters, helpers, constants, etc.

- Hybrid app with UIKit and SwiftUI.
  - App starts on AppDelegate/SceneDelegate
    - App starts with "MainCoordinator" - uses delegation pattern
    - App navigates using HostingControllers or subclassed HostingControllers only if neccesary (the subclass)
  - Every screen is represented by:
    - Content: SwiftUI
      - Logic:
        - ViewModel + MainActor + Observable pattern.
        - UseCase only if neccesary to abstract logic.
    - Parent: Generic HostingController

Swift formatting and organization:

- Put each declaration annotation or property wrapper on its own line.
- Use tabs for indentation, displayed at two spaces; place each argument or parameter of a multi-argument call or declaration on its own line.
- Group properties by responsibility, visibility, and mutability, using `// MARK:` sections when there are meaningful sections to separate. Omit marks from small types or files without distinct logical groups. Alphabetize declarations within each group when doing so preserves initialization and public or synthesized initializer behavior.
- Keep initializers in the primary type, with a `// MARK: - Life Cycle` section when the type has meaningful sections.
- Place internal methods in an extension and group private methods separately when the type has meaningful groups; label those groups with `// MARK:`. Avoid unnecessary extensions and marks in small or undivided types. Keep protocol requirements and declarations that cannot safely move in their required context.
- Alphabetize methods within each group, preserving overloads and protocol behavior.
- Put method bodies on multiple lines, including short methods, and use blank lines to separate logical blocks such as guards, state changes, cleanup, and error handling.
- Preserve stored-property order when changing it would alter an existing memberwise initializer, initialization dependencies, or serialization behavior.
- Put each protocol in its own file with its associated supporting types; give every protocol name the `Protocol` suffix (for example, `AppNavigationProtocol`).
- Separate distinct primary declarations into appropriately named files throughout the project (for example, place an image-loading actor and an article-row view in separate files). Keep closely related supporting types alongside their primary declaration when appropriate.
- When a view exposes multiple output actions, use a single output closure carrying an action enum instead of a separate closure for each action.
- Express numeric zero using the appropriate type's zero constant, such as `CGFloat.zero` or `Int.zero`, or `.zero` where the type is clear and the syntax permits it.
- Centralize reusable layout values, including spacing, in a basic design system rather than repeating numeric literals across views.
