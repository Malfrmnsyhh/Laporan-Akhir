# SPEC-PKL-KONVERSI: Kontrak Kerja Penulisan Laporan PKL Konversi (01-laporan-magang)

Dokumen ini menjadi kontrak kerja deterministik bagi seluruh sesi penulisan, penyuntingan, dan verifikasi Laporan Praktik Kerja Lapangan (PKL) Konversi pada direktori `01-laporan-magang/`.

---

## 1. Batas Isolasi Workspace (Wajib)

- Seluruh perubahan naskah, konfigurasi, gambar, dan hasil build **HANYA** dilakukan di dalam `01-laporan-magang/`.
- **DILARANG** mengubah berkas di `02-laporan-pkl/`, `03-logbook-plk/`, `04-manual-books/`, `05-artikel-jurnal/`, `MSDC/`, maupun `MSDCFrontend/`. Direktori-direktori tersebut hanya berfungsi sebagai sumber baca dan verifikasi fakta.

---

## 2. Single Source of Truth (SSOT)

Setiap angka, tanggal, nama pejabat, nama rute API, nama tabel, jumlah skenario uji, dan rujukan wajib diverifikasi langsung dari sumber berikut (dilarang mengarang atau memperkirakan):

| Domain Fakta | Sumber Kebenaran Tunggal |
| :--- | :--- |
| Identitas penulis, mode Individu/Kelompok, judul, pejabat pengesahan, dan tanggal ujian | `01-laporan-magang/metadata.yml` |
| Inventaris gambar *READY* dan slot *PENDING* | `01-laporan-magang/ASSET-MANIFEST.md` |
| Daftar rujukan ilmiah & standar 2020-2026 | `01-laporan-magang/references.bib` (23 entri terverifikasi) |
| Spesifikasi teknis 5 klaster *Data Center Operations* | `../00-bedah-klaster/data-center-ops/md/klaster-1..5*.md` |
| Spesifikasi integrasi modul tim lain | `../00-bedah-klaster/{core-platform,crm-sales,finance-accounting,hr-service-support,procurement-inventory,integration-analytics}/md/*.md` |
| Implementasi kode aktual, versi *framework* (*Laravel 12 / v12.64.0*, *PHP 8.4*, *React 18*, *TypeScript 5.6*), dan *test suite* | `../MSDC/` dan `../MSDCFrontend/` |
| Spesifikasi tata letak & struktur resmi Prodi | `../template/LAPORAN PKL.pdf` & `../template/Template Laporan Akhir PLK Prodi v3.docx` |

Apabila suatu data belum tersedia atau belum terverifikasi, wajib menulis penanda `[PERLU DATA: ...]` atau `[PERLU RUJUKAN: ...]` sesuai `../.agent/skills/naskah-id/KONTRAK.md`.

---

## 3. Spesifikasi Format & Struktur Dokumen

- **Preset Aktif:** `presets/upn-pkl-konversi.yml` (A4 `21,0 x 29,7 cm`, margin 4-4-3-3: Atas 4 cm, Kiri 4 cm, Bawah 3 cm, Kanan 3 cm, *Times New Roman* 12 pt, spasi 1,5, *first-line indent* 1,27 cm, gaya sitasi IEEE `ieee.csl`).
- **Urutan Halaman Depan (*Front-Matter*):**
  1. Halaman Sampul (tanpa nomor halaman, mendukung mode Individu maupun Kelompok).
  2. Lembar Pengesahan Praktek Kerja Lapangan Konversi (halaman `ii`, 4 kolom tanda tangan: Dosen Pembimbing, Pembimbing Lapangan, Dekan FIK, Koordinator Prodi Informatika).
  3. Surat Pernyataan Keaslian Kegiatan PKL bermaterai Rp10.000 (halaman `iii`, adaptif *Saya*/*Kami*).
  4. Abstrak Bahasa Indonesia dengan tabel header mini (`Judul`, `Studi Kasus`, `Penulis`, `Pembimbing`) dan kata kunci (halaman `iv`).
  5. *Abstract* Bahasa Inggris dan *Keywords* (halaman `v`).
  6. Kata Pengantar, Daftar Isi, Daftar Tabel, dan Daftar Gambar (Romawi), lalu nomor halaman Arab `1` dimulai pada `BAB I PENDAHULUAN`.
- **Urutan Bab & Belakang (`laporan.ps1`):**
  1. `chapters/bab1-pendahuluan.md`
  2. `chapters/bab2-gambaran-umum.md`
  3. `chapters/bab3-pelaksanaan.md`
  4. `chapters/bab4-hasil-dan-pembahasan.md`
  5. `chapters/bab5-penutup.md`
  6. `chapters/referensi.md` (`# REFERENSI {-}` + `::: {#refs} :::`)
  7. `chapters/lampiran.md` (Lampiran 1: Glosarium/Singkatan, Lampiran 2: LOA, Lampiran 3: Pembagian Tugas/Peran)

---

## 4. Hard Gates Penulisan (Wajib Lulus 100%)

1. **0 Nomor Bab, Sub-Bab, Gambar, atau Tabel Manual:**
   - Tulis `# PENDAHULUAN`, `## Latar Belakang`, `### Tujuan Umum` tanpa angka (`BAB I`, `1.1`, `Gambar 4.1` dihitung otomatis oleh `template.typ` dan `docx.lua`).
   - Khusus bab tanpa nomor gunakan `{-}` (contoh: `# KATA PENGANTAR {-}`, `# REFERENSI {-}`, `# LAMPIRAN {-}`).
2. **0 *Inline Backtick* di Paragraf Narasi (`AGENTS.md` §5.8):**
   - Dilarang memakai tanda `` ` `` di dalam paragraf narasi seluruh bab (`chapters/*.md`).
   - Seluruh istilah asing, nama modul, kelas, metode, *endpoint*, dan tabel basis data wajib ditulis menggunakan *Times New Roman* 12 pt cetak miring (*italic*), misalnya *DataCenterOps*, *lockForUpdate()*, *dc_visitor_access_log*, *2-Tier Sidebar*.
3. **0 *Em-Dash* dan 0 Karakter Box-Drawing Unicode:**
   - Dilarang memakai karakter `—` (em-dash) maupun `├`, `─`, `│`, `┌`, `└`. Gunakan tanda hubung biasa, koma, atau tanda kurung, serta format standar *Markdown Pipe Table* untuk seluruh tabel.
4. **Kepatuhan EYD V, KBBI, & Anti-Slop (`naskah-id`):**
   - Setiap bab wajib lulus `python ../.agent/skills/naskah-id/scripts/periksa.py chapters/<nama-bab>.md` dengan **0 temuan `K`** dan **0 temuan `AI`**.
   - Jalankan juga `python ../.agent/skills/humanizer-indonesia/scripts/metrik.py chapters/<nama-bab>.md --preset akademik` untuk menjaga variasi panjang kalimat alami (rerata 14-20 kata, SD minimal 6,4, verba ringan dan konektor rendah, 0 konjungsi *bila*).
   - Gunakan sudut pandang objektif/impersonal atau sebutan formal *penulis* pada bagian yang memerlukan subjek (dilarang memakai *saya*, *aku*, *kami*, *kita* di dalam bab isi).
5. **0 Salin-Tempel (*Zero Copy-Paste*) dari `02-laporan-pkl/`:**
   - Seluruh kalimat dan alur pembahasan wajib ditulis segar dengan sudut pandang **ekosistem MSDC Enterprise ERP** (memadukan *UI/UX Figma*, *Data Center Operations*, dan integrasi lintas tim).
   - Verifikasi kesegaran redaksi sebelum finalisasi (0 irisan kalimat identik panjang >= 10 kata dengan `02-laporan-pkl/chapters/`).
6. **Kejujuran Aset Gambar:**
   - Hanya sisipkan gambar berstatus `READY` di `ASSET-MANIFEST.md`.
   - Jangan pernah mengarang path gambar yang berstatus `PENDING`; biarkan penanda eksplisit `[PERLU ASET: <ID>]` sampai gambar tersedia dan diverifikasi.

---

## 5. Aturan Batas Klaim Lintas Tim (Wajib Dipatuhi)

Ekosistem *MSDC Enterprise ERP* dikembangkan secara kolaboratif oleh beberapa tim modul. Untuk menjaga kejujuran akademik:

| Area Sistem | Batas Klaim yang Sah | Cara Penulisan yang Diwajibkan |
| :--- | :--- | :--- |
| *UI/UX Design System* *Figma* & Navigasi Global *2-Tier Sidebar* | Dikerjakan langsung oleh penulis (sesuai konfigurasi `author` di `metadata.yml`) | Dapat dinyatakan sebagai kontribusi perancangan antarmuka dan implementasi standar navigasi *frontend*. |
| Modul *Data Center Operations* (Klaster 1 s.d. 5 *backend* & *frontend*) | Dikerjakan penuh oleh penulis (atau tim sesuai `mode_laporan`) | Dijelaskan mendalam hingga arsitektur *controller*, *service*, basis data, *UI*, dan pengujian otomatis. |
| Modul *CorePlatform*, *CRM & Sales*, *Finance & Accounting*, *HR & Service Support*, *Procurement & Inventory*, *Integration & Analytics* | Dikembangkan oleh tim pengembang modul lain dalam proyek ERP MSDC (kecuali anggota terkait tercantum resmi di `metadata.yml` mode Kelompok) | **Wajib ditulis jujur sebagai titik integrasi, kontrak API, dan kolaborasi lintas tim** (misalnya: *"Modul Data Center Operations mengonsumsi layanan autentikasi OAuth2 yang disediakan tim CorePlatform..."*, *"Data utilisasi diteruskan ke modul Finance yang dikelola tim keuangan melalui kontrak endpoint..."*). **DILARANG** mengklaim implementasi internal modul tim lain sebagai hasil karya satu orang. |

---

## 6. Protokol Verifikasi per Bab & Kompilasi Akhir

Setiap selesai menulis satu bab, jalankan urutan pemeriksaan berikut dari direktori `01-laporan-magang/`:

1. `python ../.agent/skills/naskah-id/scripts/periksa.py chapters/<bab>.md` -> Target: **K = 0, AI = 0**.
2. `python ../.agent/skills/humanizer-indonesia/scripts/metrik.py chapters/<bab>.md --preset akademik` -> Target: **lulus ambang akademik**.
3. `.\laporan.ps1 build` -> Menghasilkan `Laporan.pdf` (Typst) dan `Laporan.docx` (Pandoc + `docx.lua` + `finalize-docx.py` + `docx-pagenum.py`) tanpa galat.
4. Inspeksi visual halaman hasil `Laporan.pdf` untuk memastikan tidak ada tabel *overflow*, gambar terpotong, atau nomor bab/gambar ganda.
