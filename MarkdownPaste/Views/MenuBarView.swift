import SwiftUI

// macOS 14+ settings button uses openSettings environment action, which both
// opens the window and raises it if already open. activate() brings it to front
// over other apps. Falls back to SettingsLink on macOS 13 (opens but won't raise).
@available(macOS 14, *)
private struct SettingsButton: View {
    @Environment(\.openSettings) private var openSettings

    var body: some View {
        Button("Settings...") {
            NSApplication.shared.activate()
            openSettings()
            DispatchQueue.main.async {
                if let settingsWindow = NSApp.windows.first(where: { $0.canBecomeKey && $0.isVisible }) {
                    settingsWindow.makeKeyAndOrderFront(nil)
                }
            }
        }
        .keyboardShortcut(",", modifiers: [.command])
    }
}

struct MenuBarView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        Button {
            appState.isEnabled.toggle()
        } label: {
            if appState.isEnabled {
                Label("Enabled", systemImage: "checkmark")
            } else {
                Text("Disabled")
            }
        }
        .keyboardShortcut("e", modifiers: [.command])

        Divider()

        if appState.conversionCount > 0 {
            Text("Conversions: \(appState.conversionCount)")
            if let lastDate = appState.lastConversionDate {
                Text("Last: \(lastDate, style: .relative) ago")
            }
        } else {
            Text("No conversions yet")
        }

        Divider()

        if #available(macOS 14, *) {
            SettingsButton()
        } else {
            SettingsLink {
                Text("Settings...")
            }
            .keyboardShortcut(",", modifiers: [.command])
        }

        Divider()

        Button("Quit MarkdownPaste") {
            NSApplication.shared.terminate(nil)
        }
        .keyboardShortcut("q", modifiers: [.command])
    }
}
