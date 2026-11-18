#!/usr/bin/env python3
"""
normalize_markdown.py - Normalisasi struktur Markdown Klaster 1-4
Memastikan setiap code fence (```) dan list item memiliki baris kosong pemisah yang valid,
serta membersihkan indentasi abnormal pada pembuka/penutup blok kode.
"""

import re
from pathlib import Path


def normalize_file(file_path: Path):
    print(f"Normalizing: {file_path.name}")
    with open(file_path, "r", encoding="utf-8") as f:
        content = f.read()

    lines = content.replace("\r\n", "\n").split("\n")
    normalized_lines = []
    
    in_code_block = False
    current_code_lines = []
    code_lang = ""

    i = 0
    while i < len(lines):
        line = lines[i]
        stripped = line.strip()

        # Deteksi batas pembuka / penutup code fence (mis. ```, ```php,     ```php)
        if stripped.startswith("```"):
            if not in_code_block:
                # Pembuka Code Block
                in_code_block = True
                code_lang = stripped[3:].strip()
                current_code_lines = []
                
                # Pastikan ada baris kosong sebelum ``` jika baris sebelumnya bukan baris kosong
                if normalized_lines and normalized_lines[-1].strip() != "":
                    normalized_lines.append("")
                
                i += 1
                continue
            else:
                # Penutup Code Block
                in_code_block = False
                
                # Bersihkan common indentation dari code lines
                # Cari leading whitespace minimum di antara baris-baris kode yang tidak kosong
                non_empty = [l for l in current_code_lines if l.strip() != ""]
                min_indent = 999
                for l in non_empty:
                    indent_len = len(l) - len(l.lstrip())
                    if indent_len < min_indent:
                        min_indent = indent_len
                if min_indent == 999:
                    min_indent = 0
                
                dedented_lines = []
                for l in current_code_lines:
                    if l.strip() == "":
                        dedented_lines.append("")
                    else:
                        dedented_lines.append(l[min_indent:] if len(l) >= min_indent else l.lstrip())

                # Tambahkan ```lang pembuka unindented
                normalized_lines.append(f"```{code_lang}")
                normalized_lines.extend(dedented_lines)
                normalized_lines.append("```")
                
                # Pastikan ada baris kosong setelah ``` jika baris berikutnya bukan baris kosong
                if i + 1 < len(lines) and lines[i+1].strip() != "":
                    normalized_lines.append("")

                i += 1
                continue

        if in_code_block:
            current_code_lines.append(line)
            i += 1
            continue

        # Periksa apakah baris ini adalah awal Numbered List (1. , 2. ) atau Bullet List (- , * )
        # Jika baris sebelumnya adalah paragraf teks biasa (bukan heading, bukan list lain), beri baris kosong
        if re.match(r'^\d+\.\s+', stripped) or re.match(r'^[-*+]\s+', stripped):
            if normalized_lines and normalized_lines[-1].strip() != "":
                prev = normalized_lines[-1].strip()
                # Jika baris sebelumnya bukan heading (#) dan bukan list item
                if not prev.startswith("#") and not re.match(r'^\d+\.\s+', prev) and not re.match(r'^[-*+]\s+', prev):
                    normalized_lines.append("")

        normalized_lines.append(line)
        i += 1

    # Gabungkan dan simpan
    output_text = "\n".join(normalized_lines)
    # Hapus triple-newline berlebihan menjadi double-newline
    output_text = re.sub(r'\n{3,}', '\n\n', output_text)
    
    with open(file_path, "w", encoding="utf-8") as f:
        f.write(output_text.strip() + "\n")
    print(f"  [OK] Normalisasi selesai untuk: {file_path.name}")


def main():
    md_dir = Path(r"d:\website\MSDC\laporan_akhir\00-bedah-klaster\data-center-ops\md")
    for f in sorted(md_dir.glob("klaster-*.md")):
        normalize_file(f)


if __name__ == "__main__":
    main()
