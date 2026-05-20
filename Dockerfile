# Gunakan base image Python yang ringan
FROM python:3.10-slim

# Atur variabel lingkungan Python
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PORT=5001

# Tentukan direktori kerja di dalam container
WORKDIR /app

# Instal dependensi sistem dasar untuk OpenCV, PyTorch, dan proses kompilasi C++
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libgl1 \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Salin file requirements ke dalam container
COPY requirements.txt /app/

# OPTIMALISASI: Instal PyTorch versi CPU agar ukuran image Docker jauh lebih kecil (~1.2GB vs ~4.5GB)
RUN pip install --no-cache-dir torch torchvision --index-url https://download.pytorch.org/whl/cpu && \
    pip install --no-cache-dir -r requirements.txt

# Salin seluruh kode proyek ke dalam container
COPY . /app/

# Ekspos port aplikasi Flask
EXPOSE 5001

# Jalankan aplikasi Flask API
CMD ["python", "api.py"]
