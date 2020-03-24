# Copyright (C) www.jurjan.info - All Rights Reserved
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

. ".\environment.ps1"

if ($null -eq $endIndex) {
    Write-Host "check environment.ps1, missing endIndex" -ForegroundColor Yellow
    break
}

$input = [Array](Import-Csv -Path $listsFile)
$sites = [Array](Import-Csv -Path $sitesFile)

$i = 1
foreach ($line in $input) {
    if ($i -lt $startIndex) {
        $i++
        continue
    }
    
    $url = $line.Url
    $dstSiteUrl = $sites | Where-Object { $_.SourceUrl -eq $url }

    if ($null -eq $dstSiteUrl) {
        Write-Host "Destination URL not found"
        break
    }
    $dstSiteUrl = $dstSiteUrl.DestURL
    Write-Host "$i-$endIndex["$url/$($line.ListName)"] -> ["$dstSiteUrl"]" -ForegroundColor DarkGray -NoNewline

    $srcSite = Connect-Site -Url $url
    $dstSite = Connect-Site -Url $dstSiteUrl
    $srcList = Get-List -Site $srcSite -name $line.ListName
    if ($null -eq $srcList) {
        Write-Host "Source list not found"
        break
    }

    $mappings = New-MappingSettings	
    Import-UserAndGroupMapping -MappingSettings $mappings -Path "$(Get-Location)\UserAndGroupMappings.sgum" | Out-Null

    $copysettings = New-CopySettings -OnContentItemExists Skip
    $result = Copy-List -List $srcList -DestinationSite $dstSite -CopySettings $copysettings -MappingSettings $mappings
    Write-Host " Errors:" $result.Errors "Warnings:" $result.Warnings "Copied:" $result.ItemsCopied

    $statusMessage = "OK"
    if ($result.Warnings -gt 0) {
        $statusMessage = "Warning"
        Write-Host "Warning during copy" -ForegroundColor Yellow
    }
    if ($result.Errors -gt 0) {
        $statusMessage = "ERROR"
        Write-Host "Error during copy" -ForegroundColor Red
    }

    $filename = "$i-$($statusMessage).csv"
    Export-Report $result -Path "./log/$filename" -Overwrite | Out-Null
   
    Write-Host "Showing logfile errors and warnings ./log/$filename" -ForegroundColor Green
    $input = Import-Csv "./log/$filename"

    $input | ForEach-Object {
        if ($_.Status -eq "Error") {
            Write-Host "Error [$($_.Title)]" -NoNewline -ForegroundColor Magenta
            Write-Host $_.Details -ForegroundColor Red

        }
        if ($_.Status -eq "Warning") {
            Write-Host "Warning [$($_.Title)]" -NoNewline -ForegroundColor Magenta
            Write-Host $_.Details -ForegroundColor Yellow
        }
    }

    if ($i++ -ge $endIndex) {
        Write-Host "break because of endIndex limit" -ForegroundColor DarkYellow
        break
    }
}
