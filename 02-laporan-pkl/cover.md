# KATA PENGANTAR {-}

Puji syukur ke hadirat Tuhan Yang Maha Esa atas segala limpahan rahmat, taufik, dan hidayah-Nya, sehingga penulis dapat menyelesaikan penyusunan Laporan Akhir Praktik Lapangan Kerja (PLK) / Magang Mandiri yang berjudul **"Rancang Bangun Modul Data Center Operations (Visitor Access Pass, Fasilitas Ruang Rak, dan Surveilans Fisik) pada Sistem ERP MSDC PT Jawa Pos Media Televisi"** dengan baik dan tepat waktu.

Laporan ini disusun sebagai salah satu persyaratan kelulusan mata kuliah Praktik Kerja Lapangan (PKL) sekaligus pemenuhan rekognisi konversi mata kuliah program Merdeka Belajar Magang Industri pada Program Studi Informatika, Fakultas Ilmu Komputer, Universitas Pembangunan Nasional "Veteran" Jawa Timur. Selama melaksanakan kegiatan magang di PT Jawa Pos Media Televisi (JTV), penulis berkesempatan berkontribusi aktif dalam perancangan dan pengembangan sistem Enterprise Resource Planning (ERP) MSDC, khususnya pada subsistem Data Center Operations.

Penulis menyadari sepenuhnya bahwa keberhasilan penyelesaian laporan ini tidak terlepas dari bimbingan, dorongan, dan bantuan dari berbagai pihak. Oleh karena itu, pada kesempatan ini penulis menyampaikan rasa terima kasih dan apresiasi yang setinggi-tingginya kepada:

1. Bapak/Ibu Dekan Fakultas Ilmu Komputer, Universitas Pembangunan Nasional "Veteran" Jawa Timur.
2. Bapak/Ibu Koordinator Program Studi Informatika, Fakultas Ilmu Komputer, UPN "Veteran" Jawa Timur.
3. Bapak/Ibu Dosen Pembimbing PKL yang senantiasa meluangkan waktu memberikan arahan, kritik, dan bimbingan akademik yang sangat berharga.
4. Bapak/Ibu Pembimbing Lapangan dan seluruh staf Divisi TI di PT Jawa Pos Media Televisi (JTV) atas bimbingan profesional, fasilitas kerja, dan ilmu yang telah dibagikan selama kegiatan magang.
5. Rekan-rekan tim pengembang MSDC ERP serta keluarga tercinta atas dukungan moral, doa, dan motivasi tanpa henti.

Penulis menyadari bahwa laporan ini masih memiliki ruang perbaikan. Oleh sebab itu, setiap kritik dan saran yang konstruktif sangat diharapkan demi penyempurnaan karya di masa mendatang. Semoga laporan ini dapat memberikan manfaat nyata bagi institusi, mitra industri, dan pembaca.

```{=typst}
#v(0.8cm)
#align(right)[
  Surabaya, Desember 2026

  #v(1cm)
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
#set page(numbering: "1")
#counter(page).update(1)
```

```{=openxml}
<w:p><w:pPr><w:jc w:val="right"/><w:spacing w:before="454"/></w:pPr><w:r><w:t>Surabaya, Desember 2026</w:t></w:r></w:p>
<w:p><w:pPr><w:jc w:val="right"/><w:spacing w:before="567"/></w:pPr><w:r><w:t>Penulis</w:t></w:r></w:p>
```
