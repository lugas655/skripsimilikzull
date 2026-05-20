const video = document.getElementById('videoElement');
const canvas = document.getElementById('canvasElement');
const context = canvas.getContext('2d');

let isDetected = false;
let currentStream = null;
let currentFacingMode = 'user'; // 'user' untuk kamera depan, 'environment' untuk kamera belakang

// 1. Fungsi untuk Memulai Kamera dengan Fallback dan Error Handling
function startCamera() {
    // Sembunyikan container error
    const errorBox = document.getElementById('camera-error');
    if (errorBox) errorBox.style.display = 'none';

    // Hentikan stream yang sedang berjalan jika ada
    if (currentStream) {
        currentStream.getTracks().forEach(track => track.stop());
    }

    // Cek apakah browser mendukung mediaDevices (Wajib menggunakan HTTPS di mobile)
    if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) {
        showCameraError(
            "Izin kamera diblokir browser atau koneksi tidak aman (HTTP). " +
            "Gunakan koneksi aman HTTPS atau tautan NGROK Anda untuk membuka halaman ini di HP."
        );
        return;
    }

    // Terapkan efek cermin (mirror) hanya untuk kamera depan (user)
    if (currentFacingMode === 'user') {
        video.style.transform = 'scaleX(-1)';
    } else {
        video.style.transform = 'none';
    }

    // Pilihan constraints pertama: ideal HD 720p dengan facingMode pilihan
    const constraintsHD = {
        video: {
            facingMode: { ideal: currentFacingMode },
            width: { ideal: 1280 },
            height: { ideal: 720 }
        }
    };

    // Pilihan constraints kedua: fallback standar jika HD ditolak/tidak disupport
    const constraintsStandard = {
        video: {
            facingMode: currentFacingMode
        }
    };

    navigator.mediaDevices.getUserMedia(constraintsHD)
        .then(stream => {
            currentStream = stream;
            video.srcObject = stream;
            // PENTING: Panggil play() secara eksplisit agar stream video mulai berjalan di HP
            video.play().catch(e => console.log("Video play interrupted:", e));
        })
        .catch(err => {
            console.warn("Mencoba fallback kamera tanpa batasan resolusi...", err);
            navigator.mediaDevices.getUserMedia(constraintsStandard)
                .then(stream => {
                    currentStream = stream;
                    video.srcObject = stream;
                    video.play().catch(e => console.log("Fallback video play interrupted:", e));
                })
                .catch(fallbackErr => {
                    console.error("Akses Kamera Gagal:", fallbackErr);
                    let errorMsg = "Gagal mengakses kamera. Silakan pastikan izin kamera telah diberikan.";
                    if (fallbackErr.name === 'NotAllowedError' || fallbackErr.name === 'PermissionDeniedError') {
                        errorMsg = "Izin kamera ditolak. Silakan izinkan akses kamera di pengaturan browser Anda.";
                    } else if (fallbackErr.name === 'NotFoundError' || fallbackErr.name === 'DevicesNotFoundError') {
                        errorMsg = "Kamera tidak ditemukan pada perangkat Anda.";
                    }
                    showCameraError(errorMsg);
                });
        });
}

function showCameraError(message) {
    const errorBox = document.getElementById('camera-error');
    const errorMsgText = document.getElementById('camera-error-msg');
    if (errorBox && errorMsgText) {
        errorMsgText.textContent = message;
        errorBox.style.display = 'flex';
    }
}

// Jalankan kamera saat pertama kali dimuat
startCamera();

// Event Listener untuk Tombol Ganti Kamera
const switchCamBtn = document.getElementById('switch-camera-btn');
if (switchCamBtn) {
    switchCamBtn.addEventListener('click', () => {
        // Toggle antara 'user' (depan) dan 'environment' (belakang)
        currentFacingMode = currentFacingMode === 'user' ? 'environment' : 'user';
        
        // Animasi rotasi icon saat diklik
        const icon = switchCamBtn.querySelector('i');
        if (icon) {
            icon.style.transition = 'transform 0.5s ease';
            icon.style.transform = (icon.style.transform === 'rotate(180deg)' ? 'rotate(360deg)' : 'rotate(180deg)');
        }
        
        startCamera();
    });
}

// Event Listener untuk Tombol Coba Lagi pada box error
const retryCamBtn = document.getElementById('retry-camera-btn');
if (retryCamBtn) {
    retryCamBtn.addEventListener('click', () => {
        startCamera();
    });
}

// 2. Loop Deteksi Wajah (Menggunakan URL relatif agar bisa diakses dari HP via IP/Ngrok)
let isProcessing = false;

function scanFace() {
    if (isDetected) return; // Hentikan pemindaian jika sudah terdeteksi sukses
    
    if (isProcessing) {
        // Jika request sebelumnya masih berjalan, tunggu 300ms lalu cek lagi
        setTimeout(scanFace, 300);
        return;
    }

    if (video.videoWidth > 0) {
        isProcessing = true;
        
        // Downscale resolusi gambar untuk mempercepat upload via Ngrok (satset!)
        const maxDim = 640;
        let width = video.videoWidth;
        let height = video.videoHeight;
        
        if (width > maxDim || height > maxDim) {
            if (width > height) {
                height = Math.round((height * maxDim) / width);
                width = maxDim;
            } else {
                width = Math.round((width * maxDim) / height);
                height = maxDim;
            }
        }
        
        canvas.width = width;
        canvas.height = height;
        context.drawImage(video, 0, 0, width, height);
        
        // Kompresi kualitas JPEG menjadi 0.5 (ukuran berkas mengecil 90% sehingga upload instan)
        const imageData = canvas.toDataURL('image/jpeg', 0.5);

        // Menggunakan relative path '/scan_face' agar fleksibel
        fetch('/scan_face', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ image: imageData })
        })
            .then(res => res.json())
            .then(data => {
                isProcessing = false;

                if (data.status === 'success') {
                    isDetected = true;

                    // Isi data profil
                    document.getElementById('nim-val').textContent = data.nim;
                    document.getElementById('nama-val').textContent = data.member_name;
                    document.getElementById('inst-val').textContent = data.inst_name;

                    // Tampilkan kotak TERVERIFIKASI
                    const authBox = document.getElementById('auth-status-box');
                    if (authBox) authBox.style.display = 'flex';

                    // Ubah badge kamera
                    const camBadge = document.getElementById('cam-status-badge');
                    if (camBadge) {
                        camBadge.textContent = 'Terdeteksi';
                        camBadge.className = 'camera-status success';
                    }

                    // Sembunyikan scanning overlay
                    const scanOverlay = document.getElementById('scan-overlay');
                    if (scanOverlay) scanOverlay.style.display = 'none';

                    // Sembunyikan video live, tampilkan gambar hasil
                    video.style.display = 'none';

                    let imgResult = document.getElementById('img-result');
                    if (!imgResult) {
                        imgResult = document.createElement('img');
                        imgResult.id = 'img-result';
                        document.querySelector('.camera-box').appendChild(imgResult);
                    }

                    // Terapkan efek cermin (mirror) pada hasil scan hanya jika menggunakan kamera depan
                    if (currentFacingMode === 'user') {
                        imgResult.style.transform = 'scaleX(-1)';
                    } else {
                        imgResult.style.transform = 'none';
                    }

                    if (data.result_image) {
                        imgResult.src = "data:image/jpeg;base64," + data.result_image;
                        imgResult.style.display = 'block';
                    }

                    // Tampilkan badge akurasi
                    const accuracyBadge = document.getElementById('accuracy-badge');
                    if (accuracyBadge) {
                        document.getElementById('acc-value-text').textContent = data.confidence + '%';
                        accuracyBadge.style.display = 'flex';
                    }

                    // Bersihkan warning danger jika ada pemindaian sukses berikutnya
                    const instructionBox = document.getElementById('main-instruction');
                    if (instructionBox) {
                        instructionBox.classList.remove('danger');
                        const iconEl = instructionBox.querySelector('.info-icon i');
                        if (iconEl) iconEl.className = 'fa-solid fa-info';
                    }
                } else {
                    // --- WAJAH TIDAK TERDAFTAR DI DATABASE ---
                    const camBadge = document.getElementById('cam-status-badge');
                    if (camBadge) {
                        camBadge.textContent = 'Tidak Dikenali';
                        camBadge.className = 'camera-status danger';
                    }

                    const instructionBox = document.getElementById('main-instruction');
                    if (instructionBox) {
                        instructionBox.classList.add('danger');
                        const iconEl = instructionBox.querySelector('.info-icon i');
                        if (iconEl) iconEl.className = 'fa-solid fa-triangle-exclamation';
                        
                        const textEl = instructionBox.querySelector('.info-text');
                        if (textEl) {
                            textEl.innerHTML = '<strong>Wajah Tidak Ditemukan!</strong><br>Data wajah Anda belum terdaftar di sistem perpustakaan.';
                        }
                    }

                    // Reset pesan kembali ke normal setelah 1.5 detik
                    setTimeout(() => {
                        if (!isDetected) {
                            if (camBadge && camBadge.textContent === 'Tidak Dikenali') {
                                camBadge.textContent = 'Memindai...';
                                camBadge.className = 'camera-status';
                            }
                            if (instructionBox && instructionBox.classList.contains('danger')) {
                                instructionBox.classList.remove('danger');
                                const subIcon = instructionBox.querySelector('.info-icon i');
                                if (subIcon) subIcon.className = 'fa-solid fa-info';
                                
                                const subText = instructionBox.querySelector('.info-text');
                                if (subText) {
                                    subText.innerHTML = 'Berdiri di depan kamera untuk verifikasi.<br>Data Anda akan otomatis terkirim ke komputer petugas.';
                                }
                            }
                        }
                    }, 1500);

                    // Lanjutkan pemindaian dengan cepat setelah 400ms jika terdeteksi gagal (satset!)
                    setTimeout(scanFace, 400);
                }
            })
            .catch(err => {
                console.log("Fetch error:", err);
                isProcessing = false;
                // Jika error jaringan / server offline, tunggu 1.5 detik baru coba lagi
                setTimeout(scanFace, 1500);
            });
    } else {
        // Tunggu hingga feed video kamera aktif
        setTimeout(scanFace, 500);
    }
}

// Mulai loop pemindaian pertama kali
setTimeout(scanFace, 1000);

// 3. Update Jam dan Tanggal
function updateClock() {
    const now = new Date();
    const optionsDate = { day: 'numeric', month: 'long', year: 'numeric' };
    document.getElementById('current-date').textContent = now.toLocaleDateString('id-ID', optionsDate);

    const hours = String(now.getHours()).padStart(2, '0');
    const minutes = String(now.getMinutes()).padStart(2, '0');
    document.getElementById('current-time').textContent = `${hours}:${minutes} WIB`;
}
setInterval(updateClock, 1000);
updateClock();

// 4. Polling Struk dari Server (Menggunakan URL relatif agar bisa diakses dari HP)
setInterval(() => {
    if (!isDetected) return;

    fetch('/get_receipt')
        .then(res => res.json())
        .then(data => {
            if (data.status === 'found' || (data.status === 'ok' && data.data)) {
                // Perbaiki pengecekan status dan data response
                const receiptData = data.data;
                document.getElementById('receipt-box').style.display = 'block';
                document.getElementById('main-instruction').style.display = 'none';
                document.getElementById('rec-buku').textContent = receiptData.buku || '-';
                document.getElementById('rec-pinjam').textContent = receiptData.tgl_pinjam || '-';
                document.getElementById('rec-kembali').textContent = receiptData.tgl_kembali || '-';
            }
        })
        .catch(err => console.log("Receipt fetch error:", err));
}, 2000);

// 5. Tombol Reset
document.getElementById('reset-btn').addEventListener('click', () => {
    isDetected = false;
    location.reload();
});