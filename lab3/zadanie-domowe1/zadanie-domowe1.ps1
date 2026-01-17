# .\zadanie-domowe1.ps1 -StartHoursAgo <hours>

param(
    [Parameter(Mandatory=$true)]
    [int]$StartHoursAgo
)

$timestamp = Get-Date -Format "yyyy-MM-dd-HH-mm"
$csvName = "windows_logons_$timestamp.csv"
$startTime = (Get-Date).AddHours(-$StartHoursAgo)

Write-Host "Pobieranie logowań z ostatnich $StartHoursAgo godzin..." -ForegroundColor Yellow

try {
    # Pobieramy zdarzenia 4624 (Success) i 4625 (Failure)
    $events = Get-WinEvent -FilterHashtable @{
        LogName   = 'Security'
        Id        = 4624, 4625
        StartTime = $startTime
    } -ErrorAction Stop
} catch {
    Write-Host "Brak zdarzeń lub błąd dostępu do dziennika." -ForegroundColor Red
    exit
}

$report = $events | ForEach-Object {
    $xml = [xml]$_.ToXml()
    # Mapowanie przestrzeni nazw XML dla bezpiecznego wyciągania danych
    $ns = New-Object System.Xml.XmlNamespaceManager($xml.NameTable)
    $ns.AddNamespace("e", "http://schemas.microsoft.com/win/2004/08/events/event")
    
    [PSCustomObject]@{
        TimeCreated    = $_.TimeCreated
        EventID        = $_.Id
        LogonType      = ($xml.SelectSingleNode("//e:Data[@Name='LogonType']", $ns)).'#text'
        Result         = if ($_.Id -eq 4624) { "Success" } else { "Failure" }
        TargetUserName = ($xml.SelectSingleNode("//e:Data[@Name='TargetUserName']", $ns)).'#text'
        IPAddress      = ($xml.SelectSingleNode("//e:Data[@Name='IpAddress']", $ns)).'#text'
        MachineName    = $_.MachineName
        Message        = $_.Message
    }
}

# Wyświetlanie tabeli w konsoli
$report | Format-Table TimeCreated, EventID, Result, TargetUserName, IPAddress -AutoSize

# Zapis do CSV
$report | Export-Csv -Path $csvName -NoTypeInformation -Encoding UTF8
Write-Host "Dane zapisane do: $csvName" -ForegroundColor Green