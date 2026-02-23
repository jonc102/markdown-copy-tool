# Marksmith Demo

Copy any section below and paste into **Notes**, **Mail**, **Slack**, or any rich-text app to see Marksmith in action.

---

## Formatted Text

This sentence has **bold**, *italic*, and ~~strikethrough~~ text. You can also combine ***bold and italic*** together.

Here's some `inline code` mixed into a sentence.

## Links & Images

Check out [Marksmith on GitHub](https://github.com/jonc102/markdown-copy-tool) for the source code.

## Lists

### Unordered

- Monitors your clipboard automatically
- Detects Markdown in copied text
- Converts to rich text instantly
  - HTML format
  - RTF format

### Ordered

1. Copy Markdown from any source
2. Marksmith detects it in the background
3. Paste as beautifully formatted rich text

### Task List

- [x] Clipboard monitoring
- [x] Markdown detection
- [x] Rich text conversion
- [ ] Monetization (coming in v2.0)

## Blockquote

> "The best tool is the one you don't have to think about."
>
> — Every menu bar app ever

## Code Block

```swift
let detector = MarkdownDetector()
if detector.detect(text: clipboard, threshold: 2) {
    let (html, rtf) = converter.convert(markdown: clipboard)
    writer.write(plainText: clipboard, html: html, rtf: rtf)
}
```

## Table

| Feature | Status |
|---------|--------|
| Clipboard polling | Done |
| Markdown detection | Done |
| HTML conversion | Done |
| RTF conversion | Done |
| Menu bar UI | Done |
| About window | Done |

## Heading Levels

### H3 — Subsection
#### H4 — Detail
##### H5 — Fine print

## Horizontal Rule

Content above the rule.

---

Content below the rule.
