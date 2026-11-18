#!/usr/bin/env python3
"""
md_to_docx.py - Engine Konversi Markdown ke DOCX Berstandar Akademik
Spesifikasi Tata Letak: UPN "Veteran" Jawa Timur
- Kertas: A4 (21 x 29,7 cm), Margin: 2,54 cm di seluruh sisi (Atas, Bawah, Kiri, Kanan)
- Font Narasi: Times New Roman 12 pt, Justified, Spasi 1.5, First-line Indent 1,27 cm
- Fenced Code Block: Tabel 1x1, Background #F6F8FA, Border #D0D7DE, Consolas 9.5 pt, Spasi 1.0, Rata Kiri, Pygments Syntax Highlighting, cantSplit
- Numbered & Bullet Lists: Paragraf terpisah, Hanging Indent rapi, Spasi 1.15, Rata Kiri
- Gambar & Caption: Rata Tengah, Maksimal lebar printable, Keterangan gambar di bawah gambar (Italic 10 pt)
- Tabel: Header #F1F5F9 Bold 10 pt, Border tipis #D0D7DE, cantSplit & tblHeader
"""

import os
import sys
import re
import textwrap
import argparse
from pathlib import Path

import docx
from docx.shared import Inches, Pt, RGBColor, Cm
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT
from docx.oxml import parse_xml
from docx.oxml.ns import nsdecls

from pygments import lex
from pygments.lexers import get_lexer_by_name, TextLexer
from pygments.token import Token


# ── Konfigurasi Tema Warna Sintaks (GitHub / VS Code Theme) ──
TOKEN_COLORS = {
    Token.Keyword: (RGBColor(0xCF, 0x22, 0x2E), True, False),       # Merah Tua Bold
    Token.Keyword.Constant: (RGBColor(0x05, 0x50, 0xAE), True, False),
    Token.Keyword.Declaration: (RGBColor(0xCF, 0x22, 0x2E), True, False),
    Token.Keyword.Namespace: (RGBColor(0xCF, 0x22, 0x2E), True, False),
    Token.Keyword.Type: (RGBColor(0x95, 0x38, 0x00), True, False),
    
    Token.String: (RGBColor(0x0A, 0x30, 0x69), False, False),        # Biru Tua String
    Token.String.Char: (RGBColor(0x0A, 0x30, 0x69), False, False),
    Token.String.Doc: (RGBColor(0x6E, 0x77, 0x81), False, True),
    Token.String.Interpol: (RGBColor(0x0A, 0x30, 0x69), False, False),
    
    Token.Comment: (RGBColor(0x6E, 0x77, 0x81), False, True),        # Abu-abu Italic
    Token.Comment.Single: (RGBColor(0x6E, 0x77, 0x81), False, True),
    Token.Comment.Multiline: (RGBColor(0x6E, 0x77, 0x81), False, True),
    Token.Comment.Preproc: (RGBColor(0x95, 0x38, 0x00), True, False), # e.g. <?php
    
    Token.Name.Function: (RGBColor(0x82, 0x50, 0xDF), False, False),  # Ungu Function
    Token.Name.Method: (RGBColor(0x82, 0x50, 0xDF), False, False),
    Token.Name.Class: (RGBColor(0x95, 0x38, 0x00), True, False),      # Oranye Tua Class
    Token.Name.Decorator: (RGBColor(0x11, 0x63, 0x29), False, False),
    Token.Name.Variable: (RGBColor(0x95, 0x38, 0x00), False, False),  # e.g. $var PHP
    Token.Name.Variable.Instance: (RGBColor(0x95, 0x38, 0x00), False, False),
    Token.Name.Attribute: (RGBColor(0x11, 0x63, 0x29), False, False),
    
    Token.Number: (RGBColor(0x05, 0x50, 0xAE), False, False),        # Biru Terang
    Token.Operator: (RGBColor(0x24, 0x29, 0x2F), False, False),
    Token.Punctuation: (RGBColor(0x24, 0x29, 0x2F), False, False),
}

DEFAULT_CODE_COLOR = (RGBColor(0x24, 0x29, 0x2F), False, False)


def get_token_style(token_type):
    """Mencari pasangan warna, bold, italic dari hirarki Token Pygments."""
    curr = token_type
    while curr:
        if curr in TOKEN_COLORS:
            return TOKEN_COLORS[curr]
        curr = curr.parent
    return DEFAULT_CODE_COLOR


def get_pygments_lexer(lang_tag, code_text):
    """Mengembalikan lexer yang tepat berdasarkan label bahasa."""
    tag = (lang_tag or "").strip().lower()
    if tag in ("php",):
        try:
            if "<?php" not in code_text:
                return get_lexer_by_name("php", startinline=True)
            return get_lexer_by_name("php")
        except Exception:
            return TextLexer()
    elif tag in ("ts", "typescript"):
        try:
            return get_lexer_by_name("typescript")
        except Exception:
            return TextLexer()
    elif tag in ("tsx",):
        try:
            return get_lexer_by_name("tsx")
        except Exception:
            return TextLexer()
    elif tag in ("js", "javascript"):
        try:
            return get_lexer_by_name("javascript")
        except Exception:
            return TextLexer()
    elif tag in ("sql",):
        try:
            return get_lexer_by_name("sql")
        except Exception:
            return TextLexer()
    elif tag in ("json",):
        try:
            return get_lexer_by_name("json")
        except Exception:
            return TextLexer()
    elif tag in ("bash", "sh", "shell"):
        try:
            return get_lexer_by_name("bash")
        except Exception:
            return TextLexer()
    elif tag in ("powershell", "ps1"):
        try:
            return get_lexer_by_name("powershell")
        except Exception:
            return TextLexer()
    else:
        return TextLexer()


# ── Regex untuk Pemisahan Inline Markdown ──
INLINE_REGEX = re.compile(
    r'(?P<code>`[^`]+`)'
    r'|(?P<bold>\*\*(?:[^*]|\*(?!\*))+\*\*)'
    r'|(?P<italic>\*(?:[^*])+\*)'
    r'|(?P<math>\$[^$]+\$)'
    r'|(?P<link>\[[^\]]+\]\([^)]+\))'
)


def append_inline_formatted_text(paragraph, text, base_font="Times New Roman", base_size_pt=12, base_italic=False, base_color=None):
    """
    Menambahkan run teks berformat inline (bold, italic, code, math, link)
    ke dalam paragraf Word.
    """
    last_idx = 0
    for match in INLINE_REGEX.finditer(text):
        start, end = match.span()
        if start > last_idx:
            chunk = text[last_idx:start]
            r = paragraph.add_run(chunk)
            r.font.name = base_font
            r.font.size = Pt(base_size_pt)
            r.italic = base_italic
            if base_color:
                r.font.color.rgb = base_color

        for kind, val in match.groupdict().items():
            if val is not None:
                if kind == "code":
                    clean = val[1:-1]
                    r = paragraph.add_run(clean)
                    r.font.name = "Consolas"
                    r.font.size = Pt(base_size_pt - 1.5 if base_size_pt >= 11 else base_size_pt)
                    r.font.color.rgb = RGBColor(0x99, 0x1B, 0x1B)  # Dark red untuk inline code
                elif kind == "bold":
                    clean = val[2:-2]
                    # Periksa apakah di dalam bold ada italic
                    if clean.startswith("*") and clean.endswith("*") and len(clean) > 2:
                        clean = clean[1:-1]
                        r = paragraph.add_run(clean)
                        r.font.name = base_font
                        r.font.size = Pt(base_size_pt)
                        r.bold = True
                        r.italic = True
                    else:
                        r = paragraph.add_run(clean)
                        r.font.name = base_font
                        r.font.size = Pt(base_size_pt)
                        r.bold = True
                        r.italic = base_italic
                elif kind == "italic":
                    clean = val[1:-1]
                    r = paragraph.add_run(clean)
                    r.font.name = base_font
                    r.font.size = Pt(base_size_pt)
                    r.italic = True
                elif kind == "math":
                    clean = val[1:-1]
                    clean = clean.replace(r"\longrightarrow", " → ")
                    clean = clean.replace(r"\times", " × ")
                    clean = re.sub(r'\\text\{([^}]+)\}', r'\1', clean)
                    r = paragraph.add_run(clean)
                    r.font.name = "Times New Roman"
                    r.font.size = Pt(base_size_pt)
                    r.italic = True
                elif kind == "link":
                    m_link = re.match(r'\[([^\]]+)\]\(([^)]+)\)', val)
                    if m_link:
                        link_text, link_url = m_link.groups()
                        r = paragraph.add_run(link_text)
                        r.font.name = base_font
                        r.font.size = Pt(base_size_pt)
                        r.underline = True
                        r.font.color.rgb = RGBColor(0x09, 0x69, 0xDA)
                break
        last_idx = end

    if last_idx < len(text):
        chunk = text[last_idx:]
        r = paragraph.add_run(chunk)
        r.font.name = base_font
        r.font.size = Pt(base_size_pt)
        r.italic = base_italic
        if base_color:
            r.font.color.rgb = base_color


def render_code_box(doc, code_text, lang_tag, doc_width_pt=451.27):
    """
    Membuat kotak kode berupa tabel 1x1 dengan styling elegan:
    - Background: #F6F8FA
    - Border: #D0D7DE
    - Padding dalam: top/bottom 140 dxa, left/right 200 dxa
    - Format teks di dalam: Rata Kiri, Spasi 1.0, Consolas 9.5 pt
    - Syntax Highlighting via Pygments
    - cantSplit agar tidak terpotong canggung antarhalaman
    """
    # Dedent kode agar indentasi berlebih dari markdown hilang
    code_text_clean = textwrap.dedent(code_text.replace("\t", "    "))

    table = doc.add_table(rows=1, cols=1)
    table.alignment = WD_TABLE_ALIGNMENT.CENTER
    table.autofit = False

    # Set table width XML (lebar penuh halaman cetak: ~9025 dxa = 15,92 cm)
    tblPr = table._tbl.tblPr
    tblW = parse_xml(f'<w:tblW {nsdecls("w")} w:w="9025" w:type="dxa"/>')
    tblPr.append(tblW)
    tblLayout = parse_xml(f'<w:tblLayout {nsdecls("w")} w:type="fixed"/>')
    tblPr.append(tblLayout)

    cell = table.cell(0, 0)
    cell.width = Pt(doc_width_pt)

    # Shading latar belakang #F6F8FA
    shd = parse_xml(f'<w:shd {nsdecls("w")} w:fill="F6F8FA"/>')
    cell._tc.get_or_add_tcPr().append(shd)

    # Border tipis #D0D7DE
    borders = parse_xml(f'''
        <w:tcBorders {nsdecls("w")}>
            <w:top w:val="single" w:sz="4" w:space="0" w:color="D0D7DE"/>
            <w:left w:val="single" w:sz="4" w:space="0" w:color="D0D7DE"/>
            <w:bottom w:val="single" w:sz="4" w:space="0" w:color="D0D7DE"/>
            <w:right w:val="single" w:sz="4" w:space="0" w:color="D0D7DE"/>
        </w:tcBorders>
    ''')
    cell._tc.get_or_add_tcPr().append(borders)

    # Margin / Padding dalam sel
    tcMar = parse_xml(f'''
        <w:tcMar {nsdecls("w")}>
            <w:top w:w="140" w:type="dxa"/>
            <w:left w:w="200" w:type="dxa"/>
            <w:bottom w:w="140" w:type="dxa"/>
            <w:right w:w="200" w:type="dxa"/>
        </w:tcMar>
    ''')
    cell._tc.get_or_add_tcPr().append(tcMar)

    # cantSplit pada baris
    row = table.rows[0]
    trPr = row._tr.get_or_add_trPr()
    trPr.append(parse_xml(f'<w:cantSplit {nsdecls("w")}/>'))

    # Tokenisasi Pygments
    lexer = get_pygments_lexer(lang_tag, code_text_clean)
    
    # Ambil paragraf pertama yang sudah ada di cell
    p_curr = cell.paragraphs[0]
    p_curr.alignment = WD_ALIGN_PARAGRAPH.LEFT
    p_curr.paragraph_format.line_spacing = 1.0
    p_curr.paragraph_format.space_before = Pt(0)
    p_curr.paragraph_format.space_after = Pt(0)
    p_curr.paragraph_format.first_line_indent = Pt(0)
    p_curr.paragraph_format.left_indent = Pt(0)

    tokens = list(lex(code_text_clean, lexer))

    for ttype, tval in tokens:
        color, is_bold, is_italic = get_token_style(ttype)
        
        parts = tval.split("\n")
        for idx, part in enumerate(parts):
            if idx > 0:
                p_curr = cell.add_paragraph()
                p_curr.alignment = WD_ALIGN_PARAGRAPH.LEFT
                p_curr.paragraph_format.line_spacing = 1.0
                p_curr.paragraph_format.space_before = Pt(0)
                p_curr.paragraph_format.space_after = Pt(0)
                p_curr.paragraph_format.first_line_indent = Pt(0)
                p_curr.paragraph_format.left_indent = Pt(0)

            if part:
                run = p_curr.add_run(part)
                run.font.name = "Consolas"
                run.font.size = Pt(9.5)
                run.font.color.rgb = color
                run.bold = is_bold
                run.italic = is_italic

    # Paragraf pemisah setelah tabel
    p_space = doc.add_paragraph()
    p_space.paragraph_format.space_before = Pt(0)
    p_space.paragraph_format.space_after = Pt(6)
    p_space.paragraph_format.line_spacing = 1.0


def render_table(doc, table_rows, doc_width_pt=451.27):
    """
    Merender tabel Markdown menjadi Word Table berstandar akademik:
    - Header berlatar #F1F5F9 dengan teks Bold 10 pt
    - Border tipis #D0D7DE
    - Padding dalam sel yang nyaman
    - cantSplit dan tblHeader
    """
    if not table_rows:
        return

    parsed_rows = []
    for r in table_rows:
        cols = [c.strip() for c in r.strip().strip('|').split('|')]
        parsed_rows.append(cols)

    header_cols = parsed_rows[0]
    data_rows = []
    for row in parsed_rows[1:]:
        if all(re.match(r'^:?-+:?$', c) for c in row if c):
            continue
        data_rows.append(row)

    num_cols = len(header_cols)
    table = doc.add_table(rows=1 + len(data_rows), cols=num_cols)
    table.alignment = WD_TABLE_ALIGNMENT.CENTER
    table.autofit = True

    # Styling Header
    hdr_row = table.rows[0]
    hdr_trPr = hdr_row._tr.get_or_add_trPr()
    hdr_trPr.append(parse_xml(f'<w:tblHeader {nsdecls("w")}/>'))
    hdr_trPr.append(parse_xml(f'<w:cantSplit {nsdecls("w")}/>'))

    for col_idx, cell in enumerate(hdr_row.cells):
        shd = parse_xml(f'<w:shd {nsdecls("w")} w:fill="F1F5F9"/>')
        cell._tc.get_or_add_tcPr().append(shd)

        borders = parse_xml(f'''
            <w:tcBorders {nsdecls("w")}>
                <w:top w:val="single" w:sz="6" w:space="0" w:color="94A3B8"/>
                <w:left w:val="single" w:sz="4" w:space="0" w:color="CBD5E1"/>
                <w:bottom w:val="single" w:sz="6" w:space="0" w:color="94A3B8"/>
                <w:right w:val="single" w:sz="4" w:space="0" w:color="CBD5E1"/>
            </w:tcBorders>
        ''')
        cell._tc.get_or_add_tcPr().append(borders)

        tcMar = parse_xml(f'''
            <w:tcMar {nsdecls("w")}>
                <w:top w:w="120" w:type="dxa"/>
                <w:left w:w="160" w:type="dxa"/>
                <w:bottom w:w="120" w:type="dxa"/>
                <w:right w:w="160" w:type="dxa"/>
            </w:tcMar>
        ''')
        cell._tc.get_or_add_tcPr().append(tcMar)

        p = cell.paragraphs[0]
        p.alignment = WD_ALIGN_PARAGRAPH.LEFT
        p.paragraph_format.line_spacing = 1.15
        p.paragraph_format.space_before = Pt(0)
        p.paragraph_format.space_after = Pt(0)
        p.paragraph_format.first_line_indent = Pt(0)
        text = header_cols[col_idx] if col_idx < len(header_cols) else ""
        append_inline_formatted_text(p, text, base_size_pt=10, base_font="Times New Roman")
        for run in p.runs:
            run.bold = True

    # Styling Baris Data
    for row_idx, row_data in enumerate(data_rows):
        row = table.rows[row_idx + 1]
        trPr = row._tr.get_or_add_trPr()
        trPr.append(parse_xml(f'<w:cantSplit {nsdecls("w")}/>'))

        row_bg = "FFFFFF" if row_idx % 2 == 0 else "F8FAFC"

        for col_idx, cell in enumerate(row.cells):
            if row_bg != "FFFFFF":
                shd = parse_xml(f'<w:shd {nsdecls("w")} w:fill="{row_bg}"/>')
                cell._tc.get_or_add_tcPr().append(shd)

            borders = parse_xml(f'''
                <w:tcBorders {nsdecls("w")}>
                    <w:top w:val="single" w:sz="4" w:space="0" w:color="E2E8F0"/>
                    <w:left w:val="single" w:sz="4" w:space="0" w:color="E2E8F0"/>
                    <w:bottom w:val="single" w:sz="4" w:space="0" w:color="E2E8F0"/>
                    <w:right w:val="single" w:sz="4" w:space="0" w:color="E2E8F0"/>
                </w:tcBorders>
            ''')
            cell._tc.get_or_add_tcPr().append(borders)

            tcMar = parse_xml(f'''
                <w:tcMar {nsdecls("w")}>
                    <w:top w:w="100" w:type="dxa"/>
                    <w:left w:w="140" w:type="dxa"/>
                    <w:bottom w:w="100" w:type="dxa"/>
                    <w:right w:w="140" w:type="dxa"/>
                </w:tcMar>
            ''')
            cell._tc.get_or_add_tcPr().append(tcMar)

            p = cell.paragraphs[0]
            p.alignment = WD_ALIGN_PARAGRAPH.LEFT
            p.paragraph_format.line_spacing = 1.15
            p.paragraph_format.space_before = Pt(0)
            p.paragraph_format.space_after = Pt(0)
            p.paragraph_format.first_line_indent = Pt(0)
            text = row_data[col_idx] if col_idx < len(row_data) else ""
            append_inline_formatted_text(p, text, base_size_pt=10, base_font="Times New Roman")

    p_after = doc.add_paragraph()
    p_after.paragraph_format.space_before = Pt(0)
    p_after.paragraph_format.space_after = Pt(8)
    p_after.paragraph_format.line_spacing = 1.0


def convert_markdown_to_docx(md_path: Path, docx_path: Path):
    """Fungsi utama konversi berkas Markdown ke DOCX berstandar UPN Veteran Jatim."""
    print(f"--> Mengonversi Markdown: {md_path.name} -> {docx_path.name}")
    with open(md_path, "r", encoding="utf-8") as f:
        content = f.read()

    doc = docx.Document()

    # 1. Setup Halaman (A4 & Margin 2,54 cm)
    section = doc.sections[0]
    section.page_width = Cm(21.0)
    section.page_height = Cm(29.7)
    section.top_margin = Cm(2.54)
    section.bottom_margin = Cm(2.54)
    section.left_margin = Cm(2.54)
    section.right_margin = Cm(2.54)

    printable_width_pt = 451.27
    printable_width_in = Inches(6.25)

    lines = content.replace("\r\n", "\n").split("\n")

    i = 0
    total_lines = len(lines)

    while i < total_lines:
        raw_line = lines[i]
        line = raw_line.strip()

        # Lewati baris kosong
        if not line:
            i += 1
            continue

        # ── 1. Blok Fenced Code Block (``` ... ```) ──
        if line.startswith("```"):
            lang_tag = line[3:].strip()
            code_lines = []
            i += 1
            while i < total_lines and not lines[i].strip().startswith("```"):
                code_lines.append(lines[i])
                i += 1
            i += 1  # Lewati penutup ```
            code_text = "\n".join(code_lines)
            render_code_box(doc, code_text, lang_tag, printable_width_pt)
            continue

        # ── 2. Blok Tabel Markdown (| ... |) ──
        if line.startswith("|") and line.endswith("|"):
            table_lines = []
            while i < total_lines and lines[i].strip().startswith("|") and lines[i].strip().endswith("|"):
                table_lines.append(lines[i].strip())
                i += 1
            render_table(doc, table_lines, printable_width_pt)
            continue

        # ── 3. Gambar & Caption (![alt](path)) ──
        img_match = re.match(r'^!\[(.*?)\]\((.*?)\)$', line)
        if img_match:
            alt_text, img_rel_path = img_match.groups()
            img_full_path = (md_path.parent / img_rel_path).resolve()
            if img_full_path.exists():
                p_img = doc.add_paragraph()
                p_img.alignment = WD_ALIGN_PARAGRAPH.CENTER
                p_img.paragraph_format.space_before = Pt(12)
                p_img.paragraph_format.space_after = Pt(4)
                p_img.paragraph_format.first_line_indent = Pt(0)
                run_img = p_img.add_run()
                run_img.add_picture(str(img_full_path), width=printable_width_in)

                if i + 1 < total_lines and lines[i+1].strip().startswith("*") and lines[i+1].strip().endswith("*"):
                    i += 1
                    cap_text = lines[i].strip()[1:-1]
                    p_cap = doc.add_paragraph()
                    p_cap.alignment = WD_ALIGN_PARAGRAPH.CENTER
                    p_cap.paragraph_format.space_before = Pt(2)
                    p_cap.paragraph_format.space_after = Pt(12)
                    p_cap.paragraph_format.first_line_indent = Pt(0)
                    p_cap.paragraph_format.line_spacing = 1.15
                    append_inline_formatted_text(p_cap, cap_text, base_font="Times New Roman", base_size_pt=10, base_italic=True)
            else:
                p_err = doc.add_paragraph()
                p_err.alignment = WD_ALIGN_PARAGRAPH.CENTER
                p_err.paragraph_format.first_line_indent = Pt(0)
                r_err = p_err.add_run(f"[Gambar tidak ditemukan: {img_rel_path}]")
                r_err.font.color.rgb = RGBColor(0xDC, 0x26, 0x26)
            i += 1
            continue

        # ── 4. Math Block Display ($$...$$) ──
        if line.startswith("$$"):
            math_lines = []
            if line.endswith("$$") and len(line) > 2:
                math_lines.append(line[2:-2])
                i += 1
            else:
                i += 1
                while i < total_lines and not lines[i].strip().endswith("$$"):
                    math_lines.append(lines[i].strip())
                    i += 1
                if i < total_lines:
                    math_lines.append(lines[i].strip()[:-2])
                    i += 1
            math_text = " ".join(math_lines).strip()
            math_text = math_text.replace(r"\longrightarrow", " → ")
            math_text = math_text.replace(r"\times", " × ")
            math_text = math_text.replace(r"\left(", "(").replace(r"\right)", ")")
            math_text = re.sub(r'\\text\{([^}]+)\}', r'\1', math_text)
            math_text = re.sub(r'\\frac\{([^}]+)\}\{([^}]+)\}', r'(\1 / \2)', math_text)

            p_math = doc.add_paragraph()
            p_math.alignment = WD_ALIGN_PARAGRAPH.CENTER
            p_math.paragraph_format.space_before = Pt(8)
            p_math.paragraph_format.space_after = Pt(8)
            p_math.paragraph_format.first_line_indent = Pt(0)
            r_math = p_math.add_run(math_text)
            r_math.font.name = "Times New Roman"
            r_math.font.size = Pt(11)
            r_math.italic = True
            continue

        # ── 5. Garis Pembatas (---) ──
        if re.match(r'^-{3,}$', line):
            i += 1
            continue

        # ── 6. Judul & Heading (#, ##, ###, ####) ──
        if line.startswith("#"):
            h_match = re.match(r'^(#{1,4})\s+(.*)$', line)
            if h_match:
                level_str, title_text = h_match.groups()
                level = len(level_str)
                p_h = doc.add_paragraph()
                p_h.paragraph_format.first_line_indent = Pt(0)
                p_h.paragraph_format.line_spacing = 1.15

                if level == 1:
                    p_h.alignment = WD_ALIGN_PARAGRAPH.CENTER
                    p_h.paragraph_format.space_before = Pt(16)
                    p_h.paragraph_format.space_after = Pt(8)
                    append_inline_formatted_text(p_h, title_text.upper(), base_font="Times New Roman", base_size_pt=14)
                    for r in p_h.runs:
                        r.bold = True
                elif level == 2:
                    p_h.alignment = WD_ALIGN_PARAGRAPH.LEFT
                    p_h.paragraph_format.space_before = Pt(14)
                    p_h.paragraph_format.space_after = Pt(6)
                    append_inline_formatted_text(p_h, title_text, base_font="Times New Roman", base_size_pt=12)
                    for r in p_h.runs:
                        r.bold = True
                elif level == 3:
                    p_h.alignment = WD_ALIGN_PARAGRAPH.LEFT
                    p_h.paragraph_format.space_before = Pt(10)
                    p_h.paragraph_format.space_after = Pt(4)
                    append_inline_formatted_text(p_h, title_text, base_font="Times New Roman", base_size_pt=12)
                    for r in p_h.runs:
                        r.bold = True
                        r.italic = True
                else:
                    p_h.alignment = WD_ALIGN_PARAGRAPH.LEFT
                    p_h.paragraph_format.space_before = Pt(8)
                    p_h.paragraph_format.space_after = Pt(3)
                    append_inline_formatted_text(p_h, title_text, base_font="Times New Roman", base_size_pt=12)
                    for r in p_h.runs:
                        r.bold = True

                i += 1
                continue

        # ── 7. Blockquote (> ...) ──
        if line.startswith(">"):
            quote_text = line.lstrip(">").strip()
            if quote_text.startswith('"') and quote_text.endswith('"'):
                quote_text = quote_text[1:-1]
            p_q = doc.add_paragraph()
            p_q.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY
            p_q.paragraph_format.left_indent = Pt(28)
            p_q.paragraph_format.right_indent = Pt(14)
            p_q.paragraph_format.first_line_indent = Pt(0)
            p_q.paragraph_format.space_before = Pt(4)
            p_q.paragraph_format.space_after = Pt(6)
            p_q.paragraph_format.line_spacing = 1.15
            append_inline_formatted_text(p_q, quote_text, base_font="Times New Roman", base_size_pt=11, base_italic=True)
            i += 1
            continue

        # ── 8. Numbered List (1. , 2. ) ──
        num_match = re.match(r'^(\s*)(\d+)\.\s+(.*)$', raw_line)
        if num_match:
            indent_spaces, num_str, item_text = num_match.groups()
            is_nested = len(indent_spaces) >= 2

            p_li = doc.add_paragraph()
            p_li.alignment = WD_ALIGN_PARAGRAPH.LEFT
            p_li.paragraph_format.line_spacing = 1.15
            p_li.paragraph_format.space_before = Pt(2)
            p_li.paragraph_format.space_after = Pt(3)

            if is_nested:
                p_li.paragraph_format.left_indent = Pt(48)
                p_li.paragraph_format.first_line_indent = Pt(-20)
            else:
                p_li.paragraph_format.left_indent = Pt(28)
                p_li.paragraph_format.first_line_indent = Pt(-20)

            r_num = p_li.add_run(f"{num_str}. ")
            r_num.font.name = "Times New Roman"
            r_num.font.size = Pt(12)
            r_num.bold = True

            append_inline_formatted_text(p_li, item_text, base_font="Times New Roman", base_size_pt=12)
            i += 1
            continue

        # ── 9. Bullet List (- , * , + ) ──
        bullet_match = re.match(r'^(\s*)[-*+]\s+(.*)$', raw_line)
        if bullet_match:
            indent_spaces, item_text = bullet_match.groups()
            is_nested = len(indent_spaces) >= 2

            p_b = doc.add_paragraph()
            p_b.alignment = WD_ALIGN_PARAGRAPH.LEFT
            p_b.paragraph_format.line_spacing = 1.15
            p_b.paragraph_format.space_before = Pt(2)
            p_b.paragraph_format.space_after = Pt(3)

            if is_nested:
                p_b.paragraph_format.left_indent = Pt(48)
                p_b.paragraph_format.first_line_indent = Pt(-16)
                prefix_bullet = "– "
            else:
                p_b.paragraph_format.left_indent = Pt(28)
                p_b.paragraph_format.first_line_indent = Pt(-16)
                prefix_bullet = "• "

            r_bullet = p_b.add_run(prefix_bullet)
            r_bullet.font.name = "Times New Roman"
            r_bullet.font.size = Pt(12)

            append_inline_formatted_text(p_b, item_text, base_font="Times New Roman", base_size_pt=12)
            i += 1
            continue

        # ── 10. Judul Tabel di atas tabel (Tabel X.Y: ...) ──
        if line.startswith("**Tabel ") or line.startswith("*Tabel "):
            p_tbl_title = doc.add_paragraph()
            p_tbl_title.alignment = WD_ALIGN_PARAGRAPH.LEFT
            p_tbl_title.paragraph_format.first_line_indent = Pt(0)
            p_tbl_title.paragraph_format.space_before = Pt(10)
            p_tbl_title.paragraph_format.space_after = Pt(3)
            p_tbl_title.paragraph_format.line_spacing = 1.15
            append_inline_formatted_text(p_tbl_title, line, base_font="Times New Roman", base_size_pt=10)
            i += 1
            continue

        # ── 11. Narasi Standar (Justified, Spasi 1.5, First Line Indent 1,27 cm) ──
        p_narrative = doc.add_paragraph()
        p_narrative.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY
        p_narrative.paragraph_format.line_spacing = 1.5
        p_narrative.paragraph_format.first_line_indent = Cm(1.27)
        p_narrative.paragraph_format.space_before = Pt(0)
        p_narrative.paragraph_format.space_after = Pt(6)

        append_inline_formatted_text(p_narrative, line, base_font="Times New Roman", base_size_pt=12)
        i += 1

    docx_path.parent.mkdir(parents=True, exist_ok=True)
    doc.save(str(docx_path))
    print(f"    [SUKSES] Berkas tersimpan di: {docx_path}")


def main():
    parser = argparse.ArgumentParser(description="Konversi Markdown ke DOCX Berstandar UPN Veteran Jatim")
    parser.add_argument("input", help="Path berkas input markdown (.md)")
    parser.add_argument("-o", "--output", required=True, help="Path berkas output docx (.docx)")
    args = parser.parse_args()

    input_path = Path(args.input).resolve()
    output_path = Path(args.output).resolve()

    if not input_path.exists():
        print(f"[ERROR] Berkas {input_path} tidak ditemukan!", file=sys.stderr)
        sys.exit(1)

    convert_markdown_to_docx(input_path, output_path)


if __name__ == "__main__":
    main()
