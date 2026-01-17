# .\zadanie3.ps1 -TestDir <path>

param(
    [Parameter(Mandatory=$true)]
    [string]$TestDir
)

# Checking and creating test directory
Write-Host "Checking test directory..." -ForegroundColor Yellow
if (-not (Test-Path -Path $TestDir)) {
    New-Item -ItemType Directory -Path $TestDir | Out-Null
}

# Creating several .txt files
Write-Host "Creating sample files..." -ForegroundColor Yellow
1..5 | ForEach-Object {
    $fileName = "plik_$_.txt"
    $filePath = Join-Path -Path $TestDir -ChildPath $fileName
    "To jest zawartość pliku numer $_" | Set-Content -Path $filePath
}

# Collecting data and saving to CSV
Write-Host "Collecting file data and saving to CSV..." -ForegroundColor Yellow
$csvPath = Join-Path -Path $TestDir -ChildPath "raport_plikow.csv"

$fileData = Get-ChildItem -Path $TestDir -Filter *.txt | Select-Object `
    Name, 
    FullName, 
    @{Name="SizeKB"; Expression={$_.Length / 1KB}}, 
    CreationTime, 
    LastWriteTime

$fileData | Display-Table
$fileData | Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8

# Changing CreationTime to Jan 1st, 2000, 12:00
Write-Host "Updating creation dates..." -ForegroundColor Yellow
$newDate = Get-Date -Year 2000 -Month 1 -Day 1 -Hour 12 -Minute 0 -Second 0
Get-ChildItem -Path $TestDir -Filter *.txt | ForEach-Object {
    $_.CreationTime = $newDate
}

# Setting Hidden attribute for 2 files
Write-Host "Setting Hidden attribute for 2 files..." -ForegroundColor Yellow
Get-ChildItem -Path $TestDir -Filter *.txt | Select-Object -First 2 | ForEach-Object {
    $_.Attributes = "Hidden"
}

# Saving final report with attributes to .txt
Write-Host "Generating final TXT report..." -ForegroundColor Yellow
$reportPath = Join-Path -Path $TestDir -ChildPath "final_report.txt"

Get-ChildItem -Path $TestDir -Filter *.txt -Force | Select-Object `
    Name, 
    CreationTime, 
    LastWriteTime, 
    Attributes | Out-File -FilePath $reportPath

Write-Host "Script completed. Report saved in: $reportPath" -ForegroundColor Green