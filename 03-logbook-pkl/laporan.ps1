# ==============================================================================
# Laporan Generator CLI Helper for Logbook PLK (.\laporan.ps1)
# ==============================================================================
param (
    [Parameter(Position=0)]
    [string]$Command = "build",
    [Parameter(Position=1)]
    [string]$SubCommand = "",
    [Parameter(ValueFromRemainingArguments=$true)]
    [string[]]$RemainingArgs
)

$ErrorActionPreference = "Stop"
$env:PYTHONUTF8 = "1"

$scriptRoot = $PSScriptRoot
$mdPath = Join-Path $scriptRoot "chapters\logbook.md"
$templateDocx = Join-Path $scriptRoot "LOGBOOK KEGIATAN PLK.docx"
$outDocx = Join-Path $scriptRoot "Logbook_Kegiatan_PLK.docx"
$outPdf = Join-Path $scriptRoot "Logbook_Kegiatan_PLK.pdf"
$genPy = Join-Path $scriptRoot "generate_logbook.py"
$pdfPs1 = Join-Path $scriptRoot "docx2pdf.ps1"

function Show-Banner {
    Write-Host "======================================================================" -ForegroundColor Cyan
    Write-Host "             LOGBOOK GENERATOR - UPN 'VETERAN' JAWA TIMUR              " -ForegroundColor Cyan
    Write-Host "                Mitra: PT Jawa Pos Media Televisi (JTV)                " -ForegroundColor Cyan
    Write-Host "======================================================================" -ForegroundColor Cyan
}

function Get-PythonCommand {
    foreach ($cmd in @("python", "python3")) {
        $c = Get-Command $cmd -ErrorAction SilentlyContinue
        if ($c) {
            if ($c.Source -match "WindowsApps\\python") {
                continue
            }
            return $c.Source
        }
    }
    $fallback = Get-Command "python" -ErrorAction SilentlyContinue
    if ($fallback) { return $fallback.Source }
    return ""
}

function Cmd-Build {
    Show-Banner
    Write-Host "[*] Memulai kompilasi Logbook dari Single Source of Truth (SSOT)..." -ForegroundColor Yellow
    Write-Host "    Sumber: $mdPath" -ForegroundColor Gray

    $py = Get-PythonCommand
    if (-not $py) {
        throw "Python 3 tidak ditemukan di lingkungan sistem."
    }

    # 1. Generate DOCX
    Write-Host "`n[1/2] Menghasilkan Dokumen Word (DOCX)..." -ForegroundColor Blue
    & $py $genPy
    if ($LASTEXITCODE -ne 0) {
        throw "Gagal mengompilasi Logbook DOCX."
    }
    Write-Host "      [OK] Terbuat: $outDocx" -ForegroundColor Green

    # 2. Export to PDF via Word COM
    Write-Host "`n[2/2] Mengonversi Dokumen ke PDF (Word COM Engine)..." -ForegroundColor Blue
    if (Test-Path $pdfPs1) {
        & powershell -NoProfile -ExecutionPolicy Bypass -File $pdfPs1 -DocxPath $outDocx -PdfPath $outPdf
        Write-Host "      [OK] Terbuat: $outPdf" -ForegroundColor Green
    } else {
        Write-Host "      [WARNING] docx2pdf.ps1 tidak ditemukan, lewati ekspor PDF." -ForegroundColor Yellow
    }

    Write-Host "`n======================================================================" -ForegroundColor Cyan
    Write-Host "STATUS KOMPILASI: SUKSES" -ForegroundColor Green
    if (Test-Path $outDocx) {
        $docxItem = Get-Item $outDocx
        Write-Host "DOCX : $($docxItem.FullName) ($([math]::Round($docxItem.Length / 1KB, 2)) KB)" -ForegroundColor White
    }
    if (Test-Path $outPdf) {
        $pdfItem = Get-Item $outPdf
        Write-Host "PDF  : $($pdfItem.FullName) ($([math]::Round($pdfItem.Length / 1KB, 2)) KB)" -ForegroundColor White
    }
    Write-Host "======================================================================`n" -ForegroundColor Cyan
}

function Cmd-Check {
    Show-Banner
    Write-Host "Pemeriksaan Berkas SSOT & Template..." -ForegroundColor Yellow
    Write-Host "  Template DOCX : $(Test-Path $templateDocx) ($templateDocx)"
    Write-Host "  SSOT Markdown : $(Test-Path $mdPath) ($mdPath)"
    Write-Host "  Generator Py  : $(Test-Path $genPy) ($genPy)"
    Write-Host "  Converter PS1 : $(Test-Path $pdfPs1) ($pdfPs1)"
}

switch ($Command.ToLower()) {
    "build" { Cmd-Build }
    "check" { Cmd-Check }
    default {
        Write-Host "Penggunaan:" -ForegroundColor Yellow
        Write-Host "  .\laporan.ps1 build   - Kompilasi chapters/logbook.md menjadi DOCX dan PDF"
        Write-Host "  .\laporan.ps1 check   - Periksa ketersediaan berkas dan dependensi"
    }
}
