# .\zadanie-domowe2.ps1 -StartHoursAgo <hours>

param(
    [Parameter(Mandatory=$true)]
    [int]$StartHoursAgo
)

$timestamp = Get-Date -Format "yyyy-MM-dd-HH-mm"
$csvName = "windows_events_$timestamp.csv"
$startTime = (Get-Date).AddHours(-$StartHoursAgo)

Write-Host "Zbieranie ważnych zdarzeń systemowych z ostatnich $StartHoursAgo godzin..." -ForegroundColor Yellow

# Definicja zdarzeń wg treści zadania
$idList = @(4720, 4722, 4723, 7045, 6005, 6006)

try {
    # Pobieramy z wielu dzienników naraz
    $events = Get-WinEvent -FilterHashtable @{
        LogName   = 'Security', 'System'
        Id        = $idList
        StartTime = $startTime
    } -ErrorAction Stop
} catch {
    Write-Host "Brak określonych zdarzeń w podanym czasie." -ForegroundColor Red
    exit
}

$report = $events | ForEach-Object {
    [PSCustomObject]@{
        TimeCreated  = $_.TimeCreated
        EventID      = $_.Id
        ProviderName = $_.ProviderName
        MachineName  = $_.MachineName
        Message      = $_.Message
    }
}

# Wyświetlanie tabeli w konsoli (bez kolumny Message dla czytelności)
$report | Select-Object * -ExcludeProperty Message | Format-Table -AutoSize

# Zapis do CSV (z pełną wiadomością)
$report | Export-Csv -Path $csvName -NoTypeInformation -Encoding UTF8
Write-Host "Raport zapisany do: $csvName" -ForegroundColor Green