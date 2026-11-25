#set document(
  title: "$title$",
  author: ($for(author)$"$author.name$"$sep$,$endfor$),
)

$if(margin_top)$
#let doc-margin = (
  top: $margin_top$,
  bottom: $margin_bottom$,
  left: $margin_left$,
  right: $margin_right$,
)
$else$
#let doc-margin = (top: 4cm, bottom: 3cm, left: 4cm, right: 3cm)
$endif$

#set page(
  paper: "a4",
  margin: doc-margin,
  numbering: none,
)

$if(font_family)$
#set text(font: "$font_family$", size: $if(font_size)$$font_size$$else$12pt$endif$)
$else$
#set text(font: "Times New Roman", size: 12pt)
$endif$
#set text(hyphenate: false)

$if(line_spacing)$
#set par(justify: true, leading: $line_spacing$, first-line-indent: $if(first_line_indent)$$first_line_indent$$else$1.27cm$endif$)
$else$
#set par(justify: true, leading: 0.75em, first-line-indent: 1.27cm)
$endif$
#show bibliography: set par(hanging-indent: $if(first_line_indent)$$first_line_indent$$else$1.27cm$endif$, first-line-indent: 0cm)

#let raw-prefix = "$if(heading_chapter_prefix)$$heading_chapter_prefix$$else$BAB $endif$"
#let chapter-prefix = if raw-prefix == "" {
  ""
} else if raw-prefix.ends-with(" ") {
  raw-prefix
} else {
  raw-prefix + " "
}
#let chapter-fmt = "$if(heading_chapter_num_format)$$heading_chapter_num_format$$else$roman$endif$"
#let format-chapter-num(n) = {
  if chapter-fmt == "arabic" {
    numbering("1", n)
  } else {
    numbering("I", n)
  }
}

#set heading(numbering: (..ns) => {
  if ns.len() == 1 {
    if chapter-prefix != "" {
      chapter-prefix + format-chapter-num(ns.at(0))
    } else {
      format-chapter-num(ns.at(0))
    }
  } else if ns.len() == 2 {
    numbering("$if(heading_sub_dot)$1.1.$else$1.1$endif$", ..ns)
  } else {
    numbering("$if(heading_subsub_dot)$1.1.1.$else$1.1.1$endif$", ..ns)
  }
})

#show figure.where(kind: image): set figure(
  supplement: [Gambar],
  numbering: it => {
    let ch = counter(heading).get().at(0, default: 1)
    str(ch) + "." + str(it)
  }
)

#show figure.where(kind: table): set figure(
  supplement: [Tabel],
  numbering: it => {
    let ch = counter(heading).get().at(0, default: 1)
    str(ch) + "." + str(it)
  }
)

#show figure.where(kind: raw): set figure(
  supplement: [Listing],
  numbering: it => {
    let ch = counter(heading).get().at(0, default: 1)
    str(ch) + "." + str(it)
  }
)

#set math.equation(numbering: it => "(" + str(counter(heading).get().at(0, default: 1)) + "." + str(it) + ")")

#show heading.where(level: 1): it => [
  #counter(figure.where(kind: image)).update(0)
  #counter(figure.where(kind: table)).update(0)
  #counter(figure.where(kind: raw)).update(0)
  #counter(math.equation).update(0)
  #pagebreak(weak: true)
  #align(center)[
    #block(inset: (top: 0.4em, bottom: 1.5em))[
      #set par(justify: false, first-line-indent: 0cm)
      #text(size: 14pt, weight: "bold")[
        #if it.numbering != none [
          #if chapter-prefix != "" [
            #(chapter-prefix + format-chapter-num(counter(heading).get().at(0)))
            #linebreak()
          ] else [
            #(format-chapter-num(counter(heading).get().at(0)) + ". ")
          ]
          #if it.body.has("text") [
            #upper(it.body.text)
          ] else [
            #upper(it.body)
          ]
        ] else [
          #it.body
        ]
      ]
    ]
  ]
]

#show heading.where(level: 2): it => {
  block(above: 1.0em, below: 0.5em, sticky: true)[
    #set par(justify: false, first-line-indent: 0cm)
    #text(size: 12pt, weight: "bold")[#it]
  ]
}

#show heading.where(level: 3): it => {
  block(above: 0.8em, below: 0.4em, sticky: true)[
    #set par(justify: false, first-line-indent: 0cm)
    #text(size: 12pt, weight: "bold")[#it]
  ]
}

#show figure.where(kind: image): set block(breakable: false)
#show figure: it => it + par[]
#show list: it => it + par[]
#show enum: it => it + par[]
#show quote: it => {
  block(
    fill: rgb("#f3f4f6"),
    stroke: (left: 3.5pt + rgb("#2563eb")),
    inset: (x: 12pt, y: 8pt),
    radius: (right: 4pt),
    width: 100%,
  )[
    #set text(size: 10.5pt, style: "italic")
    #set par(justify: true, leading: 0.65em, first-line-indent: 0cm)
    #it.body
  ]
}
#show raw.where(block: true): it => {
  block(
    fill: rgb("#f8f9fa"),
    stroke: 0.5pt + rgb("#d1d5db"),
    inset: (x: 10pt, y: 8pt),
    radius: 4pt,
    width: 100%,
  )[
    #set text(font: "DejaVu Sans Mono", size: 8.5pt)
    #set par(justify: false, leading: 0.55em, first-line-indent: 0cm)
    #it
  ]
}

#show outline.entry.where(level: 1): set text(weight: "bold")

#set table(
  stroke: 0.5pt + luma(140),
  inset: (x: 5pt, y: 5pt),
  align: left,
)
#show table: it => {
  set text(size: 10pt, hyphenate: false)
  set par(justify: false, leading: 0.55em, first-line-indent: 0pt)
  show regex("::|/|_|\\."): m => m + sym.zws
  show regex("[a-z][A-Z]"): m => m.text.slice(0, 1) + sym.zws + m.text.slice(1)
  it
  par[]
}
#show table.header: set text(weight: "bold")
#show figure.where(kind: table): set block(breakable: true)
#show figure.where(kind: table): set figure.caption(position: top)
#set figure.caption(position: bottom)

#let doc-authors = (
  $for(author)$
  (name: "$author.name$", nim: "$author.nim$"),
  $endfor$
)
#let is-group = doc-authors.len() > 1

// ============================================================================
// 1. HALAMAN SAMPUL (Tanpa Nomor Halaman)
// ============================================================================
#block[
  #set par(justify: false, first-line-indent: 0cm, leading: 0.7em)
  #v(0.5cm)
  #align(center)[
    #text(size: 14pt, weight: "bold")[#upper("$title$".replace("\n", " "))]
    #v(0.6cm)
    #text(size: 14pt, weight: "bold")[$if(doc_kind)$$doc_kind$$else$PRAKTIK KERJA LAPANGAN$endif$]
  ]
]

#v(1fr)
#align(center)[
  #image("$if(logo)$$logo$$else$gambar/01-profil/logo-upn.png$endif$", width: $if(cover_logo_width)$$cover_logo_width$$else$4.5cm$endif$)
]
#v(1fr)

#align(center)[
  #set par(justify: false, first-line-indent: 0cm, leading: 0.65em)
  #text(size: 12pt, weight: "bold")[Oleh:]
  #v(0.35cm)
  #if is-group [
    #grid(
      columns: (auto, auto),
      column-gutter: 1.5cm,
      row-gutter: 0.28cm,
      align: (left, left),
      ..doc-authors.map(a => (
        text(size: 12pt)[#a.name],
        text(size: 12pt)[(#a.nim)],
      )).flatten()
    )
  ] else [
    #for a in doc-authors [
      #text(size: 12pt, weight: "bold")[#a.name] \
      #text(size: 12pt)[(#a.nim)]
    ]
  ]
]

#v(1fr)
#align(center)[
  #set par(justify: false, first-line-indent: 0cm, leading: 0.7em)
  #text(size: 14pt, weight: "bold")[$if(department)$$department$$else$PROGRAM STUDI INFORMATIKA$endif$] \
  #text(size: 14pt, weight: "bold")[$if(faculty)$$faculty$$else$FAKULTAS ILMU KOMPUTER$endif$] \
  #text(size: 14pt, weight: "bold")[$if(institution)$$institution$$else$UNIVERSITAS PEMBANGUNAN NASIONAL "VETERAN" JAWA TIMUR$endif$] \
  #text(size: 14pt, weight: "bold")[$if(year)$$year$$else$2026$endif$]
]
#v(0.4cm)

// Mulai halaman depan bernomor Romawi (ii dst., Sampul dihitung i)
#pagebreak()
#set page(numbering: "i", number-align: center + bottom)
#counter(page).update(2)

// ============================================================================
// 2. LEMBAR PENGESAHAN PRAKTEK KERJA LAPANGAN KONVERSI (4 Tanda Tangan)
// ============================================================================
$if(approval)$
#block[
  #set par(justify: false, first-line-indent: 0cm, leading: 0.65em)
  #align(center)[
    #text(size: 13pt, weight: "bold")[$if(approval.heading)$$approval.heading$$else$LEMBAR PENGESAHAN PRAKTEK KERJA LAPANGAN KONVERSI$endif$]
  ]
  #v(0.7cm)
  #grid(
    columns: (2.2cm, 0.4cm, 1fr),
    row-gutter: 0.35cm,
    align: (left, center, left),
    text(size: 11pt, weight: "bold")[Judul],
    text(size: 11pt, weight: "bold")[:],
    text(size: 11pt, weight: "bold")[#upper("$title$".replace("\n", " "))],
    text(size: 11pt, weight: "bold")[Oleh],
    text(size: 11pt, weight: "bold")[:],
    grid(
      columns: (1fr, auto),
      column-gutter: 0.8cm,
      row-gutter: 0.2cm,
      ..doc-authors.map(a => (
        text(size: 11pt, weight: "bold")[#a.name],
        text(size: 11pt, weight: "bold")[(#a.nim)],
      )).flatten()
    ),
  )
  #v(0.7cm)
  #align(center)[
    #text(size: 11pt, weight: "bold")[Telah Diseminarkan Dalam Ujian PKL, pada :] \
    #text(size: 11pt, weight: "bold")[Hari $if(approval.exam_day)$$approval.exam_day$$else$........$endif$, Tanggal $if(approval.exam_date)$$approval.exam_date$$else$........$endif$ Bulan $if(approval.exam_month)$$approval.exam_month$$else$Desember$endif$ $if(approval.exam_year)$$approval.exam_year$$else$2026$endif$]
  ]
  #v(0.8cm)
  #align(center)[#text(size: 11pt, weight: "bold")[Menyetujui]]
  #v(0.35cm)
  #grid(
    columns: (1fr, 1fr),
    gutter: 18pt,
    $for(approval.supervisors)$
    align(center)[
      #text(size: 11pt, weight: "bold")[$it.role$] \
      #v(2.0cm)
      #underline(text(size: 10.5pt, weight: "bold")[$it.name$]) \
      $if(it.nip)$#text(size: 10pt, weight: "bold")[NIP. $it.nip$]$endif$
    ],
    $endfor$
  )
  $if(approval.officials)$
  #v(0.9cm)
  #align(center)[#text(size: 11pt, weight: "bold")[Mengetahui]]
  #v(0.35cm)
  #grid(
    columns: (1fr, 1fr),
    gutter: 18pt,
    $for(approval.officials)$
    align(center)[
      #text(size: 11pt, weight: "bold")[$it.role$] \
      $if(it.unit)$#text(size: 11pt, weight: "bold")[$it.unit$] \$endif$
      #v(2.0cm)
      #underline(text(size: 10.5pt, weight: "bold")[$it.name$]) \
      $if(it.nip)$#text(size: 10pt, weight: "bold")[NIP. $it.nip$]$endif$
    ],
    $endfor$
  )
  $endif$
]
#pagebreak()
$endif$

// ============================================================================
// 3. SURAT PERNYATAAN KEASLIAN KEGIATAN PKL (Bermaterai Rp10.000)
// ============================================================================
$if(statement.enabled)$
#block[
  #set par(justify: true, first-line-indent: 0cm, leading: 0.72em)
  #align(center)[
    #text(size: 13pt, weight: "bold")[SURAT PERNYATAAN]
  ]
  #v(0.6cm)
  #let pron-cap = if is-group { "Kami" } else { "Saya" }
  #let pron-low = if is-group { "kami" } else { "saya" }
  #text(size: 12pt)[#pron-cap yang bertanda tangan di bawah ini:]
  #v(0.35cm)
  #for a in doc-authors [
    #grid(
      columns: (3.2cm, 0.4cm, 1fr),
      row-gutter: 0.15cm,
      [Nama], [:], [#a.name],
      [NPM], [:], [#a.nim],
    )
    #v(0.25cm)
  ]
  #v(0.2cm)
  #text(size: 12pt)[Menyatakan bahwa kegiatan PKL yang #pron-low lakukan memang benar-benar telah #pron-low laksanakan di perusahaan/instansi:]
  #v(0.3cm)
  #grid(
    columns: (4.6cm, 0.4cm, 1fr),
    row-gutter: 0.2cm,
    [Nama Perusahaan/Instansi], [:], [$if(partner_name)$$partner_name$$else$PT JAWA POS MEDIA TELEVISI (JTV)$endif$],
    [Alamat], [:], [$if(partner_address)$$partner_address$$else$Graha Pena, Jl. Ahmad Yani No. 88, Ketintang, Gayungan, Surabaya, Jawa Timur$endif$],
  )
  #v(0.35cm)
  #text(size: 12pt)[Valid, dan perusahaan/instansi tempat #pron-low melaksanakan PKL benar adanya serta dapat dibuktikan kebenarannya. Jika #pron-low menyalahi surat pernyataan yang #pron-low buat maka #pron-low siap menerima konsekuensi akademik maupun non-akademik. Demikian surat pernyataan ini #pron-low buat sebagai syarat laporan PKL di Program Studi Informatika, Fakultas Ilmu Komputer, Universitas Pembangunan Nasional "Veteran" Jawa Timur.]
  #v(1.1cm)
  #if is-group [
    #grid(
      columns: (1fr, 1fr),
      column-gutter: 1.0cm,
      row-gutter: 1.2cm,
      ..doc-authors.map(a => align(center)[
        #set par(justify: false, first-line-indent: 0cm)
        #box(stroke: 0.5pt + luma(150), inset: (x: 10pt, y: 6pt))[#text(size: 9.5pt)[$if(statement.stamp_label)$$statement.stamp_label$$else$Materai Rp10.000$endif$]]
        #v(0.9cm)
        #text(size: 11.5pt, weight: "bold")[#a.name] \
        #text(size: 11pt)[#a.nim]
      ])
    )
  ] else [
    #align(right)[
      #box(width: 7cm)[
        #set par(justify: false, first-line-indent: 0cm)
        #align(center)[
          #text(size: 11.5pt)[$if(city)$$city$$else$Surabaya$endif$, $if(date)$$date$$else$Desember 2026$endif$]
          #v(0.35cm)
          #box(stroke: 0.5pt + luma(150), inset: (x: 10pt, y: 6pt))[#text(size: 9.5pt)[$if(statement.stamp_label)$$statement.stamp_label$$else$Materai Rp10.000$endif$]]
          #v(0.9cm)
          #for a in doc-authors [
            #text(size: 11.5pt, weight: "bold")[#a.name] \
            #text(size: 11pt)[#a.nim]
          ]
        ]
      ]
    ]
  ]
]
#pagebreak()
$endif$

// ============================================================================
// 4. ABSTRAK BAHASA INDONESIA (dengan Tabel Header Mini)
// ============================================================================
$if(abstract_id)$
#block[
  #set par(justify: false, first-line-indent: 0cm, leading: 0.6em)
  #grid(
    columns: (2.8cm, 0.4cm, 1fr),
    row-gutter: 0.22cm,
    align: (left, center, left),
    text(size: 11pt)[Judul],
    text(size: 11pt)[:],
    text(size: 11pt, weight: "bold")[#upper("$title$".replace("\n", " "))],
    text(size: 11pt)[Studi Kasus],
    text(size: 11pt)[:],
    text(size: 11pt)[$if(case_study)$$case_study$$else$PT Jawa Pos Media Televisi (JTV)$endif$],
    text(size: 11pt)[Penulis],
    text(size: 11pt)[:],
    stack(
      spacing: 0.15cm,
      ..doc-authors.map(a => text(size: 11pt)[#a.name])
    ),
    text(size: 11pt)[Pembimbing],
    text(size: 11pt)[:],
    text(size: 11pt)[$if(lecturer)$$lecturer$$else$Ardhon Rakhmadi, S.Tr.T., M.Kom.$endif$],
  )
  #v(0.2cm)
  #line(length: 100%, stroke: 0.8pt + black)
]
#v(0.45cm)
#block[
  #set par(justify: true, leading: 0.65em, first-line-indent: 0cm)
  #text(size: 12pt, weight: "bold")[ABSTRAK]
  #v(0.35cm)
  #text(size: 12pt)[$abstract_id$]
  $if(keywords_id)$
  #v(0.45cm)
  #text(size: 12pt)[
    #strong[Kata kunci:] #emph[$for(keywords_id)$$keywords_id$$sep$, $endfor$.]
  ]
  $endif$
]
#pagebreak()
$endif$

// ============================================================================
// 5. ABSTRACT BAHASA INGGRIS
// ============================================================================
$if(abstract_en)$
#block[
  #set par(justify: true, leading: 0.65em, first-line-indent: 0cm)
  #text(size: 12pt, weight: "bold")[ABSTRACT]
  #v(0.35cm)
  #text(size: 12pt, style: "italic")[$abstract_en$]
  $if(keywords_en)$
  #v(0.45cm)
  #text(size: 12pt)[
    #strong[Keywords:] #emph[$for(keywords_en)$$keywords_en$$sep$, $endfor$.]
  ]
  $endif$
]
#pagebreak()
$endif$

#let opt-daftar-gambar = $if(daftar_gambar)$$daftar_gambar$$else$$if(list_of_figures)$$list_of_figures$$else$false$endif$$endif$
#let opt-daftar-tabel = $if(daftar_tabel)$$daftar_tabel$$else$$if(list_of_tables)$$list_of_tables$$else$false$endif$$endif$

$body$
