. ".\environment.ps1"

if($endIndex -eq $null) {
    Write-Host "check environment.ps1, missing endIndex" -ForegroundColor Yellow
    break
}

if($dstSiteUrl -eq $null) {
    Write-Host "check environment.ps1, missing dstSiteUrl" -ForegroundColor Yellow
    break
}

$input = [Array](Import-Csv -Path $inputFile)

$i = 1
foreach($line in $input) 
{
    if($i -lt $startIndex)
    {
        $i++
        continue
    }

    $url = $line.SiteUrl
    $projectNr = $url.split("/")[-1]


    Write-Host "$i-$endIndex [$url] -> [$dstSiteUrl/$projectNr]" -ForegroundColor DarkGray

    if($i++ -ge $endIndex) 
    {
        Write-Host "break because of endIndex limit" -ForegroundColor DarkYellow
        break
    }


}
