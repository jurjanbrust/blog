# Copyright (C) www.jurjanbrust.nl - All Rights Reserved (MIT License)

# change the following three lines to your likings
$url = "http://yourdevelopmentsitecollection/"
$listName = "sometestlist"
$itemsToCreate = 5010

$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path
Add-PSSnapin Microsoft.SharePoint.PowerShell -EA SilentlyContinue
Add-Type -Path "$ScriptDir\Microsoft.SharePoint.Client.dll" 
Add-Type -Path "$ScriptDir\Microsoft.SharePoint.Client.Runtime.dll"

# open the site
$clientContext = New-Object Microsoft.SharePoint.Client.ClientContext($url);
$web = $clientContext.Web;
$clientContext.Load($web)
$clientContext.ExecuteQuery()
Write-Host $web.Title $web.ServerRelativeUrl -ForegroundColor Red -BackgroundColor Yellow

# open the list, if no list is found it will create one
$list = $web.Lists.GetByTitle($listName);
$clientContext.Load($list)
try {
    $clientContext.ExecuteQuery()
    Write-Host "Opened list" $list.Title -ForegroundColor Red -BackgroundColor Yellow
} catch {
    Write-Host "No list found, creating a new one"
    $listCreateInfo = New-Object Microsoft.SharePoint.Client.ListCreationInformation;
    $listCreateInfo.Title = $listName; 
    $listCreateInfo.TemplateType = [Microsoft.SharePoint.Client.ListTemplateType]::GenericList
    $list = $web.Lists.Add($listCreateInfo)
    $list.Update(); 
    $clientContext.ExecuteQuery(); 

	# add some listfields for example purposes
	$a = $list.Fields.AddFieldAsXml("<Field Type='Choice' DisplayName='QuestionType'>
                            <CHOICES>
                                <CHOICE>Office 365</CHOICE>
                                <CHOICE>General</CHOICE>
                                <CHOICE>Email</CHOICE>
                                <CHOICE>OneDrive</CHOICE>
                                <CHOICE>SharePoint</CHOICE>
                                <CHOICE>Office Apps</CHOICE>
                                <CHOICE>Office Online</CHOICE>
                                <CHOICE>Other</CHOICE>
                            </CHOICES></Field>",$true,[Microsoft.SharePoint.Client.AddFieldOptions]::AddFieldToDefaultView)
}

# random words used to create listitems
$words = "Lorem","Ipsum","Donald","Duck","Wine","Chees","Fruit","Garlic","Weather","Together","Car","Pizza"
$choices = "Office 365", "General", "Email", "SharePoint"

for($index = 1; $index -lt $itemsToCreate+1; $index++) {
    $randomText = $words | Get-Random -count 1
    $titleText = "$index $randomText"
    Write-Host "[$index/$itemsToCreate] Creating '$titleText'" -ForegroundColor Green -BackgroundColor Red

    $newListItem = $list.AddItem($itemCreateInfo)
    $newListItem["Title"] =  $titleText
    $newListItem["QuestionType"] = $choices | Get-Random -count 1
    $newListItem.Update()
	if($index % 100 -eq 0)
	{
		Write-Host $index
		$clientContext.ExecuteQuery()
	}
}
$clientContext.ExecuteQuery()
Write-Host "Done!" -ForegroundColor Green
