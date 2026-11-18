#!/usr/bin/env python3
"""
Skrip Pembentukan Template Dokumen Word Resmi (UPN 'Veteran' Jawa Timur)
Lokasi: scripts/customize_reference_docx.py
Target Output: scripts/reference-klaster.docx
"""

import os
from docx import Document
from docx.shared import Inches, Pt, Cm, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.style import WD_STYLE_TYPE
from docx.oxml import OxmlElement
from docx.oxml.ns import qn

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
BASE_DOCX = os.path.join(SCRIPT_DIR, "base-reference.docx")
TARGET_DOCX = os.path.join(SCRIPT_DIR, "reference-klaster.docx")

def set_cell_margins(cell, top=100, bottom=100, left=150, right=150):
    tcPr = cell._tc.get_or_add_tcPr()
    tcMar = OxmlElement('w:tcMar')
    for m, val in [('w:top', top), ('w:bottom', bottom), ('w:left', left), ('w:right', right)]:
        node = OxmlElement(m)
        node.set(qn('w:w'), str(val))
        node.set(qn('w:type'), 'dxa')
        tcMar.append(node)
    tcPr.append(tcMar)

def customize_styles():
    doc = Document(BASE_DOCX)
    
    # 1. Konfigurasi Halaman & Margin A4 Standar Akademik (2,54 cm sekeliling)
    for section in doc.sections:
        section.page_width = Cm(21.0)
        section.page_height = Cm(29.7)
        section.top_margin = Cm(2.54)
        section.bottom_margin = Cm(2.54)
        section.left_margin = Cm(2.54)
        section.right_margin = Cm(2.54)
        section.header_distance = Cm(1.27)
        section.footer_distance = Cm(1.27)

    styles = doc.styles

    # 2. Gaya Teks Normal (Paragraf Narasi)
    if 'Normal' in styles:
        normal = styles['Normal']
        normal.font.name = 'Times New Roman'
        normal.font.size = Pt(12)
        normal.font.color.rgb = RGBColor(0, 0, 0)
        rFonts = normal.element.rPr.get_or_add_rFonts()
        rFonts.set(qn('w:ascii'), 'Times New Roman')
        rFonts.set(qn('w:hAnsi'), 'Times New Roman')
        rFonts.set(qn('w:cs'), 'Times New Roman')
        
        pf = normal.paragraph_format
        pf.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY
        pf.line_spacing = 1.5
        pf.space_before = Pt(0)
        pf.space_after = Pt(6)
        pf.first_line_indent = Cm(1.27)

    # Helper untuk font heading
    def format_heading(style_name, size, bold=True, italic=False, align=WD_ALIGN_PARAGRAPH.LEFT, before=12, after=6, center=False):
        if style_name in styles:
            h = styles[style_name]
            h.font.name = 'Times New Roman'
            h.font.size = Pt(size)
            h.font.bold = bold
            h.font.italic = italic
            h.font.color.rgb = RGBColor(0, 0, 0)
            rF = h.element.rPr.get_or_add_rFonts()
            rF.set(qn('w:ascii'), 'Times New Roman')
            rF.set(qn('w:hAnsi'), 'Times New Roman')
            rF.set(qn('w:cs'), 'Times New Roman')

            pf = h.paragraph_format
            pf.alignment = WD_ALIGN_PARAGRAPH.CENTER if center else align
            pf.space_before = Pt(before)
            pf.space_after = Pt(after)
            pf.first_line_indent = Cm(0)
            pf.keep_with_next = True
            pf.line_spacing = 1.15

    # 3. Hierarki Judul
    format_heading('Heading 1', 14, bold=True, center=True, before=18, after=8)
    format_heading('Heading 2', 12, bold=True, align=WD_ALIGN_PARAGRAPH.LEFT, before=14, after=4)
    format_heading('Heading 3', 12, bold=True, italic=True, align=WD_ALIGN_PARAGRAPH.LEFT, before=10, after=3)
    format_heading('Heading 4', 12, bold=False, italic=True, align=WD_ALIGN_PARAGRAPH.LEFT, before=8, after=2)

    # 4. Source Code & Kode Program
    for code_style_name in ['Source Code', 'Verbatim']:
        if code_style_name in styles:
            cs = styles[code_style_name]
            cs.font.name = 'Consolas'
            cs.font.size = Pt(10)
            cs.font.color.rgb = RGBColor(30, 30, 30)
            rF = cs.element.rPr.get_or_add_rFonts()
            rF.set(qn('w:ascii'), 'Consolas')
            rF.set(qn('w:hAnsi'), 'Consolas')
            
            pf = cs.paragraph_format
            pf.alignment = WD_ALIGN_PARAGRAPH.LEFT
            pf.line_spacing = 1.15
            pf.space_before = Pt(3)
            pf.space_after = Pt(3)
            pf.first_line_indent = Cm(0)

    # 5. Caption (Gambar & Tabel)
    for cap_name in ['Caption', 'Image Caption', 'Table Caption']:
        if cap_name in styles:
            cap = styles[cap_name]
            cap.font.name = 'Times New Roman'
            cap.font.size = Pt(10)
            cap.font.italic = True
            cap.font.color.rgb = RGBColor(50, 50, 50)
            rF = cap.element.rPr.get_or_add_rFonts()
            rF.set(qn('w:ascii'), 'Times New Roman')
            rF.set(qn('w:hAnsi'), 'Times New Roman')

            pf = cap.paragraph_format
            pf.alignment = WD_ALIGN_PARAGRAPH.CENTER
            pf.line_spacing = 1.15
            pf.space_before = Pt(4)
            pf.space_after = Pt(8)
            pf.first_line_indent = Cm(0)

    # 6. List Bullet & Numbering
    for list_name in ['List Bullet', 'List Number', 'List']:
        if list_name in styles:
            ls = styles[list_name]
            ls.font.name = 'Times New Roman'
            ls.font.size = Pt(12)
            ls.font.color.rgb = RGBColor(0, 0, 0)
            pf = ls.paragraph_format
            pf.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY
            pf.line_spacing = 1.15
            pf.space_before = Pt(1)
            pf.space_after = Pt(3)
            pf.first_line_indent = Cm(0)

    # 7. Blockquote
    if 'Block Text' in styles or 'Quote' in styles:
        for q_name in ['Block Text', 'Quote']:
            if q_name in styles:
                qs = styles[q_name]
                qs.font.name = 'Times New Roman'
                qs.font.size = Pt(11)
                qs.font.italic = True
                pf = qs.paragraph_format
                pf.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY
                pf.line_spacing = 1.15
                pf.left_indent = Cm(1.27)
                pf.right_indent = Cm(1.27)
                pf.first_line_indent = Cm(0)
                pf.space_before = Pt(4)
                pf.space_after = Pt(6)

    doc.save(TARGET_DOCX)
    print(f"[OK] Berhasil membuat template referensi Word: {TARGET_DOCX}")

if __name__ == "__main__":
    customize_styles()
