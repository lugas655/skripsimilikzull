# Penjelasan Detail Algoritma dan Perhitungan Face Recognition

Dokumen ini menjelaskan secara detail bagaimana sistem dalam `test_manual.py` dan `api.py` memproses sebuah gambar, mulai dari mendeteksi wajah hingga mengenali identitas (NIM/Nama) beserta tingkat akurasinya.

Sistem ini menggabungkan tiga komponen utama:
1. **YOLO (You Only Look Once)** untuk **Deteksi Wajah** (*Face Detection*).
2. **FaceNet (InceptionResnetV1)** untuk **Ekstraksi Fitur** (*Feature Extraction*).
3. **SVM (Support Vector Machine)** untuk **Klasifikasi Identitas** (*Classification*).

---

## 1. Tahap Deteksi Wajah dengan YOLO (`medium.pt`)

### Cara Kerja YOLO
YOLO adalah algoritma deteksi objek yang memproses seluruh gambar dalam satu kali evaluasi (*single forward pass*) menggunakan *Convolutional Neural Network* (CNN). 
1. Gambar yang diupload akan diubah ukurannya sesuai dengan standar YOLO (misalnya 640x640 piksel).
2. Gambar dibagi menjadi *grid* berukuran $S \times S$.
3. Setiap sel *grid* bertanggung jawab untuk memprediksi *Bounding Box* (kotak pembatas) dan nilai *Confidence Score*.

### Output dan Perhitungan YOLO
Ketika baris kode `yolo_model(img)` dijalankan, YOLO melakukan perhitungan matematika pada piksel gambar dan menghasilkan:
- **Bounding Box ($x_1, y_1, x_2, y_2$)**: Titik koordinat wajah di dalam gambar asli. 
  - $x_1, y_1$: Koordinat sudut kiri atas wajah.
  - $x_2, y_2$: Koordinat sudut kanan bawah wajah.
- **Objectness Score**: Persentase keyakinan YOLO bahwa kotak tersebut berisi "Wajah" dan bukan objek lain (misal: meja atau latar belakang).

Di dalam sistem, kita mengambil *Bounding Box* dengan tingkat keyakinan tertinggi, kemudian **memotong (*crop*)** gambar wajah tersebut untuk diproses ke tahap selanjutnya.

---

## 2. Tahap Ekstraksi Fitur dengan FaceNet 

Gambar wajah hasil potongan (*crop*) dari YOLO memiliki ukuran dan variasi piksel yang berbeda-beda. Komputer tidak bisa membandingkan wajah hanya dari warna pikselnya. Oleh karena itu, kita membutuhkan **FaceNet**.

### Pra-pemrosesan (Preprocessing)
Sebelum masuk ke FaceNet, potongan wajah diproses:
1. **Resize**: Diubah ukurannya secara mutlak menjadi `160 x 160` piksel.
2. **Normalisasi**: Nilai piksel (0 - 255) dinormalisasi menjadi rentang -1 hingga 1 menggunakan rumus:
   $$ \text{Pixel}_{baru} = \frac{\text{Pixel}_{lama} - \text{Mean}}{\text{Standard Deviation}} $$
   Hal ini membuat model kebal terhadap perbedaan pencahayaan yang minor.

### Perhitungan FaceNet (Embedding)
Wajah berukuran `160x160` piksel dilewatkan melalui jaringan saraf tiruan bernama **InceptionResnetV1**. Model ini telah dilatih secara khusus menggunakan jutaan wajah (dataset VGGFace2) dengan metode **Triplet Loss**.

Tujuan dari algoritma ini adalah mengubah gambar wajah menjadi sekumpulan angka matematika 1-Dimensi yang disebut **Embedding**.
- **Hasil/Output FaceNet**: Sebuah vektor numerik berisi tepat **512 angka desimal** (vektor dimensi 512).
- **Sifat Matematis**: Wajah dari orang yang sama (misal: foto Andi 1 dan foto Andi 2) akan menghasilkan vektor 512 angka yang nilai matematisnya sangat mirip (jarak Euclideannya sangat dekat). Sebaliknya, wajah dari dua orang yang berbeda akan memiliki jarak vektor yang saling menjauh.

Contoh visualisasi vektor (embedding):
`[0.012, -0.843, 0.432, 1.092, ... (hingga 512 angka)]`

---

## 3. Tahap Klasifikasi Identitas & Akurasi dengan SVM (`model_face.pkl`)

Setelah kita memiliki "KTP Matematika" (Vektor 512 angka) dari wajah tersebut, tugas terakhir adalah menebak vektor tersebut milik NIM/Nama siapa. Ini dilakukan oleh **Support Vector Machine (SVM)**.

### Konsep Hyperplane SVM
Dalam proses *training* (`train.py`), SVM menerima ribuan vektor 512 dimensi dari berbagai orang. SVM kemudian menggambar **Hyperplane** (garis/bidang pembatas matematika berdimensi tinggi) yang memisahkan area vektor milik "Orang A", "Orang B", "Orang C", dan seterusnya.

### Perhitungan Probabilitas / Akurasi (Akurasi di Terminal)
Ketika gambar baru diuji pada `test_manual.py`, vektor 512 angka tersebut dilempar ke ruang SVM. 
SVM menghitung jarak matematis antara vektor baru tersebut dengan bidang-bidang pembatas kelas (*Hyperplane*).

Karena kita menggunakan konfigurasi `probability=True` saat melatih SVM, jarak ini dikonversi menjadi persentase probabilitas menggunakan metode **Platt Scaling** (sebuah fungsi *Logistic Regression* internal di atas *output* SVM).

Rumus penyederhanaan probabilitas (Fungsi Logistik):
$$ P(y=Kelas | X) = \frac{1}{1 + e^{A \cdot f(X) + B}} $$
Dimana:
- $f(X)$ adalah jarak titik vektor wajah ke garis pembatas SVM.
- $A$ dan $B$ adalah parameter matematika yang dipelajari dan disimpan secara otomatis oleh model SVM (`model_face.pkl`).

### Eksekusi di Sistem:
1. `probabilities = svm_classifier.predict_proba(embedding)[0]`
   Sistem menghitung probabilitas kecocokan wajah dengan semua orang yang ada di dalam database.
   Contoh hasil (jika ada 3 orang di database): `[0.05, 0.92, 0.03]`
2. `best_class_idx = np.argmax(probabilities)`
   Sistem mencari nilai probabilitas tertinggi (yaitu `0.92` yang berada di indeks ke-1).
3. `max_prob = probabilities[best_class_idx]`
   Nilai ini (0.92) dikalikan 100 dan ditampilkan di terminal sebagai **Tingkat Akurasi 92.00%**. Ingat, nilai ini menunjukkan **Tingkat Kepercayaan (Confidence Level)** model bahwa wajah di gambar tersebut benar-benar milik orang pada indeks tersebut.
4. **Label Encoder (`label_encoder.pkl`)**: Mengubah indeks "1" kembali menjadi teks asli, misalnya "NIM: 12345".

---

## 4. Contoh Kasus Matematis: Dari Gambar ke Output NIM

Mari kita simulasikan perjalanan matematis gambar foto mahasiswa bernama **Budi (NIM: 123456)**, yang fotonya diunggah ke dalam `test_manual.py`.

### Langkah A: YOLO Memotong Gambar
- Misalkan gambar asli berukuran `1920 x 1080` piksel.
- **YOLO** membagi gambar menjadi kotak-kotak (grid) dan memberikan prediksi koordinat (*Bounding Box*).
- Hasil YOLO: `[x1: 450, y1: 200, x2: 700, y2: 550]`.
- YOLO memiliki tingkat keyakinan (Confidence) sebesar `0.89` (89%) bahwa koordinat tersebut adalah wajah manusia. Karena nilainya tinggi, sistem memotong gambar dari area koordinat tersebut.

### Langkah B: Transformasi (Normalisasi Piksel)
- Gambar wajah yang dipotong (ukuran 250x350 piksel) dipaksa menjadi persegi berukuran **160x160 piksel**.
- Misalkan nilai salah satu piksel di hidung Budi memiliki warna RGB `(150, 100, 50)`.
- Rumus normalisasi di *PyTorch*:
  - Mengubah skala RGB dari `0-255` menjadi `0.0 - 1.0` $\rightarrow$ `(0.58, 0.39, 0.19)`.
  - Mengurangi dengan *Mean* (0.5) dan membagi dengan *Standar Deviasi* (0.5).
  - Nilai matematis piksel hidung sekarang menjadi: `(0.16, -0.22, -0.62)`.
  Seluruh 25.600 piksel (160x160 piksel) diubah dengan cara yang sama menjadi matriks angka desimal.

### Langkah C: FaceNet Menghasilkan Embedding
- Matriks piksel (yang isinya angka seperti 0.16, -0.22, dll) dimasukkan ke dalam **FaceNet (InceptionResnetV1)**.
- FaceNet melakukan ribuan operasi perkalian matriks (*Convolution*) di puluhan lapisannya.
- Pada lapisan terakhirnya, FaceNet meremas semua informasi tersebut dan mengeluarkan tepat **512 angka desimal** (*Embedding*).
- Misalkan vektor 512 angka Budi yang keluar adalah:
  $$ V_{Budi} = [0.12, -0.45, 0.88, 0.01, ..., -0.33] $$

### Langkah D: Prediksi Jarak oleh SVM
- Vektor Budi ($V_{Budi}$) dilemparkan ke model **SVM** (`model_face.pkl`).
- Misalkan di dalam database, SVM telah dilatih mengenali 3 kelas (0: Andi, 1: Budi, 2: Citra).
- SVM memiliki "garis batas" (*Hyperplane*). SVM menghitung **jarak matematis** (*margin*) antara vektor $V_{Budi}$ yang baru dengan masing-masing garis batas kelas.
  - Jarak ke wilayah kelas 0 (Andi) = `-2.5` (Angka negatif = Sangat salah arah).
  - Jarak ke wilayah kelas 1 (Budi) = `+4.8` (Angka positif = Sangat tepat berada di dalam wilayah Budi).
  - Jarak ke wilayah kelas 2 (Citra) = `-1.2` (Salah arah).

### Langkah E: Menghitung Akurasi (Probabilitas) dengan Fungsi Eksponensial (Softmax/Platt Scaling)
- Nilai jarak tersebut (`-2.5`, `4.8`, `-1.2`) tidak bisa langsung ditampilkan sebagai "akurasi %". Maka, nilai jarak ini dihitung menggunakan rumus eksponensial pembagian probabilitas:
  $$ P(Kelas 1) = \frac{e^{4.8}}{e^{-2.5} + e^{4.8} + e^{-1.2}} $$
  $$ P(Kelas 1) = \frac{121.51}{0.08 + 121.51 + 0.30} $$
  $$ P(Kelas 1) = \frac{121.51}{121.89} = 0.9968 $$
- Hasil *array probabilitas* dari ketiga kelas adalah: `[0.0006, 0.9968, 0.0026]`
- Sistem (menggunakan kode `np.argmax`) secara otomatis memilih nilai probabilitas yang paling tinggi $\rightarrow$ **0.9968**.

### Langkah F: Label Encoder & Output Akhir
- Nilai terbesar berada pada urutan (indeks) ke-`1`.
- `max_prob = 0.9968`. Jika dikalikan 100, menjadi tingkat akurasi **99.68%**.
- Sistem memanggil **Label Encoder** (`label_encoder.pkl`):
  *"Hai Label Encoder, tolong terjemahkan siapa orang yang berada di daftar urutan angka 1 ini."*
- Label Encoder membuka catatan kamusnya di memori:
  - Indeks 0 = "123455" (Andi)
  - **Indeks 1 = "123456" (Budi)**
  - Indeks 2 = "123457" (Citra)
- Output Akhir Terbentuk: Sistem mencetak ke layar terminal (dan aplikasi SLiMS Anda): **Identitas / NIM: 123456** dengan **Tingkat Akurasi: 99.68%**.

---

## Ringkasan Alur Sistem

1. **Input**: Gambar `test.jpg` masuk ke dalam `test_manual.py`.
2. **YOLO**: Menemukan lokasi wajah di piksel `X1=150, Y1=60, X2=300, Y2=250` dan memotong bagian tersebut saja.
3. **Transform**: Wajah hasil potongan dipaksa berukuran `160x160` dan warnanya diseragamkan (*normalized*).
4. **FaceNet**: Meremas dan mengekstrak gambar wajah tersebut menjadi deretan **`512`** angka desimal (*Embedding*).
5. **SVM**: Mengecek deretan 512 angka tersebut dan menghitung jaraknya ke model referensi orang-orang di database. Ditemukan kecocokan terbesar pada indeks tertentu dengan **persentase/probabilitas X%**.
6. **Output Akhir**: Label Encoder mengubah indeks menjadi NIM/Nama, lalu program memunculkan kotak hijau, teks NIM, dan nilai X% di layar Anda.
