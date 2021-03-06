#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        Test-SPEAndSetSPWeb.ps1                                #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

	#region Function Test-SPEAndSetSPWeb
    #.ExternalHelp SamsPowerShellEnhancements.psm1-help.xml
	function Test-SPEAndSetSPWeb
	{
#        EXAMPLE
#        $web = Test-SPEAndSetSPWeb -url "http://portal/website" -name "TestSite" -treeViewEnabled $false
        [CmdletBinding()]
        param
        (
			[String]$Url,
			[String]$Name,
            [String]$WebTemplate="STS#1",
			[Switch]$TreeViewEnabled,
            [Switch]$AddToQuickLaunch,
            [Switch]$UseParentTopNav
		)

        begin {
        }

        process {
			if($global:ActivateTestLoggingVerbose){Write-SPELogMessage -message "PrÃ¼fe WebSite $Url"}
			$web = Get-SPWeb $Url -ErrorAction SilentlyContinue
			if($web -eq $null)
			{
				if($global:ActivateTestLoggingVerbose){Write-SPELogMessage -message "WebSite $Url existiert nicht und wird neu erstellt..."}
                $commandString = 'New-SPWeb -Url "' + $Url + '" -Template "' + $WebTemplate + '" -Name "' + $name + '"'
                if($AddToQuickLaunch)
                {
                    $commandString += ' -AddToQuickLaunch'
                }
                if($UseParentTopNav)
                {
                    $commandString += ' -UseParentTopNav'
                }
                Set-SPEVariable -VariableName newweb -CommandString
				if($treeViewEnabled)
				{
					$newweb.TreeViewEnabled = $true
				}
				$newweb.Update()
                $web = $newweb
                $newweb.Dispose()
				if($global:ActivateTestLoggingVerbose){Write-SPELogMessage -message "...ZielWeb '$Url' wurde erstellt"}
			} else {
                if($global:ActivateTestLoggingVerbose){Write-SPELogMessage -message "ZielWeb '$Url' existiert bereits und wird verwendet."}
            }
            $web
            $web.Dispose()
			return
		}
    }
	#endregion
    #EndOfFunction
