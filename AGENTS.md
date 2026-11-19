# ATURAN & PROTOKOL KERJA AGENT (AGENTS.md)

**Workspace**: `d:\website\MSDC\laporan_akhir\`  
**Proyek**: Laporan Praktik Kerja Lapangan (PKL) & Laporan Magang Industri MSDC ERP  
**Sistem / Modul**: Data Center Operations (DC Ops) — MSDC ERP  
**Institusi Kampus**: UPN "Veteran" Jawa Timur  
**Engine Dokumen**: Dual-Engine (Typst untuk PDF + Pandoc & Reference DOCX untuk Word)  

---

## 1. ATURAN EMAS UTAMA (GOLDEN RULE)

> **FOKUS SAAT INI ADALAH FASE PEMAHAMAN TERLEBIH DAHULU.**  
> **DILARANG KERAS** mulai menulis bab-bab laporan formal (Bab 1, Bab 2, Bab 3, Bab 4, Bab 5 pada folder `01-laporan-magang/` maupun `02-laporan-pkl/`) sebelum pengguna (**USER**) selesai memahami dan menguasai secara mendalam ke-5 klaster pada modul Data Center Operations!

**Alasan Akademik & Teknis:**
- Laporan formal hanya akan berkualitas, akurat, dan dapat dipertanggungjawabkan apabila mahasiswa/penulis memahami arsitektur sistem, alur kode riil (*fullstack flow*), dan alasan rekayasa (*engineering reasons*) di balik setiap fitur.
- Menulis draf laporan sebelum paham hanya akan menghasilkan teks generik tanpa substansi teknis dan rentan gagal saat sidang di hadapan dosen penguji.

---

## 2. STANDAR BEDAH KLASTER (`00-bedah-klaster/data-center-ops/`)

Setiap kali sesi pembahasan/pembedahan satu klaster selesai bersama pengguna, Agent **WAJIB secara otomatis** merangkum dan menyimpan catatan teknisnya ke berkas:
`00-bedah-klaster/data-center-ops/md/klaster-X-[nama-klaster].md`

Lalu otomatis dikonversi menjadi berkas Word di `docx/` dan PDF di `pdf/` menggunakan skrip `npm run convert:bedah`.

### 2.1. Alur Pembahasan Sistematis (4 Pilar Wajib)
Setiap dokumen bedah klaster wajib disusun runtut mengikuti 4 bagian:
1. **Filosofi Bisnis & Masalah**:
   - Peran sub-menu dalam industri data center fisik komersial (*colocation, power, cooling SLA*).
   - Masalah riil di lapangan jika fitur ini tidak diimplementasikan (risiko *double booking*, kekacauan kabel, kegagalan audit).
   - Pemodelan entitas dan relasi antar-komponen.
2. **Arsitektur Fullstack (End-to-End Code Trace)**:
   - Alur data runtut dari:
     $$\text{React UI Component} \longrightarrow \text{TanStack Query Hook} \longrightarrow \text{Laravel API Route} \longrightarrow \text{Controller} \longrightarrow \text{Service Layer} \longrightarrow \text{Eloquent Model} \longrightarrow \text{MySQL Database}$$
   - Cuplikan kode nyata dari controller, service, dan hook frontend.
3. **Spesifikasi API & Validasi (Business Guards & Edge Cases)**:
   - Kontrak endpoint (Method, URI, Parameter).
   - Aturan validasi input dan keunikan bertingkat (*scoped uniqueness*).
   - Mekanisme perlindungan data (*Delete Guards*, *Pessimistic Locking*, *Transaction Integrity*).
   - Interkoneksi lintas modul (CRM Sales Order/Contract, Fixed Assets, dsb).
4. **Bank Pertanyaan & Jawaban Sidang Penguji**:
   - Minimal 4-5 pertanyaan kritis yang sering diajukan dosen penguji/pembimbing dan formula jawaban ilmiah yang memukau.

### 2.2. Panduan Bahasa & Tipografi Akademik (UPN "Veteran" Jawa Timur)
- **Sudut Pandang Impersonal**: Wajib menggunakan sudut pandang orang ketiga atau kalimat pasif (*"Sistem ini dirancang...", "Data diperoleh melalui..."*). **DILARANG KERAS** menggunakan kata "saya", "kami", atau "penulis" di dalam catatan teknis.
- **Tipografi Asing (*Italic*)**: Seluruh istilah asing, istilah teknis bahasa Inggris, dan nama properti kode wajib dicetak miring (*italic*), seperti *middleware*, *eager loading*, *cross-connect*, *pessimistic locking*, *multi-tenancy*.
- **Spesifikasi Format Dokumen**:
  - Ukuran Kertas: A4.
  - Margin: 2,54 cm (1 inci) di seluruh sisi (Atas, Bawah, Kiri, Kanan).
  - Font Narasi: Times New Roman 12 pt, Justified, spasi baris 1,5, *first-line indent* 1,27 cm.
  - Font Kode: Consolas / Courier New 10 pt.
  - Judul Utama: 14 pt Bold Kapital (Center); Sub-bab: 12 pt Bold (Left).
  - Keterangan Gambar (*Caption*): Di bawah gambar, 10 pt *Italic*, Center.
  - Judul Tabel: Di atas tabel, 10 pt *Bold/Italic*.

---

## 3. PETA 5 KLASTER DATA CENTER OPERATIONS

Berikut adalah peta jalan pembedahan ke-5 klaster Data Center Operations:

- **Klaster 1: Hirarki Fasilitas Fisik Gedung**
  - Sub-menu: *Site Manager* (`/dc/sites`), *Room Manager* (`/dc/rooms`), *Rack Manager & Visual 42U* (`/dc/racks`).
  - Berkas: `00-bedah-klaster/data-center-ops/md/klaster-1-fasilitas-fisik.md`
- **Klaster 2: Jaringan & Pengkabelan (Connectivity Layer)**
  - Sub-menu: *Device Inventory* (`/dc/devices`), *Network Port* (`/dc/network-ports`), *Cross-Connect* (`/dc/cross-connects`), *OTB Inventory* (`/dc/otbs`), *IPAM* (`/dc/ipam`).
  - Berkas: `00-bedah-klaster/data-center-ops/md/klaster-2-jaringan-pengkabelan.md`
- **Klaster 3: Telemetri & Pengawasan (Monitoring & Surveillance)**
  - Sub-menu: *Dashboard Utama DC* (`/dc`), *Telemetri Rak & ASHRAE TC 9.9* (`/dc/monitoring`), *Pemantauan CCTV Lorong & Rak* (`/dc/cctv`).
  - Berkas: `00-bedah-klaster/data-center-ops/md/klaster-3-telemetri.md`
- **Klaster 4: Operasional & Administrasi Harian (Operations & Workflow)**
  - Sub-menu: *Ticket & Remote Hands* (`/dc/tickets`), *Perintah Kerja / Work Order* (`/dc/work-orders`), *Usage Records & Billing* (`/dc/usage`), *Surat Operasional DC* (`/dc/surat`).
  - Berkas: `00-bedah-klaster/data-center-ops/md/klaster-4-operasional-dokumen.md`
- **Klaster 5: Keamanan Akses Fisik (Security & ISO 27001 Compliance)**
  - Sub-menu: *Visitor Pass Management* (`/dc/visitor-passes`), *Scanner Pos Jaga Satpam* (`/dc/visitor-scanner`).
  - Berkas: `00-bedah-klaster/data-center-ops/md/klaster-5-keamanan-akses.md`

---

## 4. PERINTAH BUILD & OTOMASI

| Perintah | Eksekusi | Deskripsi |
| :--- | :--- | :--- |
| `npm run render-diagrams` | `laporan_akhir/` | Memindai `diagrams/source/` secara rekursif dan merender `.png` 3x scale ke `diagrams/rendered/`. |
| `npm run convert:bedah` | `laporan_akhir/` | Mengonversi seluruh catatan di `00-bedah-klaster/data-center-ops/md/` ke `docx/` (Times New Roman) dan `pdf/` (Typst). |
| `npm run build:magang` | `laporan_akhir/` | Mengompilasi dokumen formal Laporan Magang Industri. |
| `npm run build:pkl` | `laporan_akhir/` | Mengompilasi dokumen formal Laporan PKL. |
| `npm run build:all` | `laporan_akhir/` | Mengompilasi seluruh dokumen proyek. |

---

## 5. PROTOKOL HUMANIZER & STANDAR PENULISAN NARASI AKADEMIK (WAJIB)

Setiap kali Agent menulis atau menyunting draf narasi laporan pada direktori `02-laporan-pkl/` maupun `01-laporan-magang/`, Agent **WAJIB secara ketat menerapkan seluruh prinsip skill Humanizer** yang diadopsi dari `laporan-generator/.agents/`:

### 5.1. Anti-Klise AI & Eliminasi Frasa Pembuka Generik
- **DILARANG KERAS** membuka paragraf dengan klise pembuka khas AI, seperti:
  - ❌ *"Dalam era digitalisasi dan globalisasi yang berkembang pesat..."*
  - ❌ *"Tidak dapat dipungkiri bahwa teknologi memegang peranan krusial..."*
  - ❌ *"Hal ini tentu sangat penting untuk diperhatikan..."*
  - ❌ *"Lanskap teknologi modern menuntut integrasi komprehensif..."*
- **WAJIB**: Buka paragraf langsung dengan **fakta empiris, masalah teknis nyata, data operasional, standar industri, atau hubungan sebab-akibat yang konkret**.

### 5.2. Moderasi Kata Penghubung Formulaik
Hindari penggunaan kata transisi yang monoton dan mekanis secara beruntun (*formulaic starters*) di awal kalimat, seperti: *"Selain itu"*, *"Namun demikian"*, *"Oleh karena itu"*, *"Di sisi lain"*, *"Dengan demikian"*. Variasikan struktur anak kalimat dan posisi konjungsi secara alami di tengah kalimat.

### 5.3. Variasi Ritme & Panjang Kalimat Alami (*Burstiness*)
Teks narasi manusia yang berkualitas tinggi memiliki variasi panjang kalimat (*sentence burstiness*):
- Gabungkan kalimat pendek-tegas (10–18 kata) yang memuat kesimpulan atau aksi utama dengan kalimat majemuk teknis (22–35 kata) yang memuat penjelasan mekanisme rekayasa.
- Hindari deretan paragraf yang memiliki panjang kalimat seragam (*flat cadence*).

### 5.4. Sudut Pandang Objektif & Sebutan Formal
- Gunakan sudut pandang objektif impersonal atau kalimat pasif (*"Sistem ini dirancang...", "Pengujian dilakukan melalui..."*).
- Apabila konteks mengharuskan penyebutan subjek pelaku (khususnya pada Kata Pengantar dan Bab II.3), **HANYA gunakan sebutan formal "penulis"**. **DILARANG KERAS** menggunakan kata ganti orang pertama/kedua (*"saya"*, *"aku"*, *"kami"*, *"kita"*, *"kamu"*).

### 5.5. Tipografi Bahasa Indonesia Baku (EYD V / PUEBI & KBBI)
- Seluruh istilah asing, istilah teknis bahasa Inggris, dan nama properti kode pemrograman **WAJIB dicetak miring (*italic*)**, misalnya: *multi-tenancy*, *pessimistic locking*, *middleware*, *bearer token*, *cross-connect*, *rate limiting*, *payload*.
- Gunakan kosakata baku Bahasa Indonesia (contoh: *antarmuka* bukan *interface*, *peladen* atau *server*, *pencacah* bukan *counter*, *kuorum* bukan *quorum*).

### 5.6. Penomoran Heading Otomatis (Heading Hygiene)
Engine kompilasi (`template.typ` & `docx.lua`) menghitung penomoran bab dan sub-bab secara otomatis berdasarkan preset kampus aktif (`upn-plk`):
- Level 1: `# JUDUL BAB` (Contoh: `# PENDAHULUAN` — **JANGAN** tulis manual `# BAB I PENDAHULUAN`).
- Level 2: `## Sub-Bab` (Contoh: `## Latar Belakang` — **JANGAN** tulis manual `## I.1 Latar Belakang`).
- Level 3: `### Sub-Sub-Bab` (Contoh: `### Identifikasi Masalah` — **JANGAN** tulis manual `### I.1.1 Identifikasi Masalah`).
- Khusus halaman depan/belakang tanpa nomor bab (Kata Pengantar, Referensi, Lampiran), gunakan penanda *unnumbered*: `# KATA PENGANTAR {-}`.

### 5.7. Larangan Karakter Unicode Box-Drawing
- **DILARANG KERAS** menggunakan karakter gambar kotak Unicode (`├`, `─`, `│`, `┌`, `└`) di dalam tabel atau diagram karena merusak parser Pandoc/Typst.
- Seluruh tabel wajib menggunakan format standar *Markdown Pipe Table* (`| Kolom 1 | Kolom 2 |`).

