# Copyright (C) www.jurjan.info - All Rights Reserved (MIT License)

param(
	[Parameter(Mandatory=$True,Position=1)] [string]$url,
	[Parameter(Mandatory=$True,Position=2)] [string]$listTitle,
	[Parameter(Mandatory=$True,Position=3)] [string]$listItemID,
	[Parameter(Mandatory=$False,Position=4)] [string]$filter
)

Write-Host "usage: ListItems.ps1 [url] [listTitle] [listItemID] [filter]       (listItemID and filter is optional)" -ForegroundColor Yellow -BackgroundColor Green
if ($null -eq (Get-PSSnapin -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue))
{
    Add-PSSnapin Microsoft.SharePoint.PowerShell
}

try {
	Connect-PnPOnline -Url $url -CurrentCredentials -ReturnConnection
	$web = Get-PnPWeb -ErrorAction SilentlyContinue -Includes:Lists
	$list = Get-PnPList -Identity $listTitle -Includes:ContentTypes,ContentTypesEnabled,Title,Fields
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
	$listItems = Get-PnPListItem -List $list -ErrorAction:SilentlyContinue
	$listItems | Format-Table
}
else 
{
	Write-Host "Showing specific ListItem: " -BackgroundColor DarkGreen -ForegroundColor Black
	try {
		$listItem = Get-PnPListItem -List $list -Id $listItemID -ErrorAction:SilentlyContinue
	} catch {
		Write-Host "Listitem $listItemID does not exists" -ForegroundColor Red
		break
	}
	
	if(-not $filter)
	{
		foreach($key in $listItem.FieldValues.Keys)
		{
			$value = $listItem.FieldValues.$key
			Write-Host $key "[" $value "]`t`t" -ForegroundColor Yellow -BackgroundColor DarkRed
		}
	}
	else
	{
		foreach($key in $listItem.FieldValues.Keys)
		{
			$value = $listItem.FieldValues.$key
			if($key -match $filter) {
				Write-Host $key "[" $value "]`t`t" -ForegroundColor Yellow -BackgroundColor DarkRed
			}
		}
	}
}