param (
    [string]$DocxPath,
    [string]$PdfPath
)

$ErrorActionPreference = "Stop"

$fullDocx = (Resolve-Path $DocxPath).Path
$fullPdf = [System.IO.Path]::GetFullPath($PdfPath)

Write-Host "Converting $fullDocx to $fullPdf via Word COM..."

$word = New-Object -ComObject Word.Application
$word.Visible = $false
try {
    $doc = $word.Documents.Open($fullDocx)
    # 17 = wdExportFormatPDF
    $doc.ExportAsFixedFormat($fullPdf, 17)
    $doc.Close($false)
    Write-Host "Successfully exported PDF: $fullPdf"
} finally {
    $word.Quit()
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($word) | Out-Null
    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()
}
