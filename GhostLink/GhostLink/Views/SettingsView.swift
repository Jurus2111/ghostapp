import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @State private var showWipeConfirm = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                Text("USTAWIENIA")
                    .font(.title2.weight(.black))
                    .foregroundColor(GhostTheme.neonPink)

                settingRow(title: "Motyw", value: "Ciemny (zablokowany)", locked: true)

                Toggle("Animacje", isOn: $appState.settings.animationsEnabled)
                    .tint(GhostTheme.neonPink)
                    .foregroundColor(GhostTheme.textPrimary)
                    .onChange(of: appState.settings.animationsEnabled) { _ in appState.settings.save() }

                Toggle("Haptic", isOn: $appState.settings.hapticEnabled)
                    .tint(GhostTheme.neonPink)
                    .foregroundColor(GhostTheme.textPrimary)
                    .onChange(of: appState.settings.hapticEnabled) { _ in
                        appState.settings.save()
                        appState.haptic()
                    }

                settingRow(title: "Wersja", value: "1.0.0 (build 1)")

                Button("Usuń wszystkie dane") {
                    showWipeConfirm = true
                }
                .foregroundColor(.red)
                .padding()
                .frame(maxWidth: .infinity)
                .neonBorder()
            }
            .padding()
            .padding(.bottom, 90)
        }
        .background(GhostTheme.background)
        .alert("Usunąć wszystkie dane?", isPresented: $showWipeConfirm) {
            Button("Anuluj", role: .cancel) {}
            Button("Usuń", role: .destructive) {
                LogStore.shared.wipeAllData()
                appState.notificationHaptic(.warning)
            }
        } message: {
            Text("Logi, pakiety, AP, credentials – wszystko zostanie skasowane.")
        }
    }

    private func settingRow(title: String, value: String, locked: Bool = false) -> some View {
        HStack {
            Text(title).foregroundColor(GhostTheme.textPrimary)
            Spacer()
            Text(value)
                .foregroundColor(locked ? GhostTheme.textSecondary : GhostTheme.neonPinkLight)
                .font(.caption)
        }
        .padding()
        .neonBorder()
    }
}
