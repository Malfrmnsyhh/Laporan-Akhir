# PENDAHULUAN

## Gambaran Umum Modul Data Center Operations (ERP MSDC)

Modul *Data Center Operations* (*DataCenterOps*) merupakan subsistem manajemen operasional fasilitas pusat data (*Data Center Infrastructure Management* / DCIM) yang terintegrasi penuh di dalam ekosistem *Enterprise Resource Planning Micro Scale Data Center* (ERP MSDC) PT Jawa Pos Media Televisi (JTV). Perangkat lunak berbasis web ini dibangun untuk memindahkan pencatatan operasional ruang peladen dari formulir kertas dan lembar kerja terpisah menuju basis data relasional terpusat yang dapat diaudit secara *real-time*.

Ruang lingkup fungsional modul ini mencakup lima klaster operasional yang saling terhubung:

1. **Klaster 1 (Hirarki Fasilitas Fisik dan Rak 42U):** Mengelola katalog gedung pusat data (*Site*), ruangan fungsional (*Room*), lemari rak standar EIA-310 (*Rack* 42U), peta okupansi visual interaktif (*RackVisualPicker*), serta penguncian kapasitas alokasi slot pelanggan.
2. **Klaster 2 (Konektivitas Jaringan dan Pengkabelan):** Mengelola inventaris perangkat keras aktif (*Device Inventory*), antarmuka port fisik (*Network Port*) dengan validasi *MAC/IP address*, jalur kabel interkoneksi lintas rak (*Cross-Connect*), panel terminasi serat optik (*Optical Termination Box* / OTB), serta manajemen blok alamat jaringan (*IP Address Management* / IPAM).
3. **Klaster 3 (Dasbor NOC, Telemetri Termal, dan Pengawasan CCTV):** Menyediakan dasbor kendali *Network Operations Center* (NOC), evaluasi ambang batas ganda (*dual-bounds*) suhu serta kelembaban ruang peladen sesuai standar ASHRAE TC 9.9, deduplikasi alarm, dan pemantauan kamera CCTV lorong rak melalui siaran langsung *HTTP Live Streaming* (HLS).
4. **Klaster 4 (Operasional Harian, Penagihan Utilisasi, dan Tata Naskah Surat DC):** Mengelola tiket gangguan dan bantuan teknis lapangan (*Ticket & Remote Hands*) berbasis *Service Level Agreement* (SLA), daftar periksa perintah kerja (*Work Order*) dari pesanan komersial, agregasi penagihan pemakaian bulanan (*Usage Records & Billing*), serta persuratan operasional pusat data dengan tanda tangan digital dan kode QR verifikasi.
5. **Klaster 5 (Keamanan Akses Fisik dan Kepatuhan ISO/IEC 27001):** Menyelenggarakan perizinan kunjungan ruang peladen (*Visitor Pass*) melalui pendaftaran mandiri publik maupun penerbitan langsung di lokasi, persetujuan berjenjang operator, kartu *e-badge* digital, serta stasiun pemindai kode QR pos satpam (*Scanner Guard*) dengan proteksi pemakaian ulang (*anti-replay*) dan pencatatan jejak audit permanen.

Secara teknis, modul *Data Center Operations* dikembangkan dengan arsitektur terpisah (*decoupled fullstack*) berbasis *RESTful API*. Sisi peladen (*backend*) menggunakan PHP 8.2, kerangka kerja Laravel 11 Modular (*nwidart/laravel-modules*), autentikasi *OAuth2* melalui *Laravel Passport*, dan penyimpanan data relasional MySQL 8. Sementara itu, sisi antarmuka pengguna (*frontend*) dibangun sebagai *Single Page Application* (SPA) dengan React 18, TypeScript, Vite, Tailwind CSS, serta *TanStack Query v5* untuk sinkronisasi data asinkron yang responsif di peramban modern.

## Pengguna Sistem (Role dan Hak Akses)

Untuk menegakkan keamanan data dan pemisahan wewenang operasional (*segregation of duties*), setiap tindakan di dalam modul *Data Center Operations* diatur melalui pengendalian hak akses berbasis peran (*Role-Based Access Control* / RBAC) menggunakan *Spatie Permission* dan *ApiPermissionMiddleware*. Pembagian peran pengguna beserta batasan wewenangnya dirangkum pada Tabel 1.1.

| Peran Pengguna (*Role*) | Cakupan Menu & Wewenang Utama | Batasan Akses Khusus |
| :----------------------- | :-------------------------------------------- | :--------------------------------------- |
| **Super Admin / Manajer Operasional** | Akses penuh lintas seluruh lima klaster, persetujuan pelepasan atau pemindahan slot rak (*Four-Eyes Principle*), otorisasi penghapusan entitas induk, serta peninjauan laporan utilisasi dan persetujuan surat operasional DC. | Penghapusan *Site*, *Room*, *Rack*, atau subnet *IPAM* tetap diblokir otomatis oleh *delete guard* jika masih terikat kontrak atau perangkat aktif. |
| **Operator / Teknisi NOC** | Pengelolaan inventaris perangkat, port jaringan, *Cross-Connect*, *OTB*, *IPAM*, pemantauan telemetri termal dan CCTV, penanganan tiket *Remote Hands*, penyelesaian daftar periksa *Work Order*, serta verifikasi pendaftaran *Visitor Pass*. | Tidak dapat memaksa pelepasan kontrak atau menghapus data induk tanpa melewati alur persetujuan manajer; kredensial mentah kamera CCTV tersembunyi. |
| **Petugas Pos Jaga Satpam (*Security Guard*)** | Mengoperasikan stasiun *Scanner Pos Jaga* (*VisitorPassScannerPage*), memindai kode QR *e-badge* tamu saat kedatangan (*check-in*), memantau jumlah tamu aktif di gedung (*live headcount*), dan mencatat kepulangan (*check-out*). | Hanya dapat mengesahkan tiket berstatus *scheduled* yang sesuai dengan lokasi gedung pos jaga dan rentang waktu kunjungan aktif. |
| **Pengunjung Eksternal (*Public Visitor*)** | Mengakses tautan undangan publik (*PublicVisitorRegistrationPage*) untuk mengisi biodata, jadwal kunjungan, daftar peralatan, persetujuan K3 serta NDA, dan membuka kartu *e-badge* QR setelah disetujui operator. | Tidak memerlukan akun login ERP; akses dibatasi oleh token undangan *SHA-256* berbatas waktu dan respons API disaring ketat (*response whitelisting*). |

: Pembagian Peran Pengguna dan Hak Akses Modul Data Center Operations
