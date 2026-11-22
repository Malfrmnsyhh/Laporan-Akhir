# Checklist Tangkapan Layar Buku Panduan (Manual Book) Modul Data Center Operations

Panduan penamaan berkas dan pemetaan tangkapan layar (*screenshots*) untuk **Buku Panduan (Manual Book) HKI Program Komputer** di `04-manual-books/`.

> **Status Pengumpulan:** **100% Lengkap (15/15 Gambar UI + 1 Sampul Full-Bleed Terintegrasi)**.

---

## 1. Tangkapan Layar Akses Sistem & Dasbor Utama (Lengkap)

| No | Nomor Gambar Final | Folder & Nama File | Objek / Halaman yang Difoto | Penempatan Bab | Status |
| :---: | :---: | :--- | :--- | :--- | :---: |
| 1 | **Gambar 2.1** | `akses-sistem/01-login-page.png` | Halaman masuk (*Login Page*) ERP MSDC menampilkan panel *Selamat Datang*, bidang *Email*, *Password*, dan tombol *Masuk ke Portal*. | **Bab II (2.1)** | [x] Terpasang |
| 2 | **Gambar 2.2** | `akses-sistem/02-logout-menu.png` | Menu *dropdown* profil pengguna di sudut kanan atas (*Keluar (Logout)*) dan pintasan *Keluar* pada *2-Tier Sidebar*. | **Bab II (2.2)** | [x] Terpasang |
| 3 | **Gambar 3.1** | `dashboard/01-dashboard-utama.png` | Halaman penuh *Data Center Overview* (`/dc`) menampilkan *SystemStatusBanner*, 6 kartu ringkasan (*SITE, RACK, IP ADDRESS, DEVICE, TICKET, ALARM*), dan panel *Petugas Bertugas Hari Ini*. | **Bab III (3.1)** | [x] Terpasang |

---

## 2. Tangkapan Layar Antarmuka Klaster 1–5 (`gambar/workflow/` — Lengkap)

- [x] `workflow/01-dashboard-telemetri.png` (**Gambar 3.2**) — *Dashboard Monitoring Seluruh Rak* dengan evaluasi *dual-bounds* ASHRAE TC 9.9 (Bab III — 3.2 & Bab IV — 4.3).
- [x] `workflow/01-k1-site-room-detail.png` (**Gambar 4.1**) — *SiteDetailPage* lengkap dengan peta lokasi *Google Maps* dan ringkasan kapasitas (Bab IV — 4.1).
- [x] `workflow/02-k1-rack-detail.png` (**Gambar 4.2**) — *RackDetailPage* menampilkan kapasitas ruang 42U, daya listrik 5000 W, dan peringatan *delete guard* dependensi (Bab IV — 4.1).
- [x] `workflow/03-k1-rack-visual-42u.png` (**Gambar 4.3**) — Modal komponen *RackVisualPicker* (*Visual 42U Elevation Grid*) pada *Rack Manager* (Bab IV — 4.1).
- [x] `workflow/04-k2-network-port-modal.png` (**Gambar 4.4**) — *NetworkPortListPage* dan modal *DevicePortFormModal* dengan validasi *MAC/IP Address* (Bab IV — 4.2).
- [x] `workflow/05-k2-cross-connect-ipam.png` (**Gambar 4.5**) — *CrossConnectListPage* (inventaris jalur kabel *Cat5e* dan *Multi-Mode Fiber* lintas rak/OTB) (Bab IV — 4.2).
- [x] `workflow/07-k3-cctv-monitoring-list.png` (**Gambar 4.6**) — *CctvListPage* menampilkan pemutaran simultan tiga kamera CCTV berstatus *ONLINE* & *HLS* (Bab IV — 4.3).
- [x] `workflow/08-k3-cctv-hls-modal-simulation.png` (**Gambar 4.7**) — Modal pemutar *HlsPlayer* dengan *Masked Stream URL* dan metadata resolusi video (Bab IV — 4.3).
- [x] `workflow/09-k4-work-order-ticket.png` (**Gambar 4.8**) — Halaman *Perintah Kerja* (*Work Orders*) dan pelacakan progres daftar periksa instalasi (Bab IV — 4.4).
- [x] `workflow/10-k4-usage-surat-dc.png` (**Gambar 4.9**) — Halaman *Usage Records & Billing* untuk agregasi pemakaian dan penagihan *Remote Hands* (Bab IV — 4.4).
- [x] `workflow/11-k5-visitor-pass-ticket.png` (**Gambar 4.10**) — Modal kartu *e-badge* *Visitor Pass* beserta *SOP Keselamatan Fasilitas Data Center* (Bab IV — 4.5).
- [x] `workflow/12-k5-scanner-guard-pos.png` (**Gambar 4.11**) — Halaman *Scanner Pos Jaga* (*VisitorPassScannerPage*) dengan kamera QR, *input scanner* USB, dan *SOP Verifikasi Pos Jaga* (Bab IV — 4.5).
