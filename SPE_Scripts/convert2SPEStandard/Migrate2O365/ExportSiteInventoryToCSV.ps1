$webapps = Get-SPWebApplication 
try{
foreach($webApp in $webApps)
{
    $exportList = new-Object System.Collections.ArrayList
    $webAppName = $webApp.Name
    $csvPath = "C:\Scripts\Migrate2O365\SiteInventory_" + $webAppName + ".csv"
    foreach($site in $webApp.Sites)
    {
        $siteUrl = $site.Url
        foreach($web in $site.AllWebs)
        {
            $csvObj = New-Object System.Object
            $csvObj | Add-Member -NotePropertyName "Title" -NotePropertyValue $web.Title
            $csvObj | Add-Member -NotePropertyName "Url" -NotePropertyValue $web.Url
            $csvObj | Add-Member -NotePropertyName "SiteUrl" -NotePropertyValue $siteUrl
            $csvObj | Add-Member -NotePropertyName "ID" -NotePropertyValue $web.ID
            $csvObj | Add-Member -NotePropertyName "ParentWebID" -NotePropertyValue $web.ParentWebID
            $catchout = $exportList.Add($csvObj)
            Write-Host "." -NoNewline
        }
    }
    $exportList | Export-Csv -Path $csvPath -NoTypeInformation -Encoding unicode


}
}
catch{
    $ErrorMessage = $_.Exception.Message
    $FailedItem = $_.Exception.ItemName
    Write-Host $ErrorMessage
    Write-Host "--------"
    Write-host $FailedItem
}