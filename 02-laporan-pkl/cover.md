# ABSTRAK {-}

Praktik Lapangan Kerja (PLK) / Magang Mandiri dilaksanakan di PT Jawa Pos Media Televisi (JTV), stasiun televisi regional yang berpusat di Surabaya dan merupakan bagian dari Jawa Pos Group. Kegiatan berlangsung selama 20 minggu di Divisi Teknologi Informasi (IT) dalam rangka implementasi program Merdeka Belajar Kampus Merdeka (MBKM). Proyek yang dikerjakan berfokus pada rekayasa modul *Data Center Operations* (*DataCenterOps*) pada sistem *Enterprise Resource Planning* (ERP) MSDC. Modul ini dirancang untuk mengatasi tata kelola fasilitas pusat data yang terfragmentasi, risiko alokasi ganda (*double allocation*) lemari rak peladen, dan ketiadaan jejak audit operasional yang terintegrasi.

Sistem dibangun dengan arsitektur termodularisasi (*Modular Architecture*) pada kerangka kerja Laravel 11 berbasis prinsip *Domain-Driven Isolation*. Logika bisnis dipisahkan ke dalam lima klaster fungsional: Fasilitas Fisik & Rak Peladen (*Site, Room, Rack 42U*), Jaringan & Interkoneksi Fisik (*Device, Network Port, Cross-Connect, OTB, IPAM*), Telemetri Lingkungan & Pengawasan (*Monitoring & Surveillance*), Operasional Harian & Administrasi (*Ticket & Remote Hands*, *Work Order*, *Usage Billing*, dan surat operasional), serta Keamanan Akses Fisik (*Visitor Pass Management* dan pemindai pos jaga satpam). Seluruh pertukaran data dilayani melalui *RESTful API* berformat JSON yang terhubung ke *shared kernel* modul *CorePlatform*. Keamanan multi-organisasi ditegakkan melalui *X-Organization-Id* dan otentikasi memakai *OAuth2 Bearer Token*. Pada alokasi rak, *pessimistic locking* (*lockForUpdate()*) diterapkan untuk mencegah tabrakan data akibat akses konkuren (*race condition*).

Hasil implementasi mencakup *RESTful API* untuk kelima klaster, komponen visual interaktif *Visual 42U Elevation Grid* untuk memetakan status unit rak, *dashboard* pemantauan telemetri termal, gerbang validasi izin akses fisik di pos satpam berbasis pemindai kamera web, serta penerbitan surat perintah kerja. Pengujian integrasi dilakukan pada kelima klaster, termasuk skenario akses konkuren pada alokasi rak. Modul ini dirancang agar operasional fasilitas pusat data PT Jawa Pos Media Televisi dapat dikelola secara terpusat, dan hasil kerjanya dipetakan ke capaian pembelajaran paket konversi mata kuliah program studi.

**Kata Kunci:** Data Center Operations, ERP MSDC, Modular Architecture, RESTful API, JTV.

# KATA PENGANTAR {-}

Puji syukur ke hadirat Tuhan Yang Maha Esa atas segala limpahan rahmat, karunia, dan hidayah-Nya, sehingga penulis dapat menyelesaikan kegiatan Praktik Lapangan Kerja (PLK) / Magang Mandiri sekaligus menyelesaikan penyusunan Laporan Akhir yang berjudul **"Rekayasa Modul Data Center Operations Terintegrasi Berbasis Modular Architecture dan RESTful API pada Sistem ERP MSDC di PT. Jawa Pos Media Televisi (JTV)"** dengan baik dan tepat pada waktunya.

Laporan Akhir ini disusun guna memenuhi persyaratan kelulusan mata kuliah Praktik Kerja Lapangan (IF221129) sekaligus pemenuhan rekognisi konversi paket mata kuliah program Merdeka Belajar Kampus Merdeka (MBKM) pada Program Studi Informatika, Fakultas Ilmu Komputer, Universitas Pembangunan Nasional "Veteran" Jawa Timur. Melalui pelaksanaan kegiatan magang di PT Jawa Pos Media Televisi (JTV), penulis berkesempatan berkontribusi secara langsung dalam rekayasa perangkat lunak sistem *Enterprise Resource Planning* (ERP) MSDC, khususnya pada perancangan dan implementasi modul *Data Center Operations*.

Penulis menyadari sepenuhnya bahwa keberhasilan pelaksanaan magang dan penyelesaian laporan ini tidak terlepas dari bimbingan, arahan, doa, serta bantuan dari berbagai pihak. Oleh karena itu, pada kesempatan ini penulis menyampaikan rasa terima kasih dan apresiasi yang setinggi-tingginya kepada:

1. **Ibu Prof. Dr. Ir. Rossyda Priyadarshini, M.P.**, selaku Rektor Universitas Pembangunan Nasional "Veteran" Jawa Timur yang telah memfasilitasi pelaksanaan program Merdeka Belajar Kampus Merdeka bagi mahasiswa.
2. **Ibu Prof. Dr. Ir. Novirina Hendrasarie, MT.**, selaku Dekan Fakultas Ilmu Komputer Universitas Pembangunan Nasional "Veteran" Jawa Timur yang senantiasa mendukung kelancaran program magang industri mahasiswa.
3. **Ibu Dr. Intan Yuniar Purbasari, S.Kom., M.Sc.**, selaku Koordinator Program Studi Informatika Fakultas Ilmu Komputer Universitas Pembangunan Nasional "Veteran" Jawa Timur yang telah memberikan arahan akademis serta persetujuan konversi mata kuliah.
4. **Bapak Ardhon Rakhmadi, S.Tr.T., M.Kom.**, selaku Dosen Pembimbing PKL yang senantiasa meluangkan waktu memberikan bimbingan intensif, kritik konstruktif, serta arahan metodologis yang sangat berharga dalam penyusunan laporan ini.
5. **Bapak M. Triman Prasodjo, S.T.**, selaku Direktur Teknik PT Jawa Pos Media Televisi (JTV) dan Pembimbing Lapangan yang telah memberikan kesempatan, izin, fasilitas kerja, dan arahan profesional selama penulis melaksanakan praktik kerja di Divisi Teknologi Informasi.
6. Seluruh staf dan teknisi Divisi Teknologi Informasi PT Jawa Pos Media Televisi (JTV) atas transfer ilmu praktis, keterbukaan diskusi teknis, dan kerja sama yang solid selama rekayasa sistem berlangsung.
7. Rekan-rekan tim pengembang MSDC ERP atas kolaborasi, diskusi arsitektur, dan atmosfer kerja yang saling mendukung selama masa magang.
8. Kedua orang tua dan keluarga tercinta atas doa yang tiada henti, motivasi, pengorbanan, dan dukungan moral maupun material dalam setiap langkah pendidikan penulis.
9. Rekan-rekan mahasiswa Program Studi Informatika UPN "Veteran" Jawa Timur angkatan 2024 atas kebersamaan, semangat juang, dan pertukaran inspirasi selama masa studi.

Penulis menyadari bahwa penulisan laporan ini masih memiliki ruang perbaikan. Oleh sebab itu, setiap kritik dan saran yang membangun sangat diharapkan demi penyempurnaan karya di masa mendatang. Semoga laporan ini dapat memberikan sumbangsih nyata bagi institusi perguruan tinggi, mitra industri, dan pembaca.

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
