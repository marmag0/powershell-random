function Find-ProcessByName {
    param(
        [Parameter(Mandatory=$true)]
        [string]$ProcessName
    )

    Write-Host "Wyszukiwanie procesów pasujących do wzorca: '$ProcessName'..." -ForegroundColor Yellow
    
    # Pobieranie procesów (z obsługą wildcard np. *chrome*)
    $processes = Get-Process | Where-Object Name -Like "*$ProcessName*" -ErrorAction SilentlyContinue

    if (-not $processes) {
        Write-Host "Nie znaleziono procesów o nazwie pasującej do: $ProcessName" -ForegroundColor Red
        return
    }

    # Wyświetlanie szczegółów
    $data = $processes | Select-Object `
        Name, 
        Id, 
        @{Name="Memory_MB"; Expression={[Math]::Round($_.WorkingSet / 1MB, 2)}}

    $data | Format-Table -AutoSize

    # Podsumowanie
    $totalCount = $processes.Count
    $totalMem   = ($data | Measure-Object Memory_MB -Sum).Sum
    $avgMem     = ($data | Measure-Object Memory_MB -Average).Average

    Write-Host "--- PODSUMOWANIE ---" -ForegroundColor Cyan
    Write-Host "Łączna liczba procesów: $totalCount"
    Write-Host "Łączne zużycie RAM: $([Math]::Round($totalMem, 2)) MB"
    Write-Host "Średnie zużycie RAM: $([Math]::Round($avgMem, 2)) MB"
}

# Przykłady użycia:
# Find-ProcessByName -ProcessName "chrome"
# Find-ProcessByName "powershell"