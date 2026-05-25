-- ==========================================
-- FILE MIGRASI & SEEDER  PERPUSTAKAAN
-- ==========================================

-- Buat database jika belum ada
CREATE DATABASE IF NOT EXISTS perpustakaan;
USE perpustakaan;

--
-- Table structure for table `member`
--
DROP TABLE IF EXISTS `member`;
CREATE TABLE `member` (
  `member_id` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `member_name` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `gender` int NOT NULL,
  `birth_date` date DEFAULT NULL,
  `member_type_id` int DEFAULT NULL,
  `member_address` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `member_mail_address` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `member_email` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `postal_code` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `inst_name` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `is_new` int DEFAULT NULL,
  `member_image` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `pin` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `member_phone` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `member_fax` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `member_since_date` date DEFAULT NULL,
  `register_date` date DEFAULT NULL,
  `expire_date` date NOT NULL,
  `member_notes` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci,
  `is_pending` smallint NOT NULL DEFAULT '0',
  `mpasswd` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `last_login` datetime DEFAULT NULL,
  `last_login_ip` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `input_date` date DEFAULT NULL,
  `last_update` date DEFAULT NULL,
  `kode_ins` varchar(10) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `username` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`member_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

--
-- Dumping data for table `member`
--

INSERT INTO `member` (`member_id`, `member_name`, `gender`, `birth_date`, `member_type_id`, `member_address`, `member_mail_address`, `member_email`, `postal_code`, `inst_name`, `is_new`, `member_image`, `pin`, `member_phone`, `member_fax`, `member_since_date`, `register_date`, `expire_date`, `member_notes`, `is_pending`, `mpasswd`, `last_login`, `last_login_ip`, `input_date`, `last_update`, `kode_ins`, `username`) VALUES
('22533657', 'Afigo Azus Zakkyfriza', 1, '1000-10-10', 2, 'Dusun Klagen RT 18 RW 03', NULL, NULL, '63173', 'Prodi Teknik Informatika', NULL, 'member_1738639330.jpg', NULL, '083831700576', NULL, '2022-09-29', '2022-09-29', '2026-11-07', NULL, 0, 'quWXTKZmrw21OLFIcUtbCzG9', '2025-02-04 10:22:10', '31.31.31.181', '2022-09-29', '2025-02-04', '53', '22533657'),
('22533655', 'In\\\'am Vaviansyah H', 1, '1000-10-10', 2, 'DESA GEMAHARJO, KABUPATEN PACITAN', '', NULL, '63416', 'Prodi Teknik Informatika', NULL, 'member_1670823922.jpg', '', '085641279879', '', '2022-09-29', '2022-09-29', '2026-11-07', '', 0, '2ltUjcxGCOP4uLHs85ZSTAzg', '2022-12-12 12:45:22', '172.168.3.29', '2022-09-29', '2022-12-12', '53', '22533655'),
('22533648', 'Titan Apriliyan Nadine Ananta', 1, '1000-10-10', 2, 'Jalan Pulung-Pudak, RT 003, RW 001, Dusun Tunjungan Kulon', NULL, NULL, '63481', 'Prodi Teknik Informatika', NULL, 'member_1737689149.jpg', NULL, '083848227047', NULL, '2022-09-29', '2022-09-29', '2026-11-07', NULL, 0, 'Rwavmk4yUcCMVAEGsrxdp7Oz', '2025-01-24 10:25:49', '31.31.31.5', '2022-09-29', '2025-01-24', '53', '22533648'),
('22533635', 'Bella Priska Putri Aprillia', 0, '1000-10-10', 2, 'RT. 04/ RW. 03', NULL, NULL, '63372', 'Prodi Teknik Informatika', NULL, 'member_1738639263.jpg', NULL, '0882009364567', NULL, '2022-09-29', '2022-09-29', '2026-11-07', NULL, 0, 'zlRSqUvHtGjDEbh67TnmJi9I', '2025-02-04 10:21:03', '31.31.31.181', '2022-09-29', '2025-02-04', '53', '22533635'),
('22533658', 'Yahya Nour Fauzan', 1, '1000-10-10', 2, 'JL EANG SINGO GATI RT 04 RW 01 DUKUH JETIS DESA NGARIBOYO KECAMATAN NGARIBOYO KABUPATEN MAGETAN', NULL, NULL, '63351', 'Prodi Teknik Informatika', NULL, 'member_1737508835.jpg', NULL, '081235597421', NULL, '2022-09-29', '2022-09-29', '2026-11-07', NULL, 0, 'MuzocsOqnmv3jSJeUlyXVdp4', '2025-01-22 08:20:35', '31.31.31.5', '2022-09-29', '2025-01-22', '53', '22533658'),
('22533639', 'Helvy Aurilia', 0, '1000-10-10', 2, 'JALAN. KRESNO RT/002 RW/002 KRAJAN TAJUG SIMAN PONOROGO', NULL, NULL, '63471', 'Prodi Teknik Informatika', NULL, 'member_1749619888.jpg', NULL, '0895706495959', NULL, '2022-09-29', '2022-09-29', '2026-11-07', NULL, 0, 'BIkvWc1SYtw5hqyAs2me9PgE', '2025-06-11 12:31:28', '31.31.31.217', '2022-09-29', '2025-06-11', '53', '22533639'),
('22533644', 'Cindy Alya Putri', 0, '1000-10-10', 2, 'RT 03 RW 17 DUSUN BURAT BANYU', NULL, NULL, '63584', 'Prodi Teknik Informatika', NULL, 'member_1746584566.jpg', NULL, '085293634748', NULL, '2022-09-29', '2022-09-29', '2026-11-07', NULL, 0, 'KHCtsRpOx28kBVT5iYrQg3Al', '2025-05-07 02:22:46', '31.31.31.151', '2022-09-29', '2025-05-07', '53', '22533644'),
('22533636', 'Dwi Rahiatul Sela', 0, '1000-10-10', 2, 'DUKUH KRAJAN RT 03 RW 01', NULL, NULL, '63455', 'Prodi Teknik Informatika', NULL, 'member_1737685363.jpg', NULL, '081359899472', NULL, '2022-09-29', '2022-09-29', '2026-11-07', NULL, 0, 'juvIX9bPndiw6rAxWCNJgyUe', '2025-01-24 09:22:43', '31.31.31.5', '2022-09-29', '2025-01-24', '53', '22533636'),
('22533645', 'Lugas Hermanto ', 1, '1000-10-10', 2, 'DUKUH KRAJAN RT 2 RW 1 SEDARAT ', NULL, NULL, '63461', 'Prodi Teknik Informatika', NULL, 'member_1747287217.jpg', NULL, '082337681654', NULL, '2022-09-29', '2022-09-29', '2026-11-07', NULL, 0, 'Oc9IzodB2iPMrlARj8khXnQZ', '2025-05-15 05:33:37', '31.31.31.151', '2022-09-29', '2025-05-15', '53', '22533645'),
('22533630', 'Imam Galih Prayitno', 1, '1000-10-10', 2, 'GESING RT03 RW02 KISMANTORO', '', NULL, '57696', 'Prodi Teknik Informatika', NULL, 'member_1738639311.png', '', '081225378664', '', '2022-09-29', '2022-09-29', '2026-11-07', '', 0, 'PyjaTq20OgzrLmXu1icRfk4M', '2025-02-04 10:21:51', '31.31.31.181', '2022-09-29', '2025-02-04', '53', '22533630'),
('22533631', 'Nila Mahardika Tiara Sari', 0, '1000-10-10', 2, 'JALAN SULAWESI NO. 79', NULL, NULL, '63413', 'Prodi Teknik Informatika', NULL, 'member_1727923835.jpg', NULL, '085847302604', NULL, '2022-09-29', '2022-09-29', '2026-11-07', NULL, 0, 'CArsVY5NmZS4x07pqwQRB968', '2024-10-03 09:50:35', '31.31.31.82', '2022-09-29', '2024-10-03', '53', '22533631'),
('22533641', 'Angel Endrika Faiza Nurfadia', 0, '1000-10-10', 2, 'JL. RAYA SAMPUNG RT 01 RW 02 DUKUH SEJERUK', NULL, NULL, '63451', 'Prodi Teknik Informatika', NULL, 'member_1733116944.jpg', NULL, '087761647186', NULL, '2022-09-29', '2022-09-29', '2026-11-07', NULL, 0, 'eIMorDgENcbA0Ujvqn6yfCR9', '2024-12-02 12:22:24', '31.31.31.112', '2022-09-29', '2024-12-02', '53', '22533641'),
('22533651', 'Nerissa Nikmatul Qoiriyah', 0, '1000-10-10', 2, 'JL. ABIMANYU NO 28 RT.02 RW.02', NULL, NULL, '64371', 'Prodi Teknik Informatika', NULL, 'member_1736222229.jpg', NULL, '081398318229', NULL, '2022-09-29', '2022-09-29', '2026-11-07', NULL, 0, 'FPAvRr41Y8xno5mhEbSWd9ki', '2025-01-07 10:57:09', '31.31.31.49', '2022-09-29', '2025-01-07', '53', '22533651'),
('22533642', 'Annisaa Irsalina Razita', 0, '1000-10-10', 2, 'JL. MT. HARYONO, NO 15, RT. 03, RW.02', NULL, NULL, '63413', 'Prodi Teknik Informatika', NULL, 'member_1731901661.jpg', NULL, '082334299308', NULL, '2022-09-29', '2022-09-29', '2026-11-07', NULL, 0, 'C8NBhiauTpZKzGEHA3FgqRUP', '2024-11-18 10:47:41', '31.31.31.154', '2022-09-29', '2024-11-18', '53', '22533642'),
('22533646', 'Zulfiqli Kurniawan', 1, '1000-10-10', 2, 'RT.002 RW.003 Dukuh Bakayen', NULL, NULL, '63492', 'Prodi Teknik Informatika', NULL, 'member_1745564147.jpg', NULL, '085336261252', NULL, '2022-09-29', '2022-09-29', '2026-11-07', NULL, 0, 'oYSq1JTDr8utUp05iXVjdkz9', '2025-04-25 13:55:47', '31.31.31.151', '2022-09-29', '2025-04-25', '53', '22533646'),
('22533653', 'M. Ardifa Rizqi Ramadhan', 1, '1000-10-10', 2, 'JL. PARIANOM B 04/20, RT.28 RW.09', NULL, NULL, '63124', 'Prodi Teknik Informatika', NULL, 'member_1736739473.jpg', NULL, '087803077007', NULL, '2022-09-29', '2022-09-29', '2026-11-07', NULL, 0, 'aTFnUoiufeXbrxMI0WH7Qm1N', '2025-01-13 10:37:53', '31.31.31.73', '2022-09-29', '2025-01-13', '53', '22533653'),
('22533643', 'Jalu Sena Purwa Andhika ', 1, '1000-10-10', 2, 'JL. KRESNA , RT 03,RW 02,DKH.KRAJAN', NULL, NULL, '63474', 'Prodi Teknik Informatika', NULL, 'member_1747357664.jpg', NULL, '082335331121', NULL, '2022-09-29', '2022-09-29', '2026-11-07', NULL, 0, 'Kuqd2UpgokObCXj3ceSW1sVt', '2025-05-16 01:07:44', '31.31.31.151', '2022-09-29', '2025-05-16', '53', '22533643'),
('22533647', 'Kharisma Wahyu Wibowo', 0, '1000-10-10', 2, 'RT 02 RW 03 DUKUH KALISOBO', NULL, NULL, '63475', 'Prodi Teknik Informatika', NULL, 'member_1742364853.jpg', NULL, '082378316682', NULL, '2022-09-30', '2022-09-30', '2026-11-08', NULL, 0, 'jnVEoST3ZBgURmKGAhCvtpFN', '2025-03-19 13:14:13', '31.31.31.168', '2022-09-30', '2025-03-19', '53', '22533647'),
('22533637', 'Aprilia Fiajar Rina', 0, '1000-10-10', 2, 'JL. KUMBOKARNO 1/12', NULL, NULL, '63419', 'Prodi Teknik Informatika', NULL, 'member_1749619788.jpg', NULL, '081216667162', NULL, '2022-09-30', '2022-09-30', '2026-11-08', NULL, 0, 'OLYb01lK8WzjNQnC7AeiEPsm', '2025-06-11 12:29:48', '31.31.31.217', '2022-09-30', '2025-06-11', '53', '22533637'),
('22533632', 'Fernanda Aziz Adewana', 1, '1000-10-10', 2, 'DUKUH NGIMPUT RT 15 RW 02', NULL, NULL, '63491', 'Prodi Teknik Informatika', NULL, 'member_1670822529.jpg', NULL, '081336530506', NULL, '2022-09-30', '2022-09-30', '2026-11-08', NULL, 0, 'KsMpcY76RGIhLv03TOZX2ey8', '2022-12-12 12:22:09', '172.168.3.29', '2022-09-30', '2022-12-12', '53', '22533632'),
('22533638', 'Adib Adzfarul Fuadi', 1, '1000-10-10', 2, 'JL JANOKO RT 02 RW 01 DUKUH NGAGEL', NULL, NULL, '69493', 'Prodi Teknik Informatika', NULL, 'member_1664949638.jpg', NULL, '081556820027', NULL, '2022-10-05', '2022-10-05', '2026-11-13', NULL, 0, '5MzNf2mJTQdYFS0jswXeBAUH', '2022-10-05 13:00:38', '172.168.4.189', '2022-10-05', '2022-10-05', '53', '22533638')
ON DUPLICATE KEY UPDATE
    member_name = VALUES(member_name),
    inst_name = VALUES(inst_name);

