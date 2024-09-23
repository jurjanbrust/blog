# Copyright (C) www.jurjanbrust.nl - All Rights Reserved (MIT License)

$input = Import-Csv "./log/somelogfile.csv"

$input | ForEach-Object {
    if ($_.Status -eq "Error") {
        Write-Host "[$($_.Title)]" -NoNewline -ForegroundColor Magenta
        Write-Host $_.Details -ForegroundColor Red
    }
    if ($_.Status -eq "Warning") {
        Write-Host "[$($_.Title)]" -NoNewline -ForegroundColor Magenta
        Write-Host $_.Details -ForegroundColor Yellow
    }
}