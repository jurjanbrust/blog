# Copyright (C) www.jurjan.info - All Rights Reserved
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

. ".\environment.ps1"

Add-Type -Path "$PSScriptRoot\Microsoft.SharePoint.Client.dll" 
Add-Type -Path "$PSScriptRoot\Microsoft.SharePoint.Client.Runtime.dll"

if ($null -eq $endIndex) {
    Write-Host "check environment.ps1, missing endIndex" -ForegroundColor Yellow
    break
}

function checkIfWebExists($url, $listName) {
    $clientContext = New-Object Microsoft.SharePoint.Client.ClientContext($url);
    $clientContext.RequestTimeout = 5000
    $currentWeb = $clientContext.Web;
    $lists = $currentWeb.Lists
    $clientContext.Load($lists)
    $clientContext.Load($currentWeb)
    
    try {
        $clientContext.ExecuteQuery();
        Write-Host " OK" -ForegroundColor Green 
        $listExists = $lists | Where-Object { $_.Title -eq $listName }
        if (-Not $listExists) {
            Write-Host $listName "not found" -ForegroundColor Red
        }
    } 
    catch {
        Write-Host " $url does not exist" -ForegroundColor Red
    }
}

Write-Host "Processing ($startIndex-$endIndex)" -ForegroundColor Green
$input = Import-Csv -Path $listsFile

$i = 1
foreach ($line in $input) {
    if ($i -lt $startIndex) {
        $i++
        continue
    }

    $url = $line.Url

    Write-Host "[$i / $endIndex] $url       $($line.ListName)" -NoNewline -ForegroundColor Yellow
    checkIfWebExists $url $line.ListName

    if ($i++ -ge $endIndex) {
        Write-Host "break because of endIndex limit" -ForegroundColor Red
        break
    }
}

