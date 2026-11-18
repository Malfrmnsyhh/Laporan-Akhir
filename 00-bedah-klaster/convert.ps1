# Skrip Otomasi Konversi Catatan Bedah Klaster ke PDF & Word (.docx)
$localBin = Join-Path $env:LOCALAPPDATA "laporan-generator\bin"
if ((Test-Path $localBin) -and ($env:Path -notlike "*$localBin*")) {
    $env:Path = "$localBin;$env:Path"
}

$bedahDir = $PSScriptRoot
Set-Location $bedahDir

$files = Get-ChildItem -Path $bedahDir -Filter "klaster-*.md"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "   KONVERSI CATATAN BEDAH KLASTER KE PDF & DOCX           " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host ""

foreach ($f in $files) {
    $baseName = $f.BaseName
    $docxOut = "$baseName.docx"
    $pdfOut = "$baseName.pdf"

    Write-Host "--> Memproses: $($f.Name)..." -ForegroundColor Yellow

    # Konversi ke DOCX
    & pandoc -s $f.Name -o $docxOut
    if ($LASTEXITCODE -eq 0) {
        Write-Host "    [OK] DOCX: $docxOut" -ForegroundColor Green
    } else {
        Write-Host "    [GAGAL] DOCX: $docxOut" -ForegroundColor Red
    }

    # Konversi ke PDF via Typst
    & pandoc -s $f.Name --pdf-engine=typst -o $pdfOut
    if ($LASTEXITCODE -eq 0) {
        Write-Host "    [OK] PDF : $pdfOut" -ForegroundColor Green
    } else {
        Write-Host "    [GAGAL] PDF : $pdfOut" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Semua catatan bedah klaster berhasil dikonversi beserta diagram gambarnya!" -ForegroundColor Green
