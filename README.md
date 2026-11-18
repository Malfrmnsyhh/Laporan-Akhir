# Dokumentasi & Laporan Akhir Magang / PKL — MSDC ERP

Repositori ini berisi seluruh dokumentasi teknis, catatan pembedahan arsitektur sistem, diagram rekayasa, serta draf dokumen akademik untuk **Laporan Magang Industri** dan **Laporan Praktik Kerja Lapangan (PKL)** berbasis sistem **MSDC ERP (Data Center Operations)** di PT JTV.

---

## 📁 Struktur Repositori

```text
.
├── 00-bedah-klaster/          # Catatan pemahaman teknis & arsitektur per klaster
│   ├── klaster-1-fasilitas-fisik.md
│   ├── klaster-2-jaringan-pengkabelan.md
│   ├── klaster-3-telemetri.md
│   ├── klaster-4-operasional-dokumen.md
│   └── klaster-5-keamanan-akses.md
├── 01-laporan-magang/         # Proyek dokumen Laporan Magang Industri
│   ├── metadata.yml           # Konfigurasi judul, penulis, institusi, preset
│   ├── cover.md               # Kata Pengantar & lembar pengesahan
│   ├── chapters/              # Batang tubuh bab (Bab 1 - Bab 5)
│   ├── references.bib         # Database sitasi BibTeX
│   └── laporan.ps1            # CLI helper kompilasi lokal
├── 02-laporan-pkl/            # Proyek dokumen Laporan PKL (Data Center Operations)
│   ├── metadata.yml
│   ├── cover.md
│   ├── chapters/
│   ├── references.bib
│   └── laporan.ps1
├── diagrams/                  # Diagram teknis sistem
│   ├── source/                # Sumber diagram Mermaid (.mmd)
│   └── rendered/              # Gambar resolusi tinggi (.png, scale 3x)
├── laporan-generator/         # Engine kompilasi akademik (MenulisCep4t v4.0.0)
│   ├── presets/               # 14 preset kampus & jurnal ilmiah
│   ├── templates/             # Template dasar Typst & DOCX
│   └── scripts/               # Skrip post-processing & penomoran halaman
├── AGENTS.md                  # Protokol kerja AI Agent & pedoman penulisan akademik
└── package.json               # Runner npm untuk otomatisasi build
```

---

## 🚀 Perintah Build & Kompilasi

Kompilasi dokumen menggunakan dual-engine **Typst** (menghasilkan PDF presisi tinggi) dan **Pandoc + OpenXML** (menghasilkan Microsoft Word `.docx` dengan penomoran halaman ganda):

```powershell
# Render semua diagram Mermaid (.mmd -> .png)
npm run render-diagrams

# Kompilasi Laporan Magang
npm run build:magang

# Kompilasi Laporan PKL
npm run build:pkl

# Kompilasi Seluruh Laporan
npm run build:all
```

Atau masuk ke direktori laporan masing-masing:
```powershell
cd 01-laporan-magang
.\laporan.ps1 doctor   # Audit kelengkapan berkas & sitasi
.\laporan.ps1 audit    # Review pola penulisan
.\laporan.ps1 build    # Build Laporan.pdf dan Laporan.docx
```
