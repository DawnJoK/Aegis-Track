import os
import uuid
from flask import Flask, request, jsonify
import firebase_admin
from firebase_admin import credentials, firestore, storage
from werkzeug.utils import secure_filename

app = Flask(__name__)

# --- FIREBASE SETUP ---
# IMPORTANT: Download your service account key from Firebase Console -> Project Settings -> Service Accounts
# Rename it to 'serviceAccountKey.json' and place it in the same 'backend' folder.
SERVICE_ACCOUNT_FILE = 'serviceAccountKey.json'

# Initialize Firebase
try:
    cred = credentials.Certificate(SERVICE_ACCOUNT_FILE)
    # REPLACE 'YOUR_PROJECT_ID.appspot.com' with your actual Firebase Storage bucket name
    # You can find this in the Firebase Console under Storage.
    firebase_admin.initialize_app(cred, {
        'storageBucket': 'YOUR_PROJECT_ID.appspot.com' 
    })
    db = firestore.client()
    bucket = storage.bucket()
    print("Firebase initialized successfully!")
except Exception as e:
    print(f"Failed to initialize Firebase: {e}")
    # Application still runs so you can see errors, but Firebase uploads won't work.

UPLOAD_FOLDER = 'uploads'
os.makedirs(UPLOAD_FOLDER, exist_ok=True)
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

@app.route('/upload', methods=['POST'])
def upload_image():
    if 'imageFile' not in request.files:
        return jsonify({"error": "No imageFile part"}), 400
    
    file = request.files['imageFile']
    if file.filename == '':
        return jsonify({"error": "No selected file"}), 400

    if file:
        filename = secure_filename(file.filename)
        if not filename:
            filename = f"esp32_{uuid.uuid4().hex}.jpg"
            
        filepath = os.path.join(app.config['UPLOAD_FOLDER'], filename)
        file.save(filepath)

        try:
            # 1. Upload to Firebase Storage
            blob = bucket.blob(f"evidence/{filename}")
            blob.upload_from_filename(filepath)
            blob.make_public() # Ensure the Flutter app can read it
            image_url = blob.public_url

            # 2. Add document to Firestore 'evidence' collection
            # Using server timestamp to match the Flutter app expectations
            doc_ref = db.collection('evidence').document()
            doc_ref.set({
                'imageUrl': image_url,
                'timestamp': firestore.SERVER_TIMESTAMP,
            })

            return jsonify({
                "message": "Upload successful",
                "imageUrl": image_url
            }), 200

        except Exception as e:
            print(f"Firebase error: {e}")
            return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    # Run server on all available interfaces on port 5000
    app.run(host='0.0.0.0', port=5000, debug=True)
