# ATURAN & PROTOKOL KERJA AGENT (AGENTS.md)

**Workspace**: `d:\website\MSDC\laporan_akhir\`  
**Proyek**: Laporan Praktik Kerja Lapangan (PKL) & Laporan Magang Industri MSDC ERP  
**Sistem / Modul**: Data Center Operations (DC Ops) & Ekosistem MSDC ERP  
**Engine Dokumen**: MenulisCep4t Dual-Engine (Typst untuk PDF + Pandoc & OpenXML Multi-Pass untuk Word DOCX)  

---

## 1. ATURAN EMAS UTAMA (GOLDEN RULE)

> **FOKUS SAAT INI ADALAH FASE PEMAHAMAN TERLEBIH DAHULU.**  
> **DILARANG KERAS** mulai menulis bab-bab laporan formal (Bab 1, Bab 2, Bab 3, Bab 4, Bab 5 pada folder `01-laporan-magang/` maupun `02-laporan-pkl/`) sebelum pengguna (**USER**) selesai memahami dan menguasai secara mendalam ke-5 klaster pada modul Data Center Operations!

**Alasan Akademik & Teknis:**
- Laporan formal hanya akan berkualitas, akurat, dan dapat dipertanggungjawabkan apabila mahasiswa/penulis memahami arsitektur sistem, alur kode riil (*fullstack flow*), dan alasan rekayasa (*engineering reasons*) di balik setiap fitur.
- Menulis draf laporan sebelum paham hanya akan menghasilkan teks generik tanpa substansi teknis dan rentan gagal saat sidang di hadapan dosen penguji.

---

## 2. STANDAR BEDAH KLASTER (`00-bedah-klaster/`)

Setiap kali sesi pembahasan/pembedahan satu klaster selesai bersama pengguna, Agent **WAJIB secara otomatis** merangkum dan menyimpan catatan teknisnya ke berkas:
`laporan_akhir/00-bedah-klaster/klaster-X-[nama-klaster].md`

Struktur wajib pada setiap berkas bedah klaster:
1. **Ringkasan Eksekutif & Filosofi Bisnis**:
   - Apa peran bisnis sub-menu ini di data center komersial?
   - Mengapa struktur datanya dirancang demikian?
2. **Arsitektur End-to-End (Fullstack Trace)**:
   - Alur data runtut dari:
     $$\text{React UI Component} \longrightarrow \text{TanStack Query Hook} \longrightarrow \text{Axios API Client} \longrightarrow \text{Laravel Route} \longrightarrow \text{Form Request / Validator} \longrightarrow \text{Controller} \longrightarrow \text{Service Layer} \longrightarrow \text{Eloquent Model} \longrightarrow \text{MySQL Database}$$
3. **Logika Proteksi & Integritas Data (Business Guards & Edge Cases)**:
   - *Delete Guards* (mengapa dan kapan data dilarang dihapus).
   - Validasi unik bertingkat (*scoped uniqueness*).
   - Interkoneksi lintas modul (CRM, Fixed Assets, HR, dsb).
4. **Diagram Sumber (`.mmd`)**:
   - Setiap diagram arsitektur, DFD, atau Flowchart wajib disimpan file sumbernya di `diagrams/source/` dengan format Mermaid (`.mmd`), lalu dirender ke `diagrams/rendered/*.png` untuk disisipkan ke laporan.
5. **Bank Pertanyaan & Jawaban Sidang Penguji**:
   - Minimal 4-5 pertanyaan kritis yang sering diajukan dosen penguji/pembimbing dan formula jawaban ilmiah yang memukau.

---

## 3. PETA 5 KLASTER DATA CENTER OPERATIONS

Berikut adalah peta jalan pembedahan ke-5 klaster Data Center Operations:

- **Klaster 1: Hirarki Fasilitas Fisik Gedung**
  - Sub-menu: *Site Manager* (`/dc/sites`), *Room Manager* (`/dc/rooms`), *Rack Manager & Visual 42U* (`/dc/racks`).
  - Berkas: `00-bedah-klaster/klaster-1-fasilitas-fisik.md`
- **Klaster 2: Jaringan & Pengkabelan (Connectivity Layer)**
  - Sub-menu: *Device Inventory* (`/dc/devices`), *Network Port* (`/dc/network-ports`), *Cross-Connect* (`/dc/cross-connects`), *OTB Inventory* (`/dc/otbs`), *IPAM* (`/dc/ipam`).
  - Berkas: `00-bedah-klaster/klaster-2-jaringan-pengkabelan.md`
- **Klaster 3: Telemetri & Pengawasan (Monitoring & Surveillance)**
  - Sub-menu: *Dashboard Utama DC* (`/dc`), *Telemetri Rak & ASHRAE TC 9.9* (`/dc/monitoring`), *Pemantauan CCTV Lorong & Rak* (`/dc/cctv`).
  - Berkas: `00-bedah-klaster/klaster-3-telemetri.md` *(Selesai dibedah)*
- **Klaster 4: Operasional & Administrasi Harian (Operations & Workflow)**
  - Sub-menu: *Ticket & Remote Hands* (`/dc/tickets`), *Perintah Kerja / Work Order* (`/dc/work-orders`), *Usage Records & Billing* (`/dc/usage`), *Surat Operasional DC* (`/dc/surat`).
  - Berkas: `00-bedah-klaster/klaster-4-operasional-dokumen.md`
- **Klaster 5: Keamanan Akses Fisik (Security & ISO 27001 Compliance)**
  - Sub-menu: *Visitor Pass Management* (`/dc/visitor-passes`), *Scanner Pos Jaga Satpam* (`/dc/visitor-scanner`).
  - Berkas: `00-bedah-klaster/klaster-5-keamanan-akses.md`

---

## 4. PEDOMAN PENULISAN AKADEMIK & ANTI-POLA AI (MENULISCEP4T STANDARD)

Saat fase penulisan formal dimulai (setelah 5 klaster selesai), setiap bab dalam `01-laporan-magang/` dan `02-laporan-pkl/` wajib mematuhi standar penulisan berikut:

### 4.1. Nada Bahasa Baku & Objektif (EYD V & KBBI)
- **Gaya Impersonal & Pasif**: Gunakan konstruksi objektif (*"Sistem ini dirancang dengan pendekatan modular..."* bukan *"Saya merancang sistem..."*; *"Pengujian dilakukan menggunakan PHPUnit..."* bukan *"Kami menguji aplikasi..."*).
- **Istilah Asing**: Kata atau istilah teknis bahasa Inggris wajib dicetak miring (*italic*), misalnya *middleware*, *dependency injection*, *payload*, *cross-connect*, *high availability*.

### 4.2. Larangan Frasa Klise & Anti-Pola AI (AI Cliché Ban)
- ❌ **DILARANG KERAS menggunakan frasa klise AI generik**:
  - *"Dalam era globalisasi dan transformasi digital yang serba cepat..."*
  - *"Hal ini tentu sangat penting dan krusial bagi keberlangsungan..."*
  - *"Tak dapat dipungkiri bahwa perkembangan teknologi..."*
  - *"Seperti yang kita ketahui bersama..."*
  - *"Membuka cakrawala baru..."*
- ✔ **WAJIB**: Langsung fokus pada fakta teknis, masalah operasional nyata di data center, bukti empiris, metrik performa, dan relasi sebab-akibat rekayasa perangkat lunak.

### 4.3. Higienitas Heading (Otomatisasi Penomoran)
- Tingkat Bab: `# Judul Bab` (misal: `# Pendahuluan`, `# Landasan Teori`).
- Tingkat Sub-bab: `## Nama Sub-bab` (misal: `## Latar Belakang Masalah`).
- Tingkat Anak Sub-bab: `### Nama Topik` (misal: `### Identifikasi Masalah`).
- ❌ **JANGAN menulis nomor manual pada heading** (JANGAN `## 1.1 Latar Belakang` atau `### 2.1.3 Analisis`). Engine kompilasi otomatis menghitung dan memberikan nomor sub-bab sesuai preset kampus yang aktif!

### 4.4. Higienitas Sitasi & Anti-Halusinasi
- ❌ **DILARANG mengarang referensi palsu atau DOI fiktif**.
- Setiap referensi wajib tercatat di `references.bib` dengan metadata lengkap (penulis, judul, tahun, publikasi/jurnal, DOI/URL).
- Format sitasi di Markdown:
  - Sitasi kurung: `[@kurniawan2023]`
  - Sitasi naratif: `@kurniawan2023 menjelaskan bahwa...`
  - Sitasi ganda: `[@tanenbaum2011; @stallings2016]`

### 4.5. Karakter Khusus & Notasi Matematika
- **Mata Uang**: Tulis `Rp10.000.000` atau `\$100` (wajib *escape* `\$` jika menggunakan simbol dolar agar tidak merusak parser LaTeX).
- **Rumus Matematika**: Gunakan `$formula$` untuk inline dan `$$formula$$` untuk blok.

---

## 5. ALUR BUILD & PEMERIKSAAN DOKUMEN (DUAL-ENGINE CLI)

Dokumen laporan magang dan PKL dikelola terpisah namun menggunakan engine kompilasi yang sama:

| Perintah | Lokasi / Eksekusi | Deskripsi |
| :--- | :--- | :--- |
| `npm run render-diagrams` | `laporan_akhir/` | Mengonversi semua file `.mmd` di `diagrams/source/` menjadi `.png` 3x scale di `diagrams/rendered/`. |
| `npm run build:magang` | `laporan_akhir/` | Mengompilasi `01-laporan-magang` menjadi `Laporan.pdf` dan `Laporan.docx`. |
| `npm run build:pkl` | `laporan_akhir/` | Mengompilasi `02-laporan-pkl` menjadi `Laporan.pdf` dan `Laporan.docx`. |
| `npm run build:all` | `laporan_akhir/` | Mengompilasi kedua laporan sekaligus. |
| `.\laporan.ps1 doctor` | Di subfolder dokumen | Audit kesehatan dokumen (cek sitasi rusak, gambar hilang, format tabel). |
| `.\laporan.ps1 audit` | Di subfolder dokumen | Audit heuristik variasi kalimat dan pola tulisan anti-AI. |
| `.\laporan.ps1 citations verify` | Di subfolder dokumen | Memverifikasi keabsahan tautan DOI secara daring via Crossref. |
| `.\laporan.ps1 stats` | Di subfolder dokumen | Menghitung statistik kata, jumlah bab, dan estimasi ketebalan halaman. |
| `.\laporan.ps1 clean` | Di subfolder dokumen | Membersihkan berkas build temporer (`Laporan.pdf`, `Laporan.docx`, `tmp/`). |
