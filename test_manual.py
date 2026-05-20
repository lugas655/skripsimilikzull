import cv2
import torch
import numpy as np
from ultralytics import YOLO
from facenet_pytorch import InceptionResnetV1
from torchvision import transforms
import joblib
import sys
import os
import tkinter as tk
from tkinter import filedialog

# --- KONFIGURASI PATH MODEL ---
# Pastikan file model ini berada di folder yang sama dengan file ini
# Atau sesuaikan path-nya jika model ada di folder lain.
MODEL_YOLO_PATH = 'medium.pt'
MODEL_FACE_PKL = 'model_face.pkl'
LABEL_ENCODER_PKL = 'label_encoder.pkl'

def test_image(image_path):
    if not image_path or not os.path.exists(image_path):
        print("\n[ERROR] Gambar tidak dipilih atau tidak ditemukan.")
        return

    print(f"\nMenguji gambar: {image_path}")
    print("\n=== 1. MEMUAT MODEL ===")
    device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
    print(f"Menggunakan device: {device}")

    # Load YOLO
    try:
        yolo_model = YOLO(MODEL_YOLO_PATH)
        print("[OK] Model YOLO berhasil dimuat.")
    except Exception as e:
        print(f"[GAGAL] YOLO gagal dimuat: {e}")
        return

    # Load FaceNet
    try:
        facenet_model = InceptionResnetV1(pretrained='vggface2').eval().to(device)
        print("[OK] Model FaceNet berhasil dimuat.")
    except Exception as e:
        print(f"[GAGAL] FaceNet gagal dimuat: {e}")
        return

    # Load SVM Classifier (.pkl)
    try:
        svm_classifier = joblib.load(MODEL_FACE_PKL)
        print("[OK] Model Klasifikasi (SVM) berhasil dimuat.")
    except Exception as e:
        print(f"[GAGAL] SVM Classifier gagal dimuat: {e}")
        return

    # Load Label Encoder
    try:
        label_encoder = joblib.load(LABEL_ENCODER_PKL)
        print("[OK] Label Encoder berhasil dimuat.")
    except Exception as e:
        print(f"[GAGAL] Label Encoder gagal dimuat: {e}")
        label_encoder = None

    # Preprocessing Image untuk FaceNet
    transform = transforms.Compose([
        transforms.ToPILImage(),
        transforms.Resize((160, 160)),
        transforms.ToTensor(),
        transforms.Normalize(mean=[0.5, 0.5, 0.5], std=[0.5, 0.5, 0.5])
    ])

    print("\n=== 2. MEMPROSES GAMBAR ===")
    img = cv2.imread(image_path)
    if img is None:
        print("[ERROR] File ada, tetapi OpenCV gagal membaca gambar tersebut. Pastikan itu file gambar yang valid.")
        return

    # Prediksi Wajah dengan YOLO
    results = yolo_model(img, verbose=False)

    if len(results) > 0 and len(results[0].boxes) > 0:
        # Ambil box wajah dengan confidence tertinggi (box pertama)
        boxes = results[0].boxes.xyxy.cpu().numpy()
        box = boxes[0]
        x1, y1, x2, y2 = map(int, box)
        
        # Pastikan tidak keluar batas ukuran gambar
        x1, y1 = max(0, x1), max(0, y1)
        x2, y2 = min(img.shape[1], x2), min(img.shape[0], y2)
        
        face_crop = img[y1:y2, x1:x2]

        if face_crop.size > 0:
            # Konversi warna untuk FaceNet
            face_rgb = cv2.cvtColor(face_crop, cv2.COLOR_BGR2RGB)
            face_tensor = transform(face_rgb).unsqueeze(0).to(device)
            
            # Ekstraksi Fitur dengan FaceNet
            with torch.no_grad():
                embedding = facenet_model(face_tensor).cpu().numpy()
            
            # Prediksi Identitas (Akurasi) dengan SVM
            if hasattr(svm_classifier, "predict_proba"):
                probabilities = svm_classifier.predict_proba(embedding)[0]
                best_class_idx = np.argmax(probabilities)
                max_prob = probabilities[best_class_idx]
            else:
                best_class_idx = svm_classifier.predict(embedding)[0]
                max_prob = 1.0 # Default jika SVM tidak punya probabilitas
            
            # Terjemahkan angka kelas menjadi nama/NIM asli
            if label_encoder:
                nim_atau_nama = str(label_encoder.inverse_transform([best_class_idx])[0])
            else:
                nim_atau_nama = str(svm_classifier.classes_[best_class_idx])
            
            # Tampilkan Hasil di Terminal
            print("\n=== 3. HASIL DETEKSI ===")
            print(f"Identitas / NIM  : {nim_atau_nama}")
            print(f"Tingkat Akurasi  : {max_prob * 100:.2f}%")
            print(f"Koordinat Wajah  : X1:{x1}, Y1:{y1}, X2:{x2}, Y2:{y2}")
            print("========================\n")

            # Tampilkan Gambar Pop-up (Opsional)
            cv2.rectangle(img, (x1, y1), (x2, y2), (0, 255, 0), 2)
            teks_label = f"{nim_atau_nama} ({max_prob*100:.1f}%)"
            cv2.putText(img, teks_label, (x1, y1 - 10), cv2.FONT_HERSHEY_SIMPLEX, 0.9, (0, 255, 0), 2)
            
            # Ubah ukuran window jika gambar terlalu besar
            h, w = img.shape[:2]
            if h > 800 or w > 800:
                scale = 800 / max(h, w)
                img = cv2.resize(img, (int(w * scale), int(h * scale)))

            cv2.imshow("Hasil Pengujian Manual", img)
            print("PENTING: Tekan tombol apapun pada jendela gambar yang terbuka untuk menutupnya...")
            cv2.waitKey(0)
            cv2.destroyAllWindows()
    else:
        print("\n[WARNING] Tidak ada wajah yang terdeteksi pada gambar ini oleh YOLO.")

def select_image():
    """Membuka jendela dialog sistem untuk memilih gambar"""
    # Sembunyikan window utama tkinter yang tidak terpakai
    root = tk.Tk()
    root.withdraw()
    
    # Buka dialog pemilihan file
    file_path = filedialog.askopenfilename(
        title="Pilih Gambar untuk Diuji",
        filetypes=[
            ("Image files", "*.jpg *.jpeg *.png *.bmp *.webp"),
            ("All files", "*.*")
        ]
    )
    return file_path

if __name__ == "__main__":
    print("--------------------------------------------------")
    print("       PENGUJIAN MANUAL MODEL FACE RECOGNITION    ")
    print("--------------------------------------------------")
    
    print("Membuka jendela pemilihan file... Silakan pilih gambar Anda.")
    
    # Buka GUI Upload file
    image_to_test = select_image()
    
    if image_to_test:
        test_image(image_to_test)
    else:
        print("Pengujian dibatalkan karena tidak ada gambar yang dipilih.")
