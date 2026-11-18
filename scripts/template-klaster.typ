// Template Typst Pandoc untuk Catatan Bedah Klaster (Standar UPN 'Veteran' Jawa Timur)
#set page(
  paper: "a4",
  margin: (top: 2.54cm, bottom: 2.54cm, left: 2.54cm, right: 2.54cm),
  numbering: "1",
)

#set text(
  font: "Times New Roman",
  size: 12pt,
  lang: "id",
  region: "ID",
)

#set par(
  justify: true,
  leading: 0.75em,
  first-line-indent: 1.27cm,
)

#show raw: set text(font: "Consolas", size: 10pt)
#show raw.where(block: true): it => block(
  fill: rgb("#f8fafc"),
  stroke: 0.5pt + rgb("#cbd5e1"),
  inset: 8pt,
  radius: 4pt,
  width: 100%,
  it
)

#show heading.where(level: 1): it => {
  set align(center)
  set text(font: "Times New Roman", size: 14pt, weight: "bold")
  block(above: 18pt, below: 12pt)[#upper(it.body)]
}

#show heading.where(level: 2): it => {
  set text(font: "Times New Roman", size: 12pt, weight: "bold")
  block(above: 14pt, below: 6pt)[#it.body]
}

#show heading.where(level: 3): it => {
  set text(font: "Times New Roman", size: 12pt, weight: "bold", style: "italic")
  block(above: 10pt, below: 4pt)[#it.body]
}

#show figure.where(kind: image): set figure(supplement: [Gambar])
#show figure.where(kind: image): set figure.caption(position: bottom)
#show figure.where(kind: table): set figure(supplement: [Tabel])
#show figure.where(kind: table): set figure.caption(position: top)
#show figure.caption: it => text(font: "Times New Roman", size: 10pt, style: "italic")[#it]

$body$
