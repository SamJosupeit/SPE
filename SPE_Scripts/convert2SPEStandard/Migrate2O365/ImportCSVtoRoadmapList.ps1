
$url = "http://migrate2o365.mt-ag.com"
$pathsCsv = @(
    "C:\Scripts\Migrate2O365\SiteInventory_intranet.mt-ag.com.csv",
    "C:\Scripts\Migrate2O365\SiteInventory_migration.mt-ag.com.csv" #,
#    "C:\Scripts\Migrate2O365\SiteInventory_mysite.mt-ag.com.csv",
#    "C:\Scripts\Migrate2O365\SiteInventory_SharePoint - 10000.csv",
#    "C:\Scripts\Migrate2O365\SiteInventory_SharePoint - Migrate2O365.csv"
)
$web = get-spweb $url
$list = $web.lists["Roadmap Websites"]
Write-Host "Deleting Existing ListItems"
#region delete all items
#<#
$items = $list.items
foreach($item in $items)
{
    $list.GetItemById($item.ID).Delete()
    Write-Host "." -NoNewline
}
#>
#endregion
Write-Host "Importing new ListItems"
$countNewItems = 0
foreach($pathCsv in $pathsCsv)
{
    $csv = import-csv -Delimiter "," -Path $pathCsv

    #region Importing new Items
    #<#
    try{
        foreach($csvItem in $csv){
            $newItem = $list.AddItem()
            $newItem["Title"] = $csvItem.Title
            $newItem["Site_x0020_URL"] = $csvItem.Url
            $newItem["SiteCollection_x0020_Url"] = $csvItem.SiteUrl
            $newItem.Update()
            $countNewItems++
            $list.Update()
            Write-Host "." -NoNewline
        }
    }
    catch
    {
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName
        Write-Host $ErrorMessage
        Write-Host "--------"
        Write-host $FailedItem
    }
    #>
    #endregion
}
Write-Host "Created $countNewItems new items"
Write-host "Done!"