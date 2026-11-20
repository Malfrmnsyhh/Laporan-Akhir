# PANDUAN RESMI STRUKTUR LAPORAN AKHIR PLK (KONVERSI MATA KULIAH)
## Program Studi Informatika — Fakultas Ilmu Komputer
## Universitas Pembangunan Nasional "Veteran" Jawa Timur
**Single Source of Truth (SSOT)**: Berdasarkan Dokumen Resmi `Template Laporan Akhir PLK Prodi v3.docx`

---

## 1. IDENTITAS DOKUMEN & PEDOMAN TATA LETAK

| Parameter | Ketentuan Resmi Prodi Informatika UPN "Veteran" Jatim |
| :--- | :--- |
| **Ukuran Kertas** | A4 ($210 \times 297\text{ mm}$), $80\text{ gram}$ |
| **Batas Margin** | **Atas (Top): 4 cm**, **Kiri (Left): 4 cm**, **Bawah (Bottom): 3 cm**, **Kanan (Right): 3 cm** |
| **Jenis Font** | **Times New Roman** |
| **Ukuran Font** | **12 pt** untuk teks narasi, **14 pt Bold** untuk judul bab, **10 pt** untuk tabel & keterangan gambar |
| **Spasi Baris** | **1.5 spasi** (*line spacing* $1.5$ / pada Typst `line_spacing: 0.75em`) |
| **Indentasi Paragraf** | **1.27 cm** (*first-line indent* standar 0.5 inci) |
| **Gaya Sitasi** | **IEEE Style** (penomoran numerik kurung siku terurut abjad berdasar nama pengarang, e.g. `[1]`) |
| **Tipografi Narasi & Larangan Backtick** | Seluruh teks narasi wajib menggunakan font utama **Times New Roman 12 pt**. **DILARANG KERAS** menggunakan tanda *inline backtick* (`` ` ``) di tengah paragraf narasi; seluruh nama modul, kelas, method, header HTTP, tabel database, file, maupun istilah asing wajib ditulis menggunakan font utama **Times New Roman 12 pt** dengan format **cetak miring (*italic*)**. |
| **Preset Engine** | `upn-plk` (`02-laporan-pkl/presets/upn-plk.yml`) |

---

## 2. SUSUNAN ANATOMI LAPORAN AKHIR PLK

Laporan akhir disusun dalam urutan hierarkis berikut tanpa mengubah urutan standar prodi:

```
[FRONT-MATTER]
1. Halaman Sampul (Cover Luar)
2. Lembar Pengesahan
3. Abstraksi (Bahasa Indonesia & Wajib 5 Kata Kunci)
4. Kata Pengantar
5. Daftar Isi
6. Daftar Tabel (jika > 1 tabel)
7. Daftar Gambar (jika > 1 gambar)

[MAIN-BODY (BATANG TUBUH)]
8. BAB I: PENDAHULUAN
9. BAB II: ORGANISASI ATAU LINGKUNGAN ORGANISASI MITRA PLK
10. BAB III: RANCANG BANGUN MODUL DATA CENTER OPERATIONS PADA SISTEM ERP MSDC (PELAKSANAAN PROYEK)
11. BAB IV: REKOGNISI KEGIATAN PLK DENGAN KONVERSI MATA KULIAH
12. BAB V: PENUTUP

[BACK-MATTER]
13. REFERENSI (DAFTAR PUSTAKA) -> Format IEEE [1], urut abjad nama pengarang, terletak SEBELUM lampiran
14. BAB VI: LAMPIRAN A. LOG ACTIVITY -> Tabel 4 Kolom
```

---

## 3. INSTRUKSI RINCI SETIAP BAB & SUB-BAB

### 3.1. Halaman Depan (*Front-Matter*)
1. **Halaman Sampul (Cover)**:
   - Teks: `LAPORAN AKHIR`
   - Program: `Magang Mandiri / Praktik Lapangan Kerja (PLK)`
   - Judul: `Rancang Bangun Modul Data Center Operations (Visitor Access Pass, Fasilitas Ruang Rak, dan Surveilans Fisik) pada Sistem ERP MSDC PT Jawa Pos Media Televisi` (disusun piramida terbalik).
   - Keterangan: *"Diajukan untuk memenuhi persyaratan kelulusan Program Magang Mandiri / Merdeka Belajar Magang Industri"*.
   - Identitas Mahasiswa: Nama Lengkap / Nomor Pokok Mahasiswa (NPM).
   - Logo Resmi: Logo UPN "Veteran" Jawa Timur resolusi tinggi.
   - Lembaga: `PROGRAM STUDI INFORMATIKA, FAKULTAS ILMU KOMPUTER, UNIVERSITAS PEMBANGUNAN NASIONAL “VETERAN” JAWA TIMUR, 2026`.
2. **Lembar Pengesahan**:
   - Memuat topik proyek magang di PT Jawa Pos Media Televisi (JTV), nama mahasiswa, NPM, tanggal pengesahan, nama Dosen Pembimbing beserta NIP.
3. **Abstraksi**:
   - Berisi ringkasan laporan PLK: gambaran proyek secara umum, profil singkat bidang usaha mitra PT Jawa Pos Media Televisi (JTV), misi proyek, tahapan pelaksanaan, pencapaian hasil, dan kesimpulan umum.
   - **Wajib 5 Kata Kunci**: Disertakan tepat di bawah abstrak (contoh: *Data Center Operations, ERP, Laravel Modular, React, Multi-Tenancy*).
4. **Kata Pengantar**:
   - Ucapan rasa syukur dan terima kasih kepada pihak terkait (Dosen Pembimbing, Koordinator Prodi, Pembimbing Lapangan/Mentor Mitra JTV, keluarga, dan rekan tim) dalam bahasa Indonesia formal baku.
5. **Daftar Isi, Daftar Gambar, dan Daftar Tabel**:
   - Masing-masing diletakkan pada halaman terpisah. Penomoran halaman front-matter menggunakan angka Romawi kecil (`i, ii, iii, iv, ...`).

---

### 3.2. Batang Tubuh Laporan (*Main Body*)

#### BAB I: PENDAHULUAN
* **I.1 Latar Belakang**:
  - Latar belakang pelaksanaan PLK di PT Jawa Pos Media Televisi (JTV) sebagai stasiun televisi regional terkemuka yang melakukan diversifikasi infrastruktur ke penyediaan layanan *Data Center* dan *Managed Services*.
  - Masalah operasional pengelolaan fasilitas fisik gedung, lemari rak 42U, jalur pengkabelan, dan audit keamanan fisik ISO 27001 yang melatarbelakangi perancangan modul *Data Center Operations* pada ekosistem ERP MSDC.
* **I.2 Lingkup**:
  - Batasan lingkup proyek yang dikembangkan: modul *Data Center Operations* yang mencakup subsistem fasilitas fisik (*Site, Room, Rack 42U*), manajemen konektivitas jaringan (*Device, Port, Cross-Connect*), telemetri lingkungan, operasional dokumen kerja, dan sistem izin akses pengunjung (*Visitor Access Pass*).
* **I.3 Tujuan**:
  - Tujuan teknis dan capaian hasil pelaksanaan magang bagi mahasiswa dan mitra industri (merancang arsitektur perangkat lunak modular, membangun REST API yang andal dengan proteksi konkurensi, dan mengimplementasikan antarmuka interaktif responsif).

#### BAB II: ORGANISASI ATAU LINGKUNGAN ORGANISASI MITRA PLK
* **II.1 Struktur Organisasi**:
  - Deskripsi struktur organisasi PT Jawa Pos Media Televisi (JTV) secara formal.
  - Diagram visual struktur organisasi di mana **unit/divisi tempat mahasiswa bertugas (Divisi IT / Tim Rekayasa Perangkat Lunak MSDC ERP) WAJIB dibedakan secara visual menggunakan arsiran (*shading*) atau garis putus-putus**.
* **II.2 Lingkup Pekerjaan**:
  - Uraian lingkup tanggung jawab divisi TI/Software Engineering di mitra dan keterkaitannya dengan proyek MSDC ERP.
* **II.3 Deskripsi Pekerjaan**:
  - Deskripsi runtut tahapan pekerjaan mahasiswa selama magang (analisis kebutuhan, perancangan basis data, implementasi backend modular, integrasi frontend SPA, pengujian sistem, dan penyusunan dokumentasi teknis).
* **II.4 Jadwal Kerja**:
  - Gambaran linimasa kegiatan magang selama 1 semester (Agustus – Desember 2026), yang merefleksikan catatan pada logbook kegiatan.

#### BAB III: RANCANG BANGUN MODUL DATA CENTER OPERATIONS PADA SISTEM ERP MSDC (PELAKSANAAN PROYEK)
* **III.1 Persoalan**:
  - Identifikasi persoalan nyata pengelolaan operasional data center: risiko alokasi ganda slot rak (*double booking*), inefisiensi pelacakan pengkabelan lintas rak (*cross-connect*), potensi pelanggaran regulasi akses fisik tanpa catatan jejak audit, serta kebutuhan visualisasi spasial 42U secara *real-time*.
* **III.2 Proses Pelaksanaan & Hambatan/Solusi**:
  - Metodologi pengembangan perangkat lunak (Agile/Scrum: Sprint planning, standup, review).
  - Tumpukan teknologi (*technology stack*): React 18, TypeScript, Tailwind CSS, TanStack Query pada sisi klien; Laravel 11 Modular (*nwidart/laravel-modules*), Laravel Passport, dan MySQL pada sisi server.
  - Kendala teknis (penanganan *race condition* penomoran dan alokasi rak, latensi kueri hierarkis spasial) beserta solusi rekayasanya (*pessimistic locking*, *eager loading optimization*, caching).
  - Hambatan koordinasi tim dan solusinya.
* **III.3 Pencapaian Hasil & Evaluasi Mitra**:
  - Demonstrasi luaran modul yang berhasil dibangun (Klaster 1 hingga Klaster 5).
  - Pelaksanaan uji coba di lingkungan server mitra JTV (*staging environment*), sesi pengujian pengguna (*User Acceptance Testing* / UAT), dan pelatihan staf operasional.
  - Evaluasi resmi serta umpan balik dari mentor industri mitra PT Jawa Pos Media Televisi.

#### BAB IV: REKOGNISI KEGIATAN PLK DENGAN KONVERSI MATA KULIAH
Bab ini menjadi inti pertanggungjawaban akademik konversi paket kurikulum Merdeka Belajar (MG220):
* **IV.1 Rekognisi Mata Kuliah Analisis Kebutuhan (IF261206)**:
  - Spesifikasi Kebutuhan Perangkat Lunak (SKPL) fungsional dan non-fungsional modul DC Ops.
  - Pemodelan Alur Data: *Data Flow Diagram* (DFD Level 0 / Diagram Konteks, DFD Level 1, DFD Level 2).
  - Pemodelan Pengguna: *Usecase Diagram*, skenario *usecase*, dan *User Flow Diagram* alur alokasi rak dan penerbitan izin pengunjung.
* **IV.2 Rekognisi Mata Kuliah Pemrograman Framework (IF261208)**:
  - Arsitektur sisi klien (Frontend): Pemanfaatan React SPA, TypeScript *type safety*, arsitektur komponen modular, *custom hooks* TanStack Query, dan *state management*.
  - Arsitektur sisi server (Backend): Pola arsitektur modular Laravel, pembagian lapisan *Controller*, *Domain Service*, *Form Request*, dan *Eloquent Model*.
  - Penerapan *trait* semesta *ScopesOrganization* untuk penegakan *multi-tenancy*.
* **IV.3 Rekognisi Mata Kuliah Pemrograman API (IF261217)**:
  - Perancangan RESTful API: Kontrak endpoint representatif, format respon standar JSON, penanganan kode status HTTP.
  - Mekanisme Keamanan API: Autentikasi OAuth2 *Bearer Token* via Passport guard *api*, otorisasi peran via *ApiPermissionMiddleware*, serta proteksi integrasi IoT sensor via *ApiKeyMiddleware* dengan validasi subnet CIDR IP.
  - Perancangan Basis Data & ERD: *Physical Data Model* (ERD MySQL) relasi tabel *dc_site*, *dc_site_room*, *dc_rack*, *dc_device*, *dc_network_port*, *dc_visitor_pass*, dsb.
* **IV.4 Rekognisi Mata Kuliah Praktik Kerja Lapangan (IF221129) / MBKM (IF221381)**:
  - Bukti pemenuhan capaian pembelajaran praktik industri di PT Jawa Pos Media Televisi.
  - Integrasi budaya kerja industri, kolaborasi tim, dan kesiapan berkas luaran untuk Seminar Hasil Merdeka Belajar I (IF221379).

#### BAB V: PENUTUP
* **V.1 Kesimpulan**:
  - Kesimpulan mengenai proses pelaksanaan program magang mandiri di mitra JTV (per poin).
  - Kesimpulan mengenai substansi teknis rekayasa perangkat lunak modul DC Ops yang dihasilkan (per poin).
* **V.2 Saran**:
  - Saran perbaikan proses pelaksanaan program magang bagi universitas dan mitra industri (per poin).
  - Saran pengembangan teknis sistem ke depan (misalnya integrasi otomatisasi protokol SNMP/Modbus untuk sensor daya dan integrasi sistem RFID turnstile) (per poin).

---

### 3.3. Halaman Belakang (*Back-Matter*)

#### REFERENSI (DAFTAR PUSTAKA)
* **Penempatan**: Terletak tepat setelah Bab V sebelum Lampiran.
* **Format**: Penomoran numerik IEEE terurut abjad nama pengarang pertama, contoh:
  `[1]  I. N. K. Wardana, J. W. Gardner dan S. A. Fahmy, “Optimising Deep Learning at the Edge for Accurate Hourly Air Quality Prediction,” Sensors, vol. 21, no. 4, p. 1064, 2021.`
* Seluruh sitasi yang ditulis di daftar pustaka wajib disitir di dalam batang tubuh (`[@citekey]`).

#### BAB VI: LAMPIRAN A. LOG ACTIVITY
* **Penempatan**: Bab penutup lampiran laporan.
* **Format Tabel**: Wajib menggunakan tabel 4 kolom resmi:
  | Minggu/Tgl | Kegiatan | Hasil | Validasi Dosen Pembimbing |
  | :--- | :--- | :--- | :--- |
  | Minggu 1 (01-05 Agt 2026) | Orientasi mitra PT Jawa Pos Media Televisi, analisis arsitektur ERP MSDC. | Pemahaman arsitektur sistem dan pembagian modul tim. | Disetujui |
  | ... | ... | ... | ... |

---

## 4. PEMETAAN RUJUKAN SUMBER DATA DARI BEDAH KLASTER

Untuk menjaga akurasi dan kedalaman teknis laporan, setiap bab merujuk secara langsung pada dokumentasi bedah klaster yang telah selesai disusun:

| Bagian Laporan PKL | Sub-Menu / Topik Bahasan | Sumber Rujukan Data Teknis (`00-bedah-klaster/`) |
| :--- | :--- | :--- |
| **Bab I & II** | Gambaran Makro ERP & Infrastruktur Mitra JTV | `core-platform/md/modul-core-platform.md` (Bagian 1) & `data-center-ops/md/klaster-1-fasilitas-fisik.md` |
| **Bab III** (Pelaksanaan Proyek) | Rancang Bangun Modul DC Ops | `data-center-ops/md/klaster-1` s.d. `klaster-5` |
| **Bab IV.1** (Analisis Kebutuhan) | SRS, DFD, & User Flow Alokasi Rak & Visitor Pass | `data-center-ops/md/klaster-1-fasilitas-fisik.md` (Alokasi 42U) & `klaster-5-keamanan-akses.md` (Visitor Pass Scanner) |
| **Bab IV.2** (Pemrograman Framework) | React TypeScript, TanStack Query, & Laravel Modular | `data-center-ops/md/klaster-2-jaringan-pengkabelan.md`, `klaster-3-telemetri.md`, & `core-platform/md/modul-core-platform.md` |
| **Bab IV.3** (Pemrograman API) | REST Endpoints, API Key IoT, & Skema ERD MySQL | `data-center-ops/md/klaster-2` (Port & IPAM), `klaster-4` (Ticket & Surat), & `core-platform` (ApiKey Subnet Matcher) |
| **Bab IV.4** (Rekognisi PKL) | Implementasi Lapangan, Work Orders, & Logbook | `data-center-ops/md/klaster-4-operasional-dokumen.md` & `D:\magang\laporan pkl\LOGBOOK KEGIATAN PLK.docx` |
