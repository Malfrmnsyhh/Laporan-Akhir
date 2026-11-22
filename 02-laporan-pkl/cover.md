# ABSTRAK {-}

```{=typst}
#set par(leading: 0.52em, justify: true, first-line-indent: 1.27cm)
```

Praktik Lapangan Kerja (PLK) pada skema Magang Mandiri dilaksanakan selama 20 minggu (10 Agustus hingga 23 Desember 2026) di Divisi Teknologi Informasi PT Jawa Pos Media Televisi (JTV) Surabaya. Kegiatan dijalani dengan pola kerja hibrida (empat hari *Work From Home* dan *Work From Office* rutin setiap hari Kamis) dengan intensitas 50 hingga 60 jam per pekan atau lebih dari 1.000 jam kerja efektif, melampaui batas minimal 900 jam untuk penyetaraan 20 SKS pada paket konversi *MG220*. Penugasan difokuskan pada rancang bangun modul *Data Center Operations* (*DataCenterOps*) pada ekosistem *Enterprise Resource Planning* (ERP) MSDC guna menggantikan pencatatan ruang peladen yang masih terfragmentasi dan rawan konflik alokasi rak.

Pengembangan perangkat lunak menerapkan siklus iteratif *Agile/Sprint* menggunakan arsitektur *decoupled fullstack* berbasis Laravel 11 Modular (*nwidart/laravel-modules*), React 18 TypeScript, dan MySQL 8. Modul dibagi menjadi lima klaster operasional: hierarki fasilitas fisik dan pemetaan elevasi rak 42U (*Site*, *Room*, *Rack*), konektivitas jaringan (*Device*, *Network Port*, *Cross-Connect*, *OTB*, *IPAM*), dasbor NOC bersama telemetri termal *dual-bounds* dan pengawasan CCTV *HLS*, operasional harian (*Ticket* SLA, *Work Order*, *Usage Billing*, *Surat DC* QR), serta keamanan akses fisik *Visitor Pass* dan pemindai pos satpam (*Scanner Guard*). Seluruh aturan bisnis dan keamanan API dirancang mengikuti acuan *ANSI/TIA-942-C*, *ASHRAE TC 9.9*, dan *ISO/IEC 27001:2022*, dilengkapi isolasi *multi-tenancy* *X-Organization-Id*, autentikasi *OAuth2* *Laravel Passport*, *pessimistic locking* (*lockForUpdate()*), proteksi *Anti-SSRF*, serta token QR sekali pakai.

Hasil implementasi telah lulus 9 *suite* dengan 123 skenario pengujian fitur otomatis Laravel dan tervalidasi melalui *User Acceptance Testing* (UAT) pada *staging server* JTV tanggal 19 November 2026. Luaran magang mencakup modul produksi *DataCenterOps*, publikasi terbuka repositori kode sumber modul, catatan *logbook* harian, serta Buku Panduan (*Manual Book*) pendaftaran Hak Kekayaan Intelektual (HKI) Program Komputer.

**Kata Kunci:** *Data Center Operations*, ERP MSDC, *Modular Architecture*, *RESTful API*, *ISO/IEC 27001:2022*.

```{=typst}
#set par(leading: 0.75em, justify: true, first-line-indent: 1.27cm)
```

# KATA PENGANTAR {-}

Puji syukur penulis panjatkan ke hadirat Tuhan Yang Maha Esa atas segala rahmat dan karunia-Nya, sehingga kegiatan Praktik Lapangan Kerja (PLK) pada skema Magang Mandiri serta penyusunan Laporan Akhir berjudul **"Rekayasa Modul Data Center Operations Terintegrasi Berbasis Modular Architecture dan RESTful API pada Sistem ERP MSDC di PT. Jawa Pos Media Televisi (JTV)"** dapat diselesaikan dengan baik dan tepat waktu.

Laporan Akhir ini disusun guna memenuhi persyaratan kelulusan mata kuliah Praktek Kerja Lapangan (*IF221129*) serta pertanggungjawaban konversi 20 SKS paket *MG220* program Merdeka Belajar Kampus Merdeka (MBKM) pada Program Studi Informatika, Fakultas Ilmu Komputer, Universitas Pembangunan Nasional "Veteran" Jawa Timur. Keterlibatan langsung di Unit IT PT Jawa Pos Media Televisi memberi kesempatan berharga bagi penulis untuk berkontribusi dalam rekayasa sistem *Enterprise Resource Planning* (ERP) MSDC, khususnya pada pembangunan modul *Data Center Operations*.

Keberhasilan pelaksanaan praktik kerja hingga rampungnya naskah ini terwujud berkat bimbingan, dukungan, dan kerja sama dari berbagai pihak. Pada kesempatan ini penulis menyampaikan rasa terima kasih yang tulus kepada:

1. **Ibu Prof. Dr. Ir. Rossyda Priyadarshini, M.P.**, selaku Rektor Universitas Pembangunan Nasional "Veteran" Jawa Timur yang telah memfasilitasi penyelenggaraan program Merdeka Belajar Kampus Merdeka bagi mahasiswa.
2. **Ibu Prof. Dr. Ir. Novirina Hendrasarie, M.T.**, selaku Dekan Fakultas Ilmu Komputer Universitas Pembangunan Nasional "Veteran" Jawa Timur atas dukungan kelembagaan dan payung kerja sama industri yang memungkinkan pelaksanaan magang ini.
3. **Ibu Dr. Intan Yuniar Purbasari, S.Kom., M.Sc.**, selaku Koordinator Program Studi Informatika Fakultas Ilmu Komputer Universitas Pembangunan Nasional "Veteran" Jawa Timur yang telah memberikan arahan akademis serta persetujuan konversi mata kuliah paket *MG220*.
4. **Bapak Ardhon Rakhmadi, S.Tr.T., M.Kom.**, selaku Dosen Pembimbing yang telah meluangkan waktu memberikan bimbingan, masukan teknis, dan arahan penyusunan selama pelaksanaan magang hingga tahap akhir laporan.
5. **Bapak M. Triman Prasodjo, S.T.**, selaku Direktur Teknik PT Jawa Pos Media Televisi (JTV) sekaligus Pembimbing Lapangan yang telah memberikan kepercayaan, ruang berkarya, evaluasi mingguan, serta bimbingan industri selama 20 minggu pelaksanaan proyek.
6. Seluruh staf dan teknisi Unit IT PT Jawa Pos Media Televisi (JTV) atas keterbukaan diskusi teknis ruang peladen, bantuan pengujian *staging*, dan suasana kerja yang kondusif.
7. Rekan-rekan tim pengembang magang MSDC ERP, khususnya rekan Tim 3 serta tim lintas modul (*CorePlatform*, *CRM & Sales*, *Finance*, *HR*, dan *Procurement*), atas kolaborasi integrasi kode yang solid sepanjang masa proyek.
8. Kedua orang tua dan keluarga tercinta atas doa, kesabaran, dorongan semangat, serta dukungan moral maupun material yang senantiasa menyertai setiap langkah studi penulis.

Penulis menyadari bahwa laporan ini masih memiliki ruang untuk disempurnakan. Kritik dan saran yang membangun sangat diharapkan agar karya ini memberi manfaat nyata bagi institusi pendidikan, mitra industri, dan pembaca.

```{=typst}
#v(0.8cm)
#align(right)[
  Surabaya, Desember 2026

  #v(1.2cm)
  Penulis
]
#pagebreak()
#outline(
  title: [#align(center)[#text(size: 14pt, weight: "bold")[DAFTAR ISI]]],
  depth: 3,
)
#context {
  if opt-daftar-gambar {
    let imgs = query(figure.where(kind: image))
    if imgs.len() > 0 {
      pagebreak()
      outline(
        title: align(center)[#text(size: 14pt, weight: "bold")[DAFTAR GAMBAR]],
        target: figure.where(kind: image),
      )
    }
  }
  if opt-daftar-tabel {
    let tbls = query(figure.where(kind: table))
    if tbls.len() > 0 {
      pagebreak()
      outline(
        title: align(center)[#text(size: 14pt, weight: "bold")[DAFTAR TABEL]],
        target: figure.where(kind: table),
      )
    }
  }
}
#pagebreak()
#set page(numbering: "1", number-align: center + bottom)
#counter(page).update(1)
```

```{=openxml}
<w:p><w:pPr><w:jc w:val="right"/><w:spacing w:before="454"/></w:pPr><w:r><w:t>Surabaya, Desember 2026</w:t></w:r></w:p>
<w:p><w:pPr><w:jc w:val="right"/><w:spacing w:before="567"/></w:pPr><w:r><w:t>Penulis</w:t></w:r></w:p>
```
