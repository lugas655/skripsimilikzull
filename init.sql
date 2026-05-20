-- ==========================================
-- FILE MIGRASI & SEEDER  PERPUSTAKAAN
-- ==========================================

-- Buat database jika belum ada
CREATE DATABASE IF NOT EXISTS perpustakaan;
USE perpustakaan;

-- 1. Buat Tabel Member (Mahasiswa) jika belum ada
CREATE TABLE IF NOT EXISTS member (
    member_id VARCHAR(50) NOT NULL,
    member_name VARCHAR(100) NOT NULL,
    inst_name VARCHAR(100) NOT NULL,
    PRIMARY KEY (member_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. Data Seeder (Data Awal Mahasiswa)
-- CATATAN: Silakan sesuaikan/tambahkan NIM (member_id) di bawah ini
-- agar cocok dengan wajah-wajah yang Anda daftarkan pada SVM model Anda!
INSERT INTO member (member_id, member_name, inst_name) VALUES
('22533647', 'Andi Wijaya', 'Teknik Informatika'),
('22533646', 'Zulfiqli Kurniawan', 'Teknik Informatika'),
('22533645', 'Lugas Hermanto', 'Teknik Informatika')
ON DUPLICATE KEY UPDATE 
    member_name = VALUES(member_name),
    inst_name = VALUES(inst_name);
