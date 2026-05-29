"""
GHOSTLINK SMS Lab Backend – EDU / controlled environment only.
Simulates SMS burst; does NOT send real SMS without integrating your provider.
"""
from flask import Flask, request, jsonify

app = Flask(__name__)


@app.route("/health")
def health():
    return jsonify({"status": "ok", "service": "ghostlink-sms-lab"})


@app.route("/send", methods=["POST"])
def send():
    data = request.get_json(force=True, silent=True) or {}
    phone = data.get("phone", "")
    count = int(data.get("count", 0))
    if not phone or count < 10 or count > 200:
        return jsonify({"error": "phone and count (10-200) required"}), 400

    # Lab simulation – replace with Twilio/etc. only in authorized lab
    print(f"[LAB] Simulated {count} SMS to {phone}")
    return jsonify({"sent": count, "phone": phone, "mode": "simulation"})


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5050, debug=True)
