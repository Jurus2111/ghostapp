import SwiftUI

struct RootView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        ZStack {
            if appState.isAuthenticated {
                MainShellView()
                    .transition(GhostTheme.asymmetricTransition)
            } else {
                LoginView()
                    .transition(GhostTheme.asymmetricTransition)
            }

            PinkFlashOverlay(isActive: $appState.showFlashTransition)
        }
        .animation(appState.settings.animationsEnabled ? GhostTheme.spring : nil, value: appState.isAuthenticated)
    }
}
