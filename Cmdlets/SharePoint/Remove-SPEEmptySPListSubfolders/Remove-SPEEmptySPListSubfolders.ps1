#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        Remove-SPEEmptySPListSubfolders.ps1                    #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

	#region Function Remove-SPEEmptySPListSubfolders
    #.ExternalHelp SamsPowerShellEnhancements.psm1-help.xml
	function Remove-SPEEmptySPListSubfolders
	{
        [CmdletBinding()]
        param
        (
			[Microsoft.SharePoint.SPFolder]$sourceFolder
		)

        begin {
        }

        process {
			Write-SPELogMessage -area "SPFolder" -category "Determining" -CorrelationId $CorrelationID -level "Verbose" -message "PrÃ¼fe, ob SPFolder '$($sourceFolder.Name)' leer ist und gelÃ¶scht werden kann."
			$folderRelativeUrl = $sourceFolder.ServerRelativeUrl
			$folderName = $sourceFolder.Name
			if(!($sourceFolder.ServerRelativeUrl -match "/Forms"))
			{
				$NoFilesInFolder = $false
				$NoSubFoldersInFolder = $false
				if($global:ActivateTestLoggingVerbose){Write-SPELogMessage -area "SPItem" -category "Determining" -CorrelationId $CorrelationID -level "Verbose" -message "PrÃ¼fe, ob keine Items vorhanden sind..."}
				if($sourceFolder.Items.Count -eq 0)
				{
					if($global:ActivateTestLoggingVerbose){Write-SPELogMessage -area "SPItem" -category "Determining" -CorrelationId $CorrelationID -level "Verbose" -message "Es sind keine Items vorhanden."}
					$NoFilesInFolder = $true
				}
				else 
				{
					if($global:ActivateTestLoggingVerbose){Write-SPELogMessage -area "SPItem" -category "Determining" -CorrelationId $CorrelationID -level "Verbose" -message "Es sind Items vorhanden. Ordner kann nicht gelÃ¶scht werden."}
				}
				if($global:ActivateTestLoggingVerbose){Write-SPELogMessage -area "SPFolder" -category "Determining" -CorrelationId $CorrelationID -level "Verbose" -message "PrÃ¼fe, ob keine SubFolders vorhanden sind..."}
				if($sourceFolder.SubFolders.Count -eq 0)
				{
					if($global:ActivateTestLoggingVerbose){Write-SPELogMessage -area "SPFolder" -category "Determining" -CorrelationId $CorrelationID -level "Verbose" -message "Es sind keine SubFolder vorhanden."}
					$NoSubFoldersInFolder = $true
				} else {
					foreach($subFolder in $sourceFolder.SubFolders)
					{
						if($global:ActivateTestLoggingVerbose){Write-SPELogMessage -area "SPFolder" -category "Determining" -CorrelationId $CorrelationID -level "Verbose" -message "Es sind SubFolder vorhanden. Iteriere tiefer..."}
						Remove-SPEEmptySPListSubfolders -sourceFolder $subFolder
						if($global:ActivateTestLoggingVerbose){Write-SPELogMessage -area "SPFolder" -category "Determining" -CorrelationId $CorrelationID -level "Verbose" -message "RÃ¼cksprung nach Iteration. ÃœberprÃ¼fe erneut auf vorhandene SubFolder..."}
						if($sourceFolder.subFolders.Count -eq 0)
						{
							if($global:ActivateTestLoggingVerbose){Write-SPELogMessage -area "SPFolder" -category "Determining" -CorrelationId $CorrelationID -level "Verbose" -message "Keine weiteren SubFolder vorhanden."}
							$NoSubFoldersInFolder = $true
						}
						else
						{
							if($global:ActivateTestLoggingVerbose){Write-SPELogMessage -area "SPFolder" -category "Determining" -CorrelationId $CorrelationID -level "Verbose" -message "Es sind weitere SubFolder vorhanden. Folder kann nicht gelÃ¶scht werden."}
						}
					}
				}
				if($NoFilesInFolder -and -$NoSubFoldersInFolder)
				{
					if($global:ActivateTestLoggingVerbose){Write-SPELogMessage -area "SPFolder" -category "Removing" -CorrelationId $CorrelationID -level "Verbose" -message "Folder '$folderName' besitzt keine Items oder SubFolder und kann gelÃ¶scht werden."}
					$parentFolder = $sourceFolder.ParentFolder
					if($global:ActivateTestLoggingVerbose){Write-SPELogMessage -area "SPFolder" -category "Removing" -CorrelationId $CorrelationID -level "Verbose" -message "LÃ¶sche Folder '$folderName'..."}
					if(!$TestModus)
					{
						$parentFolder.SubFolders.Delete($sourceFolder)
					}
					if($global:ActivateTestLoggingVerbose){Write-SPELogMessage -area "SPFolder" -category "Removed" -CorrelationId $CorrelationID -level "Verbose" -message "Folder '$folderName' wurde gelÃ¶scht..."}
				}
			} else {
				if($global:ActivateTestLoggingVerbose){Write-SPELogMessage -area "SPFolder" -category "Determining" -CorrelationId $CorrelationID -level "Medium" -message "Aktuelle Folder ist der FORMS-Folder"}
			}
		}
    }
	#endregion
    #EndOfFunction
