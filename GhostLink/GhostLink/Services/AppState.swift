import SwiftUI
import Combine

final class AppState: ObservableObject {
    @Published var isAuthenticated = false
    @Published var showFlashTransition = false
    @Published var selectedTab: MainTab = .home
    @Published var activeModule: GhostModule?
    @Published var settings = AppSettings.load()

    let logStore = LogStore.shared
    let sniffer = SnifferService.shared
    let wifiScanner = WiFiScannerService.shared
    let fakeAP = FakeAPService.shared
    let smsService = SMSService.shared
    let credentialStore = CredentialStore.shared

    private let validUsername = "revishef"
    private let validPassword = "revishef"

    func login(username: String, password: String) -> Bool {
        let ok = username == validUsername && password == validPassword
        if ok {
            logStore.add(module: "AUTH", message: "Session started for \(username)")
        }
        return ok
    }

    func completeLogin() {
        withAnimation(GhostTheme.spring) {
            isAuthenticated = true
        }
    }

    func logout() {
        withAnimation(GhostTheme.spring) {
            isAuthenticated = false
            activeModule = nil
            selectedTab = .home
        }
        logStore.add(module: "AUTH", message: "Session terminated")
    }

    func haptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        guard settings.hapticEnabled else { return }
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }

    func notificationHaptic(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        guard settings.hapticEnabled else { return }
        UINotificationFeedbackGenerator().notificationOccurred(type)
    }
}

struct AppSettings: Codable, Equatable {
    var animationsEnabled: Bool = true
    var hapticEnabled: Bool = true
    var smsAPIBaseURL: String = "http://127.0.0.1:5050"

    static let storageKey = "ghostlink_settings"

    static func load() -> AppSettings {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let s = try? JSONDecoder().decode(AppSettings.self, from: data) else {
            return AppSettings()
        }
        return s
    }

    func save() {
        if let data = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(data, forKey: Self.storageKey)
        }
    }
}
