# ASSET-MANIFEST: Inventaris Aset Visual Laporan PKL Konversi (01-laporan-magang)

Dokumen ini memetakan seluruh aset gambar yang sudah tersedia (`READY`, telah disalin secara mandiri ke dalam `01-laporan-magang/gambar/`) serta daftar slot tangkapan layar yang masih perlu dikumpulkan (`PENDING`) sebelum penulisan penuh Bab I-V.

---

## 1. Ringkasan Status Aset per Subfolder

| Subfolder | Jumlah `READY` | Jumlah `PENDING` | Fokus Konten |
| :--- | :---: | :---: | :--- |
| `gambar/01-profil/` | 5 | 0 | Logo UPN, struktur organisasi JTV, LOA, dan MoA/PKS |
| `gambar/02-uiux-figma/` | 1 | 3 | Kanvas purwarupa Figma (*READY*) + ekspor bersih *Design System* & *2-Tier Sidebar* (*PENDING*) |
| `gambar/03-dc-ops/` | 21 | 0 | DFD, ERD, 5 diagram arsitektur klaster, tangkapan layar 5 klaster, serta komposit uji *anti-replay* `VP-202611-0004` |
| `gambar/04-integrasi-tim/` | 6 | 4 | 6 diagram arsitektur modul lintas tim (*READY*) + 4 tangkapan layar antarmuka integrasi tim lain (*PENDING*) |
| `gambar/05-pengujian/` | 4 | 1 | 3 bukti *Postman* (200/422/409) + hasil *PHPUnit* (*READY*) + foto/berita acara *UAT* (*PENDING*, opsional) |
| **Total** | **37** | **8** | **Seluruh 37 path aset `READY` terverifikasi ada di `01-laporan-magang/gambar/`** |

---

## 2. Tabel Inventaris Lengkap Aset

### A. Profil Institusi, Mitra JTV, & Lampiran (`gambar/01-profil/`)

| ID | Path File | Sumber / Pemilik | Target Sub-Bab | Deskripsi Visual | Status |
| :--- | :--- | :--- | :--- | :--- | :---: |
| `PROF-01` | `gambar/01-profil/logo-upn.png` | UPN "Veteran" Jawa Timur (`02-laporan-pkl/gambar/logo.png`) | Sampul | Logo resmi UPN "Veteran" Jawa Timur beresolusi tinggi untuk halaman sampul | `READY` |
| `PROF-02` | `gambar/01-profil/struktur-organisasi-jtv-direksi.png` | PT JTV / `diagrams/rendered/pkl/` | Bab 2 (Struktur Organisasi) | Bagan struktur organisasi jajaran direksi PT Jawa Pos Media Televisi (JTV) | `READY` |
| `PROF-03` | `gambar/01-profil/struktur-organisasi-jtv-teknik.png` | PT JTV / `diagrams/rendered/pkl/` | Bab 2 (Struktur Organisasi) | Bagan struktur Direktorat Teknik dan Unit TI beserta posisi tim magang MSDC ERP | `READY` |
| `PROF-04` | `gambar/01-profil/loa-jtv.png` | PT JTV (`02-laporan-pkl/gambar/berkas-bab4/LOA.png`) | Lampiran 2 | Pindaian resmi *Letter of Acceptance* (LOA) pelaksanaan magang di JTV | `READY` |
| `PROF-05` | `gambar/01-profil/moa-pks-jtv.png` | FIK UPN & PT JTV (`02-laporan-pkl/gambar/berkas-bab4/MoA.png`) | Bab 2 / Lampiran (Opsional) | Pindaian dokumen Perjanjian Kerja Sama (PKS No. 015/UN63.7/PKS/2024) | `READY` |

### B. Perancangan UI/UX Figma & Design System Global (`gambar/02-uiux-figma/`)

| ID | Path File | Sumber / Pemilik | Target Sub-Bab | Deskripsi Visual | Status |
| :--- | :--- | :--- | :--- | :--- | :---: |
| `FIG-01` | `gambar/02-uiux-figma/01-figma-prototype-canvas.png` | Penulis (`02-laporan-pkl/gambar/ui-ux/01-figma-design-system-prototype.png`) | Bab 4 (UI/UX & Design System) | Tampilan kanvas alur *prototyping* interaktif *Figma* modul *Data Center Operations* (catatan: tangkapan layar penuh peramban; disarankan dipotong tipis atau didampingi ekspor bersih) | `READY` |
| `FIG-02` | *(belum tersedia)* | Penulis (Figma MSDC ERP) | Bab 4 (UI/UX & Design System) | Ekspor bersih papan *Design System* (palet warna korporat, skala tipografi, dan token spasi) tanpa bilah tab peramban | `PENDING` |
| `FIG-03` | *(belum tersedia)* | Penulis (Figma MSDC ERP) | Bab 4 (UI/UX & Design System) | Ekspor bersih pustaka komponen standar (*buttons*, *badges*, *cards*, *modal*, dan *data table*) di *Figma* | `PENDING` |
| `FIG-04` | *(belum tersedia)* | Penulis (Figma / *MSDCFrontend*) | Bab 4 (UI/UX & Design System) | Perbandingan rancangan *Figma* dan implementasi antarmuka navigasi global *2-Tier Sidebar* lintas modul ERP | `PENDING` |

### C. Modul Data Center Operations 5 Klaster (`gambar/03-dc-ops/`)

| ID | Path File | Sumber / Pemilik | Target Sub-Bab | Deskripsi Visual | Status |
| :--- | :--- | :--- | :--- | :--- | :---: |
| `DC-00A` | `gambar/03-dc-ops/00-dfd-konteks-dc-ops.png` | Penulis (`02-laporan-pkl/gambar/berkas-bab4/`) | Bab 3 (Perancangan Sistem) | Diagram Alir Data (*DFD Konteks*) modul *Data Center Operations* beserta aktor dan modul eksternal | `READY` |
| `DC-00B` | `gambar/03-dc-ops/00-physical-erd-dc-ops.png` | Penulis (`02-laporan-pkl/gambar/berkas-bab4/`) | Bab 3 (Perancangan Sistem) | *Physical Entity-Relationship Diagram* (ERD) tabel-tabel inti *DataCenterOps* beserta relasi kunci asing | `READY` |
| `DC-K1A` | `gambar/03-dc-ops/k1-arsitektur-fasilitas-fisik.png` | Penulis (`diagrams/rendered/data-center-ops/`) | Bab 4 (Klaster 1) | Diagram arsitektur *fullstack* Klaster 1 (Hirarki Fasilitas Fisik: *Site*, *Room*, *Rack*) | `READY` |
| `DC-K1B` | `gambar/03-dc-ops/k1-site-room-detail.png` | Penulis (`02-laporan-pkl/gambar/klaster-1/`) | Bab 4 (Klaster 1) | Antarmuka halaman manajemen *Site* dan detail ruangan (*Room Manager*) | `READY` |
| `DC-K1C` | `gambar/03-dc-ops/k1-rack-detail.png` | Penulis (`02-laporan-pkl/gambar/klaster-1/`) | Bab 4 (Klaster 1) | Antarmuka rincian kapasitas daya, spesifikasi, dan status sewa lemari rak | `READY` |
| `DC-K1D` | `gambar/03-dc-ops/k1-rack-visual-42u.png` | Penulis (`02-laporan-pkl/gambar/klaster-1/`) | Bab 4 (Klaster 1) | Visualisasi elevasi rak 42U interaktif (*front/rear view*) beserta alokasi unit perangkat | `READY` |
| `DC-K2A` | `gambar/03-dc-ops/k2-arsitektur-jaringan-pengkabelan.png` | Penulis (`diagrams/rendered/data-center-ops/`) | Bab 4 (Klaster 2) | Diagram arsitektur *fullstack* Klaster 2 (*Device*, *Network Port*, *Cross-Connect*, *OTB*, *IPAM*) | `READY` |
| `DC-K2B` | `gambar/03-dc-ops/k2-network-port-modal.png` | Penulis (`02-laporan-pkl/gambar/klaster-2/`) | Bab 4 (Klaster 2) | Modal inventaris perangkat jaringan dan pemetaan *Network Port* | `READY` |
| `DC-K2C` | `gambar/03-dc-ops/k2-cross-connect-ipam.png` | Penulis (`02-laporan-pkl/gambar/klaster-2/`) | Bab 4 (Klaster 2) | Halaman pengelolaan tautan *Cross-Connect* serat optik dan alokasi subnet *IPAM* | `READY` |
| `DC-K3A` | `gambar/03-dc-ops/k3-arsitektur-telemetri.png` | Penulis (`diagrams/rendered/data-center-ops/`) | Bab 4 (Klaster 3) | Diagram arsitektur *fullstack* Klaster 3 (Dasbor NOC, Telemetri *ASHRAE TC 9.9*, CCTV *HLS*) | `READY` |
| `DC-K3B` | `gambar/03-dc-ops/k3-dashboard-telemetri.png` | Penulis (`02-laporan-pkl/gambar/klaster-3/`) | Bab 4 (Klaster 3) | Antarmuka dasbor operasional NOC dan grafik telemetri termal *dual-bounds* | `READY` |
| `DC-K3C` | `gambar/03-dc-ops/k3-cctv-monitoring-list.png` | Penulis (`02-laporan-pkl/gambar/klaster-3/`) | Bab 4 (Klaster 3) | Halaman daftar kamera pemantauan lorong dan rak beserta status konektivitas | `READY` |
| `DC-K3D` | `gambar/03-dc-ops/k3-cctv-hls-modal.png` | Penulis (`02-laporan-pkl/gambar/klaster-3/`) | Bab 4 (Klaster 3) | Modal pemutar siaran langsung *HLS* (*HlsPlayer*) dengan penyamaran URL *stream* | `READY` |
| `DC-K3E` | `gambar/03-dc-ops/k3-cctv-simulasi-obs-mediamtx.jpg` | Penulis (`02-laporan-pkl/gambar/klaster-3/`) | Bab 4 (Klaster 3) | Dokumentasi simulasi fisik transmisi *RTMP/HLS* menggunakan *OBS Studio* dan *MediaMTX* | `READY` |
| `DC-K4A` | `gambar/03-dc-ops/k4-arsitektur-operasional-dokumen.png` | Penulis (`diagrams/rendered/data-center-ops/`) | Bab 4 (Klaster 4) | Diagram arsitektur *fullstack* Klaster 4 (*Ticket*, *Work Order*, *Usage Billing*, *Surat DC*) | `READY` |
| `DC-K4B` | `gambar/03-dc-ops/k4-work-order-ticket.png` | Penulis (`02-laporan-pkl/gambar/klaster-4/`) | Bab 4 (Klaster 4) | Antarmuka manajemen *Work Order* dan pelacakan progres daftar periksa instalasi | `READY` |
| `DC-K4C` | `gambar/03-dc-ops/k4-usage-surat-dc.png` | Penulis (`02-laporan-pkl/gambar/klaster-4/`) | Bab 4 (Klaster 4) | Antarmuka *Usage Records & Billing* serta penerbitan dokumen *Surat Operasional DC* | `READY` |
| `DC-K5A` | `gambar/03-dc-ops/k5-arsitektur-keamanan-akses.png` | Penulis (`diagrams/rendered/data-center-ops/`) | Bab 4 (Klaster 5) | Diagram arsitektur *fullstack* Klaster 5 (Keamanan Akses Fisik & Kepatuhan *ISO/IEC 27001*) | `READY` |
| `DC-K5B` | `gambar/03-dc-ops/k5-flowchart-verifikasi-6-lapis.png` | Penulis (`05-artikel-jurnal/gambar/`) | Bab 4 (Klaster 5) | Diagram alur transaksi penguncian baris pesimis (*lockForUpdate()*) dan 6 lapis validasi *anti-replay* | `READY` |
| `DC-K5C` | `gambar/03-dc-ops/k5-ebadge-lifecycle-komposit.png` | Penulis (`05-artikel-jurnal/gambar/`) | Bab 4 (Klaster 5) | Komposit 2 panel kartu *E-Badge* tiket *VP-202611-0004*: (a) *TERJADWAL* aktif dan (b) *DI FASILITAS* (*fail-closed*) | `READY` |
| `DC-K5D` | `gambar/03-dc-ops/k5-scanner-antireplay-komposit.png` | Penulis (`05-artikel-jurnal/gambar/`) | Bab 4 (Klaster 5) | Komposit 3 panel stasiun pemindai pos jaga (*VP-202611-0004*): (a) penyamaran token, (b) *check-in* + *Live Headcount*, (c) penolakan *replay* HTTP 409 | `READY` |

### D. Integrasi Lintas Modul Tim ERP (`gambar/04-integrasi-tim/`)

> **Catatan Batas Klaim:** Seluruh aset pada kategori ini merepresentasikan arsitektur dan titik integrasi modul yang dikembangkan oleh tim kolaborator MSDC ERP (bukan klaim buatan satu orang).

| ID | Path File | Sumber / Pemilik | Target Sub-Bab | Deskripsi Visual | Status |
| :--- | :--- | :--- | :--- | :--- | :---: |
| `INT-ARC-01` | `gambar/04-integrasi-tim/arsitektur-core-platform.png` | Tim *CorePlatform* (`diagrams/rendered/core-platform/`) | Bab 4 (Integrasi Lintas Modul) | Diagram arsitektur modul *CorePlatform* (*OAuth2*, *RBAC*, *Multi-Tenancy*) sebagai penyedia autentikasi global | `READY` |
| `INT-ARC-02` | `gambar/04-integrasi-tim/arsitektur-crm-sales.png` | Tim *CRM & Sales* (`diagrams/rendered/crm-sales/`) | Bab 4 (Integrasi Lintas Modul) | Diagram arsitektur modul *CRM & Sales* sebagai sumber kontrak pelanggan dan *Sales Order* bagi *DC Ops* | `READY` |
| `INT-ARC-03` | `gambar/04-integrasi-tim/arsitektur-finance-accounting.png` | Tim *Finance & Accounting* (`diagrams/rendered/finance-accounting/`) | Bab 4 (Integrasi Lintas Modul) | Diagram arsitektur modul *Finance & Accounting* sebagai penerima agregasi tagihan *Usage Records* | `READY` |
| `INT-ARC-04` | `gambar/04-integrasi-tim/arsitektur-hr-service-support.png` | Tim *HR & Service Support* (`diagrams/rendered/hr-service-support/`) | Bab 4 (Integrasi Lintas Modul) | Diagram arsitektur modul *HR & Service Support* terkait data teknisi dan layanan dukungan internal | `READY` |
| `INT-ARC-05` | `gambar/04-integrasi-tim/arsitektur-procurement-inventory.png` | Tim *Procurement* (`diagrams/rendered/procurement-inventory/`) | Bab 4 (Integrasi Lintas Modul) | Diagram arsitektur modul *Procurement & Inventory* untuk rantai pasok aset perangkat keras | `READY` |
| `INT-ARC-06` | `gambar/04-integrasi-tim/arsitektur-integration-analytics.png` | Tim *Integration & Analytics* (`diagrams/rendered/integration-analytics/`) | Bab 4 (Integrasi Lintas Modul) | Diagram arsitektur modul *Integration & Analytics* sebagai agregator pelaporan lintas unit | `READY` |
| `INT-UI-01` | *(belum tersedia)* | Tim *CorePlatform* (Staging ERP) | Bab 4 (Integrasi Lintas Modul) | Tangkapan layar antarmuka *CorePlatform* (pengelolaan *Organization/Tenant* dan *Role Permissions*) | `PENDING` |
| `INT-UI-02` | *(belum tersedia)* | Tim *CRM & Sales* (Staging ERP) | Bab 4 (Integrasi Lintas Modul) | Tangkapan layar antarmuka *CRM & Sales* (daftar kontrak aktif pelanggan yang tertaut ke *DC Ops*) | `PENDING` |
| `INT-UI-03` | *(belum tersedia)* | Tim *Finance & Accounting* (Staging ERP) | Bab 4 (Integrasi Lintas Modul) | Tangkapan layar antarmuka *Finance* (penerbitan *invoice* hasil sinkronisasi pemakaian bulanan *DC Ops*) | `PENDING` |
| `INT-UI-04` | *(belum tersedia)* | Tim *HR & Service Support* (Staging ERP) | Bab 4 (Integrasi Lintas Modul) | Tangkapan layar antarmuka *HR & Service Support* (direktori personel/teknisi pelaksana tugas) | `PENDING` |

### E. Pengujian Otomatis, Kontrak API, & Validasi Staging (`gambar/05-pengujian/`)

| ID | Path File | Sumber / Pemilik | Target Sub-Bab | Deskripsi Visual | Status |
| :--- | :--- | :--- | :--- | :--- | :---: |
| `TEST-01` | `gambar/05-pengujian/01-postman-happy-path-200.png` | Penulis (`02-laporan-pkl/gambar/pengujian-api/`) | Bab 4 (Pengujian API) | Bukti pengujian *Postman* skenario sukses (*HTTP 200 OK*) pada *endpoint* detail dasbor operasional | `READY` |
| `TEST-02` | `gambar/05-pengujian/02-postman-validation-422.png` | Penulis (`02-laporan-pkl/gambar/pengujian-api/`) | Bab 4 (Pengujian API) | Bukti pengujian validasi masukan (*HTTP 422 Unprocessable Entity*) pada pendaftaran lemari rak | `READY` |
| `TEST-03` | `gambar/05-pengujian/03-postman-security-409.png` | Penulis (`02-laporan-pkl/gambar/pengujian-api/`) | Bab 4 (Pengujian API) | Bukti pengujian proteksi *allocation guard* (*HTTP 409 Conflict*) pada penghapusan subnet *IPAM* aktif | `READY` |
| `TEST-04` | `gambar/05-pengujian/04-phpunit-automated-tests.png` | Penulis (`02-laporan-pkl/gambar/pengujian-api/`) | Bab 4 (Pengujian Otomatis) | Tangkapan layar eksekusi terminal pengujian fitur otomatis *PHPUnit* Laravel (*PASS* 100%) | `READY` |
| `TEST-05` | *(belum tersedia)* | Penulis & Pembimbing Lapangan JTV | Bab 4 (Validasi UAT) | Foto dokumentasi atau pindaian catatan *User Acceptance Testing* (UAT) *staging* 19 November 2026 (opsional) | `PENDING` |
