# Copyright (C) www.jurjan.info - All Rights Reserved
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

. ".\environment.ps1"

if ($null -eq $endIndex) {
    Write-Host "check environment.ps1, missing endIndex" -ForegroundColor Yellow
    break
}

if ($null -eq $dstSiteUrl) {
    Write-Host "check environment.ps1, missing dstSiteUrl" -ForegroundColor Yellow
    break
}

$input = [Array](Import-Csv -Path $inputFile)

$i = 1
foreach ($line in $input) {
    if ($i -lt $startIndex) {
        $i++
        continue
    }

    $url = $line.SiteUrl
    Write-Host "$i-$endIndex [$url] -> [$dstSiteUrl]" -ForegroundColor DarkGray

    if ($i++ -ge $endIndex) {
        Write-Host "break because of endIndex limit" -ForegroundColor DarkYellow
        break
    }
}
