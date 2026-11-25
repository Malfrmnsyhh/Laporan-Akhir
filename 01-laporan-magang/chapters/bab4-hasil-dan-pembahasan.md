# HASIL DAN PEMBAHASAN

## Gambaran Umum Proyek

[KERANGKA BAB 4.1: Paparkan arsitektur makro ekosistem *MSDC Enterprise ERP* yang dibangun secara kolaboratif, pembagian tanggung jawab antar-tim modul, serta posisi modul *Data Center Operations* sebagai tulang punggung operasional ruang peladen.]

## Analisis Masalah Sistem Eksisting

[KERANGKA BAB 4.2: Analisis permasalahan operasional sebelum implementasi sistem baru mencakup risiko konflik alokasi unit rak, ketiadaan riwayat pengkabelan terpusat, celah keamanan izin akses fisik statis, serta ketidakselarasan antarmuka antar-modul.]

## Perancangan UI/UX dan Design System Global ERP

[KERANGKA BAB 4.3: Bahas perancangan purwarupa *Figma*, sistem desain (*color palette*, tipografi, komponen standar, pola formulir dan tabel), serta arsitektur navigasi *2-Tier Sidebar* yang diadopsi lintas modul *MSDCFrontend*. Rujuk aset pada *gambar/02-uiux-figma/*.]

## Implementasi Modul Data Center Operations

### Klaster 1: Hirarki Fasilitas Fisik dan Visualisasi Rak 42U

[KERANGKA BAB 4.4.1: Implementasi *Site Manager*, *Room Manager*, dan *Rack Manager* beserta peta elevasi 42U interaktif, validasi tumpang tindih *U-position*, dan *delete guard*. Rujuk aset pada *gambar/03-dc-ops/*.]

### Klaster 2: Jaringan, Pengkabelan, dan Manajemen IP

[KERANGKA BAB 4.4.2: Implementasi *Device Inventory*, *Network Port*, *Cross-Connect*, *OTB Inventory*, dan *IPAM* beserta proteksi *allocation guard* (HTTP 409) pada subnet aktif.]

### Klaster 3: Dasbor NOC, Telemetri Termal, dan Pengawasan CCTV

[KERANGKA BAB 4.4.3: Implementasi dasbor agregasi *NOC*, pemantauan telemetri suhu dan kelembapan *dual-bounds* mengacu *ASHRAE TC 9.9*, serta integrasi pengawasan *CCTV* *HLS* dengan proteksi *Anti-SSRF*.]

### Klaster 4: Operasional Harian, Penagihan Utilisasi, dan Surat DC

[KERANGKA BAB 4.4.4: Implementasi *Ticket & Remote Hands*, *Work Order* berbasis daftar periksa, *Usage Records & Billing*, serta penerbitan dokumen *Surat Operasional DC* berverifikasi *QR code*.]

### Klaster 5: Keamanan Akses Fisik dan Proteksi Anti-Replay

[KERANGKA BAB 4.4.5: Implementasi manajemen *Visitor Pass*, *E-Badge* lokal *fail-closed*, stasiun *Scanner Pos Jaga*, serta enam lapis validasi *anti-replay* dalam transaksi penguncian pesimis (*lockForUpdate()*) mengacu *ISO/IEC 27001:2022*. Rujuk aset komposit uji *VP-202611-0004* pada *gambar/03-dc-ops/*.]

## Integrasi Lintas Modul Tim ERP

[KERANGKA BAB 4.5: Jelaskan secara jujur titik integrasi dan kontrak pertukaran data antara modul *Data Center Operations* dengan modul yang dikembangkan tim lain (*CorePlatform* untuk autentikasi *OAuth2*, *RBAC*, dan *multi-tenancy*; *CRM & Sales* untuk validasi pelanggan, kontrak aktif, dan *Sales Order*; *Finance & Accounting* untuk penagihan utilisasi dan *invoice*; serta *HR & Service Support* untuk data personel dan eskalasi layanan). Wajib mematuhi aturan batas klaim lintas tim pada *SPEC-PKL-KONVERSI.md*.]

## Pengujian dan Validasi Sistem

### Pengujian Fitur Otomatis

[KERANGKA BAB 4.6.1: Paparkan hasil eksekusi pengujian fitur otomatis *PHPUnit* mencakup jumlah *suite*, skenario uji, *assertions*, serta verifikasi keamanan konkurensi dan respons publik.]

### Pengujian Kontrak API

[KERANGKA BAB 4.6.2: Paparkan hasil verifikasi *endpoint* *RESTful API* pada *Postman* mencakup skenario sukses (*HTTP 200 OK*), validasi masukan (*HTTP 422 Unprocessable Entity*), dan proteksi konflik (*HTTP 409 Conflict*).]

### Validasi User Acceptance Testing (UAT) Staging

[KERANGKA BAB 4.6.3: Uraikan pelaksanaan validasi *UAT* pada lingkungan *staging* JTV Surabaya bersama pembimbing lapangan termasuk verifikasi alur *end-to-end* operasional dan proteksi *anti-replay*.]
