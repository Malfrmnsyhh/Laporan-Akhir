r"""
Build script resmi JIFoSI 2026:
Konversi 05-artikel-jurnal/naskah-jifosi.md ke:
  1. 05-artikel-jurnal/Artikel_JIFOSI_DataCenter_QR_ISO27001.docx
  2. 05-artikel-jurnal/Artikel-JIFOSI-2026.pdf (ekspor via Microsoft Word COM)

Menjamin:
- Header/footer resmi template/JIFOSI_Template_2026.docx (A4, margin 2 cm, 1 kolom,
  Times New Roman 11 pt spasi 1, daftar rujukan IEEE hanging indent 1,13 cm).
- 0 bug escaping \$ dan 0 italic tak sengaja dari garis bawah (_) pada identifier kode.
- Spasi di sekitar token inline code (`VPINV_` dan `VPQR_`) terjaga penuh (xml:space="preserve").
- Lebar kolom tabel eksplisit (fixed tblLayout & tblGrid) agar 0 kolom bergeser/bertumpuk.
- Operator `DB::transactionLevel() === 0` terender utuh.
- Superskrip angka 1 (¹) tampil jelas di depan baris afiliasi pertama halaman 1.
"""

import re
import struct
import subprocess
import sys
import zipfile
from pathlib import Path

import docx
from docx.enum.table import WD_ALIGN_VERTICAL, WD_TABLE_ALIGNMENT
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.oxml import OxmlElement, parse_xml
from docx.oxml.ns import nsdecls, qn
from docx.shared import Cm, Pt

BASE_DIR = Path(__file__).resolve().parent
TEMPLATE_PATH = BASE_DIR.parent / "template" / "JIFOSI_Template_2026.docx"
MD_PATH = BASE_DIR / "naskah-jifosi.md"
OUT_DOCX = BASE_DIR / "Artikel_JIFOSI_DataCenter_QR_ISO27001.docx"
OUT_PDF = BASE_DIR / "Artikel-JIFOSI-2026.pdf"

# Explicit fixed column widths (cm) summing to 17.0 cm (A4 21.0 - 2*2.0 margins)
TABLE_COL_WIDTHS_CM = {
    3: [3.6, 4.1, 9.3],                  # Tabel 1: Pemetaan Annex A ISO/IEC 27001:2022
    5: [2.7, 3.4, 1.5, 4.3, 5.1],        # Tabel 2: Spesifikasi Token Kriptografi
    4: [3.6, 9.4, 1.8, 2.2],             # Tabel 3: Hasil Pengujian Otomatis
    6: [2.7, 2.5, 2.4, 2.6, 2.6, 4.2],   # Tabel 4: Perbandingan Penelitian Terdahulu
}

# Tailored image widths / max-heights (cm) to ensure sharp readability within <= 10 pages
IMAGE_LAYOUT_RULES = {
    "01-arsitektur-visitor-pass.png": (11.0, 6.9),
    "02-flowchart-verifikasi-6-lapis.png": (11.2, 7.0),
    "03-ebadge-lifecycle-komposit.png": (15.8, 5.85),
    "04-scanner-antireplay-komposit.png": (13.8, 8.5),
}


def set_run_font(run, name="Times New Roman", size_pt=11, bold=None, italic=None, superscript=False):
    run.font.name = name
    rPr = run._r.get_or_add_rPr()
    rFonts = rPr.find(qn("w:rFonts"))
    if rFonts is None:
        rFonts = OxmlElement("w:rFonts")
        rPr.insert(0, rFonts)
    rFonts.set(qn("w:ascii"), name)
    rFonts.set(qn("w:hAnsi"), name)
    rFonts.set(qn("w:cs"), name)
    rFonts.set(qn("w:eastAsia"), name)
    if size_pt is not None:
        run.font.size = Pt(size_pt)
    if bold is not None:
        run.bold = bold
    if italic is not None:
        run.italic = italic
    if superscript:
        run.font.superscript = True
        vert = rPr.find(qn("w:vertAlign"))
        if vert is None:
            vert = OxmlElement("w:vertAlign")
            rPr.append(vert)
        vert.set(qn("w:val"), "superscript")
    # Preserve leading/trailing spaces explicitly across adjacent prose/code runs
    for t_el in run._r.findall(qn("w:t")):
        if t_el.text and (t_el.text[0].isspace() or t_el.text[-1].isspace()):
            t_el.set("{http://www.w3.org/XML/1998/namespace}space", "preserve")


def add_formatted_runs(p, text, base_size=11, base_bold=False, base_italic=False, code_font="Courier New"):
    """
    Recursive inline Markdown parser supporting:
      - `inline code` (underscores _, dollar $, operators === 0 preserved literally)
      - **bold** (including nested *italic* or `code`, and *** closing sequences)
      - *italic* (NEVER treats underscore _ as italic!)
    """
    i = 0
    n = len(text)
    buf = []

    def flush():
        if buf:
            r = p.add_run("".join(buf))
            set_run_font(r, "Times New Roman", base_size, bold=base_bold, italic=base_italic)
            buf.clear()

    while i < n:
        # Inline code: `...`
        if text[i] == "`":
            end = text.find("`", i + 1)
            if end != -1:
                flush()
                code_txt = text[i + 1:end]
                r = p.add_run(code_txt)
                code_sz = max(base_size - 2.0, 8.0)
                set_run_font(r, code_font, code_sz, bold=base_bold, italic=base_italic)
                i = end + 1
                continue

        # Bold: **...**
        if text[i:i + 2] == "**":
            end = text.find("**", i + 2)
            if end != -1:
                if text[end:end + 3] == "***":
                    end += 1
                flush()
                add_formatted_runs(
                    p,
                    text[i + 2:end],
                    base_size=base_size,
                    base_bold=True,
                    base_italic=base_italic,
                    code_font=code_font,
                )
                i = end + 2
                continue

        # Italic: *...* (single asterisk only; underscore _ is NEVER parsed as italic)
        if text[i] == "*" and text[i:i + 2] != "**":
            j = i + 1
            end = -1
            while j < n:
                if text[j] == "`":
                    c_end = text.find("`", j + 1)
                    j = (c_end + 1) if c_end != -1 else (j + 1)
                    continue
                if text[j:j + 2] == "**":
                    j += 2
                    continue
                if text[j] == "*":
                    end = j
                    break
                j += 1
            if end != -1 and end > i + 1:
                flush()
                add_formatted_runs(
                    p,
                    text[i + 1:end],
                    base_size=base_size,
                    base_bold=base_bold,
                    base_italic=True,
                    code_font=code_font,
                )
                i = end + 1
                continue

        buf.append(text[i])
        i += 1

    flush()


def clear_document_body(doc):
    """Remove all body paragraphs & tables while preserving sectPr (headers/footers/margins)."""
    body = doc.element.body
    for child in list(body):
        if child.tag != qn("w:sectPr"):
            body.remove(child)


def patch_header_xml_in_zip(docx_path: Path):
    """Patch running header placeholder text in word/header1.xml directly inside the DOCX archive."""
    tmp_path = docx_path.with_suffix(".tmp.docx")
    with zipfile.ZipFile(docx_path, "r") as zin, zipfile.ZipFile(tmp_path, "w", zipfile.ZIP_DEFLATED) as zout:
        for item in zin.infolist():
            data = zin.read(item.filename)
            if item.filename in ("word/header1.xml", "word/header2.xml"):
                xml_str = data.decode("utf-8")
                if "Nama " in xml_str and "JUDUL NASKAH" in xml_str:
                    xml_str = re.sub(
                        r"(<w:t[^>]*>)\s*Nama\s*(</w:t>)",
                        r"\1M. A. Firmansyah dkk., SISTEM MANAJEMEN IZIN AKSES FISIK PUSAT DATA\2",
                        xml_str,
                        count=1,
                    )
                    for leftover in ("Penulis", "Pertama", "Dkk", "JUDUL NASKAH", ", "):
                        xml_str = re.sub(
                            rf"(<w:t[^>]*>){re.escape(leftover)}(</w:t>)",
                            r"\1\2",
                            xml_str,
                        )
                    xml_str = re.sub(r'(<w:t xml:space="preserve">) (</w:t>)', r"\1\2", xml_str)
                    data = xml_str.encode("utf-8")
            zout.writestr(item, data)
    tmp_path.replace(docx_path)


def add_para(doc, align=WD_ALIGN_PARAGRAPH.JUSTIFY, space_before=0, space_after=2.5, line_spacing=1.0,
             left_indent=None, first_line_indent=None, keep_with_next=False):
    p = doc.add_paragraph()
    p.alignment = align
    pf = p.paragraph_format
    pf.space_before = Pt(space_before)
    pf.space_after = Pt(space_after)
    pf.line_spacing = line_spacing
    if left_indent is not None:
        pf.left_indent = Cm(left_indent)
    if first_line_indent is not None:
        pf.first_line_indent = Cm(first_line_indent)
    if keep_with_next:
        pf.keep_with_next = True
    return p


def set_cell_shading(cell, fill_hex):
    tcPr = cell._tc.get_or_add_tcPr()
    shd = parse_xml(f'<w:shd {nsdecls("w")} w:fill="{fill_hex}"/>')
    tcPr.append(shd)


def set_cell_margins(cell, top=28, bottom=28, left=68, right=68):
    tcPr = cell._tc.get_or_add_tcPr()
    tcMar = OxmlElement("w:tcMar")
    for side, val in (("top", top), ("bottom", bottom), ("left", left), ("right", right)):
        node = OxmlElement(f"w:{side}")
        node.set(qn("w:w"), str(val))
        node.set(qn("w:type"), "dxa")
        tcMar.append(node)
    tcPr.append(tcMar)


def set_cell_width_dxa(cell, dxa: int):
    tcPr = cell._tc.get_or_add_tcPr()
    for old in tcPr.findall(qn("w:tcW")):
        tcPr.remove(old)
    tcW = OxmlElement("w:tcW")
    tcW.set(qn("w:w"), str(dxa))
    tcW.set(qn("w:type"), "dxa")
    tcPr.append(tcW)


def style_academic_table(table, col_widths_cm):
    """Apply clean JIFoSI academic borders, fixed column widths, header repeat, cantSplit, and subtle shading."""
    table.alignment = WD_TABLE_ALIGNMENT.CENTER
    table.autofit = False
    tblPr = table._tbl.tblPr

    for tag in ("w:tblBorders", "w:tblLayout", "w:tblW"):
        for old in tblPr.findall(qn(tag)):
            tblPr.remove(old)

    dxa_widths = [int(round(w * 566.929)) for w in col_widths_cm]
    total_dxa = sum(dxa_widths)

    tblW = OxmlElement("w:tblW")
    tblW.set(qn("w:w"), str(total_dxa))
    tblW.set(qn("w:type"), "dxa")
    tblPr.append(tblW)

    tblLayout = OxmlElement("w:tblLayout")
    tblLayout.set(qn("w:type"), "fixed")
    tblPr.append(tblLayout)

    borders = parse_xml(
        f'<w:tblBorders {nsdecls("w")}>'
        '  <w:top w:val="single" w:sz="8" w:space="0" w:color="1E293B"/>'
        '  <w:bottom w:val="single" w:sz="8" w:space="0" w:color="1E293B"/>'
        '  <w:left w:val="none" w:sz="0" w:space="0" w:color="auto"/>'
        '  <w:right w:val="none" w:sz="0" w:space="0" w:color="auto"/>'
        '  <w:insideH w:val="single" w:sz="4" w:space="0" w:color="CBD5E1"/>'
        '  <w:insideV w:val="none" w:sz="0" w:space="0" w:color="auto"/>'
        '</w:tblBorders>'
    )
    tblPr.append(borders)

    # Set explicit tblGrid column widths so Word never shifts columns
    old_grid = table._tbl.find(qn("w:tblGrid"))
    if old_grid is not None:
        table._tbl.remove(old_grid)
    tblGrid = OxmlElement("w:tblGrid")
    for w_dxa in dxa_widths:
        gc = OxmlElement("w:gridCol")
        gc.set(qn("w:w"), str(w_dxa))
        tblGrid.append(gc)
    tblPr.addnext(tblGrid)

    for r_idx, row in enumerate(table.rows):
        trPr = row._tr.get_or_add_trPr()
        trPr.append(OxmlElement("w:cantSplit"))
        if r_idx == 0:
            trPr.append(OxmlElement("w:tblHeader"))
        for c_idx, cell in enumerate(row.cells):
            set_cell_width_dxa(cell, dxa_widths[c_idx])
            cell.vertical_alignment = WD_ALIGN_VERTICAL.CENTER
            set_cell_margins(cell)
            if r_idx == 0:
                set_cell_shading(cell, "EFF6FF")
                tcPr = cell._tc.get_or_add_tcPr()
                tcPr.append(parse_xml(
                    f'<w:tcBorders {nsdecls("w")}>'
                    '  <w:bottom w:val="single" w:sz="6" w:space="0" w:color="1E293B"/>'
                    '</w:tcBorders>'
                ))
            elif r_idx % 2 == 0:
                set_cell_shading(cell, "F8FAFC")


def get_png_size(img_path: Path):
    with open(img_path, "rb") as f:
        f.read(16)
        return struct.unpack(">II", f.read(8))


def verify_docx_integrity(docx_path: Path):
    """Run strict automated checks on the generated DOCX XML before PDF export."""
    d = docx.Document(str(docx_path))
    all_texts = [p.text for p in d.paragraphs]
    for tbl in d.tables:
        for row in tbl.rows:
            for cell in row.cells:
                all_texts.append(cell.text)
    full = "\n".join(all_texts)

    errors = []
    if r"\$" in full:
        errors.append("Found escaped \\$ in DOCX text")
    if "**" in full:
        errors.append("Found unparsed ** in DOCX text")
    if "VPINV_dan" in full or "VPQR_dan" in full:
        errors.append("Lost space around VPINV_ / VPQR_")
    if "DB::transactionLevel() === 0" not in full:
        errors.append("Missing literal DB::transactionLevel() === 0")
    for expected in ("$hidden", "$attemptedHash", "$this->travelTo()", "VPINV_ dan VPQR_"):
        if expected not in full:
            errors.append(f"Missing expected literal token: {expected}")

    # Verify Affiliation 1 has explicit superscript "1" run
    aff1 = [p for p in d.paragraphs if "Program Studi Informatika" in p.text]
    if not aff1 or not aff1[0].runs or aff1[0].runs[0].text != "1" or not aff1[0].runs[0].font.superscript:
        errors.append("Affiliation 1 missing explicit superscript '1' run")

    if errors:
        raise RuntimeError("DOCX integrity check failed:\n - " + "\n - ".join(errors))
    print("DOCX integrity self-check: ALL PASSED (0 \\$, 0 **, === 0 intact, VPINV_/VPQR_ spaced, aff1 sup '1' OK)")


def export_pdf_via_word_com(docx_path: Path, pdf_path: Path):
    """Export DOCX to PDF via Microsoft Word COM using PowerShell (no pywin32 dependency)."""
    ps_script = (
        "$ErrorActionPreference = 'Stop'; "
        "$word = New-Object -ComObject Word.Application; "
        "$word.Visible = $false; "
        "$word.DisplayAlerts = 0; "
        "try { "
        f"  $doc = $word.Documents.Open('{str(docx_path)}', $false, $true); "
        f"  $doc.ExportAsFixedFormat('{str(pdf_path)}', 17, $false, 0, 0, 1, 1, 0, $true, $true, 1, $true, $true, $false); "
        "  $doc.Close([ref]$false); "
        "} finally { "
        "  $word.Quit([ref]$false); "
        "  [System.Runtime.Interopservices.Marshal]::ReleaseComObject($word) | Out-Null; "
        "}"
    )
    res = subprocess.run(
        ["powershell", "-NoProfile", "-Command", ps_script],
        capture_output=True,
        text=True,
        check=False,
    )
    if res.returncode != 0:
        raise RuntimeError(f"Word COM PDF export failed:\nSTDOUT: {res.stdout}\nSTDERR: {res.stderr}")
    print(f"Exported PDF: {pdf_path} ({pdf_path.stat().st_size:,} bytes)")


def build(export_pdf: bool = True):
    doc = docx.Document(str(TEMPLATE_PATH))
    clear_document_body(doc)

    normal = doc.styles["Normal"]
    normal.font.name = "Times New Roman"
    normal.font.size = Pt(11)

    lines = MD_PATH.read_text(encoding="utf-8").splitlines()
    i = 0
    in_english_abstract = False
    in_references = False

    while i < len(lines):
        raw = lines[i].rstrip()
        stripped = raw.strip()

        if not stripped or stripped == "---":
            i += 1
            continue

        # 1. Main Title (H1)
        if stripped.startswith("# ") and not stripped.startswith("## "):
            title_text = stripped[2:].strip()
            p = add_para(doc, align=WD_ALIGN_PARAGRAPH.JUSTIFY, space_before=2, space_after=2, line_spacing=1.0)
            add_formatted_runs(p, title_text, base_size=14, base_bold=True, base_italic=False)
            i += 1
            continue

        # 2. Author line (*¹Nama ..., ²..., ³...)
        if stripped.startswith("*¹"):
            auth_text = stripped[:-1] if stripped.endswith("*") else stripped
            p = add_para(doc, align=WD_ALIGN_PARAGRAPH.JUSTIFY, space_before=1.5, space_after=1.5, line_spacing=1.0,
                         first_line_indent=0.50)
            parts = re.split(r"(\*¹|²|³)", auth_text)
            for part in parts:
                if not part:
                    continue
                if part == "*¹":
                    r1 = p.add_run("*")
                    set_run_font(r1, "Times New Roman", 12, bold=True)
                    r2 = p.add_run("1")
                    set_run_font(r2, "Times New Roman", 12, bold=True, superscript=True)
                elif part in ("²", "³"):
                    num = "2" if part == "²" else "3"
                    r = p.add_run(num)
                    set_run_font(r, "Times New Roman", 12, bold=True, superscript=True)
                else:
                    r = p.add_run(part)
                    set_run_font(r, "Times New Roman", 12, bold=True)
            i += 1
            continue

        # 3. Affiliation lines (explicit superscript 1/2/3 in front of each affiliation)
        if stripped[:1] in ("¹", "²", "³"):
            sup_num = {"¹": "1", "²": "2", "³": "3"}[stripped[0]]
            rest = stripped[1:].strip()
            p = add_para(doc, align=WD_ALIGN_PARAGRAPH.JUSTIFY, space_before=0, space_after=0.5, line_spacing=1.0,
                         left_indent=0.50)
            r_sup = p.add_run(sup_num)
            set_run_font(r_sup, "Times New Roman", 12, bold=False, superscript=True)
            r_txt = p.add_run(rest)
            set_run_font(r_txt, "Times New Roman", 12, bold=False)
            i += 1
            continue

        # 4. Metadata lines
        if stripped.startswith("DOI:") or stripped.startswith("*Corresponding Author:") or stripped.startswith("Submit:"):
            p = add_para(doc, align=WD_ALIGN_PARAGRAPH.JUSTIFY, space_before=(2 if stripped.startswith("DOI:") else 0),
                         space_after=(2 if stripped.startswith("Submit:") else 0.5), line_spacing=1.0)
            r = p.add_run(stripped.rstrip("*"))
            set_run_font(r, "Times New Roman", 11, bold=False)
            i += 1
            continue

        # 5. Level-2 Headings
        if stripped.startswith("## "):
            h2 = stripped[3:].strip()
            if h2.startswith("*") and h2.endswith("*") and "ABSTRACT" not in h2:
                p = add_para(doc, align=WD_ALIGN_PARAGRAPH.JUSTIFY, space_before=3, space_after=2, line_spacing=1.0,
                             keep_with_next=True)
                add_formatted_runs(p, h2.strip("*"), base_size=14, base_bold=True, base_italic=True)
                in_english_abstract = True
            elif h2.strip("*") == "ABSTRACT":
                p = add_para(doc, align=WD_ALIGN_PARAGRAPH.JUSTIFY, space_before=2, space_after=1.5, line_spacing=1.0,
                             keep_with_next=True)
                r = p.add_run("ABSTRACT")
                set_run_font(r, "Times New Roman", 11, bold=True, italic=True)
                in_english_abstract = True
            else:
                in_english_abstract = False
                in_references = (h2 == "DAFTAR RUJUKAN")
                p = add_para(doc, align=WD_ALIGN_PARAGRAPH.JUSTIFY, space_before=(3 if h2 == "ABSTRAK" else 6),
                             space_after=2, line_spacing=1.0, keep_with_next=True)
                r = p.add_run(h2)
                set_run_font(r, "Times New Roman", 11, bold=True)
            i += 1
            continue

        # 6. Level-3 Subheadings
        if stripped.startswith("### "):
            h3 = stripped[4:].strip()
            p = add_para(doc, align=WD_ALIGN_PARAGRAPH.LEFT, space_before=4.5, space_after=2, line_spacing=1.0,
                         keep_with_next=True)
            add_formatted_runs(p, h3, base_size=11, base_bold=True, base_italic=False)
            i += 1
            continue

        # 7. Image line ![alt](path)
        img_m = re.match(r"^!\[(.*?)\]\((.*?)\)$", stripped)
        if img_m:
            rel_path = img_m.group(2).strip()
            img_path = BASE_DIR / rel_path
            if not img_path.exists():
                raise FileNotFoundError(f"Missing referenced figure: {img_path}")
            pw, ph = get_png_size(img_path)
            ratio = pw / ph if ph else 1.5
            max_w_cm, max_h_cm = IMAGE_LAYOUT_RULES.get(img_path.name, (14.0, 8.0))
            target_w = max_w_cm
            target_h = target_w / ratio
            if target_h > max_h_cm:
                target_h = max_h_cm
                target_w = target_h * ratio
            p = add_para(doc, align=WD_ALIGN_PARAGRAPH.CENTER, space_before=3, space_after=1.5,
                         line_spacing=1.0, keep_with_next=True)
            p.add_run().add_picture(str(img_path), width=Cm(target_w))
            i += 1
            continue

        # 8. Figure caption
        if stripped.startswith("**Gambar ") and stripped.endswith("**"):
            cap = stripped[2:-2].strip()
            p = add_para(doc, align=WD_ALIGN_PARAGRAPH.CENTER, space_before=1, space_after=5, line_spacing=1.0)
            add_formatted_runs(p, cap, base_size=10.5, base_bold=True, base_italic=False)
            i += 1
            continue

        # 9. Table caption
        if stripped.startswith("**Tabel ") and stripped.endswith("**"):
            cap = stripped[2:-2].strip()
            p = add_para(doc, align=WD_ALIGN_PARAGRAPH.CENTER, space_before=5, space_after=2,
                         line_spacing=1.0, keep_with_next=True)
            add_formatted_runs(p, cap, base_size=10.5, base_bold=True, base_italic=False)
            i += 1
            continue

        # 10. Markdown Table block
        if stripped.startswith("|") and stripped.endswith("|"):
            tbl_lines = []
            while i < len(lines) and lines[i].strip().startswith("|") and lines[i].strip().endswith("|"):
                tbl_lines.append(lines[i].strip())
                i += 1
            if len(tbl_lines) >= 2:
                headers = [c.strip() for c in tbl_lines[0].strip("|").split("|")]
                align_cells = [c.strip() for c in tbl_lines[1].strip("|").split("|")]
                col_aligns = []
                for ac in align_cells:
                    if ac.startswith(":") and ac.endswith(":"):
                        col_aligns.append(WD_ALIGN_PARAGRAPH.CENTER)
                    elif ac.endswith(":"):
                        col_aligns.append(WD_ALIGN_PARAGRAPH.RIGHT)
                    else:
                        col_aligns.append(WD_ALIGN_PARAGRAPH.LEFT)
                data_rows = [[c.strip() for c in row_line.strip("|").split("|")] for row_line in tbl_lines[2:]]
                for r_idx, r_data in enumerate(data_rows):
                    if len(r_data) != len(headers):
                        raise ValueError(f"Table row {r_idx + 1} has {len(r_data)} cols, expected {len(headers)}: {r_data}")

                ncols = len(headers)
                col_widths = TABLE_COL_WIDTHS_CM.get(ncols, [round(17.0 / ncols, 2)] * ncols)
                table = doc.add_table(rows=1 + len(data_rows), cols=ncols)
                for c_idx, h_txt in enumerate(headers):
                    cell = table.rows[0].cells[c_idx]
                    p = cell.paragraphs[0]
                    p.alignment = col_aligns[c_idx] if c_idx < len(col_aligns) else WD_ALIGN_PARAGRAPH.LEFT
                    p.paragraph_format.space_before = Pt(1)
                    p.paragraph_format.space_after = Pt(1)
                    p.paragraph_format.line_spacing = 1.0
                    add_formatted_runs(p, h_txt, base_size=9.5, base_bold=True)

                for r_idx, r_data in enumerate(data_rows):
                    for c_idx, val in enumerate(r_data):
                        cell = table.rows[r_idx + 1].cells[c_idx]
                        p = cell.paragraphs[0]
                        p.alignment = col_aligns[c_idx] if c_idx < len(col_aligns) else WD_ALIGN_PARAGRAPH.LEFT
                        p.paragraph_format.space_before = Pt(1)
                        p.paragraph_format.space_after = Pt(1)
                        p.paragraph_format.line_spacing = 1.0
                        add_formatted_runs(p, val, base_size=8.8 if ncols >= 5 else 9.0, base_bold=False)

                style_academic_table(table, col_widths)
                sp_p = add_para(doc, space_before=0, space_after=1, line_spacing=1.0)
                set_run_font(sp_p.add_run(""), "Times New Roman", 3)
            continue

        # 11. References ([n] ...)
        if in_references and re.match(r"^\[\d+\]\s+", stripped):
            m = re.match(r"^(\[\d+\])\s+(.*)$", stripped)
            num_lbl, ref_body = m.group(1), m.group(2)
            p = add_para(doc, align=WD_ALIGN_PARAGRAPH.JUSTIFY, space_before=0, space_after=0.3,
                         line_spacing=1.0, left_indent=1.13, first_line_indent=-1.13)
            r_num = p.add_run(num_lbl + "\t")
            set_run_font(r_num, "Times New Roman", 11, bold=False)
            add_formatted_runs(p, ref_body, base_size=11, base_bold=False, base_italic=False)
            i += 1
            continue

        # 12. Numbered list items
        num_m = re.match(r"^(\d+\.)\s+(.*)$", stripped)
        if num_m:
            num_lbl, body_txt = num_m.group(1), num_m.group(2)
            p = add_para(doc, align=WD_ALIGN_PARAGRAPH.JUSTIFY, space_before=0, space_after=1.2,
                         line_spacing=1.0, left_indent=0.65, first_line_indent=-0.65)
            r_num = p.add_run(num_lbl + "\t")
            set_run_font(r_num, "Times New Roman", 11, bold=False)
            add_formatted_runs(p, body_txt, base_size=11, base_bold=False, base_italic=False)
            i += 1
            continue

        # 13. Kata Kunci / Keywords
        if stripped.startswith("Kata Kunci:"):
            p = add_para(doc, align=WD_ALIGN_PARAGRAPH.JUSTIFY, space_before=1.5, space_after=3, line_spacing=1.0)
            r_lbl = p.add_run("Kata Kunci: ")
            set_run_font(r_lbl, "Times New Roman", 11, bold=True)
            add_formatted_runs(p, stripped[len("Kata Kunci:"):].strip(), base_size=11, base_bold=False)
            i += 1
            continue

        if stripped.startswith("*Keywords:"):
            p = add_para(doc, align=WD_ALIGN_PARAGRAPH.JUSTIFY, space_before=1.5, space_after=4, line_spacing=1.0)
            kw_body = stripped.strip("*")[len("Keywords:"):].strip()
            r_lbl = p.add_run("Keywords: ")
            set_run_font(r_lbl, "Times New Roman", 11, bold=True, italic=True)
            add_formatted_runs(p, kw_body, base_size=11, base_bold=False, base_italic=True)
            in_english_abstract = False
            i += 1
            continue

        # 14. Body paragraph / English abstract
        if in_english_abstract and stripped.startswith("*") and stripped.endswith("*"):
            p = add_para(doc, align=WD_ALIGN_PARAGRAPH.JUSTIFY, space_before=0, space_after=1.5, line_spacing=1.0)
            add_formatted_runs(p, stripped[1:-1], base_size=11, base_bold=False, base_italic=True)
        else:
            p = add_para(doc, align=WD_ALIGN_PARAGRAPH.JUSTIFY, space_before=0, space_after=1.8, line_spacing=1.0)
            add_formatted_runs(p, stripped, base_size=11, base_bold=False, base_italic=False)
        i += 1

    doc.save(str(OUT_DOCX))
    patch_header_xml_in_zip(OUT_DOCX)
    print(f"Saved DOCX: {OUT_DOCX} ({OUT_DOCX.stat().st_size:,} bytes)")
    verify_docx_integrity(OUT_DOCX)

    if export_pdf:
        export_pdf_via_word_com(OUT_DOCX, OUT_PDF)


if __name__ == "__main__":
    no_pdf = "--no-pdf" in sys.argv
    build(export_pdf=not no_pdf)
