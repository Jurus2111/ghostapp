import Foundation
import Combine

final class SMSService: ObservableObject {
    static let shared = SMSService()

    @Published private(set) var isSending = false
    @Published private(set) var sentCount = 0
    @Published private(set) var lastError: String?

    func sendBurst(phone: String, count: Int, apiBaseURL: String, useSimulation: Bool, completion: @escaping (Bool) -> Void) {
        guard !phone.isEmpty, count >= 10, count <= 200 else {
            lastError = "Invalid phone or count"
            completion(false)
            return
        }
        isSending = true
        sentCount = 0
        lastError = nil
        LogStore.shared.add(module: "SMS", message: "Burst started: \(count) msgs to \(phone)")

        if useSimulation {
            simulateSend(count: count, completion: completion)
        } else {
            sendViaAPI(phone: phone, count: count, baseURL: apiBaseURL, completion: completion)
        }
    }

    private func simulateSend(count: Int, completion: @escaping (Bool) -> Void) {
        var sent = 0
        Timer.scheduledTimer(withTimeInterval: 0.08, repeats: true) { [weak self] timer in
            sent += 1
            self?.sentCount = sent
            if sent >= count {
                timer.invalidate()
                self?.isSending = false
                LogStore.shared.add(module: "SMS", message: "Simulation complete: \(count) messages queued")
                completion(true)
            }
        }
    }

    private func sendViaAPI(phone: String, count: Int, baseURL: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseURL.trimmingCharacters(in: CharacterSet(charactersIn: "/")))/send") else {
            lastError = "Invalid API URL"
            isSending = false
            completion(false)
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = ["phone": phone, "count": count]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isSending = false
                if let error = error {
                    self?.lastError = error.localizedDescription
                    LogStore.shared.add(module: "SMS", message: "API error: \(error.localizedDescription)")
                    completion(false)
                    return
                }
                if let http = response as? HTTPURLResponse, http.statusCode == 200,
                   let data = data,
                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let sent = json["sent"] as? Int {
                    self?.sentCount = sent
                    LogStore.shared.add(module: "SMS", message: "API sent \(sent) messages")
                    completion(true)
                } else {
                    self?.lastError = "Server returned error"
                    completion(false)
                }
            }
        }.resume()
    }
}
