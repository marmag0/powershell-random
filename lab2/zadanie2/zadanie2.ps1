# .\zadanie2.ps1 -sourceDir <path> -csvFile <path> -logFile <path>

param(
    [Parameter(Mandatory=$true)] [string]$sourceDir,
    [Parameter(Mandatory=$true)] [string]$csvFile,
    [Parameter(Mandatory=$true)] [string]$logFile
)

# Checking if source directory exists
Write-Host "Checking if source directory exists..." -ForegroundColor Yellow
if (-not (Test-Path -Path $sourceDir -PathType Container)) {
    Write-Host "Error! Source directory not found: $sourceDir" -ForegroundColor Red
    exit 1
}

# Counting .txt and .log files (including subdirectories)
Write-Host "Counting files..." -ForegroundColor Yellow
$txtFiles = Get-ChildItem -Path $sourceDir -Filter *.txt -Recurse
$logFiles = Get-ChildItem -Path $sourceDir -Filter *.log -Recurse

$txtCount = $txtFiles.Count
$logCount = $logFiles.Count

Write-Host "Found $txtCount .txt files and $logCount .log files." -ForegroundColor Cyan

# Generating CSV with .txt file properties
Write-Host "Generating CSV file..." -ForegroundColor Yellow
$txtFiles | Select-Object Name, CreationTime, Length, Attributes | Export-Csv -Path $csvFile -NoTypeInformation -Encoding UTF8

# Writing to log file
Write-Host "Updating log file..." -ForegroundColor Yellow
$currentDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$logEntry = "[$currentDate] Found files - TXT: $txtCount, LOG: $logCount"

# Add-Content creates the file automatically if it doesn't exist
Add-Content -Path $logFile -Value $logEntry

Write-Host "Script completed." -ForegroundColor Green