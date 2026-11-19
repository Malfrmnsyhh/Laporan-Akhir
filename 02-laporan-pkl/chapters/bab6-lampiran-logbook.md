# LAMPIRAN A. LOG ACTIVITY {-}

Pada bagian ini disajikan catatan logbook aktivitas mingguan selama pelaksanaan Praktik Lapangan Kerja (PLK) / Magang Mandiri di PT Jawa Pos Media Televisi (JTV) sesuai format resmi Program Studi Informatika UPN "Veteran" Jawa Timur:

| Minggu/Tgl | Kegiatan | Hasil | Validasi Dosen Pembimbing |
| :--- | :--- | :--- | :--- |
| **Minggu 1**<br/>01–05 Agt 2026 | Orientasi kerja, pengenalan tim divisi IT PT Jawa Pos Media Televisi, dan analisis kebutuhan awal sistem ERP MSDC. | Pemahaman arsitektur sistem eksisting dan pembagian tanggung jawab modul *Data Center Operations*. | Disetujui |
| **Minggu 2**<br/>08–12 Agt 2026 | Analisis kebutuhan fungsional dan non-fungsional fasilitas fisik data center (*Site*, *Room*, *Rack*). | Dokumen spesifikasi kebutuhan perangkat lunak (SKPL) awal Klaster 1. | Disetujui |
| **Minggu 3**<br/>15–19 Agt 2026 | Perancangan skema basis data MySQL untuk tabel `dc_site`, `dc_site_room`, `dc_rack`, dan `dc_rack_allocation`. | Skema *Entity Relationship Diagram* (ERD) dan berkas migrasi database Laravel. | Disetujui |
| **Minggu 4**<br/>22–26 Agt 2026 | Implementasi REST API CRUD fasilitas fisik dan pembuatan komponen antarmuka React TypeScript. | Endpoint `/api/v1/data-center-ops/sites` dan halaman `SiteListPage.tsx`. | Disetujui |
| **Minggu 5**<br/>29 Agt–02 Sep 2026 | Rancang bangun komponen interaktif *Visual 42U Elevation Grid* untuk pemetaan unit slot rak server. | Komponen `RackVisualPicker.tsx` dengan indikator warna status slot. | Disetujui |
| **Minggu 6**<br/>05–09 Sep 2026 | Penerapan mekanisme *pessimistic locking* (`lockForUpdate`) untuk mencegah alokasi ganda slot rak. | Layanan `RackService::allocate()` terproteksi terhadap kondisi persaingan data (*race condition*). | Disetujui |
| **Minggu 7**<br/>12–16 Sep 2026 | Analisis kebutuhan dan perancangan skema inventarisasi perangkat server fisik (*Device*) dan port jaringan (*Network Port*). | Skema tabel `dc_device` dan `dc_network_port` beserta aturan validasi keunikan bertingkat. | Disetujui |
| **Minggu 8**<br/>19–23 Sep 2026 | Implementasi fitur manajemen pengkabelan interkoneksi lintas rak (*Cross-Connect*) dan panel OTB. | Antarmuka `CrossConnectPage.tsx` dan endpoint pemetaan rute kabel. | Disetujui |
| **Minggu 9**<br/>26–30 Sep 2026 | Pengembangan subsistem manajemen alokasi alamat IP (*IPAM - IP Address Management*). | Fitur subnetting, alokasi IP publik/privat, dan validasi status reservasi. | Disetujui |
| **Minggu 10**<br/>03–07 Okt 2026 | Rancang bangun dashboard telemetri lingkungan dan pemantauan termal lemari rak sesuai standar ASHRAE TC 9.9. | Dashboard telemetri *real-time* dengan visualisasi grafik suhu dan kelembaban. | Disetujui |
| **Minggu 11**<br/>10–14 Okt 2026 | Integrasi umpan video kamera CCTV lorong rak data center dan pengaturan hak akses pengawasan. | Komponen `CctvViewerModal.tsx` dengan proteksi akses operator. | Disetujui |
| **Minggu 12**<br/>17–21 Okt 2026 | Implementasi modul operasional harian: penanganan tiket insiden (*Remote Hands*) dan perintah kerja (*Work Order*). | Alur kerja penerbitan work order dan pencatatan penggunaan utilitas (*Usage Billing*). | Disetujui |
| **Minggu 13**<br/>24–28 Okt 2026 | Pengembangan sistem surat operasional resmi data center dan mekanisme tanda tangan digital via kode QR. | Generator surat operasional dan endpoint verifikasi keabsahan publik. | Disetujui |
| **Minggu 14**<br/>31 Okt–04 Nov 2026 | Rancang bangun modul izin akses keamanan fisik (*Visitor Pass Management*) berstandar ISO/IEC 27001. | Form pendaftaran kunjungan dan generator *Dynamic One-Time QR Code*. | Disetujui |
| **Minggu 15**<br/>07–11 Nov 2026 | Pengembangan antarmuka pemindai kode QR pos satpam (*Scanner Guard*) menggunakan kamera web HTML5. | Antarmuka `VisitorScannerPage.tsx` dengan validasi izin masuk/keluar instan. | Disetujui |
| **Minggu 16**<br/>14–18 Nov 2026 | Pengujian integrasi modul secara *end-to-end* (Klaster 1 hingga Klaster 5) bersama modul `CorePlatform`. | Seluruh fitur terintegrasi sempurna dengan isolasi tenant `X-Organization-Id`. | Disetujui |
| **Minggu 17**<br/>21–25 Nov 2026 | Pelaksanaan pengujian penerimaan pengguna (*User Acceptance Testing* / UAT) bersama teknisi data center mitra JTV. | Dokumen berita acara UAT dan masukan perbaikan performa kueri. | Disetujui |
| **Minggu 18**<br/>28 Nov–02 Des 2026 | Optimalisasi performa sistem (*eager loading* Eloquent) dan penyusunan draf dokumentasi teknis. | Latensi respon endpoint berkurang > 40% dan draf dokumentasi selesai. | Disetujui |
| **Minggu 19**<br/>05–09 Des 2026 | Penyusunan draf Laporan Akhir PLK dan pemetaan materi konversi mata kuliah Merdeka Belajar. | Draf Bab I hingga Bab V selesai disusun. | Disetujui |
| **Minggu 20**<br/>12–16 Des 2026 | Finalisasi laporan, peninjauan bersama Dosen Pembimbing dan Mentor Industri, serta persiapan ujian seminar hasil. | Laporan akhir tervalidasi lengkap dan siap diseminarkan. | Disetujui |
