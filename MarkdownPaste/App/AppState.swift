import SwiftUI
import ServiceManagement
import UserNotifications

@MainActor
class AppState: ObservableObject {
    static let shared = AppState()

    @AppStorage("isEnabled") var isEnabled: Bool = true
    @AppStorage("launchAtLogin") var launchAtLogin: Bool = false {
        didSet {
            updateLaunchAtLogin()
        }
    }
    @AppStorage("detectionSensitivity") var detectionSensitivity: Int = 2
    @AppStorage("includeRTF") var includeRTF: Bool = true
    @AppStorage("showNotifications") var showNotifications: Bool = false {
        didSet {
            if showNotifications {
                requestNotificationPermission()
            }
        }
    }
    @AppStorage("baseFontSize") var baseFontSize: Int = 14

    @Published var conversionCount: Int = 0
    @Published var lastConversionDate: Date? = nil

    private init() {}

    private func updateLaunchAtLogin() {
        do {
            if launchAtLogin {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            print("Failed to update launch at login: \(error)")
        }
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, _ in
            if !granted {
                Task { @MainActor in self.showNotifications = false }
            }
        }
    }
}
