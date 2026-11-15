# SwiftUI and Architecture Review Guide

Use this guide when reviewing or changing app code. The goal is to keep view updates safe, rendering predictable, and responsibilities clear across the app's SwiftUI, view model, and data layers.

## Collection rendering

- Use `ForEach` over identifiable elements and their stable IDs:

  ```swift
  ForEach(model.items) { item in
      ItemRow(item: item)
  }
  ```

- Do not drive a rendered collection from `collection.indices`, and do not subscript the source collection from a loop body. SwiftUI can reevaluate a row after the collection changes, leaving a captured index invalid and causing an out-of-range crash.
- Do not use `enumerated()` in a view just to recover an element's index or ID. `id: \.self` on an index is not a substitute for the element's identity.
- When the UI needs positional presentation, map the data into identifiable presentation items before rendering. Include the source model and the presentation property in the mapped item:

  ```swift
  struct FeedArticleItem: Identifiable, Sendable {
      let article: Article
      let isFeatured: Bool

      var id: String { article.id }
  }
  ```

  The mapper can use the element's position to assign `isFeatured`; the view then renders `ForEach(items)` without calculating positions or indexing the source array.
- If source elements are primitive values without unique identity, introduce a small identifiable model in the parsing or mapping layer. Give repeated values distinct IDs. Do not make the view invent identity while rendering.
- For custom layouts that produce one placement per subview, pair subviews and placements directly (for example, with `zip`) instead of indexing one collection from a loop over another.

## SwiftUI view responsibilities

- Keep `body` declarative: select and render already-prepared state. Avoid mapping, sorting, filtering, or building lookup collections in `body` when that work belongs to the view model or a mapper.
- Keep row views focused on rendering one model. Pass a complete identifiable presentation item when the row needs both source data and display-specific values.
- Keep derived presentation state synchronized with its source. Recompute mapped items when the source result changes, and clear them when the source request or context resets.
- Avoid duplicate stored representations unless there is a clear reason. When a source array and a mapped display array both exist, update them together in one state transition and keep the source array authoritative.
- Prefer stable IDs that represent the same logical item across updates. IDs must be unique among siblings in a `ForEach`.

## Architecture boundaries

- Keep networking and parsing responsible for turning external data into app models. Keep reusable, source-independent presentation mapping in a dedicated mapper or the view model that owns the screen state.
- Keep screen state and transformations in the screen's `@MainActor` observable view model. Keep SwiftUI views from reaching into mutable collections to reconstruct a screen model.
- Use a dedicated presentation model when rendering needs values that do not belong to the domain model, such as featured status, formatted labels, or section identity. Preserve the domain model's stable ID in that presentation model.
- Keep UIKit coordination and navigation in the coordinator/navigation layer. Views should issue actions through the established navigation interface rather than creating navigation infrastructure themselves.
- Prefer the simplest layer that owns the decision. Do not add a generic mapper or abstraction for a one-off transformation unless it improves reuse or makes ownership clearer.

## Review checklist

Before merging a UI or data-flow change, check:

1. Does every `ForEach` iterate identifiable elements directly?
2. Is any source collection accessed by index from a loop or row closure? Replace it with direct element iteration or a mapped presentation model.
3. Is positional display logic computed before rendering and carried on the presentation item?
4. Are derived items updated and cleared whenever their source state changes?
5. Can the source collection change while SwiftUI reevaluates a row? If so, does each row carry its own element instead of a potentially stale index?
6. Are IDs stable and unique for the lifetime of the logical item?
7. Does each transformation live in the layer that owns the data and decision, without unnecessary work in `body`?
8. For a reported crash, does the fix address the symbolicated frame and the underlying state/identity issue, rather than only hiding the failing access?

Follow the repository's `AGENTS.md` requirements for tests, builds, and UI validation when verifying a change.
