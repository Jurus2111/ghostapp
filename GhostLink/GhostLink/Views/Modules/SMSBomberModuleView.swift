import SwiftUI

struct SMSBomberModuleView: View {
    @EnvironmentObject var appState: AppState
    @ObservedObject private var sms = SMSService.shared
    @State private var phone = ""
    @State private var count: Double = 50
    @State private var useSimulation = true

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                Text("SMS BOMBER")
                    .font(.title2.weight(.black))
                    .foregroundColor(GhostTheme.neonPink)
                    .padding(.top, 56)

                TextField("+48 numer telefonu", text: $phone)
                    .keyboardType(.phonePad)
                    .padding()
                    .foregroundColor(GhostTheme.textPrimary)
                    .background(GhostTheme.pureBlack)
                    .neonBorder()

                Text("SMS: \(Int(count))")
                    .foregroundColor(GhostTheme.textSecondary)
                Slider(value: $count, in: 10...200, step: 1)
                    .tint(GhostTheme.neonPink)

                Toggle("Tryb symulacji (lab)", isOn: $useSimulation)
                    .foregroundColor(GhostTheme.textPrimary)
                    .tint(GhostTheme.neonPink)

                if !useSimulation {
                    TextField("API URL", text: Binding(
                        get: { appState.settings.smsAPIBaseURL },
                        set: {
                            appState.settings.smsAPIBaseURL = $0
                            appState.settings.save()
                        }
                    ))
                    .padding()
                    .foregroundColor(GhostTheme.textPrimary)
                    .background(GhostTheme.pureBlack)
                    .neonBorder()
                }

                Button(sms.isSending ? "Wysyłanie… \(sms.sentCount)" : "WYBUCH") {
                    appState.haptic(.heavy)
                    sms.sendBurst(
                        phone: phone,
                        count: Int(count),
                        apiBaseURL: appState.settings.smsAPIBaseURL,
                        useSimulation: useSimulation
                    ) { ok in
                        appState.notificationHaptic(ok ? .success : .error)
                    }
                }
                .buttonStyle(NeonFillButtonStyle())
                .disabled(sms.isSending)

                if let err = sms.lastError {
                    Text(err).font(.caption).foregroundColor(.red)
                }
            }
            .padding()
            .padding(.bottom, 40)
        }
        .background(GhostTheme.background)
    }
}
