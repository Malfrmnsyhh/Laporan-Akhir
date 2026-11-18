# Skrip Otomasi Konversi Catatan Bedah Klaster (Standar UPN 'Veteran' Jawa Timur)
# Engine: Python (python-docx + Pygments) untuk DOCX + MS Word COM Automation untuk PDF 100% Identik
# Lokasi: scripts/convert-klaster.ps1

param(
    [string]$Target = "all"
)

$ErrorActionPreference = "Stop"

$root = Resolve-Path (Join-Path $PSScriptRoot "..")
$bedahRoot = Join-Path $root "00-bedah-klaster"
$pythonEngine = Join-Path $root "scripts\md_to_docx.py"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "   KONVERSI BEDAH KLASTER (UPN 'VETERAN' JAWA TIMUR)      " -ForegroundColor Cyan
Write-Host "   Engine: Python (python-docx + Pygments) + MS Word PDF  " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host ""

$targetDirs = @()
if ($Target -eq "all") {
    $subDirs = Get-ChildItem -Path $bedahRoot -Directory
    foreach ($d in $subDirs) {
        $mdPath = Join-Path $d.FullName "md"
        if (Test-Path $mdPath) {
            $targetDirs += $d.FullName
        }
    }
} else {
    $specificDir = Join-Path $bedahRoot $Target
    if (Test-Path $specificDir) {
        $targetDirs += $specificDir
    } else {
        Write-Error "Direktori target '$Target' tidak ditemukan di $bedahRoot"
    }
}

$docxList = @()

foreach ($dir in $targetDirs) {
    $moduleName = (Get-Item $dir).Name
    $mdDir = Join-Path $dir "md"
    $docxDir = Join-Path $dir "docx"
    $pdfDir = Join-Path $dir "pdf"

    New-Item -ItemType Directory -Path $docxDir -Force | Out-Null
    New-Item -ItemType Directory -Path $pdfDir -Force | Out-Null

    $files = Get-ChildItem -Path $mdDir -Filter "*.md" | Sort-Object Name
    Write-Host "--> Memproses Modul: $moduleName ($($files.Count) berkas markdown)" -ForegroundColor Yellow

    foreach ($f in $files) {
        $base = $f.BaseName
        $docxOut = Join-Path $docxDir "$base.docx"
        $pdfOut = Join-Path $pdfDir "$base.pdf"

        try {
            & python $pythonEngine "$($f.FullName)" -o "$docxOut"
            if ($LASTEXITCODE -eq 0) {
                Write-Host "    [SUKSES] DOCX: $base.docx" -ForegroundColor Green
                $docxList += [PSCustomObject]@{
                    Docx = "$docxOut"
                    Pdf  = "$pdfOut"
                    Base = "$base"
                }
            } else {
                Write-Host "    [GAGAL] DOCX: $base.docx (Exit code: $LASTEXITCODE)" -ForegroundColor Red
            }
        } catch {
            Write-Host "    [ERROR] DOCX: $_" -ForegroundColor Red
        }
    }
}

Write-Host ""
Write-Host "[2/2] Mengonversi DOCX ke PDF via MS Word COM Automation..." -ForegroundColor Yellow

# ── 2. Konversi DOCX ke PDF via MS Word COM Automation ──
$word = $null
try {
    $word = New-Object -ComObject Word.Application
    $word.Visible = $false
    $word.DisplayAlerts = 0

    foreach ($item in $docxList) {
        $docxPath = [string]$item.Docx
        $pdfPath = [string]$item.Pdf
        $baseName = [string]$item.Base

        try {
            Write-Host "--> Export PDF: $baseName.pdf..." -ForegroundColor Cyan
            $doc = $word.Documents.Open($docxPath, $false, $true) # Read-Only
            # ExportAsFixedFormat: 17 = wdExportFormatPDF
            $doc.ExportAsFixedFormat($pdfPath, 17)
            $doc.Close([ref]$false)

            $fileInfo = Get-Item $pdfPath
            $sizeKb = [math]::Round($fileInfo.Length / 1KB, 1)
            Write-Host "    [SUKSES] PDF : $baseName.pdf ($sizeKb KB)" -ForegroundColor Green
        } catch {
            Write-Host "    [GAGAL] PDF : $baseName.pdf - $_" -ForegroundColor Red
        }
    }
} catch {
    Write-Host "[WARNING] Gagal menginisialisasi MS Word COM: $_" -ForegroundColor Yellow
} finally {
    if ($word -ne $null) {
        $word.Quit([ref]$false)
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($word) | Out-Null
    }
}

Write-Host ""
Write-Host "==========================================================" -ForegroundColor Green
Write-Host "   KONVERSI SELESAI DENGAN SEMPURNA!                      " -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green
