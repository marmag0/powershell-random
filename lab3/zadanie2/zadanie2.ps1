# .\zadanie2.ps1 -outputPath <path>

param([string]$outputPath = "app_errors.csv")

# Pobranie zdarzeń Error i Warning z ostatnich 7 dni
Write-Host "Pobieranie zdarzeń Error i Warning z ostatnich 7 dni..." -ForegroundColor Yellow
$startDate = (Get-Date).AddDays(-7)

# Poziomy: 2 = Error, 3 = Warning
$events = Get-WinEvent -FilterHashtable @{LogName='Application'; Level=@(2,3); StartTime=$startDate} -ErrorAction SilentlyContinue

$report = $events | ForEach-Object {
    [PSCustomObject]@{
        TimeCreated      = $_.TimeCreated
        SourceName       = $_.ProviderName
        ProviderName     = $_.ProviderName
        EventID          = $_.Id
        Level            = $_.LevelDisplayName
        Message          = $_.Message.Split("`n")[0]
        FaultingApp      = if ($_.Id -eq 1000) { $_.Properties[0].Value } else { "N/A" }
    }
}

# Zapis do CSV
$report | Export-Csv -Path $outputPath -NoTypeInformation -Encoding UTF8

# Grupowanie według źródła
Write-Host "`nLiczba zdarzeń według źródła (Top 10):" -ForegroundColor Yellow
$report | Group-Object SourceName | Sort-Object Count -Descending | Select-Object -First 10 -Property Name, Count | Format-Table -AutoSize

# Liczba zdarzeń dla każdego poziomu
Write-Host "Ilość zdarzeń według poziomu:" -ForegroundColor Yellow
$report | Group-Object Level | Select-Object Name, Count | Format-Table -AutoSize

Write-Host "Raport zapisano w: $outputPath" -ForegroundColor Green