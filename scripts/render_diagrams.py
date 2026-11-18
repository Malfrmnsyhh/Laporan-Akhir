#!/usr/bin/env python3
"""
Skrip Otomasi Render Diagram Mermaid (.mmd -> .png)
Lokasi: laporan_akhir/scripts/render_diagrams.py

Fungsi:
Memindai seluruh berkas .mmd di `diagrams/source/`, mengonversinya menjadi .png
beresolusi tinggi (scale 3x, latar putih) ke `diagrams/rendered/`.

Prioritas Renderer:
1. Lokal npx / node_modules/.bin/mmdc (@mermaid-js/mermaid-cli)
2. Fallback aman via Kroki HTTPS API (jika mmdc belum siap/tanpa chromium)
"""

import os
import sys
import glob
import subprocess
import base64
import zlib
import urllib.request

ROOT_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
SOURCE_DIR = os.path.join(ROOT_DIR, "diagrams", "source")
RENDERED_DIR = os.path.join(ROOT_DIR, "diagrams", "rendered")

os.makedirs(SOURCE_DIR, exist_ok=True)
os.makedirs(RENDERED_DIR, exist_ok=True)

def find_mmdc():
    # Cek local node_modules
    local_bin = os.path.join(ROOT_DIR, "node_modules", ".bin", "mmdc.cmd")
    if os.path.exists(local_bin):
        return local_bin
    local_bin_sh = os.path.join(ROOT_DIR, "node_modules", ".bin", "mmdc")
    if os.path.exists(local_bin_sh):
        return local_bin_sh
    # Cek global PATH
    try:
        res = subprocess.run(["where", "mmdc"], capture_output=True, text=True)
        if res.returncode == 0 and res.stdout.strip():
            return res.stdout.splitlines()[0].strip()
    except Exception:
        pass
    return None

def render_via_mmdc(mmdc_bin, mmd_file, png_file):
    cmd = [
        mmdc_bin,
        "-i", mmd_file,
        "-o", png_file,
        "-s", "3",           # Scale 3x (High-Res 300dpi style)
        "-b", "white",       # Background putih bersih untuk skripsi/laporan
    ]
    res = subprocess.run(cmd, capture_output=True, text=True)
    if res.returncode != 0:
        raise RuntimeError(f"mmdc error: {res.stderr}")
    return True

def render_via_kroki(mmd_file, png_file):
    with open(mmd_file, "r", encoding="utf-8") as f:
        diagram_text = f.read()
    
    # Kroki URL encoding: deflate + base64url
    compressed = zlib.compress(diagram_text.encode("utf-8"), 9)
    encoded = base64.urlsafe_b64encode(compressed).decode("ascii")
    url = f"https://kroki.io/mermaid/png/{encoded}"

    req = urllib.request.Request(
        url,
        headers={"User-Agent": "MSDC-Doc-Generator/1.0"}
    )
    with urllib.request.urlopen(req, timeout=30) as resp:
        data = resp.read()
    with open(png_file, "wb") as f:
        f.write(data)
    return True

def main():
    mmd_files = glob.glob(os.path.join(SOURCE_DIR, "**", "*.mmd"), recursive=True)
    if not mmd_files:
        print(f"[INFO] Belum ada berkas .mmd di '{SOURCE_DIR}'.")
        print("Silakan letakkan diagram Mermaid mentah (.mmd) di folder tersebut.")
        return

    print(f"[INFO] Ditemukan {len(mmd_files)} diagram untuk dirender...")
    mmdc_bin = find_mmdc()
    if mmdc_bin:
        print(f"[INFO] Menggunakan Mermaid CLI lokal: {mmdc_bin}")
    else:
        print("[INFO] Mermaid CLI lokal belum terinstal. Menggunakan fallback Kroki Engine...")

    success = 0
    failed = 0

    for mmd_path in mmd_files:
        rel_path = os.path.relpath(mmd_path, SOURCE_DIR)
        rel_dir = os.path.dirname(rel_path)
        basename = os.path.splitext(os.path.basename(mmd_path))[0]
        
        target_dir = os.path.join(RENDERED_DIR, rel_dir)
        os.makedirs(target_dir, exist_ok=True)
        png_path = os.path.join(target_dir, f"{basename}.png")
        
        display_name = os.path.join(rel_dir, f"{basename}.mmd") if rel_dir else f"{basename}.mmd"
        print(f"  Rendering: {display_name} -> {basename}.png ... ", end="", flush=True)

        try:
            if mmdc_bin:
                try:
                    render_via_mmdc(mmdc_bin, mmd_path, png_path)
                except Exception as ex:
                    # Fallback to kroki if mmdc encounters puppeteer browser issues
                    render_via_kroki(mmd_path, png_path)
            else:
                render_via_kroki(mmd_path, png_path)

            print("SUKSES")
            success += 1
        except Exception as e:
            print(f"GAGAL ({e})")
            failed += 1

    print(f"\n[SELESAI] Total: {len(mmd_files)} | Berhasil: {success} | Gagal: {failed}")
    print(f"Hasil render tersimpan di: {RENDERED_DIR}")

if __name__ == "__main__":
    main()
