$HealthAndUsageApp = Get-SPUsageApplication | ?{$_.DisplayName -match "Health"}
if(!$HealthAndUsageApp)
{
    $HealthAndUsageApp = New-SPUsageApplication -Name "Usage and Health Data Collection" -DatabaseName "SP13_UsageAndHealth"
}
$svc = [Microsoft.SharePoint.Administration.SPWebService]::ContentService
$dds = $svc.DeveloperDashboardSettings
switch($dds.DisplayLevel){
    "Off" 
        {
            Write-Host "Developer Dashboard is off, switching on..."
            $dds.DisplayLevel = "On"
            break
        }
    "On" 
        {
            Write-Host "Developer Dashboard is on, switching off..."
            $dds.DisplayLevel = "Off"
            break
        }
    default
        {
            Write-Host "Cannot determing Visibility-State from Developer Dashboard!"
            exit
        }
}
$dds.Update()
Write-Host "...done."