# This is the simplest code I could come up with. This checks a password and returns 'pong' when it gets pinged.

from flask import Flask, request, jsonify
import os

app = Flask(__name__)

PASSWORD = os.environ.get("API_PASSWORD", "")

@app.get("/ping")
def ping():
    supplied_password = request.args.get("password")

    if supplied_password != PASSWORD:
        return jsonify({"error": "Unauthorized"}), 401

    return jsonify({"message": "pong"})


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)