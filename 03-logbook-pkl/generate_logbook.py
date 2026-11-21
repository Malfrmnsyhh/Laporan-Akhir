import os
import re
import docx
from docx.shared import Inches, Pt, Cm, Mm
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.oxml import OxmlElement
from docx.oxml.ns import qn, nsdecls
from docx.oxml import parse_xml

def add_cant_split(row):
    trPr = row._tr.get_or_add_trPr()
    if trPr.find(qn('w:cantSplit')) is None:
        trPr.append(parse_xml(r'<w:cantSplit xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"/>'))

def add_tbl_header(row):
    trPr = row._tr.get_or_add_trPr()
    if trPr.find(qn('w:tblHeader')) is None:
        trPr.append(parse_xml(r'<w:tblHeader xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"/>'))

def set_cell_width(cell, dxa_width):
    tcPr = cell._tc.get_or_add_tcPr()
    tcW = tcPr.find(qn('w:tcW'))
    if tcW is None:
        tcW = OxmlElement('w:tcW')
        tcPr.append(tcW)
    tcW.set(qn('w:w'), str(dxa_width))
    tcW.set(qn('w:type'), 'dxa')

def set_run_font(run, font_name="Arial", size_pt=12, bold=False):
    run.font.name = font_name
    run.font.size = Pt(size_pt)
    run.font.bold = bold
    # Ensure XML has w:rFonts
    rPr = run._r.get_or_add_rPr()
    rFonts = rPr.find(qn('w:rFonts'))
    if rFonts is None:
        rFonts = OxmlElement('w:rFonts')
        rPr.append(rFonts)
    rFonts.set(qn('w:ascii'), font_name)
    rFonts.set(qn('w:hAnsi'), font_name)
    rFonts.set(qn('w:cs'), font_name)

def parse_markdown_logbook(md_path):
    with open(md_path, 'r', encoding='utf-8') as f:
        content = f.read()

    rows = []
    post_table_lines = []
    in_table = False
    table_ended = False

    for line in content.splitlines():
        line_s = line.strip()
        if line_s.startswith('|'):
            if ':---' in line_s or '---:' in line_s or '---|---' in line_s:
                in_table = True
                continue
            parts = [p.strip() for p in line.split('|')]
            # Parts will have empty string at start and end if line starts and ends with |
            if len(parts) >= 6:
                cols = parts[1:5]
            elif len(parts) == 5:
                cols = parts[1:5]
            else:
                continue

            if cols[0] == 'Bulan' and cols[1] == 'Minggu':
                continue

            rows.append({
                'bulan': cols[0],
                'minggu': cols[1],
                'tanggal': cols[2],
                'kegiatan': cols[3]
            })
        else:
            if in_table and len(rows) > 0:
                table_ended = True
            if table_ended and line_s:
                post_table_lines.append(line_s)

    return rows, post_table_lines

def generate_docx(template_docx, md_path, out_docx):
    rows_data, post_table_lines = parse_markdown_logbook(md_path)
    print(f"Parsed {len(rows_data)} rows and {len(post_table_lines)} post-table lines from {md_path}")

    doc = docx.Document(template_docx)
    table = doc.tables[0]

    # Ensure row 0 has tblHeader and cantSplit
    header_row = table.rows[0]
    add_tbl_header(header_row)
    add_cant_split(header_row)

    # Remove all data rows after header
    for tr in table._tbl.xpath('./w:tr[position() > 1]'):
        table._tbl.remove(tr)

    print(f"Cleared existing data rows. Populating {len(rows_data)} rows...")

    col_widths = [1696, 1570, 1691, 5533]

    for idx, r in enumerate(rows_data, 1):
        row = table.add_row()
        add_cant_split(row)

        cells = row.cells
        for c_i, w in enumerate(col_widths):
            set_cell_width(cells[c_i], w)

        # Cell 0: Bulan (Center)
        p0 = cells[0].paragraphs[0]
        p0.alignment = WD_ALIGN_PARAGRAPH.CENTER
        p0.paragraph_format.space_before = Pt(0)
        p0.paragraph_format.space_after = Pt(0)
        p0.paragraph_format.line_spacing = 1.0
        run0 = p0.add_run(r['bulan'])
        set_run_font(run0, "Arial", 12, bold=False)

        # Cell 1: Minggu (Center)
        p1 = cells[1].paragraphs[0]
        p1.alignment = WD_ALIGN_PARAGRAPH.CENTER
        p1.paragraph_format.space_before = Pt(0)
        p1.paragraph_format.space_after = Pt(0)
        p1.paragraph_format.line_spacing = 1.0
        run1 = p1.add_run(r['minggu'])
        set_run_font(run1, "Arial", 12, bold=False)

        # Cell 2: Tanggal (Left)
        p2 = cells[2].paragraphs[0]
        p2.alignment = WD_ALIGN_PARAGRAPH.LEFT
        p2.paragraph_format.space_before = Pt(0)
        p2.paragraph_format.space_after = Pt(0)
        p2.paragraph_format.line_spacing = 1.0
        run2 = p2.add_run(r['tanggal'])
        set_run_font(run2, "Arial", 12, bold=False)

        # Cell 3: Kegiatan (Justify)
        keg_raw = r['kegiatan']
        # Handle <br/> and newlines
        parts = keg_raw.replace('<br/>', '\n').replace('<br>', '\n').split('\n')
        
        for p_idx, text_part in enumerate(parts):
            if p_idx == 0:
                p3 = cells[3].paragraphs[0]
            else:
                p3 = cells[3].add_paragraph()
            p3.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY
            p3.paragraph_format.space_before = Pt(0)
            p3.paragraph_format.space_after = Pt(0)
            p3.paragraph_format.line_spacing = 1.0
            run3 = p3.add_run(text_part.strip())
            set_run_font(run3, "Arial", 12, bold=False)

    # Clean up any trailing paragraphs after table from template
    tbl_element = table._tbl
    parent = tbl_element.getparent()
    found_tbl = False
    to_remove = []
    for ch in parent:
        if ch == tbl_element:
            found_tbl = True
            continue
        if found_tbl and ch.tag.endswith('p'):
            to_remove.append(ch)
    for ch in to_remove:
        parent.remove(ch)

    # Render post-table notes (Catatan ekivalensi SKS)
    if post_table_lines:
        print(f"Adding post-table notes: {post_table_lines}")
        for idx, line_text in enumerate(post_table_lines):
            p = doc.add_paragraph()
            p.alignment = WD_ALIGN_PARAGRAPH.LEFT
            p.paragraph_format.line_spacing = 1.0

            # Distance from bottom border of table: approx 12 pt for first paragraph
            if idx == 0:
                p.paragraph_format.space_before = Pt(12)
                p.paragraph_format.space_after = Pt(6)
            else:
                p.paragraph_format.space_before = Pt(0)
                p.paragraph_format.space_after = Pt(2)

            # Keep note lines together
            p.paragraph_format.keep_with_next = (idx < len(post_table_lines) - 1)

            # Bold for 'Catatan' header, regular for description
            is_bold = (line_text.strip().lower() == 'catatan')
            run = p.add_run(line_text)
            set_run_font(run, "Arial", 12, bold=is_bold)

    doc.save(out_docx)
    print(f"Successfully generated {out_docx} with {len(table.rows)} rows (including header) and {len(post_table_lines)} note lines.")

if __name__ == '__main__':
    base_dir = r'd:\website\MSDC\laporan_akhir\03-logbook-pkl'
    template_docx = os.path.join(base_dir, 'LOGBOOK KEGIATAN PLK.docx')
    md_path = os.path.join(base_dir, 'chapters', 'logbook.md')
    out_docx = os.path.join(base_dir, 'Logbook_Kegiatan_PLK.docx')

    generate_docx(template_docx, md_path, out_docx)
