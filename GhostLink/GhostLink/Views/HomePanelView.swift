import SwiftUI

struct HomePanelView: View {
    @EnvironmentObject var appState: AppState
    @State private var tilesVisible = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                header
                moduleGrid
                    .padding(.bottom, 90)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
        .background(GhostTheme.background)
        .onAppear {
            if appState.settings.animationsEnabled {
                tilesVisible = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    withAnimation(GhostTheme.spring) { tilesVisible = true }
                }
            } else {
                tilesVisible = true
            }
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("GHOSTLINK v1.0")
                    .font(.system(size: 22, weight: .black, design: .monospaced))
                    .foregroundColor(GhostTheme.neonPink)
                Text("Operator: revishef")
                    .font(.caption)
                    .foregroundColor(GhostTheme.textSecondary)
            }
            Spacer()
            ZStack {
                Circle()
                    .fill(GhostTheme.pureBlack)
                    .frame(width: 48, height: 48)
                    .neonBorder(highlighted: true)
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(
                        LinearGradient(colors: [GhostTheme.neonPink, GhostTheme.neonPinkLight], startPoint: .top, endPoint: .bottom)
                    )
            }
        }
        .padding(.vertical, 8)
    }

    private var moduleGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
            ForEach(Array(GhostModule.allCases.enumerated()), id: \.element.id) { index, module in
                ModuleTile(module: module, index: index, visible: tilesVisible)
                    .onTapGesture {
                        appState.haptic(.medium)
                        withAnimation(appState.settings.animationsEnabled ? GhostTheme.spring : nil) {
                            appState.activeModule = module
                        }
                    }
            }
        }
    }
}

struct ModuleTile: View {
    @EnvironmentObject var appState: AppState
    let module: GhostModule
    let index: Int
    let visible: Bool
    @State private var pressed = false

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: module.icon)
                .font(.system(size: 32))
                .foregroundColor(GhostTheme.neonPink)
            Text(module.rawValue)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(GhostTheme.textPrimary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, minHeight: 120)
        .neonBorder(highlighted: pressed)
        .scaleEffect(pressed ? 0.96 : 1)
        .opacity(visible ? 1 : 0)
        .offset(x: visible ? 0 : 40)
        .animation(
            appState.settings.animationsEnabled
                ? GhostTheme.spring.delay(Double(index) * 0.05)
                : nil,
            value: visible
        )
        .onLongPressGesture(minimumDuration: 0, pressing: { p in
            withAnimation(GhostTheme.springFast) { pressed = p }
        }, perform: {})
    }
}
