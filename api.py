import os
import cv2
import numpy as np
import base64
import re
import mysql.connector
from flask import Flask, request, jsonify, render_template
from ultralytics import YOLO
from flask_cors import CORS
import torch
from facenet_pytorch import InceptionResnetV1
from torchvision import transforms
import joblib

app = Flask(__name__)
app.config['TEMPLATES_AUTO_RELOAD'] = True
CORS(app)

# --- KONFIGURASI ---
MODEL_YOLO_PATH = 'medium.pt'
#MODEL_FACE_PKL = 'model_face.pkl'
MODEL_FACE_PKL = 'face_classifier_model.pkl'
LABEL_ENCODER_PKL = 'label_encoder.pkl'

DB_CONFIG = {
    'host': os.environ.get('DB_HOST', 'localhost'),
    'user': os.environ.get('DB_USER', 'root'),
    'password': os.environ.get('DB_PASSWORD', ''),
    'database': os.environ.get('DB_DATABASE', 'perpustakaan')
}

PORT = int(os.environ.get('PORT', 5001))

# Buffer untuk Sinkronisasi
signal_buffer = None
receipt_buffer = None

# FIX: Deklarasi global dulu agar tidak "not defined" jika load gagal
model_yolo = None
facenet_model = None
svm_classifier = None
label_encoder = None
device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')

transform = transforms.Compose([
    transforms.ToPILImage(),
    transforms.Resize((160, 160)),
    transforms.ToTensor(),
    transforms.Normalize(mean=[0.5, 0.5, 0.5], std=[0.5, 0.5, 0.5])
])

# --- LOAD MODELS ---
print("Memuat model YOLO...")
try:
    model_yolo = YOLO(MODEL_YOLO_PATH)
    print("  [OK] YOLO berhasil dimuat.")
except Exception as e:
    print(f"  [GAGAL] YOLO: {e}")

print("Memuat model FaceNet...")
try:
    facenet_model = InceptionResnetV1(pretrained='vggface2').eval().to(device)
    print("  [OK] FaceNet berhasil dimuat.")
except Exception as e:
    print(f"  [GAGAL] FaceNet: {e}")

print("Memuat model Klasifikasi (SVM)...")
try:
    svm_classifier = joblib.load(MODEL_FACE_PKL)
    print("  [OK] Model Klasifikasi (SVM) berhasil dimuat.")
except Exception as e:
    print(f"  [GAGAL] Model Klasifikasi (SVM): {e}")

print("Memuat Label Encoder...")
try:
    label_encoder = joblib.load(LABEL_ENCODER_PKL)
    print("  [OK] Label Encoder berhasil dimuat.")
except Exception as e:
    print(f"  [GAGAL] Label Encoder: {e}")


def get_member_info(nim):
    try:
        conn = mysql.connector.connect(**DB_CONFIG)
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT member_name, inst_name FROM member WHERE member_id = %s", (nim,))
        data = cursor.fetchone()
        cursor.close()
        conn.close()
        return data
    except Exception as e:
        print(f"Database error: {e}")
        return None

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/scan_face', methods=['POST'])
def scan_face():
    global signal_buffer

    # FIX: Cek apakah model sudah ter-load sebelum digunakan
    if model_yolo is None or facenet_model is None or svm_classifier is None:
        return jsonify({
            "status": "error",
            "message": "Model belum ter-load. Cek log server untuk detail error."
        })

    try:
        data = request.json
        img_b64 = data.get('image')
        img_data = re.sub('^data:image/.+;base64,', '', img_b64)
        np_arr = np.frombuffer(base64.b64decode(img_data), np.uint8)
        frame = cv2.imdecode(np_arr, cv2.IMREAD_COLOR)

        # --- ENHANCEMENT UNTUK KONDISI GELAP (LOW-LIGHT) ---
        # Menggunakan CLAHE (Contrast Limited Adaptive Histogram Equalization)
        # Pisahkan channel kecerahan (Luminance) dari warna agar warna tidak rusak
        lab = cv2.cvtColor(frame, cv2.COLOR_BGR2LAB)
        l, a, b = cv2.split(lab)
        
        # Terapkan CLAHE untuk menerangkan area yang gelap secara otomatis
        clahe = cv2.createCLAHE(clipLimit=2.5, tileGridSize=(8,8))
        cl = clahe.apply(l)
        
        # Gabungkan kembali dan kembalikan ke format BGR
        limg = cv2.merge((cl, a, b))
        frame = cv2.cvtColor(limg, cv2.COLOR_LAB2BGR)
        # ---------------------------------------------------

        # STEP 1: Deteksi lokasi wajah dengan YOLO
        results = model_yolo.predict(source=frame, conf=0.2, verbose=False)
        
        if len(results) > 0 and len(results[0].boxes) > 0:
            # Ambil wajah dengan confidence tertinggi
            boxes = results[0].boxes.xyxy.cpu().numpy()
            box = boxes[0] # [x1, y1, x2, y2]
            
            x1, y1, x2, y2 = map(int, box)
            
            x1, y1 = max(0, x1), max(0, y1)
            x2, y2 = min(frame.shape[1], x2), min(frame.shape[0], y2)
            
            face_crop = frame[y1:y2, x1:x2]

            if face_crop.size > 0:
                # STEP 2: Ekstraksi fitur (Embedding) dengan FaceNet
                face_rgb = cv2.cvtColor(face_crop, cv2.COLOR_BGR2RGB)
                face_tensor = transform(face_rgb).unsqueeze(0).to(device)
                
                with torch.no_grad():
                    embedding = facenet_model(face_tensor).cpu().numpy()
                
                # STEP 3: Prediksi dengan SVM Klasifikator
                if hasattr(svm_classifier, "predict_proba"):
                    probabilities = svm_classifier.predict_proba(embedding)[0]
                    best_class_idx = np.argmax(probabilities)
                    max_prob = probabilities[best_class_idx]
                else:
                    best_class_idx = svm_classifier.predict(embedding)[0]
                    max_prob = 1.0 # Default jika tak ada probabilitas
                
                # Threshold: 0.50 disamakan dengan test_manual.py untuk bacaan lebih baik
                if max_prob >= 0.20:
                    if label_encoder:
                        nim = str(label_encoder.inverse_transform([best_class_idx])[0])
                    else:
                        nim = str(svm_classifier.classes_[best_class_idx])
                    
                    # STEP 4: Ambil data dari MySQL
                    member = get_member_info(nim)
                    if member:
                        signal_buffer = nim
                        
                        # --- GAMBAR KOTAK HIJAU SAJA ---
                        cv2.rectangle(frame, (x1, y1), (x2, y2), (0, 255, 0), 4) # Kotak Hijau tebal 4
                        
                        # Kompresi gambar JPEG dengan kualitas 60% agar hemat bandwidth dan cepat terunduh via Ngrok
                        _, buffer = cv2.imencode('.jpg', frame, [int(cv2.IMWRITE_JPEG_QUALITY), 60])
                        frame_b64 = base64.b64encode(buffer).decode('utf-8')
                        
                        return jsonify({
                            "status": "success",
                            "nim": nim,
                            "member_name": member['member_name'],
                            "inst_name": member['inst_name'],
                            "confidence": round(float(max_prob) * 100, 1),
                            "result_image": frame_b64
                        })
        
        return jsonify({"status": "failure", "message": "Wajah tidak terdaftar atau kemiripan rendah"})
    
    except Exception as e:
        print(f"Error pada /scan_face: {e}")
        return jsonify({"status": "error", "message": str(e)})

@app.route('/get_signal', methods=['GET'])
def get_signal():
    global signal_buffer
    if signal_buffer:
        nim = signal_buffer
        signal_buffer = None
        return jsonify({"status": "ok", "nim": nim})
    return jsonify({"status": "empty"})

@app.route('/send_receipt', methods=['POST'])
def send_receipt():
    global receipt_buffer
    data = request.json
    receipt_buffer = data
    return jsonify({"status": "ok"})

@app.route('/get_receipt', methods=['GET'])
def get_receipt():
    global receipt_buffer
    if receipt_buffer:
        receipt = receipt_buffer
        receipt_buffer = None
        return jsonify({"status": "ok", "data": receipt})
    return jsonify({"status": "empty"})

if __name__ == '__main__':
    print("\n" + "="*50)
    print(f"SISTEM ABSENSI PERPUSTAKAAN (FACENET SVM)")
    print(f"Server berjalan di http://0.0.0.0:{PORT}")
    print("="*50 + "\n")

    try:
        app.run(host='0.0.0.0', port=PORT, debug=False)
    except KeyboardInterrupt:
        print("\nMematikan Server...")