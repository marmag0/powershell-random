# .\zadanie1.ps1 -outputPath <path>

param([string]$outputPath = "failed_logins.csv")

# Pobranie zdarzeń nieudanych logowań (4625) z ostatnich 14 dni
Write-Host "Pobieranie zdarzeń Security (4625) z ostatnich 14 dni..." -ForegroundColor Yellow
$startDate = (Get-Date).AddDays(-14)
$events = Get-WinEvent -FilterHashtable @{LogName='Security'; Id=4625; StartTime=$startDate} -ErrorAction SilentlyContinue

if (-not $events) {
    Write-Host "Nie znaleziono nieudanych prób logowania." -ForegroundColor Green
    exit
}

$report = $events | ForEach-Object {
    [PSCustomObject]@{
        TimeCreated      = $_.TimeCreated
        TargetUserName   = $_.Properties[5].Value
        TargetDomainName = $_.Properties[6].Value
        IpAddress        = $_.Properties[19].Value
        WorkstationName  = $_.Properties[13].Value
        LogonType        = $_.Properties[10].Value
        FailureReason    = $_.Properties[8].Value
        SubStatus        = $_.Properties[9].Value
    }
}

# Wyświetlenie i zapis do CSV
$report | Out-GridView -Title "Raport nieudanych logowań"
$report | Export-Csv -Path $outputPath -NoTypeInformation -Encoding UTF8

# Statystyka IP
$topIp = $report | Group-Object IpAddress | Sort-Object Count -Descending | Select-Object -First 1
$lastTime = ($report | Where-Object IpAddress -eq $topIp.Name | Sort-Object TimeCreated -Descending | Select-Object -First 1).TimeCreated

Write-Host "`nNajwięcej prób z IP: $($topIp.Name) (Liczba: $($topIp.Count))" -ForegroundColor Cyan
Write-Host "Ostatnia próba z tego adresu: $lastTime" -ForegroundColor Cyan

# Grupowanie na ekranie
Write-Host "`nLiczba nieudanych logowań według adresów IP:" -ForegroundColor Yellow
$report | Group-Object IpAddress | Select-Object @{Name="Adres IP"; Expression={$_.Name}}, Count | Sort-Object Count -Descending | Format-Table -AutoSize

Write-Host "Raport zapisano w: $outputPath" -ForegroundColor Green