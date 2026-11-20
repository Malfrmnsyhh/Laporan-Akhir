# RANCANG BANGUN MODUL DATA CENTER OPERATIONS PADA SISTEM ERP MSDC

## Persoalan Operasional Data Center

*(Panduan Penulisan Sub-Bab III.1)*:
Bagian ini membedah akar permasalahan riil yang dihadapi operasional data center komersial mitra:
1. **Risiko Alokasi Ganda (*Double-Booking / Over-selling*)**: Pelanggan yang berbeda secara tidak sengaja dijanjikan unit rak server yang sama akibat ketiadaan sistem pemetaan ruang spasial 42U yang terintegrasi langsung dengan kontrak penjualan CRM.
2. **Kekacauan Jalur Pengkabelan (*Cable Spaghetti & Port Collision*)**: Teknisi lapangan kesulitan melacak rute kabel interkoneksi (*cross-connect*) antara panel OTB, switch jaringan, dan server pelanggan, memicu risiko salah cabut kabel (*accidental downtime*).
3. **Ketidaksesuaian Standar Keamanan Fisik ISO/IEC 27001**: Pencatatan akses tamu eksternal yang masih mengandalkan buku tamu manual berbasis kertas, rentan pemalsuan identitas, dan tidak memiliki verifikasi izin akses berbasis kode QR sekali pakai (*One-Time QR Code*).
4. **Ketiadaan Visibilitas Telemetri Lingkungan Terpadu**: Pemantauan suhu lorong dingin/panas (*hot/cold aisle*) dan konsumsi daya listrik per rak tidak terpantau secara terpusat, berisiko melanggar batas rekomendasi termal ASHRAE TC 9.9 [@ashrae2021tc99].

## Proses Pelaksanaan dan Solusi Rekayasa

*(Panduan Penulisan Sub-Bab III.2)*:
Bagian ini menguraikan tahapan proses rekayasa sistem dan solusi teknis yang diimplementasikan:
1. **Metodologi Pengembangan**: Penerapan siklus kerja *Agile Development* (Sprint mingguan, peninjauan kode/code review, dan integrasi berkelanjutan).
2. **Kakas dan Teknologi (*Tech Stack*)**:
   - Sisi Klien: React 18, TypeScript, Tailwind CSS, TanStack Query (React Query v5), Axios, Lucide Icons, dan HTML5 QR Scanner.
   - Sisi Server: PHP 8.2, Laravel 11 Modular (*nwidart/laravel-modules*), Laravel Passport (OAuth2 Bearer Token), dan MySQL 8.
3. **Hambatan Teknis yang Dihadapi**:
   - Persaingan akses konkuren (*race condition*) pada saat dua teknisi melakukan alokasi slot unit rak atau menghasilkan nomor urut dokumen secara bersamaan.
   - Kompleksitas validasi relasi hierarkis spasial bertingkat (*Site -> Room -> Rack -> Unit Slot*).
   - Penolakan otentikasi API guard pada request lintas domain.
4. **Solusi Rekayasa yang Diterapkan**:
   - Penggunaan transaksi atomik basis data (*DB::transaction*) dan kunci pesimistik (*lockForUpdate()*) pada layanan alokasi rak dan *NumberSequence*.
   - Penerapan *trait* semesta *ScopesOrganization* untuk mengisolasi seluruh data *tenant* secara transparan di tingkat Eloquent ORM.
   - Penyediaan komponen visual antarmuka *RackVisualPicker* 42U interaktif yang langsung memetakan status slot hijau (*available*), biru (*reserved*), dan merah (*booked*).

## Pencapaian Hasil dan Evaluasi Mitra

*(Panduan Penulisan Sub-Bab III.3)*:
Bagian ini menyajikan luaran konkret yang berhasil diselesaikan dan penilaian dari mitra industri:
1. **Demonstrasi Luaran Sistem (Klaster 1 – 5)**:
   - Klaster 1: Manajemen Gedung, Ruangan, dan Lemari Rak Visual 42U.
   - Klaster 2: Inventaris Perangkat Server, Port Jaringan, Cross-Connect, OTB, dan IPAM.
   - Klaster 3: Dashboard Telemetri Rak, Monitoring Suhu ASHRAE TC 9.9, dan Integrasi CCTV.
   - Klaster 4: Helpdesk Tiket Insiden, Perintah Kerja (Work Order), dan Surat Operasional.
   - Klaster 5: Sistem Izin Kunjungan (Visitor Pass Management) dan Scanner Pos Satpam.
2. **Kesesuaian dengan Tujuan Awal (I.3)**: Bukti bahwa seluruh target yang dirumuskan pada Bab I telah tercapai secara fungsional.
3. **Uji Coba Lapangan & UAT**: Hasil pengujian fungsional sistem bersama staf operasional NOC data center di lingkungan server mitra (*staging server*).
4. **Evaluasi dan Umpan Balik Mitra**: Catatan evaluasi positif dari mentor industri PT Jawa Pos Media Televisi, serta rekomendasi fitur tambahan untuk rilis produksi selanjutnya.
