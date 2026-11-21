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
#let doc-margin = if "$margin_preset$" == "skripsi-4433" or "$margin_preset$" == "4-4-3-3" {
  (top: 4cm, bottom: 3cm, left: 4cm, right: 3cm)
} else {
  (top: 2cm, bottom: 3cm, left: 2.5cm, right: 2.5cm)
}
$endif$

#set page(
  paper: "a4",
  margin: doc-margin,
  numbering: none,
)

$if(font_family)$
#set text(font: "$font_family$", size: $if(font_size)$$font_size$$else$12pt$endif$)
$else$
#set text(font: "Libertinus Serif", size: 12pt)
$endif$
#set text(hyphenate: false)

$if(line_spacing)$
#set par(justify: true, leading: $line_spacing$, first-line-indent: $if(first_line_indent)$$first_line_indent$$else$1.25cm$endif$)
$else$
#set par(justify: true, leading: 0.75em, first-line-indent: 1.25cm)
$endif$
#show bibliography: set par(hanging-indent: $if(first_line_indent)$$first_line_indent$$else$1.25cm$endif$, first-line-indent: 0cm)

#let is-journal = ("$doc_type$" == "journal" or "$is_journal$" == "true" or "$cover_show$" == "false")
#let raw-prefix = if is-journal { "" } else { "$if(heading_chapter_prefix)$$heading_chapter_prefix$$else$BAB $endif$" }
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
    format-chapter-num(ns.at(0)) + "." + str(ns.at(1))
  } else {
    format-chapter-num(ns.at(0)) + "." + str(ns.at(1)) + "." + str(ns.at(2))
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
  #if is-journal [
    #v(0.6cm)
    #block(inset: (bottom: 0.3em))[
      #set text(size: 11pt, weight: "bold")
      #set par(first-line-indent: 0cm)
      #it.body
    ]
  ] else [
    #pagebreak(weak: true)
    #align(center)[
      #block(inset: (top: 0.5em, bottom: 1.8em))[
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
]

#show heading.where(level: 2): it => {
  block(above: 1.0em, below: 0.5em)[
    #text(size: 12pt, weight: "bold")[#it]
  ]
  par(leading: 0.75em)[]
}

#show heading.where(level: 3): it => {
  block(above: 0.8em, below: 0.4em)[
    #text(size: 12pt, weight: "bold")[#it]
  ]
  par(leading: 0.75em)[]
}

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
    #set par(justify: true, leading: 0.65em)
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
    #set par(justify: false, leading: 0.55em)
    #it
  ]
}

#show outline.entry.where(level: 1): set text(weight: "bold")
#set par(leading: 0.75em)

#let balance-split(title, k) = {
  let words = title.split(" ")
  let n = words.len()
  if n <= 1 {
    return (title,)
  }
  if n <= k {
    return words
  }
  let single-count = lines => lines.map(l => if l.split(" ").len() <= 1 { 1 } else { 0 }).sum()
  let candidates = ()
  if k == 2 {
    for c in range(1, n) {
      let line1 = words.slice(0, c).join(" ")
      let line2 = words.slice(c, n).join(" ")
      let mx = calc.max(line1.len(), line2.len())
      candidates = candidates + (
        (mx + 100 * single-count((line1, line2)), (line1, line2)),
      )
    }
  } else if k == 3 {
    for c1 in range(1, n - 1) {
      for c2 in range(c1 + 1, n) {
        let line1 = words.slice(0, c1).join(" ")
        let line2 = words.slice(c1, c2).join(" ")
        let line3 = words.slice(c2, n).join(" ")
        let mx = calc.max(line1.len(), line2.len(), line3.len())
        candidates = candidates + (
          (mx + 100 * single-count((line1, line2, line3)), (line1, line2, line3)),
        )
      }
    }
  }
  let best = candidates.at(0)
  for cand in candidates {
    if cand.at(0) < best.at(0) {
      best = cand
    }
  }
  best.at(1)
}

#let title-lines = layout(size => {
  let t = upper("$title$".replace("\n", " ").replace("\r", " "))
  let lines = if measure(text(t, size: 14pt, weight: "bold")).width <= size.width {
    (t,)
  } else {
    let two = balance-split(t, 2)
    let w-two = two.map(l => measure(text(l, size: 14pt, weight: "bold")).width)
      .fold(0pt, calc.max)
    let orphan = two.any(l => l.split(" ").len() <= 1)
    if (not orphan) and w-two <= size.width {
      two
    } else {
      balance-split(t, 3)
    }
  }
  let out = ()
  for i in range(lines.len()) {
    if i > 0 {
      out.push(linebreak())
    }
    out.push(lines.at(i))
  }
  out.join()
})

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

#set figure.caption(position: bottom)
#show raw.where(block: true): set text(font: "DejaVu Sans Mono", size: 9pt)

#let is-journal = ("$doc_type$" == "journal" or "$is_journal$" == "true" or "$cover_show$" == "false")

#if is-journal [
  #set page(numbering: "1")
  #counter(page).update(1)

  #v(0.4cm)
  #align(center)[
    #text(size: 14pt, weight: "bold")[#title-lines]
    #v(0.5cm)
    #text(size: 11pt, weight: "bold")[
      $for(author)$$author.name$$sep$, $endfor$
    ]
    $if(institution)$
    #v(0.15cm)
    #text(size: 10pt)[$institution$]
    $endif$
    $if(email)$
    #v(0.1cm)
    #text(size: 9.5pt, font: "DejaVu Sans Mono")[$email$]
    $endif$
  ]

  #v(0.5cm)
  $if(abstract_id)$
  #block(inset: (x: 0.8cm))[
    #set par(justify: true, leading: 0.55em, first-line-indent: 0cm)
    #text(size: 10pt)[
      #strong[Abstrak] --- #emph[$abstract_id$]
    ]
    $if(keywords_id)$
    #v(0.2cm)
    #text(size: 9.5pt)[
      #strong[Kata Kunci:] #emph[$for(keywords_id)$$keywords_id$$sep$, $endfor$]
    ]
    $endif$
  ]
  #v(0.3cm)
  $endif$

  $if(abstract_en)$
  #block(inset: (x: 0.8cm))[
    #set par(justify: true, leading: 0.55em, first-line-indent: 0cm)
    #text(size: 10pt, style: "italic")[
      #strong[Abstract] --- $abstract_en$
    ]
    $if(keywords_en)$
    #v(0.2cm)
    #text(size: 9.5pt)[
      #strong[Keywords:] #emph[$for(keywords_en)$$keywords_en$$sep$, $endfor$]
    ]
    $endif$
  ]
  #v(0.5cm)
  $endif$
] else [
  #set par(justify: false, first-line-indent: 0cm)
  #v(0.5cm)
  #align(center)[
    #set par(justify: false, first-line-indent: 0cm)
    #text(size: 14pt, weight: "bold")[LAPORAN AKHIR]
    #v(0.2cm)
    #text(size: 14pt, weight: "bold")[MAGANG MANDIRI]
    #v(0.8cm)
    #text(size: 14pt, weight: "bold")[#title-lines]
    #v(0.4cm)
    #text(size: 12pt)[$if(pks_number)$$pks_number$$else$No. PKS: 015/UN63.7/PKS/2024$endif$]
  ]

  #v(1fr)
  #align(center)[
    #image("$if(logo)$$logo$$else$gambar/logo.png$endif$", width: $if(cover_logo_width)$$cover_logo_width$$else$4.5cm$endif$)
  ]
  #v(1fr)

  #align(center)[
    #set par(justify: false, first-line-indent: 0cm)
    #text(size: 12pt)[
      Diajukan untuk memenuhi persyaratan kelulusan \
      Program Magang Mandiri
    ]
    #v(0.6cm)
    #text(size: 12pt)[oleh :] \
    #v(0.2cm)
    $for(author)$
    #text(size: 12pt)[$author.name$ \/ $author.nim$]
    $endfor$
  ]

  #v(1fr)
  #align(center)[
    #set par(justify: false, first-line-indent: 0cm)
    #text(size: 14pt, weight: "bold")[PROGRAM STUDI INFORMATIKA] \
    #text(size: 14pt, weight: "bold")[FAKULTAS ILMU KOMPUTER] \
    #text(size: 14pt, weight: "bold")[UNIVERSITAS PEMBANGUNAN NASIONAL "VETERAN" JAWA TIMUR] \
    #text(size: 14pt, weight: "bold")[2026]
  ]
  #v(0.5cm)
]

#pagebreak()
#set page(numbering: "i", number-align: center + bottom)
#counter(page).update(1)

#if not is-journal [
  $if(approval)$
  #align(center)[
    #text(size: 14pt, weight: "bold")[LEMBAR PENGESAHAN]
    #v(0.8cm)
    #text(size: 12pt, weight: "bold")[#title-lines]
    #v(0.3cm)
    #text(size: 11pt)[Di PT Jawa Pos Media Televisi (JTV)]
  ]
  #v(0.5cm)
  #align(center)[
    #text(size: 11pt)[oleh :] \
    #v(0.15cm)
    $for(author)$
    #text(size: 11pt, weight: "bold")[$author.name$] #text(size: 11pt)[\/ $author.nim$] \
    $endfor$
    #v(0.3cm)
    #text(size: 11pt)[disetujui sebagai] \
    #text(size: 11pt, weight: "bold")[Laporan Magang Mandiri]
    #v(0.3cm)
    #text(size: 11pt)[$if(approval.city)$$approval.city$, $endif$$if(approval.date)$$approval.date$$else$$date$$endif$]
  ]
  #v(1.2cm)
  #grid(
    columns: (1fr, 1fr),
    gutter: 20pt,
    $for(approval.supervisors)$
    align(center)[
      #text(size: 10.5pt)[$it.role$] \
      #v(2.2cm)
      #text(size: 10.5pt, weight: "bold")[$it.name$] \
      $if(it.nip)$#text(size: 9.5pt)[NIP. $it.nip$]$endif$
    ],
    $endfor$
  )
  #pagebreak()
  $endif$
]

#let opt-daftar-gambar = $if(daftar_gambar)$$daftar_gambar$$else$$if(list_of_figures)$$list_of_figures$$else$false$endif$$endif$
#let opt-daftar-tabel = $if(daftar_tabel)$$daftar_tabel$$else$$if(list_of_tables)$$list_of_tables$$else$false$endif$$endif$

$body$