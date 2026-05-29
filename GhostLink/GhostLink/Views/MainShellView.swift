import SwiftUI

struct MainShellView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        ZStack(alignment: .bottom) {
            GhostTheme.background.ignoresSafeArea()

            Group {
                switch appState.selectedTab {
                case .home:
                    HomePanelView()
                case .logs:
                    LogsView()
                case .terminal:
                    TerminalView()
                case .settings:
                    SettingsView()
                case .powerOff:
                    Color.clear.onAppear { appState.logout() }
                }
            }
            .transition(GhostTheme.asymmetricTransition)

            if appState.selectedTab != .powerOff {
                BottomTabBar()
            }
        }
        .animation(appState.settings.animationsEnabled ? GhostTheme.spring : nil, value: appState.selectedTab)
        .fullScreenCover(item: $appState.activeModule) { module in
            ModuleDetailContainer(module: module)
        }
    }
}

struct BottomTabBar: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        HStack(spacing: 0) {
            ForEach(MainTab.allCases, id: \.rawValue) { tab in
                Button {
                    if tab == .powerOff {
                        appState.haptic(.rigid)
                    } else {
                        appState.haptic(.light)
                    }
                    appState.selectedTab = tab
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 18))
                        Text(tab.title)
                            .font(.system(size: 9, weight: .semibold))
                    }
                    .foregroundColor(appState.selectedTab == tab ? GhostTheme.neonPink : GhostTheme.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                }
                .buttonStyle(.plain)
            }
        }
        .background(GhostTheme.pureBlack.opacity(0.95))
        .overlay(Rectangle().frame(height: 1).foregroundColor(GhostTheme.neonPink.opacity(0.4)), alignment: .top)
    }
}

struct ModuleDetailContainer: View {
    @EnvironmentObject var appState: AppState
    let module: GhostModule

    var body: some View {
        ZStack(alignment: .topLeading) {
            GhostTheme.background.ignoresSafeArea()

            Group {
                switch module {
                case .sniffer: SnifferModuleView()
                case .deauth: DeauthModuleView()
                case .fakeAP: FakeAPModuleView()
                case .smsBomber: SMSBomberModuleView()
                case .credentialHarvester: CredentialHarvesterView()
                }
            }
            .transition(GhostTheme.asymmetricTransition)

            Button {
                appState.haptic()
                appState.activeModule = nil
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title3.weight(.bold))
                    .foregroundColor(GhostTheme.neonPink)
                    .padding(12)
                    .background(GhostTheme.pureBlack.opacity(0.8))
                    .clipShape(Circle())
                    .neonBorder()
            }
            .padding()
        }
    }
}

extension GhostModule: Hashable {}
