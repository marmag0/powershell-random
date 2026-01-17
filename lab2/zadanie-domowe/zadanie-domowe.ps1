# .\zadanie-domowe.ps1 -FilePath <path_to_file>

# Getting arguments
param(
    [Parameter(Mandatory=$true)]
    [string]$FilePath
)

# Checking if the file exists
Write-Host "Checking if file exists..." -ForegroundColor Yellow
if (-not (Test-Path -Path $FilePath -PathType Leaf)) {
    Write-Host "Error! File not found or is a directory: $FilePath" -ForegroundColor Red
    exit 1
}

# Reading the file ADS
Write-Host "`nReading file ADS..." -ForegroundColor Yellow
Write-Host "--- Current ADS ---" -ForegroundColor Yellow
Get-Item -Path $FilePath -Stream * | Where-Object Stream -ne ':$DATA' | ForEach-Object {
    $content = Get-Content -Path $FilePath -Stream $_.Stream
    Write-Host "Found ADS: $($_.Stream) => $content" -ForegroundColor Cyan
}

# Adding new ADS to the file
Write-Host "`nAdding new ADS to the file..." -ForegroundColor Yellow
Set-Content -Path $FilePath -Stream "Recenzent" -Value "Jan Kowalski, Anna Nowak"
Set-Content -Path $FilePath -Stream "Sledztwo" -Value "Akta 32/2025"
Set-Content -Path $FilePath -Stream "Departament" -Value "DEV"

# Listing all ADS after addition
Write-Host "--- Updated ADS ---" -ForegroundColor Yellow
$streams = "Recenzent", "Sledztwo", "Departament"
foreach ($s in $streams) {
    $val = Get-Content -Path $FilePath -Stream $s
    Write-Host "$s = $val" -ForegroundColor Cyan
}

Write-Host "Script completed." -ForegroundColor Green