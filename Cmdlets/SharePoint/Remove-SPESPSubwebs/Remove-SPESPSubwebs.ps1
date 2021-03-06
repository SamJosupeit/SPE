#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        Remove-SPESPSubwebs.ps1                                #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

	#region Function Remove-SPESPSubwebs
    #.ExternalHelp SamsPowerShellEnhancements.psm1-help.xml
	function Remove-SPESPSubwebs
	{
        [CmdletBinding()]
        param
        ([Microsoft.SharePoint.SPWeb]$web)

        begin {
        }

        process {
			$WebUrl = $web.Url
			if($web.Webs.Count -gt 0)
			{
				if($global:ActivateTestLoggingVerbose){Write-SPELogMessage -message "Weitere SubWebSites vorhanden, iteriere tiefer...)"}
				foreach($subweb in $web.Webs)
				{
					Remove-SPESPSubwebs -web $subweb
				}
				if($global:ActivateTestLoggingVerbose){Write-SPELogMessage -message "...Alle SubWebSites auf dieser Ebene gelÃ¶scht"}
			}
			Remove-SPWeb $webUrl -Confirm:$false
			if($global:ActivateTestLoggingVerbose){Write-SPELogMessage -message "WebSite mit URL '$webUrl' gelÃ¶scht"}
		}
    }
	#endregion
    #EndOfFunction
