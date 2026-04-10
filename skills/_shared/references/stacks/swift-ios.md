---
name: swift-ios
detection: ["Package.swift", "*.xcodeproj", "*.xcworkspace", "*.swift"]
archetype: F
---

# Swift / iOS — Stack Knowledge

## Conventions

**Project structure**:
- Feature-based: `Features/{FeatureName}/` with Views, ViewModels, Models subdirectories
- Shared: `Core/` for extensions, utilities, networking, persistence
- Resources: `Resources/` for assets, localization, fonts
- Tests mirror source: `Tests/{FeatureName}Tests/`

**API targets**: Target iOS 17+ for new projects (enables @Observable, SwiftData, new navigation). Drop to iOS 16 only if business requirement demands it — the API differences are substantial.

**Naming**: CamelCase types, camelCase properties/functions, UPPER_SNAKE_CASE never (use static let). Protocols: `-able` suffix for capabilities (`Configurable`), no suffix for roles (`DataStore`).

**Error handling**: Use typed errors (`enum AppError: LocalizedError`). Never force-unwrap (`!`) outside of IBOutlets and tests. Use `guard let` for early returns, `if let` for optional binding.

**Concurrency model**: Swift structured concurrency (async/await, actors, @Sendable) exclusively. No GCD (`DispatchQueue`), no completion handlers in new code. Use `@MainActor` for all UI-touching code.

## Toolchain

| Action | Command | Notes |
|--------|---------|-------|
| Build | `xcodebuild -scheme {scheme} -sdk iphonesimulator build` | Or `swift build` for SPM-only |
| Test | `xcodebuild test -scheme {scheme} -destination 'platform=iOS Simulator,name=iPhone 16'` | Or `swift test` |
| Lint | `swiftlint` | Configure via `.swiftlint.yml` |
| Format | `swiftformat .` | Configure via `.swiftformat` |
| Build (SPM) | `swift build` | For server-side or CLI Swift |
| Resolve deps | `swift package resolve` | SPM dependency resolution |

**CI pipeline**: `swiftformat --lint . && swiftlint && xcodebuild test -scheme ... -destination ...`

## Safety Patterns

**Concurrency**: All UI updates via `@MainActor`. Mark ViewModels as `@MainActor`. Use actors for shared mutable state instead of locks. Never use `DispatchQueue.main.async` — use `MainActor.run {}` if you must escape structured concurrency.

**Memory management**: Watch for retain cycles in closures — use `[weak self]` when capturing self in escaping closures. Use `@Observable` (iOS 17+) instead of `ObservableObject` — it tracks property access automatically and avoids unnecessary redraws.

**Type safety**: No stringly-typed APIs. Use enums for finite sets, protocols for capabilities. Avoid `Any` and `AnyObject` — use generics or opaque types (`some Protocol`).

**Optionals**: Never force-unwrap. Use `guard let` / `if let` / nil-coalescing (`??`). If a value truly cannot be nil, use `fatalError("reason")` in debug to catch invariant violations early.

## Anti-Patterns

**NavigationView instead of NavigationStack**:
- BAD: `NavigationView { ... }` (deprecated)
- GOOD: `NavigationStack { ... }` with `navigationDestination(for:)` (iOS 16+)
- WHY: NavigationView has broken behavior on iPad and is deprecated

**ObservableObject when @Observable is available**:
- BAD: `class VM: ObservableObject { @Published var items: [Item] = [] }`
- GOOD: `@Observable class VM { var items: [Item] = [] }`
- WHY: @Observable tracks property access granularly — views only re-render when properties they actually read change, massive performance improvement

**Computed properties instead of separate views**:
- BAD: `var headerSection: some View { VStack { ... } }` (computed property in parent view)
- GOOD: `struct HeaderSection: View { var body: some View { VStack { ... } } }` (separate view)
- WHY: With @Observable, SwiftUI can skip re-evaluating separate views whose observed properties didn't change. Computed properties always re-evaluate with the parent.

**DispatchQueue.main.async for UI updates**:
- BAD: `DispatchQueue.main.async { self.isLoading = false }`
- GOOD: `@MainActor func updateUI() { isLoading = false }` or `await MainActor.run { ... }`
- WHY: GCD doesn't integrate with Swift's structured concurrency; mixing models causes subtle bugs

**Force-unwrapping optionals**:
- BAD: `let url = URL(string: urlString)!`
- GOOD: `guard let url = URL(string: urlString) else { throw AppError.invalidURL(urlString) }`
- WHY: Force-unwrap crashes at runtime — the exact scenario optionals exist to prevent

**Hardcoded dimensions**:
- BAD: `Text("Hello").frame(width: 375)`
- GOOD: Use `frame(maxWidth: .infinity)`, `GeometryReader`, or adaptive layout
- WHY: Hardcoded sizes break on different screen sizes, Dynamic Type, and accessibility

**Ignoring Dynamic Type fonts**:
- BAD: `Text("Title").font(.system(size: 24))`
- GOOD: `Text("Title").font(.title)`
- WHY: System fonts scale with user accessibility settings; fixed sizes don't

## Testing Patterns

**Framework**: Swift Testing (`import Testing`, `@Test`, `#expect`) for new code. XCTest for legacy. Don't mix in the same target.

**Dependency injection**: Use protocol-based DI. Define protocols for services, inject via init parameters with defaults:
```swift
protocol DataStoring: Sendable {
    func save(_ item: Item) async throws
}

@Observable class ItemVM {
    let store: DataStoring
    init(store: DataStoring = DataStore()) { self.store = store }
}
```

**Test doubles**: Create `Mock{Protocol}` conformances. Use `withDependencies` (Point-Free) if using their DI system.

**UI testing**: XCUITest for critical user journeys. SwiftUI previews for visual verification during development (not a replacement for tests).

**Coverage**: Xcode built-in coverage. Target 80%+ for business logic, lower acceptable for UI layers.

## Deploy Patterns

**TestFlight (beta)**:
- Archive: `xcodebuild archive -scheme ... -archivePath ...`
- Export: `xcodebuild -exportArchive -archivePath ... -exportOptionsPlist ...`
- Upload: `xcrun altool --upload-app -f ... -t ios -u ... -p ...`
- Or use `fastlane` for automated pipeline

**App Store**:
- Same archive/export/upload flow with App Store Connect review
- Version bump in Xcode project settings
- Screenshots, metadata via App Store Connect or `fastlane deliver`

**CI verification**: `swiftformat --lint . && swiftlint && xcodebuild test -scheme ... && xcodebuild archive ...`
