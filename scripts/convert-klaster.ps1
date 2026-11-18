# Skrip Otomasi Konversi Catatan Bedah Klaster (Standar UPN 'Veteran' Jawa Timur)
# Lokasi: scripts/convert-klaster.ps1

$ErrorActionPreference = "Stop"

$localBin = Join-Path $env:LOCALAPPDATA "laporan-generator\bin"
if ((Test-Path $localBin) -and ($env:Path -notlike "*$localBin*")) {
    $env:Path = "$localBin;$env:Path"
}

$root = Resolve-Path (Join-Path $PSScriptRoot "..")
$mdDir = Join-Path $root "00-bedah-klaster\data-center-ops\md"
$docxDir = Join-Path $root "00-bedah-klaster\data-center-ops\docx"
$pdfDir = Join-Path $root "00-bedah-klaster\data-center-ops\pdf"
$refDocx = Join-Path $root "scripts\reference-klaster.docx"
$typstTpl = Join-Path $root "scripts\template-klaster.typ"

New-Item -ItemType Directory -Path $docxDir -Force | Out-Null
New-Item -ItemType Directory -Path $pdfDir -Force | Out-Null

$files = Get-ChildItem -Path $mdDir -Filter "klaster-*.md"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "   KONVERSI BEDAH KLASTER (UPN 'VETERAN' JAWA TIMUR)      " -ForegroundColor Cyan
Write-Host "   Engine: Pandoc + Typst + Reference DOCX                " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host ""

Set-Location $mdDir

foreach ($f in $files) {
    $base = $f.BaseName
    $docxOut = Join-Path $docxDir "$base.docx"
    $pdfOut = Join-Path $pdfDir "$base.pdf"

    Write-Host "--> Memproses: $($f.Name)..." -ForegroundColor Yellow

    # 1. Konversi ke DOCX dengan template referensi Times New Roman
    try {
        & pandoc -s $f.Name --reference-doc=$refDocx -o $docxOut
        if ($LASTEXITCODE -eq 0) {
            Write-Host "    [SUKSES] DOCX: $docxOut" -ForegroundColor Green
        } else {
            Write-Host "    [GAGAL] DOCX: $docxOut (Exit code: $LASTEXITCODE)" -ForegroundColor Red
        }
    } catch {
        Write-Host "    [ERROR] DOCX: $_" -ForegroundColor Red
    }

    # 2. Konversi ke PDF via Typst Engine dengan template akademik
    try {
        & pandoc -s $f.Name --pdf-engine=typst --template=$typstTpl -o $pdfOut
        if ($LASTEXITCODE -eq 0) {
            Write-Host "    [SUKSES] PDF : $pdfOut" -ForegroundColor Green
        } else {
            Write-Host "    [GAGAL] PDF : $pdfOut (Exit code: $LASTEXITCODE)" -ForegroundColor Red
        }
    } catch {
        Write-Host "    [ERROR] PDF : $_" -ForegroundColor Red
    }
}

Set-Location $root
Write-Host ""
Write-Host "Konversi selesai! Berkas tersimpan di folder docx/ dan pdf/." -ForegroundColor Green
