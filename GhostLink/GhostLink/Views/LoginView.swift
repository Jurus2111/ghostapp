import SwiftUI

struct LoginView: View {
    @EnvironmentObject var appState: AppState
    @State private var username = ""
    @State private var password = ""
    @State private var showError = false
    @State private var shakeTrigger: CGFloat = 0
    @State private var buttonHoverShake: CGFloat = 0

    var body: some View {
        ZStack {
            MatrixBackground()

            VStack(spacing: 28) {
                Spacer()

                VStack(spacing: 8) {
                    Image(systemName: "ghost.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(
                            LinearGradient(colors: [GhostTheme.neonPink, GhostTheme.neonPinkLight], startPoint: .top, endPoint: .bottom)
                        )
                        .shadow(color: GhostTheme.neonPink.opacity(0.8), radius: 16)

                    Text("GHOSTLINK")
                        .font(.system(size: 32, weight: .black, design: .monospaced))
                        .foregroundColor(GhostTheme.neonPink)
                }

                VStack(spacing: 16) {
                    NeonTextField(placeholder: "Login", text: $username)
                    NeonTextField(placeholder: "Hasło", text: $password, isSecure: true)
                }
                .padding(.horizontal, 24)

                Button {
                    attemptLogin()
                } label: {
                    Text("ENTER GHOSTLINK")
                        .font(.headline.weight(.bold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(colors: [GhostTheme.neonPinkLight, GhostTheme.neonPink], startPoint: .leading, endPoint: .trailing)
                        )
                        .cornerRadius(12)
                        .shadow(color: GhostTheme.neonPink.opacity(0.7), radius: 12)
                }
                .buttonStyle(WaveButtonStyle())
                .padding(.horizontal, 24)
                .modifier(ShakeEffect(animatableData: shakeTrigger))
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in
                            withAnimation(.default.repeatCount(2, autoreverses: true)) {
                                buttonHoverShake += 1
                            }
                            appState.haptic(.soft)
                        }
                )

                Spacer()
                Spacer()
            }
        }
        .alert("Nie kurwa, Alpha się nie poddaje", isPresented: $showError) {
            Button("OK", role: .cancel) {
                withAnimation { shakeTrigger += 1 }
                appState.notificationHaptic(.error)
            }
        }
    }

    private func attemptLogin() {
        if appState.login(username: username, password: password) {
            appState.haptic(.heavy)
            appState.showFlashTransition = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
                appState.showFlashTransition = false
                appState.completeLogin()
            }
        } else {
            showError = true
            withAnimation { shakeTrigger += 1 }
        }
    }
}
