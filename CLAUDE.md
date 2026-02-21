# MarkdownPaste

macOS menu bar utility that monitors the clipboard, detects Markdown content, converts it to rich text (HTML + RTF), and writes it back so pasting renders formatted text in any app.

Swift · SwiftUI · macOS 13+ · `swift-markdown` (SPM) · XcodeGen · Bundle ID: `com.jonathancheung.MarkdownPaste`

## Prerequisites

- Xcode 15+
- [XcodeGen](https://github.com/yonaskolb/XcodeGen): `brew install xcodegen`

## Commands

| Command | Description |
|---------|-------------|
| `xcodegen generate` | Generate `.xcodeproj` from `project.yml` |
| `xcodebuild build -project MarkdownPaste.xcodeproj -scheme MarkdownPaste` | Build the app |
| `xcodebuild test -project MarkdownPaste.xcodeproj -scheme MarkdownPaste` | Run all 56 unit tests |
| `xcodebuild test -only-testing:MarkdownPasteTests/MarkdownDetectorTests` | Run a single test class |
| `./Scripts/build-release.sh` | Build and package unsigned DMG |
| `SIGN=1 ./Scripts/build-release.sh` | Build signed DMG (requires Developer ID) |
| `SIGN=1 NOTARIZE=1 ./Scripts/build-release.sh` | Build signed + notarized DMG |

## Architecture

```
MarkdownPaste/
├── MarkdownPaste/
│   ├── App/           # MarkdownPasteApp.swift (@main), AppDelegate, AppState
│   ├── Views/         # MenuBarView (dropdown), SettingsView (General + Detection tabs)
│   ├── Services/      # ClipboardMonitor, MarkdownDetector, MarkdownConverter, ClipboardWriter
│   ├── Utilities/     # Constants, PasteboardTypes (marker extension)
│   └── Resources/     # Assets.xcassets, Info.plist
├── MarkdownPasteTests/  # 56 tests: detector (22), converter (23), writer (11)
├── Scripts/             # build-release.sh
├── ExportOptions.plist  # developer-id export config
└── project.yml          # XcodeGen configuration
```

**Data flow**: Timer (0.5s) → changeCount changed? → marker absent? → no existing HTML/RTF? → extract plain text → not empty, ≤100KB? → detect Markdown (score >= threshold) → convert (AST → HTML + RTF) → write back with marker → update conversion count

## Key Files

- `App/MarkdownPasteApp.swift` — `@main` entry point, `MenuBarExtra` + `Settings` scenes
- `App/AppState.swift` — `@MainActor` singleton with `@AppStorage` preferences, `SMAppService` login item management
- `App/AppDelegate.swift` — Creates and manages `ClipboardMonitor` lifecycle
- `Services/ClipboardMonitor.swift` — Timer-based polling with 10-step guard pipeline, `[weak self]` timer, `.common` RunLoop mode
- `Services/MarkdownDetector.swift` — 15 pre-compiled `NSRegularExpression` patterns with weighted scoring, `.anchorsMatchLines` for `^`/`$` anchors
- `Services/MarkdownConverter.swift` — `HTMLVisitor` conforming to `MarkupVisitor` (22 visit methods), CSS styling, RTF via `NSAttributedString`
- `Services/ClipboardWriter.swift` — Multi-format `NSPasteboardItem` write with self-marker
- `Views/MenuBarView.swift` — Toggle, conversion status, Settings button, quit with keyboard shortcuts
- `Views/SettingsView.swift` — `TabView` with General (enable, login, RTF) and Detection (sensitivity slider) tabs
- `Utilities/PasteboardTypes.swift` — `NSPasteboard.PasteboardType.markdownPasteMarker` extension
- `Utilities/Constants.swift` — `pollingInterval` (0.5s), `maxContentSize` (100KB), `defaultDetectionThreshold` (2)

## Interface Contracts

```swift
// AppState — @MainActor singleton, consumed by all layers
@MainActor
class AppState: ObservableObject {
    static let shared = AppState()
    @AppStorage("isEnabled") var isEnabled: Bool                        // true
    @AppStorage("launchAtLogin") var launchAtLogin: Bool                // false
    @AppStorage("detectionSensitivity") var detectionSensitivity: Int   // 2
    @AppStorage("includeRTF") var includeRTF: Bool                     // true
    @Published var conversionCount: Int                                 // 0
    @Published var lastConversionDate: Date?                            // nil
}

// Detector — stateless, pre-compiled regexes in init()
struct MarkdownDetector {
    func detect(text: String, threshold: Int) -> Bool
    func score(text: String) -> Int
}

// Converter — uses swift-markdown AST + HTMLVisitor
struct MarkdownConverter {
    func convert(markdown: String) -> (html: String, rtf: Data?)
}

// Writer — always includes marker type
struct ClipboardWriter {
    func write(plainText: String, html: String, rtf: Data?)
}

// Monitor — owns detector, converter, writer; uses [weak self] timer
class ClipboardMonitor {
    init(appState: AppState)
    func start()
    func stop()
}
```

## Code Style

- Swift naming conventions (camelCase properties, PascalCase types)
- `struct` for stateless services (Detector, Converter, Writer); `class` for stateful (AppState, Monitor)
- `@MainActor` on `AppState` for SwiftUI thread safety
- `@AppStorage` for persisted user preferences; `@Published` for runtime-only state
- Prefer `guard` for early returns in pipeline methods
- Pre-compile `NSRegularExpression` patterns as stored properties in `init()`, not per-call
- Use `.anchorsMatchLines` option for regex patterns that use `^` or `$` anchors
- Use `@Environment(\.openSettings)` (macOS 14+) + `NSApplication.shared.activate()` for the Settings button — this both opens and raises the window. `SettingsLink` does not activate the app and fails to raise an already-open window in menu bar–only apps (`LSUIElement = true`). `NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)` is unreliable in SwiftUI; `SettingsLink` uses an internal SwiftUI mechanism, not that selector. Fall back to `SettingsLink` on macOS 13.

## Gotchas

- **No clipboard notification API on macOS** — must poll with `Timer`; 0.5s is the sweet spot for responsiveness vs CPU
- **Infinite loop risk** — writing to pasteboard triggers changeCount bump; always write the marker type and check for it before processing
- **Sandbox disabled** — `NSPasteboard.general` requires unsandboxed access; app is distributed via DMG, not App Store
- **macOS 16+ privacy prompts** — `NSPasteboardUsageDescription` in Info.plist provides the rationale; handle `nil` pasteboard reads gracefully
- **RTF generation must happen on main thread** — `NSAttributedString(html:documentAttributes:)` uses WebKit internally; Timer fires on main RunLoop so this is satisfied
- **Content size guard** — skip clipboard content > 100KB to avoid blocking the main thread
- **Detection false positives** — single `*` or `-` in plain text can score; threshold default of 2 requires multiple pattern matches
- **Operator precedence with Optional Bool** — `!optional?.contains(...) ?? true` has wrong precedence; use `optional?.contains(...) != true` instead
- **Timer RunLoop mode** — must add timer to `.common` mode via `RunLoop.current.add(timer!, forMode: .common)` so it fires even while menus are open
- **`@MainActor` access from Timer** — Timer callback runs on main thread but isn't annotated `@MainActor`; use `Task { @MainActor in ... }` for AppState mutations

## Testing

56 tests across 3 test files:

- `MarkdownDetectorTests` (22 tests) — 15+ positive (all GFM patterns), 6 negative (plain text, URLs, emails), 6 edge cases (empty, whitespace, threshold boundary, score capping, zero threshold)
- `MarkdownConverterTests` (23 tests) — all GFM elements produce correct HTML tags, RTF data is non-nil, HTML entities escaped, CSS styling present, full document structure, XSS prevention in code blocks
- `ClipboardWriterTests` (11 tests) — all pasteboard types written, RTF conditional, marker always present, content integrity, clearing old content

## Distribution Strategy

**Current (v1.0)**: Unsigned DMG via GitHub Releases. Recipients bypass Gatekeeper with right-click → Open → Open on first launch.

**Future (v2.0)**: Once demand is validated, enroll in Apple Developer Program ($99/year) for signed+notarized distribution. Monetize with free trial (7-14 days) + one-time lifetime unlock ($9-15).

## Implementation Status

Milestones 1–7 and 9 are complete. See `docs/PLAN.md` for remaining tasks:
- ~~**Milestone 7**: Build verification~~ ✓ (70 tests passing)
- **Milestone 8**: Manual QA testing
- ~~**Milestone 9**: App icon design~~ ✓ (app icon + custom M↓ menu bar icon)
- **Milestone 10**: Performance profiling
- **Milestone 11**: Unsigned DMG distribution + GitHub Release
- **Milestone 12**: Polish & enhancements (v1.1)
- **Milestone 13**: Monetization — free trial + lifetime unlock (v2.0, requires Apple Developer Program)
