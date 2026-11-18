#!/usr/bin/env python3
"""
[DEPRECATED / DIPENSIUNKAN]
Skrip ini telah dipensiunkan dan digantikan oleh engine MenulisCep4t (Typst + Pandoc Multi-Pass)
yang terintegrasi langsung di masing-masing sub-folder dokumen:
- 01-laporan-magang/laporan.ps1
- 02-laporan-pkl/laporan.ps1
Atau melalui:
- npm run build:magang
- npm run build:pkl
- npm run build:all
"""

import os
import sys
import glob
import re
from docx import Document
from docx.shared import Inches, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT, WD_ALIGN_VERTICAL
from docx.oxml import OxmlElement, parse_xml
from docx.oxml.ns import nsdecls, qn

ROOT_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
TEMPLATE_DIR = os.path.join(ROOT_DIR, "template")
DIAGRAMS_DIR = os.path.join(ROOT_DIR, "diagrams", "rendered")

def find_template():
    docx_files = glob.glob(os.path.join(TEMPLATE_DIR, "*.docx"))
    if docx_files:
        # Pilih template pertama yang tidak berawalan ~$ (lock file Word)
        for f in docx_files:
            if not os.path.basename(f).startswith("~$"):
                return f
    return None

def set_academic_margins(doc):
    """Standar margin skripsi/PKL Indonesia: Kiri 4cm, Atas 4cm, Kanan 3cm, Bawah 3cm"""
    for section in doc.sections:
        section.top_margin = Inches(1.57)      # 4 cm
        section.bottom_margin = Inches(1.18)   # 3 cm
        section.left_margin = Inches(1.57)     # 4 cm
        section.right_margin = Inches(1.18)    # 3 cm
        section.page_width = Inches(8.27)      # A4
        section.page_height = Inches(11.69)    # A4

def set_base_styles(doc):
    styles = doc.styles
    normal_style = styles['Normal']
    font = normal_style.font
    font.name = 'Times New Roman'
    font.size = Pt(12)
    font.color.rgb = RGBColor(0, 0, 0)
    normal_style.paragraph_format.line_spacing = 1.5
    normal_style.paragraph_format.space_after = Pt(6)
    normal_style.paragraph_format.space_before = Pt(0)

def add_styled_heading(doc, text, level):
    # Jika Heading 1 dan bukan halaman pertama, beri page break
    if level == 1 and len(doc.paragraphs) > 1:
        doc.add_page_break()

    p = doc.add_paragraph()
    p.paragraph_format.keep_with_next = True
    run = p.add_run(text)
    run.font.name = 'Times New Roman'
    run.bold = True

    if level == 1:
        p.alignment = WD_ALIGN_PARAGRAPH.CENTER
        run.font.size = Pt(14)
        p.paragraph_format.space_before = Pt(12)
        p.paragraph_format.space_after = Pt(12)
    elif level == 2:
        p.alignment = WD_ALIGN_PARAGRAPH.LEFT
        run.font.size = Pt(12)
        p.paragraph_format.space_before = Pt(10)
        p.paragraph_format.space_after = Pt(4)
    elif level == 3:
        p.alignment = WD_ALIGN_PARAGRAPH.LEFT
        run.font.size = Pt(12)
        run.italic = True
        p.paragraph_format.space_before = Pt(8)
        p.paragraph_format.space_after = Pt(2)
    else:
        p.alignment = WD_ALIGN_PARAGRAPH.LEFT
        run.font.size = Pt(11)
        p.paragraph_format.space_before = Pt(6)
        p.paragraph_format.space_after = Pt(2)

def add_formatted_paragraph(doc, text):
    p = doc.add_paragraph()
    p.paragraph_format.line_spacing = 1.5
    p.paragraph_format.space_after = Pt(6)

    # Tokenisasi inline bold **text**, italic *text*, dan code `text`
    tokens = re.split(r'(\*\*.*?\*\*|\*.*?\*|`.*?`)', text)
    for token in tokens:
        if not token:
            continue
        if token.startswith('**') and token.endswith('**') and len(token) >= 4:
            run = p.add_run(token[2:-2])
            run.bold = True
        elif token.startswith('*') and token.endswith('*') and len(token) >= 2:
            run = p.add_run(token[1:-1])
            run.italic = True
        elif token.startswith('`') and token.endswith('`') and len(token) >= 2:
            run = p.add_run(token[1:-1])
            run.font.name = 'Consolas'
            run.font.size = Pt(10)
            run.font.color.rgb = RGBColor(180, 50, 50)
        else:
            p.add_run(token)

def add_markdown_table(doc, table_lines):
    rows_data = []
    for line in table_lines:
        line_clean = line.strip()
        if not line_clean.startswith('|') or not line_clean.endswith('|'):
            continue
        # Abaikan separator line |---|---|
        if re.match(r'^\|[\s\:\-\|]+\|$', line_clean):
            continue
        cells = [c.strip() for c in line_clean.split('|')[1:-1]]
        rows_data.append(cells)

    if not rows_data:
        return

    num_cols = max(len(r) for r in rows_data)
    table = doc.add_table(rows=len(rows_data), cols=num_cols)
    table.alignment = WD_TABLE_ALIGNMENT.CENTER
    table.autofit = True

    for row_idx, row in enumerate(rows_data):
        for col_idx in range(num_cols):
            cell_val = row[col_idx] if col_idx < len(row) else ""
            cell = table.cell(row_idx, col_idx)
            cell.text = cell_val
            p = cell.paragraphs[0]
            p.paragraph_format.line_spacing = 1.15
            p.paragraph_format.space_after = Pt(2)
            p.paragraph_format.space_before = Pt(2)

            for run in p.runs:
                run.font.name = 'Times New Roman'
                run.font.size = Pt(10)
                if row_idx == 0:
                    run.bold = True

            # Header shading (Abu-abu lembut #EAEAEA)
            if row_idx == 0:
                shading_elm = parse_xml(r'<w:shd {} w:fill="EAEAEA"/>'.format(nsdecls('w')))
                cell._tc.get_or_add_tcPr().append(shading_elm)

    # Tambahkan spasi setelah tabel
    p_after = doc.add_paragraph()
    p_after.paragraph_format.space_before = Pt(0)
    p_after.paragraph_format.space_after = Pt(6)

def parse_markdown_to_docx(md_content, doc):
    lines = md_content.splitlines()
    in_table = False
    table_lines = []
    in_code_block = False
    code_lines = []

    for line in lines:
        stripped = line.strip()

        # Handle code blocks ```
        if stripped.startswith("```"):
            if in_code_block:
                in_code_block = False
                p = doc.add_paragraph("\n".join(code_lines))
                p.paragraph_format.line_spacing = 1.0
                p.paragraph_format.space_before = Pt(4)
                p.paragraph_format.space_after = Pt(6)
                for r in p.runs:
                    r.font.name = 'Consolas'
                    r.font.size = Pt(9.5)
                code_lines = []
            else:
                in_code_block = True
                code_lines = []
            continue

        if in_code_block:
            code_lines.append(line)
            continue

        # Handle tables
        if stripped.startswith("|") and stripped.endswith("|"):
            in_table = True
            table_lines.append(line)
            continue
        elif in_table:
            in_table = False
            add_markdown_table(doc, table_lines)
            table_lines = []

        if not stripped:
            continue

        # Handle Headings
        if stripped.startswith("# "):
            add_styled_heading(doc, stripped[2:].strip(), 1)
        elif stripped.startswith("## "):
            add_styled_heading(doc, stripped[3:].strip(), 2)
        elif stripped.startswith("### "):
            add_styled_heading(doc, stripped[4:].strip(), 3)
        elif stripped.startswith("#### "):
            add_styled_heading(doc, stripped[5:].strip(), 4)
        # Handle Blockquotes
        elif stripped.startswith("> "):
            p = doc.add_paragraph()
            p.paragraph_format.left_indent = Inches(0.5)
            p.paragraph_format.line_spacing = 1.15
            p.paragraph_format.space_after = Pt(6)
            run = p.add_run(stripped[2:].strip())
            run.italic = True
            run.font.name = 'Times New Roman'
        # Handle Bullet lists
        elif stripped.startswith("- ") or stripped.startswith("* "):
            p = doc.add_paragraph(style='List Bullet')
            p.paragraph_format.line_spacing = 1.15
            p.paragraph_format.space_after = Pt(3)
            p.add_run(stripped[2:].strip())
        # Handle Numbered lists
        elif re.match(r'^\d+\.\s', stripped):
            p = doc.add_paragraph(style='List Number')
            p.paragraph_format.line_spacing = 1.15
            p.paragraph_format.space_after = Pt(3)
            item_text = re.sub(r'^\d+\.\s', '', stripped)
            p.add_run(item_text)
        # Handle Inline Images: ![Alt](path)
        elif re.match(r'^!\[(.*?)\]\((.*?)\)$', stripped):
            match = re.match(r'^!\[(.*?)\]\((.*?)\)$', stripped)
            img_caption = match.group(1)
            img_rel_path = match.group(2)
            
            # Coba resolve lokasi gambar
            possible_paths = [
                os.path.join(ROOT_DIR, img_rel_path),
                os.path.join(DIAGRAMS_DIR, os.path.basename(img_rel_path)),
                os.path.abspath(img_rel_path)
            ]
            found_img = None
            for p in possible_paths:
                if os.path.exists(p):
                    found_img = p
                    break

            if found_img:
                doc.add_paragraph()
                p_img = doc.add_paragraph()
                p_img.alignment = WD_ALIGN_PARAGRAPH.CENTER
                p_img.paragraph_format.space_before = Pt(6)
                p_img.paragraph_format.space_after = Pt(2)
                p_img.add_run().add_picture(found_img, width=Inches(6.0))

                if img_caption:
                    p_cap = doc.add_paragraph()
                    p_cap.alignment = WD_ALIGN_PARAGRAPH.CENTER
                    p_cap.paragraph_format.space_before = Pt(0)
                    p_cap.paragraph_format.space_after = Pt(8)
                    r_cap = p_cap.add_run(f"Gambar: {img_caption}")
                    r_cap.font.name = 'Times New Roman'
                    r_cap.font.size = Pt(10)
                    r_cap.italic = True
        else:
            add_formatted_paragraph(doc, stripped)

    if in_table and table_lines:
        add_markdown_table(doc, table_lines)

def build_target(folder_name, output_filename):
    target_dir = os.path.join(ROOT_DIR, folder_name)
    if not os.path.exists(target_dir):
        print(f"[SKIP] Folder '{folder_name}' tidak ditemukan.")
        return

    md_files = sorted(glob.glob(os.path.join(target_dir, "*.md")))
    if not md_files:
        print(f"[INFO] Belum ada berkas .md di '{folder_name}'.")
        return

    print(f"\n[BUILD] Memproses folder: {folder_name} ({len(md_files)} file markdown)...")
    template_path = find_template()
    if template_path:
        print(f"  [TEMPLATE] Mewarisi template resmi: {os.path.basename(template_path)}")
        doc = Document(template_path)
    else:
        print("  [STYLING] Template belum ada di template/. Menggunakan standar akademik (A4, 4-4-3-3cm, TNR 12pt).")
        doc = Document()
        set_academic_margins(doc)
        set_base_styles(doc)

    for md_file in md_files:
        print(f"  -> Menyusun: {os.path.basename(md_file)}")
        with open(md_file, "r", encoding="utf-8") as f:
            content = f.read()
        parse_markdown_to_docx(content, doc)

    output_path = os.path.join(target_dir, output_filename)
    doc.save(output_path)
    print(f"  [SUKSES] Dokumen Word berhasil dibuat: {output_path}")

def main():
    print("=" * 60)
    print("MSDC DOCS BUILDER: Otomasi Kompilasi Markdown ke .DOCX")
    print("=" * 60)

    # 1. Target Laporan PKL
    build_target("02-laporan-pkl", "Laporan_PKL_DataCenterOps.docx")
    
    # 2. Target Laporan Magang Industri
    build_target("01-laporan-magang", "Laporan_Magang_Industri_MSDC.docx")

if __name__ == "__main__":
    main()
