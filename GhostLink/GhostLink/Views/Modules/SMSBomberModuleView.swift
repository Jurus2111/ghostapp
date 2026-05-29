import SwiftUI

struct SMSBomberModuleView: View {
    @EnvironmentObject var appState: AppState
    @State private var phone = ""
    @State private var count: Double = 50
    @State private var useSimulation = true
    @State private var isSending = false
    @State private var sentCount = 0
    @State private var lastError: String?

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

                Button(isSending ? "Wysyłanie… \(sentCount)" : "WYBUCH") {
                    appState.haptic(.heavy)
                    SMSService.shared.sendBurst(
                        phone: phone,
                        count: Int(count),
                        apiBaseURL: appState.settings.smsAPIBaseURL,
                        useSimulation: useSimulation
                    ) { ok in
                        appState.notificationHaptic(ok ? .success : .error)
                        syncSMS()
                    }
                    syncSMS()
                }
                .buttonStyle(NeonFillButtonStyle())
                .disabled(isSending)

                if let err = lastError {
                    Text(err).font(.caption).foregroundColor(.red)
                }
            }
            .padding()
            .padding(.bottom, 40)
        }
        .background(GhostTheme.background)
        .onReceive(SMSService.shared.$isSending) { _ in syncSMS() }
        .onReceive(SMSService.shared.$sentCount) { _ in syncSMS() }
        .onReceive(SMSService.shared.$lastError) { _ in syncSMS() }
    }

    private func syncSMS() {
        isSending = SMSService.shared.isSending
        sentCount = SMSService.shared.sentCount
        lastError = SMSService.shared.lastError
    }
}
