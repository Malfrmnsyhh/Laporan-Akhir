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
#let doc-margin = (top: 2.5cm, bottom: 2.5cm, left: 2.5cm, right: 2.5cm)
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
#set par(justify: true, leading: $line_spacing$, spacing: 0.85em, first-line-indent: $if(first_line_indent)$$first_line_indent$$else$0cm$endif$)
$else$
#set par(justify: true, leading: 0.65em, spacing: 0.85em, first-line-indent: 0cm)
$endif$

#let chapter-prefix = "BAB "
#set heading(numbering: (..ns) => {
  if ns.len() == 1 {
    chapter-prefix + numbering("I", ns.at(0))
  } else if ns.len() == 2 {
    str(ns.at(0)) + "." + str(ns.at(1))
  } else {
    str(ns.at(0)) + "." + str(ns.at(1)) + "." + str(ns.at(2))
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

#show heading.where(level: 1): it => [
  #counter(figure.where(kind: image)).update(0)
  #counter(figure.where(kind: table)).update(0)
  #pagebreak(weak: true)
  #align(center)[
    #block(inset: (top: 0.3em, bottom: 1.4em))[
      #text(size: 14pt, weight: "bold")[
        #if it.numbering != none [
          #(chapter-prefix + numbering("I", counter(heading).get().at(0)))
          #linebreak()
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
  block(above: 1.1em, below: 0.45em, sticky: true)[
    #text(size: 12pt, weight: "bold")[#it]
  ]
}

#show heading.where(level: 3): it => {
  block(above: 0.85em, below: 0.35em, sticky: true)[
    #text(size: 11.5pt, weight: "bold")[#it]
  ]
}

#show figure: it => {
  v(0.35em)
  it
  v(0.35em)
}
#show figure.caption: set text(size: 10pt, style: "italic")
#set figure.caption(position: bottom)

#show quote: it => {
  block(
    fill: rgb("#FFF8EB"),
    stroke: (left: 3.5pt + rgb("#FF6C00")),
    inset: (x: 12pt, y: 9pt),
    radius: (right: 4pt),
    width: 100%,
  )[
    #set text(size: 10.5pt)
    #set par(justify: false, leading: 0.6em, first-line-indent: 0pt)
    #it.body
  ]
}

#show raw.where(block: true): it => {
  block(
    fill: rgb("#F6F8FA"),
    stroke: 0.6pt + rgb("#D0D7DE"),
    inset: (x: 9pt, y: 7pt),
    radius: 4pt,
    width: 100%,
    breakable: true,
  )[
    #set text(font: ("Consolas", "DejaVu Sans Mono", "Courier New"), size: 8.5pt, hyphenate: false)
    #set par(justify: false, leading: 0.48em, spacing: 0.48em, first-line-indent: 0pt)
    #it
  ]
}

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
}
#show table.header: set text(weight: "bold")
#show figure.where(kind: table): set block(breakable: true)

#show outline.entry.where(level: 1): set text(weight: "bold")

// =========================================================================
// HALAMAN 1: SAMPUL GRAFIS FULL-BLEED A4 (MARGIN 0cm, TANPA NOMOR HALAMAN)
// =========================================================================
#page(margin: 0cm, numbering: none)[
  #image("$if(cover_image)$$cover_image$$else$gambar/cover-buku-panduan.png$endif$", width: 100%, height: 100%, fit: "cover")
]

$body$
