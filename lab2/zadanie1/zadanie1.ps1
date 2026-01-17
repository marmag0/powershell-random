# .\zadanie1.ps1 -sourceDir <path> -destinationDirTXT <path> -destinationDirLOG <path>

# Getting parameters
param(
    [Parameter(Mandatory=$true)]
    [string]$sourceDir,
    [Parameter(Mandatory=$true)]
    [string]$destinationDirTXT,
    [Parameter(Mandatory=$true)]
    [string]$destinationDirLOG
)

# Checking if source directory exists
Write-Host "Checking if source directory exists..." -ForegroundColor Yellow
if (-not (Test-Path -Path $sourceDir -PathType Container)) {
    Write-Host "Error! Source directory not found: $sourceDir" -ForegroundColor Red
    exit 1
}

# Creating destination directories if they don't exist
Write-Host "Checking if destination directories exist..." -ForegroundColor Yellow
if (-not (Test-Path -Path $destinationDirTXT -PathType Container)) {
    Write-Host "Creating destination directory for .txt files..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $destinationDirTXT | Out-Null 
}
if (-not (Test-Path -Path $destinationDirLOG -PathType Container)) {
    Write-Host "Creating destination directory for .log files..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $destinationDirLOG | Out-Null
}

# Copying .txt files
Write-Host "`nCopying .txt files..." -ForegroundColor Yellow
Get-ChildItem -Path $sourceDir -Filter *.txt | ForEach-Object {
    $destinationPath = Join-Path -Path $destinationDirTXT -ChildPath "kopia-$($_.Name)"
    Copy-Item -Path $_.FullName -Destination $destinationPath
}

# Copying .log files
Write-Host "`nCopying .log files..." -ForegroundColor Yellow
Get-ChildItem -Path $sourceDir -Filter *.log | ForEach-Object {
    $destinationPath = Join-Path -Path $destinationDirLOG -ChildPath "kopia-$($_.Name)"
    Copy-Item -Path $_.FullName -Destination $destinationPath
}

Write-Host "Script completed." -ForegroundColor Green