# ==============================================================================
# Manual Book Builder CLI Helper for Windows PowerShell (.\laporan.ps1)
# Modul Data Center Operations (Sistem ERP MSDC) — HKI Program Komputer
# ==============================================================================
param (
    [Parameter(Position=0)]
    [string]$Command = "help",
    [Parameter(Position=1)]
    [string]$SubCommand = "",
    [Parameter(ValueFromRemainingArguments=$true)]
    [string[]]$RemainingArgs
)

$ErrorActionPreference = "Stop"
$env:PYTHONUTF8 = "1"

$localBin = Join-Path $env:LOCALAPPDATA "laporan-generator\bin"
if ((Test-Path $localBin) -and ($env:Path -notlike "*$localBin*")) {
    $env:Path = "$localBin;$env:Path"
}

$generatorRoot = if (Test-Path (Join-Path $PSScriptRoot "..\laporan-generator\scripts\finalize-docx.py")) {
    (Resolve-Path (Join-Path $PSScriptRoot "..\laporan-generator")).Path
} else {
    $PSScriptRoot
}
$scriptsDir = Join-Path $generatorRoot "scripts"

$OutputPdf  = "Manual_Book_DC_Ops.pdf"
$OutputDocx = "Manual_Book_DC_Ops.docx"

$OrderedChapters = @(
    "bab1-pendahuluan.md",
    "bab2-akses-sistem.md",
    "bab3-analitik-utama.md",
    "bab4-panduan-workflow.md",
    "bab5-resources-code.md"
)

function Get-PythonCommand {
    foreach ($cmd in @("python", "python3")) {
        $c = Get-Command $cmd -ErrorAction SilentlyContinue
        if ($c -and ($c.Source -notmatch "WindowsApps\\python")) {
            return $c.Source
        }
    }
    $fallback = Get-Command "python" -ErrorAction SilentlyContinue
    if ($fallback) { return $fallback.Source }
    return ""
}

function Get-InputFiles {
    $chapterFiles = @()
    foreach ($chap in $OrderedChapters) {
        $chapPath = Join-Path "chapters" $chap
        if (Test-Path $chapPath) {
            $chapterFiles += (Resolve-Path $chapPath).Path
        }
    }
    return @("cover.md") + $chapterFiles
}

function Get-PresetOption {
    if (Test-Path "metadata.yml") {
        $content = Get-Content "metadata.yml" -Raw
        if ($content -match "(?:preset|margin_preset)\s*:\s*[`"']?([a-zA-Z0-9_-]+)[`"']?") {
            $presetName = $matches[1]
            $localPreset = Join-Path $PSScriptRoot "presets\$presetName.yml"
            if (Test-Path $localPreset) {
                return "--metadata-file=$localPreset"
            }
        }
    }
    return ""
}

function Show-Banner {
    Write-Host "  ========================================================" -ForegroundColor Cyan
    Write-Host "         MANUAL BOOK GENERATOR - HKI PROGRAM KOMPUTER     " -ForegroundColor Cyan
    Write-Host "     Modul Data Center Operations (Sistem ERP MSDC)       " -ForegroundColor Cyan
    Write-Host "  ========================================================" -ForegroundColor Cyan
    Write-Host ""
}

function Cmd-Build-PDF {
    Show-Banner
    Write-Host "Membangun Buku Panduan PDF (Typst Engine)..." -ForegroundColor Blue

    $inputFiles = Get-InputFiles
    $presetOpt = Get-PresetOption

    $pandocArgs = @()
    $pandocArgs += $inputFiles
    $pandocArgs += "--template=template.typ"
    if ($presetOpt) { $pandocArgs += $presetOpt }
    $pandocArgs += "--metadata-file=metadata.yml"
    $pandocArgs += "--top-level-division=chapter"
    $pandocArgs += "--pdf-engine=typst"
    $pandocArgs += "--syntax-highlighting=none"
    $pandocArgs += @("-o", $OutputPdf)

    & pandoc $pandocArgs
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "=== PDF BERHASIL DIBUAT ===" -ForegroundColor Green
        Write-Host "Lokasi: $(Get-Location)\$OutputPdf" -ForegroundColor Cyan
    } else {
        throw "Kompilasi PDF gagal (exit code $LASTEXITCODE)."
    }
}

function Cmd-Build-DOCX {
    Show-Banner
    Write-Host "Membangun Buku Panduan Microsoft Word (DOCX)..." -ForegroundColor Blue

    $pyCmd = Get-PythonCommand
    $inputFiles = Get-InputFiles
    $presetOpt = Get-PresetOption

    $tmpDocx  = [System.IO.Path]::GetTempFileName() + ".docx"
    $sectDocx = [System.IO.Path]::GetTempFileName() + ".docx"

    try {
        $pandocArgs = @()
        $pandocArgs += $inputFiles
        if ($presetOpt) { $pandocArgs += $presetOpt }
        $pandocArgs += "--metadata-file=metadata.yml"
        $pandocArgs += "--top-level-division=chapter"
        $pandocArgs += "--reference-doc=reference.docx"
        $pandocArgs += "--lua-filter=docx.lua"
        $pandocArgs += "--syntax-highlighting=none"
        $pandocArgs += @("-o", $tmpDocx)

        & pandoc $pandocArgs
        if ($LASTEXITCODE -ne 0) {
            throw "Kompilasi Pandoc ke DOCX gagal (exit code $LASTEXITCODE)."
        }

        if ($pyCmd -and (Test-Path (Join-Path $scriptsDir "finalize-docx.py"))) {
            & $pyCmd (Join-Path $scriptsDir "finalize-docx.py") $tmpDocx $sectDocx
            if ($LASTEXITCODE -ne 0) { throw "Pemrosesan struktur DOCX gagal." }
            & $pyCmd (Join-Path $scriptsDir "docx-pagenum.py") $sectDocx $OutputDocx
            if ($LASTEXITCODE -ne 0) { throw "Finalisasi nomor halaman DOCX gagal." }
        } else {
            Copy-Item -Path $tmpDocx -Destination $OutputDocx -Force
        }

        if (Test-Path $OutputDocx) {
            Write-Host ""
            Write-Host "=== DOCX BERHASIL DIBUAT ===" -ForegroundColor Green
            Write-Host "Lokasi: $(Get-Location)\$OutputDocx" -ForegroundColor Cyan
        } else {
            throw "Build DOCX berakhir tanpa menghasilkan $OutputDocx."
        }
    } finally {
        Remove-Item -Force -ErrorAction SilentlyContinue $tmpDocx, $sectDocx
    }
}

function Cmd-Build {
    Show-Banner
    Write-Host "[1/2] Membangun Dokumen PDF..." -ForegroundColor Blue
    Cmd-Build-PDF
    Write-Host ""
    Write-Host "[2/2] Membangun Dokumen DOCX..." -ForegroundColor Blue
    Cmd-Build-DOCX
    Write-Host ""
    Write-Host "Manual Book PDF dan DOCX berhasil diproses!" -ForegroundColor Green
}

function Cmd-Audit {
    param([string[]]$ArgsList)
    $pyCmd = Get-PythonCommand
    if ($pyCmd -and (Test-Path (Join-Path $scriptsDir "audit-forensics.py"))) {
        & $pyCmd (Join-Path $scriptsDir "audit-forensics.py") @ArgsList
    }
}

function Cmd-Clean {
    Remove-Item -Force -ErrorAction SilentlyContinue $OutputPdf, $OutputDocx
    Write-Host "[OK] Berkas output dibersihkan." -ForegroundColor Green
}

switch ($Command.ToLower()) {
    "build" { Cmd-Build }
    "pdf"   { Cmd-Build-PDF }
    "docx"  { Cmd-Build-DOCX }
    "audit" { Cmd-Audit $RemainingArgs }
    "clean" { Cmd-Clean }
    default {
        Show-Banner
        Write-Host "Perintah tersedia: .\laporan.ps1 [build | pdf | docx | audit | clean]" -ForegroundColor Yellow
    }
}
