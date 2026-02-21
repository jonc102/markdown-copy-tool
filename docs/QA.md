# MarkdownPaste — Milestone 8 QA Checklist

**Build**: Debug (or release DMG)
**macOS target**: 13+
**Tester**:
**Date**:

Mark each item `[x]` when it passes, `[!]` when it fails (add notes below the item).

---

## 1. Installation & First Launch

- [ ] App launches without crashing
- [ ] `M↓` icon appears in menu bar (template image — adapts to light/dark menu bar)
- [ ] No Dock icon appears (LSUIElement app)
- [ ] Clicking the icon opens the dropdown menu

---

## 2. Menu Bar Dropdown

- [ ] **Enabled** state shows checkmark + "Enabled" label
- [ ] **Disabled** state shows "Disabled" label (no checkmark)
- [ ] Toggling enable/disable with `⌘E` keyboard shortcut works
- [ ] "No conversions yet" shows on first launch (before any conversion)
- [ ] After a conversion: "Conversions: N" and "Last: X ago" appear
- [ ] "Settings..." button is present
- [ ] `⌘,` keyboard shortcut opens Settings
- [ ] "Quit MarkdownPaste" button is present
- [ ] `⌘Q` keyboard shortcut quits the app

---

## 3. Settings Window — Open & Raise

- [ ] Clicking "Settings..." opens the Settings window
- [ ] Settings window comes to the front over other apps
- [ ] Opening Settings while it's already in the background brings it to the front (the fix from this session)
- [ ] `⌘,` shortcut also raises an already-open Settings window
- [ ] Settings window has the correct size (~640×440)

---

## 4. Settings — General Tab

- [ ] "General" is selected by default in the sidebar
- [ ] **Enable MarkdownPaste** toggle reflects current state
  - [ ] Toggling off stops conversions (copy Markdown → no enrichment)
  - [ ] Toggling on resumes conversions
- [ ] **Launch at Login** toggle works
  - [ ] Toggle on → app appears in Login Items (verify in System Settings > General > Login Items)
  - [ ] Toggle off → app removed from Login Items
- [ ] **Include RTF Format** toggle works
  - [ ] Toggle off → pasting in TextEdit (Plain Text mode) works but RTF apps may lose formatting
  - [ ] Toggle on → pasting in RTF-aware apps (Pages, Mail) renders formatting
- [ ] **Notify on Conversion** toggle works
  - [ ] Toggle on → macOS prompts for notification permission on first conversion
  - [ ] After granting permission, a notification fires on each Markdown conversion
  - [ ] Toggle off → no notifications fire
- [ ] **Output Font Size** picker has three options: Small (12px), Medium (14px), Large (18px)
  - [ ] Changing font size affects the rendered output (paste into Pages/TextEdit and compare)

---

## 5. Settings — Detection Tab

- [ ] Detection sensitivity slider has 5 steps (1–5)
  - [ ] Step 1: "Very Aggressive (threshold: 1)"
  - [ ] Step 2: "Normal (threshold: 2)"
  - [ ] Step 3: "Moderate (threshold: 3)"
  - [ ] Step 4: "Conservative (threshold: 4)"
  - [ ] Step 5: "Very Conservative (threshold: 5)"
- [ ] Explanatory text is visible below the slider card
- [ ] At threshold 1: plain text with a single `*` or `-` triggers conversion (expected false positive)
- [ ] At threshold 5: only heavily marked-up Markdown triggers conversion

---

## 6. Settings — Support Tab

- [ ] "Support" tab is visible and selectable in sidebar
- [ ] "Buy Me a Coffee" row is present
- [ ] Clicking it opens `https://buymeacoffee.com/jonc102` in the default browser

---

## 7. Core Conversion — GFM Pattern Coverage

For each test: copy the snippet, wait ~1 second, paste into a rich text app (TextEdit in Rich Text mode, Pages, or Mail).

### Headings
```
# Heading 1
## Heading 2
### Heading 3
```
- [ ] Pastes with H1, H2, H3 styling (progressively smaller)

### Bold & Italic
```
**bold text** and *italic text*
```
- [ ] "bold text" is bold; "italic text" is italic

### Strikethrough
```
~~strikethrough~~
```
- [ ] Text renders with strikethrough

### Inline Code
```
Use `code` here
```
- [ ] `` `code` `` renders in monospace with grey background

### Code Block
````
```python
def hello():
    print("world")
```
````
- [ ] Renders as a code block with monospace font and `#f6f8fa` background

### Unordered List
```
- Item one
- Item two
- Item three
```
- [ ] Renders as a bulleted list

### Ordered List
```
1. First
2. Second
3. Third
```
- [ ] Renders as a numbered list

### Task List
```
- [x] Done
- [ ] Not done
```
- [ ] Renders with checkboxes (checked and unchecked)

### Blockquote
```
> This is a blockquote
```
- [ ] Renders with left border and indented grey text

### Horizontal Rule
```
---
```
- [ ] Renders as a horizontal dividing line

### Link
```
[OpenAI](https://openai.com)
```
- [ ] "OpenAI" renders as a blue hyperlink

### Table
```
| Name  | Age |
|-------|-----|
| Alice | 30  |
| Bob   | 25  |
```
- [ ] Renders as a formatted table with header row

### Mixed document
```markdown
# My Doc

This has **bold**, *italic*, and `code`.

- Item A
- Item B

> A quote

| Col1 | Col2 |
|------|------|
| a    | b    |
```
- [ ] Full document pastes with all elements formatted correctly

---

## 8. Negative Cases — Plain Text Must NOT Convert

Copy each snippet and verify the paste is still plain text (no formatting applied, conversion count does not increment).

- [ ] Plain prose: `The quick brown fox jumps over the lazy dog`
- [ ] URL only: `https://example.com`
- [ ] Email: `user@example.com`
- [ ] Single bullet: `- one item` (at default sensitivity 2)
- [ ] Single asterisk: `a * b` (at default sensitivity 2)
- [ ] Numbers: `1. only one line`
- [ ] Code without surrounding text: `x = 1` (no backticks)

---

## 9. Guard Rail Cases

- [ ] **Re-processing prevention**: After a conversion, copying the same text again immediately does NOT trigger a second conversion (marker guard works)
- [ ] **Large content**: Copy >100KB of text → no conversion, no crash
- [ ] **Empty clipboard**: Clear clipboard (copy a single space, then delete) → no crash
- [ ] **Monitor off during copy**: Disable monitoring, copy Markdown, re-enable → the already-copied content is NOT converted (change count guard works)
- [ ] **Whitespace-only**: Copy `   \n   ` → no conversion

---

## 10. Source App Exclusions (Semantic HTML Guard)

Copy from each app and verify the clipboard is NOT converted (these apps put semantic HTML on the clipboard already).

- [ ] Safari (select text on a webpage, copy) → pastes rich text as-is, no double-conversion
- [ ] Chrome (select text on a webpage, copy) → same
- [ ] Apple Notes (copy formatted text) → not converted
- [ ] Google Docs (copy formatted text) → not converted

Copy from code editors and verify Markdown **IS** converted (editors put only span/div HTML, not semantic HTML):

- [ ] VS Code: copy Markdown source text → converts
- [ ] Cursor: copy Markdown source text → converts
- [ ] Xcode: copy Markdown source text → converts

---

## 11. Paste Destination App Coverage

Paste a converted Markdown snippet (e.g., `**bold** and *italic*`) into each app and verify formatting renders:

- [ ] **TextEdit** (Rich Text mode) — bold and italic visible
- [ ] **Pages** — bold and italic visible
- [ ] **Mail** (compose window) — bold and italic visible
- [ ] **Notion** (web) — formatting renders
- [ ] **Slack** — formatting renders (or gracefully falls back to plain text)
- [ ] **Terminal** — pastes as plain Markdown source (expected; Terminal is plain-text)
- [ ] **VS Code** — pastes as plain Markdown source (expected)

---

## 12. Quit & Relaunch

- [ ] Quitting via "Quit MarkdownPaste" exits the app cleanly
- [ ] Quitting via `⌘Q` from dropdown exits cleanly
- [ ] Relaunching: all settings persist (enable state, sensitivity, font size, RTF toggle)
- [ ] Conversion count resets to 0 on relaunch (runtime-only state — expected)

---

## 13. Edge / Regression Cases

- [ ] Rapid clipboard changes (copy multiple things quickly) → no crash, no incorrect conversion
- [ ] Settings window: switching tabs (General → Detection → Support → General) works without layout glitches
- [ ] Resizing the Settings window doesn't break layout
- [ ] Menu bar icon remains visible after display sleep/wake
- [ ] Menu bar icon remains visible after connecting/disconnecting an external display

---

## Notes

_Record any failures, unexpected behaviour, or observations here._

```
[!] TC-XX: <description of failure>
    Steps: ...
    Expected: ...
    Actual: ...
```
