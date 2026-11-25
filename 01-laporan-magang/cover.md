# KATA PENGANTAR {-}

[DRAF KATA PENGANTAR: Diisi saat penulisan akhir dengan ungkapan syukur dan ucapan terima kasih resmi kepada Rektor UPN "Veteran" Jawa Timur, Dekan Fakultas Ilmu Komputer, Koordinator Program Studi Informatika, Dosen Pembimbing, Pembimbing Lapangan PT Jawa Pos Media Televisi (JTV), staf Unit Teknologi Informasi JTV, serta rekan tim lintas modul MSDC Enterprise ERP.]

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
}
#pagebreak()
#set page(numbering: "1", number-align: center + bottom)
#counter(page).update(1)
```

```{=openxml}
<w:p><w:pPr><w:jc w:val="right"/><w:spacing w:before="454"/></w:pPr><w:r><w:t>Surabaya, Desember 2026</w:t></w:r></w:p>
<w:p><w:pPr><w:jc w:val="right"/><w:spacing w:before="567"/></w:pPr><w:r><w:t>Penulis</w:t></w:r></w:p>
```
