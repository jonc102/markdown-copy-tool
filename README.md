# MarkdownPaste

A lightweight macOS menu bar utility that automatically converts Markdown on your clipboard to rich text, so pasting into Slack, Telegram, Notes, and other apps "just works" with formatting.

## The Problem

When you copy text from `.md` files or code editors, the clipboard only contains plain text. Pasting into apps like Slack or Apple Notes shows raw Markdown syntax — `# headings`, `**bold**`, `- lists` — instead of formatted text.

## The Solution

MarkdownPaste sits in your menu bar and watches the clipboard. When it detects Markdown content, it silently converts it to rich text (HTML + RTF) and writes it back. The next time you paste, the receiving app gets properly formatted content.

## Features

- **Automatic detection** — Weighted scoring across 15 Markdown patterns minimizes false positives
- **Full GFM support** — Headings, bold, italic, links, images, code blocks, tables, task lists, strikethrough, footnotes
- **Styled output** — System font, syntax-highlighted code blocks, bordered tables, styled blockquotes
- **Non-intrusive** — Menu bar only, no Dock icon, no windows unless you open Settings
- **Smart skip** — Ignores clipboard content that already has rich formatting (copied from web, docs, etc.)
- **Configurable sensitivity** — Adjust detection threshold from aggressive (1) to conservative (5)
- **Launch at Login** — Optional auto-start via SMAppService
- **Lightweight** — <1% CPU with 0.5s polling interval

## Requirements

- macOS 13.0 (Ventura) or later
- Xcode 15+ (for building from source)

## Installation

Download the latest `.dmg` from [Releases](#), open it, and drag MarkdownPaste to Applications.

## Usage

1. MarkdownPaste appears as a document icon in your menu bar
2. Copy any Markdown text (from a `.md` file, terminal, editor, etc.)
3. Paste into Slack, Telegram, Notes, or any rich text app — it renders formatted

### Menu Bar Controls

- **Toggle** — Enable/disable conversion on the fly (⌘E)
- **Status** — See how many conversions have been performed
- **Settings** — Adjust detection sensitivity, launch at login, RTF inclusion (⌘,)
- **Quit** — Exit the app (⌘Q)

### Settings

| Tab | Options |
|-----|---------|
| **General** | Enable/disable, Launch at Login, Include RTF format |
| **Detection** | Sensitivity slider (1=Very Aggressive → 5=Very Conservative) |

## Building from Source

### Prerequisites

- Xcode 15+
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`)

### Build

```bash
xcodegen generate
xcodebuild build -project MarkdownPaste.xcodeproj -scheme MarkdownPaste
```

### Test

```bash
xcodebuild test -project MarkdownPaste.xcodeproj -scheme MarkdownPaste
```

56 unit tests cover the detection engine (22 tests), Markdown-to-HTML converter (23 tests), and clipboard writer (11 tests).

### Release

```bash
./Scripts/build-release.sh
```

This archives, code-signs, notarizes, and packages the app into a `.dmg`. Requires an Apple Developer ID certificate and `create-dmg` (`brew install create-dmg`).

## How It Works

```
Clipboard change detected (polling every 0.5s)
  → Is this our own write? Skip (marker check)
  → Already has HTML/RTF? Skip (rich content)
  → Extract plain text
  → Empty or > 100KB? Skip
  → Score against 15 weighted Markdown patterns
  → Score >= threshold? Convert!
  → Parse Markdown → AST (swift-markdown) → Styled HTML + RTF
  → Write plain text + HTML + RTF + marker back to clipboard
```

## Architecture

```
MarkdownPaste/
├── App/           # Entry point, lifecycle, shared state
├── Services/      # Detection, conversion, clipboard I/O
├── Views/         # Menu bar dropdown, settings window
├── Utilities/     # Constants, pasteboard type extensions
└── Resources/     # Info.plist, asset catalog
```

| Component | Role |
|-----------|------|
| `MarkdownDetector` | 15 regex patterns with weighted scoring (headings ×3, code blocks ×4, tables ×4, etc.) |
| `MarkdownConverter` | AST-based HTML generation via `MarkupVisitor`, CSS styling, RTF via `NSAttributedString` |
| `ClipboardMonitor` | Timer-based polling with 10-step guard pipeline (enabled → changed → marker → rich → text → size → detect → convert → write → state) |
| `ClipboardWriter` | Multi-format pasteboard write with self-detection marker |
| `AppState` | `@MainActor` singleton with `@AppStorage` preferences and `SMAppService` login management |

## License

MIT
