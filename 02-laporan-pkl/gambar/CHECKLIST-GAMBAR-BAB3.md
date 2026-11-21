# Checklist Tangkapan Layar & Dokumentasi Visual Bab III

Panduan resmi penamaan berkas dan penempatan dokumentasi tangkapan layar (*screenshots*) untuk melengkapi **Bab III (`02-laporan-pkl/chapters/bab3-pelaksanaan-proyek.md`)**.

> **Catatan Teknis Pengambilan Gambar:**
> - Gunakan format **PNG** (`.png`) atau **JPG** (`.jpg`) resolusi tinggi agar teks antarmuka dan terminal tetap tajam saat dicetak pada kertas A4.
> - Disarankan menggunakan rasio layar *desktop* standar (**16:9** atau **16:10**, lebar minimal `1280px`–`1920px`, zoom browser `100%`).
> - Pastikan data sensitif (seperti *Bearer Token* asli, kata sandi, atau URL RTMP mentah) disamarkan sebelum disimpan.

---

## Tabel Checklist Gambar Bab III (Terintegrasi)

| No | Nomor Gambar Final | Folder & Nama File | Objek / Halaman yang Difoto | Penempatan Sub-bab | Caption Final pada Bab III |
| :---: | :---: | :--- | :--- | :--- | :--- |
| 1 | **Gambar 3.1** | `ui-ux/01-figma-design-system-prototype.png` | Kanvas pustaka komponen (*Design System*: palet warna JTV, tipografi, komponen UI) dan alur koneksi prototipe interaktif modul *Data Center Operations* di Figma. | **III.2.1** Metodologi Pengembangan dan Arsitektur Perangkat Lunak | Dokumentasi *Design System* dan Alur Prototipe Interaktif Modul *Data Center Operations* pada Figma |
| 2 | **Gambar 3.3** | `klaster-1/01-site-room-detail.png` | Halaman `SiteDetailPage` (*SiteInfoCard* dengan peta *Google Maps* & panel *DependentsCard*). | **III.2.3** Klaster 1: Hirarki Fasilitas Fisik dan Visualisasi Elevasi Rak 42U | Antarmuka Detail Fasilitas Gedung (*SiteDetailPage*) Lengkap dengan Peta Lokasi dan Ringkasan Kapasitas |
| 3 | **Gambar 3.4** | `klaster-1/02-rack-detail.png` | Halaman `RackDetailPage` yang menampilkan bar kapasitas 42U, daya listrik 5000 W, dan peringatan *delete guard* dependensi rak. | **III.2.3** Klaster 1: Hirarki Fasilitas Fisik dan Visualisasi Elevasi Rak 42U | Antarmuka Detail Kapasitas Rak (*RackDetailPage*) dengan Indikator Daya 5000 W dan Peringatan *Delete Guard* Dependensi |
| 4 | **Gambar 3.5** | `klaster-1/02-rack-visual-42u.png` | Modal komponen interaktif `RackVisualPicker` (*Visual 42U Elevation Grid* beserta indikator kode warna status slot dan identitas penyewa). | **III.2.3** Klaster 1: Hirarki Fasilitas Fisik dan Visualisasi Elevasi Rak 42U | Implementasi Komponen *Visual 42U Elevation Grid* (*RackVisualPicker*) pada *Rack Manager* |
| 5 | **Gambar 3.7** | `klaster-2/01-network-port-modal.png` | Halaman `NetworkPortListPage` beserta modal `DevicePortFormModal` yang menampilkan lencana dan validasi *MAC Address* serta *IP Address*. | **III.2.3** Klaster 2: Konektivitas Jaringan dan Pengkabelan | Antarmuka Master Port Jaringan (*NetworkPortListPage*) dan Modal Pendaftaran Port dengan Validasi *MAC/IP Address* |
| 6 | **Gambar 3.8** | `klaster-2/02-cross-connect-ipam.png` | Halaman `CrossConnectListPage` (inventaris jalur kabel *Cat5e* dan *Multi-Mode Fiber* lintas rak dan port *OTB*). | **III.2.3** Klaster 2: Konektivitas Jaringan dan Pengkabelan | Antarmuka Inventaris Jalur Kabel Interkoneksi (*CrossConnectListPage*) Lintas Rak dan Panel *OTB* |
| 7 | **Gambar 3.10** | `klaster-3/01-dashboard-telemetri.png` | Halaman `RackMonitoringDashboardPage` (*Dashboard Monitoring Seluruh Rak* dengan evaluasi ambang batas *dual-bounds* ASHRAE TC 9.9). | **III.2.3** Klaster 3: Dasbor Operasional NOC, Telemetri Termal *Dual-Bounds*, dan Pengawasan CCTV | Dasbor Pemantauan Telemetri Termal Seluruh Rak dengan Evaluasi Ambang Batas Ganda Standar ASHRAE TC 9.9 |
| 8 | **Gambar 3.11** | `klaster-3/02-cctv-monitoring-list.png` | Halaman `CctvListPage` yang menampilkan kartu status kamera `ONLINE`, metadata `HLS` & `H.264 (AVC)`, serta pemutaran simultan 3 kamera. | **III.2.3** Klaster 3: Dasbor Operasional NOC, Telemetri Termal *Dual-Bounds*, dan Pengawasan CCTV | Antarmuka Kisi Pengawasan Kamera CCTV (*CctvListPage*) dengan Pemutaran Siaran Langsung *HLS* Simultan |
| 9 | **Gambar 3.12** | `klaster-3/03-cctv-hls-modal-simulation.png` | Modal pemutar `HlsPlayer` aktif saat simulasi *live stream* RTMP/HLS lokal (*Larix Broadcaster* via *MediaMTX*) menampilkan *Masked Stream URL* dan metadata resolusi video. | **III.2.3** Klaster 3: Dasbor Operasional NOC, Telemetri Termal *Dual-Bounds*, dan Pengawasan CCTV | Modal Pemutar Siaran Langsung *HLS* (*HlsPlayer*) dengan Verifikasi *Masked Stream URL* dan Metadata Video |
| 10 | **Gambar 3.13** | `klaster-3/04-cctv-simulasi-obs-mediamtx.jpg` | Dokumentasi fisik pengujian transmisi siaran langsung *RTMP/HLS* lintas perangkat menggunakan *OBS Studio* dan peladen *MediaMTX*. | **III.2.3** Klaster 3: Dasbor Operasional NOC, Telemetri Termal *Dual-Bounds*, dan Pengawasan CCTV | Dokumentasi Pengujian Fisik Transmisi Siaran Langsung *RTMP/HLS* Menggunakan *OBS Studio* dan Peladen *MediaMTX* |
| 11 | **Gambar 3.15** | `klaster-4/01-work-order-ticket.png` | Halaman `Perintah Kerja` (*Work Orders*) dengan pelacakan daftar periksa instalasi kontrak *Sales Order*. | **III.2.3** Klaster 4: Operasional Harian, Penagihan Utilisasi, dan Tata Naskah Surat DC | Antarmuka Manajemen Perintah Kerja (*Work Orders*) dan Pelacakan Progres Daftar Periksa Instalasi |
| 12 | **Gambar 3.16** | `klaster-4/02-usage-surat-dc.png` | Halaman `UsageListPage` (*Usage Records & Billing*) untuk agregasi pemakaian bulanan dan penagihan jam kerja *Remote Hands* ke modul *Finance*. | **III.2.3** Klaster 4: Operasional Harian, Penagihan Utilisasi, dan Tata Naskah Surat DC | Antarmuka Pencatatan Pemakaian dan Penagihan Operasional (*Usage Records & Billing*) menuju Modul *Finance* |
| 13 | **Gambar 3.18** | `klaster-5/01-visitor-pass-ticket.png` | Modal kartu *e-badge* `VisitorPassTicket` beserta *SOP Keselamatan Fasilitas Data Center* dan tautan publik. | **III.2.3** Klaster 5: Keamanan Akses Fisik dan Kepatuhan ISO/IEC 27001 | Antarmuka Kartu *E-Badge* Digital Izin Kunjungan (*Visitor Pass*) dan Daftar SOP Keselamatan Fasilitas |
| 14 | **Gambar 3.19** | `klaster-5/02-scanner-guard-pos.png` | Halaman `VisitorPassScannerPage` (*Scanner Pos Jaga*) berbasis kamera peramban, masukan *scanner* USB, *live headcount*, dan SOP verifikasi pos jaga. | **III.2.3** Klaster 5: Keamanan Akses Fisik dan Kepatuhan ISO/IEC 27001 | Antarmuka Stasiun Pemindai Pos Jaga (*Scanner Guard*) Berbasis Kamera Peramban, Masukan *Scanner* USB, dan SOP Verifikasi |
| 15 | **Gambar 3.20** | `pengujian-api/01-postman-happy-path-200.png` | Tangkapan layar Postman menunjukkan permintaan dan respons sukses `200 OK` pada *endpoint* `GET /v1/data-center-ops/dashboard/details`. | **III.3.1** Hasil Implementasi dan Pengujian Sistem | Bukti Pengujian API Postman Skenario Sukses (*HTTP 200 OK*) pada *Endpoint* Detail Dasbor Operasional |
| 16 | **Gambar 3.21** | `pengujian-api/02-postman-validation-422.png` | Tangkapan layar Postman menunjukkan respons validasi penolakan `422 Unprocessable Entity` pada *endpoint* `POST /v1/data-center-ops/racks`. | **III.3.1** Hasil Implementasi dan Pengujian Sistem | Bukti Pengujian Validasi Masukan (*HTTP 422 Unprocessable Entity*) pada *Endpoint* Pendaftaran Lemari Rak |
| 17 | **Gambar 3.22** | `pengujian-api/03-postman-security-409.png` | Tangkapan layar Postman menunjukkan respons proteksi `409 Conflict` (*allocation guard*) pada `DELETE /v1/data-center-ops/ip-subnets/2`. | **III.3.1** Hasil Implementasi dan Pengujian Sistem | Bukti Pengujian Proteksi *Allocation Guard* (*HTTP 409 Conflict*) terhadap Penghapusan Subnet *IPAM* Aktif |
| 18 | **Gambar 3.23** | `pengujian-api/04-phpunit-automated-tests.png` | Tangkapan layar terminal hasil eksekusi `php artisan test` untuk *suite* pengujian fitur otomatis `DataCenterOps` (*PASS*). | **III.3.1** Hasil Implementasi dan Pengujian Sistem | Hasil Eksekusi Pengujian Fitur Otomatis (*Automated Feature Tests*) Laravel pada Terminal *PowerShell* |

*(Catatan: Gambar 3.2, 3.6, 3.9, 3.14, dan 3.17 merupakan diagram arsitektur alur data fullstack Klaster 1 s.d. Klaster 5 pada folder root `gambar/`).*

---

## Ringkasan Status Pengumpulan & Integrasi

- [x] `ui-ux/01-figma-design-system-prototype.png` (**Gambar 3.1**)
- [x] `klaster-1/01-site-room-detail.png` (**Gambar 3.3**)
- [x] `klaster-1/02-rack-detail.png` (**Gambar 3.4**)
- [x] `klaster-1/02-rack-visual-42u.png` (**Gambar 3.5**)
- [x] `klaster-2/01-network-port-modal.png` (**Gambar 3.7**)
- [x] `klaster-2/02-cross-connect-ipam.png` (**Gambar 3.8**)
- [x] `klaster-3/01-dashboard-telemetri.png` (**Gambar 3.10**)
- [x] `klaster-3/02-cctv-monitoring-list.png` (**Gambar 3.11**)
- [x] `klaster-3/03-cctv-hls-modal-simulation.png` (**Gambar 3.12**)
- [x] `klaster-3/04-cctv-simulasi-obs-mediamtx.jpg` (**Gambar 3.13**)
- [x] `klaster-4/01-work-order-ticket.png` (**Gambar 3.15**)
- [x] `klaster-4/02-usage-surat-dc.png` (**Gambar 3.16**)
- [x] `klaster-5/01-visitor-pass-ticket.png` (**Gambar 3.18**)
- [x] `klaster-5/02-scanner-guard-pos.png` (**Gambar 3.19**)
- [x] `pengujian-api/01-postman-happy-path-200.png` (**Gambar 3.20**)
- [x] `pengujian-api/02-postman-validation-422.png` (**Gambar 3.21**)
- [x] `pengujian-api/03-postman-security-409.png` (**Gambar 3.22**)
- [x] `pengujian-api/04-phpunit-automated-tests.png` (**Gambar 3.23**)
