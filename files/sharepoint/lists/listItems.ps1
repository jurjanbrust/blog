# Copyright (C) www.jurjan.info - All Rights Reserved
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

param(
	[Parameter(Mandatory=$True,Position=1)] [string]$url,
	[Parameter(Mandatory=$True,Position=2)] [string]$listTitle,
	[Parameter(Mandatory=$False,Position=3)] [string]$listItemID,
	[Parameter(Mandatory=$False,Position=4)] [string]$filter
)

Write-Host "usage: ListItems.ps1 [url] [listTitle] [listItemID] [filter]       (listItemID and filter is optional)" -ForegroundColor Yellow -BackgroundColor Green
if ($null -eq (Get-PSSnapin -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue))
{
    Add-PSSnapin Microsoft.SharePoint.PowerShell
}

try {
	$web = Get-SPWeb $url -ErrorAction SilentlyContinue
	$list = $web.Lists[$listTitle]
} catch {
	Write-Host "$url does not exist" -ForegroundColor Red
	break
}

if(-not $listItemID)
{
	Write-Host "ListItemID was not supplied, listing all listitems" -BackgroundColor DarkGreen -ForegroundColor Black
	if($null -eq $list)
	{
		Write-Host "No list found, showing all available lists" -ForegroundColor Red
		$web.Lists | ForEach-Object {
			Write-Host $_.Title
		}
	}
	$list.Items | Format-Table
}
else 
{
	Write-Host "Showing specific ListItem: " -BackgroundColor DarkGreen -ForegroundColor Black
	try {
		$listItem = $list.GetItemByID($listItemID)
	} catch {
		Write-Host "Listitem $listItemID does not exists" -ForegroundColor Red
		break
	}
	
	if(-not $filter)
	{
		$listItem.Fields | ForEach-Object {
	 		Write-Host $_.Title "[" $_.InternalName "]`t`t" -NoNewline -ForegroundColor Yellow -BackgroundColor DarkRed
	 		Write-Host $listItem[$_.InternalName] -ForegroundColor Yellow -BackgroundColor Red
		}
	}
	else
	{
		$listItem.Fields | Where-Object {$_.InternalName -match $filter} | ForEach-Object {
	 		Write-Host $_.Title "[" $_.InternalName "]`t`t" -NoNewline -ForegroundColor Yellow -BackgroundColor DarkRed
			Write-Host $listItem[$_.InternalName] -ForegroundColor Yellow -BackgroundColor Red
		}
	}
}